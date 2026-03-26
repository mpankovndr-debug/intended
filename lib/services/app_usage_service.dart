import 'package:shared_preferences/shared_preferences.dart';

class AppUsageService {
  static const _firstLaunchKey = 'first_launch_date';

  // ── Coach mark counters ────────────────────────────────────────

  static const _totalHabitsCompletedKey = 'total_habits_completed';
  static const _daysActiveKey = 'days_active';
  static const _daysActiveLastDateKey = 'days_active_last_date';
  static const _notificationsTappedKey = 'notifications_tapped';

  static Future<int> getTotalHabitsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalHabitsCompletedKey) ?? 0;
  }

  static Future<int> incrementHabitsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_totalHabitsCompletedKey) ?? 0) + 1;
    await prefs.setInt(_totalHabitsCompletedKey, next);
    return next;
  }

  static Future<int> getDaysActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_daysActiveKey) ?? 0;
  }

  /// Increments days_active by 1, but only once per calendar day.
  /// Returns the new count, or the existing count if already incremented today.
  static Future<int> incrementDaysActiveOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_daysActiveLastDateKey);
    if (lastDate == today) {
      return prefs.getInt(_daysActiveKey) ?? 0;
    }
    final next = (prefs.getInt(_daysActiveKey) ?? 0) + 1;
    await prefs.setInt(_daysActiveKey, next);
    await prefs.setString(_daysActiveLastDateKey, today);
    return next;
  }

  static Future<int> getNotificationsTapped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_notificationsTappedKey) ?? 0;
  }

  static Future<int> incrementNotificationsTapped() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_notificationsTappedKey) ?? 0) + 1;
    await prefs.setInt(_notificationsTappedKey, next);
    return next;
  }

  /// Returns the first launch date, storing it on the very first call.
  static Future<DateTime> getFirstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_firstLaunchKey);

    if (stored != null) {
      return DateTime.parse(stored);
    }

    final now = DateTime.now();
    await prefs.setString(_firstLaunchKey, now.toIso8601String());
    return now;
  }

  /// Returns the number of full weeks since first launch (minimum 1).
  static Future<int> getWeekCount() async {
    final firstLaunch = await getFirstLaunchDate();
    final now = DateTime.now();
    final days = now.difference(firstLaunch).inDays;
    return days ~/ 7 < 1 ? 1 : days ~/ 7;
  }
}
