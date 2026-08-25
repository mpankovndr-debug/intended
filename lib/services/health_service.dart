import 'package:shared_preferences/shared_preferences.dart';

import '../models/pause_check_in.dart';
import 'analytics_service.dart';
import 'pause_native.dart';

/// HealthKit is written to, never read, in this release. All writes are
/// silent no-ops when Health is unavailable or unauthorized — the pause
/// never depends on them, and no failure here may surface in the UI.
class HealthService {
  HealthService._();

  static const _answeredKey = 'pause_health_prompted';
  static const _offersKey = 'pause_health_offers';
  static const _watchLoggedKey = 'watch_paired_logged';

  /// How many times the sheet may appear without being answered before the
  /// ask retires itself. Three is enough to survive a stray tap; more would
  /// be nagging, which this app does not do.
  static const _maxOffers = 3;

  /// True when the one-time soft-ask should be shown: first completed pause,
  /// on hardware where Health exists. Asked contextually there, never in
  /// onboarding — someone who just finished a minute of breath knows exactly
  /// what "save this to Health" means.
  static Future<bool> shouldOfferSave() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_answeredKey) ?? false) return false;
    if ((prefs.getInt(_offersKey) ?? 0) >= _maxOffers) return false;
    return PauseNative.healthIsAvailable();
  }

  /// Records that the sheet reached the screen. Written *before* it appears,
  /// so being killed mid-sheet still counts and the ask can never loop.
  static Future<void> markOffered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_offersKey, (prefs.getInt(_offersKey) ?? 0) + 1);
  }

  /// The user chose — "Save to Health" or an explicit "Not now". Either way
  /// the question is settled and never comes back.
  ///
  /// *Scar:* this was once written before the sheet appeared, so a tap on the
  /// barrier — no decision at all — retired the feature permanently. There is
  /// no way back from that: with no `requestAuthorization` call the app never
  /// appears in Health's own Sources list either. A dismissal is not an
  /// answer; only this method closes the door.
  static Future<void> markAnswered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_answeredKey, true);
  }

  /// Mirrors one completed pause into Health: the real interval as a mindful
  /// session, and the chosen state (if any) as a State of Mind sample on
  /// iOS 18+. Only completed pauses are written — an invented duration would
  /// be fabricated health data, the Health equivalent of stating a finding
  /// that was never computed.
  static Future<void> saveCompletedPause({
    required DateTime start,
    required DateTime end,
    PauseState? state,
  }) async {
    await PauseNative.healthWriteMindful(start, end);
    if (state != null) {
      await PauseNative.healthWriteStateOfMind(state.key, end);
    }
  }

  /// One-time Watch-pairing measurement — device info, not health data, so
  /// Firebase is fine. This is the number the sleep feature's build decision
  /// waits on. The native side answers null on iPad, so iPads never dilute
  /// the denominator.
  static Future<void> logWatchPairedOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_watchLoggedKey) ?? false) return;
    final paired = await PauseNative.watchIsPaired();
    if (paired == null) return;
    AnalyticsService.logWatchPaired(paired);
    await prefs.setBool(_watchLoggedKey, true);
  }
}
