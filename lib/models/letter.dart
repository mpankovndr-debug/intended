import 'moment.dart';
import 'moment_rollup.dart';

/// Which observation a letter line is making. The data each one needs differs,
/// so a line is only ever built by its own reader below — never assembled by
/// hand at a call site.
enum LetterLineKind {
  /// A named day the user came back on, after a quiet stretch.
  cameBack,

  /// The action that carried the month.
  anchor,

  /// How the month landed: glad / took effort.
  mood,

  /// A single day that held several moments.
  oneBigDay,

  /// How many separate days had something in them.
  showedUp,
}

/// The closing line. Always a question — see [Letter].
enum LetterQuestion {
  whatBroughtYouBack,
  whatMakesItEasier,
  whatDoTheyShare,
  whatWasDifferent,
  whatWouldYouMiss,
}

/// One observation, with whatever that observation needs to be stated.
///
/// Dates travel as [DateTime] rather than pre-formatted text: "on the 14th"
/// and "on Friday" are built differently in every language, so the screen
/// formats them and the model stays out of it — the same split [Season] uses
/// for its words.
class LetterLine {
  const LetterLine(
    this.kind, {
    this.count = 0,
    this.secondCount = 0,
    this.day,
    this.habitName,
  });

  final LetterLineKind kind;

  /// Quiet days before a return · times an action was reached for · moments
  /// the user was glad about · moments on the busiest day · days shown up on.
  final int count;

  /// Only [LetterLineKind.mood] uses it: the moments that took effort.
  final int secondCount;

  /// The user's own calendar day, as wall clock. Set for [cameBack] and
  /// [oneBigDay].
  final DateTime? day;

  /// Set for [anchor].
  final String? habitName;
}

/// Four lines about the month, ending in a question (§5.3).
///
/// Replaces the stock quote that used to sit in this slot ("Consistency is
/// important, but so is self-compassion") — a sentence equally true of a
/// stranger, which is why it read as filler. The letter earns the space by
/// naming things only this user's month could produce: the weekday they came
/// back on, the action that carried the month, how those moments landed.
///
/// Every line is generated from stored data and dropped when the data isn't
/// there. Nothing is padded and nothing is inferred — a letter that pads is
/// §5.3's "bought a promise, received a promise" failure in prose form, and
/// the whole page is paid on the strength of these sentences being true.
///
/// It closes on a question rather than a comfort. A comfort finishes the
/// subject; a question leaves the user holding it, which is what has to happen
/// if this page is going to be worth opening in month seven.
class Letter {
  const Letter({required this.lines, required this.question});

  /// Observations, strongest first. Two or three of them; the question below
  /// makes up the fourth line.
  final List<LetterLine> lines;

  /// Follows from [lines].first, so the letter asks about what it just found
  /// rather than asking something generic underneath it.
  final LetterQuestion question;

  /// How many observations a letter carries at most. Three, plus the question,
  /// is the four lines §5.3 specifies — long enough to be about a month,
  /// short enough to be read.
  static const int maxLines = 3;

  /// Below this, a month is a handful of separate days rather than a month.
  ///
  /// Lower than the season's ten on purpose: a season names a *pattern* and
  /// needs enough of one to be real, where the letter names *events*, and "you
  /// came back on Friday" is true the first time it happens. But under eight,
  /// three observations end up describing the same two afternoons three
  /// different ways, which reads as the app straining to have something to say.
  static const int minMoments = 8;

  /// A month's letter, or null when there is nothing honest to write.
  ///
  /// Silence is the default here, exactly as it is for the drift warning: a
  /// card that appears only when it has something is worth reading, and one
  /// that always appears has to invent material on quiet months.
  static Letter? read(List<Moment> moments) {
    if (moments.length < minMoments) return null;

    // Priority order, and also reading order — the most specific thing the
    // month produced goes first, and the question follows from it.
    final candidates = [
      _cameBack(moments),
      _anchor(moments),
      _mood(moments),
      _oneBigDay(moments),
      _showedUp(moments),
    ].whereType<LetterLine>().toList();

    // One observation is not a letter, it is a caption. [_showedUp] alone
    // means the month held nothing worth naming beyond a count the grid
    // already shows.
    if (candidates.length < 2) return null;

    final lines = candidates.take(maxLines).toList();
    return Letter(lines: lines, question: _questionFor(lines.first.kind));
  }

