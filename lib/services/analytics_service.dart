import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart'
    show PurchasesErrorCode, PurchasesErrorHelper;
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ── Launch-decision metrics ───────────────────────────────────

  /// First-and-repeated use of the grid's legend filter. If this stays near
  /// zero, the inline caption wasn't enough and the chips need a louder cue.
  static Future<void> logGridFilterUsed() async {
    try {
      await _analytics.logEvent(name: 'grid_filter_used');
    } catch (_) {}
  }


  /// The one number the paid tier lives or dies on: whether people take the
  /// mood tap or skip it. The letter's mood line, all of what-lifts-you and
  /// the plan's texture starve on skips — this event is how we find out
  /// before month four does.
  static Future<void> logMoodResponse(String? moodKey) async {
    try {
      await _analytics.logEvent(
        name: 'mood_response',
        parameters: {'mood': moodKey ?? 'skipped'},
      );
    } catch (_) {}
  }

  /// §4.1's own test, finally wired: intention-as-header was the least
  /// evidence-backed decision in the doc, and it asked to be graded on Day-7
  /// retention. Segmenting Firebase's retention cohorts by this property is
  /// what grades it.
  static Future<void> setIntentionPath(String pathKey) async {
    try {
      await _analytics.setUserProperty(
        name: 'intention_path',
        value: pathKey,
      );
    } catch (_) {}
  }

  /// Someone redirected their whole practice — the sharpest available signal
  /// that §4.1's framing is real to them. Nobody changes decoration.
  ///
  /// [daysOnPrevious] is the half that matters: a change on day 2 is someone
  /// still shopping, a change on day 60 is the intention having drifted out
  /// of their life and them noticing. The first tells you onboarding picked
  /// wrong; the second tells you the app needs to ask.
  static Future<void> logIntentionChanged({
    required String from,
    required String to,
    required int daysOnPrevious,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'intention_changed',
        parameters: {
          'from_path': from,
          'to_path': to,
          'days_on_previous': daysOnPrevious,
        },
      );
    } catch (_) {}
  }

  // ── Screen Views ──────────────────────────────────────────────

  static void logScreenView(String screenName) {
    _analytics.logScreenView(screenName: screenName);
  }

  // ── Onboarding Funnel ─────────────────────────────────────────

  static void logOnboardingStarted() {
    _analytics.logEvent(name: 'onboarding_started');
  }

  static void logOnboardingStepCompleted(String stepName) {
    _analytics.logEvent(
      name: 'onboarding_step_completed',
      parameters: {'step_name': stepName},
    );
  }

  static void logOnboardingCompleted() {
    _analytics.logEvent(name: 'onboarding_completed');
  }

  // ── Habit Events ──────────────────────────────────────────────

  static void logHabitCompleted(String habitName) {
    _analytics.logEvent(
      name: 'habit_completed',
      parameters: {'habit_name': habitName},
    );
  }

  static void logCustomHabitCreated(String habitName) {
    _analytics.logEvent(
      name: 'custom_habit_created',
      parameters: {'habit_name': habitName},
    );
  }

  static void logCustomHabitRemoved() {
    _analytics.logEvent(name: 'custom_habit_removed');
  }

  static void logHabitSwapped() {
    _analytics.logEvent(name: 'habit_swapped');
  }

  static void logHabitSwapLimitReached() {
    _analytics.logEvent(name: 'habit_swap_limit_reached');
  }

  static void logHabitRefreshed() {
    _analytics.logEvent(name: 'habit_refreshed');
  }

  static void logHabitRefreshLimitReached() {
    _analytics.logEvent(name: 'habit_refresh_limit_reached');
  }

  static void logHabitPinned() {
    _analytics.logEvent(name: 'habit_pinned');
  }

  static void logHabitUnpinned() {
    _analytics.logEvent(name: 'habit_unpinned');
  }

  // ── Paywall & Monetization ────────────────────────────────────

  static void logPaywallShown(String source) {
    _analytics.logEvent(
      name: 'paywall_shown',
      parameters: {'source': source},
    );
  }

  static void logPaywallDismissed(String source) {
    _analytics.logEvent(
      name: 'paywall_dismissed',
      parameters: {'source': source},
    );
  }

  static void logPurchaseStarted(String plan) {
    _analytics.logEvent(
      name: 'purchase_started',
      parameters: {'plan': plan},
    );
  }

  static void logPurchaseCompleted(String plan) {
    _analytics.logEvent(
      name: 'purchase_completed',
      parameters: {'plan': plan},
    );
  }

  static void logPurchaseCancelled() {
    _analytics.logEvent(name: 'purchase_cancelled');
  }

  /// A purchase the store refused. [error] is whatever the SDK threw — a
  /// PlatformException for every RevenueCat failure — and becomes the
  /// `error_code` / `error_message` pair, so the dashboard can tell a
  /// declined card from a StoreKit outage from an Apple ID that can't buy.
  static void logPurchaseFailed(Object error) {
    try {
      _analytics.logEvent(
        name: 'purchase_failed',
        parameters: purchaseErrorParams(error),
      );
    } catch (_) {}
  }

  /// The store returned without an error and the entitlement stayed off.
  /// Same event as [logPurchaseFailed], since the user was charged, with
  /// `error_code` set to `entitlementMissing` — a RevenueCat dashboard
  /// problem, not a store one.
  static void logPurchaseEntitlementMissing() {
    try {
      _analytics.logEvent(
        name: 'purchase_failed',
        parameters: {
          errorCodeParam: 'entitlementMissing',
          errorMessageParam:
              'purchase returned without an error; entitlement inactive',
        },
      );
    } catch (_) {}
  }

  /// A purchase that could not even start — no current offering, no package
  /// for the plan, or an SDK that never configured — as opposed to one the
  /// user closed. [stage] is `load` when a paywall opened without a usable
  /// offering and `tap` when the purchase button was pressed anyway. Its own
  /// event on purpose: these used to be logged as purchase_cancelled, which
  /// made a broken button look like disinterest.
  ///
  /// [error] is the exception behind the reason when there is one — the
  /// failed `configure` or `getOfferings` call — and is null for a store
  /// that answered with nothing to sell.
  static void logPurchaseUnavailable(
    String reason, {
    required String stage,
    Object? error,
  }) {
    try {
      _analytics.logEvent(
        name: 'purchase_unavailable',
        parameters: {
          'reason': reason,
          'stage': stage,
          ...purchaseErrorParams(error),
        },
      );
    } catch (_) {}
  }

  // ── Purchase error detail ─────────────────────────────────────

  static const errorCodeParam = 'error_code';
  static const errorMessageParam = 'error_message';

  /// GA4 truncates event parameter values past this many characters.
  static const errorMessageMaxLength = 100;

  /// The `error_code` / `error_message` pair for a purchase event.
  ///
  /// A PlatformException is what the RevenueCat plugin throws for every
  /// store failure: its `code` is the PurchasesErrorCode index and its
  /// `details` carry the StoreKit text under `underlyingErrorMessage`. The
  /// code becomes the enum's name (`purchaseNotAllowedError`,
  /// `storeProblemError`, `paymentPendingError`…); the message prefers the
  /// StoreKit text, falls back to RevenueCat's, and is cut to GA4's limit.
  /// Null — no error, just nothing to sell — reads `none` for both.
  @visibleForTesting
  static Map<String, Object> purchaseErrorParams(Object? error) {
    if (error == null) {
      return {errorCodeParam: 'none', errorMessageParam: 'none'};
    }
    if (error is PlatformException) {
      return {
        errorCodeParam: _purchasesErrorCode(error).name,
        errorMessageParam: _truncate(_purchasesErrorMessage(error)),
      };
    }
    return {
      errorCodeParam: PurchasesErrorCode.unknownError.name,
      errorMessageParam: _truncate(error.toString()),
    };
  }

  static PurchasesErrorCode _purchasesErrorCode(PlatformException e) {
    try {
      return PurchasesErrorHelper.getErrorCode(e);
    } catch (_) {
      // A non-numeric or out-of-range code is nothing the helper can map.
      return PurchasesErrorCode.unknownError;
    }
  }

  static String _purchasesErrorMessage(PlatformException e) {
    final details = e.details;
    if (details is Map) {
      final underlying = details['underlyingErrorMessage'];
      if (underlying is String && underlying.trim().isNotEmpty) {
        return underlying.trim();
      }
    }
    final message = e.message?.trim();
    if (message != null && message.isNotEmpty) return message;
    return e.code;
  }

  static String _truncate(String s) => s.length <= errorMessageMaxLength
      ? s
      : s.substring(0, errorMessageMaxLength);

  static void logRestoreStarted() {
    _analytics.logEvent(name: 'restore_started');
  }

  static void logRestoreCompleted() {
    _analytics.logEvent(name: 'restore_completed');
  }

  // ── Engagement ────────────────────────────────────────────────

  static void logDailyReminderToggled(bool enabled) {
    _analytics.logEvent(
      name: 'daily_reminder_toggled',
      parameters: {'enabled': enabled.toString()},
    );
  }

  static void logReminderTimeChanged() {
    _analytics.logEvent(name: 'reminder_time_changed');
  }

  static void logThemeChanged(String themeName) {
    _analytics.logEvent(
      name: 'theme_changed',
      parameters: {'theme_name': themeName},
    );
  }

  static void logFocusAreasChanged(List<String> areas) {
    _analytics.logEvent(
      name: 'focus_areas_changed',
      parameters: {'areas': areas.join(',')},
    );
  }

  static void logFocusAreaChangeLimitShown() {
    _analytics.logEvent(name: 'focus_area_change_limit_shown');
  }

  static void logProfileNameEdited() {
    _analytics.logEvent(name: 'profile_name_edited');
  }

  // ── Reach & channels ──────────────────────────────────────────

  /// [kind] is 'daily' | 'weekly' | 'monthly_letter' | 'pause_action'.
  /// Tap-through is the
  /// only signal notifications earn their place with; the local counter in
  /// AppUsageService can't segment by kind.
  static void logNotificationOpened(String kind) {
    _analytics.logEvent(
      name: 'notification_opened',
      parameters: {'kind': kind},
    );
  }

  /// [status] is ShareResult.status.name — success / dismissed /
  /// unavailable. Opening the share sheet and actually posting are
  /// different funnels; only the OS result separates them.
  static void logShareResult(String surface, String status) {
    _analytics.logEvent(
      name: 'share_result',
      parameters: {'surface': surface, 'status': status},
    );
  }

  /// Completions that arrived from the home-screen widget rather than the
  /// app — the widget's whole value, invisible to habit_completed.
  static void logWidgetCompletionsSynced(int count) {
    _analytics.logEvent(
      name: 'widget_completions_synced',
      parameters: {'count': count},
    );
  }

  // ── Pause ─────────────────────────────────────────────────────

  /// [entry] is 'home' | 'widget' | 'lockscreen' | 'notification' — which
  /// door people actually use decides where the entry points live long-term.
  static void logPauseStarted(String entry) {
    try {
      _analytics.logEvent(
        name: 'pause_started',
        parameters: {'entry': entry},
      );
    } catch (_) {}
  }

  static void logPauseCompleted(String entry) {
    try {
      _analytics.logEvent(
        name: 'pause_completed',
        parameters: {'entry': entry},
      );
    } catch (_) {}
  }

  /// Leaving early is fine by design; this exists to notice if *everyone*
  /// leaves at second 20, which would mean the minute is mis-shaped.
  static void logPauseLeftEarly(int secondsIn) {
    try {
      _analytics.logEvent(
        name: 'pause_left_early',
        parameters: {'seconds_in': secondsIn},
      );
    } catch (_) {}
  }

  /// [state] is a PauseState.key or 'skipped'. App-native data, same class
  /// as mood_response — never HealthKit-derived. Nothing read from Health
  /// may ever reach analytics, directly or by implication.
  static void logPauseCheckIn(String state) {
    try {
      _analytics.logEvent(
        name: 'pause_checkin',
        parameters: {'state': state},
      );
    } catch (_) {}
  }

  /// Outcome of the contextual Health soft-ask (our sheet, not the system
  /// permission dialog — that one's answer stays inside HealthKit).
  /// [outcome] is 'accepted' | 'declined' | 'dismissed'. A dismissal is kept
  /// apart from a refusal so the accept rate is measured against real answers
  /// only — the same reason iPads stay out of the Watch-pairing denominator.
  static void logPauseHealthPrompt(String outcome) {
    try {
      _analytics.logEvent(
        name: 'pause_health_prompt',
        parameters: {'outcome': outcome},
      );
    } catch (_) {}
  }

  /// One-time, iPhone-only: whether an Apple Watch is paired. Device info,
  /// not health data. This single number decides whether sleep-softening is
  /// worth building.
  static void logWatchPaired(bool paired) {
    try {
      _analytics.logEvent(
        name: 'watch_paired',
        parameters: {'paired': paired.toString()},
      );
    } catch (_) {}
  }

  /// The return-note offer card: 'shown', 'accepted', or 'declined'.
  /// Acceptance rate is the number that decides whether the card earns
  /// its place on the return day's screen.
  static void logReturnNoteOffer(String outcome) {
    try {
      _analytics.logEvent(
        name: 'return_note_offer',
        parameters: {'outcome': outcome},
      );
    } catch (_) {}
  }

  // ── Tester flag ───────────────────────────────────────────────

  /// Shared-preferences key behind the hidden toggle in Profile.
  static const testerPrefKey = 'is_tester';

  /// Debug builds are always testers; release builds honour the toggle.
  @visibleForTesting
  static bool resolveTester({required bool debug, required bool? stored}) =>
      debug || (stored ?? false);

  /// Sets the `is_tester` user property from the build mode and the stored
  /// toggle. Called at launch, before the first event, and after each
  /// toggle. Returns the value applied.
  static Future<bool> applyTesterFlag() async {
    var tester = kDebugMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      tester = resolveTester(
        debug: kDebugMode,
        stored: prefs.getBool(testerPrefKey),
      );
      await _analytics.setUserProperty(
        name: 'is_tester',
        value: tester.toString(),
      );
      FirebaseCrashlytics.instance.setCustomKey('is_tester', tester);
    } catch (_) {}
    return tester;
  }

  /// Flips the stored toggle and re-applies it. Returns the effective value
  /// afterwards — in a debug build that is always true, whatever is stored.
  static Future<bool> toggleTester() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        testerPrefKey,
        !(prefs.getBool(testerPrefKey) ?? false),
      );
    } catch (_) {}
    return applyTesterFlag();
  }

  // ── User Properties ───────────────────────────────────────────

  static void setSubscriptionStatus(String status) {
    _analytics.setUserProperty(name: 'subscription_status', value: status);
    FirebaseCrashlytics.instance.setCustomKey('subscription_status', status);
  }

  static void setFocusAreaCount(int count) {
    _analytics.setUserProperty(
      name: 'focus_area_count',
      value: count.toString(),
    );
    FirebaseCrashlytics.instance.setCustomKey('focus_area_count', count);
  }

  static void setTheme(String themeName) {
    _analytics.setUserProperty(name: 'theme', value: themeName);
    FirebaseCrashlytics.instance.setCustomKey('theme', themeName);
  }
}
