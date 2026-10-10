import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/letter.dart';
import '../services/analytics_service.dart';
import '../services/moments_service.dart';
import '../services/plan_service.dart';
import '../services/review_request_service.dart';
import '../services/revenue_cat_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/app_toast.dart';

/// Soft paywall shown immediately after onboarding completion.
///
/// Two paths only: start the yearly free trial or continue with Core.
/// There is no close button and no swipe-to-dismiss — the user must make
/// an explicit choice. This is by design (matches Finch / Atoms pattern)
/// and keeps "Continue with Core" as the gentle, clearly-labelled exit.
///
/// The primary button waits (a spinner) until the store has answered, and
/// becomes a retry when it couldn't. It never says "free trial" unless the
/// live product carries a free intro offer, and never shows a typed-in
/// price: a claim the store hasn't confirmed is not made.
///
/// Pop value:
///  - `true`  — purchase succeeded.
///  - `false` — user chose Core, or a purchase attempt failed/was cancelled.
class OnboardingPaywallScreen extends StatefulWidget {
  const OnboardingPaywallScreen({super.key});

  /// Analytics source — keep distinct from other paywalls so the
  /// onboarding-soft funnel can be measured in isolation.
  static const String source = 'onboarding_soft';

  /// The plan we offer here. Yearly is the only plan with a free trial,
  /// and the "soft" moment is intentionally simpler than the full paywall.
  static const String _plan = 'yearly';

  /// Set once this paywall has been shown after a first completed action,
  /// from whichever door it came: onboarding's first moment or Today's
  /// first tap. Never shown twice.
  static const String firstCompletionShownKey =
      'first_completion_paywall_shown';

  /// Whether to show the paywall now, after a first completed action: once
  /// ever, and never to someone already subscribed. Claims the one showing
  /// when it says yes, so two doors cannot both show it.
  static Future<bool> claimFirstCompletion({required bool isPremium}) async {
    if (isPremium) return false;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(firstCompletionShownKey) == true) return false;
    await prefs.setBool(firstCompletionShownKey, true);
    return true;
  }

  @override
  State<OnboardingPaywallScreen> createState() =>
      _OnboardingPaywallScreenState();
}

