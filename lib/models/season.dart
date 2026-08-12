import '../models/moment.dart';

/// One of four readings of a month. No axis has a bad end (§4.4) — every pole
/// is a way of showing up, not a grade. "Bursts" is not worse than "Steady";
/// "Wandering" is not worse than "Focused".
enum SeasonAxis { rhythmOfDay, pacing, returning, spread }

/// The pole a month landed on, and how strongly.
class SeasonReading {
  const SeasonReading({
    required this.axis,
    required this.pole,
    required this.strength,
  });

  final SeasonAxis axis;

  /// Stable key for the winning pole. Persisted — never rename.
  final String pole;

  /// 0..1, distance from the middle of the axis. Used to pick the word: the
  /// axis a month leans on hardest is the one worth naming.
  final double strength;
}

/// A month's season. Recomputed monthly and **never a fixed identity** — the
/// copy is always "this month you've been", never "you are". A trait the app
/// assigns permanently would be a personality test; a reading that changes is
/// an observation.
class Season {
  const Season({
    required this.monthKey,
    required this.pole,
    required this.readings,
    required this.sampleSize,
    required this.computedAt,
  });

  /// "2026-08".
  final String monthKey;

  /// The winning pole across all axes — the season's word.
  final String pole;

  final List<SeasonReading> readings;
  final int sampleSize;
  final DateTime computedAt;

  /// Below this a month has not said anything yet, and claiming otherwise
  /// would be inventing a pattern from noise (§4.4).
  static const int minMoments = 10;

  /// Poles. Stable storage keys; the display words are localised separately.
  static const String morning = 'morning';
  static const String evening = 'evening';
  static const String steady = 'steady';
  static const String bursts = 'bursts';
  static const String returning = 'returning';
  static const String continuous = 'continuous';
  static const String focused = 'focused';
  static const String wandering = 'wandering';

  /// Shown before [minMoments] — a month still forming, with a count.
  static const String beginning = 'beginning';

  Map<String, dynamic> toJson() => {
        'monthKey': monthKey,
        'pole': pole,
        'sampleSize': sampleSize,
        'computedAt': computedAt.toUtc().toIso8601String(),
        'readings': [
          for (final r in readings)
            {'axis': r.axis.name, 'pole': r.pole, 'strength': r.strength},
        ],
      };

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        monthKey: json['monthKey'] as String,
        pole: json['pole'] as String,
        sampleSize: json['sampleSize'] as int,
        computedAt: DateTime.parse(json['computedAt'] as String).toUtc(),
        readings: [
          for (final r in (json['readings'] as List? ?? const []))
            SeasonReading(
              axis: SeasonAxis.values.firstWhere(
                (a) => a.name == (r as Map)['axis'],
                orElse: () => SeasonAxis.pacing,
              ),
              pole: (r as Map)['pole'] as String,
              strength: (r['strength'] as num).toDouble(),
            ),
        ],
      );

  /// Reads a month. Returns a [beginning] season below [minMoments].
  ///
  /// Every axis is computed from fields recorded at completion time —
  /// `localHour`, `localWeekday`, the stored offset — never re-derived from
  /// UTC, which would silently misread anyone who travelled mid-month.
  static Season read(String monthKey, List<Moment> moments) {
    if (moments.length < minMoments) {
      return Season(
        monthKey: monthKey,
        pole: beginning,
        readings: const [],
        sampleSize: moments.length,
        computedAt: DateTime.now().toUtc(),
      );
    }

    final readings = <SeasonReading>[
      _readRhythm(moments),
      _readPacing(moments),
      _readReturning(moments),
      _readSpread(moments),
    ];

    // Name the month after whichever axis it leans on hardest. A month that
    // is mildly everything gets the clearest of its mild leanings rather than
    // an average, which would be true of every month and describe none.
    final strongest =
        readings.reduce((a, b) => a.strength >= b.strength ? a : b);

    return Season(
      monthKey: monthKey,
      pole: strongest.pole,
      readings: readings,
      sampleSize: moments.length,
      computedAt: DateTime.now().toUtc(),
    );
  }

  /// Morning ↔ Evening, split at midday on the user's own clock.
  static SeasonReading _readRhythm(List<Moment> moments) {
    final morningCount =
        moments.where((m) => m.localHour >= 5 && m.localHour < 12).length;
    final share = morningCount / moments.length;
    return SeasonReading(
      axis: SeasonAxis.rhythmOfDay,
      pole: share >= 0.5 ? morning : evening,
      strength: (share - 0.5).abs() * 2,
    );
  }

  /// Steady ↔ Bursts — how evenly moments spread across the days they landed
  /// on. A month with four moments on each of five days is steady; one with
  /// sixteen on a single day and one each on four others is bursts.
  static SeasonReading _readPacing(List<Moment> moments) {
    final perDay = <DateTime, int>{};
    for (final m in moments) {
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      final day = DateTime.utc(local.year, local.month, local.day);
      perDay[day] = (perDay[day] ?? 0) + 1;
    }
    final counts = perDay.values.toList();
    final mean = moments.length / counts.length;
    final variance = counts
            .map((c) => (c - mean) * (c - mean))
            .reduce((a, b) => a + b) /
        counts.length;
    // Coefficient of variation: spread relative to the average, so a busy
    // month and a quiet one are judged on the same scale.
    final cv = mean == 0 ? 0.0 : (variance <= 0 ? 0.0 : _sqrt(variance) / mean);
    return SeasonReading(
      axis: SeasonAxis.pacing,
      pole: cv < 0.5 ? steady : bursts,
      strength: (cv - 0.5).abs().clamp(0.0, 1.0),
    );
  }

  /// Returning ↔ Continuous — did the month have quiet stretches and comebacks,
  /// or was it unbroken? Neither is better; returning is the one worth naming
  /// because it is the mechanic this app replaces streaks with (§4.3).
  static SeasonReading _readReturning(List<Moment> moments) {
    final days = <DateTime>{};
    for (final m in moments) {
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      days.add(DateTime.utc(local.year, local.month, local.day));
    }
    final sorted = days.toList()..sort();
    var gaps = 0;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays - 1 >= 2) gaps++;
    }
    return SeasonReading(
      axis: SeasonAxis.returning,
      pole: gaps > 0 ? returning : continuous,
      // A month with real comebacks outranks an unbroken one — the old
      // formula gave zero gaps 0.6 and one gap 0.3, which meant the user who
      // most embodied §4.3 was the least likely to be named for it (review
      // finding #8). Continuous keeps a solid-but-beatable 0.6; Returning
      // starts above it and grows with each return.
      strength:
          gaps == 0 ? 0.6 : (0.65 + 0.1 * (gaps - 1)).clamp(0.65, 0.95),
    );
  }

  /// Focused ↔ Wandering — how concentrated the month was in one focus area.
  static SeasonReading _readSpread(List<Moment> moments) {
    final counts = <String, int>{};
    for (final m in moments) {
      final key = m.category;
      if (key != null) counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      return const SeasonReading(
        axis: SeasonAxis.spread,
        pole: wandering,
        strength: 0.0,
      );
    }
    final top = counts.values.reduce((a, b) => a > b ? a : b);
    final share = top / moments.length;
    return SeasonReading(
      axis: SeasonAxis.spread,
      pole: share >= 0.6 ? focused : wandering,
      strength: (share - 0.6).abs().clamp(0.0, 1.0),
    );
  }

  static double _sqrt(double v) {
    var x = v;
    for (var i = 0; i < 20; i++) {
      x = 0.5 * (x + v / x);
    }
    return x;
  }
}
