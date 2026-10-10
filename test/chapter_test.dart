import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/chapter.dart';

/// A chapter is three months under one sentence (spec §2.1). These pin the
/// dates, because every screen that says "until 31 December" reads them.
void main() {
  Chapter startOn(int year, int month, int day, {int offsetMinutes = 0}) =>
      Chapter.start(
        id: 'c',
        sentence: 'let the day go before I sleep',
        pathKey: 'windingDown',
        // Midday on the person's clock, so the offset cannot move the day.
        startedAt: DateTime.utc(year, month, day, 12)
            .subtract(Duration(minutes: offsetMinutes)),
        offsetMinutes: offsetMinutes,
      );

  DateTime day(int y, int m, int d) => DateTime.utc(y, m, d);

  group('the 14-day start rule', () {
    test('starting on the 1st: that month is month 1', () {
      final c = startOn(2026, 9, 1);
      expect(c.month1Key, '2026-09');
      expect(c.lastDay, day(2026, 11, 30));
      expect(c.lastDay.difference(c.startDay).inDays + 1, 91);
    });

    test('exactly 14 days left: the start month still counts', () {
      final c = startOn(2026, 9, 17);
      expect(c.month1Key, '2026-09');
      expect(c.lastDay, day(2026, 11, 30));
      expect(c.firstMonthDays, 14);
    });

    test('13 days left: they fold into the next month', () {
      final c = startOn(2026, 9, 18);
      expect(c.month1Key, '2026-10');
      expect(c.lastDay, day(2026, 12, 31));
      expect(c.firstMonthDays, 13 + 31);
    });

    test('signing up on 29 September runs to 31 December', () {
      final c = startOn(2026, 9, 29);
      expect(c.month1Key, '2026-10');
      expect(c.endMonthKey, '2026-12');
      expect(c.lastDay, day(2026, 12, 31));
    });

    test('a late-December start crosses the year', () {
      final c = startOn(2026, 12, 20);
      expect(c.month1Key, '2027-01');
      expect(c.lastDay, day(2027, 3, 31));
    });

    test('February ends where February ends', () {
      expect(startOn(2027, 12, 1).lastDay, day(2028, 2, 29)); // leap year
      expect(startOn(2026, 12, 1).lastDay, day(2027, 2, 28));
    });
  });

  group('the start day comes from the recorded offset', () {
    // 23:30 UTC on 17 September is still the 17th in New York and already
    // the 18th in Berlin, and that one day decides which month is month 1.
    final instant = DateTime.utc(2026, 9, 17, 23, 30);

    test('west of UTC', () {
      final c = Chapter.start(
        id: 'c',
        sentence: 's',
        pathKey: 'p',
        startedAt: instant,
        offsetMinutes: -240,
      );
      expect(c.startDay, day(2026, 9, 17));
      expect(c.month1Key, '2026-09');
    });

    test('east of UTC', () {
      final c = Chapter.start(
        id: 'c',
        sentence: 's',
        pathKey: 'p',
        startedAt: instant,
        offsetMinutes: 120,
      );
      expect(c.startDay, day(2026, 9, 18));
      expect(c.month1Key, '2026-10');
    });
  });

  group('a short first month asks for less', () {
    test('20 days: two actions', () {
      final c = startOn(2026, 9, 11);
      expect(c.firstMonthDays, 20);
      expect(c.suggestedFirstActions, 2);
    });

    test('21 days: three actions', () {
      final c = startOn(2026, 9, 10);
      expect(c.firstMonthDays, 21);
      expect(c.suggestedFirstActions, 3);
    });

    test('folded days make a long first month: three actions', () {
      expect(startOn(2026, 9, 29).suggestedFirstActions, 3);
    });
  });

  group('stages are the months', () {
    final c = startOn(2026, 9, 29); // month 1 is Sep 29 to Oct 31

    test('before the start and after the end: no stage', () {
      expect(c.stageOn(day(2026, 9, 28)), isNull);
      expect(c.stageOn(day(2027, 1, 1)), isNull);
    });

    test('folded days belong to month 1', () {
      expect(c.stageOn(day(2026, 9, 29)), 1);
      expect(c.stageOn(day(2026, 10, 31)), 1);
    });

    test('then one stage per calendar month', () {
      expect(c.stageOn(day(2026, 11, 1)), 2);
      expect(c.stageOn(day(2026, 12, 1)), 3);
      expect(c.stageOn(day(2026, 12, 31)), 3);
    });

    test('a time of day on the input does not matter', () {
      expect(c.stageOn(DateTime.utc(2026, 11, 1, 23, 59)), 2);
    });

    test('over only after the last day', () {
      expect(c.isOverOn(day(2026, 12, 31)), isFalse);
      expect(c.isOverOn(day(2027, 1, 1)), isTrue);
    });
  });

  group('the sentence', () {
    test('is trimmed', () {
      final c = Chapter.start(
        id: 'c',
        sentence: '  sleep a bit earlier \n',
        pathKey: 'p',
        startedAt: DateTime.utc(2026, 9, 1, 12),
        offsetMinutes: 0,
      );
      expect(c.sentence, 'sleep a bit earlier');
    });

    test('cannot be empty', () {
      expect(
        () => Chapter.start(
          id: 'c',
          sentence: '   ',
          pathKey: 'p',
          startedAt: DateTime.utc(2026, 9, 1, 12),
          offsetMinutes: 0,
        ),
        throwsArgumentError,
      );
      expect(() => startOn(2026, 9, 1).withSentence(''), throwsArgumentError);
    });

    test('can change while open', () {
      expect(startOn(2026, 9, 1).withSentence('move a little').sentence,
          'move a little');
    });
  });

  group('a closed chapter never changes', () {
    final closed = startOn(2026, 9, 1).closedWith(ChapterClose(
      closedAt: DateTime.utc(2026, 12, 1),
      answer: ChapterAnswer.partOfMe,
      note: 'The breathing stuck.',
    ));

    test('it cannot be closed twice', () {
      expect(
        () => closed.closedWith(ChapterClose(
          closedAt: DateTime.utc(2026, 12, 2),
          answer: ChapterAnswer.somethingElse,
        )),
        throwsStateError,
      );
    });

    test('its sentence cannot be edited', () {
      expect(() => closed.withSentence('something new'), throwsStateError);
    });
  });

  group('storage', () {
    test('round-trips open and closed chapters', () {
      final open = startOn(2026, 9, 29, offsetMinutes: -300);
      final back = Chapter.fromJson(open.toJson())!;
      expect(back.sentence, open.sentence);
      expect(back.startedAt, open.startedAt);
      expect(back.startOffsetMinutes, -300);
      expect(back.month1Key, open.month1Key);
      expect(back.endMonthKey, open.endMonthKey);
      expect(back.isClosed, isFalse);

      final closed = open.closedWith(ChapterClose(
        closedAt: DateTime.utc(2027, 1, 2),
        answer: ChapterAnswer.keepGoing,
        note: 'Not yet.',
      ));
      final closedBack = Chapter.fromJson(closed.toJson())!;
      expect(closedBack.close!.answer, ChapterAnswer.keepGoing);
      expect(closedBack.close!.note, 'Not yet.');
      expect(closedBack.close!.closedAt, DateTime.utc(2027, 1, 2));
    });

    test('answer keys are the persisted ones', () {
      expect(ChapterAnswer.values.map((a) => a.key),
          ['part_of_me', 'keep_going', 'something_else']);
    });

    test('an unreadable record reads as null, not as invented dates', () {
      expect(Chapter.fromJson({'id': 'c'}), isNull);
      final json = startOn(2026, 9, 1).toJson()..['endMonthKey'] = '2026-13';
      expect(Chapter.fromJson(json), isNull);
    });
  });
}
