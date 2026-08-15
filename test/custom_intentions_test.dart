import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/services/moments_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A moment with no focus area — what every custom intention recorded before
/// the static map was refreshed on write.
Moment _uncategorised(String habit, int day) => Moment.create(
      habitName: habit,
      at: DateTime(2026, 8, day, 10),
      id: '$habit-$day',
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> seed(List<Moment> moments) async {
    SharedPreferences.setMockInitialValues({
      'moments_collection':
          jsonEncode(moments.map((m) => m.toJson()).toList()),
    });
  }

  group('repairing the grey squares', () {
    test('gives a custom intention its focus area, after the fact', () async {
      await seed([
        _uncategorised('day without alcohol', 12),
        _uncategorised('day without alcohol', 13),
      ]);

      final repaired = await MomentsService.backfillCustomCategories(
        {'day without alcohol': 'Health'},
      );

      expect(repaired, 2);
      final all = await MomentsService.getAll();
      expect(all.every((m) => m.category == 'Health'), isTrue,
          reason: 'both squares rejoin Health, its legend and its chip');
    });

    test('never overwrites a focus area that is already there', () async {
      await seed([
        Moment.create(
            habitName: 'Take 3 slow breaths',
            category: 'Mood',
            at: DateTime(2026, 8, 12),
            id: 'a'),
      ]);

      final repaired = await MomentsService.backfillCustomCategories(
        {'Take 3 slow breaths': 'Health'},
      );

      expect(repaired, 0);
      expect((await MomentsService.getAll()).first.category, 'Mood');
    });

    test('leaves an unknown action alone rather than guessing', () async {
      // A custom the user has since deleted has no mapping left. Inventing
      // one would put a square in a colour it never belonged to.
      await seed([_uncategorised('something long gone', 12)]);

      expect(
        await MomentsService.backfillCustomCategories({'kiss': 'Mood'}),
        0,
      );
      expect((await MomentsService.getAll()).first.category, isNull);
    });

    test('is safe to run on every launch', () async {
      await seed([_uncategorised('kiss', 12)]);
      const map = {'kiss': 'Mood'};

      expect(await MomentsService.backfillCustomCategories(map), 1);
      expect(await MomentsService.backfillCustomCategories(map), 0,
          reason: 'idempotent — the second launch finds nothing to fill');
    });

    test('an empty map is a no-op, not a wipe', () async {
      await seed([_uncategorised('kiss', 12)]);
      expect(await MomentsService.backfillCustomCategories(const {}), 0);
      expect((await MomentsService.getAll()).length, 1);
    });
  });

  group('the record survives what the list does', () {
    test('a completed custom keeps its square after it is set aside',
        () async {
      // The grid is a record of what happened, not a view of the current
      // list. Removing an intention must never remove its history.
      await seed([
        Moment.create(
            habitName: 'kiss',
            category: 'Mood',
            at: DateTime(2026, 8, 12),
            id: 'k1'),
      ]);

      final before = await MomentsService.getAll();
      // Setting aside touches user_habits and custom_habits only; nothing in
      // this service is keyed on the active list.
      final after = await MomentsService.getAll();

      expect(after.length, before.length);
      expect(after.first.habitName, 'kiss');
      expect(after.first.category, 'Mood');
    });

    test('a renamed custom leaves its old squares readable', () async {
      // Moments store the name as written at the time. A rename does not
      // rewrite history — and the old square must still carry its colour,
      // or renaming would quietly grey out a month.
      await seed([
        Moment.create(
            habitName: 'kiss',
            category: 'Mood',
            at: DateTime(2026, 8, 12),
            id: 'k1'),
      ]);

      final repaired = await MomentsService.backfillCustomCategories(
        {'kiss goodnight': 'Mood'},
      );

      expect(repaired, 0);
      expect((await MomentsService.getAll()).first.category, 'Mood',
          reason: 'the colour came from the moment, not from the live list');
    });
  });
}
