/// How a chapter ended, in the person's own answer (spec §2.3).
///
/// The app never declares a chapter achieved or missed: it asks, and this is
/// what the person said. Keys are persisted — never rename them.
enum ChapterAnswer {
  /// "It's part of me now." The next chapter keeps the sentence, lighter.
  partOfMe('part_of_me'),

  /// "Keep going." Same sentence, a new chapter from the next 1st.
  keepGoing('keep_going'),

  /// "Something else now." A new sentence.
  somethingElse('something_else');

  const ChapterAnswer(this.key);

  final String key;

  static ChapterAnswer? fromKey(String? key) {
    for (final a in ChapterAnswer.values) {
      if (a.key == key) return a;
    }
    return null;
  }
}

/// The end of a chapter: when, the person's answer, and anything they wanted
/// to remember. Frozen once written, like a closed season.
class ChapterClose {
  const ChapterClose({
    required this.closedAt,
    required this.answer,
    this.note,
  });

  final DateTime closedAt;
  final ChapterAnswer answer;

  /// Their own words, optional. Never localised, never shortened.
  final String? note;

  Map<String, dynamic> toJson() => {
        'closedAt': closedAt.toUtc().toIso8601String(),
        'answer': answer.key,
        if (note != null) 'note': note,
      };

  /// Null when the stored answer is unreadable: a close we cannot read is
  /// safer treated as still open than as an answer the person never gave.
  static ChapterClose? fromJson(Map<String, dynamic> json) {
    final answer = ChapterAnswer.fromKey(json['answer'] as String?);
    final closedAt = DateTime.tryParse(json['closedAt'] as String? ?? '');
    if (answer == null || closedAt == null) return null;
    return ChapterClose(
      closedAt: closedAt.toUtc(),
      answer: answer,
      note: json['note'] as String?,
    );
  }
}

/// About three months under one sentence in the person's own words
/// (spec §2). Stages are the months: *Try a few*, *Keep what stuck*,
/// *Make it lighter*. A chapter ends on a date, or when the person says so —
/// never because the app decides it is done.
///
/// Moments are not tagged with a chapter. A chapter is a range of the
/// person's own calendar days, and a moment belongs to it by
/// `Moment.localDay`.
class Chapter {
  const Chapter({
    required this.id,
    required this.sentence,
    required this.pathKey,
    required this.startedAt,
    required this.startOffsetMinutes,
    required this.month1Key,
    required this.endMonthKey,
    this.close,
  });

  /// A start month with fewer days left than this does not count as month 1:
  /// its remaining days fold into the next month, which becomes month 1.
  /// Two weeks is the least that "try a few" can mean anything over.
  static const int minDaysForStartMonth = 14;

  /// A first month shorter than this suggests two actions instead of three,
  /// so each one gets enough tries to be read fairly at the first plan.
  /// A starting value — tune it against real first plans.
  static const int shortFirstMonthDays = 21;

  static const int actionsForShortFirstMonth = 2;
  static const int actionsForFullFirstMonth = 3;

  final String id;

  /// "I want to …", in the person's words. Editable while the chapter is
  /// open, frozen when it closes.
  final String sentence;

  /// `IntentionPathId.key` when the chapter began.
  final String pathKey;

  /// UTC instant the chapter was started.
  final DateTime startedAt;

  /// The UTC offset on the person's clock when they started. The start day is
  /// read from this, never from the device's current zone (CLAUDE.md: a west-
  /// of-UTC user must not start a day early).
  final int startOffsetMinutes;

  /// "2026-10": month 1, after the [minDaysForStartMonth] rule.
  final String month1Key;

  /// "2026-12": the chapter ends at the end of this month.
  final String endMonthKey;

  /// Null while the chapter is open.
  final ChapterClose? close;

  bool get isClosed => close != null;

