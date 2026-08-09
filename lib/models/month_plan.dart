import 'moment.dart';

/// The four changes the app is willing to propose.
///
/// Every one of them writes a real setting when accepted. That is the whole
/// test for whether something belongs on this list (§4.5): a paid insight has
/// to end in a button that changes something, and a mirror does not justify a
/// subscription.
///
/// §6.2 also sketched a "lighter on Wednesdays and Thursdays" nudge. It is not
/// here, because there is no setting behind it — accepting would change
/// nothing and the app would be asking for a decision it cannot act on.
enum NudgeKind {
  /// Move the daily reminder to where the moments actually land.
  moveReminder,

  /// Return an action to the pool it came from. Never "delete", never "fail".
  setAside,

  /// Pin the action that carried the month to the top of Today.
  keepAnchor,

  /// Add the focus area they lived but never chose.
  addFocusArea,
}

/// One proposed change, with the evidence that produced it.
class PlanNudge {
  const PlanNudge({
    required this.kind,
    required this.confidence,
    required this.count,
    this.habitName,
    this.focusArea,
    this.hour,
  });

  final NudgeKind kind;

  /// 0..1. Ranks the nudges against each other so the strongest becomes this
  /// month's one decision.
  final double confidence;

  /// The number the copy quotes: times an action was reached for, or moments
  /// that landed in a window or a focus area.
  final int count;

  final String? habitName;
  final String? focusArea;

  /// Local hour to move the reminder to.
  final int? hour;

  /// Stable identity for "this exact suggestion", so declining the set-aside
  /// of one action doesn't silence the set-aside of another.
  String get id => '${kind.name}:${habitName ?? focusArea ?? hour ?? ''}';

  /// What the nudge is about, for the record kept after it is accepted.
  String get subject => habitName ?? focusArea ?? hour?.toString() ?? '';
}

/// Next month, proposed from last month's evidence (§6.2).
///
/// This is what changes the subscription from *reviewing the past* to
/// *planning the next month*, which is what makes someone open the page in
/// month seven. It also absorbs what used to be loose nudges scattered across
/// the app, so they stop being buttons and become one decision.
///
/// **One decision per month, not three** (§5.3). The nudges are ranked and the
/// screen shows the top one; the rest wait behind "2 more when you're ready".
/// An earlier version put three nudges and six buttons on the page, which read
/// as a dashboard demanding optimisation — the opposite of what this app is.
class MonthPlan {
  const MonthPlan({required this.monthKey, required this.nudges});

  /// The month the plan is *for* — this month, read from last month.
  final String monthKey;

  /// Ranked, strongest first. Empty means the card is not on the screen at
  /// all: §5.3 forbids a section that exists to restate a promise.
  final List<PlanNudge> nudges;

  bool get isEmpty => nudges.isEmpty;

  /// Below this, last month cannot support a claim about how the month went.
  static const int minMoments = 10;

  /// Reads last month and proposes changes for this one.
  ///
  /// [declinedIds] are suggestions the user has already passed on this month;
  /// re-offering one every time the tab opens turns a suggestion into nagging.
  static MonthPlan read({
    required String monthKey,
    required List<Moment> lastMonth,
    required List<String> activeHabits,
    required List<String> customHabits,
    required List<String> focusAreas,
    required int reminderHour,
    required bool remindersEnabled,
    required bool hasPinnedHabit,
    Set<String> declinedIds = const {},
  }) {
    if (lastMonth.length < minMoments) {
      return MonthPlan(monthKey: monthKey, nudges: const []);
    }

    final counts = _countsByHabit(lastMonth);
    final nudges = [
      if (remindersEnabled) _moveReminder(lastMonth, reminderHour),
      _addFocusArea(lastMonth, focusAreas),
      _setAside(lastMonth, counts, activeHabits, customHabits),
      _keepAnchor(counts, activeHabits, hasPinnedHabit),
    ].whereType<PlanNudge>().where((n) => !declinedIds.contains(n.id)).toList()
      // Ties fall back to the order the kinds are declared in, so the same
      // month always proposes the same decision. Dart's sort is not stable,
      // and a card that offered a different suggestion each time the tab
      // opened would read as the app changing its mind.
      ..sort((a, b) {
        final byConfidence = b.confidence.compareTo(a.confidence);
        return byConfidence != 0
            ? byConfidence
            : a.kind.index.compareTo(b.kind.index);
      });

    return MonthPlan(monthKey: monthKey, nudges: nudges);
  }

  /// Move the reminder to where the moments actually land.
  ///
  /// The one nudge §6.2 has a worked before/after for, and the cheapest change
  /// a user can make — it costs them nothing and moves the prompt to the hour
  /// they were already showing up in.
  ///
  /// Only offered when reminders are switched on at all. Moving a reminder
  /// nobody receives is a button that changes nothing, which is the one thing
  /// a paid suggestion is not allowed to be.
  static PlanNudge? _moveReminder(List<Moment> moments, int reminderHour) {
    // The hour the moments are actually in — the reminder goes there, not to
    // whichever neighbouring hour happens to sweep up the same moments.
    final byHour = <int, int>{};
    for (final m in moments) {
      byHour[m.localHour] = (byHour[m.localHour] ?? 0) + 1;
    }
    var bestHour = 0;
    var bestCount = 0;
    for (final entry in byHour.entries) {
      if (entry.value > bestCount ||
          (entry.value == bestCount && entry.key < bestHour)) {
        bestCount = entry.value;
        bestHour = entry.key;
      }
    }

    // Qualified by the hours either side of it, so someone landing at 21:00,
    // 22:00 and 23:00 reads as one evening rather than three hours that each
    // hold a third of the month and none of which is a pattern.
    final windowCount =
        moments.where((m) => _hoursApart(m.localHour, bestHour) <= 1).length;
    final share = windowCount / moments.length;
    if (share < _minWindowShare) return null;

    // Within a couple of hours the reminder is already in the right part of
    // the day, and moving it would be churn dressed as insight.
    if (_hoursApart(bestHour, reminderHour) < _minReminderShift) return null;

    return PlanNudge(
      kind: NudgeKind.moveReminder,
      confidence: share,
      count: windowCount,
      hour: bestHour,
    );
  }