class _OnboardingPaywallScreenState extends State<OnboardingPaywallScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;

  /// How many moments the person has. "Your first moment is already
  /// yours." is said only when that is literally one.
  int? _moments;
  late final AnimationController _entrance;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView('onboarding_paywall');
    AnalyticsService.logPaywallShown(OnboardingPaywallScreen.source);
    // Stand down the review prompt for the rest of this session so we don't
    // pile a "rate Intended" dialog on top of someone who just declined a trial.
    ReviewRequestService.markPaywallShown();
    MomentsService.getAll().then((all) {
      if (mounted) setState(() => _moments = all.length);
    });

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Lazy-load offerings so the price and the trial length come from the
    // store. Until they do, the button and the disclaimer paint a loading
    // state; if they can't, the service reports why and the button becomes
    // a retry.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<RevenueCatService>()
          .ensureOfferings(plan: OnboardingPaywallScreen._plan);
      _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _handleStartTrial() async {
    if (_isLoading) return;
    final rc = context.read<RevenueCatService>();
    const plan = OnboardingPaywallScreen._plan;

    // A tap with nothing to sell is not a cancel — it is the broken button
    // this screen used to record as purchase_cancelled. The button is only
    // enabled once the plan is purchasable, so this is the race guard: a
    // retry emptied the offering under the tap. The build already shows the
    // message and the retry for this state.
    final blocked = rc.unavailableReasonFor(plan);
    if (blocked != null) {
      AnalyticsService.logPurchaseUnavailable(
        blocked.analyticsValue,
        stage: 'tap',
        error: rc.lastUnavailableError,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    AnalyticsService.logPurchaseStarted(plan);

    try {
      final outcome = await rc.purchasePlan(plan);
      if (!mounted) return;
      switch (outcome) {
        case PurchaseOutcome.purchased:
          AnalyticsService.logPurchaseCompleted(plan);
          Navigator.of(context).pop(true);
        case PurchaseOutcome.cancelled:
          // The user closed the App Store sheet — stay on the paywall and
          // let them choose again.
          AnalyticsService.logPurchaseCancelled();
        case PurchaseOutcome.unavailable:
          AnalyticsService.logPurchaseUnavailable(
            (rc.unavailableReasonFor(plan) ??
                    PurchaseUnavailableReason.noPackage)
                .analyticsValue,
            stage: 'tap',
            error: rc.lastUnavailableError,
          );
        case PurchaseOutcome.entitlementMissing:
          // The store took the purchase and the entitlement stayed off: the
          // product isn't attached to Intended+ in the RevenueCat dashboard.
          // An error, never a cancel.
          AnalyticsService.logPurchaseEntitlementMissing();
          AppToast.show(
            context,
            AppLocalizations.of(context).boostPurchaseError,
          );
      }
    } catch (e) {
      AnalyticsService.logPurchaseFailed(e);
      if (mounted) {
        AppToast.show(
          context,
          AppLocalizations.of(context).boostPurchaseError,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleRetry() {
    HapticFeedback.selectionClick();
    context
        .read<RevenueCatService>()
        .retryOfferings(plan: OnboardingPaywallScreen._plan);
  }

  void _handleContinueFree() {
    if (_isLoading) return;
    HapticFeedback.selectionClick();
    AnalyticsService.logPaywallDismissed(OnboardingPaywallScreen.source);
    Navigator.of(context).pop(false);
  }

  /// The line under the button: a held space while the store answers, the
  /// retry message when it didn't, otherwise the price — with the trial in
  /// front of it only when the store's intro offer is free. Set at a size
  /// people can read: what they are agreeing to is not a footnote.
  Widget _disclaimer(
    AppLocalizations l10n,
    AppColorScheme colors,
    RevenueCatService rc, {
    required bool pricesLoading,
    required PurchaseUnavailableReason? blocked,
    required int? trialDays,
  }) {
    final style = TextStyle(
      fontFamily: AppTextStyles.bodyFont(context),
      fontSize: 13.5,
      color: colors.textSecondary,
      height: 1.45,
    );
    // Three lines of this style (the trial timeline); holding them keeps
    // the buttons still while the store answers.
    const held = SizedBox(height: 59);
    if (pricesLoading) return held;
    if (blocked != null) {
      return Text(
        l10n.paywallPricesUnavailable,
        textAlign: TextAlign.center,
        style: style,
      );
    }
    final price = rc.yearlyPriceString;
    if (price == null) return held;
    final String text;
    if (trialDays != null) {
      // The trial timeline. Both numbers are the store's intro offer; if it
      // can't say what the trial costs, the timeline doesn't render.
      final trialPrice =
          rc.freeTrialPriceStringForPlan(OnboardingPaywallScreen._plan);
      if (trialPrice == null) return held;
      text = [
        l10n.paywallTimelineToday(trialPrice),
        l10n.paywallTimelineRenewsYearly(trialDays, price),
        l10n.paywallTimelineCancel,
      ].join('\n');
    } else {
      final perMonth = rc.yearlyPerMonthString;
      text = perMonth == null
          ? l10n.paywallHintYearlyNoTrial(price)
          : l10n.onboardingPaywallDisclaimerNoTrial(price, perMonth);
    }
    return Text(text, textAlign: TextAlign.center, style: style);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final colors = provider.colors;
    final l10n = AppLocalizations.of(context);
    final rc = context.watch<RevenueCatService>();
    final status = rc.offeringsStatus;
    final pricesLoading = status == OfferingsStatus.pending ||
        status == OfferingsStatus.loading;
    final blocked = pricesLoading
        ? null
        : rc.unavailableReasonFor(OnboardingPaywallScreen._plan);
    // Nothing here falls back to a typed-in number. Before the store answers
    // the screen shows a loading state; after it answers, a plan with no free
    // intro offer is sold without a trial claim.
    final trialDays = rc.freeTrialDaysForPlan(OnboardingPaywallScreen._plan);
    final ctaLabel = blocked != null
        ? l10n.paywallRetry
        : trialDays == null
            ? l10n.paywallCtaSubscribe
            : l10n.onboardingPaywallPrimaryCta;
    final body = AppTextStyles.bodyFont(context);
    const gutter = 24.0;

    Widget enter(Widget child) => FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(position: _slideUp, child: child),
        );

    // Block the system back gesture / hardware back. The user must choose
    // one of the two CTAs — there is no implicit dismiss.
    return PopScope(
      canPop: false,
      child: CupertinoPageScaffold(
        backgroundColor: colors.onboardingBg3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Iris has its own painting (decided 6 Oct). The other themes
            // keep their gradient until each gets one: a lavender sunrise
            // under a dark theme's light text would be unreadable.
            if (provider.theme == AppTheme.iris)
              _Painting(colors: colors)
            else ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0.15, -1.0),
                    end: const Alignment(-0.15, 1.0),
                    colors: [
                      colors.onboardingBg1,
                      colors.onboardingBg2,
                      colors.onboardingBg3,
                      colors.onboardingBg4,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
              _BackgroundOrbs(colors: colors),
            ],

            SafeArea(
              child: LayoutBuilder(
                builder: (context, viewport) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: gutter),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewport.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          enter(_BrandIcon(colors: colors)),
                          const SizedBox(height: 24),
                          enter(_Glow(
                            child: Column(
                              children: [
                                _Title(
                                  text: l10n.onboardingPaywallTitle,
                                  width: MediaQuery.sizeOf(context).width -
                                      2 * gutter,
                                  style: TextStyle(
                                    // Sora has no Cyrillic (CLAUDE.md).
                                    fontFamily: AppTextStyles.displayFontFor(
                                        Localizations.localeOf(context)
                                            .toString()),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                                if (_moments == 1) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    l10n.onboardingPaywallFirstMoment,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: body,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                      color: colors.ctaSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )),
                          const SizedBox(height: 28),

                          // Only what Intended+ adds, each with when it
                          // arrives (6 Oct): the free mosaic is not on a
                          // screen asking for money, and someone deciding
                          // on day 14 knows the plan is still coming. The
                          // numbers come from the thresholds themselves.
                          enter(_Cycle(
                            width:
                                MediaQuery.sizeOf(context).width - 2 * gutter,
                            colors: colors,
                            steps: [
                              (
                                l10n.onboardingPaywallLetter,
                                l10n.onboardingPaywallLetterWhen(
                                    Letter.minMoments),
                              ),
                              (
                                l10n.onboardingPaywallPlan,
                                l10n.onboardingPaywallPlanWhen,
                              ),
                              (
                                l10n.onboardingPaywallReview,
                                l10n.onboardingPaywallReviewWhen(
                                    PlanService.windowDays ~/ 7),
                              ),
                            ],
                          )),
                          const SizedBox(height: 18),
                          FadeTransition(
                            opacity: _fadeIn,
                            child: Text(
                              l10n.onboardingPaywallLoop,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: body,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: colors.ctaSecondary,
                              ),
                            ),
                          ),

                          const Spacer(flex: 3),
                          const SizedBox(height: 24),

                          enter(_PrimaryCta(
                            colors: colors,
                            label: ctaLabel,
                            isLoading: _isLoading || pricesLoading,
                            onPressed:
                                blocked != null ? _handleRetry : _handleStartTrial,
                          )),
                          const SizedBox(height: 14),

                          // The price sits right under the button, at a
                          // size people can read: what they are agreeing to
                          // is not a footnote.
                          FadeTransition(
                            opacity: _fadeIn,
                            child: _disclaimer(
                              l10n,
                              colors,
                              rc,
                              pricesLoading: pricesLoading,
                              blocked: blocked,
                              trialDays: trialDays,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FadeTransition(
                            opacity: _fadeIn,
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed:
                                  _isLoading ? null : _handleContinueFree,
                              child: Text(
                                l10n.onboardingPaywallSecondaryCta,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: body,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: colors.ctaSecondary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: colors.ctaSecondary
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Iris's paywall painting under a wash, so the words stay first.
class _Painting extends StatelessWidget {
  const _Painting({required this.colors});

  final AppColorScheme colors;

  static const String asset = 'assets/images/paywall_sunrise_iris.webp';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.onboardingBg1.withValues(alpha: 0.45),
                colors.onboardingBg2.withValues(alpha: 0.55),
                colors.onboardingBg3.withValues(alpha: 0.6),
                colors.onboardingBg4.withValues(alpha: 0.82),
              ],
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// The headline. A title with its own line breaks (the Russian one is two
/// sentences, one per line: 6 Oct) keeps them: the size steps down until
/// every line fits on one line, rather than each wrapping in two. A title
/// without breaks wraps as usual.
class _Title extends StatelessWidget {
  const _Title({required this.text, required this.width, required this.style});

  final String text;
  final double width;
  final TextStyle style;

  static const double smallest = 20;

  /// The largest size, from [style]'s down to [smallest], at which each of
  /// [lines] fits within [width].
  static double fit(
      List<String> lines, TextStyle style, double width, TextScaler scaler) {
    for (var size = style.fontSize!; size > smallest; size -= 0.5) {
      final fits = lines.every((line) {
        final painter = TextPainter(
          text: TextSpan(text: line, style: style.copyWith(fontSize: size)),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout();
        return painter.width <= width;
      });
      if (fits) return size;
    }
    return smallest;
  }

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final size = lines.length > 1
        ? fit(lines, style, width, MediaQuery.textScalerOf(context))
        : style.fontSize!;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: style.copyWith(fontSize: size),
    );
  }
}

/// A soft, very light blue light behind words that sit on the painting, so
/// they lift off it without a box around them (6 Oct: light blue, never
/// white-white). A heavily blurred oval: it fades from the middle and has
/// no edge anywhere.
class _Glow extends StatelessWidget {
  const _Glow({
    required this.child,
    this.spread = 18,
    this.strength = 0.85,
  });

  final Widget child;

  /// How far past the words the light reaches.
  final double spread;
  final double strength;

  static const Color light = Color(0xFFE4ECFF);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlowPainter(
        color: light.withValues(alpha: strength),
        spread: spread,
      ),
      child: child,
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.color, required this.spread});

  final Color color;
  final double spread;

  @override
  void paint(Canvas canvas, Size size) {
    final area = (Offset.zero & size).inflate(spread);
    final sigma = area.shortestSide * 0.28;
    canvas.drawOval(
      area,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.color != color || old.spread != spread;
}

/// The three things Intended+ adds, as the loop they make: a letter, a plan,
/// and whether the plan's changes helped. Each step says when it arrives.
///
/// The dots sit on one circle and the arrows are arcs of it (6 Oct); the arc
/// from 2 back round to 3 is flatter than the circle, because the full curve
/// would run through the labels under 2 and 3.
///
/// Laid out from measured text, not fixed boxes, so Russian's longer lines
/// push the drawing taller instead of spilling out of it (the reason a
/// circle was once rejected here).
class _Cycle extends StatelessWidget {
  const _Cycle({
    required this.width,
    required this.colors,
    required this.steps,
  });

  final double width;
  final AppColorScheme colors;

  /// (what, when), in order.
  final List<(String, String)> steps;

  static const double _dot = 52;
  static const double _gap = 8;

  /// How far the arc from 2 to 3 dips below the dots.
  static const double _dip = 22;

  @override
  Widget build(BuildContext context) {
    final body = AppTextStyles.bodyFont(context);
    final scaler = MediaQuery.textScalerOf(context);
    final whatStyle = TextStyle(
      fontFamily: body,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: colors.textPrimary,
    );
    final whenStyle = TextStyle(
      fontFamily: body,
      fontSize: 14,
      height: 1.3,
      color: colors.textSecondary,
    );

    double measure(String text, TextStyle style, double maxWidth) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout(maxWidth: maxWidth);
      return painter.height;
    }

    double labelHeight(int i, double w) =>
        measure(steps[i].$1, whatStyle, w) +
        2 +
        measure(steps[i].$2, whenStyle, w);

    final topWidth = width * 0.42;
    final sideWidth = width * 0.44;
    const r = _dot / 2;

    final p1 = Offset(width / 2, r);
    final y23 = r + r + _gap + labelHeight(0, topWidth) + 36 + r;
    final p2 = Offset(width - sideWidth / 2, y23);
    final p3 = Offset(sideWidth / 2, y23);
    final sides = [labelHeight(1, sideWidth), labelHeight(2, sideWidth)];
    final height = y23 + r + _gap + sides.reduce((a, b) => a > b ? a : b);

    // The circle through the three dots: centred on the middle line.
    final d = p2.dx - p1.dx;
    final cy = (d * d + y23 * y23 - r * r) / (2 * (y23 - r));
    final centre = Offset(width / 2, cy);
    final radius = cy - r;

    Widget dot(int n, Offset at) => Positioned(
          left: at.dx - r,
          top: at.dy - r,
          child: ExcludeSemantics(
            child: Container(
              width: _dot,
              height: _dot,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Glow.light.withValues(alpha: 0.8),
                border: Border.all(
                    color: colors.ctaPrimary.withValues(alpha: 0.35),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _Glow.light.withValues(alpha: 0.9),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '$n',
                style: TextStyle(
                  fontFamily: body,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.ctaPrimary,
                ),
              ),
            ),
          ),
        );

    Widget label(int i, double left, double top, double w) => Positioned(
          left: left,
          top: top,
          width: w,
          child: Semantics(
            sortKey: OrdinalSortKey(i.toDouble()),
            child: _Glow(
              spread: 14,
              strength: 0.85,
              child: Column(
                children: [
                  Text(steps[i].$1,
                      textAlign: TextAlign.center, style: whatStyle),
                  const SizedBox(height: 2),
                  Text(steps[i].$2,
                      textAlign: TextAlign.center, style: whenStyle),
                ],
              ),
            ),
          ),
        );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // A wide, soft light inside the circle, so the loop reads as one
          // object lifted off the painting.
          Positioned(
            left: centre.dx - radius * 0.85,
            top: centre.dy - radius * 0.85,
            width: radius * 1.7,
            height: radius * 1.7,
            child: const _Glow(
              spread: 0,
              strength: 0.7,
              child: SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _CyclePainter(
                centre: centre,
                radius: radius,
                p1: p1,
                p2: p2,
                p3: p3,
                inset: r + 6,
                dip: _dip,
                color: colors.ctaPrimary.withValues(alpha: 0.45),
              ),
            ),
          ),
          dot(1, p1),
          dot(2, p2),
          dot(3, p3),
          label(0, p1.dx - topWidth / 2, p1.dy + r + _gap, topWidth),
          label(1, width - sideWidth, p2.dy + r + _gap, sideWidth),
          label(2, 0, p3.dy + r + _gap, sideWidth),
        ],
      ),
    );
  }
}

/// The arrows of the loop, clockwise: 1 to 2 and 3 to 1 along the circle
/// through the dots, 2 to 3 along a flatter arc that stays above their
/// labels.
class _CyclePainter extends CustomPainter {
  _CyclePainter({
    required this.centre,
    required this.radius,
    required this.p1,
    required this.p2,
    required this.p3,
    required this.inset,
    required this.dip,
    required this.color,
  });

  final Offset centre;
  final double radius;
  final Offset p1, p2, p3;
  final double inset;
  final double dip;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color;

    // A filled head at [tip], pointing along [dir].
    void head(Offset tip, Offset dir) {
      final unit = dir / dir.distance;
      final side = Offset(-unit.dy, unit.dx);
      const len = 10.0, half = 5.5;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx + unit.dx * 2, tip.dy + unit.dy * 2)
          ..lineTo(tip.dx - unit.dx * len + side.dx * half,
              tip.dy - unit.dy * len + side.dy * half)
          ..lineTo(tip.dx - unit.dx * len - side.dx * half,
              tip.dy - unit.dy * len - side.dy * half)
          ..close(),
        fill,
      );
    }

    double angleOf(Offset p) => math.atan2(p.dy - centre.dy, p.dx - centre.dx);
    final gap = inset / radius;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // Along the circle, clockwise from [from] to [to] (radians), leaving
    // room around each dot.
    void along(double from, double to) {
      final start = from + gap;
      final end = to - gap;
      canvas.drawArc(rect, start, end - start, false, stroke);
      final tip = centre + Offset(math.cos(end), math.sin(end)) * radius;
      head(tip, Offset(-math.sin(end), math.cos(end)));
    }

    final a1 = angleOf(p1), a2 = angleOf(p2), a3 = angleOf(p3);
    along(a1, a2);
    along(a3, a1 + 2 * math.pi);

    // 2 to 3: a shallow arc under the dots, clockwise.
    final from = Offset(p2.dx - inset * 0.8, p2.dy + inset * 0.45);
    final to = Offset(p3.dx + inset * 0.8, p3.dy + inset * 0.45);
    final chord = (from - to).distance;
    final r2 = (chord * chord / 4 + dip * dip) / (2 * dip);
    canvas.drawPath(
      Path()
        ..moveTo(from.dx, from.dy)
        ..arcToPoint(to, radius: Radius.circular(r2), clockwise: true),
      stroke,
    );
    final c2 = Offset((from.dx + to.dx) / 2, from.dy + dip - r2);
    final v = to - c2;
    head(to, Offset(-v.dy, v.dx));
  }

  @override
  bool shouldRepaint(_CyclePainter old) =>
      old.centre != centre ||
      old.radius != radius ||
      old.p1 != p1 ||
      old.p2 != p2 ||
      old.p3 != p3 ||
      old.color != color;
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(255, 255, 255, 0.4),
                Color.fromRGBO(255, 255, 255, 0.2),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: 56,
            height: 56,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(colors.ctaPrimary, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/intended_icon_transparent.png',
                width: 56,
                height: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.colors,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final AppColorScheme colors;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 384),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.ctaPrimary.withValues(alpha: 0.30),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.ctaPrimary, colors.ctaSecondary],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(24),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const CupertinoActivityIndicator(color: Color(0xFFFFFFFF))
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
        ),
      ),
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: size.height * -0.05,
            right: size.width * 0.05,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.9,
                    colors: [
                      colors.surfaceLightest.withValues(alpha: 0.65),
                      colors.onboardingBg2.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            left: size.width * -0.08,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.35),
                    radius: 0.9,
                    colors: [
                      colors.onboardingBg1.withValues(alpha: 0.55),
                      colors.onboardingBg4.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
