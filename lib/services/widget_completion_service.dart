import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

/// Syncs habit completions made from the iOS widget into Flutter's
/// SharedPreferences on app launch.
///
/// Flow:
/// 1. User taps a habit on the widget → Swift AppIntent writes to
///    shared UserDefaults ('widget_pending_completions').
/// 2. On next Flutter app launch, this service reads those pending
///    completions, applies them to SharedPreferences, and clears the queue.
class WidgetCompletionService {
  static const _appGroupId = 'group.com.intendedapp.ios';
  static const _pendingKey = 'widget_pending_completions';

  /// Call at app startup to sync any widget completions into SharedPreferences.
  /// Returns the number of completions synced.
  static Future<int> syncPendingCompletions() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);

      // Read pending completions from shared UserDefaults
      final pendingJson = await HomeWidget.getWidgetData<String>(_pendingKey);
      if (pendingJson == null || pendingJson.isEmpty) return 0;

      final List<dynamic> pending;
      try {
        pending = jsonDecode(pendingJson) as List<dynamic>;
      } catch (_) {
        // Corrupted data — clear it
        await HomeWidget.saveWidgetData<String>(_pendingKey, '[]');
        return 0;
      }

      if (pending.isEmpty) return 0;

      final prefs = await SharedPreferences.getInstance();
      int synced = 0;

      for (final entry in pending) {
        if (entry is! Map<String, dynamic>) continue;
        final habitName = entry['habitName'] as String?;
        final dateKey = entry['dateKey'] as String?;
        if (habitName == null || dateKey == null) continue;

        // Resolve habit ID from name
        final habitId = HabitTracker.habitId(habitName);
        final prefsKey = 'habit_done_${habitId}_$dateKey';

        // Only set if not already completed
        if (!(prefs.getBool(prefsKey) ?? false)) {
          await prefs.setBool(prefsKey, true);
          synced++;
          debugPrint('Widget sync: completed "$habitName" for $dateKey');
        }
      }

      // Clear the pending queue
      await HomeWidget.saveWidgetData<String>(_pendingKey, '[]');

      return synced;
    } catch (e) {
      debugPrint('Widget completion sync failed: $e');
      return 0;
    }
  }
}
