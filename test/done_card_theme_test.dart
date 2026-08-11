import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/theme/app_colors.dart';
import 'package:intended/theme/category_colors.dart';

/// The completed card's V1 treatment, measured on every theme.
///
/// The failure this guards against was found by eye, not by the contrast
/// suite: the done card was solved against the *card* background but sits on
/// the *page*, and on Iris the two were nearly the same lavender, so kept
/// actions dissolved. Contrast ratios alone can't catch it — a pure hue tint
/// barely moves luminance — so these tests measure channel distance too:
/// whether the tinted fill, the border and the pending fill are actually
/// different colours on screen, not just different numbers in a formula.
void main() {
  /// What [colour] looks like after Flutter composites it over [background].
  Color over(Color colour, Color background) =>
      Color.alphaBlend(colour, background);

  /// Straight-line RGB distance, 0–441. Below ~6 two fills are the same
  /// colour to the eye; 10+ is a visible difference on adjacent surfaces.
  double distance(Color a, Color b) {
    final dr = (a.r - b.r) * 255;
    final dg = (a.g - b.g) * 255;
    final db = (a.b - b.b) * 255;
    return (dr * dr + dg * dg + db * db).clamp(0, double.infinity).toDouble();
  }

  double d(Color a, Color b) => distance(a, b).abs().sqrtSafe();

  for (final theme in AppTheme.values) {
    final colors = AppColors.of(theme);
    final isDark = theme.isDark;

    // The page behind a card: the background gradient's midpoint. The real
    // page adds a landscape illustration, but the gradient is its floor.
    final page = Color.lerp(
      colors.bgGradientTop,
      colors.bgGradientBottom,
      0.5,
    )!;

    final pendingFill = over(
      colors.profileCard.withValues(alpha: colors.profileCardOpacity),
      page,
    );

    group('$theme', () {
      for (final category in ['Health', 'Self-care', 'Mood']) {
        final tile = CategoryColors.onCard(category, theme);
        final doneFill = over(
          tile.withValues(alpha: isDark ? 0.13 : 0.18),
          pendingFill,
        );
        final border = over(tile.withValues(alpha: 0.35), doneFill);

        test('$category: done card separates from the page', () {
          expect(
            d(doneFill, page),
            greaterThan(10),
            reason: 'done fill ≈ page background — the Iris dissolve',
          );
        });

        test('$category: tint is visible against a pending card', () {
          expect(
            d(doneFill, pendingFill),
            greaterThan(6),
            reason: 'done and pending fills are the same colour to the eye',
          );
        });

        test('$category: border reads against the fill it edges', () {
          expect(
            d(border, doneFill),
            greaterThan(10),
            reason: '1px border vanishes into the wash',
          );
        });
      }
    });
  }
}

extension on double {
  double sqrtSafe() {
    if (this <= 0) return 0;
    var x = this;
    var guess = x / 2;
    for (var i = 0; i < 32; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}