  static LetterQuestion _questionFor(LetterLineKind lead) => switch (lead) {
        LetterLineKind.cameBack => LetterQuestion.whatBroughtYouBack,
        LetterLineKind.anchor => LetterQuestion.whatMakesItEasier,
        LetterLineKind.mood => LetterQuestion.whatDoTheyShare,
        LetterLineKind.oneBigDay => LetterQuestion.whatWasDifferent,
        LetterLineKind.showedUp => LetterQuestion.whatWouldYouMiss,
      };

  /// The most recent return in the month, not the longest gap.
  ///
  /// The question that follows asks what brought them back, so the day has to
  /// be one they can still remember. A three-week-old comeback is a better
  /// statistic and a worse question.
  static LetterLine? _cameBack(List<Moment> moments) {
    final days = _activeDays(moments);
    for (var i = days.length - 1; i >= 1; i--) {
      final quiet = days[i].difference(days[i - 1]).inDays - 1;
      if (quiet >= MomentRollup.gapThresholdDays) {
        return LetterLine(
          LetterLineKind.cameBack,
          count: quiet,
          day: days[i],
        );
      }
    }
    return null;
  }

  /// The action the month leaned on, when one clearly did.
  ///
  /// "Most of it was X" is a claim, so it is only made when X actually beat
  /// everything else — a two-way tie at five each is a month with no anchor,
  /// and naming either one would be picking a winner by sort order.
  static LetterLine? _anchor(List<Moment> moments) {
    final counts = <String, int>{};
    for (final m in moments) {
      counts[m.habitName] = (counts[m.habitName] ?? 0) + 1;
    }
    if (counts.length < 2) return null;

    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.first;
    if (top.value < _minAnchorCount) return null;
    if (top.value == ranked[1].value) return null;
    if (top.value / moments.length < _minAnchorShare) return null;

    return LetterLine(
      LetterLineKind.anchor,
      count: top.value,
      habitName: top.key,
    );
  }

  /// How the month landed, from the mood tap.
  ///
  /// Needs most of the month to actually carry a mood: counting "eleven you
  /// were glad about" out of thirty moments where nineteen were skipped
  /// reports a minority as if it were the month.
  static LetterLine? _mood(List<Moment> moments) {
    final rated = moments.where((m) => m.mood != null).toList();
    if (rated.length < _minRatedMoments) return null;
    if (rated.length / moments.length < _minRatedShare) return null;

    final glad =
        rated.where((m) => m.mood == MomentMood.gladIDid).length;
    final effort =
        rated.where((m) => m.mood == MomentMood.tookEffort).length;
    if (glad == 0 && effort == 0) return null;

    return LetterLine(LetterLineKind.mood, count: glad, secondCount: effort);
  }

  /// The busiest single day, when it stands out from the rest.
  static LetterLine? _oneBigDay(List<Moment> moments) {
    final perDay = <DateTime, int>{};
    for (final m in moments) {
      final day = _wallDay(m);
      perDay[day] = (perDay[day] ?? 0) + 1;
    }
    if (perDay.length < 2) return null;

    final ranked = perDay.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (ranked.first.value < _minBigDayCount) return null;
    if (ranked.first.value == ranked[1].value) return null;

    return LetterLine(
      LetterLineKind.oneBigDay,
      count: ranked.first.value,
      day: ranked.first.key,
    );
  }

  /// Days with something in them. The one line that is always available, and
  /// the reason it sits last: it is the least specific true thing there is.
  static LetterLine _showedUp(List<Moment> moments) =>
      LetterLine(LetterLineKind.showedUp, count: _activeDays(moments).length);

  /// Distinct days the user was active on, oldest first.
  ///
  /// Rebuilt from each moment's own recorded offset rather than the device's
  /// current zone — the same rule every reader in this app follows, because a
  /// UTC timestamp does not record what the user's clock said.
  static List<DateTime> _activeDays(List<Moment> moments) {
    final days = <DateTime>{for (final m in moments) _wallDay(m)};
    return days.toList()..sort();
  }

  static DateTime _wallDay(Moment m) {
    final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// Fewer than three times is not an anchor, it is a coincidence.
  static const int _minAnchorCount = 3;

  /// And it has to be enough of the month to carry the word "most".
  ///
  /// Set by the sentence, not the other way round: three out of twelve is the
  /// tallest of a scatter, and calling that "most of the month" would be the
  /// copy stating a finding the data doesn't hold. Two fifths, with nothing
  /// else close, is a month that leaned somewhere.
  static const double _minAnchorShare = 0.4;

  static const int _minRatedMoments = 5;
  static const double _minRatedShare = 0.6;

  /// Two things in a day is an ordinary day.
  static const int _minBigDayCount = 3;
}
