import 'dart:ui' show Locale, PlatformDispatcher;

import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import '../models/letter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'analytics_service.dart';
import 'app_usage_service.dart';
import 'moments_service.dart';
import 'notification_messages.dart';
import 'notification_preferences_service.dart';
import 'pause_launcher.dart';
import 'week_stats_service.dart';

/// Adaptive notification frequency tiers.
enum _AdaptiveTier {
  /// User checks in 5+ days/week → every other day
  reduced,
  /// User checks in 2-4 days/week → daily (default)
  normal,
  /// User checks in 0-1 days/week → one gentle nudge, then back off
  reengage,
}

class NotificationScheduler {
  NotificationScheduler._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Fires when the user taps the weekly notification (ID 100).
  /// Listeners should switch to the Progress tab (index 1).
  static final ValueNotifier<int> pendingTabSwitch = ValueNotifier<int>(-1);

  /// The daily notification's "minute of breath" action (iOS category and
  /// action ids — registered once at initialize, referenced by scheduleDaily).
  static const String _pauseCategoryId = 'daily_pause';
  static const String _pauseActionId = 'open_pause';

  /// True when the app was cold-started by the pause action button — the
  /// response callback does not fire for launches from terminated, so the
  /// launcher asks this at startup.
  static Future<bool> launchedFromPauseAction() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      return details?.didNotificationLaunchApp == true &&
          details?.notificationResponse?.actionId == _pauseActionId;
    } catch (_) {
      return false;
    }
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // Action titles are baked at registration time, before any BuildContext
    // exists, so the locale comes from the platform dispatcher — the same
    // pattern main() uses for cold-start rescheduling.
    final locale = PlatformDispatcher.instance.locale;
    final actionL10n = lookupAppLocalizations(
      locale.languageCode == 'ru' ? const Locale('ru') : const Locale('en'),
    );
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          _pauseCategoryId,
          actions: [
            // foreground: the action opens the app into the Pause screen —
            // there is no background version of a breathing exercise.
            DarwinNotificationAction.plain(
              _pauseActionId,
              actionL10n.pauseNotifAction,
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );
    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // The action button routes to the Pause and nothing else; the body
        // tap keeps its original meaning.
        if (response.actionId == _pauseActionId) {
          AnalyticsService.logNotificationOpened('pause_action');
          PauseLauncher.pending.value = 'notification';
          return;
        }
        AppUsageService.incrementNotificationsTapped();
        AnalyticsService.logNotificationOpened(switch (response.id) {
          100 => 'weekly',
          _monthlyLetterId => 'monthly_letter',
          _ => 'daily',
        });
        // Weekly (100) and the monthly letter (101) both land on the
        // Progress tab — that's where the letter lives.
        if (response.id == 100 || response.id == _monthlyLetterId) {
          pendingTabSwitch.value = 1; // Progress tab index
        }
      },
    );
  }

  static Future<bool> requestPermission() async {
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: false,
          sound: true,
        );
        return granted ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Adaptive timing
  // ---------------------------------------------------------------------------

  /// Determines the notification frequency tier from check-in behavior: the
  /// average of `days_active` per week since first launch, plus a recency
  /// override for users who have gone quiet.
  ///
  /// Reads `days_active` rather than `reflection_weekly_history` on purpose —
  /// the latter is only written when the Progress tab renders a reflection, so
  /// it tracks whether the user browses their stats, not whether they show up.
  /// Falls back to [_AdaptiveTier.normal] whenever there isn't enough data.
  static Future<_AdaptiveTier> _getAdaptiveTier() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final daysActive = prefs.getInt('days_active') ?? 0;
      final firstLaunch = prefs.getString('first_launch_date');
      if (firstLaunch == null) return _AdaptiveTier.normal;

      final daysSinceFirst = DateTime.now()
          .difference(DateTime.parse(firstLaunch))
          .inDays;

      if (daysSinceFirst < 7) return _AdaptiveTier.normal; // Too early to adapt

      // The lifetime average decays too slowly to notice a long-tenured user
      // who stopped showing up, so a full week of silence goes straight to
      // re-engage. Reverts on their next open, when days_active_last_date moves.
      final lastActive = prefs.getString('days_active_last_date');
      if (lastActive != null) {
        final daysSinceActive =
            DateTime.now().difference(DateTime.parse(lastActive)).inDays;
        if (daysSinceActive >= 7) return _AdaptiveTier.reengage;
      }

      // Calculate weekly activity rate
      final totalWeeks = daysSinceFirst / 7;
      final avgDaysPerWeek = daysActive / totalWeeks;

      if (avgDaysPerWeek >= 5) return _AdaptiveTier.reduced;
      if (avgDaysPerWeek >= 2) return _AdaptiveTier.normal;
      return _AdaptiveTier.reengage;
    } catch (_) {
      return _AdaptiveTier.normal;
    }
  }

  // ---------------------------------------------------------------------------
  // Daily scheduling
  // ---------------------------------------------------------------------------

  static Future<void> scheduleDaily(AppLocalizations l10n) async {
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();

    // Always cancel existing daily notifications before rescheduling
    for (int i = 0; i <= 6; i++) {
      await _plugin.cancel(i);
    }

    final now = tz.TZDateTime.now(tz.local);

    // Get user's intention path for path-aware copy
    final prefs = await SharedPreferences.getInstance();
    final pathKey = prefs.getString('selected_intention_path') ?? 'your_own_way';
    final pathId = IntentionPathId.fromKey(pathKey);

    // Use path-aware message pool
    final messages = NotificationMessages.dailyForPath(l10n, pathId);

    final subscribed = await NotificationPreferencesService.isSubscribed();
    final poolSize = subscribed ? messages.length : (messages.length * 0.6).round().clamp(1, messages.length);
    final startIndex =
        await NotificationPreferencesService.nextMessageIndex(poolSize);

    // Adaptive timing: determine how many notifications to schedule
    final tier = await _getAdaptiveTier();
    final int dayStep;
    switch (tier) {
      case _AdaptiveTier.reduced:
        dayStep = 2; // Every other day
      case _AdaptiveTier.normal:
        dayStep = 1; // Every day
      case _AdaptiveTier.reengage:
        dayStep = 3; // Every 3 days (gentle)
    }

    int notifId = 0;
    int msgOffset = 0;
    for (int dayOffset = 0; dayOffset < 7; dayOffset += dayStep) {
      if (notifId > 6) break;

      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(days: dayOffset));

      // Skip if the time has already passed today
      if (scheduled.isBefore(now)) {
        if (dayOffset == 0) {
          msgOffset++;
          continue;
        }
      }

      final msgIndex = (startIndex + msgOffset) % poolSize;
      String body;

      // For re-engage tier, use special gentle messaging on first notification
      if (tier == _AdaptiveTier.reengage && msgOffset == 0) {
        body = NotificationMessages.reengageMessage(l10n);
      } else {
        body = messages[msgIndex];
      }

      await _plugin.zonedSchedule(
        notifId,
        '',
        body,
        scheduled,
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: true,
            categoryIdentifier: _pauseCategoryId,
          ),
          android: AndroidNotificationDetails(
            'daily_reminders',
            l10n.notifDailyChannelName,
            channelDescription: l10n.notifDailyChannelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );

      notifId++;
      msgOffset++;
    }
  }

  static Future<void> scheduleWeekly(AppLocalizations l10n) async {
    final now = tz.TZDateTime.now(tz.local);

    // Find the next Sunday at 21:00
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      21,
      0,
    );

    // Advance to next Sunday (weekday 7)
    while (scheduled.weekday != DateTime.sunday ||
        !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
      scheduled = tz.TZDateTime(
        tz.local,
        scheduled.year,
        scheduled.month,
        scheduled.day,
        21,
        0,
      );
    }

    // Dynamic weekly message based on this week's check-in count
    final prefs = await SharedPreferences.getInstance();
    final allHabits = prefs.getStringList('habits') ?? [];
    final weekStats = await WeekStatsService.calculate(allHabits, DateTime.now());
    final checkIns = weekStats.completionCount; // days active this week

    final String body;
    if (checkIns == 0) {
      body = l10n.notifWeeklyDynamic0;
    } else if (checkIns == 1) {
      body = l10n.notifWeeklyDynamic1;
    } else {
      body = l10n.notifWeeklyDynamicN(checkIns);
    }

    await _plugin.zonedSchedule(
      100,
      '',
      body,
      scheduled,
      NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
        android: AndroidNotificationDetails(
          'weekly_reminders',
          l10n.notifWeeklyChannelName,
          channelDescription: l10n.notifWeeklyChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static const int _monthlyLetterId = 101;

  /// «Твоё письмо за август готово» on the 1st of next month, 10:00 — a
  /// call, not a report. Deliberately numberless: the weekly above bakes
  /// this week's count into a repeating notification, so three quiet weeks
  /// replay the same stale number; the letter must never do that.
  ///
  /// Scheduled only once the letter for the *current* month already
  /// computes: moments only accumulate within a month, so a letter that
  /// exists now still exists on the 1st — and if it doesn't exist yet,
  /// nothing is promised. Each app open re-runs this via [rescheduleAll],
  /// so it arms itself the day the threshold is crossed.
  static Future<void> scheduleMonthlyLetter(AppLocalizations l10n) async {
    final moments = await MomentsService.momentsForMonth(DateTime.now());
    if (Letter.read(moments) == null) return;

    final now = tz.TZDateTime.now(tz.local);
    final firstOfNext = now.month == 12
        ? tz.TZDateTime(tz.local, now.year + 1, 1, 1, 10)
        : tz.TZDateTime(tz.local, now.year, now.month + 1, 1, 10);

    // Standalone month name (LLLL): «август», not the in-context «августа».
    final month = DateFormat('LLLL', l10n.localeName).format(now);

    await _plugin.zonedSchedule(
      _monthlyLetterId,
      '',
      l10n.notifMonthlyLetter(month),
      firstOfNext,
      NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
        // Same channel as the weekly: both are the reflection cadence.
        android: AndroidNotificationDetails(
          'weekly_reminders',
          l10n.notifWeeklyChannelName,
          channelDescription: l10n.notifWeeklyChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<int> pendingDailyCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.where((n) => n.id >= 0 && n.id <= 6).length;
  }

  static Future<void> refreshTimezone(AppLocalizations? l10n) async {
    if (l10n == null) return;
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    final newLocation = tz.getLocation(tzInfo.identifier);
    if (newLocation != tz.local) {
      tz.setLocalLocation(newLocation);
      final enabled = await NotificationPreferencesService.isEnabled();
      if (enabled) {
        await rescheduleAll(l10n);
      }
    }
  }

  /// Rebuilds the queue when the app's language has changed since it was
  /// built.
  ///
  /// A notification carries its text, not a reference to it, so switching the
  /// phone from Russian to English left up to a week of Russian reminders
  /// queued — and the monthly letter for up to a month. Nothing noticed:
  /// [refreshTimezone] is the only other automatic rebuild and it fires on a
  /// zone change, not a language one.
  ///
  /// Silent on a first run and on installs predating the stamp: with nothing
  /// to compare against, the queue is already in whatever language built it,
  /// and rebuilding would only reshuffle which message comes next.
  static Future<void> refreshLocale(AppLocalizations? l10n) async {
    if (l10n == null) return;
    final previous = await NotificationPreferencesService.getScheduledLocale();
    final enabled = await NotificationPreferencesService.isEnabled();

    if (needsLocaleRebuild(
      scheduled: previous,
      current: l10n.localeName,
      remindersEnabled: enabled,
    )) {
      // Stamps the new language itself.
      await rescheduleAll(l10n);
      return;
    }

    // Nothing is queued in the wrong language, but the stamp may still be
    // stale — a first run, or a switch made while reminders were off. Record
    // where we are, so turning reminders on later doesn't read as a change
    // and rebuild a queue that was already correct.
    if (previous != l10n.localeName) {
      await NotificationPreferencesService.setScheduledLocale(l10n.localeName);
    }
  }

  /// Whether the queue has to be rebuilt for a language change.
  ///
  /// Pure, and separate from [refreshLocale], because the rule is the part
  /// worth testing and the rebuild is a plugin call that a test cannot make.
  ///
  /// [scheduled] is null on a first run and on installs predating the stamp.
  /// Null never rebuilds: with nothing to compare against, the queue is
  /// already in whatever language built it, and rebuilding would only
  /// reshuffle which message comes next for no reason.
  static bool needsLocaleRebuild({
    required String? scheduled,
    required String current,
    required bool remindersEnabled,
  }) {
    if (scheduled == null) return false;
    if (scheduled == current) return false;
    // Nothing queued means nothing queued in the wrong language.
    return remindersEnabled;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> rescheduleAll(AppLocalizations l10n) async {
    await cancelAll();

    // Stamped here and nowhere else: this is the only path that rebuilds the
    // *whole* queue in one language. [scheduleDaily] alone would leave the
    // weekly and the monthly letter still speaking the old one, and a stamp
    // written there would claim otherwise.
    await NotificationPreferencesService.setScheduledLocale(l10n.localeName);

    await scheduleDaily(l10n);

    final weeklyEnabled =
        await NotificationPreferencesService.isWeeklyEnabled();
    if (weeklyEnabled) {
      await scheduleWeekly(l10n);
      // The monthly letter rides the same preference: both are the
      // reflection cadence, and a separate toggle would need its own UI.
      await scheduleMonthlyLetter(l10n);
    }
  }
}
