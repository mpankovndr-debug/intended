import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/drift.dart';
import 'package:intended/models/moment.dart';

final _now = DateTime(2026, 8, 12); // a Wednesday

Moment _on(DateTime day) =>
    Moment.create(habitName: 'x', category: 'Health', at: day);

/// [count] moments in the week starting [weeksAgo] weeks before this one.
List<Moment> _week(int weeksAgo, int count) {
  final weekStart = DateTime(_now.year, _now.month, _now.day)
      .subtract(Duration(days: _now.weekday - 1 + 7 * weeksAgo));
  return [for (var i = 0; i < count; i++) _on(weekStart.add(Duration(days: i % 7)))];
}

void main() {
  test('says nothing without enough history to know a baseline', () {
    // Two weeks in, "you usually collect 6" has no basis — the card would be
    // inventing a norm and then measuring the user against it.
    final moments = [..._week(1, 6), ..._week(0, 1)];
    expect(Drift.read(moments, now: _now), isNull);
  });

  test('says nothing when the week is running normally', () {
    final moments = [
      for (var w = 4; w >= 1; w--) ..._week(w, 6),
      ..._week(0, 6),
    ];
    expect(Drift.read(moments, now: _now), isNull);
  });

  test('reads a real dip against the user own baseline', () {
    final moments = [
      for (var w = 4; w >= 1; w--) ..._week(w, 6),
      ..._week(0, 2),
    ];
    final drift = Drift.read(moments, now: _now);
    expect(drift, isNotNull);
    expect(drift!.thisWeek, 2);
    expect(drift.usual, 6);
  });

  test('only claims a quiet stretch followed when it actually did', () {
    // Steady history, one dip now: no grounds to say "the last two times".
    final steady = [
      for (var w = 4; w >= 1; w--) ..._week(w, 6),
      ..._week(0, 1),
    ];
    expect(Drift.read(steady, now: _now)!.precededQuiet, isFalse);
  });

  test('a user who never collects much is not told they are drifting', () {
    // Baseline of zero means there is no norm to fall below.
    final moments = [
      for (var w = 4; w >= 1; w--) ..._week(w, 0),
      ..._week(0, 0),
    ];
    expect(Drift.read(moments, now: _now), isNull);
  });
}
