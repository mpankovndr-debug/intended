import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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

  static void logPurchaseFailed() {
    _analytics.logEvent(name: 'purchase_failed');
  }

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
