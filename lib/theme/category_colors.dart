import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Colour for each focus area, tuned per theme.
///
/// §4.2 fixes colour to *meaning*: a square's colour says which focus area the
/// moment belonged to, not which theme is active. But a single fixed trio
/// cannot work across ten themes — coral that sits beautifully on Iris fights
/// the beige of warmClay and glares against nightBloom.
///
/// So meaning lives in the **hue**, which never changes, while saturation is
/// tuned per theme and lightness is solved for so every swatch clears the same
/// contrast bar against that theme's card. A category stays recognisably
/// itself everywhere and stays legible everywhere — and tuning a theme means
/// changing one number, not eight colours, so the palette cannot drift
/// internally inconsistent. `test/category_colors_test.dart` holds the bar.
class CategoryColors {
  const CategoryColors._();

  /// Hue per focus area, in degrees. These carry the meaning and are the same
  /// on every theme. Keys match `OnboardingState.habitsByCategory` exactly —
  /// they are display strings, not slugs, so a mismatch fails silently.
  static const Map<String, double> _hues = {
    'Health': 14, // coral
    'Self-care': 258, // violet
    'Mood': 96, // sage
    'Productivity': 205, // blue
    'Home & organization': 34, // amber
    'Relationships': 342, // rose
    'Creativity': 288, // magenta
    'Finances': 172, // teal
  };

  /// Fallback for custom habits with no focus area, and for any category key
  /// that stops matching. Deliberately desaturated so an unmapped square reads
  /// as "uncategorised" rather than impersonating a real focus area.
  static const _Tuning _neutralTuning = _Tuning(saturation: 0.10);
  static const double _neutralHue = 250;

  /// Per-theme saturation. This is the tuning knob: how vivid the palette
  /// feels on that theme. Lightness is *not* set here — see [of].
  ///
  /// Kept low. Contrast is already guaranteed by the luminance solve, so
  /// saturation only controls how loud a swatch feels — and at full strength
  /// the tiles shouted next to the pale cards they sit on.
  ///
  /// Dark themes carry less saturation, because a vivid swatch on a dark
  /// field vibrates and pulls the eye off the text beside it.
  static const Map<AppTheme, double> _saturation = {
    AppTheme.warmClay: 0.36,
    AppTheme.iris: 0.34,
    AppTheme.clearSky: 0.38,
    AppTheme.morningSlate: 0.38,
    AppTheme.softDusk: 0.36,
    AppTheme.deepFocus: 0.34,
    AppTheme.forestFloor: 0.40,
    AppTheme.goldenHour: 0.40,
    AppTheme.nightBloom: 0.36,
    AppTheme.sandDune: 0.40,
  };

  /// Contrast the swatches aim for against their card background. WCAG 1.4.11
  /// requires 3:1 for non-text UI that carries meaning; the extra margin keeps
  /// rounding and future background tweaks from dropping below the bar.
  static const double _targetContrast = 3.4;

  static final Map<int, Color> _cache = {};

  /// The full-strength swatch — grid tiles, legend dots, the tile that lands
  /// in the completion modal.
  ///
  /// Lightness is solved for rather than declared. Hues differ enormously in
  /// perceived luminance — sage at HSL lightness 0.62 is far brighter than
  /// violet at the same value — so a fixed lightness produces swatches that
  /// range from washed out to nearly black depending on hue. Instead each
  /// swatch is driven to the *luminance* that hits [_targetContrast] against
  /// this theme's card, which makes all eight categories equally legible and
  /// keeps any future theme correct without hand-tuning.
  static Color of(String? category, AppTheme theme) {
    final key = Object.hash(category, theme);
    final cached = _cache[key];
    if (cached != null) return cached;

    final hue = _hues[category] ?? _neutralHue;
    final saturation =
        _hues.containsKey(category) ? (_saturation[theme] ?? 0.40) : _neutralTuning.saturation;

    final background = AppColors.of(theme).cardBackground;
    final backgroundLuminance = _relativeLuminance(background);

    // Solve for the luminance that lands on the target ratio, on whichever
    // side of the background this theme needs.
    final double targetLuminance = theme.isDark
        ? (backgroundLuminance + 0.05) * _targetContrast - 0.05
        : (backgroundLuminance + 0.05) / _targetContrast - 0.05;

    final color = _solveForLuminance(
      hue: hue,
      saturation: saturation,
      targetLuminance: targetLuminance.clamp(0.0, 1.0),
    );
    _cache[key] = color;
    return color;
  }

