import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../models/moment.dart';
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
    'Doing one thing': 205, // blue
    'Home & organization': 34, // amber
    'Relationships': 342, // rose
    'Creativity': 288, // magenta
    'Finances': 172, // teal
  };

  /// Per-hue saturation multiplier, applied on top of the per-theme knob.
  ///
  /// A single saturation number across all eight hues does not work, because
  /// saturation is not perceived evenly around the wheel. At the value that
  /// makes coral read as a soft salmon, green reads as neon lime and magenta
  /// reads as a highlighter. Warm reds and ambers absorb chroma; greens and
  /// magentas broadcast it.
  ///
  /// These are eyeballed against the reference palette — coral near full,
  /// violet around two thirds, sage down at a bit over a third — so every
  /// focus area lands at the same *apparent* softness rather than the same
  /// number.
  static const Map<String, double> _hueSaturation = {
    'Health': 1.00, // coral
    'Home & organization': 0.92, // amber
    'Relationships': 0.86, // rose
    'Doing one thing': 0.76, // blue
    'Self-care': 0.68, // violet
    'Finances': 0.60, // teal
    'Creativity': 0.58, // magenta
    'Mood': 0.38, // sage
  };

  /// Fallback for custom habits with no focus area, and for any category key
  /// that stops matching. Deliberately desaturated so an unmapped square reads
  /// as "uncategorised" rather than impersonating a real focus area.
  static const _Tuning _neutralTuning = _Tuning(saturation: 0.10);
  static const double _neutralHue = 250;

  /// Per-theme saturation. This is the tuning knob: how vivid the palette
  /// feels on that theme. Lightness is *not* set here — see [of].
  ///
  /// Kept high, and deliberately so. An earlier version ran these near 0.36
  /// and paired them with a 3.4:1 contrast target; on a pale card the solve
  /// can only reach that by driving lightness *down*, and dark plus
  /// desaturated is mud. The tiles came out brown, not coral.
  ///
  /// Saturation and lightness have to move together for a swatch to read as a
  /// colour rather than a stain: these are chosen so the solve lands in the
  /// pastel band — vivid hue, high lightness — which is what the focus areas
  /// are meant to look like.
  ///
  /// Dark themes carry less, because a vivid swatch on a dark field vibrates
  /// and pulls the eye off the text beside it.
  static const Map<AppTheme, double> _saturation = {
    AppTheme.warmClay: 0.70,
    AppTheme.iris: 0.72,
    AppTheme.clearSky: 0.74,
    AppTheme.morningSlate: 0.72,
    AppTheme.softDusk: 0.68,
    AppTheme.deepFocus: 0.52,
    AppTheme.forestFloor: 0.70,
    AppTheme.goldenHour: 0.74,
    AppTheme.nightBloom: 0.52,
    AppTheme.sandDune: 0.74,
  };

  /// Contrast the swatches aim for against their card background.
  ///
  /// ⚠️ **This is below WCAG 1.4.11's 3:1 for meaningful non-text UI**, and it
  /// is a deliberate trade rather than an oversight. At 3:1 on these pale
  /// cards the palette is forced dark and stops reading as the coral / violet
  /// / sage the design calls for. What makes it defensible: every place a
  /// swatch carries meaning also names it in text — the legend reads
  /// "Health 5" beside its dot, and a tapped tile names its own moment — so
  /// colour is never the only channel. If that ever stops being true, this
  /// number has to go back up first.
  static const double _targetContrast = 2.0;

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
  /// [mood] tints the swatch without moving its hue (§4.2: colour is the focus
  /// area, brightness is how it landed). A wall of identical squares reads as
  /// wallpaper; three tints of one hue read as a month with texture in it.
  ///
  /// Applied as a *contrast* offset rather than a lightness one, so it works
  /// in the same direction on light and dark themes and — more importantly —
  /// cannot drop a swatch below the legibility bar. The softest variant is the
  /// one solved at [_targetContrast]; the others only ever add to it.
  static Color of(String? category, AppTheme theme, {MomentMood? mood}) {
    final key = Object.hash(category, theme, mood);
    final cached = _cache[key];
    if (cached != null) return cached;

    final hue = _hues[category] ?? _neutralHue;
    final saturation = _hues.containsKey(category)
        ? (_saturation[theme] ?? 0.40) * (_hueSaturation[category] ?? 1.0)
        : _neutralTuning.saturation;

    final background = AppColors.of(theme).cardBackground;
    final backgroundLuminance = _relativeLuminance(background);

    final contrast = _targetContrast + _moodWeight(mood);

    // Solve for the luminance that lands on the target ratio, on whichever
    // side of the background this theme needs.
    final double targetLuminance = theme.isDark
        ? (backgroundLuminance + 0.05) * contrast - 0.05
        : (backgroundLuminance + 0.05) / contrast - 0.05;

    final color = _solveForLuminance(
      hue: hue,
      saturation: saturation,
      targetLuminance: targetLuminance.clamp(0.0, 1.0),
    );
    _cache[key] = color;
    return color;
  }

  /// How much weight a mood adds on top of [_targetContrast].
  ///
  /// The ones that took effort sit deepest — they cost the most and they are
  /// what a month is actually made of. Glad sits lightest. Unrated moments
  /// take the middle rather than a fourth tint, because "you didn't say" is
  /// not a fourth kind of feeling and should not look like one.
  ///
  /// Kept small on purpose: this is texture within a hue, not a second
  /// encoding. If three tints start reading as three categories, the grid has
  /// stopped saying what §4.2 needs it to say.
  static double _moodWeight(MomentMood? mood) => switch (mood) {
        MomentMood.gladIDid => 0.0,
        MomentMood.tookEffort => 0.45,
        _ => 0.20,
      };

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
  ///
  /// Softer than the grid in two extra ways, both from the design review
  /// (SS6): saturation is trimmed a quarter, and the solved colour is pulled a
  /// quarter of the way toward the theme's own accent. The grid keeps the full
  /// swatch — colour is the *data* there — but on a card the text names the
  /// action, so the tile can afford to sit in the palette's family instead of
  /// visiting from outside it. Coral on Iris stops shouting; the hue is still
  /// legibly Health.
  static Color onCard(String? category, AppTheme theme) {
    final hue = _hues[category] ?? _neutralHue;
    final saturation = (_hues.containsKey(category)
            ? (_saturation[theme] ?? 0.40)
            : _neutralTuning.saturation) *
        0.75;

    final backgroundLuminance =
        _relativeLuminance(AppColors.of(theme).cardBackground);
    final target = theme.isDark
        ? (backgroundLuminance + 0.05) * _onCardContrast - 0.05
        : (backgroundLuminance + 0.05) / _onCardContrast - 0.05;

    final solved = _solveForLuminance(
      hue: hue,
      saturation: saturation,
      targetLuminance: target.clamp(0.0, 1.0),
    );
    return Color.lerp(solved, AppColors.of(theme).ctaPrimary, 0.25)!;
  }

  /// Contrast the completed-card wash aims for. Just enough to register as a
  /// tint, nowhere near the swatch — §5.1 warns a saturated fill reads as
  /// "selected" or "alert" rather than the quiet "kept" intended here.
  static const double _washContrast = 1.14;

  /// The wash carries far less chroma than the swatch. Lightness alone is not
  /// enough: at the same luminance a sage at full tuning saturation is much
  /// more vivid than a violet, and reads as "selected" rather than "kept".
  /// Pulling saturation back makes the tint whisper on every hue.
  ///
  /// Cut when the swatch saturation roughly doubled to fix the muddy tiles.
  /// A completed card and a grid tile want opposite things — pop and quiet —
  /// so the wash is pinned to its own number rather than riding the swatch's.
  static const double _washSaturationFactor = 0.13;

  /// The very pale fill behind a completed card (§5.1).
  ///
  /// Solved as its own light tint rather than the swatch at low alpha. Fading
  /// a colour chosen for 3.4:1 contrast pulls it toward the background *grey*,
  /// not toward a paler version of itself — sage in particular came out muddy
  /// and read as disabled, which is the one thing this state must not do.
  static Color wash(String? category, AppTheme theme, {required bool isDark}) {
    final hue = _hues[category] ?? _neutralHue;
    final base = _hues.containsKey(category)
        ? (_saturation[theme] ?? 0.40) * (_hueSaturation[category] ?? 1.0)
        : _neutralTuning.saturation;

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
