import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/letter.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/week_recap.dart';

/// A moment at [hour] on [day] of [month] 2026, by its own clock.
Moment _at(
  int month,
  int day, {
  int hour = 9,
  String habit = 'Body scan',
  MomentMood? mood,
}) =>
    Moment.create(
      habitName: habit,
      category: 'Health',
      mood: mood,
      at: DateTime(2026, month, day, hour),
      id: 'wr-$month-$day-$hour-$habit',
    );

/// Monday 28 September 2026 — its week ends on Sunday 4 October, so it
/// straddles a month boundary.
final _monday = DateTime.utc(2026, 9, 28);

void main() {
  group('which week the card reads', () {
    test('on a Sunday, the week ending that day', () {
      expect(WeekRecap.weekStartFor(DateTime(2026, 10, 4, 21)), _monday);
    });

    test('Monday to Saturday, the week that ended last Sunday', () {
      // A tap that lands late still finds the week it was promised.
      expect(WeekRecap.weekStartFor(DateTime(2026, 10, 5, 8)), _monday);
      expect(WeekRecap.weekStartFor(DateTime(2026, 10, 10, 23)), _monday);
    });

    test('the next Sunday replaces it', () {
      expect(
        WeekRecap.weekStartFor(DateTime(2026, 10, 11)),
        DateTime.utc(2026, 10, 5),
      );
    });

    test('across a year boundary', () {
      expect(
        WeekRecap.weekStartFor(DateTime(2027, 1, 3)),
        DateTime.utc(2026, 12, 28),
      );
    });
  });

  group('the week', () {
    test('counts a week that starts in the month before', () {
      final recap = WeekRecap.readWeek([
        _at(9, 27), // the Sunday before — not this week
        _at(9, 29),
        _at(9, 30),
        _at(10, 2),
        _at(10, 5), // the Monday after — not this week
      ], _monday)!;
      expect(recap.momentCount, 3);
      expect(recap.weekStart, _monday);
      expect(recap.weekEnd, DateTime.utc(2026, 10, 4));
    });

    test('a two-moment week gets silence, not a verdict', () {
      expect(WeekRecap.readWeek([_at(9, 29), _at(10, 1)], _monday), isNull);
    });

    test("the moment's own clock decides its week, not UTC", () {
      // 03:30 UTC on Monday 5 October, recorded seven hours west: 20:30 on
      // Sunday the 4th where it happened. It belongs to the week ending that
      // Sunday, and to its evening.
      final westward = Moment(
        id: 'west',
        habitName: 'Stretch',
        habitEmoji: '✦',
        completedAt: DateTime.utc(2026, 10, 5, 3, 30),
        localHour: 20,
        localWeekday: DateTime.sunday,
        tzOffsetMinutes: -7 * 60,
      );
      final week = [_at(9, 29, hour: 19), _at(9, 30, hour: 20), westward];
      final recap = WeekRecap.readWeek(week, _monday)!;
      expect(recap.momentCount, 3);
      expect(recap.dominantPart, DayPart.evenings);
      expect(
        WeekRecap.readWeek(week, DateTime.utc(2026, 10, 5)),
        isNull,
      );
    });

    test('read() follows the day it is asked on', () {
      final week = [_at(9, 28), _at(9, 30), _at(10, 3)];
      expect(
        WeekRecap.read(week, now: DateTime(2026, 10, 7))!.momentCount,
        3,
      );
      // The following Sunday reads the following week, which is empty.
      expect(WeekRecap.read(week, now: DateTime(2026, 10, 11)), isNull);
    });
  });

  group('"Most of them in the evening"', () {
    test('names a part that holds more than half the week', () {
      final recap = WeekRecap.readWeek([
        _at(9, 28, hour: 20),
        _at(9, 29, hour: 21),
        _at(9, 30, hour: 19),
        _at(10, 1, hour: 8),
      ], _monday)!;
      expect(recap.dominantPart, DayPart.evenings);
    });

    test('says nothing at exactly half — that is a tie, not most', () {
      final recap = WeekRecap.readWeek([
        _at(9, 28, hour: 20),
        _at(9, 29, hour: 21),
        _at(9, 30, hour: 8),
        _at(10, 1, hour: 9),
      ], _monday)!;
      expect(recap.dominantPart, isNull);
    });
  });

  group('the one you were glad about most', () {
    test('needs two glads and a clear winner', () {
      final recap = WeekRecap.readWeek([
        _at(9, 28, habit: 'Walk', mood: MomentMood.gladIDid),
        _at(9, 29, habit: 'Walk', mood: MomentMood.gladIDid),
        _at(9, 30, habit: 'Water', mood: MomentMood.gladIDid),
      ], _monday)!;
      expect(recap.gladdestHabit, 'Walk');
    });

    test('one tap is not "most"', () {
      final recap = WeekRecap.readWeek([
        _at(9, 28, habit: 'Walk', mood: MomentMood.gladIDid),
        _at(9, 29, habit: 'Walk'),
        _at(9, 30, habit: 'Water'),
      ], _monday)!;
      expect(recap.gladdestHabit, isNull);
    });

    test('a tie names nobody', () {
      final recap = WeekRecap.readWeek([
        _at(9, 28, habit: 'Walk', mood: MomentMood.gladIDid),
        _at(9, 29, habit: 'Walk', mood: MomentMood.gladIDid),
        _at(9, 30, habit: 'Water', mood: MomentMood.gladIDid),
        _at(10, 1, habit: 'Water', mood: MomentMood.gladIDid),
      ], _monday)!;
      expect(recap.gladdestHabit, isNull);
    });
  });
}
