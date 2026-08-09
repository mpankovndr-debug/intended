import 'moment.dart';

/// Pre-aggregated view of every moment, recomputed whenever one is recorded.
///
/// Exists so the widget and the Month page don't rescan the whole collection
/// on every read (§10). Cheap to rebuild — at ~4 moments/week the list stays
/// small — so it is derived from scratch rather than incrementally patched,
/// which keeps it impossible to drift out of sync with the source data.
class MomentRollup {
  /// A quiet stretch only counts as a gap at two or more empty days.
  ///
  /// One missed day is not a gap. Lally et al. found missing a single
  /// opportunity did not materially affect habit formation, and treating it as
  /// a break would rebuild the streak logic this app exists to remove.
  static const int gapThresholdDays = 2;

  /// Counts keyed by local hour (0-23), local weekday (1-7, Mon=1),
  /// focus-area key, and mood key.
  final Map<int, int> byHour;
  final Map<int, int> byWeekday;
  final Map<String, int> byCategory;
  final Map<String, int> byMood;

  final int total;
  final DateTime? lastMomentAt;

  /// Quiet-day counts, oldest first — one entry per return. Length is the
  /// number of times the user came back; a shrinking series means the gaps
  /// are getting shorter (§4.3).
  final List<int> gapDays;

  const MomentRollup({
    required this.byHour,
    required this.byWeekday,
    required this.byCategory,
    required this.byMood,
    required this.total,
    required this.gapDays,
    this.lastMomentAt,
  });

  static const MomentRollup empty = MomentRollup(
    byHour: {},
    byWeekday: {},
    byCategory: {},
    byMood: {},
    total: 0,
    gapDays: [],
  );

  int get returnCount => gapDays.length;

  /// True when each successive gap is no longer than the one before it.
  bool get gapsAreShortening {
    if (gapDays.length < 2) return false;
    for (var i = 1; i < gapDays.length; i++) {
      if (gapDays[i] > gapDays[i - 1]) return false;
    }
    return true;
  }

  factory MomentRollup.from(List<Moment> moments) {
    if (moments.isEmpty) return empty;

    final byHour = <int, int>{};
    final byWeekday = <int, int>{};
    final byCategory = <String, int>{};
    final byMood = <String, int>{};
    final activeDays = <DateTime>{};
    DateTime? last;

    for (final m in moments) {
      byHour[m.localHour] = (byHour[m.localHour] ?? 0) + 1;
      byWeekday[m.localWeekday] = (byWeekday[m.localWeekday] ?? 0) + 1;
      if (m.category != null) {
        byCategory[m.category!] = (byCategory[m.category!] ?? 0) + 1;
      }
      if (m.mood != null) {
        byMood[m.mood!.key] = (byMood[m.mood!.key] ?? 0) + 1;
      }

      // Bucket by the user's own calendar day, reconstructed from the offset
      // recorded at completion — not the device's current zone.
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      activeDays.add(DateTime.utc(local.year, local.month, local.day));

      if (last == null || m.completedAt.isAfter(last)) last = m.completedAt;
    }

    final days = activeDays.toList()..sort();
    final gaps = <int>[];
    for (var i = 1; i < days.length; i++) {
      final quiet = days[i].difference(days[i - 1]).inDays - 1;
      if (quiet >= gapThresholdDays) gaps.add(quiet);
    }

    return MomentRollup(
      byHour: byHour,
      byWeekday: byWeekday,
      byCategory: byCategory,
      byMood: byMood,
      total: moments.length,
      gapDays: gaps,
      lastMomentAt: last,
    );
  }

  Map<String, dynamic> toJson() => {
    'byHour': byHour.map((k, v) => MapEntry(k.toString(), v)),
    'byWeekday': byWeekday.map((k, v) => MapEntry(k.toString(), v)),
    'byCategory': byCategory,
    'byMood': byMood,
    'total': total,
    'gapDays': gapDays,
    'lastMomentAt': lastMomentAt?.toUtc().toIso8601String(),
  };

  factory MomentRollup.fromJson(Map<String, dynamic> json) {
    Map<int, int> intKeyed(String field) {
      final raw = json[field] as Map<String, dynamic>? ?? const {};
      return raw.map((k, v) => MapEntry(int.parse(k), v as int));
    }

    Map<String, int> stringKeyed(String field) {
      final raw = json[field] as Map<String, dynamic>? ?? const {};
      return raw.map((k, v) => MapEntry(k, v as int));
    }

    final lastRaw = json['lastMomentAt'] as String?;
    return MomentRollup(
      byHour: intKeyed('byHour'),
      byWeekday: intKeyed('byWeekday'),
      byCategory: stringKeyed('byCategory'),
      byMood: stringKeyed('byMood'),
      total: json['total'] as int? ?? 0,
      gapDays: (json['gapDays'] as List<dynamic>? ?? const [])
          .map((e) => e as int)
          .toList(),
      lastMomentAt: lastRaw == null ? null : DateTime.parse(lastRaw).toUtc(),
    );
  }
}
