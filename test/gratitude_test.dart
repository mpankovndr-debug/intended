import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/gratitude_cadence.dart';
import 'package:intended/models/gratitude_entry.dart';
import 'package:intended/models/gratitude_month.dart';

void main() {
  GratitudeEntry entry(
    DateTime utc, {
    List<String> self = const ['a'],
    List<String> others = const [],
    int offset = 0,
  }) =>
      GratitudeEntry(
        id: utc.toIso8601String(),
        completedAt: utc,
        forSelf: self,
        forOthers: others,
        localHour: utc.add(Duration(minutes: offset)).hour,
        localWeekday: utc.add(Duration(minutes: offset)).weekday,
        tzOffsetMinutes: offset,
      );

  group('GratitudeEntry', () {
    test('drops blank lines rather than keeping them as empties', () {
      final e = GratitudeEntry.create(
        forSelf: ['  walked  ', '', '   ', 'soup'],
        forOthers: const [],
      );
      expect(e.forSelf, ['walked', 'soup']);
    });

    test('caps each side at the add path, not by silent truncation later', () {
      final many = [for (int i = 0; i < 25; i++) 'line $i'];
      final e = GratitudeEntry.create(forSelf: many, forOthers: many);
      expect(e.forSelf.length, GratitudeEntry.maxLinesPerSide);
      expect(e.forOthers.length, GratitudeEntry.maxLinesPerSide);
      // The kept lines are the *first* ones written, never a random window.
      expect(e.forSelf.first, 'line 0');
    });

    test('clamps an over-long line', () {
      final e = GratitudeEntry.create(
        forSelf: ['x' * (GratitudeEntry.maxLineLength + 50)],
        forOthers: const [],
      );
      expect(e.forSelf.single.length, GratitudeEntry.maxLineLength);
    });

    test('isEmpty is true only when both sides are empty', () {
      expect(GratitudeEntry.create(forSelf: const [], forOthers: const [])
          .isEmpty, isTrue);
      expect(GratitudeEntry.create(forSelf: const ['a'], forOthers: const [])
          .isEmpty, isFalse);
    });

    test('reads the wall clock from its own offset, never the device zone',
        () {
      // 01:30 UTC at UTC-5 is the previous evening, 20:30, for the writer.
      final e = entry(DateTime.utc(2026, 6, 3, 1, 30), offset: -300);
      expect(e.localWallClock.hour, 20);
      expect(e.localDay, DateTime.utc(2026, 6, 2));
    });

    test('copyWith keeps the original instant and its wall clock', () {
      final e = entry(DateTime.utc(2026, 6, 3, 1, 30), offset: -300);
      final later = e.copyWith(forSelf: ['a', 'b']);
      expect(later.completedAt, e.completedAt);
      expect(later.localDay, e.localDay);
      expect(later.forSelf, ['a', 'b']);
    });

    test('survives a json round trip, offset included', () {
      final e = entry(DateTime.utc(2026, 6, 3, 1, 30),
          self: ['one'], others: ['two'], offset: -300);
      final back = GratitudeEntry.fromJson(e.toJson());
      expect(back.forSelf, ['one']);
      expect(back.forOthers, ['two']);
      expect(back.tzOffsetMinutes, -300);
      expect(back.localDay, e.localDay);
    });

    test('a malformed lines field reads as empty rather than throwing', () {
      final back = GratitudeEntry.fromJson({
        'id': 'x',
        'completedAt': DateTime.utc(2026, 6, 3).toIso8601String(),
        'forSelf': 'not a list',
        'forOthers': [1, 'kept', null],
        'localHour': 21,
        'localWeekday': 3,
        'tzOffsetMinutes': 0,
      });
      expect(back.forSelf, isEmpty);
      expect(back.forOthers, ['kept']);
    });
  });

  group('GratitudeMonth', () {
    test('filters by the writer\'s own local day, not a shifted anchor', () {
      // Written 1 July 01:30 UTC at UTC-5 — a June evening for the writer.
      // The scar this guards: momentsForMonth once shifted the anchor and
      // every user west of UTC read the wrong month for a whole month.
      final june = entry(DateTime.utc(2026, 7, 1, 1, 30), offset: -300);
      final july = entry(DateTime.utc(2026, 7, 2, 18, 0), offset: -300);
      final inJune =
          GratitudeMonth.forMonth([june, july], DateTime(2026, 6, 1));
      expect(inJune, [june]);
    });

    test('orders oldest first, with a stable tiebreak', () {
      final a = entry(DateTime.utc(2026, 6, 2, 21));
      final b = entry(DateTime.utc(2026, 6, 5, 21));
      final c = entry(DateTime.utc(2026, 6, 9, 21));
      final ordered =
          GratitudeMonth.forMonth([c, a, b], DateTime(2026, 6, 1));
      expect(ordered.map((e) => e.completedAt).toList(),
          [a.completedAt, b.completedAt, c.completedAt]);
    });

    test('monthsWithPages skips months holding nothing, newest first', () {
      final all = [
        entry(DateTime.utc(2026, 6, 2, 21)),
        entry(DateTime.utc(2026, 6, 8, 21)),
        entry(DateTime.utc(2026, 8, 1, 21)),
      ];
      expect(GratitudeMonth.monthsWithPages(all),
          [DateTime.utc(2026, 8, 1), DateTime.utc(2026, 6, 1)]);
    });

    test('forDay returns null rather than an empty page', () {
      final all = [entry(DateTime.utc(2026, 6, 2, 21))];
      expect(GratitudeMonth.forDay(all, DateTime(2026, 6, 2)), isNotNull);
      expect(GratitudeMonth.forDay(all, DateTime(2026, 6, 3)), isNull);
    });
  });

  group('GratitudeSchedule', () {
    test('daily fires every weekday', () {
      for (int d = 1; d <= 7; d++) {
        final date = DateTime(2026, 6, 1).add(Duration(days: d - 1));
        expect(GratitudeSchedule.firesOn(GratitudeCadence.daily, date), isTrue);
      }
    });

    test('fewDays never puts two evenings back to back', () {
      final days = GratitudeSchedule.weekdaysFor[GratitudeCadence.fewDays]!;
      expect(days.length, 3);
      for (final d in days) {
        expect(days.contains(d + 1), isFalse,
            reason: 'weekday $d has an adjacent sibling');
      }
    });

    test('weekly fires on Sunday only', () {
      expect(
          GratitudeSchedule.firesOn(
              GratitudeCadence.weekly, DateTime(2026, 6, 7)), // Sunday
          isTrue);
      expect(
          GratitudeSchedule.firesOn(
              GratitudeCadence.weekly, DateTime(2026, 6, 8)),
          isFalse);
    });

    test('never returns a slot that has already passed today', () {
      // 22:00 on a Monday, reminder set for 21:30 — tonight is gone.
      final from = DateTime(2026, 6, 1, 22, 0);
      final times = GratitudeSchedule.nextFireTimes(GratitudeCadence.daily,
          from: from, hour: 21, minute: 30, count: 3);
      expect(times.first, DateTime(2026, 6, 2, 21, 30));
      expect(times.every((t) => t.isAfter(from)), isTrue);
    });

    test('keeps tonight when the time has not passed yet', () {
      final from = DateTime(2026, 6, 1, 19, 0);
      final times = GratitudeSchedule.nextFireTimes(GratitudeCadence.daily,
          from: from, hour: 21, minute: 30, count: 2);
      expect(times.first, DateTime(2026, 6, 1, 21, 30));
    });

    // What the one-a-day rule actually costs the habit nudge. Whatever
    // evenings the page owns, [scheduleDaily] stands down on — so these two
    // numbers ARE the notification budget, and a change here changes it.
    test('daily cadence leaves the habit nudge no evenings', () {
      final week = [
        for (int i = 0; i < 7; i++) DateTime(2026, 6, 1).add(Duration(days: i))
      ];
      final free = week
          .where((d) => !GratitudeSchedule.firesOn(GratitudeCadence.daily, d));
      expect(free, isEmpty);
    });

    test('weekly cadence leaves the habit nudge six of seven', () {
      final week = [
        for (int i = 0; i < 7; i++) DateTime(2026, 6, 1).add(Duration(days: i))
      ];
      final free = week
          .where((d) => !GratitudeSchedule.firesOn(GratitudeCadence.weekly, d));
      expect(free.length, 6);
    });

    test('fills every weekly slot asked for, one week apart', () {
      // The lookahead bound has to clear 14 weekly slots (98 days) — at the
      // original 60 it silently returned a short list.
      final times = GratitudeSchedule.nextFireTimes(GratitudeCadence.weekly,
          from: DateTime(2026, 6, 1, 8), hour: 21, minute: 30, count: 14);
      expect(times.length, 14);
      expect(times.every((t) => t.weekday == DateTime.sunday), isTrue);
      for (int i = 1; i < times.length; i++) {
        expect(times[i].difference(times[i - 1]).inDays, 7);
      }
    });
  });
}
