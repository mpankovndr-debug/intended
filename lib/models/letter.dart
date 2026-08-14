import 'moment.dart';
import 'moment_rollup.dart';
import 'season.dart';

/// Which observation a letter line is making.
enum LetterLineKind {
  /// The month started slower than it finished.
  openedQuietly,

  /// Or the other way round.
  openedFull,

  /// A quiet stretch, and the return that ended it.
  cameBack,

  /// One focus area held almost the whole month.
  mostlyChose,

  /// The action that carried it.
  anchor,

  /// How it landed: glad / took effort.
  mood,

  /// How many separate days had something in them.
  showedUp,
}

/// The closing line. Always a question, and always about the month ahead —
/// see [Letter].
enum LetterQuestion {
  /// Their moments land in one part of the day and their reminder sits in
  /// another. Carries both, so the question can name them.
  planForPart,

  /// They went quiet and came back more than once.
  shorterQuiet,

  /// The intention chosen at onboarding no longer describes the life being
  /// lived. Outranks the others: nothing else the letter could ask matters
  /// as much as whether the thing at the top of Today is still true.
  intentionStillFits,

  /// Nothing sharper to ask.
  moreOfWhat,
}

/// Parts of the day the letter can name, as plural nouns: "evenings".
enum DayPart { mornings, afternoons, evenings, nights }

/// One observation, with whatever that observation needs to be stated.
class LetterLine {
  const LetterLine(
    this.kind, {
    this.count = 0,
    this.secondCount = 0,
    this.habitName,
    this.focusArea,
  });

  final LetterLineKind kind;

  /// Quiet days before a return · times an action was reached for · moments
  /// the user was glad about · days shown up on.
  final int count;

  /// Only [LetterLineKind.mood] uses it: the moments that took effort.
  final int secondCount;

  final String? habitName;
  final String? focusArea;
}

/// Four lines about the month, ending in a question about the next one (§5.3).
///
/// Replaces the stock quote that used to sit here ("Consistency is important,
/// but so is self-compassion") — a sentence equally true of a stranger.
///
/// Two rules shape what it is allowed to say.
///
/// **It describes the month's shape, not its facts.** The grid already says
/// how many and in which areas; the season already names the pattern. A letter
/// that repeats either is three cards saying one thing. So the lines here are
/// about pace, concentration and how the month felt to make — and [read] is
/// told which season was drawn so it can drop a line that season has already
/// made the whole card about.
///
/// **It closes on the month ahead.** A comfort finishes the subject and a
/// backward question is just more looking; a question about next month is the
/// hand-off to the plan sitting under it, which is the thing someone opens
/// this page for in month seven.
class Letter {
  const Letter({required this.lines, required this.question, this.part});

  /// Observations, strongest first. Two or three; the question makes up the
  /// fourth line.
  final List<LetterLine> lines;

  final LetterQuestion question;

  /// Set only for [LetterQuestion.planForPart]: where their moments actually
  /// land, and where the reminder currently sits.
  final ({DayPart lived, DayPart planned})? part;

  static const int maxLines = 3;

  /// Below this, a month is a handful of separate days rather than a month.
  static const int minMoments = 8;

  /// A month's letter, or null when there is nothing honest to write.
  ///
  /// [seasonPole] is the word the season card is showing, so the letter can
  /// avoid restating it. [reminderHour] is where the daily nudge currently
  /// sits, which is what makes the closing question specific rather than
  /// rhetorical.
  static Letter? read(
    List<Moment> moments, {
    String? seasonPole,
    int? reminderHour,
    List<String> pathAreas = const [],
  }) {
    if (moments.length < minMoments) return null;

    final candidates = [
      _opening(moments),
      // The season card is already a card-sized statement about going quiet
      // and coming back. Saying it again two cards later is not emphasis.
      if (seasonPole != Season.returning) _cameBack(moments),
      _mostlyChose(moments),
      _anchor(moments),
      _mood(moments),
      _showedUp(moments),
    ].whereType<LetterLine>().toList();

    if (candidates.length < 2) return null;

    final lines = candidates.take(maxLines).toList();

    // Asked before anything else, because an intention that has stopped
    // describing someone turns the top of Today into a stale promise they
    // scroll past — worse than a neutral date, which cannot be wrong about
    // them. The letter only ever asks; the redirect stays one tap away on
    // Today, where it already lives.
    if (_hasDrifted(moments, pathAreas)) {
      return Letter(lines: lines, question: LetterQuestion.intentionStillFits);
    }

    final lived = _dominantPart(moments);
    final planned = reminderHour == null ? null : _partOf(reminderHour);

    if (lived != null && planned != null && lived != planned) {
      return Letter(
        lines: lines,
        question: LetterQuestion.planForPart,
        part: (lived: lived, planned: planned),
      );
    }
    return Letter(
      lines: lines,
      question: _gapCount(moments) >= 2
          ? LetterQuestion.shorterQuiet
          : LetterQuestion.moreOfWhat,
    );
  }

