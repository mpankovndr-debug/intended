import 'package:shared_preferences/shared_preferences.dart';

/// Reads the permanent completion record — the `habit_done_*` keys.
///
/// That store has no cap and is never pruned, so it is the only place a claim
/// spanning several months can be computed from. `moments_collection` is
/// capped at 1000 and cannot answer a question this long-range.
///
/// Lives here rather than on `HabitTracker` because that class is in
/// `main.dart`, which nothing new may grow into.
class HabitHistoryService {
  HabitHistoryService._();

  static const String _prefix = 'habit_done_';

  /// Normalise a habit title into the slug its storage keys use.
  ///
  /// The single definition. `HabitTracker.habitId` and `OnboardingState`'s
  /// copy both delegate here: three hand-copies of one rule is how they stop
  /// agreeing, and every key this service parses was written by one of them.
  static String habitId(String habitTitle) {
    return habitTitle
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// The `yyyy-MM` keys of the [count] calendar months that have closed before
  /// [now], most recent first.
  ///
  /// The month being lived is excluded: it cannot testify to a full month's
  /// rhythm until it is over.
  static List<String> closedMonthsBefore(DateTime now, {int count = 3}) {
    final keys = <String>[];
    var year = now.year;
    var month = now.month;
    for (var i = 0; i < count; i++) {
      month -= 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
      keys.add('$year-${month.toString().padLeft(2, '0')}');
    }
    return keys;
  }

  /// Days holding a completion, per habit, for each month in [months].
  ///
  /// Returns `{title: [count for months[0], months[1], …]}`, so the caller's
  /// month order is the list order. A habit with no key in a month gets 0
  /// rather than being absent — the rule needs to see the zero.
  ///
  /// Counts *days*, never a share of the month: there is no denominator here
  /// and no rate, by design.
  static Future<Map<String, List<int>>> monthCountsFor(
    List<String> titles,
    List<String> months,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // slug -> title, so two titles slugging the same way cannot both claim
    // the keys; the first listed wins, matching render order.
    final bySlug = <String, String>{};
    for (final t in titles) {
      bySlug.putIfAbsent(habitId(t), () => t);
    }

    final counts = <String, List<int>>{
      for (final t in titles) t: List<int>.filled(months.length, 0),
    };

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_prefix)) continue;
      if (prefs.getBool(key) != true) continue;

      // `habit_done_{slug}_{yyyy-MM-dd}` — the slug may itself hold
      // underscores, so the date is taken from the end, not by splitting.
      final rest = key.substring(_prefix.length);
      if (rest.length < 12) continue;
      final date = rest.substring(rest.length - 10);
      final slug = rest.substring(0, rest.length - 11);

      final title = bySlug[slug];
      if (title == null) continue;

      final monthIndex = months.indexOf(date.substring(0, 7));
      if (monthIndex == -1) continue;

      counts[title]![monthIndex] += 1;
    }

    return counts;
  }
}
