import 'letter.dart';
import 'moment.dart';

/// The Sunday read-back: one card naming the week that just ended.
///
/// §5.6 folded the old weekly reflection into the month page, but the
/// Sunday notification kept promising a week — and opened a page with no
/// week on it. This is that week, as a card on the month page rather than a
/// screen of its own, in the first-week keepsake's shape and words so the
/// two read as one ritual.
///
/// The week runs Monday to Sunday by each moment's own wall clock. From
/// Sunday — the evening the notification goes out — the card reads the
/// current week; Monday to Saturday it keeps reading the one just ended, so
/// a tap that lands late still finds the week it was promised. The next
/// Sunday replaces it, so it is never a fixture.
class WeekRecap {
  const WeekRecap({
    required this.weekStart,
    required this.momentCount,
    this.dominantPart,
    this.gladdestHabit,
  });

  /// Monday of the week read, UTC-flagged like [Moment.localDay].
  final DateTime weekStart;

  /// Moments in the week.
  final int momentCount;

  /// Where the week's moments clustered, when more than half of them did.
  final DayPart? dominantPart;

  /// The action marked "glad I did" most, when one clearly was.
  final String? gladdestHabit;

  /// Sunday of the week read.
  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  /// Fewer moments than this and the week has no card — and no Sunday
  /// notification, which is only ever armed over a card that exists. Same
  /// floor as the first week, for the same reason: "1 small thing" reads as
  /// a verdict, and silence is kinder than thin praise.
  static const int minMoments = 3;

  /// Monday of the week the card reads on [today]: this week on a Sunday,
  /// the one that ended last Sunday on any other day.
  static DateTime weekStartFor(DateTime today) {
    // Back to the most recent Sunday (today, on a Sunday), then six more
    // days to its Monday. UTC-flagged so the arithmetic never crosses DST.
    final sunday =
        DateTime.utc(today.year, today.month, today.day - today.weekday % 7);
    return sunday.subtract(const Duration(days: 6));
  }

  /// The card for [now]'s week, or null when that week is too thin to name.
  static WeekRecap? read(List<Moment> moments, {DateTime? now}) =>
      readWeek(moments, weekStartFor(now ?? DateTime.now()));

  /// The card for the week starting on [weekStart] (a Monday, UTC-flagged),
  /// or null below [minMoments].
  static WeekRecap? readWeek(List<Moment> moments, DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 7));
    final week = moments.where((m) {
      final day = m.localDay;
      return !day.isBefore(weekStart) && day.isBefore(end);
    }).toList();
    if (week.length < minMoments) return null;

    return WeekRecap(
      weekStart: weekStart,
      momentCount: week.length,
      dominantPart: _dominantPart(week),
      gladdestHabit: _gladdest(week),
    );
  }

  /// The card says "Most of them in the evening", so the part has to hold
  /// more than half the week. At exactly half, two parts tie and neither is
  /// most of anything.
  static DayPart? _dominantPart(List<Moment> week) {
    final counts = <DayPart, int>{};
    for (final m in week) {
      final part = DayPart.ofHour(m.localHour);
      counts[part] = (counts[part] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      if (entry.value * 2 > week.length) return entry.key;
    }
    return null;
  }

  /// The habit marked glad most often — at least two glads and a clear
  /// winner, because "the one you were glad about most" from a single tap,
  /// or from a tie, is a claim the data doesn't hold.
  static String? _gladdest(List<Moment> week) {
    final counts = <String, int>{};
    for (final m in week) {
      if (m.mood != MomentMood.gladIDid) continue;
      counts[m.habitName] = (counts[m.habitName] ?? 0) + 1;
    }
    String? top;
    var best = 0;
    var tied = false;
    for (final entry in counts.entries) {
      if (entry.value > best) {
        top = entry.key;
        best = entry.value;
        tied = false;
      } else if (entry.value == best) {
        tied = true;
      }
    }
    return best < 2 || tied ? null : top;
  }
}