  /// Add the focus area they lived but never chose.
  ///
  /// This is the finding the free tier's teaser card points at — the gap
  /// between the focus someone picked and the one they actually spent the
  /// month in. Here it becomes something they can act on.
  static PlanNudge? _addFocusArea(
    List<Moment> moments,
    List<String> focusAreas,
  ) {
    final counts = <String, int>{};
    for (final m in moments) {
      final key = m.category;
      if (key == null || focusAreas.contains(key)) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;

    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final share = top.value / moments.length;
    if (top.value < _minUnchosenCount || share < _minUnchosenShare) return null;

    return PlanNudge(
      kind: NudgeKind.addFocusArea,
      confidence: share,
      count: top.value,
      focusArea: top.key,
    );
  }

  /// Return an action to the pool. Never framed as failure — the action didn't
  /// work out, and taking it off the list is curation.
  ///
  /// Custom actions are never proposed: they are the user's own words, and
  /// the storage layer deliberately refuses to remove them, so the button
  /// would do nothing.
  static PlanNudge? _setAside(
    List<Moment> moments,
    Map<String, int> counts,
    List<String> activeHabits,
    List<String> customHabits,
  ) {
    if (moments.length < _minMonthForSetAside) return null;

    final candidates = activeHabits
        .where((h) => !customHabits.contains(h))
        .where((h) => (counts[h] ?? 0) <= _maxSetAsideCount)
        .toList();
    if (candidates.isEmpty) return null;

    // Taking one away has to leave a list worth opening.
    if (activeHabits.length - 1 < _minHabitsRemaining) return null;

    // The least-reached-for, and among equals the first the user listed — a
    // stable choice rather than one that changes with map ordering.
    var chosen = candidates.first;
    for (final habit in candidates) {
      if ((counts[habit] ?? 0) < (counts[chosen] ?? 0)) chosen = habit;
    }
    final chosenCount = counts[chosen] ?? 0;

    // Only when the rest of the month clearly went elsewhere. A quiet action
    // in a quiet month is just a quiet month.
    final busiest = counts.values.isEmpty
        ? 0
        : counts.values.reduce((a, b) => a > b ? a : b);
    if (busiest < (chosenCount + 1) * 3) return null;

    return PlanNudge(
      kind: NudgeKind.setAside,
      confidence:
          ((_maxSetAsideCount + 1 - chosenCount) / (_maxSetAsideCount + 1))
              .clamp(0.0, 1.0),
      count: chosenCount,
      habitName: chosen,
    );
  }

  /// Pin the action that carried the month.
  ///
  /// Deliberately the weakest of the four, and it exists mostly as the
  /// counterweight to setting one aside: a month that only ever proposes
  /// removals reads as an audit. It is the fallback decision, never the
  /// headline one — hence the fixed low confidence.
  static PlanNudge? _keepAnchor(
    Map<String, int> counts,
    List<String> activeHabits,
    bool hasPinnedHabit,
  ) {
    if (hasPinnedHabit) return null;

    final ranked = counts.entries
        .where((e) => activeHabits.contains(e.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (ranked.length < 2) return null;
    if (ranked.first.value < _minAnchorCount) return null;
    // "More than anything else" has to be true, so a tie names nothing.
    if (ranked.first.value == ranked[1].value) return null;

    return PlanNudge(
      kind: NudgeKind.keepAnchor,
      confidence: _keepAnchorConfidence,
      count: ranked.first.value,
      habitName: ranked.first.key,
    );
  }

  static Map<String, int> _countsByHabit(List<Moment> moments) {
    final counts = <String, int>{};
    for (final m in moments) {
      counts[m.habitName] = (counts[m.habitName] ?? 0) + 1;
    }
    return counts;
  }

  /// Distance between two hours around the clock: 23:00 and 01:00 are two
  /// hours apart, not twenty-two.
  static int _hoursApart(int a, int b) {
    final d = (a - b).abs();
    return d <= 12 ? d : 24 - d;
  }

  /// The window has to hold half the month before "that's when your moments
  /// land" is a description rather than a guess.
  static const double _minWindowShare = 0.5;

  /// Under three hours the reminder is already in the right part of the day.
  static const int _minReminderShift = 3;

  static const int _minUnchosenCount = 4;
  static const double _minUnchosenShare = 0.25;

  /// Set-aside needs a month full enough that passing something over means
  /// something.
  static const int _minMonthForSetAside = 12;
  static const int _maxSetAsideCount = 3;
  static const int _minHabitsRemaining = 2;

  static const int _minAnchorCount = 3;
  static const double _keepAnchorConfidence = 0.2;
}
