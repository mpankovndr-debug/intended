import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/letter.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/season.dart';

/// A moment on day [day] of August 2026.
///
/// Moods default to "glad I did" so a month always has *something* to say —
/// otherwise a test asserting one line is absent would see the whole letter
/// vanish underneath it and pass for the wrong reason. Pass `mood: null` where
/// the point is a month nobody rated.
Moment _on(
  int day, {
  String habit = 'Body scan',
  int hour = 9,
  String category = 'Health',
  MomentMood? mood = MomentMood.gladIDid,
}) =>
    Moment.create(
      habitName: habit,
      category: category,
      mood: mood,
      at: DateTime(2026, 8, day, hour),
      id: '$day-$hour-$habit-$category',
    );

/// [count] moments on consecutive days from [startDay], one per day.
List<Moment> _daily(
  int count, {
  int startDay = 1,
  String habit = 'Body scan',
  int hour = 9,
  String category = 'Health',
  MomentMood? mood = MomentMood.gladIDid,
}) =>
    [
      for (var i = 0; i < count; i++)
        _on(startDay + i,
            habit: habit, hour: hour, category: category, mood: mood),
    ];

/// Reminder defaults to 09:00 and moments default to 09:00, so the closing
/// question is only about the day's shape where a test says so.
Letter? _read(List<Moment> m, {String? season, int? reminderHour = 9}) =>
    Letter.read(m, seasonPole: season, reminderHour: reminderHour);

LetterLine? _lineOf(Letter letter, LetterLineKind kind) {
  for (final line in letter.lines) {
    if (line.kind == kind) return line;
  }
  return null;
}

