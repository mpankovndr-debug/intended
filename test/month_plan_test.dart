import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/month_plan.dart';

Moment _on(int day, {String habit = 'Body scan', int hour = 9, String category = 'Health'}) =>
    Moment.create(
      habitName: habit,
      category: category,
      at: DateTime(2026, 7, day, hour),
      id: '$day-$hour-$habit-$category',
    );

List<Moment> _daily(
  int count, {
  int startDay = 1,
  String habit = 'Body scan',
  int hour = 9,
  String category = 'Health',
}) =>
    [
      for (var i = 0; i < count; i++)
        _on(startDay + i, habit: habit, hour: hour, category: category),
    ];

MonthPlan _plan(
  List<Moment> lastMonth, {
  List<String> habits = const ['Body scan', 'Drink water', 'Stretch'],
  List<String> custom = const [],
  List<String> focus = const ['Health'],
  int reminderHour = 9,
  bool remindersEnabled = true,
  bool pinned = false,
  Set<String> declined = const {},
}) =>
    MonthPlan.read(
      monthKey: '2026-08',
      lastMonth: lastMonth,
      activeHabits: habits,
      customHabits: custom,
      focusAreas: focus,
      reminderHour: reminderHour,
      remindersEnabled: remindersEnabled,
      hasPinnedHabit: pinned,
      declinedIds: declined,
    );

PlanNudge? _nudgeOf(MonthPlan plan, NudgeKind kind) {
  for (final n in plan.nudges) {
    if (n.kind == kind) return n;
  }
  return null;
}