  /// Starts a chapter at [startedAt] (any zone; stored as UTC) on a clock
  /// whose offset was [offsetMinutes].
  factory Chapter.start({
    required String id,
    required String sentence,
    required String pathKey,
    required DateTime startedAt,
    required int offsetMinutes,
  }) {
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(sentence, 'sentence', 'must not be empty');
    }
    final utc = startedAt.toUtc();
    final day = _localDay(utc, offsetMinutes);
    final daysLeft = _daysInMonth(day) - day.day + 1;
    final month1 = daysLeft >= minDaysForStartMonth
        ? DateTime.utc(day.year, day.month, 1)
        : DateTime.utc(day.year, day.month + 1, 1);
    final endMonth = DateTime.utc(month1.year, month1.month + 2, 1);
    return Chapter(
      id: id,
      sentence: trimmed,
      pathKey: pathKey,
      startedAt: utc,
      startOffsetMinutes: offsetMinutes,
      month1Key: _monthKey(month1),
      endMonthKey: _monthKey(endMonth),
    );
  }

  /// The person's calendar day the chapter started, UTC-flagged.
  DateTime get startDay => _localDay(startedAt, startOffsetMinutes);

  /// The chapter's last calendar day, UTC-flagged: the last day of
  /// [endMonthKey].
  DateTime get lastDay {
    final end = _parseMonthKey(endMonthKey);
    return DateTime.utc(end.year, end.month + 1, 0);
  }

  /// Last calendar day of month 1, UTC-flagged.
  DateTime get _month1LastDay {
    final m1 = _parseMonthKey(month1Key);
    return DateTime.utc(m1.year, m1.month + 1, 0);
  }

  /// Days in the first stage, the start day included. 14 to 31 when the start
  /// month counts, 31 to 44 when its last days fold into the next month.
  int get firstMonthDays => _month1LastDay.difference(startDay).inDays + 1;

  /// How many actions the first stage suggests (spec §2.1).
  int get suggestedFirstActions => firstMonthDays < shortFirstMonthDays
      ? actionsForShortFirstMonth
      : actionsForFullFirstMonth;

  /// 1, 2 or 3 on [localDay] (a UTC-flagged calendar day, as
  /// `Moment.localDay` returns), or null outside the chapter.
  int? stageOn(DateTime localDay) {
    final day = DateTime.utc(localDay.year, localDay.month, localDay.day);
    if (day.isBefore(startDay) || day.isAfter(lastDay)) return null;
    if (!day.isAfter(_month1LastDay)) return 1;
    final m1 = _parseMonthKey(month1Key);
    final monthsIn = (day.year - m1.year) * 12 + (day.month - m1.month);
    return monthsIn + 1;
  }

  /// True once [localDay] is past the chapter's last day.
  bool isOverOn(DateTime localDay) =>
      DateTime.utc(localDay.year, localDay.month, localDay.day)
          .isAfter(lastDay);

  /// The sentence edited while the chapter is open.
  Chapter withSentence(String sentence) {
    if (isClosed) {
      throw StateError('A closed chapter is immutable');
    }
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(sentence, 'sentence', 'must not be empty');
    }
    return _copy(sentence: trimmed);
  }

  /// This chapter, closed with the person's answer. Once closed, a chapter
  /// never changes again: "this is what I was after in autumn" is only worth
  /// keeping if it stays true.
  Chapter closedWith(ChapterClose close) {
    if (isClosed) {
      throw StateError('A closed chapter is immutable');
    }
    return _copy(close: close);
  }

  Chapter _copy({String? sentence, ChapterClose? close}) => Chapter(
        id: id,
        sentence: sentence ?? this.sentence,
        pathKey: pathKey,
        startedAt: startedAt,
        startOffsetMinutes: startOffsetMinutes,
        month1Key: month1Key,
        endMonthKey: endMonthKey,
        close: close ?? this.close,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sentence': sentence,
        'pathKey': pathKey,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'startOffsetMinutes': startOffsetMinutes,
        'month1Key': month1Key,
        'endMonthKey': endMonthKey,
        if (close != null) 'close': close!.toJson(),
      };

  /// Null when the record is unreadable. The caller drops it rather than
  /// inventing dates for a chapter the person may have written.
  static Chapter? fromJson(Map<String, dynamic> json) {
    try {
      final startedAt = DateTime.parse(json['startedAt'] as String).toUtc();
      final closeJson = json['close'];
      return Chapter(
        id: json['id'] as String,
        sentence: json['sentence'] as String,
        pathKey: json['pathKey'] as String,
        startedAt: startedAt,
        startOffsetMinutes: json['startOffsetMinutes'] as int,
        month1Key: _checkedMonthKey(json['month1Key'] as String),
        endMonthKey: _checkedMonthKey(json['endMonthKey'] as String),
        close: closeJson is Map<String, dynamic>
            ? ChapterClose.fromJson(closeJson)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  static DateTime _localDay(DateTime utc, int offsetMinutes) {
    final w = utc.toUtc().add(Duration(minutes: offsetMinutes));
    return DateTime.utc(w.year, w.month, w.day);
  }

  static int _daysInMonth(DateTime day) =>
      DateTime.utc(day.year, day.month + 1, 0).day;

  static String _monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  static DateTime _parseMonthKey(String key) {
    final parts = key.split('-');
    return DateTime.utc(int.parse(parts[0]), int.parse(parts[1]), 1);
  }

  static String _checkedMonthKey(String key) {
    final m = _parseMonthKey(key);
    if (m.month < 1 || m.month > 12 || _monthKey(m) != key) {
      throw FormatException('Bad month key', key);
    }
    return key;
  }
}
