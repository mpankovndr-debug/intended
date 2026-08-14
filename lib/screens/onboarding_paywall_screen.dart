import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
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

  @override
  State<OnboardingPaywallScreen> createState() =>
      _OnboardingPaywallScreenState();
}

class _OnboardingPaywallScreenState extends State<OnboardingPaywallScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
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

    // Lazy-load offerings so the trial price renders correctly in the
    // disclaimer line. Triggers an App Store sign-in dialog on first call,
    // which is acceptable here — the user has just finished onboarding.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RevenueCatService>().ensureOfferings();
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
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    AnalyticsService.logPurchaseStarted(OnboardingPaywallScreen._plan);

    try {
      final success = await context
          .read<RevenueCatService>()
          .purchasePlan(OnboardingPaywallScreen._plan);
      if (!mounted) return;
      if (success) {
        AnalyticsService.logPurchaseCompleted(OnboardingPaywallScreen._plan);
        Navigator.of(context).pop(true);
      } else {
        // User cancelled the iOS purchase sheet — stay on the paywall and
        // let them choose again. RevenueCatService swallows
        // purchaseCancelledError and returns false, so this is the normal path.
        AnalyticsService.logPurchaseCancelled();
      }
    } catch (_) {
      AnalyticsService.logPurchaseFailed();
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

  void _handleContinueFree() {
    if (_isLoading) return;
    HapticFeedback.selectionClick();
    AnalyticsService.logPaywallDismissed(OnboardingPaywallScreen.source);
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final rc = context.watch<RevenueCatService>();
    final yearlyPrice = rc.yearlyPriceString ?? l10n.paywallYearlyPrice;

    // Block the system back gesture / hardware back. The user must choose
    // one of the two CTAs — there is no implicit dismiss.
    return PopScope(
      canPop: false,
      child: CupertinoPageScaffold(
        backgroundColor: colors.onboardingBg3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient — same palette as the final onboarding
            // screens so this feels like a continuation, not an interruption.
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

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: _BrandIcon(colors: colors),
                      ),
                    ),
                    const SizedBox(height: 32),

                    FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Text(
                          l10n.onboardingPaywallTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Three steps, not a wall (device review, SS1). Six
                    // sentences at the exact moment someone wants to get back
                    // to their first kept moment were being skipped whole;
                    // a journey reads at a glance. Still one CTA and no plan
                    // pickers — the wallet decision stays on the full paywall,
                    // this screen only opens the door.
                    FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Column(
                          children: [
                            for (final (i, step) in [
                              l10n.onboardingPaywallStep1,
                              l10n.onboardingPaywallStep2,
                              l10n.onboardingPaywallStep3,
                            ].indexed) ...[
                              if (i > 0) const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.ctaPrimary
                                          .withValues(alpha: 0.14),
                                      border: Border.all(
                                        color: colors.ctaPrimary
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: colors.ctaPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: colors.textPrimary
                                            .withValues(alpha: 0.85),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: _PrimaryCta(
                          colors: colors,
                          label: l10n.onboardingPaywallPrimaryCta,
                          isLoading: _isLoading,
                          onPressed: _handleStartTrial,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeTransition(
                      opacity: _fadeIn,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: _isLoading ? null : _handleContinueFree,
                        child: Text(
                          l10n.onboardingPaywallSecondaryCta,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    FadeTransition(
                      opacity: _fadeIn,
                      child: Text(
                        l10n.onboardingPaywallDisclaimer(yearlyPrice),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colors.textTertiary.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
              colorFilter:
                  ColorFilter.mode(colors.ctaPrimary, BlendMode.srcIn),
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
