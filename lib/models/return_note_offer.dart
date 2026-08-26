import 'moment.dart';
import 'rescue.dart';

/// When the home screen may offer to turn on the come-back note — the one
/// gentle notification promised by "never paywall the rescue" that a user
/// who declined notification permission can currently never receive.
///
/// Pure statics with no storage or context, like [LetterOfferPolicy]:
/// callers read prefs and the iOS permission status and pass plain values
/// in, so the whole policy is testable.
class ReturnNoteOffer {
  ReturnNoteOffer._();

  /// Unanswered appearances before the offer retires itself, matching the
  /// Health soft-ask: enough to survive a stray scroll-past, short of
  /// nagging.
  static const int maxOffers = 3;

  /// Prefs keys, owned here so the card and the tests agree on them.
  static const String answeredKey = 'return_note_offer_answered';
  static const String offersKey = 'return_note_offer_shows';
  static const String lastOfferDayKey = 'return_note_offer_last_day';
  static const String enabledKey = 'return_note_enabled';

  /// 'yyyy-MM-dd' — the per-day ratchet on the offer count, so reopening
  /// the app three times on one return day is one ignored offer, not three.
  static String dayKey(DateTime now) =>
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';

  /// True when today is a return worth speaking to: the newest moment
  /// landed today, and the nearest moment-day before it is at least
  /// [Rescue.minQuietDays] back. The same threshold as the rescue screen,
  /// so "a quiet stretch" means one thing everywhere.
  ///
  /// Days come from each moment's own recorded offset ([Moment.localDay]),
  /// never the device's current zone.
  static bool isReturnDay(List<Moment> moments, {DateTime? now}) {
    if (moments.length < 2) return false;

    final local = now ?? DateTime.now();
    final today = DateTime.utc(local.year, local.month, local.day);

    DateTime? latest;
    for (final m in moments) {
      final day = m.localDay;
      if (latest == null || day.isAfter(latest)) latest = day;
    }
    if (latest != today) return false;

    DateTime? previous;
    for (final m in moments) {
      final day = m.localDay;
      if (day == latest) continue;
      if (previous == null || day.isAfter(previous)) previous = day;
    }
    if (previous == null) return false;

    return latest!.difference(previous).inDays >= Rescue.minQuietDays;
  }

  /// Whether the card may render right now.
  ///
  /// [permissionGranted] is the iOS notification permission. When it is
  /// true the app can already reach this user, and anyone who then turned
  /// the Profile toggle off gave an answer this card must not re-ask —
  /// which is why the permission check alone excludes them: their
  /// permission is still granted.
  static bool shouldOffer({
    required bool returnedToday,
    required bool permissionGranted,
    required bool answered,
    required int priorOffers,
  }) {
    if (!returnedToday) return false;
    if (permissionGranted) return false;
    if (answered) return false;
    if (priorOffers >= maxOffers) return false;
    return true;
  }
}
