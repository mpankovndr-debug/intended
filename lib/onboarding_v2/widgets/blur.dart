import 'dart:ui';

import 'package:flutter/widgets.dart';

// The onboarding's one motion language (spec §6): things leave by blurring
// out and arrive by blurring in, driven by an animation value the screen
// owns.

/// Blurs and fades its child away as [amount] goes from 0 to 1.
class BlurVeil extends StatelessWidget {
  const BlurVeil({super.key, required this.amount, required this.child});

  final double amount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return child;
    return Opacity(
      opacity: (1 - amount).clamp(0.0, 1.0),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 12 * amount, sigmaY: 12 * amount),
        child: child,
      ),
    );
  }
}

/// Brings its child in from a soft blur as [amount] goes from 0 to 1.
class BlurAppear extends StatelessWidget {
  const BlurAppear({super.key, required this.amount, required this.child});

  final double amount;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (amount >= 1) return child;
    final blur = 8 * (1 - amount);
    return Opacity(
      opacity: amount.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 6 * (1 - amount)),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );
  }
}
