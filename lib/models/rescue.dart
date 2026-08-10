import 'moment.dart';

/// How long someone has been away, and what the app should do about it (§4.6).
///
/// **Free forever.** Gap detection, the gentle notification after silence and
/// the reduced home screen are never behind the paywall, and the reasoning is
/// not generosity: someone who has disappeared for nine days is the person who
/// most needs help and is least likely to be a subscriber. Free catches you
/// when you fall; paid helps you fall less often.
///
/// Deliberately not the same computation as the drift warning. Drift speaks
/// *before* a gap, from a rolling average, and is paid. This speaks *after*
/// one, from a single date, and is free. Neither should ever be made to depend
/// on the other.
class Rescue {
  const Rescue({required this.quietDays});

  /// Whole days since the last moment.
  final int quietDays;

  /// Nothing counts as a gap until here.
  ///
  /// Well above the two-day threshold the grid uses for a "return". A return
  /// is worth marking in a month's history at two days; interrupting someone's
  /// screen is worth doing at five. Lally found missing a single opportunity
  /// did not materially affect habit formation — a Tuesday off is not a
  /// relapse, and treating it as one rebuilds the streak logic in reverse.
  static const int minQuietDays = 5;

  /// Past this, the reduced screen stops asking for one action and simply
  /// acknowledges the time. Someone three weeks away does not need a nudge,
  /// they need the app to not pretend nothing happened.
  static const int longAbsenceDays = 21;

  bool get isLongAbsence => quietDays >= longAbsenceDays;

  /// Null when the user is not away — the ordinary case, and the one where
  /// this must stay completely silent.
  static Rescue? read(List<Moment> moments, {DateTime? now}) {
    if (moments.isEmpty) return null;

    final today = _wallToday(now);
    var last = _wallDay(moments.first);
    for (final m in moments) {
      final day = _wallDay(m);
      if (day.isAfter(last)) last = day;
    }

    final quiet = today.difference(last).inDays;
    if (quiet < minQuietDays) return null;
    return Rescue(quietDays: quiet);
  }

  static DateTime _wallDay(Moment m) {
    final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
    return DateTime.utc(local.year, local.month, local.day);
  }

  static DateTime _wallToday(DateTime? now) {
    final local = now ?? DateTime.now();
    return DateTime.utc(local.year, local.month, local.day);
  }
}
