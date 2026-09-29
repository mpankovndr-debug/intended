/// When the letter paywall may offer itself — the app's one *proactive*
/// paywall moment, so every rule here exists to keep it from becoming a
/// nag: it speaks only when the letter it sells is already real.
///
/// Pure statics with no storage or context, so the whole policy is
/// testable; callers read prefs and pass plain values in.
class LetterOfferPolicy {
  LetterOfferPolicy._();

  /// Quiet for the first three days of life; the offer may fire from the
  /// fourth. Before that the grid hasn't had a chance to mean anything,
  /// and a paywall before affection is just a toll booth.
  static const int minDaysOfLife = 3;

  /// Key under which the caller remembers the last month it offered.
  static const String lastOfferedPrefsKey = 'letter_offer_last_month';

  /// 'yyyy-MM', the once-per-month ratchet.
  static String monthKey(DateTime now) =>
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}';

  static bool shouldOffer({
    required bool hasSubscription,
    required bool letterExists,
    required DateTime? firstLaunch,
    required DateTime now,
    required String? lastOfferedMonth,
  }) {
    if (hasSubscription) return false;
    // The claim "your letter is ready" must be computed, never promised.
    if (!letterExists) return false;
    // Unknown age reads as day zero: stay quiet rather than guess.
    if (firstLaunch == null) return false;
    if (now.difference(firstLaunch).inDays < minDaysOfLife) return false;
    if (lastOfferedMonth == monthKey(now)) return false;
    return true;
  }
}
