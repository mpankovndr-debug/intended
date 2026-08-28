import 'dart:math' as math;

import 'package:flutter/painting.dart' show Color, HSLColor;

import 'app_colors.dart';

/// The one colour the breath circles use, per theme.
///
/// Not a ninth seat on the category wheel — all eight hues are owned, and a
/// pause is not a category. The circles take the app's own voice colour
/// instead: the theme's ctaPrimary hue, softened to sit *in* the card the
/// way [CategoryColors] sits its swatches — lightness solved to a contrast
/// target against the card rather than declared, so every theme (dark ones
/// included) lands legible without hand-tuning.
class PauseInk {
  PauseInk._();

  /// A step above the grid's 2.0: a single quiet hue has no legend of
  /// colours to lean on, so the marks themselves carry the row. Still soft —
  /// the section must read quieter than the mosaic above it.
  static const double targetContrast = 3.0;

  static final Map<AppTheme, Color> _cache = {};

  static Color of(AppTheme theme) {
    final cached = _cache[theme];
    if (cached != null) return cached;

    final scheme = AppColors.of(theme);
    final cta = HSLColor.fromColor(scheme.ctaPrimary);
    final backgroundLuminance = relativeLuminance(scheme.cardBackground);

    final double targetLuminance = theme.isDark
        ? (backgroundLuminance + 0.05) * targetContrast - 0.05
        : (backgroundLuminance + 0.05) / targetContrast - 0.05;

    var lo = 0.0, hi = 1.0;
    for (var i = 0; i < 24; i++) {
      final mid = (lo + hi) / 2;
      final lum = relativeLuminance(cta.withLightness(mid).toColor());
      if (lum < targetLuminance) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final color = cta.withLightness(((lo + hi) / 2).clamp(0.0, 1.0)).toColor();
    _cache[theme] = color;
    return color;
  }

  /// WCAG relative luminance. Public so the tests can assert the contrast
  /// this class promises instead of trusting it.
  static double relativeLuminance(Color color) {
    double f(double c) => c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * f(color.r) + 0.7152 * f(color.g) + 0.0722 * f(color.b);
  }
}
