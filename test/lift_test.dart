import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/lift.dart';
import 'package:intended/models/moment.dart';

final _today = DateTime(2026, 8, 20);

/// [count] rated moments of [habit], one per day counting back from
/// [endDaysAgo] days before today.
List<Moment> _rated(
  String habit,
  int count, {
  required int endDaysAgo,
  MomentMood mood = MomentMood.gladIDid,
}) =>
    [
      for (var i = 0; i < count; i++)
        Moment.create(
          habitName: habit,
          category: 'Health',
          mood: mood,
          at: _today.subtract(Duration(days: endDaysAgo + i)),
          id: '$habit-$endDaysAgo-$i-${mood.key}',
        ),
    ];

const _active = ['Body scan', 'Drink water', 'Stretch'];

Lift? _read(List<Moment> m, {List<String> active = _active}) =>
    Lift.read(m, activeHabits: active, now: _today);

void main() {
  test('nothing rated, nothing said', () {
    final unrated = [
      Moment.create(habitName: 'Body scan', category: 'Health', at: _today),
    ];
    expect(_read(unrated), isNull);
  });

  test('ranks by how actions land, best first', () {
    // Eight weeks of history: body scan mostly glad, water mostly effort.
    final moments = [
      ..._rated('Body scan', 8, endDaysAgo: 50),
      ..._rated('Body scan', 2, endDaysAgo: 2, mood: MomentMood.tookEffort),
      ..._rated('Drink water', 2, endDaysAgo: 58),
      ..._rated('Drink water', 6, endDaysAgo: 10, mood: MomentMood.tookEffort),
    ];
    final lift = _read(moments)!;

    expect(lift.mature, isTrue);
    expect(lift.readings.first.habitName, 'Body scan');
    expect(lift.readings.first.gladCount, 8);
    expect(lift.readings.first.ratedCount, 10);
    expect(lift.readings.last.habitName, 'Drink water');
    expect(lift.readings.last.gladCount, 2);
  });

  test('under eight weeks it forms instead of ranking', () {
    // Plenty of taps, but the history is only three weeks deep.
    final moments = [
      ..._rated('Body scan', 10, endDaysAgo: 5),
      ..._rated('Drink water', 8, endDaysAgo: 5, mood: MomentMood.tookEffort),
    ];
    final lift = _read(moments)!;

    expect(lift.mature, isFalse);
    // One real reading, not a premature ranking.
    expect(lift.readings.length, 1);
    expect(lift.worst, isNull);
    expect(Lift.weeksRemaining(moments, now: _today), 6);
  });

  test('one rankable action is not a ranking', () {
    // Only body scan clears the per-action bar — nothing to rank it against.
    final moments = [
      ..._rated('Body scan', 10, endDaysAgo: 50),
      ..._rated('Drink water', 2, endDaysAgo: 50),
    ];
    expect(_read(moments)!.mature, isFalse);
  });

  test('names the one that mostly does not land', () {
    final moments = [
      ..._rated('Body scan', 8, endDaysAgo: 50),
      ..._rated('Drink water', 6, endDaysAgo: 55, mood: MomentMood.tookEffort),
      ..._rated('Drink water', 1, endDaysAgo: 3),
    ];
    expect(_read(moments)!.worst!.habitName, 'Drink water');
  });

  test('an action glad half the time is not a problem', () {
    // Proposing to remove something that lands half the time would be the
    // app inventing a problem to seem useful.
    final moments = [
      ..._rated('Body scan', 8, endDaysAgo: 50),
      ..._rated('Drink water', 3, endDaysAgo: 55),
      ..._rated('Drink water', 3, endDaysAgo: 3, mood: MomentMood.tookEffort),
    ];
    final lift = _read(moments)!;

    expect(lift.mature, isTrue);
    expect(lift.worst, isNull);
  });

  test('only ranks what is still on the list', () {
    // A swapped-out action's history stays in storage; ranking it would
    // propose decisions about something the user already decided on.
    final moments = [
      ..._rated('Body scan', 8, endDaysAgo: 50),
      ..._rated('Old habit', 9, endDaysAgo: 50, mood: MomentMood.tookEffort),
    ];
    final lift = _read(moments, active: ['Body scan', 'Stretch'])!;

    expect(
      lift.readings.every((r) => r.habitName != 'Old habit'),
      isTrue,
    );
  });
}
