import 'pause_check_in.dart';

/// The month's pauses, read the way the moment grid reads moments: filtered
/// by each check-in's own recorded wall clock, ordered oldest first so circle
/// one is the month's first breath. Pure statics, so the whole reading is
/// testable without a screen.
class PauseMonth {
  PauseMonth._();

  /// The check-ins whose *local* day falls in [anchor]'s month. Never the
  /// device's current zone — [PauseCheckIn.localDay] carries the offset the
  /// pause was breathed in.
  static List<PauseCheckIn> forMonth(
      List<PauseCheckIn> all, DateTime anchor) {
    final inMonth = [
      for (final c in all)
        if (c.localDay.year == anchor.year && c.localDay.month == anchor.month)
          c,
    ];
    // Dart's sort is not stable; the id (an ISO instant) breaks ties so the
    // row cannot reshuffle between visits.
    inMonth.sort((a, b) {
      final byTime = a.completedAt.compareTo(b.completedAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    return inMonth;
  }

  /// Counts per *answered* state. Skipped check-ins are in the row but not
  /// here: the pills name answers, and "you didn't say" is not an answer —
  /// the same rule that keeps uncategorised moments out of the legend.
  static Map<PauseState, int> answerCounts(List<PauseCheckIn> checkIns) {
    final counts = <PauseState, int>{};
    for (final c in checkIns) {
      final s = c.state;
      if (s == null) continue;
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }
}
