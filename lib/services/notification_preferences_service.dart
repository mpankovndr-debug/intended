import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesService {
  NotificationPreferencesService._();

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  static Future<int> getHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('notification_time_hour') ?? 9;
  }

  static Future<void> setHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_time_hour', hour);
  }

  static Future<int> getMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('notification_time_minute') ?? 0;
  }

  static Future<void> setMinute(int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_time_minute', minute);
  }

  /// The language the currently-queued notifications were written in, or null
  /// on an install that predates this record.
  ///
  /// iOS stores the sentence itself, not a reference to a translation, so a
  /// queue built in Russian keeps speaking Russian after the app switches to
  /// English. This is what lets [NotificationScheduler.refreshLocale] notice.
  static Future<String?> getScheduledLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('notification_scheduled_locale');
  }

  static Future<void> setScheduledLocale(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_scheduled_locale', value);
  }

  static Future<bool> isWeeklyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('weekly_notification_enabled') ?? false;
  }

  static Future<void> setWeeklyEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weekly_notification_enabled', value);
  }

  static Future<int> getMessageIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('notification_message_index') ?? 0;
  }

  static Future<void> setMessageIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_message_index', index);
  }

  static Future<bool> isSubscribed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_subscription') ?? false;
  }

  static Future<void> setSubscribed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_subscription', value);
  }

  static Future<int> nextMessageIndex(int poolSize) async {
    final current = await getMessageIndex();
    final next = (current + 1) % poolSize;
    await setMessageIndex(next);
    return next;
  }
}
