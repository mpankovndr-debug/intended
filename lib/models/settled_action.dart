/// An action steady enough, for long enough, that the app can offer its slot
/// back: *"this looks like it's yours now — keep it, or make room?"*
///
/// The other branch of the question `_setAside` asks. That one finds a slot
/// holding something you don't reach for; this one finds a slot holding
/// something that no longer needs the holding.
///
/// Pure — every input is passed in, nothing is read from storage and nothing
/// needs a `BuildContext`, so the rule is testable and the reading of it lives
/// somewhere else. The counting store is `habit_done_*`, which is permanent
/// and uncapped; `moments_collection` stops at 1000 and could not answer a
/// question this long-range.
///
/// What this measures is **steadiness of return**, which is not automaticity —
/// that is a psychological state no count can see. So the copy may claim only
/// the computed thing (this often, three months running) and a hedge ("looks
/// like"), never the state itself.
class SettledAction {
  const SettledAction({required this.habitName, required this.monthCounts});

  final String habitName;

  /// Days holding a completion in each of the three closed months, most
  /// recent first. The evidence the card quotes, carried with the finding so
  /// the sentence and the rule can never be computed from different numbers.
  final List<int> monthCounts;

  int get total => monthCounts.fold(0, (a, b) => a + b);

  /// Closed calendar months of evidence required.
  ///
  /// Lally's ~66-day median for automaticity — the same finding
  /// `MomentRollup.gapThresholdDays` cites — means two months straddles it.
  /// Three clears it for the fast half and reaches it for the slow.
  static const int monthsRequired = 3;

  /// Days in a month below which it cannot testify.
  ///
  /// Twelve is already this codebase's bar for "a month with enough signal",
  /// borrowed from `MonthPlan._minMonthForSetAside`. Roughly three returns a
  /// week. Deliberately far below daily: a higher bar would be a perfection
  /// test, which is a streak wearing a threshold's clothes.
  ///
  /// A floor on a count — never a numerator. The month's length is not
  /// consulted and no share of it is computed anywhere in this file.
  static const int minMonthDays = 12;

  /// How far apart the three months may sit.
  ///
  /// The sentence is "about as often, three months running", so the months
  /// have to be about as often — the threshold is set by the copy, not the
  /// other way round. Five absorbs the calendar's own jitter (a 28-day
  /// February against a 31-day neighbour is 3) plus a lost weekend, while
  /// still blocking a climb (8/15/22 — a habit still taking hold, the worst
  /// possible moment to pull its support) and a slide (22/15/12 — a habit
  /// fading, where "it's yours now" would be a compliment wearing a mistake).
  static const int countBand = 5;

  /// Taking one away has to leave a list worth opening — `_setAside`'s guard.
  static const int minHabitsRemaining = 2;

  /// The settled action, or null when nothing qualifies.
  ///
  /// [monthCounts] maps title to its per-month day counts, in the same order
  /// for every habit. [candidates] must be in render order: it is the tiebreak
  /// when two actions total the same, because Dart's sort is not stable and a
  /// plan that changed its mind between visits would read as the app being
  /// unsure.
  ///
  /// [atCeiling] is whether the list is full. "Make room for something else"
  /// is only true when there is no room; below the cap the second clause of
  /// the offer is false, and a card must not speak a clause its data
  /// contradicts.
  ///
  /// [declinedRecently] are habits whose give-back was passed on inside the
  /// cooldown. Settled evidence barely moves month to month, so the ordinary
  /// per-month decline would re-ask every month — and a monthly "are you sure
  /// it isn't yours?" is a nag wearing a compliment.
  static SettledAction? read({
    required List<String> candidates,
    required Map<String, List<int>> monthCounts,
    required List<String> customHabits,
    required bool atCeiling,
    String? pinnedHabit,
    Set<String> declinedRecently = const {},
  }) {
    if (!atCeiling) return null;
    if (candidates.length - 1 < minHabitsRemaining) return null;

    SettledAction? best;
    for (final habit in candidates) {
      // v1 is seeded actions only. A masked custom is offered on fewer days
      // by the user's own choice, so a flat 12-day floor would measure the
      // schedule rather than the rhythm — and no mask history exists to ask
      // what a past month actually offered.
      if (customHabits.contains(habit)) continue;
      // Pinning is the user's own declaration that this slot is load-bearing.
      if (habit == pinnedHabit) continue;
      if (declinedRecently.contains(habit)) continue;

      final counts = monthCounts[habit];
      if (counts == null || counts.length < monthsRequired) continue;
      if (counts.any((c) => c < minMonthDays)) continue;

      final high = counts.reduce((a, b) => a > b ? a : b);
      final low = counts.reduce((a, b) => a < b ? a : b);
      if (high - low > countBand) continue;

      final found = SettledAction(habitName: habit, monthCounts: counts);
      // Strictly greater: an equal total leaves the earlier candidate in
      // place, which is render order — the explicit, stable tiebreak.
      if (best == null || found.total > best.total) best = found;
    }
    return best;
  }
}
