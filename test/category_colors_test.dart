import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/theme/app_colors.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/theme/category_colors.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';

/// WCAG relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // Below WCAG 1.4.11's 3:1 on purpose — see the note on
  // `CategoryColors._targetContrast`. At 3:1 the solve drives these pale-card
  // themes dark and the palette turns to mud, so the bar here is "clearly
  // distinguishable from the card", and the meaning is carried in text beside
  // every swatch rather than by colour alone.
  //
  // It is still a bar. Without one a saturation tweak can quietly sink a hue
  // into its background on one theme out of ten and nobody would look.
  const minContrast = 1.7;

  test('every category swatch is legible on every theme, at every mood', () {
    final failures = <String>[];

    for (final theme in AppTheme.values) {
      final surface = AppColors.of(theme).cardBackground;
      for (final category in CategoryColors.categories) {
        // Mood tints the swatch, so the bar has to hold for all of them —
        // otherwise a month of "glad I did" would quietly go illegible while
        // the test kept passing on the middle tone.
        for (final mood in [null, ...MomentMood.values]) {
          final swatch = CategoryColors.of(category, theme, mood: mood);
          final ratio = _contrast(swatch, surface);
          if (ratio < minContrast) {
            failures.add(
              '${theme.name} / $category / ${mood?.key ?? 'unrated'}: '
              '${ratio.toStringAsFixed(2)}:1',
            );
          }
        }
      }
    }

    expect(
      failures,
      isEmpty,
      reason: 'Swatches below $minContrast:1 on their card background:\n'
          '${failures.join('\n')}',
    );
  });

  test('completed-card wash stays subtle enough to read as quiet', () {
    // The wash must be visible but must never approach the swatch itself —
    // §5.1 warns a saturated fill reads as "selected" or "alert".
    for (final theme in AppTheme.values) {
      final surface = AppColors.of(theme).cardBackground;
      for (final category in CategoryColors.categories) {
        final raw = CategoryColors.wash(category, theme, isDark: theme.isDark);
        // Translucent by design (keeps the frosted look), so flatten it over
        // the card before judging how strongly it reads.
        final wash = Color.from(
          alpha: 1,
          red: raw.r * raw.a + surface.r * (1 - raw.a),
          green: raw.g * raw.a + surface.g * (1 - raw.a),
          blue: raw.b * raw.a + surface.b * (1 - raw.a),
        );
        final ratio = _contrast(wash, surface);
        expect(
          ratio,
          lessThan(1.5),
          reason: '${theme.name} / $category wash is too strong '
              '(${ratio.toStringAsFixed(2)}:1)',
        );
        // Lightness alone does not make a tint quiet — chroma does. A vivid
        // wash reads as "selected"; §5.1 wants "kept". Measured as how much
        // chroma the wash *adds*: some themes have a saturated card colour of
        // their own, and absolute saturation would penalise them for it.
        final added = HSLColor.fromColor(wash).saturation -
            HSLColor.fromColor(surface).saturation;
        expect(
          added,
          lessThan(0.18),
          reason: '${theme.name} / $category wash adds too much chroma '
              '(+${added.toStringAsFixed(2)})',
        );
      }
    }
  });

  test('every focus area the app can assign has a hue', () {
    // A category key that stops matching fails silently to the neutral
    // swatch, so every assignable area is pinned to a hue here.
    //
    // Subset, not equality: a retired focus area keeps its hue for as long as
    // moments recorded under it exist, and those are never rewritten. Finances
    // is no longer offered, but a square completed under it in August 2026
    // stays teal forever — dropping the hue would repaint somebody's archived
    // month grey.
    expect(
      OnboardingState.habitsByCategory.keys.toSet()
          .difference(CategoryColors.categories.toSet()),
      isEmpty,
      reason: 'a focus area the app can assign has no hue',
    );
  });

  test('unknown and null categories fall back to the neutral swatch', () {
    final neutral = CategoryColors.of(null, AppTheme.iris);
    expect(CategoryColors.of('Not A Category', AppTheme.iris), neutral);
  });
}
