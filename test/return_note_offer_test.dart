import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/rescue.dart';
import 'package:intended/models/return_note_offer.dart';

void main() {
  // UTC moments with a zero offset, so wall day == calendar day and the
  // fixtures read as what they mean.
  Moment moment(DateTime day) => Moment(
        id: 'm-${day.toIso8601String()}',
        habitName: 'Take 3 slow breaths',
        habitEmoji: '🌿',
        completedAt: DateTime.utc(day.year, day.month, day.day, 9),
        localHour: 9,
        localWeekday: day.weekday,
        tzOffsetMinutes: 0,
      );

  final today = DateTime.utc(2026, 8, 26, 14);

  group('isReturnDay', () {
    test('true when today follows a quiet stretch of exactly the threshold',
        () {
      final gap = Rescue.minQuietDays;
      final moments = [
        moment(DateTime.utc(2026, 8, 26)),
        moment(DateTime.utc(2026, 8, 26 - gap)),
      ];
      expect(ReturnNoteOffer.isReturnDay(moments, now: today), isTrue);
    });

    test('false when the gap is one day short', () {
      final gap = Rescue.minQuietDays - 1;
      final moments = [
        moment(DateTime.utc(2026, 8, 26)),
        moment(DateTime.utc(2026, 8, 26 - gap)),
      ];
      expect(ReturnNoteOffer.isReturnDay(moments, now: today), isFalse);
    });

    test('false when the latest moment is not today', () {
      final moments = [
        moment(DateTime.utc(2026, 8, 25)),
        moment(DateTime.utc(2026, 8, 15)),
      ];
      expect(ReturnNoteOffer.isReturnDay(moments, now: today), isFalse);
    });

    test('false for a first-ever moment — a beginning, not a return', () {
      final moments = [moment(DateTime.utc(2026, 8, 26))];
      expect(ReturnNoteOffer.isReturnDay(moments, now: today), isFalse);
      expect(ReturnNoteOffer.isReturnDay(const [], now: today), isFalse);
    });

    test('multiple moments today still measure the gap to the day before', () {
      final moments = [
        moment(DateTime.utc(2026, 8, 26)),
        moment(DateTime.utc(2026, 8, 26)),
        moment(DateTime.utc(2026, 8, 18)),
      ];
      expect(ReturnNoteOffer.isReturnDay(moments, now: today), isTrue);
    });

    test('a moment yesterday breaks the stretch regardless of older gaps', () {
      final moments = [
        moment(DateTime.utc(2026, 8, 26)),
        moment(DateTime.utc(2026, 8, 25)),
        moment(DateTime.utc(2026, 8, 1)),
      ];
      expect(ReturnNoteOffer.isReturnDay(moments, now: today), isFalse);
    });
  });

  group('shouldOffer', () {
    bool offer({
      bool returnedToday = true,
      bool permissionGranted = false,
      bool answered = false,
      int priorOffers = 0,
    }) =>
        ReturnNoteOffer.shouldOffer(
          returnedToday: returnedToday,
          permissionGranted: permissionGranted,
          answered: answered,
          priorOffers: priorOffers,
        );

    test('offers on a return day to an unreachable, unasked user', () {
      expect(offer(), isTrue);
    });

    test('stays silent on ordinary days', () {
      expect(offer(returnedToday: false), isFalse);
    });

    test('never speaks to someone the app can already reach', () {
      // This is also what protects the user who granted permission and then
      // turned the Profile toggle off: their permission is still granted.
      expect(offer(permissionGranted: true), isFalse);
    });

    test('an answer is final, either way', () {
      expect(offer(answered: true), isFalse);
    });

    test('retires after the third unanswered appearance', () {
      expect(offer(priorOffers: ReturnNoteOffer.maxOffers - 1), isTrue);
      expect(offer(priorOffers: ReturnNoteOffer.maxOffers), isFalse);
    });
  });
}
