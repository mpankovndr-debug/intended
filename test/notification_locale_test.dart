import 'package:flutter_test/flutter_test.dart';
import 'package:intended/services/notification_scheduler.dart';

/// A queued notification carries its own text, so a queue built in one
/// language keeps speaking it after the app switches. These are the cases
/// that decide whether it has to be rebuilt.
void main() {
  group('needsLocaleRebuild', () {
    test('ru queue, app now in en, reminders on — rebuild', () {
      expect(
        NotificationScheduler.needsLocaleRebuild(
          scheduled: 'ru',
          current: 'en',
          remindersEnabled: true,
        ),
        isTrue,
      );
    });

    test('the reverse too — en queue, app now in ru', () {
      expect(
        NotificationScheduler.needsLocaleRebuild(
          scheduled: 'en',
          current: 'ru',
          remindersEnabled: true,
        ),
        isTrue,
      );
    });

    test('same language is not a change', () {
      expect(
        NotificationScheduler.needsLocaleRebuild(
          scheduled: 'en',
          current: 'en',
          remindersEnabled: true,
        ),
        isFalse,
      );
    });

    test('reminders off — nothing is queued to be wrong', () {
      expect(
        NotificationScheduler.needsLocaleRebuild(
          scheduled: 'ru',
          current: 'en',
          remindersEnabled: false,
        ),
        isFalse,
      );
    });

    test('no stamp — a first run rebuilds nothing', () {
      // Rebuilding here would reshuffle which message comes next on every
      // launch of an install that predates the stamp, for no gain.
      expect(
        NotificationScheduler.needsLocaleRebuild(
          scheduled: null,
          current: 'en',
          remindersEnabled: true,
        ),
        isFalse,
      );
    });
  });
}