  /// Binary-searches HSL lightness for the colour closest to [targetLuminance].
  /// Luminance rises monotonically with lightness at fixed hue and saturation,
  /// so this converges quickly and unambiguously.
  static Color _solveForLuminance({
    required double hue,
    required double saturation,
    required double targetLuminance,
  }) {
    double low = 0.0;
    double high = 1.0;
    Color best = HSLColor.fromAHSL(1, hue, saturation, 0.5).toColor();

    for (var i = 0; i < 24; i++) {
      final mid = (low + high) / 2;
      best = HSLColor.fromAHSL(1, hue, saturation, mid).toColor();
      if (_relativeLuminance(best) < targetLuminance) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return best;
  }

  static double _relativeLuminance(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  /// Contrast for the single tile on a habit card.
  ///
  /// Lighter than the grid's bar on purpose. WCAG 1.4.11 asks for 3:1 where
  /// colour *is* the information — true in the grid, where a square is all
  /// you get. On a card the habit is named in text beside it and the wash
  /// repeats the same hue, so the tile is reinforcing meaning rather than
  /// carrying it, and it can sit softer without costing anyone anything.
  static const double _onCardContrast = 2.1;

  /// The tile shown on a completed habit card. See [_onCardContrast].
  static Color onCard(String? category, AppTheme theme) {
    final hue = _hues[category] ?? _neutralHue;
    final saturation = _hues.containsKey(category)
        ? (_saturation[theme] ?? 0.40)
        : _neutralTuning.saturation;

    final backgroundLuminance =
        _relativeLuminance(AppColors.of(theme).cardBackground);
    final target = theme.isDark
        ? (backgroundLuminance + 0.05) * _onCardContrast - 0.05
        : (backgroundLuminance + 0.05) / _onCardContrast - 0.05;

    return _solveForLuminance(
      hue: hue,
      saturation: saturation,
      targetLuminance: target.clamp(0.0, 1.0),
    );
  }

  /// Contrast the completed-card wash aims for. Just enough to register as a
  /// tint, nowhere near the swatch — §5.1 warns a saturated fill reads as
  /// "selected" or "alert" rather than the quiet "kept" intended here.
  static const double _washContrast = 1.14;

  /// The wash carries far less chroma than the swatch. Lightness alone is not
  /// enough: at the same luminance a sage at full tuning saturation is much
  /// more vivid than a violet, and reads as "selected" rather than "kept".
  /// Pulling saturation back makes the tint whisper on every hue.
  static const double _washSaturationFactor = 0.28;

  /// The very pale fill behind a completed card (§5.1).
  ///
  /// Solved as its own light tint rather than the swatch at low alpha. Fading
  /// a colour chosen for 3.4:1 contrast pulls it toward the background *grey*,
  /// not toward a paler version of itself — sage in particular came out muddy
  /// and read as disabled, which is the one thing this state must not do.
  static Color wash(String? category, AppTheme theme, {required bool isDark}) {
    final hue = _hues[category] ?? _neutralHue;
    final base =
        _hues.containsKey(category) ? (_saturation[theme] ?? 0.40) : _neutralTuning.saturation;

    final background = AppColors.of(theme).cardBackground;
    final backgroundLuminance = _relativeLuminance(background);
    final target = isDark
        ? (backgroundLuminance + 0.05) * _washContrast - 0.05
        : (backgroundLuminance + 0.05) / _washContrast - 0.05;

    return _solveForLuminance(
      hue: hue,
      saturation: base * _washSaturationFactor,
      targetLuminance: target.clamp(0.0, 1.0),
    ).withValues(alpha: _washAlpha);
  }

  /// The wash stays translucent so the card keeps its frosted-glass depth —
  /// an opaque fill flattens a completed card into a solid slab beside its
  /// still-glassy neighbours. Alpha is safe here in a way it was not for the
  /// full-strength swatch: this tint is already light, so blending it toward
  /// the background keeps it a paler version of itself rather than pulling it
  /// toward grey.
  static const double _washAlpha = 0.62;

  /// Outline for a completed card. This is the state's *structural* cue, so
  /// it must not be the only carrier of meaning — colour alone fails for
  /// colour-blind users (WCAG 1.4.1). The outline's presence does that work;
  /// its hue only adds which focus area the moment belonged to.
  static Color outline(String? category, AppTheme theme, {required bool isDark}) {
    return of(category, theme).withValues(alpha: isDark ? 0.55 : 0.45);
  }

  /// Every category key that has a hue, in legend order.
  static List<String> get categories => _hues.keys.toList();
}

class _Tuning {
  const _Tuning({required this.saturation});
  final double saturation;
}
