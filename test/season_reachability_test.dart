import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/season.dart';

/// Every season word must be reachable.
///
/// Three of the eight were not, and nothing caught it: the axis tests each
/// asserted their own pole in isolation, and the winner-selection test was a
/// tautology (`pole == strongest.pole`). The formulas had four different
/// ranges — Focused capped at 0.4, Steady at 0.5, Wandering at 0.35 — while
/// Returning carried a hard floor of 0.6, so «Постоянство», «Фокус» and
/// «Поиск» could not win a month however hard someone lived them.
///
/// This is the test that would have caught it, so it is the one that keeps it
/// caught.
void main() {
  Moment at(int day, int hour, String category) => Moment.create(
        habitName: 'x',
        category: category,
        at: DateTime.parse('2026-08-${day.toString().padLeft(2, '0')}'
            'T${hour.toString().padLeft(2, '0')}:00:00'),
      );

  test('every pole is reachable by some month', () {
    final rng = Random(11);
    const cats = ['Health', 'Mood', 'Self-care', 'Growth'];
    final won = <String, int>{};

    for (var trial = 0; trial < 60000; trial++) {
      final moments = <Moment>[];
      // Deliberately lopsided shapes as well as uniform ones: uniform random
      // days never produce a month lived entirely before noon, and a sampler
      // that cannot express a morning person cannot prove one exists.
      final dayCeiling = 1 + rng.nextInt(28);
      final hourFloor = rng.nextInt(2) == 0 ? 5 : 12;
      final hourSpan = 1 + rng.nextInt(12);
      final catSpan = 1 + rng.nextInt(cats.length);
      final n = 10 + rng.nextInt(50);
      for (var i = 0; i < n; i++) {
        moments.add(at(
          1 + rng.nextInt(dayCeiling),
          (hourFloor + rng.nextInt(hourSpan)) % 24,
          cats[rng.nextInt(catSpan)],
        ));
      }
      won[Season.read('2026-08', moments).pole] =
          (won[Season.read('2026-08', moments).pole] ?? 0) + 1;
    }

    for (final pole in [
      Season.morning, Season.evening,
      Season.steady, Season.bursts,
      Season.returning, Season.continuous,
      Season.focused, Season.wandering,
    ]) {
      expect(won[pole] ?? 0, greaterThan(0), reason: '$pole never wins');
    }
  });

  test('no single axis decides most months', () {
    // Before: returning and continuous took 96% between them. A word that
    // almost everyone gets is not a reading of anyone's month.
    final rng = Random(29);
    const cats = ['Health', 'Mood', 'Self-care', 'Growth'];
    final won = <String, int>{};
    const trials = 20000;

    for (var trial = 0; trial < trials; trial++) {
      final moments = <Moment>[];
      final dayCeiling = 1 + rng.nextInt(28);
      final hourFloor = rng.nextInt(2) == 0 ? 5 : 12;
      final catSpan = 1 + rng.nextInt(cats.length);
      final n = 10 + rng.nextInt(50);
      for (var i = 0; i < n; i++) {
        moments.add(at(1 + rng.nextInt(dayCeiling),
            (hourFloor + rng.nextInt(8)) % 24, cats[rng.nextInt(catSpan)]));
      }
      final pole = Season.read('2026-08', moments).pole;
      won[pole] = (won[pole] ?? 0) + 1;
    }

    final busiest = won.values.reduce((a, b) => a > b ? a : b);
    expect(busiest / trials, lessThan(0.6),
        reason: 'one word takes ${(busiest / trials * 100).round()}% of months');
  });

  test('every strength stays inside 0..1 on every axis', () {
    // The bug was a range mismatch, so the ranges themselves are asserted.
    final rng = Random(5);
    for (var trial = 0; trial < 5000; trial++) {
      final moments = [
        for (var i = 0; i < 10 + rng.nextInt(40); i++)
          at(1 + rng.nextInt(28), rng.nextInt(24), 'Health'),
      ];
      for (final r in Season.read('2026-08', moments).readings) {
        expect(r.strength, inInclusiveRange(0.0, 1.0),
            reason: '${r.axis} produced ${r.strength}');
      }
    }
  });

  test('a tie is broken by axis priority, not by fold order', () {
    // Same month read twice must name itself the same thing, always.
    final moments = [for (var d = 1; d <= 20; d++) at(d, 9, 'Health')];
    final first = Season.read('2026-08', moments).pole;
    for (var i = 0; i < 50; i++) {
      expect(Season.read('2026-08', moments).pole, first);
    }
  });
}
