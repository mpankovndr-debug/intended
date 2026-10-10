import 'package:flutter_test/flutter_test.dart';
import 'package:intended/services/backup_service.dart';

/// Backups inside the 30s window are deferred to its end, not dropped: a
/// dropped one left the cloud copy without the window's last changes, and a
/// restore before the next backup never brought them back.
void main() {
  final now = DateTime.utc(2026, 10, 10, 12);
  Duration? wait(Duration? since,
          {bool busy = false, bool immediately = false}) =>
      BackupService.deferBy(
        lastRequest: since == null ? null : now.subtract(since),
        now: now,
        busy: busy,
        immediately: immediately,
      );

  test('the first backup runs at once', () {
    expect(wait(null), isNull);
  });

  test('one asked for inside the window waits for the rest of it', () {
    expect(wait(const Duration(seconds: 4)), const Duration(seconds: 26));
    expect(wait(const Duration(seconds: 4), busy: true),
        const Duration(seconds: 26));
  });

  test('once the window has passed it runs at once, unless one is in flight',
      () {
    expect(wait(const Duration(seconds: 30)), isNull);
    expect(wait(const Duration(seconds: 30), busy: true),
        const Duration(seconds: 30));
  });

  test('immediately skips the window, but never a backup in flight', () {
    expect(wait(const Duration(seconds: 4), immediately: true), isNull);
    expect(wait(const Duration(seconds: 4), busy: true, immediately: true),
        const Duration(seconds: 26));
    expect(wait(null, busy: true, immediately: true),
        const Duration(seconds: 30));
  });

  test('a clock set back counts as no recent request', () {
    expect(wait(const Duration(hours: -2)), isNull);
  });
}
