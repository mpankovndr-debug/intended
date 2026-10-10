import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.currentFill = 1,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  /// How much of the current segment is filled, 0 to 1: a part with several
  /// screens fills a little more on each, so the bar moves every time.
  final double currentFill;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return SizedBox(
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button (or spacer to keep segments centered)
          SizedBox(
            width: 44,
            child: onBack != null
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onBack,
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  )
                : null,
          ),

          // Segmented bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: List.generate(totalSteps, (index) {
                  final fill = index < currentStep - 1
                      ? 1.0
                      : index == currentStep - 1
                          ? currentFill.clamp(0.0, 1.0)
                          : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 3,
                        right: index == totalSteps - 1 ? 0 : 3,
                      ),
                      child: _Segment(
                        fill: fill,
                        ctaPrimary: colors.ctaPrimary,
                        ctaSecondary: colors.ctaSecondary,
                        mutedColor: colors.borderMedium.withValues(alpha: 0.45),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Spacer to balance the back button
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.fill,
    required this.ctaPrimary,
    required this.ctaSecondary,
    required this.mutedColor,
  });

  final double fill;
  final Color ctaPrimary;
  final Color ctaSecondary;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (fill < 1) Container(color: mutedColor),
            if (fill > 0)
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fill,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ctaPrimary, ctaSecondary],
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
