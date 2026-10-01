import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../main.dart' show AppBackground;
import '../../theme/theme_provider.dart';
import '../../utils/text_styles.dart';
import '../../widgets/onboarding_progress_bar.dart';
import 'blur.dart';

/// The frame every screen of the new onboarding shares (spec §6): the app's
/// own painted background for the current theme, the step bar, an optional
/// headline, the screen's own content, and the primary button over a fade.
///
/// The older onboarding screens drew a flat gradient with two blurred orbs
/// and never showed the painting the rest of the app sits on; that was most
/// of why they felt like a form.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    this.ctaLabel,
    this.onCta,
    this.cta,
    required this.child,
    this.title,
    this.subtitle,
    this.onBack,
    this.footer,
  }) : assert((cta == null) != (ctaLabel == null),
            'Give either a standard button label or a custom cta');

  /// Onboarding is three steps in the bar: what you want, how you'll get
  /// there, and the first moment.
  static const int totalSteps = 3;

  /// Scrolling content pads its bottom by this, so nothing ends up under
  /// the button.
  static const double contentBottomPadding = 200;

  /// 1-based position in the step bar.
  final int step;
  final String? title;
  final String? subtitle;
  final Widget child;
  final String? ctaLabel;

  /// Null draws the button disabled.
  final VoidCallback? onCta;
  final VoidCallback? onBack;

  /// A quiet line under the button, such as "Skip for now".
  final Widget? footer;

  /// Replaces the standard button, for a screen whose action is not a tap
  /// (the hold on the sentence screen).
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final locale = Localizations.localeOf(context).toString();
    final ctaBottom = footer == null ? 60.0 : 88.0;
    final scope = OnboardingStepScope.maybeOf(context);

    // Inside the flow, what every screen shares holds still while the
    // content changes; on its own, the screen is drawn as it always was.
    Widget chrome(Widget w) =>
        scope == null ? w : Opacity(opacity: scope.chromeOpacity, child: w);
    Widget label(Widget w) =>
        scope == null ? w : Opacity(opacity: scope.labelOpacity, child: w);
    Widget content(Widget w) => scope == null
        ? w
        : scope.leaving
            ? BlurVeil(amount: scope.contentVeil, child: w)
            : BlurAppear(amount: scope.contentAppear, child: w);

    final body = Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: chrome(OnboardingProgressBar(
                  currentStep: step,
                  totalSteps: totalSteps,
                  onBack: onBack,
                )),
              ),
              Expanded(
                child: content(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title!,
                              style: TextStyle(
                                fontFamily:
                                    AppTextStyles.displayFontFor(locale),
                                fontSize: locale.startsWith('ru') ? 26 : 28,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                height: 1.25,
                                color: colors.textPrimary,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: colors.ctaSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    Expanded(child: child),
                  ],
                )),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: ctaBottom + 100,
          child: IgnorePointer(
            child: chrome(DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.onboardingBg4.withValues(alpha: 0.0),
                    colors.onboardingBg4.withValues(alpha: 0.92),
                    colors.onboardingBg4.withValues(alpha: 0.98),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            )),
          ),
        ),
        Positioned(
          left: 28,
          right: 28,
          bottom: ctaBottom,
          // The standard button's pill hands over and only its label
          // changes; a custom one changes whole, out and then in, so two
          // different labels never show at once.
          child: cta == null
              ? chrome(OnboardingCta(label: ctaLabel!, onPressed: onCta))
              : label(cta!),
        ),
        if (footer != null)
          Positioned(
            left: 28,
            right: 28,
            bottom: 36,
            child: label(Center(child: footer)),
          ),
      ],
    );

    // The flow paints the background once, beneath every screen, so the
    // painting never blurs or blinks as screens change.
    return CupertinoPageScaffold(
      backgroundColor: scope == null ? null : const Color(0x00000000),
      child: scope == null ? AppBackground(child: body) : body,
    );
  }
}

/// Set by the onboarding flow around each screen while screens change: how
/// far this one has come in (0 to 1) and whether it is the one leaving.
///
/// The chrome every screen shares (step bar, bottom fade, the button's
/// pill) hands over without a dip: the incoming copy fades in over the
/// first half while the outgoing one stays, then the outgoing fades out
/// beneath it. Words on the chrome change out-then-in instead, since two
/// different labels on one pill read as one garbled one. The content blurs
/// out over the first 60% and in over the last 60%.
class OnboardingStepScope extends InheritedWidget {
  const OnboardingStepScope({
    super.key,
    required this.value,
    required this.leaving,
    required super.child,
  });

  final double value;
  final bool leaving;

  static OnboardingStepScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<OnboardingStepScope>();

  double get chromeOpacity => (value * 2).clamp(0.0, 1.0);

  /// Words on the chrome (a button's label, a link): the old ones out over
  /// the first 40%, the new ones in over the next 40%, never both at once.
  double get labelOpacity => leaving
      ? (1 - (1 - value) / 0.4).clamp(0.0, 1.0)
      : ((value - 0.4) / 0.4).clamp(0.0, 1.0);

  double get contentVeil => leaving ? ((1 - value) / 0.6).clamp(0.0, 1.0) : 0.0;

  double get contentAppear =>
      leaving ? 1.0 : ((value - 0.4) / 0.6).clamp(0.0, 1.0);

  @override
  bool updateShouldNotify(OnboardingStepScope oldWidget) =>
      oldWidget.value != value || oldWidget.leaving != leaving;
}

/// The primary onboarding button: the brand gradient when it can be pressed,
/// a quiet wash of the same colour when it cannot.
class OnboardingCta extends StatelessWidget {
  const OnboardingCta(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final enabled = onPressed != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: colors.ctaPrimary.withValues(alpha: 0.30),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ]
            : const [],
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.ctaPrimary, colors.ctaSecondary],
                )
              : null,
          color: enabled
              ? null
              : Color.alphaBlend(
                  colors.ctaPrimary.withValues(alpha: 0.32),
                  colors.onboardingBg4,
                ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: CupertinoButton(
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(24),
          child: Opacity(
            opacity: OnboardingStepScope.maybeOf(context)?.labelOpacity ?? 1,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont(context),
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? const Color(0xFFFFFFFF)
                    : Color.alphaBlend(
                        colors.ctaPrimary.withValues(alpha: 0.65),
                        colors.onboardingBg4,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