  /// Whether the month started slower or faster than it ended.
  ///
  /// The one thing on this page that describes the month as something with a
  /// direction rather than a total, which is why it leads.
  static LetterLine? _opening(List<Moment> moments) {
    final days = _activeDays(moments);
    // Measured across the *active* span — first active day to last — not the
    // calendar's day numbers. Day-of-month made `early` count days before a
    // mid-month install existed, so anyone who started on the 18th was told
    // "you started this month quietly" regardless of how they actually
    // started (review finding #9). The first day is active by construction,
    // so `early` is always at least one.
    final first = days.first.day;
    final last = days.last.day;
    final span = last - first + 1;
    if (span < _minSpanForPace) return null;

    final third = span / 3;
    var early = 0;
    var late = 0;
    for (final m in moments) {
      final day = _wallDay(m).day;
      if (day < first + third) early++;
      if (day > last - third) late++;
    }

    if (late >= early * 2) return const LetterLine(LetterLineKind.openedQuietly);
    if (early >= late * 2) return const LetterLine(LetterLineKind.openedFull);
    return null;
  }

  /// The most recent quiet stretch, told as the thing that ended it.
  static LetterLine? _cameBack(List<Moment> moments) {
    final days = _activeDays(moments);
    for (var i = days.length - 1; i >= 1; i--) {
      final quiet = days[i].difference(days[i - 1]).inDays - 1;
      if (quiet >= MomentRollup.gapThresholdDays) {
        return LetterLine(LetterLineKind.cameBack, count: quiet);
      }
    }
    return null;
  }

  /// When one focus area held almost the whole month.
  ///
  /// The legend under the grid gives the counts; this says what they add up
  /// to, which is a different sentence.
  static LetterLine? _mostlyChose(List<Moment> moments) {
    final counts = <String, int>{};
    for (final m in moments) {
      final key = m.category;
      if (key != null) counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.length < 2) return null;

    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (top.value / moments.length < _minConcentration) return null;

    return LetterLine(LetterLineKind.mostlyChose, focusArea: top.key);
  }

  /// The action the month leaned on, when one clearly did.
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

  /// How the month landed, from the mood tap. Needs most of the month rated,
  /// or it reports a minority as though it were the whole of it.
  static LetterLine? _mood(List<Moment> moments) {
    final rated = moments.where((m) => m.mood != null).toList();
    if (rated.length < _minRatedMoments) return null;
    if (rated.length / moments.length < _minRatedShare) return null;

    final glad = rated.where((m) => m.mood == MomentMood.gladIDid).length;
    final effort = rated.where((m) => m.mood == MomentMood.tookEffort).length;
    if (glad == 0 && effort == 0) return null;

    return LetterLine(LetterLineKind.mood, count: glad, secondCount: effort);
  }

  /// Always available, and last for exactly that reason.
  static LetterLine _showedUp(List<Moment> moments) =>
      LetterLine(LetterLineKind.showedUp, count: _activeDays(moments).length);

  /// True when the month was mostly spent outside the areas the chosen
  /// intention is made of.
  ///
  /// Deliberately strict. Most people's intentions fit fine, and asking
  /// someone whether they still mean it — when they plainly do — is the app
  /// second-guessing a person about their own life. So: an empty [pathAreas]
  /// (the "your own way" path, which makes no claim to describe anyone) never
  /// drifts, and the lived area has to both sit outside the intention and
  /// carry most of the month.
  static bool _hasDrifted(List<Moment> moments, List<String> pathAreas) {
    if (pathAreas.isEmpty) return false;
    if (moments.length < _minMomentsForDrift) return false;

    final counts = <String, int>{};
    for (final m in moments) {
      final key = m.category;
      if (key != null) counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return false;

    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (pathAreas.contains(top.key)) return false;
    return top.value / moments.length >= _minDriftShare;
  }

  /// A fortnight of moments is not a life changing direction.
  static const int _minMomentsForDrift = 12;

  /// And it has to be most of the month, not a busy week elsewhere.
  static const double _minDriftShare = 0.55;

  /// The part of day most moments fall in, or null when nothing dominates.
  static DayPart? _dominantPart(List<Moment> moments) {
    final counts = <DayPart, int>{};
    for (final m in moments) {
      final part = _partOf(m.localHour);
      counts[part] = (counts[part] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.value / moments.length < _minPartShare ? null : top.key;
  }

  static DayPart _partOf(int hour) => hour < 5
      ? DayPart.nights
      : hour < 12
          ? DayPart.mornings
          : hour < 17
              ? DayPart.afternoons
              : hour < 22
                  ? DayPart.evenings
                  : DayPart.nights;

  static int _gapCount(List<Moment> moments) {
    final days = _activeDays(moments);
    var gaps = 0;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays - 1 >=
          MomentRollup.gapThresholdDays) {
        gaps++;
      }
    }
    return gaps;
  }

  /// Distinct days the user was active on, oldest first, on the clock each
  /// moment recorded rather than the reader's.
  static List<DateTime> _activeDays(List<Moment> moments) {
    final days = <DateTime>{for (final m in moments) _wallDay(m)};
    return days.toList()..sort();
  }

  static DateTime _wallDay(Moment m) {
    final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// A month needs two weeks in it before "you started quietly" is describing
  /// a shape rather than the fact that it is the 9th.
  static const int _minSpanForPace = 14;

  /// "Carried almost the whole month" has to be nearly all of it.
  static const double _minConcentration = 0.6;

  static const int _minAnchorCount = 3;
  static const double _minAnchorShare = 0.4;

  static const int _minRatedMoments = 5;
  static const double _minRatedShare = 0.6;

  /// Below this the day has no shape worth planning around, and the closing
  /// question would be proposing a change on the strength of a coin flip.
  static const double _minPartShare = 0.5;
}
