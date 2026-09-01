import 'package:flutter_test/flutter_test.dart';
import 'package:intended/services/notification_scheduler.dart';

void main() {
  group('NotificationScheduler.previousMonthStart', () {
    test('the letter that fires on the 1st opens on the month it is about', () {
      expect(NotificationScheduler.previousMonthStart(DateTime(2026, 9, 1, 10)),
          DateTime(2026, 8, 1));
    });

    test('mid-month still points at the closed month, never the open one', () {
      expect(NotificationScheduler.previousMonthStart(DateTime(2026, 9, 17)),
          DateTime(2026, 8, 1));
    });

    test('January reaches back into December of the previous year', () {
      expect(NotificationScheduler.previousMonthStart(DateTime(2027, 1, 1, 10)),
          DateTime(2026, 12, 1));
    });
  });
}
