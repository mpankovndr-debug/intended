import 'dart:ui' show Locale, PlatformDispatcher;

import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import '../models/letter.dart';
import '../models/week_recap.dart';
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

  /// A tab switch asked for from outside the tabs — the season archive,
  /// which sits over the Profile tab. The tabs consume it (back to -1).
  static final ValueNotifier<int> pendingTabSwitch = ValueNotifier<int>(-1);

  /// The month a notification tap wants the Progress tab opened on — the
  /// weekly and the monthly letter both land there. Set whether the tap came
  /// in live or launched the app, and held until the tabs exist to take it:
  /// they consume it on creation as well as on change, and set it back to
  /// null.
  static final ValueNotifier<DateTime?> pendingProgressMonth =
      ValueNotifier<DateTime?>(null);

  /// Notification ids. The daily reminders use 0–6.
  static const int _weeklyId = 100;
  static const int _monthlyLetterId = 101;

  /// The daily notification's "minute of breath" action (iOS category and
  /// action ids — registered once at initialize, referenced by scheduleDaily).
  static const String _pauseCategoryId = 'daily_pause';
  static const String _pauseActionId = 'open_pause';

  /// Set once [initialize] has run. Arming needs the time zone it sets up,
  /// and the lifecycle hooks that arm can fire before it has.
  static bool _ready = false;

  /// One path for every tap, live or launching: the action button opens the
  /// Pause, the weekly and the letter open the Progress tab on their month,
  /// and a daily body tap just opens the app.
  static void _handleTap(NotificationResponse response) {
    if (response.actionId == _pauseActionId) {
      AnalyticsService.logNotificationOpened('pause_action');
      PauseLauncher.pending.value = 'notification';
      return;
    }
    AppUsageService.incrementNotificationsTapped();
    AnalyticsService.logNotificationOpened(switch (response.id) {
      _weeklyId => 'weekly',
      _monthlyLetterId => 'monthly_letter',
      _ => 'daily',
    });
    final month = progressMonthFor(
      id: response.id,
      payload: response.payload,
      now: DateTime.now(),
    );
    if (month != null) pendingProgressMonth.value = month;
  }

  /// The month a tap should open the Progress tab on, or null for a tap that
  /// just opens the app.
  ///
  /// The weekly opens on the month being lived, the only page the week card
  /// sits on. The letter opens on the month it is about, carried in its
  /// payload: it goes out on the 1st, when the month being lived is the new
  /// one and holds no letter yet. A letter queued before the payload existed
  /// has none — and was queued for the 1st after the month it names, so it
  /// falls back to the month before today.
  ///
  /// Pure, so the rule can be tested without a device.
  static DateTime? progressMonthFor({
    required int? id,
    required String? payload,
    required DateTime now,
  }) {
    switch (id) {
      case _weeklyId:
        return DateTime(now.year, now.month);
      case _monthlyLetterId:
        return _parseMonth(payload) ?? DateTime(now.year, now.month - 1);
      default:
        return null;
    }
  }

  /// The letter's payload: its month as 'yyyy-MM'.
  static String _monthPayload(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  static DateTime? _parseMonth(String? payload) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(payload ?? '');
    if (match == null) return null;
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) return null;
    return DateTime(int.parse(match.group(1)!), month);
  }

  /// Routes the tap that launched the app, if one did. The response callback
  /// never fires for a launch from terminated — the plugin holds that tap for
  /// this call instead — so [initialize] makes it, exactly once.
  static Future<void> _routeLaunchTap() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      final response = details?.notificationResponse;
      if (details?.didNotificationLaunchApp == true && response != null) {
        _handleTap(response);
      }
    } catch (_) {
      // No launch to report — the app opens where it always does.
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
      onDidReceiveNotificationResponse: _handleTap,
    );
    _ready = true;
    await _routeLaunchTap();
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
    await cancelDaily();

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

  /// The weekly goes out on Sunday evening, as its setting says.
  static const int _weeklyHour = 21;

  /// The letter goes out on the 1st, mid-morning.
  static const int _letterHour = 10;

  /// The Sunday whose evening is the next weekly fire after [now]: today, on
  /// a Sunday before 21:00, otherwise the coming Sunday.
  static DateTime weeklyFireDay(DateTime now) {
    final daysToSunday = DateTime.sunday - now.weekday;
    final pastTonight = daysToSunday == 0 && now.hour >= _weeklyHour;
    return DateTime(
      now.year,
      now.month,
      now.day + daysToSunday + (pastTonight ? 7 : 0),
    );
  }

  /// The 1st whose 10:00 is the next letter fire after [now]: today, on a
  /// 1st before ten, otherwise next month's. The letter it carries is for the
  /// month before that day.
  static DateTime letterFireDay(DateTime now) =>
      now.day == 1 && now.hour < _letterHour
          ? DateTime(now.year, now.month, 1)
          : DateTime(now.year, now.month + 1, 1);

  /// "Your week is ready" on Sunday evening, pointing at the week card.
  ///
  /// A one-shot, not a repeating alarm, because the sentence has to be true
  /// when it lands. The repeating version baked the count it was scheduled
  /// with into every Sunday after — stale within a week, and a count of days
  /// presented as moments to begin with. Now it is armed only once the
  /// coming Sunday's card already computes: moments only accumulate within a
  /// week, so a card that exists now still exists on Sunday. A thinner week
  /// gets silence, never "your week is ready" over a card that isn't there.
  /// Numberless for the letter's reason: the count at arming time is not the
  /// count on Sunday.
  ///
  /// [scheduleReadings] re-runs this on every open and every exit, so it
  /// arms itself the day the week crosses the threshold.
  static Future<void> scheduleWeekly(AppLocalizations l10n) async {
    final now = tz.TZDateTime.now(tz.local);
    final sunday = weeklyFireDay(now);
    final weekStart = DateTime.utc(sunday.year, sunday.month, sunday.day - 6);
    final moments = await MomentsService.getAll();
    if (WeekRecap.readWeek(moments, weekStart) == null) {
      await _withdrawPending(_weeklyId);
      return;
    }

    await _plugin.zonedSchedule(
      _weeklyId,
      '',
      l10n.notifWeeklyRecap,
      tz.TZDateTime(
        tz.local,
        sunday.year,
        sunday.month,
        sunday.day,
        _weeklyHour,
      ),
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
      matchDateTimeComponents: null,
    );
  }

  /// «Твоё письмо за август готово» on the 1st of next month, 10:00 — a
  /// call, not a report. Deliberately numberless, like the weekly.
  ///
  /// Scheduled only once the letter it announces already computes: moments
  /// only accumulate within a month, so a letter that exists now still exists
  /// on the 1st — and if it doesn't exist yet, nothing is promised. Before
  /// ten on a 1st, the letter is the month that just closed, so an open that
  /// morning re-arms it rather than dropping it for the new, empty month.
  ///
  /// Carries its month as the payload, so the tap opens the page that holds
  /// the letter instead of the new month's. [scheduleReadings] re-runs this
  /// on every open and every exit, so it arms itself the day the threshold is
  /// crossed.
  static Future<void> scheduleMonthlyLetter(AppLocalizations l10n) async {
    final now = tz.TZDateTime.now(tz.local);
    final fireDay = letterFireDay(now);
    final letterMonth = DateTime(fireDay.year, fireDay.month - 1);
    final moments = await MomentsService.momentsForMonth(letterMonth);
    if (Letter.read(moments) == null) {
      await _withdrawPending(_monthlyLetterId);
      return;
    }

    // Standalone month name (LLLL): «август», not the in-context «августа».
    final month = DateFormat('LLLL', l10n.localeName).format(letterMonth);

    await _plugin.zonedSchedule(
      _monthlyLetterId,
      '',
      l10n.notifMonthlyLetter(month),
      tz.TZDateTime(tz.local, fireDay.year, fireDay.month, 1, _letterHour),
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
      payload: _monthPayload(letterMonth),
    );
  }

  /// Arms the weekly and the monthly letter when their setting is on — the
  /// one switch covers both, since both are the reflection cadence.
  ///
  /// Both are one-shots whose truth depends on data that changes between
  /// opens, so this runs on every open and every exit as well as from
  /// [rescheduleAll]. Before this, the letter was armed only by a full
  /// rebuild — a settings change, a new language or time zone — so most
  /// people never had one queued at all.
  static Future<void> scheduleReadings(AppLocalizations l10n) async {
    if (!_ready) return;
    if (!await NotificationPreferencesService.isWeeklyEnabled()) return;
    await scheduleWeekly(l10n);
    await scheduleMonthlyLetter(l10n);
  }

  /// Takes [id] out of the queue, but only while it is still queued. `cancel`
  /// also clears a delivered notification from Notification Center, and one
  /// already delivered was true when it landed — wiping it because the next
  /// week is still empty would take away a tap the user hasn't made yet.
  static Future<void> _withdrawPending(int id) async {
    final pending = await _plugin.pendingNotificationRequests();
    if (pending.any((n) => n.id == id)) await _plugin.cancel(id);
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

  /// The daily reminders alone. Turning them off must not take the weekly
  /// and the letter with them — those have a setting of their own.
  static Future<void> cancelDaily() async {
    for (int i = 0; i <= 6; i++) {
      await _plugin.cancel(i);
    }
  }

  static Future<void> rescheduleAll(AppLocalizations l10n) async {
    await cancelAll();

    // Stamped here and nowhere else: this is the only path that rebuilds the
    // *whole* queue in one language. [scheduleDaily] alone would leave the
    // weekly and the monthly letter still speaking the old one, and a stamp
    // written there would claim otherwise.
    await NotificationPreferencesService.setScheduledLocale(l10n.localeName);

    // Each cadence answers to its own setting. This used to queue the daily
    // reminders unconditionally, so flipping the weekly switch brought back
    // reminders the user had turned off.
    if (await NotificationPreferencesService.isEnabled()) {
      await scheduleDaily(l10n);
    }
    await scheduleReadings(l10n);
  }
}
