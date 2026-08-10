import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/first_week.dart';
import 'package:intended/models/letter.dart';
import 'package:intended/models/moment.dart';

Moment _on(int day, {int hour = 9, String habit = 'Body scan', MomentMood? mood}) =>
    Moment.create(
      habitName: habit,
      category: 'Health',
      mood: mood,
      at: DateTime(2026, 8, day, hour),
      id: 'fw-$day-$hour-$habit',
    );

/// A healthy first week: five moments across four days.
final _week = [
  _on(1, mood: MomentMood.gladIDid),
  _on(2, hour: 21, mood: MomentMood.gladIDid),
  _on(3, hour: 21, habit: 'Drink water'),
  _on(5, hour: 21, mood: MomentMood.tookEffort),
  _on(6, hour: 20, habit: 'Drink water', mood: MomentMood.gladIDid),
];

DateTime _day(int d) => DateTime(2026, 8, d);

void main() {
  test('appears when the first week completes, not before', () {
    expect(FirstWeek.read(_week, now: _day(6)), isNull);
    expect(FirstWeek.read(_week, now: _day(8)), isNotNull);
  });

  test('leaves on its own a week later', () {
    // An event, not a fixture — nothing dismisses it, it expires.
    expect(FirstWeek.read(_week, now: _day(14)), isNotNull);
    expect(FirstWeek.read(_week, now: _day(15)), isNull);
  });

  test('counts only the first seven days', () {
    final withLater = [..._week, _on(9), _on(10)];
    expect(FirstWeek.read(withLater, now: _day(10))!.momentCount, 5);
  });

  test('a two-moment week gets silence, not a verdict', () {
    // "Your first week: 2 moments" reads as a judgement. Say nothing.
    final thin = [_on(1), _on(3)];
    expect(FirstWeek.read(thin, now: _day(8)), isNull);
  });

  test('names where the week clustered, when it did', () {
    // Four of five in the evening.
    expect(
      FirstWeek.read(_week, now: _day(8))!.dominantPart,
      DayPart.evenings,
    );
  });

  test('a scattered week has no cluster to name', () {
    final scattered = [
      _on(1, hour: 7),
      _on(2, hour: 13),
      _on(3, hour: 21),
      _on(4, hour: 23),
    ];
    expect(FirstWeek.read(scattered, now: _day(8))!.dominantPart, isNull);
  });

  test('the gladdest action needs two glads and a clear winner', () {
    expect(
      FirstWeek.read(_week, now: _day(8))!.gladdestHabit,
      'Body scan',
    );

    // One glad each: no winner, no claim.
    final tied = [
      _on(1, mood: MomentMood.gladIDid),
      _on(2, habit: 'Drink water', mood: MomentMood.gladIDid),
      _on(3),
    ];
    expect(FirstWeek.read(tied, now: _day(8))!.gladdestHabit, isNull);
  });

  test('anchors to the first moment, wherever it falls', () {
    // A first week that started mid-month still gets its keepsake on time.
    final late = [for (var d = 20; d < 25; d++) _on(d)];
    expect(FirstWeek.read(late, now: _day(27)), isNotNull);
    expect(FirstWeek.read(late, now: _day(26)), isNull);
  });
}
