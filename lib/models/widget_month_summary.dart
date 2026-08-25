import 'package:flutter/painting.dart' show Alignment;

import '../theme/app_colors.dart';
import 'moment.dart';

/// One legend line under the widget's mosaic: a focus area and how many
/// moments it holds this month. Counts are facts; there is no denominator.
class WidgetLegendEntry {
  const WidgetLegendEntry(this.category, this.count);

  final String category;
  final int count;
}

/// The pure rules behind the home-screen widget's month summary. They live
/// here, not in the service that needs a theme and a localizer, so they can
/// be tested (CLAUDE.md: logic that needs a BuildContext can't be tested).
class WidgetMonthSummary {
  /// Focus areas ranked by moment count, most first. Dart's sort is not
  /// stable, so ties break on the category name to keep the widget from
  /// reshuffling between refreshes. Uncategorised moments (customs made
  /// before a focus area was chosen) are counted in the total but have no
  /// legend line — a grey "null 3" is not a sentence.
  static List<WidgetLegendEntry> legend(List<Moment> moments, {int cap = 5}) {
    final counts = <String, int>{};
    for (final m in moments) {
      final c = m.category;
      if (c == null) continue;
      counts[c] = (counts[c] ?? 0) + 1;
    }
    final entries = [
      for (final e in counts.entries) WidgetLegendEntry(e.key, e.value),
    ]..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        return byCount != 0 ? byCount : a.category.compareTo(b.category);
      });
    return entries.take(cap).toList();
  }

  /// Wall-clock time of the latest moment recorded today for [habitName],
  /// read from the moment's own offset (never the device zone).
  static DateTime? latestTodayFor(
    List<Moment> moments,
    String habitName,
    DateTime today,
  ) {
    DateTime? best;
    for (final m in moments) {
      if (m.habitName != habitName) continue;
      final day = m.localDay;
      if (day.year != today.year ||
          day.month != today.month ||
          day.day != today.day) {
        continue;
      }
      final wall = m.localWallClock;
      if (best == null || wall.isAfter(best)) best = wall;
    }
    return best;
  }
}

/// The painted background behind a widget, per theme.
///
/// Every theme already owns a painting — the one the Today screen paints
/// behind its cards — so the widget matches the screen it opens into rather
/// than arriving as a flat gradient. Those are 2:3 portraits whose detail
/// sits low (grass, water, foreground), so each crop is anchored above
/// centre: the calm band is where the type goes.
///
/// A theme graduates to dedicated art by naming its own files here. All ten
/// have them now — one sunrise painted ten times, composed for the widget
/// frame — so every theme crops from the centre.
class WidgetArt {
  const WidgetArt({
    required this.square,
    required this.wide,
    this.squareAlign = const Alignment(0, -0.24),
    this.wideAlign = const Alignment(0, -0.32),
  });

  /// Asset behind the small and large widgets (≈1:1).
  final String square;

  /// Asset behind the medium widget (≈2:1).
  final String wide;

  /// Which band of the painting survives the crop, as `BoxFit.cover` reads it.
  final Alignment squareAlign;
  final Alignment wideAlign;

  /// Themes with art composed for the widget frame. Adding one is two files
  /// — `assets/images/widget_sq_<key>.jpg` and `widget_hor_<key>.jpg` — and
  /// its key here; everything else keeps the Today-screen fallback.
  ///
  /// JPEG, not PNG, and deliberately: these are downsampled to 760 px before
  /// anything renders them, so the format's losses land below the resample.
  /// Measured at q90 on the darkest theme, the sky's longest flat run is 6 px
  /// against the PNG's 7 — no banding — for 28 MB less in the bundle.
  ///
  /// All ten are listed, so the fallback below is currently unreachable. It
  /// stays because a new theme should be able to land its code before its
  /// painting, and a bare gradient is a better placeholder than a crash.
  static const Set<String> _dedicated = {
    'warmclay',
    'iris',
    'clearsky',
    'morningslate',
    'softdusk',
    'deepfocus',
    'forestfloor',
    'goldenhour',
    'nightbloom',
    'sanddune',
  };

  static WidgetArt? forTheme(AppTheme theme) {
    final key = _assetKey(theme);
    if (_dedicated.contains(key)) {
      return WidgetArt(
        square: 'assets/images/widget_sq_$key.jpg',
        wide: 'assets/images/widget_hor_$key.jpg',
        squareAlign: Alignment.center,
        wideAlign: Alignment.center,
      );
    }
    final ms = AppColors.of(theme).backgroundMs;
    return WidgetArt(square: ms, wide: ms);
  }

  /// The asset key for a theme — `AppTheme.morningSlate` is `morningslate`
  /// on disk, matching how the app icons are already named
  /// (`intended-icon-morningslate-1024.png`).
  ///
  /// Deliberately not snake_case: the older `background_*` files are split
  /// between both conventions (`background_ms_clear_sky` but
  /// `background_soft_nightbloom`), so there is no single existing rule to
  /// follow. One join-the-words rule that matches every widget file beats a
  /// prettier one that silently resolves to a path that isn't there — a
  /// missing asset throws inside the render, gets swallowed, and shows up
  /// only as a widget that quietly kept its gradient.
  static String _assetKey(AppTheme theme) => theme.name.toLowerCase();
}
