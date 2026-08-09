import 'package:flutter/widgets.dart';

import '../models/moment.dart';
import '../theme/app_colors.dart';
import '../theme/category_colors.dart';

/// The month's moments as tiles, indexed by moment rather than by date (§4.2).
///
/// This is the single most important structural decision in the redesign, and
/// it is easy to undo by accident. GitHub's contribution graph and Daylio's
/// Year in Pixels both index by *date*, so an empty cell means "you failed" —
/// a streak with better manners. Here cell 1 is the first moment and cell 47
/// the forty-seventh. There is no cell for a skipped Tuesday because days are
/// not the unit.
///
/// Consequences to preserve if this widget is ever edited:
///
/// * **The grid only grows.** Absence is structurally unrepresentable. Never
///   render a fixed number of slots and fill some of them.
/// * **Never outline empty cells.** A bounded grid of 300 empty squares is
///   "look how much you haven't done." Tiles fill and stop.
/// * **Gaps appear as returns, not absences.** The first tile after a quiet
///   stretch gets a soft ring — the moment someone came back, marked as an
///   arrival rather than a hole.
class MomentGrid extends StatelessWidget {
  const MomentGrid({
    super.key,
    required this.moments,
    required this.theme,
    this.tileSize = 30,
    this.spacing = 8,
    this.showGhost = true,
  });

  /// Oldest first. Only this month's moments belong here.
  final List<Moment> moments;
  final AppTheme theme;
  final double tileSize;
  final double spacing;

  /// One faint tile after the last real one, hinting the grid continues.
  /// Exactly one — a row of them becomes the empty-slot problem above.
  final bool showGhost;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(theme);
    final returnIndices = returnIndicesFor(moments);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (var i = 0; i < moments.length; i++)
          _Tile(
            color: CategoryColors.of(moments[i].category, theme),
            size: tileSize,
            // A ring marks the first moment after a quiet stretch: "you came
            // back here." It is the only decoration the grid carries.
            isReturn: returnIndices.contains(i),
          ),
        if (showGhost && moments.isNotEmpty)
          _Tile(
            color: colors.textPrimary.withValues(alpha: 0.06),
            size: tileSize,
            flat: true,
          ),
      ],
    );
  }

  /// Indices of moments that are the first after a gap of at least
  /// [MomentGrid.gapThresholdDays] quiet days.
  static Set<int> returnIndicesFor(List<Moment> moments) {
    final result = <int>{};
    DateTime? previousDay;

    for (var i = 0; i < moments.length; i++) {
      final m = moments[i];
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      final day = DateTime.utc(local.year, local.month, local.day);

      if (previousDay != null) {
        final quiet = day.difference(previousDay).inDays - 1;
        if (quiet >= gapThresholdDays) result.add(i);
      }
      previousDay = day;
    }
    return result;
  }

  /// Matches `MomentRollup.gapThresholdDays` — one missed day is not a gap.
  static const int gapThresholdDays = 2;
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.color,
    required this.size,
    this.isReturn = false,
    this.flat = false,
  });

  final Color color;
  final double size;

  /// First moment after a quiet stretch. Marked with a light halo rather than
  /// an outline: an outline draws a boundary around the tile, which reads as
  /// something singled out. A glow reads as something lit — the difference
  /// between marking a gap and celebrating a return (§4.2).
  final bool isReturn;

  /// The ghost tile is a hint, not a moment, so it takes no dimension.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    // A slight lift toward the top-left gives the tile body rather than
    // leaving it a flat chip.
    final lit = hsl
        .withLightness((hsl.lightness + 0.07).clamp(0.0, 1.0))
        .toColor();
    final shade = hsl
        .withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0))
        .toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: flat ? color : null,
        gradient: flat
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [lit, color, shade],
                stops: const [0.0, 0.55, 1.0],
              ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: isReturn
            ? [
                BoxShadow(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
                  blurRadius: size * 0.30,
                  spreadRadius: size * 0.06,
                ),
              ]
            : null,
      ),
    );
  }
}
