import 'package:shared_preferences/shared_preferences.dart';

import 'app_usage_service.dart';

class TipData {
  final String keyEn;
  final int index;

  const TipData({required this.keyEn, required this.index});
}

class TipsService {
  TipsService._();

  static const _currentIndexKey = 'tips_current_index';
  static const _dismissedKey = 'tips_dismissed';
  static const _tipCount = 3;

  /// Returns the current tip index, or null if tips are done/dismissed.
  static Future<int?> getCurrentTipIndex() async {
    final prefs = await SharedPreferences.getInstance();

    // Already dismissed all tips
    if (prefs.getBool(_dismissedKey) ?? false) return null;

    // Don't show tips if user has been using app for more than 7 days
    final firstLaunch = await AppUsageService.getFirstLaunchDate();
    final daysSinceFirst = DateTime.now().difference(firstLaunch).inDays;
    if (daysSinceFirst > 7) return null;

    final index = prefs.getInt(_currentIndexKey) ?? 0;
    if (index >= _tipCount) return null;

    return index;
  }

  /// Advances to the next tip. Returns the next tip index, or null if done.
  static Future<int?> dismissCurrentTip() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(_currentIndexKey) ?? 0) + 1;
    await prefs.setInt(_currentIndexKey, next);
    return next < _tipCount ? next : null;
  }

  /// Marks all tips as permanently dismissed.
  static Future<void> skipAllTips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissedKey, true);
  }

  /// Whether this is the last tip.
  static bool isLastTip(int index) => index >= _tipCount - 1;
}
