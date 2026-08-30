/// One page of the gratitude journal: what you were thankful for, split by
/// direction — toward yourself, and toward other people.
///
/// Deliberately not a [Moment] with a note. Three reasons, in order of how
/// much they would have cost:
///
///  1. A moment carries a focus-area category, and a page a night would shift
///     the month's colour mix and the season computed from it. Seasons are
///     immutable once a month closes, so that damage could never be undone.
///  2. `Moment.note` is one 280-character string. Ten lines do not fit, and
///     widening it would change the meaning of every note already stored.
///  3. Moments trim at 1000. At three or four a day that is under a year;
///     these are meant to be read back years later, and at one page a day
///     the same cap holds nearly three.
///
/// Same local-clock discipline as [Moment] and [PauseCheckIn]: the wall clock
/// is recorded at write time and never derived from the device's zone later.
class GratitudeEntry {
  /// Longest single line kept. Lines, not paragraphs — the page is a list of
  /// small specific things, and a wall of text is a different exercise.
  static const int maxLineLength = 200;

  /// Most lines kept per side. Above the "five each is plenty" the page
  /// suggests, so the guidance is never a wall — but bounded, because the
  /// cap belongs at the *add* path where it can be said out loud, never at
  /// render where a list silently loses its tail (§10).
  static const int maxLinesPerSide = 10;

  final String id;

  /// Always UTC.
  final DateTime completedAt;

  /// Thanks directed at yourself, in the order they were written.
  final List<String> forSelf;

  /// Thanks directed at other people, in the order they were written.
  final List<String> forOthers;

  /// Hour (0-23) and weekday (1-7, Mon=1) on the user's own clock at the time
  /// of writing, plus the UTC offset that produced them. Stored rather than
  /// derived: a UTC timestamp does not record what the user's clock said, and
  /// these cannot be backfilled afterwards.
  final int localHour;
  final int localWeekday;
  final int tzOffsetMinutes;

  /// The writing instant on the user's own clock at the time, rebuilt from
  /// the offset recorded with the entry — flagged UTC so wall-clock values
  /// compare against each other, never against device-local times.
  DateTime get localWallClock =>
      completedAt.add(Duration(minutes: tzOffsetMinutes));

  /// The user's calendar day of the entry, as a UTC-flagged date.
  DateTime get localDay {
    final w = localWallClock;
    return DateTime.utc(w.year, w.month, w.day);
  }

  /// True when there is nothing on the page. Never stored — an empty page is
  /// not a record of anything, and writing one would put a dated blank in the
  /// archive that reads as a night you failed at.
  bool get isEmpty => forSelf.isEmpty && forOthers.isEmpty;

  /// Every line, both directions, for callers that only need the text.
  List<String> get allLines => [...forSelf, ...forOthers];

  const GratitudeEntry({
    required this.id,
    required this.completedAt,
    required this.forSelf,
    required this.forOthers,
    required this.localHour,
    required this.localWeekday,
    required this.tzOffsetMinutes,
  });

  /// Builds an entry for *now* (or [at]), capturing the local-clock fields.
  /// Prefer this over the raw constructor at every call site.
  factory GratitudeEntry.create({
    required List<String> forSelf,
    required List<String> forOthers,
    DateTime? at,
  }) {
    final local = (at ?? DateTime.now()).toLocal();
    return GratitudeEntry(
      id: local.toUtc().toIso8601String(),
      completedAt: local.toUtc(),
      forSelf: _clean(forSelf),
      forOthers: _clean(forOthers),
      localHour: local.hour,
      localWeekday: local.weekday,
      tzOffsetMinutes: local.timeZoneOffset.inMinutes,
    );
  }

  /// Same page, new text. Keeps the original instant and its wall clock: the
  /// page belongs to the evening it was started, not to the moment a line was
  /// added to it.
  GratitudeEntry copyWith({
    List<String>? forSelf,
    List<String>? forOthers,
  }) =>
      GratitudeEntry(
        id: id,
        completedAt: completedAt,
        forSelf: forSelf == null ? this.forSelf : _clean(forSelf),
        forOthers: forOthers == null ? this.forOthers : _clean(forOthers),
        localHour: localHour,
        localWeekday: localWeekday,
        tzOffsetMinutes: tzOffsetMinutes,
      );

  /// Trims, drops blanks, clamps each line and caps the list. Blank lines are
  /// dropped rather than kept as empties: the page grows by "add another", so
  /// an untouched new line is an affordance the writer did not use, not a
  /// thing they left undone.
  static List<String> _clean(List<String> lines) {
    final out = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      out.add(trimmed.length > maxLineLength
          ? trimmed.substring(0, maxLineLength)
          : trimmed);
      if (out.length == maxLinesPerSide) break;
    }
    return out;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedAt': completedAt.toUtc().toIso8601String(),
        'forSelf': forSelf,
        'forOthers': forOthers,
        'localHour': localHour,
        'localWeekday': localWeekday,
        'tzOffsetMinutes': tzOffsetMinutes,
      };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.parse(json['completedAt'] as String);
    final utc = parsed.isUtc ? parsed : parsed.toUtc();
    final local = utc.toLocal();
    return GratitudeEntry(
      id: json['id'] as String,
      completedAt: utc,
      forSelf: _readLines(json['forSelf']),
      forOthers: _readLines(json['forOthers']),
      localHour: json['localHour'] as int? ?? local.hour,
      localWeekday: json['localWeekday'] as int? ?? local.weekday,
      tzOffsetMinutes:
          json['tzOffsetMinutes'] as int? ?? local.timeZoneOffset.inMinutes,
    );
  }

  static List<String> _readLines(Object? raw) {
    if (raw is! List) return const [];
    return _clean([for (final e in raw) if (e is String) e]);
  }
}
