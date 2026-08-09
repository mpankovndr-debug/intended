/// How an action landed, captured as one tap at completion time.
///
/// Deliberately not a sensation scale ("heavy / okay / light"): that breaks on
/// non-somatic actions and hides a judgement, so hard-but-valuable work gets
/// labelled negatively. This scale has no bad end and captures *worth* rather
/// than pleasantness, which is the more useful correlation for later insights.
enum MomentMood {
  gladIDid('glad_i_did'),
  neutral('neutral'),
  tookEffort('took_effort');

  const MomentMood(this.key);

  /// Stable storage key. Never change these — they are persisted.
  final String key;

  static MomentMood? fromKey(String? key) {
    if (key == null) return null;
    for (final mood in MomentMood.values) {
      if (mood.key == key) return mood;
    }
    return null;
  }
}

class Moment {
  /// Maximum stored note length. Notes are for the user's own recall, not
  /// for analysis — see the handoff doc, §10.
  static const int maxNoteLength = 280;

  final String id;
  final String habitName;
  final String habitEmoji;

  /// Always UTC.
  final DateTime completedAt;

  /// Focus-area key this action belongs to (health, mood, self_care, …).
  /// Null when the habit has no known category.
  final String? category;

  /// Null when the user skipped the mood tap.
  final MomentMood? mood;

  /// Optional free text, capped at [maxNoteLength].
  final String? note;

  /// Hour (0-23) and weekday (1-7, Mon=1) on the user's own clock at the
  /// time of completion, plus the UTC offset that produced them.
  ///
  /// Stored rather than derived, because a UTC timestamp does not record what
  /// the user's clock said. Deriving at read time silently reports the wrong
  /// hour the moment someone travels, and these values cannot be recovered
  /// afterwards — so every moment records them at creation.
  final int localHour;
  final int localWeekday;
  final int tzOffsetMinutes;

  const Moment({
    required this.id,
    required this.habitName,
    required this.habitEmoji,
    required this.completedAt,
    required this.localHour,
    required this.localWeekday,
    required this.tzOffsetMinutes,
    this.category,
    this.mood,
    this.note,
  });

  /// Builds a moment for *now* (or [at]), capturing the local-clock fields.
  ///
  /// Prefer this over the raw constructor at every call site — it is the only
  /// place that knows how to derive the local fields correctly.
  factory Moment.create({
    required String habitName,
    String habitEmoji = '✦',
    String? category,
    MomentMood? mood,
    String? note,
    DateTime? at,
    String? id,
  }) {
    final local = (at ?? DateTime.now()).toLocal();
    return Moment(
      // Widget-synced completions share a timestamp across habits on the same
      // day, so they pass their own id to stay distinct.
      id: id ?? local.toUtc().toIso8601String(),
      habitName: habitName,
      habitEmoji: habitEmoji,
      completedAt: local.toUtc(),
      category: category,
      mood: mood,
      note: _clampNote(note),
      localHour: local.hour,
      localWeekday: local.weekday,
      tzOffsetMinutes: local.timeZoneOffset.inMinutes,
    );
  }

  Moment copyWith({
    String? category,
    MomentMood? mood,
    String? note,
    bool clearNote = false,
  }) {
    return Moment(
      id: id,
      habitName: habitName,
      habitEmoji: habitEmoji,
      completedAt: completedAt,
      category: category ?? this.category,
      mood: mood ?? this.mood,
      note: clearNote ? null : _clampNote(note) ?? this.note,
      localHour: localHour,
      localWeekday: localWeekday,
      tzOffsetMinutes: tzOffsetMinutes,
    );
  }

  static String? _clampNote(String? note) {
    if (note == null) return null;
    final trimmed = note.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length <= maxNoteLength
        ? trimmed
        : trimmed.substring(0, maxNoteLength);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitName': habitName,
    'habitEmoji': habitEmoji,
    'completedAt': completedAt.toUtc().toIso8601String(),
    if (category != null) 'category': category,
    if (mood != null) 'mood': mood!.key,
    if (note != null) 'note': note,
    'localHour': localHour,
    'localWeekday': localWeekday,
    'tzOffsetMinutes': tzOffsetMinutes,
  };

  factory Moment.fromJson(Map<String, dynamic> json) {
    final raw = json['completedAt'] as String;
    final parsed = DateTime.parse(raw);
    // New data ends with 'Z' (UTC). Old data has no offset → parsed as local.
    // Normalize everything to UTC.
    final utc = parsed.isUtc ? parsed : parsed.toUtc();

    // Moments recorded before the local-clock fields existed fall back to the
    // device's *current* zone. That is wrong for anyone who has since moved,
    // and unfixable — the original offset was never stored. Accepted as a
    // one-off cost for pre-existing data only.
    final local = utc.toLocal();

    return Moment(
      id: json['id'] as String,
      habitName: json['habitName'] as String,
      habitEmoji: json['habitEmoji'] as String,
      completedAt: utc,
      category: json['category'] as String?,
      mood: MomentMood.fromKey(json['mood'] as String?),
      note: json['note'] as String?,
      localHour: json['localHour'] as int? ?? local.hour,
      localWeekday: json['localWeekday'] as int? ?? local.weekday,
      tzOffsetMinutes: json['tzOffsetMinutes'] as int? ??
          local.timeZoneOffset.inMinutes,
    );
  }
}
