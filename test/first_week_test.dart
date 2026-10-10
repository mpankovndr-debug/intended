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

  test('half the week is not most of it', () {
    // The card says "Most of them in the evening." Two evenings out of four
    // isn't most — and with two mornings beside them, which part got named
    // came down to the order the moments were read in.
    final tied = [
      _on(1, hour: 8),
      _on(2, hour: 20),
      _on(3, hour: 8),
      _on(4, hour: 20),
    ];
    expect(FirstWeek.read(tied, now: _day(8))!.dominantPart, isNull);
    expect(
      FirstWeek.read(tied.reversed.toList(), now: _day(8))!.dominantPart,
      isNull,
    );

    // Half with nothing level beside it is still only half.
    final half = [
      _on(1, hour: 20),
      _on(2, hour: 20),
      _on(3, hour: 8),
      _on(4, hour: 14),
    ];
    expect(FirstWeek.read(half, now: _day(8))!.dominantPart, isNull);

    // One more evening, and it is most of them.
    expect(
      FirstWeek.read([...tied, _on(5, hour: 20)], now: _day(8))!.dominantPart,
      DayPart.evenings,
    );
  });

  test('the month card reads "most of them" through the same rule', () {
    // Twelve moments across a fortnight — nothing to do with the first
    // week's window. Six evenings is half of them; a seventh makes it most.
    final month = [
      for (var day = 1; day <= 6; day++) _on(day, hour: 20),
      for (var day = 7; day <= 12; day++) _on(day, hour: 8),
    ];
    expect(FirstWeek.majorityPart(month), isNull);
    expect(
      FirstWeek.majorityPart([...month, _on(13, hour: 20)]),
      DayPart.evenings,
    );
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
