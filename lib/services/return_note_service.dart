import 'package:shared_preferences/shared_preferences.dart';

import '../models/moment.dart';
import '../models/return_note_offer.dart';
import 'notification_scheduler.dart';

/// Storage and input-gathering for the return-note offer. The rules live in
/// [ReturnNoteOffer]; this only reads prefs and the permission status and
/// hands them over.
class ReturnNoteService {
  ReturnNoteService._();

  /// Whether the user accepted the offer — the flag
  /// [NotificationScheduler.scheduleReturnNote] checks on every app open.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ReturnNoteOffer.enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ReturnNoteOffer.enabledKey, value);
  }

  /// True when the card should render on this open of the home screen.
  static Future<bool> shouldOffer(List<Moment> moments,
      {DateTime? now}) async {
    if (!ReturnNoteOffer.isReturnDay(moments, now: now)) return false;
    final prefs = await SharedPreferences.getInstance();
    return ReturnNoteOffer.shouldOffer(
      returnedToday: true,
      permissionGranted: await NotificationScheduler.permissionGranted(),
      answered: prefs.getBool(ReturnNoteOffer.answeredKey) ?? false,
      priorOffers: prefs.getInt(ReturnNoteOffer.offersKey) ?? 0,
    );
  }

  /// Counts one unanswered appearance, at most once per calendar day, so
  /// three ignored *returns* — not three opens of one afternoon — retire
  /// the offer for good.
  static Future<void> recordOffer({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = ReturnNoteOffer.dayKey(now ?? DateTime.now());
    if (prefs.getString(ReturnNoteOffer.lastOfferDayKey) == today) return;
    await prefs.setString(ReturnNoteOffer.lastOfferDayKey, today);
    final shown = prefs.getInt(ReturnNoteOffer.offersKey) ?? 0;
    await prefs.setInt(ReturnNoteOffer.offersKey, shown + 1);
  }

  /// Either button is a final answer — the card never returns.
  static Future<void> markAnswered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ReturnNoteOffer.answeredKey, true);
  }
}
