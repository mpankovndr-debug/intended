import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/drift.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/services/moments_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A Wednesday, so weekday == 3 throughout.
final _wed = DateTime(2026, 8, 12);

Future<OnboardingState> _boot({
  List<String> habits = const [],
  List<String> customs = const [],
  Map<String, Object> extra = const {},
}) async {
  SharedPreferences.setMockInitialValues({
    'user_habits': habits,
    'custom_habits': customs,
    'focus_areas': <String>['Health'],
    ...extra,
  });
  final s = OnboardingState();
  await s.loadUserHabits();
  return s;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('habitsForToday', () {
    test('with no mask set, it is visibleHabits unchanged', () async {
      final s = await _boot(
        habits: ['Drink a glass of water', 'Walk the dog'],
        customs: ['Walk the dog'],
      );
      expect(s.habitsForToday(now: _wed), s.visibleHabits());
    });

    test('drops a custom whose mask excludes today', () async {
      final s = await _boot(
        habits: ['Drink a glass of water', 'Walk the dog'],
        customs: ['Walk the dog'],
      );
      await s.setCustomHabitDays('Walk the dog', [1, 2]); // Mon, Tue
      expect(s.habitsForToday(now: _wed), ['Drink a glass of water']);
    });

    test('keeps a custom whose mask includes today', () async {
      final s = await _boot(
        habits: ['Drink a glass of water', 'Walk the dog'],
        customs: ['Walk the dog'],
      );
      await s.setCustomHabitDays('Walk the dog', [3]); // Wed
      expect(s.habitsForToday(now: _wed), s.visibleHabits());
    });

    test('never masks a seeded action', () async {
      final s = await _boot(
        habits: ['Drink a glass of water', 'Walk the dog'],
        customs: ['Walk the dog'],
      );
      await s.setCustomHabitDays('Drink a glass of water', [1]);
      expect(s.customHabitDays, isEmpty);
      expect(s.habitsForToday(now: _wed), s.visibleHabits());
    });

    test('a day that would be empty falls back to the full list', () async {
      final s = await _boot(
        habits: ['Walk the dog', 'Call mum'],
        customs: ['Walk the dog', 'Call mum'],
      );
      await s.setCustomHabitDays('Walk the dog', [1]);
      await s.setCustomHabitDays('Call mum', [2]);
      // Both masked off a Wednesday — the screen must not go blank.
      expect(s.habitsForToday(now: _wed), s.visibleHabits());
      expect(s.habitsForToday(now: _wed), isNotEmpty);
    });
  });

  group('setCustomHabitDays', () {
    test('all seven days clears the entry rather than storing it', () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await s.setCustomHabitDays('Walk the dog', [1, 2, 3, 4, 5, 6, 7]);
      expect(s.customHabitDays, isEmpty);
    });

    test('normalises order and duplicates', () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await s.setCustomHabitDays('Walk the dog', [5, 1, 5, 9, 0, 3]);
      expect(s.customHabitDays['Walk the dog'], [1, 3, 5]);
    });

    test('an unchanged mask does not re-stamp the drift timestamp', () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await s.setCustomHabitDays('Walk the dog', [1, 3]);
      final prefs = await SharedPreferences.getInstance();
      final first = prefs.getString(OnboardingState.customHabitDaysChangedAtKey);
      expect(first, isNotNull);

      await s.setCustomHabitDays('Walk the dog', [3, 1]); // same mask
      expect(prefs.getString(OnboardingState.customHabitDaysChangedAtKey),
          first);
    });

    test('survives a restart', () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await s.setCustomHabitDays('Walk the dog', [1, 3]);

      final reloaded = OnboardingState();
      await reloaded.loadUserHabits();
      expect(reloaded.customHabitDays['Walk the dog'], [1, 3]);
    });
  });

  group('lifecycle', () {
    test('rename carries the mask across, without re-stamping', () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await s.setCustomHabitDays('Walk the dog', [1, 3]);
      final prefs = await SharedPreferences.getInstance();
      final stamp = prefs.getString(OnboardingState.customHabitDaysChangedAtKey);

      await s.renameCustomHabit('Walk the dog', 'Walk Bruno');
      expect(s.customHabitDays['Walk Bruno'], [1, 3]);
      expect(s.customHabitDays.containsKey('Walk the dog'), isFalse);
      // Rewording is not rescheduling.
      expect(prefs.getString(OnboardingState.customHabitDaysChangedAtKey),
          stamp);
    });

    test('rename carries the moments across, so history does not split',
        () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await MomentsService.record(Moment.create(
        habitName: 'Walk the dog',
        category: 'Health',
        at: _wed,
      ));

      await s.renameCustomHabit('Walk the dog', 'Walk Bruno');

      final all = await MomentsService.getAll();
      expect(all.map((m) => m.habitName), ['Walk Bruno']);
    });

    test('a case-only rename still moves them, though the slug is unchanged',
        () async {
      // The completion keys slug to the same id and need no migration, but
      // `habitName` is the full title — the key everything else joins on.
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await MomentsService.record(Moment.create(
        habitName: 'Walk the dog',
        category: 'Health',
        at: _wed,
      ));

      await s.renameCustomHabit('Walk the dog', 'Walk The Dog');

      final all = await MomentsService.getAll();
      expect(all.single.habitName, 'Walk The Dog');
    });

    test('it leaves another action\'s moments alone', () async {
      final s = await _boot(
        habits: ['Walk the dog', 'Read'],
        customs: ['Walk the dog', 'Read'],
      );
      await MomentsService.record(Moment.create(
        habitName: 'Read', category: 'Health', at: _wed));
      await MomentsService.record(Moment.create(
        habitName: 'Walk the dog', category: 'Health', at: _wed));

      await s.renameCustomHabit('Walk the dog', 'Walk Bruno');

      final all = await MomentsService.getAll();
      expect(all.map((m) => m.habitName).toSet(), {'Walk Bruno', 'Read'});
    });

    test('delete removes the mask entry', () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await s.setCustomHabitDays('Walk the dog', [1, 3]);
      await s.removeCustomHabit('Walk the dog');
      expect(s.customHabitDays, isEmpty);
    });

    test('reset clears both mask keys', () async {
      final s = await _boot(habits: ['Walk the dog'], customs: ['Walk the dog']);
      await s.setCustomHabitDays('Walk the dog', [1, 3]);
      await s.reset();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('custom_habit_days'), isNull);
      expect(prefs.getString(OnboardingState.customHabitDaysChangedAtKey),
          isNull);
      expect(s.customHabitDays, isEmpty);
    });

    test('generateUserHabits and changeFocusAreas keep the mask', () async {
      final s = await _boot(
        habits: ['Drink a glass of water', 'Walk the dog'],
        customs: ['Walk the dog'],
      );
      await s.setCustomHabitDays('Walk the dog', [1, 3]);
      await s.generateUserHabits();
      expect(s.customHabitDays['Walk the dog'], [1, 3]);
      await s.changeFocusAreas(['Mood']);
      expect(s.customHabitDays['Walk the dog'], [1, 3]);
    });
  });

  group('Drift suppression', () {
    Moment on(DateTime day) =>
        Moment.create(habitName: 'x', category: 'Health', at: day);

    List<Moment> week(int weeksAgo, int count) {
      final start = DateTime(_wed.year, _wed.month, _wed.day)
          .subtract(Duration(days: _wed.weekday - 1 + 7 * weeksAgo));
      return [
        for (var i = 0; i < count; i++) on(start.add(Duration(days: i % 7)))
      ];
    }

    final dipping = [
      for (var w = 4; w >= 1; w--) ...week(w, 6),
      ...week(0, 2),
    ];

    test('a real dip still reads when no mask was ever set', () {
      expect(Drift.read(dipping, now: _wed), isNotNull);
    });

    test('silent while a mask is younger than 28 days', () {
      final recent = _wed.subtract(const Duration(days: 27));
      expect(Drift.read(dipping, now: _wed, maskChangedAt: recent), isNull);
    });

    test('speaks again once the mask is 28 days old', () {
      final old = _wed.subtract(const Duration(days: 28));
      expect(Drift.read(dipping, now: _wed, maskChangedAt: old), isNotNull);
    });
  });
}
