import 'package:shared_preferences/shared_preferences.dart';

import '../models/gratitude_cadence.dart';

/// Settings for the gratitude page: whether it is on, how often it asks, and
/// at what time. Separate from [NotificationPreferencesService] on purpose —
/// the habit nudge lands in the morning by default and this lands at night,
/// and a shared hour would drag one to the other.
class GratitudePreferencesService {
  GratitudePreferencesService._();

  static const String _enabledKey = 'gratitude_enabled';
  static const String _cadenceKey = 'gratitude_cadence';
  static const String _hourKey = 'gratitude_hour';
  static const String _minuteKey = 'gratitude_minute';

  /// Default reminder time. Evening, because the page asks what the day held.
  static const int defaultHour = 21;
  static const int defaultMinute = 30;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  /// The chosen cadence, or null when the chooser has not been answered yet —
  /// which is also how the door knows to open first-run setup instead of a
  /// blank page.
  static Future<GratitudeCadence?> getCadence() async {
    final prefs = await SharedPreferences.getInstance();
    return GratitudeCadence.fromKey(prefs.getString(_cadenceKey));
  }

  static Future<void> setCadence(GratitudeCadence cadence) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cadenceKey, cadence.key);
  }

  static Future<int> getHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_hourKey) ?? defaultHour;
  }

  static Future<void> setHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, hour);
  }

  static Future<int> getMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_minuteKey) ?? defaultMinute;
  }

  static Future<void> setMinute(int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_minuteKey, minute);
  }

  /// True once the chooser has been answered. The door opens setup exactly
  /// once, then goes straight to the page ever after.
  static Future<bool> hasChosenCadence() async => (await getCadence()) != null;
}
