import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/season.dart';

Moment _m(String iso, {String category = 'Health'}) =>
    Moment.create(habitName: 'x', category: category, at: DateTime.parse(iso));

/// [count] moments spread one per day from [startDay], at [hour].
List<Moment> _daily(int count, {int startDay = 1, int hour = 9, String category = 'Health'}) {
  return [
    for (var i = 0; i < count; i++)
      _m('2026-08-${(startDay + i).toString().padLeft(2, '0')}'
          'T${hour.toString().padLeft(2, '0')}:00:00', category: category),
  ];
}

void main() {
  test('a month below the threshold is still forming, not named', () {
    // Naming a month from nine moments would be inventing a pattern from
    // noise — and the word would then change, which §4.4 forbids.
    final season = Season.read('2026-08', _daily(9));
    expect(season.pole, Season.beginning);
    expect(season.sampleSize, 9);
    expect(season.readings, isEmpty);
  });

  test('the threshold is exactly ten', () {
    expect(Season.read('2026-08', _daily(10)).pole, isNot(Season.beginning));
  });

  test('mornings read as morning, evenings as evening', () {
    final morning = Season.read('2026-08', _daily(12, hour: 7));
    expect(
      morning.readings.firstWhere((r) => r.axis == SeasonAxis.rhythmOfDay).pole,
      Season.morning,
    );

    final evening = Season.read('2026-08', _daily(12, hour: 22));
    expect(
      evening.readings.firstWhere((r) => r.axis == SeasonAxis.rhythmOfDay).pole,
      Season.evening,
    );
  });

  test('one a day is steady; everything at once is bursts', () {
    final steady = Season.read('2026-08', _daily(12));
    expect(
      steady.readings.firstWhere((r) => r.axis == SeasonAxis.pacing).pole,
      Season.steady,
    );

    final bursts = Season.read('2026-08', [
      for (var i = 0; i < 10; i++) _m('2026-08-01T0${i % 9}:00:00'),
      _m('2026-08-05T09:00:00'),
      _m('2026-08-09T09:00:00'),
    ]);
    expect(
      bursts.readings.firstWhere((r) => r.axis == SeasonAxis.pacing).pole,
      Season.bursts,
    );
  });

  test('quiet stretches read as returning, an unbroken run as continuous', () {
    final continuous = Season.read('2026-08', _daily(12));
    expect(
      continuous.readings.firstWhere((r) => r.axis == SeasonAxis.returning).pole,
      Season.continuous,
    );

    final returning = Season.read('2026-08', [
      ..._daily(6),
      ..._daily(6, startDay: 15),
    ]);
    expect(
      returning.readings.firstWhere((r) => r.axis == SeasonAxis.returning).pole,
      Season.returning,
    );
  });

  test('one focus area reads as focused, a spread as wandering', () {
    final focused = Season.read('2026-08', _daily(12));
    expect(
      focused.readings.firstWhere((r) => r.axis == SeasonAxis.spread).pole,
      Season.focused,
    );

    final wandering = Season.read('2026-08', [
      ..._daily(4, category: 'Health'),
      ..._daily(4, startDay: 5, category: 'Mood'),
      ..._daily(4, startDay: 9, category: 'Self-care'),
    ]);
    expect(
      wandering.readings.firstWhere((r) => r.axis == SeasonAxis.spread).pole,
      Season.wandering,
    );
  });

  test('every axis is read, and the word comes from the strongest', () {
    final season = Season.read('2026-08', _daily(12));
    expect(season.readings.length, 4);
    final strongest =
        season.readings.reduce((a, b) => a.strength >= b.strength ? a : b);
    expect(season.pole, strongest.pole);
  });

  test('a season survives a round trip through storage', () {
    final season = Season.read('2026-08', _daily(12));
    final restored = Season.fromJson(season.toJson());
    expect(restored.pole, season.pole);
    expect(restored.monthKey, season.monthKey);
    expect(restored.sampleSize, season.sampleSize);
    expect(restored.readings.length, season.readings.length);
  });
}
