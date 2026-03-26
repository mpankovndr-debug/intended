import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app_usage_service.dart';
import 'notification_messages.dart';
import 'notification_preferences_service.dart';
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

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        AppUsageService.incrementNotificationsTapped();
        // Weekly notification (ID 100) → navigate to Progress tab
        if (response.id == 100) {
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

  /// Determines the notification frequency tier based on recent check-in
  /// behavior. Uses the last 2 weeks of daily activity data.
  static Future<_AdaptiveTier> _getAdaptiveTier() async {
    final prefs = await SharedPreferences.getInstance();
    final rawHistory = prefs.getString('reflection_weekly_history');
    if (rawHistory == null) return _AdaptiveTier.normal;

    try {
      // Parse weekly history: each entry is [weekKey, bool, bool, ...]
      final entries = (rawHistory.split('[')
          .where((s) => s.contains('true') || s.contains('false'))
          .toList());

      // Count active days from the last 2 weeks
      int recentActiveDays = 0;
      int weeksAnalyzed = 0;
      // Simple heuristic: check days_active for recent behavior
      final daysActive = prefs.getInt('days_active') ?? 0;
      final firstLaunch = prefs.getString('first_launch_date');
      if (firstLaunch == null) return _AdaptiveTier.normal;

      final daysSinceFirst = DateTime.now()
          .difference(DateTime.parse(firstLaunch))
          .inDays;

      if (daysSinceFirst < 7) return _AdaptiveTier.normal; // Too early to adapt

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

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> rescheduleAll(AppLocalizations l10n) async {
    await cancelAll();
    await scheduleDaily(l10n);

    final weeklyEnabled =
        await NotificationPreferencesService.isWeeklyEnabled();
    if (weeklyEnabled) {
      await scheduleWeekly(l10n);
    }
  }
}