void main() {
  group('when there is nothing to propose', () {
    test('a thin month proposes nothing', () {
      expect(_plan(_daily(9, hour: 22)).isEmpty, isTrue);
    });

    test('a declined suggestion is not offered again this month', () {
      final moments = _daily(14, hour: 22);
      final first = _nudgeOf(_plan(moments), NudgeKind.moveReminder)!;

      expect(
        _nudgeOf(_plan(moments, declined: {first.id}), NudgeKind.moveReminder),
        isNull,
      );
    });
  });

  group('moving the reminder', () {
    test('proposes the hour the moments actually landed in', () {
      // A month of late evenings against a 9am reminder.
      final plan = _plan(_daily(14, hour: 22), reminderHour: 9);
      expect(_nudgeOf(plan, NudgeKind.moveReminder)!.hour, 22);
    });

    test('says nothing when the reminder is already about right', () {
      final plan = _plan(_daily(14, hour: 22), reminderHour: 21);
      expect(_nudgeOf(plan, NudgeKind.moveReminder), isNull);
    });

    test('counts around midnight, not across it', () {
      // 23:00 and 01:00 are two hours apart. Measured the naive way they are
      // twenty-two, and the app would propose moving a reminder that is
      // already sitting in the right hour.
      final plan = _plan(_daily(14, hour: 23), reminderHour: 1);
      expect(_nudgeOf(plan, NudgeKind.moveReminder), isNull);
    });

    test('a month spread across the clock has no hour to propose', () {
      final moments = [
        for (var i = 0; i < 16; i++) _on(i + 1, hour: i + 4),
      ];
      expect(_nudgeOf(_plan(moments), NudgeKind.moveReminder), isNull);
    });

    test('never offered when reminders are switched off', () {
      // The button would move a notification nobody receives.
      final plan = _plan(
        _daily(14, hour: 22),
        reminderHour: 9,
        remindersEnabled: false,
      );
      expect(_nudgeOf(plan, NudgeKind.moveReminder), isNull);
    });
  });

  group('setting an action aside', () {
    test('names the one that was passed over', () {
      final moments = [
        ..._daily(12, habit: 'Body scan'),
        ..._daily(2, startDay: 13, habit: 'Drink water'),
      ];
      final nudge = _nudgeOf(_plan(moments), NudgeKind.setAside)!;

      // 'Stretch' was never reached for at all.
      expect(nudge.habitName, 'Stretch');
      expect(nudge.count, 0);
    });

    test('never proposes the user own words', () {
      // Custom actions cannot be removed by the storage layer, so proposing
      // one would be a button that does nothing.
      final moments = _daily(14, habit: 'Body scan');
      final nudge = _nudgeOf(
        _plan(moments, habits: ['Body scan', 'Drink water', 'Sit with Nina'],
            custom: ['Sit with Nina']),
        NudgeKind.setAside,
      );

      expect(nudge!.habitName, 'Drink water');
    });

    test('a quiet action in an evenly spread month is left alone', () {
      // Nothing carried this month, so nothing was passed over either.
      final moments = [
        ..._daily(5, habit: 'Body scan'),
        ..._daily(5, startDay: 6, habit: 'Drink water'),
        ..._daily(3, startDay: 11, habit: 'Stretch'),
      ];
      expect(_nudgeOf(_plan(moments), NudgeKind.setAside), isNull);
    });

    test('never leaves the list too short to open', () {
      final moments = _daily(14, habit: 'Body scan');
      final plan = _plan(moments, habits: ['Body scan', 'Drink water']);
      expect(_nudgeOf(plan, NudgeKind.setAside), isNull);
    });
  });

  group('keeping the anchor', () {
    test('names the action reached for most', () {
      final moments = [
        ..._daily(10, habit: 'Body scan'),
        ..._daily(4, startDay: 11, habit: 'Drink water'),
      ];
      final nudge = _nudgeOf(_plan(moments), NudgeKind.keepAnchor)!;

      expect(nudge.habitName, 'Body scan');
      expect(nudge.count, 10);
    });

    test('a tie names nothing — "more than anything else" has to be true', () {
      final moments = [
        ..._daily(7, habit: 'Body scan'),
        ..._daily(7, startDay: 8, habit: 'Drink water'),
      ];
      expect(_nudgeOf(_plan(moments), NudgeKind.keepAnchor), isNull);
    });

    test('nothing to pin when something is already pinned', () {
      final moments = [
        ..._daily(10, habit: 'Body scan'),
        ..._daily(4, startDay: 11, habit: 'Drink water'),
      ];
      expect(
        _nudgeOf(_plan(moments, pinned: true), NudgeKind.keepAnchor),
        isNull,
      );
    });

    test('is the fallback decision, never the headline one', () {
      // A month that also earns a reminder move: the pin ranks below it.
      final moments = [
        ..._daily(10, habit: 'Body scan', hour: 22),
        ..._daily(4, startDay: 11, habit: 'Drink water', hour: 22),
      ];
      final plan = _plan(moments, reminderHour: 9);

      expect(plan.nudges.first.kind, NudgeKind.moveReminder);
      expect(plan.nudges.last.kind, NudgeKind.keepAnchor);
    });
  });

  group('adding the focus area they lived', () {
    test('names the area they spent the month in but never chose', () {
      final moments = [
        ..._daily(8, category: 'Health'),
        ..._daily(6, startDay: 9, category: 'Self-care'),
      ];
      final nudge = _nudgeOf(_plan(moments, focus: ['Health']),
          NudgeKind.addFocusArea)!;

      expect(nudge.focusArea, 'Self-care');
      expect(nudge.count, 6);
    });

    test('says nothing when the chosen focus is the lived one', () {
      final moments = _daily(14, category: 'Health');
      expect(
        _nudgeOf(_plan(moments, focus: ['Health']), NudgeKind.addFocusArea),
        isNull,
      );
    });

    test('a stray moment elsewhere is not a focus area', () {
      final moments = [
        ..._daily(13, category: 'Health'),
        _on(14, category: 'Creativity'),
      ];
      expect(
        _nudgeOf(_plan(moments, focus: ['Health']), NudgeKind.addFocusArea),
        isNull,
      );
    });
  });
}
