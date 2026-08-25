import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/month_plan.dart';
import 'package:intended/models/settled_action.dart';
import 'package:intended/services/habit_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _six = ['Walk', 'Read', 'Water', 'Stretch', 'Breathe', 'Tidy'];

SettledAction? _read({
  Map<String, List<int>> counts = const {},
  List<String> candidates = _six,
  List<String> customs = const [],
  bool atCeiling = true,
  String? pinned,
  Set<String> declined = const {},
}) =>
    SettledAction.read(
      candidates: candidates,
      monthCounts: counts,
      customHabits: customs,
      atCeiling: atCeiling,
      pinnedHabit: pinned,
      declinedRecently: declined,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('what counts as settled', () {
    test('three steady months qualify', () {
      final s = _read(counts: {'Walk': [15, 14, 16]});
      expect(s?.habitName, 'Walk');
      expect(s?.monthCounts, [15, 14, 16]);
      expect(s?.total, 45);
    });

    test('one month under the floor disqualifies', () {
      // 11 is below minMonthDays; a quiet month is not a season of steadiness.
      expect(_read(counts: {'Walk': [15, 11, 16]}), isNull);
    });

    test('a climb is not settled — it is still taking hold', () {
      expect(_read(counts: {'Walk': [22, 15, 12]}), isNull);
    });

    test('a slide is not settled either', () {
      expect(_read(counts: {'Walk': [12, 15, 22]}), isNull);
    });

    test('a band of exactly 5 is still steady', () {
      expect(_read(counts: {'Walk': [17, 12, 14]})?.habitName, 'Walk');
    });

    test('fewer than three months says nothing', () {
      expect(_read(counts: {'Walk': [20, 20]}), isNull);
    });
  });

  group('what disqualifies regardless of the counts', () {
    test('below the ceiling there is no room to offer', () {
      expect(
        _read(counts: {'Walk': [15, 14, 16]}, atCeiling: false),
        isNull,
      );
    });

    test('the pinned action is the user saying the slot is load-bearing', () {
      expect(_read(counts: {'Walk': [15, 14, 16]}, pinned: 'Walk'), isNull);
    });

    test('a custom is out of scope in v1', () {
      expect(
        _read(counts: {'Walk': [15, 14, 16]}, customs: ['Walk']),
        isNull,
      );
    });

    test('a declined offer stays quiet through the cooldown', () {
      expect(
        _read(counts: {'Walk': [15, 14, 16]}, declined: {'Walk'}),
        isNull,
      );
    });

    test('removing it must leave a list worth opening', () {
      expect(
        _read(counts: {'Walk': [15, 14, 16]}, candidates: ['Walk', 'Read']),
        isNull,
      );
    });
  });

  group('choosing between several', () {
    test('the highest three-month total wins', () {
      final s = _read(counts: {
        'Walk': [13, 13, 13],
        'Read': [16, 15, 14],
      });
      expect(s?.habitName, 'Read');
    });

    test('a tie is broken by render order, not by map order', () {
      final s = _read(counts: {
        'Read': [14, 14, 14],
        'Walk': [14, 14, 14],
      });
      // 'Walk' is first in candidates, so it wins however the map iterates.
      expect(s?.habitName, 'Walk');
    });
  });

  group('the plan places it correctly', () {
    const settled =
        SettledAction(habitName: 'Walk', monthCounts: [15, 14, 16]);

    Moment did(String habit) => Moment.create(
          habitName: habit,
          category: 'Health',
          at: DateTime(2026, 7, 10, 9),
        );

    PlanNudge? actionOf(List<Moment> lastMonth, {SettledAction? s = settled}) {
      return MonthPlan.read(
        monthKey: '2026-08',
        lastMonth: lastMonth,
        activeHabits: _six,
        customHabits: const [],
        focusAreas: const ['Health'],
        reminderHour: 9,
        remindersEnabled: false,
        hasPinnedHabit: false,
        settled: s,
      ).topAction;
    }

    test('no plan at all when last month is too quiet', () {
      // minMoments guards the whole plan, however settled the action is.
      expect(actionOf(const []), isNull);
    });

    test('it becomes the month\'s one action when nothing outranks it', () {
      // Two each across six habits: 12 moments clears minMoments, no habit is
      // quiet enough for set-aside, none high enough to anchor.
      final lastMonth = [for (final h in _six) ...[did(h), did(h)]];
      final top = actionOf(lastMonth);
      expect(top?.kind, NudgeKind.giveBack);
      expect(top?.habitName, 'Walk');
      // The card quotes three months, so the evidence travels with it.
      expect(top?.monthCounts, [15, 14, 16]);
    });

    test('set-aside speaks first when both fire', () {
      // A wrong set-aside returns something unused to the pool; a wrong
      // give-back pulls the support out from under the strongest practice.
      final lastMonth = [
        for (var i = 0; i < 12; i++) did('Read'),
        did('Tidy'),
      ];
      expect(actionOf(lastMonth)?.kind, NudgeKind.setAside);
    });

    test('a declined give-back leaves the slot to another nudge', () {
      final lastMonth = [for (final h in _six) ...[did(h), did(h)]];
      final plan = MonthPlan.read(
        monthKey: '2026-08',
        lastMonth: lastMonth,
        activeHabits: _six,
        customHabits: const [],
        focusAreas: const ['Health'],
        reminderHour: 9,
        remindersEnabled: false,
        hasPinnedHabit: false,
        declinedIds: const {'giveBack:Walk'},
        settled: settled,
      );
      expect(plan.topAction, isNull);
    });
  });

  group('HabitHistoryService counts days from the permanent store', () {
    test('groups keys by habit and month, ignoring other months', () async {
      SharedPreferences.setMockInitialValues({
        'habit_done_walk_2026-07-01': true,
        'habit_done_walk_2026-07-02': true,
        'habit_done_walk_2026-06-14': true,
        'habit_done_walk_2026-03-01': true, // outside the window
        'habit_done_read_2026-07-09': true,
      });
      final counts = await HabitHistoryService.monthCountsFor(
        ['Walk', 'Read'],
        ['2026-07', '2026-06', '2026-05'],
      );
      expect(counts['Walk'], [2, 1, 0]);
      expect(counts['Read'], [1, 0, 0]);
    });

    test('a slug holding underscores still parses', () async {
      SharedPreferences.setMockInitialValues({
        'habit_done_walk_the_dog_2026-07-01': true,
      });
      final counts = await HabitHistoryService.monthCountsFor(
        ['Walk the dog'],
        ['2026-07'],
      );
      expect(counts['Walk the dog'], [1]);
    });

    test('a key written false is not a completion', () async {
      SharedPreferences.setMockInitialValues({
        'habit_done_walk_2026-07-01': false,
      });
      final counts =
          await HabitHistoryService.monthCountsFor(['Walk'], ['2026-07']);
      expect(counts['Walk'], [0]);
    });

    test('closed months exclude the one being lived', () {
      expect(
        HabitHistoryService.closedMonthsBefore(DateTime(2026, 8, 25)),
        ['2026-07', '2026-06', '2026-05'],
      );
    });

    test('and hold across a January boundary', () {
      expect(
        HabitHistoryService.closedMonthsBefore(DateTime(2026, 1, 15)),
        ['2025-12', '2025-11', '2025-10'],
      );
    });
  });
}
