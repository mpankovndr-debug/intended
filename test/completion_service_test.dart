import 'package:flutter_test/flutter_test.dart';
import 'package:intended/main.dart' show HabitTracker;
import 'package:intended/services/completion_service.dart';
import 'package:intended/services/moments_service.dart';
import 'package:intended/services/reflection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One way to record a completed action, used by Today, the yesterday-log,
/// the reduced home screen and onboarding's first moment. Every door has to
/// write both stores.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const action = 'Take 3 slow breaths';

  test('a live completion writes both stores', () async {
    final moment = await CompletionService.record(action);

    expect(await HabitTracker.wasDone(action, DateTime.now()), isTrue);
    final all = await MomentsService.getAll();
    expect(all.map((m) => m.id), [moment.id]);
    expect(moment.habitName, action);
    expect(moment.category, ReflectionService.categoryForHabit(action));
  });

  test('the yesterday-log books both stores on that day', () async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1, 12);
    final moment = await CompletionService.record(action, on: yesterday);

    expect(await HabitTracker.wasDone(action, yesterday), isTrue);
    expect(await HabitTracker.wasDone(action, now), isFalse);
    expect(moment.localDay,
        DateTime.utc(yesterday.year, yesterday.month, yesterday.day));
  });
}
