import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

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
                  final isFilled = index < currentStep;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 3,
                        right: index == totalSteps - 1 ? 0 : 3,
                      ),
                      child: _Segment(
                        isFilled: isFilled,
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
    required this.isFilled,
    required this.ctaPrimary,
    required this.ctaSecondary,
    required this.mutedColor,
  });

  final bool isFilled;
  final Color ctaPrimary;
  final Color ctaSecondary;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 4,
        child: isFilled
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ctaPrimary, ctaSecondary],
                  ),
                ),
              )
            : Container(color: mutedColor),
      ),
    );
  }
}
