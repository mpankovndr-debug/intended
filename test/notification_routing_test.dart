import 'package:flutter_test/flutter_test.dart';
import 'package:intended/services/notification_scheduler.dart';

/// Where a tap lands, and when the weekly and the letter go out. The plugin
/// calls around these can't run in a test; the rules can.
void main() {
  final now = DateTime(2026, 10, 6, 9);

  group('progressMonthFor', () {
    test('the weekly opens the month being lived — the week card is there',
        () {
      expect(
        NotificationScheduler.progressMonthFor(
          id: 100,
          payload: null,
          now: now,
        ),
        DateTime(2026, 10),
      );
    });

    test('the letter opens the month it is about, not the new one', () {
      expect(
        NotificationScheduler.progressMonthFor(
          id: 101,
          payload: '2026-09',
          now: DateTime(2026, 10, 1, 10),
        ),
        DateTime(2026, 9),
      );
    });

    test('a letter queued before payloads existed falls back a month', () {
      expect(
        NotificationScheduler.progressMonthFor(
          id: 101,
          payload: null,
          now: DateTime(2026, 10, 1, 10),
        ),
        DateTime(2026, 9),
      );
      // Across the year boundary.
      expect(
        NotificationScheduler.progressMonthFor(
          id: 101,
          payload: null,
          now: DateTime(2027, 1, 1, 10),
        ),
        DateTime(2026, 12),
      );
    });

    test('a garbled payload falls back too', () {
      for (final payload in ['2026-13', 'September', '']) {
        expect(
          NotificationScheduler.progressMonthFor(
            id: 101,
            payload: payload,
            now: DateTime(2026, 10, 1, 10),
          ),
          DateTime(2026, 9),
          reason: payload,
        );
      }
    });

    test('a daily reminder just opens the app', () {
      for (final id in [0, 3, 6, null]) {
        expect(
          NotificationScheduler.progressMonthFor(
            id: id,
            payload: null,
            now: now,
          ),
          isNull,
          reason: '$id',
        );
      }
    });
  });

  group('weeklyFireDay', () {
    test('a Sunday before nine is tonight', () {
      expect(
        NotificationScheduler.weeklyFireDay(DateTime(2026, 10, 4, 20, 59)),
        DateTime(2026, 10, 4),
      );
    });

    test('a Sunday from nine on is next Sunday', () {
      expect(
        NotificationScheduler.weeklyFireDay(DateTime(2026, 10, 4, 21)),
        DateTime(2026, 10, 11),
      );
    });

    test('any other day is the coming Sunday, across a month end', () {
      expect(
        NotificationScheduler.weeklyFireDay(now),
        DateTime(2026, 10, 11),
      );
      expect(
        NotificationScheduler.weeklyFireDay(DateTime(2026, 10, 31, 23)),
        DateTime(2026, 11, 1),
      );
    });
  });

  group('letterFireDay', () {
    test('the 1st before ten is this morning — last month\'s letter', () {
      // An open that morning re-arms the closing month's letter instead of
      // dropping it for the new, empty one.
      expect(
        NotificationScheduler.letterFireDay(DateTime(2026, 10, 1, 9, 59)),
        DateTime(2026, 10, 1),
      );
    });

    test('from ten on the 1st, and every other day, it is next month\'s', () {
      expect(
        NotificationScheduler.letterFireDay(DateTime(2026, 10, 1, 10)),
        DateTime(2026, 11, 1),
      );
      expect(
        NotificationScheduler.letterFireDay(now),
        DateTime(2026, 11, 1),
      );
      expect(
        NotificationScheduler.letterFireDay(DateTime(2026, 12, 20)),
        DateTime(2027, 1, 1),
      );
    });
  });
}
