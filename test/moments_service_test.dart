import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/services/moments_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Moment _at(DateTime when, {String habit = 'Body scan', String? source}) =>
    Moment.create(
      habitName: habit,
      category: 'Health',
      at: when,
      source: source,
      id: '${when.toIso8601String()}-$habit',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('a retro-log lands in order, not at the head', () async {
    // The cap trim drops the tail assuming newest-first; before the sort in
    // record(), a yesterday-log sat at index 0 and a *recent* moment sat on
    // the droppable tail (review finding, fixed).
    final today = DateTime(2026, 8, 13, 9);
    await MomentsService.record(_at(today.subtract(const Duration(days: 2))));
    await MomentsService.record(_at(today));
    await MomentsService.record(
        _at(today.subtract(const Duration(days: 1)), habit: 'Drink water'));

    final all = await MomentsService.getAll();
    expect(
      [for (final m in all) m.completedAt.day],
      [13, 12, 11],
      reason: 'newest first regardless of insertion order',
    );
  });

  test('the month window reads the wall clock, not a shifted anchor', () async {
    // 22:00 UTC on Aug 31 in Moscow (+3) is already September 1 on the wall.
    final m = Moment(
      id: 'wall',
      habitName: 'Body scan',
      habitEmoji: '✦',
      completedAt: DateTime.utc(2026, 8, 31, 22),
      category: 'Health',
      localHour: 1,
      localWeekday: 2,
      tzOffsetMinutes: 180,
    );
    await MomentsService.record(m);

    final august = await MomentsService.momentsForMonth(DateTime(2026, 8, 15));
    final september =
        await MomentsService.momentsForMonth(DateTime(2026, 9, 15));

    expect(august, isEmpty);
    expect(september.length, 1);
  });

  test('source survives the round trip', () async {
    await MomentsService.record(
        _at(DateTime(2026, 8, 13, 12), source: 'widget'));
    final all = await MomentsService.getAll();
    expect(all.single.source, 'widget');
  });
}
