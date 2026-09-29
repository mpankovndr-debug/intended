import 'moment.dart';

/// A read on whether this week is running below the user's own baseline (§6.1).
///
/// The only forward-looking thing in the app. Finch, Streaks and Daylio all
/// *react* to absence — they notice once you have already gone. This warns
/// before the gap, while there is still a week to change.
///
/// Compared against the user's own rolling average, never a target. "You
/// usually collect 6" is an observation about them; "you should collect 6"
/// would be a goal, and goals are the pressure this app exists to remove.
class Drift {
  const Drift({
    required this.thisWeek,
    required this.usual,
    required this.precededQuiet,
  });

  final int thisWeek;
  final int usual;

  /// True when previous dips of this size were followed by a quiet stretch.
  /// Only then is the second line honest.
  final bool precededQuiet;

  /// Below this share of the usual rate, the week counts as drifting.
  static const double _threshold = 0.5;

  /// Weeks of history needed before a baseline means anything. Under four,
  /// "you usually" has no basis and the card would be inventing a norm.
  static const int minWeeksOfHistory = 4;

  /// How long a weekday mask silences this card.
  ///
  /// A mask changes how many actions are even *offered* in a week, so the
  /// average built before it describes a different app. Warning that someone
  /// is running below their usual rate, when the drop is the schedule they
  /// just chose, would read as the app disapproving of their own decision.
  /// Four weeks — the same span [minWeeksOfHistory] needs — is how long it
  /// takes for the baseline to describe the masked week again.
  static const int maskSuppressionDays = minWeeksOfHistory * 7;

  /// Null when there is nothing honest to say — too little history, or a week
  /// that is doing fine. Silence is the default; this card earns its place.
  /// [maskChangedAt] is when a custom action's weekday mask was last created
  /// or changed, or null if none ever was. Kept a parameter rather than a
  /// storage read so this stays pure and testable.
  static Drift? read(
    List<Moment> moments, {
    DateTime? now,
    DateTime? maskChangedAt,
  }) {
    if (moments.isEmpty) return null;
    final today = now ?? DateTime.now();

    // Silent while the baseline predates the current schedule — see
    // [maskSuppressionDays]. Checked before anything else: no amount of
    // history makes a comparison against the wrong app honest.
    if (maskChangedAt != null &&
        today.difference(maskChangedAt).inDays < maskSuppressionDays) {
      return null;
    }

    // Everything is compared in one space: UTC-flagged wall clock, rebuilt
    // from each moment's own recorded offset. Mixing that with plain local
    // DateTimes shifts every comparison by the offset — enough to read a
    // 28-day history as 27 and silently suppress the card.
    DateTime wall(Moment m) =>
        m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));

    int countBetween(DateTime from, DateTime to) => moments.where((m) {
          final at = wall(m);
          return !at.isBefore(from) && at.isBefore(to);
        }).length;

    final weekStart = DateTime.utc(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));

    // Completed weeks before this one, oldest first.
    final history = <int>[];
    for (var i = minWeeksOfHistory; i >= 1; i--) {
      final from = weekStart.subtract(Duration(days: 7 * i));
      history.add(countBetween(from, from.add(const Duration(days: 7))));
    }

    final earliest = moments.map(wall).reduce((a, b) => a.isBefore(b) ? a : b);
    if (weekStart.difference(earliest).inDays < minWeeksOfHistory * 7) {
      return null;
    }

    final usual = (history.reduce((a, b) => a + b) / history.length).round();
    if (usual == 0) return null;

    final thisWeek = countBetween(weekStart, weekStart.add(const Duration(days: 7)));
    if (thisWeek >= usual * _threshold) return null;

    // Did earlier dips actually precede quiet stretches? Only claim it if so.
    var dips = 0;
    var dipsFollowedByQuiet = 0;
    for (var i = 0; i < history.length - 1; i++) {
      if (history[i] < usual * _threshold) {
        dips++;
        if (history[i + 1] < usual * _threshold) dipsFollowedByQuiet++;
      }
    }

    return Drift(
      thisWeek: thisWeek,
      usual: usual,
      precededQuiet: dips >= 2 && dipsFollowedByQuiet >= 2,
    );
  }
}
