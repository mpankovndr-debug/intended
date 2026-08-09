import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

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
