/// How the user says they are, one tap after the minute of breath.
///
/// A sensation scale, deliberately separate from `MomentMood`: that scale
/// records the *worth* of an action and was designed to have no bad end,
/// while this one records a state of the body before/after a pause. Reusing
/// or extending `MomentMood` would poison both datasets. "Tense" is
/// information here, not a verdict — the copy stays observational
/// ("still tense"), never graded.
enum PauseState {
  tense('tense'),
  neutral('neutral'),
  calm('calm');

  const PauseState(this.key);

  /// Stable storage key. Never change these — they are persisted, and
  /// mirrored into HealthKit State of Mind samples.
  final String key;

  static PauseState? fromKey(String? key) {
    if (key == null) return null;
    for (final state in PauseState.values) {
      if (state.key == key) return state;
    }
    return null;
  }
}

/// One completed 60-second pause. Early exits are never recorded — a record
/// of an abandoned pause would grade the leaving, and leaving is fine.
class PauseCheckIn {
  final String id;

  /// Always UTC.
  final DateTime completedAt;

  /// Null when the user skipped the tap. The pause still counts — the
  /// question is an offer, not a toll.
  final PauseState? state;

  /// Where the pause was opened from: 'home' | 'widget' | 'lockscreen' |
  /// 'notification'.
  final String entry;

  /// Hour (0-23) and weekday (1-7, Mon=1) on the user's own clock at the
  /// time of completion, plus the UTC offset that produced them. Stored
  /// rather than derived, same discipline as `Moment`: a UTC timestamp does
  /// not record what the user's clock said, and these values cannot be
  /// backfilled.
  final int localHour;
  final int localWeekday;
  final int tzOffsetMinutes;

  /// The completion instant on the user's own clock at the time, flagged UTC
  /// so wall-clock values compare against each other, never against the
  /// device's current zone.
  DateTime get localWallClock =>
      completedAt.add(Duration(minutes: tzOffsetMinutes));

  /// The user's calendar day of the completion, as a UTC-flagged date.
  DateTime get localDay {
    final w = localWallClock;
    return DateTime.utc(w.year, w.month, w.day);
  }

  const PauseCheckIn({
    required this.id,
    required this.completedAt,
    required this.entry,
    required this.localHour,
    required this.localWeekday,
    required this.tzOffsetMinutes,
    this.state,
  });

  /// Builds a check-in for *now* (or [at]), capturing the local-clock fields.
  /// Prefer this over the raw constructor at every call site.
  factory PauseCheckIn.create({
    required String entry,
    PauseState? state,
    DateTime? at,
  }) {
    final local = (at ?? DateTime.now()).toLocal();
    return PauseCheckIn(
      id: local.toUtc().toIso8601String(),
      completedAt: local.toUtc(),
      state: state,
      entry: entry,
      localHour: local.hour,
      localWeekday: local.weekday,
      tzOffsetMinutes: local.timeZoneOffset.inMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedAt': completedAt.toUtc().toIso8601String(),
        if (state != null) 'state': state!.key,
        'entry': entry,
        'localHour': localHour,
        'localWeekday': localWeekday,
        'tzOffsetMinutes': tzOffsetMinutes,
      };

  factory PauseCheckIn.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.parse(json['completedAt'] as String);
    final utc = parsed.isUtc ? parsed : parsed.toUtc();
    final local = utc.toLocal();
    return PauseCheckIn(
      id: json['id'] as String,
      completedAt: utc,
      state: PauseState.fromKey(json['state'] as String?),
      entry: json['entry'] as String? ?? 'home',
      localHour: json['localHour'] as int? ?? local.hour,
      localWeekday: json['localWeekday'] as int? ?? local.weekday,
      tzOffsetMinutes:
          json['tzOffsetMinutes'] as int? ?? local.timeZoneOffset.inMinutes,
    );
  }
}
