import 'moment.dart';

/// One action, and how it tends to land when the user does it.
class LiftReading {
  const LiftReading({
    required this.habitName,
    required this.gladCount,
    required this.ratedCount,
  });

  final String habitName;

  /// Moments of this action the user marked "glad I did".
  final int gladCount;

  /// Moments of this action that carry any mood at all. The denominator —
  /// unrated moments say nothing about how it landed and are not counted
  /// against it.
  final int ratedCount;

  double get gladShare => ratedCount == 0 ? 0 : gladCount / ratedCount;
}

/// What actually lifts you (§6.4): actions ranked by how they land.
///
/// "Body scan — glad you did it 8 times out of 10. Drink water — 2 out of 10."
/// The only feature in the app that tells someone which habits are worth
/// keeping, and the reason the mood tap exists at all — counts alone can only
/// ever say "you did 4 things".
///
/// Built before its data exists, on purpose: the mood taps started
/// accumulating the day v2 ships, and if this card weren't in that same
/// release, the users whose data matured at week eight would need an app
/// update to see it. Until the data is there it follows the same rule as
/// drift, the letter and the plan — real partial content with honest
/// confidence, or nothing. Never a rendered promise.
class Lift {
  const Lift({required this.readings, required this.mature});

  /// Best-landing first. In the forming state this holds only the top one.
  final List<LiftReading> readings;

  /// True once the data can support a ranking; false is the forming state,
  /// which shows one real reading and asks to be asked again later.
  final bool mature;

  /// The action that mostly doesn't land, when the evidence is strong enough
  /// to say so — the "swap the water one" of §6.4. Null in the forming state
  /// and null when nothing is clearly failing: an action someone is glad
  /// about half the time is fine, and proposing to remove it would be the
  /// app inventing a problem to seem useful.
  LiftReading? get worst {
    if (!mature) return null;
    final last = readings.last;
    if (last.ratedCount < minRatedMature) return null;
    return last.gladShare <= _worstShare ? last : null;
  }

  /// ~8 weeks of rated history before a ranking is a pattern (§6.4).
  static const int minSpanDays = 56;

  /// Ratings one action needs before its ratio means anything. Below six,
  /// "2 out of 3" swings 33 points on a single tap.
  static const int minRatedMature = 6;

  /// The forming state's lower bar — enough to be a real observation, not
  /// enough to rank by.
  static const int minRatedForming = 3;

  static const double _worstShare = 0.3;

  /// Weeks left before [read] can mature, given the earliest rated moment.
  /// For the "ask me again in N weeks" line.
  static int weeksRemaining(List<Moment> moments, {DateTime? now}) {
    final span = _spanDays(moments, now);
    if (span == null) return (minSpanDays / 7).ceil();
    final days = minSpanDays - span;
    return days <= 0 ? 1 : (days / 7).ceil();
  }

  /// Null when there is nothing honest to show — no rated moments on any
  /// active action, or not even one action past the forming bar.
  static Lift? read(
    List<Moment> moments, {
    required List<String> activeHabits,
    DateTime? now,
  }) {
    final counts = <String, ({int glad, int rated})>{};
    for (final m in moments) {
      if (m.mood == null) continue;
      if (!activeHabits.contains(m.habitName)) continue;
      final c = counts[m.habitName] ?? (glad: 0, rated: 0);
      counts[m.habitName] = (
        glad: c.glad + (m.mood == MomentMood.gladIDid ? 1 : 0),
        rated: c.rated + 1,
      );
    }
    if (counts.isEmpty) return null;

    final all = [
      for (final e in counts.entries)
        LiftReading(
          habitName: e.key,
          gladCount: e.value.glad,
          ratedCount: e.value.rated,
        ),
    ]..sort((a, b) {
        final byShare = b.gladShare.compareTo(a.gladShare);
        // Ties break toward the better-evidenced action, then by name so the
        // same data always ranks the same way.
        if (byShare != 0) return byShare;
        final byCount = b.ratedCount.compareTo(a.ratedCount);
        return byCount != 0 ? byCount : a.habitName.compareTo(b.habitName);
      });

    final span = _spanDays(moments, now) ?? 0;
    final ranked =
        all.where((r) => r.ratedCount >= minRatedMature).toList();

    // A ranking needs two things to rank, and a pattern needs its eight
    // weeks. Both, or this is the forming state.
    if (span >= minSpanDays && ranked.length >= 2) {
      return Lift(readings: ranked, mature: true);
    }

    final forming =
        all.where((r) => r.ratedCount >= minRatedForming).toList();
    if (forming.isEmpty) return null;
    return Lift(readings: [forming.first], mature: false);
  }

  /// Days from the earliest rated moment to today, on the wall clock each
  /// moment recorded. Null with no rated moments at all.
  static int? _spanDays(List<Moment> moments, DateTime? now) {
    DateTime? earliest;
    for (final m in moments) {
      if (m.mood == null) continue;
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      final day = DateTime.utc(local.year, local.month, local.day);
      if (earliest == null || day.isBefore(earliest)) earliest = day;
    }
    if (earliest == null) return null;
    final local = now ?? DateTime.now();
    final today = DateTime.utc(local.year, local.month, local.day);
    return today.difference(earliest).inDays;
  }
}
