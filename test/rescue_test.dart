import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/rescue.dart';

final _today = DateTime(2026, 8, 20);

Moment _on(DateTime day) =>
    Moment.create(habitName: 'Body scan', category: 'Health', at: day);

Moment _daysAgo(int days) =>
    _on(_today.subtract(Duration(days: days)));

void main() {
  test('says nothing to someone who was here yesterday', () {
    expect(Rescue.read([_daysAgo(1)], now: _today), isNull);
  });

  test('a few days off is not a gap', () {
    // Lally: missing an opportunity did not materially affect habit
    // formation. Interrupting someone's screen over a long weekend would be
    // the streak logic this app removed, wearing a kinder face.
    expect(Rescue.read([_daysAgo(4)], now: _today), isNull);
  });

  test('the threshold is exactly five days', () {
    expect(Rescue.read([_daysAgo(5)], now: _today)!.quietDays, 5);
  });

  test('counts from the most recent moment, not the first', () {
    final moments = [_daysAgo(40), _daysAgo(30), _daysAgo(8)];
    expect(Rescue.read(moments, now: _today)!.quietDays, 8);
  });

  test('says nothing when there is no history at all', () {
    // A brand new account has not gone quiet — it has not started.
    expect(Rescue.read(const [], now: _today), isNull);
  });

  test('three weeks away stops counting out loud', () {
    // "Twenty-nine days" is a number someone can feel judged by.
    expect(Rescue.read([_daysAgo(20)], now: _today)!.isLongAbsence, isFalse);
    expect(Rescue.read([_daysAgo(21)], now: _today)!.isLongAbsence, isTrue);
  });

  test('reads the day on the clock the moment recorded', () {
    // Logged at 22:00 UTC from Moscow, where it was already the next day.
    // Deriving the day from UTC would report one more quiet day than there
    // was — and this number is on screen, in a sentence about the user.
    final moment = Moment(
      id: 'a',
      habitName: 'Body scan',
      habitEmoji: '✦',
      completedAt: DateTime.utc(2026, 8, 13, 22),
      category: 'Health',
      localHour: 1,
      localWeekday: 5,
      tzOffsetMinutes: 180,
    );
    expect(Rescue.read([moment], now: _today)!.quietDays, 6);
  });
}
