import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/letter.dart';
import 'package:intended/models/moment.dart';

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
  MomentMood? mood = MomentMood.gladIDid,
}) =>
    Moment.create(
      habitName: habit,
      category: 'Health',
      mood: mood,
      at: DateTime(2026, 8, day, hour),
      id: '$day-$hour-$habit',
    );

/// [count] moments on consecutive days from [startDay], one per day.
List<Moment> _daily(
  int count, {
  int startDay = 1,
  String habit = 'Body scan',
  MomentMood? mood = MomentMood.gladIDid,
}) =>
    [
      for (var i = 0; i < count; i++)
        _on(startDay + i, habit: habit, mood: mood),
    ];

LetterLine? _lineOf(Letter letter, LetterLineKind kind) {
  for (final line in letter.lines) {
    if (line.kind == kind) return line;
  }
  return null;
}

void main() {
  group('when there is nothing to write', () {
    test('a month under the threshold gets no letter', () {
      expect(Letter.read(_daily(7)), isNull);
      expect(Letter.read(_daily(8)), isNotNull);
    });

    test('one observation is a caption, not a letter', () {
      // Eight moments, eight different actions, nothing rated, no gaps: the
      // only true thing left is "you showed up on eight days", which the grid
      // already says in squares.
      final moments = [
        for (var i = 0; i < 8; i++) _on(i + 1, habit: 'Action $i', mood: null),
      ];
      expect(Letter.read(moments), isNull);
    });

    test('an empty month gets no letter', () {
      expect(Letter.read(const []), isNull);
    });
  });

  group('coming back', () {
    test('names the day and the quiet stretch', () {
      // Aug 1-5, silent through the 9th, back on the 10th.
      final moments = [..._daily(5), ..._daily(5, startDay: 10)];
      final line = _lineOf(Letter.read(moments)!, LetterLineKind.cameBack)!;

      expect(line.day, DateTime.utc(2026, 8, 10));
      expect(line.count, 4); // the 6th through the 9th
    });

    test('a single quiet day is not a return', () {
      // Lally: missing one opportunity did not materially affect habit
      // formation. Calling it a comeback rebuilds streak logic in reverse.
      final moments = [..._daily(5), ..._daily(5, startDay: 7)];
      expect(_lineOf(Letter.read(moments)!, LetterLineKind.cameBack), isNull);
    });

    test('picks the most recent return, not the longest gap', () {
      // A twelve-day gap early, a three-day gap last. The question that
      // follows asks what brought them back, so it has to be a day they can
      // still place — the better statistic makes the worse question.
      final moments = [
        ..._daily(4),
        ..._daily(4, startDay: 17),
        ..._daily(4, startDay: 24),
      ];
      final line = _lineOf(Letter.read(moments)!, LetterLineKind.cameBack)!;

      expect(line.day, DateTime.utc(2026, 8, 24));
      expect(line.count, 3);
    });

    test('a return leads the letter and sets the question', () {
      final moments = [..._daily(5), ..._daily(5, startDay: 10)];
      final letter = Letter.read(moments)!;

      expect(letter.lines.first.kind, LetterLineKind.cameBack);
      expect(letter.question, LetterQuestion.whatBroughtYouBack);
    });
  });

  group('the anchor', () {
    test('names the action that carried the month', () {
      final moments = [
        ..._daily(8, habit: 'Body scan'),
        ..._daily(2, startDay: 9, habit: 'Drink water'),
      ];
      final line = _lineOf(Letter.read(moments)!, LetterLineKind.anchor)!;

      expect(line.habitName, 'Body scan');
      expect(line.count, 8);
    });

    test('a tie has no anchor — picking one would be sorting, not reading', () {
      final moments = [
        ..._daily(5, habit: 'Body scan'),
        ..._daily(5, startDay: 6, habit: 'Drink water'),
      ];
      expect(_lineOf(Letter.read(moments)!, LetterLineKind.anchor), isNull);
    });

    test('a month of one action has no anchor to name', () {
      // "Most of the month was X" says nothing when X is all there was.
      final moments = _daily(10);
      expect(_lineOf(Letter.read(moments)!, LetterLineKind.anchor), isNull);
    });

    test('the tallest of a scatter is not "most of the month"', () {
      // Three of one, one each of nine others. It wins, but a quarter of the
      // month is not most of it, and the sentence would be claiming otherwise.
      final moments = [
        ..._daily(3, habit: 'Body scan'),
        for (var i = 0; i < 9; i++) _on(4 + i, habit: 'Action $i'),
      ];
      expect(_lineOf(Letter.read(moments)!, LetterLineKind.anchor), isNull);
    });
  });

  group('how it landed', () {
    test('splits glad from took-effort', () {
      final moments = [
        ..._daily(6, mood: MomentMood.gladIDid),
        ..._daily(3, startDay: 7, mood: MomentMood.tookEffort),
        ..._daily(2, startDay: 10, mood: MomentMood.neutral),
      ];
      final line = _lineOf(Letter.read(moments)!, LetterLineKind.mood)!;

      expect(line.count, 6);
      expect(line.secondCount, 3);
    });

    test('a minority of rated moments is not reported as the month', () {
      // Four moods across fourteen moments: "four you were glad about"
      // presents a quarter of the month as though it were the whole of it.
      final moments = [
        ..._daily(4, mood: MomentMood.gladIDid),
        ..._daily(10, startDay: 8, mood: null),
      ];
      expect(_lineOf(Letter.read(moments)!, LetterLineKind.mood), isNull);
    });

    test('all-neutral says nothing about how the month landed', () {
      final moments = [
        ..._daily(5, mood: MomentMood.neutral),
        ..._daily(5, startDay: 9, mood: MomentMood.neutral),
      ];
      expect(_lineOf(Letter.read(moments)!, LetterLineKind.mood), isNull);
    });
  });

  group('one big day', () {
    test('names a day that stands out', () {
      final moments = [
        _on(3, hour: 8),
        _on(3, hour: 12),
        _on(3, hour: 20),
        ..._daily(7, startDay: 10),
      ];
      final line = _lineOf(Letter.read(moments)!, LetterLineKind.oneBigDay)!;

      expect(line.day, DateTime.utc(2026, 8, 3));
      expect(line.count, 3);
    });

    test('two busiest days tied means neither is the one', () {
      final moments = [
        _on(3, hour: 8), _on(3, hour: 12), _on(3, hour: 20),
        _on(4, hour: 8), _on(4, hour: 12), _on(4, hour: 20),
        ..._daily(4, startDay: 10),
      ];
      expect(_lineOf(Letter.read(moments)!, LetterLineKind.oneBigDay), isNull);
    });
  });

  group('shape', () {
    test('never more than three observations plus the question', () {
      // A month with everything in it: a return, an anchor, moods, a big day.
      final moments = [
        ..._daily(6),
        _on(6, hour: 14, mood: MomentMood.tookEffort),
        _on(6, hour: 20, mood: MomentMood.tookEffort),
        ..._daily(4, startDay: 12, habit: 'Drink water'),
      ];
      final letter = Letter.read(moments)!;

      expect(letter.lines.length, Letter.maxLines);
      expect(letter.lines.length, 3);
    });

    test('the question follows whatever line leads', () {
      // No gaps and no anchor — a dead-even split — so the mood line leads,
      // and the question has to be the one about moods rather than a generic
      // sign-off pinned to the bottom of every letter.
      final moments = [
        ..._daily(3, habit: 'Body scan'),
        ..._daily(2, startDay: 4, habit: 'Body scan',
            mood: MomentMood.tookEffort),
        ..._daily(3, startDay: 6, habit: 'Drink water'),
        ..._daily(2, startDay: 9, habit: 'Drink water',
            mood: MomentMood.tookEffort),
      ];
      final letter = Letter.read(moments)!;

      expect(_lineOf(letter, LetterLineKind.anchor), isNull);
      expect(letter.lines.first.kind, LetterLineKind.mood);
      expect(letter.question, LetterQuestion.whatDoTheyShare);
    });

    test('showing up is the last thing said, never the first', () {
      final moments = [
        ..._daily(8),
        ..._daily(2, startDay: 9, habit: 'Drink water'),
      ];
      final letter = Letter.read(moments)!;

      expect(letter.lines.first.kind, isNot(LetterLineKind.showedUp));
    });

    test('counts days on the clock each moment recorded, not the reader\'s',
        () {
      // Nine moments at 22:00 UTC, logged from Moscow — where it is already
      // 01:00 the next day. Re-deriving the day from UTC would report days the
      // user never had.
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
      final letter = Letter.read(moments)!;

      expect(_lineOf(letter, LetterLineKind.showedUp)!.count, 9);
      // The 3rd at 22:00 UTC is the 4th in Moscow — and the run ends on the
      // 12th, not the 11th.
      expect(_lineOf(letter, LetterLineKind.cameBack), isNull);
    });
  });
}
