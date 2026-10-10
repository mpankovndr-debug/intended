import 'package:flutter_test/flutter_test.dart';
import 'package:intended/services/notification_scheduler.dart';

/// The weekly repeats every Sunday with the text it was armed with, so a
/// new line only reaches people whose queued weekly is re-armed. These are
/// the cases that decide it.
void main() {
  group('needsWeeklyRearm', () {
    test('install from before the stamp, weekly queued — re-arm', () {
      expect(
        NotificationScheduler.needsWeeklyRearm(
          stamp: null,
          weeklyQueued: true,
        ),
        isTrue,
      );
    });

    test('nothing queued — never arms a weekly someone did not have', () {
      expect(
        NotificationScheduler.needsWeeklyRearm(
          stamp: null,
          weeklyQueued: false,
        ),
        isFalse,
      );
    });

    test('already on the current text — leave it', () {
      expect(
        NotificationScheduler.needsWeeklyRearm(
          stamp: NotificationScheduler.weeklyTextVersion,
          weeklyQueued: true,
        ),
        isFalse,
      );
    });

    test('an older stamp with a weekly queued — re-arm', () {
      expect(
        NotificationScheduler.needsWeeklyRearm(
          stamp: NotificationScheduler.weeklyTextVersion - 1,
          weeklyQueued: true,
        ),
        isTrue,
      );
    });
  });
}
