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

  /// Which axis wins an exact tie. Returning first because coming back is the
  /// reading this app exists to make (§4.3); spread last because "one area or
  /// several" is the least a month is about.
  static const List<SeasonAxis> axisPriority = [
    SeasonAxis.returning,
    SeasonAxis.rhythmOfDay,
    SeasonAxis.pacing,
    SeasonAxis.spread,
  ];

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
    //
    // All four strengths now span the same 0..1, which is what makes this
    // comparison mean anything: the four formulas used to have four different
    // ranges, and the axis with the highest ceiling won regardless of what
    // the month actually did.
    //
    // Ties break on [axisPriority], explicitly. Leaving it to whichever way
    // `reduce` happened to fold would make the word depend on list order —
    // the same class of bug as an unstable sort in the plan's ranking.
    final strongest = readings.reduce((a, b) {
      if (a.strength != b.strength) return a.strength > b.strength ? a : b;
      return axisPriority.indexOf(a.axis) <= axisPriority.indexOf(b.axis)
          ? a
          : b;
    });

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

  /// Two weeks of runway before "most days" can mean anything. Without it,
  /// everything logged on a single day divides by one and reads as perfect
  /// constancy.
  static const int minHorizonDays = 14;

  /// Returns needed for a full-strength [returning]. One comeback is an
  /// incident; three is a month whose shape *is* coming back.
  static const int returnsForFullStrength = 3;

  /// A quiet stretch this long or longer is a gap, not a day off.
  static const int quietDaysForGap = 2;

  /// Share of moments in one area at or above which a month reads [focused].
  static const double focusedShare = 0.6;

  /// Steady ↔ Bursts — how much of the month you were actually present for.
  ///
  /// This used to be the coefficient of variation of moments-per-day across
  /// *active days only*, and empty days never entered the arithmetic. A month
  /// touched on three days and a month touched on twelve both scored 0.5 —
  /// the maximum — so the axis could not tell them apart, and "a little, most
  /// days" asserted a frequency nothing had computed.
  static SeasonReading _readPacing(List<Moment> moments) {
    final days = _activeDays(moments);
    final lastDay = days.map((d) => d.day).reduce((a, b) => a > b ? a : b);
    final horizon = lastDay < minHorizonDays ? minHorizonDays : lastDay;
    final density = days.length / horizon;
    return SeasonReading(
      axis: SeasonAxis.pacing,
      pole: density >= 0.5 ? steady : bursts,
      // Each side spans its own half of the axis, so both poles can reach 1.0.
      strength: ((density - 0.5).abs() / 0.5).clamp(0.0, 1.0),
    );
  }

  /// Returning ↔ Continuous — did the month have quiet stretches and comebacks,
  /// or was it unbroken? Neither is better; returning is the one worth naming
  /// because it is the mechanic this app replaces streaks with (§4.3).
  static SeasonReading _readReturning(List<Moment> moments) {
    final sorted = _activeDays(moments).toList()..sort();
    var gaps = 0;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays - 1 >= quietDaysForGap) {
        gaps++;
      }
    }

    if (gaps > 0) {
      return SeasonReading(
        axis: SeasonAxis.returning,
        pole: returning,
        strength: (gaps / returnsForFullStrength).clamp(0.0, 1.0),
      );
    }

    // Unbroken — but a thread across four days is not the same claim as one
    // across twenty-six. Review finding #8 was right that Returning must be
    // able to outrank Continuous; the fix for it was a flat 0.6 floor here,
    // which silently put three other words out of reach for good. The reach
    // now comes from measuring the thread instead of propping it up.
    final lastDay = sorted.last.day;
    final horizon = lastDay < minHorizonDays ? minHorizonDays : lastDay;
    final span = sorted.last.difference(sorted.first).inDays + 1;
    return SeasonReading(
      axis: SeasonAxis.returning,
      pole: continuous,
      strength: (span / horizon).clamp(0.0, 1.0),
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
    // Normalised per side. The old `(share - 0.6).abs()` capped Focused at
    // 0.4 — a share cannot exceed 1.0 — so Focused could never outrank an
    // axis with a 0.6 floor, and never once won.
    return SeasonReading(
      axis: SeasonAxis.spread,
      pole: share >= focusedShare ? focused : wandering,
      strength: share >= focusedShare
          ? ((share - focusedShare) / (1 - focusedShare)).clamp(0.0, 1.0)
          : ((focusedShare - share) / focusedShare).clamp(0.0, 1.0),
    );
  }

  /// The distinct days moments landed on, read from each moment's own recorded
  /// offset — never the device's current zone.
  static Set<DateTime> _activeDays(List<Moment> moments) {
    final days = <DateTime>{};
    for (final m in moments) {
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      days.add(DateTime.utc(local.year, local.month, local.day));
    }
    return days;
  }
}