void main() {
  group('when there is nothing to write', () {
    test('a month under the threshold gets no letter', () {
      expect(_read(_daily(7)), isNull);
      expect(_read(_daily(8)), isNotNull);
    });

    test('one observation is a caption, not a letter', () {
      // Eight moments, eight different actions, nothing rated, no gaps and no
      // change of pace: the only true thing left is "you showed up on eight
      // days", which the grid already says in squares.
      final moments = [
        for (var i = 0; i < 8; i++) _on(i + 1, habit: 'Action $i', mood: null),
      ];
      expect(_read(moments), isNull);
    });

    test('an empty month gets no letter', () {
      expect(_read(const []), isNull);
    });
  });

  group('not saying what the card above already said', () {
    test('drops the return when the season is already Returning', () {
      // The season card is a card-sized statement about going quiet and
      // coming back. Repeating it two cards down is three cards, one fact.
      final moments = [..._daily(5), ..._daily(6, startDay: 10)];

      expect(
        _lineOf(_read(moments)!, LetterLineKind.cameBack),
        isNotNull,
        reason: 'no season showing, so the return is the letter to write',
      );
      expect(
        _lineOf(_read(moments, season: Season.returning)!,
            LetterLineKind.cameBack),
        isNull,
      );
    });

    test('a different season leaves the return alone', () {
      final moments = [..._daily(5), ..._daily(6, startDay: 10)];
      expect(
        _lineOf(_read(moments, season: Season.evening)!,
            LetterLineKind.cameBack),
        isNotNull,
      );
    });
  });

  group('the shape of the month', () {
    test('names a month that started slower than it finished', () {
      // One moment in the first third, eight in the last.
      final moments = [_on(1), ..._daily(8, startDay: 16)];
      final letter = _read(moments)!;

      expect(letter.lines.first.kind, LetterLineKind.openedQuietly);
    });

    test('and one that started faster', () {
      final moments = [..._daily(8), _on(20)];
      expect(
        _lineOf(_read(moments)!, LetterLineKind.openedFull),
        isNotNull,
      );
    });

    test('an even month has no pace to report', () {
      final moments = [..._daily(5), ..._daily(5, startDay: 16)];
      expect(_lineOf(_read(moments)!, LetterLineKind.openedQuietly), isNull);
      expect(_lineOf(_read(moments)!, LetterLineKind.openedFull), isNull);
    });

    test('nine days into a month is not a shape yet', () {
      // "You started this month quietly" would just be describing the 9th.
      final moments = [_on(1), ..._daily(8, startDay: 2)];
      expect(_lineOf(_read(moments)!, LetterLineKind.openedQuietly), isNull);
    });
  });

  group('what the month was made of', () {
    test('names the focus area that carried it', () {
      final moments = [
        ..._daily(9, category: 'Health'),
        ..._daily(3, startDay: 10, category: 'Mood'),
      ];
      final line = _lineOf(_read(moments)!, LetterLineKind.mostlyChose)!;

      expect(line.focusArea, 'Health');
    });

    test('an evenly spread month is not carried by anything', () {
      final moments = [
        ..._daily(6, category: 'Health'),
        ..._daily(6, startDay: 7, category: 'Mood'),
      ];
      expect(_lineOf(_read(moments)!, LetterLineKind.mostlyChose), isNull);
    });

    test('a single-area month says nothing — there is no choice in it', () {
      expect(
        _lineOf(_read(_daily(12))!, LetterLineKind.mostlyChose),
        isNull,
      );
    });
  });

  group('how it landed', () {
    test('splits glad from took-effort', () {
      final moments = [
        ..._daily(6, mood: MomentMood.gladIDid),
        ..._daily(3, startDay: 7, mood: MomentMood.tookEffort),
        ..._daily(2, startDay: 10, mood: MomentMood.neutral),
      ];
      final line = _lineOf(_read(moments)!, LetterLineKind.mood)!;

      expect(line.count, 6);
      expect(line.secondCount, 3);
    });

    test('a minority of rated moments is not reported as the month', () {
      final moments = [
        ..._daily(4, mood: MomentMood.gladIDid),
        ..._daily(10, startDay: 8, mood: null),
      ];
      expect(_lineOf(_read(moments)!, LetterLineKind.mood), isNull);
    });
  });

  group('the closing question', () {
    test('names where they live and where they planned', () {
      // A month of late evenings against a 9am reminder. The question has a
      // real alternative in it rather than being rhetorical.
      final letter = _read(_daily(12, hour: 22), reminderHour: 9)!;

      expect(letter.question, LetterQuestion.planForPart);
      expect(letter.part!.lived, DayPart.nights);
      expect(letter.part!.planned, DayPart.mornings);
    });

    test('says nothing about timing when the reminder already fits', () {
      final letter = _read(_daily(12, hour: 9), reminderHour: 9)!;
      expect(letter.question, isNot(LetterQuestion.planForPart));
    });

    test('a day with no shape gets no timing question', () {
      // Spread across the clock: proposing a time would be a coin flip.
      final moments = [for (var i = 0; i < 12; i++) _on(i + 1, hour: i + 5)];
      expect(_read(moments)!.question, isNot(LetterQuestion.planForPart));
    });

    test('falls back to the quiet stretches when the day has no lesson', () {
      final moments = [
        ..._daily(4, hour: 9),
        ..._daily(4, startDay: 9, hour: 9),
        ..._daily(4, startDay: 17, hour: 9),
      ];
      expect(_read(moments)!.question, LetterQuestion.shorterQuiet);
    });
  });

  group('shape', () {
    test('never more than three observations plus the question', () {
      final moments = [
        _on(1),
        ..._daily(6, startDay: 16, category: 'Health'),
        ..._daily(5, startDay: 23, habit: 'Drink water', category: 'Health'),
      ];
      expect(_read(moments)!.lines.length, Letter.maxLines);
    });

    test('showing up is the last thing said, never the first', () {
      final moments = [
        ..._daily(8),
        ..._daily(2, startDay: 9, habit: 'Drink water'),
      ];
      expect(
        _read(moments)!.lines.first.kind,
        isNot(LetterLineKind.showedUp),
      );
    });

    test('counts days on the clock each moment recorded, not the reader\'s',
        () {
      // Nine moments at 22:00 UTC, logged from Moscow — where it is already
      // 01:00 the next day. Re-deriving from UTC would report days the user
      // never had, and split one of them into two.
      final moments = [
        for (var i = 0; i < 9; i++)
          Moment(
            id: 'a$i',
            habitName: 'Body scan',
            habitEmoji: '✦',
            completedAt: DateTime.utc(2026, 8, 3 + i, 22),
            category: 'Health',
            mood: MomentMood.gladIDid,
            localHour: 1,
            localWeekday: 1,
            tzOffsetMinutes: 180,
          ),
      ];
      expect(
        _lineOf(_read(moments)!, LetterLineKind.showedUp)!.count,
        9,
      );
    });
  });
}
