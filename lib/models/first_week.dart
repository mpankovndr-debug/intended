import 'letter.dart';
import 'moment.dart';

/// The day-7 keepsake (§12): one card marking the first week.
///
/// Week one is where people decide whether to keep the app — day one and
/// month one are both easy by comparison. The early days are carried by the
/// so-far card naming each moment; this is the capstone that gives the week
/// an ending instead of a fade: "Your first week. 5 small things, most of
/// them in the evening."
///
/// Event-like, so it behaves like an event: it appears when the first week
/// completes and leaves a week later on its own. No dismissal state to
/// store, nothing to get stuck on screen forever — presence is computed
/// from the same dates everything else here reads.
class FirstWeek {
  const FirstWeek({
    required this.momentCount,
    this.dominantPart,
    this.gladdestHabit,
  });

  /// Moments in the seven days from the first one.
  final int momentCount;

  /// Where the week's moments clustered, when half of them did.
  final DayPart? dominantPart;

  /// The action marked "glad I did" most, when one clearly was.
  final String? gladdestHabit;

  /// Days after the first moment when the card appears / leaves.
  static const int showFromDay = 7;
  static const int showUntilDay = 14;

  /// Fewer moments than this and the week has no keepsake. "Your first week:
  /// 1 moment" is a sentence that reads as a verdict, and silence is kinder
  /// than thin praise.
  static const int minMoments = 3;

  /// Null outside the day 7–13 window, or when the first week was too thin
  /// to mark.
  static FirstWeek? read(List<Moment> moments, {DateTime? now}) {
    if (moments.isEmpty) return null;

    DateTime? firstDay;
    for (final m in moments) {
      final day = _wallDay(m);
      if (firstDay == null || day.isBefore(firstDay)) firstDay = day;
    }

    final local = now ?? DateTime.now();
    final today = DateTime.utc(local.year, local.month, local.day);
    final age = today.difference(firstDay!).inDays;
    if (age < showFromDay || age >= showUntilDay) return null;

    final week = moments
        .where((m) => _wallDay(m).difference(firstDay!).inDays < 7)
        .toList();
    if (week.length < minMoments) return null;

    return FirstWeek(
      momentCount: week.length,
      dominantPart: _dominantPart(week),
      gladdestHabit: _gladdest(week),
    );
  }

  static DayPart? _dominantPart(List<Moment> week) {
    final counts = <DayPart, int>{};
    for (final m in week) {
      final part = _partOf(m.localHour);
      counts[part] = (counts[part] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    // Half the week or it isn't a cluster, just an assortment.
    return top.value / week.length < 0.5 ? null : top.key;
  }

  /// The habit marked glad most often — needs at least two glads and a clear
  /// winner, because "the one you were glad about most" from one tap is a
  /// claim the data doesn't hold.
  static String? _gladdest(List<Moment> week) {
    final counts = <String, int>{};
    for (final m in week) {
      if (m.mood != MomentMood.gladIDid) continue;
      counts[m.habitName] = (counts[m.habitName] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (ranked.first.value < 2) return null;
    if (ranked.length > 1 && ranked.first.value == ranked[1].value) return null;
    return ranked.first.key;
  }

  static DayPart _partOf(int hour) => hour < 5
      ? DayPart.nights
      : hour < 12
          ? DayPart.mornings
          : hour < 17
              ? DayPart.afternoons
              : hour < 22
                  ? DayPart.evenings
                  : DayPart.nights;

  static DateTime _wallDay(Moment m) {
    final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
    return DateTime.utc(local.year, local.month, local.day);
  }
}
