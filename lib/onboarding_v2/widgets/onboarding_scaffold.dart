import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../../utils/text_styles.dart';
import '../../widgets/onboarding_progress_bar.dart';

/// The frame every screen of the new onboarding shares (spec §6): the
/// onboarding gradient and its two orbs, the step bar, an optional headline,
/// the screen's own content, and the primary button over a fade.
///
/// Three older screens each carry their own copy of the orbs; the new ones
/// take them from here.
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
    final size = MediaQuery.of(context).size;
    final locale = Localizations.localeOf(context).toString();
    final ctaBottom = footer == null ? 60.0 : 88.0;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
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
          _Orbs(size: size, colors: colors),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: OnboardingProgressBar(
                    currentStep: step,
                    totalSteps: totalSteps,
                    onBack: onBack,
                  ),
                ),
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFontFor(locale),
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
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: ctaBottom + 100,
            child: IgnorePointer(
              child: DecoratedBox(
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
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: ctaBottom,
            child: cta ?? OnboardingCta(label: ctaLabel!, onPressed: onCta),
          ),
          if (footer != null)
            Positioned(
              left: 28,
              right: 28,
              bottom: 36,
              child: Center(child: footer),
            ),
        ],
      ),
    );
  }
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
    );
  }
}

class _Orbs extends StatelessWidget {
  const _Orbs({required this.size, required this.colors});

  final Size size;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: size.height * 0.1,
            right: size.width * -0.05,
            child: _orb(
              256,
              60,
              colors.surfaceLightest.withValues(alpha: 0.6),
              colors.borderMedium.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: size.width * -0.08,
            child: _orb(
              224,
              55,
              colors.onboardingBg1.withValues(alpha: 0.55),
              colors.onboardingBg4.withValues(alpha: 0.18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double diameter, double blur, Color inner, Color outer) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.35),
            radius: 0.9,
            colors: [inner, outer],
          ),
        ),
      ),
    );
  }
}
