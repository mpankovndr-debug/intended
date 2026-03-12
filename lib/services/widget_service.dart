import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../main.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/reflection_service.dart';
import '../theme/app_colors.dart';

/// Pushes habit & theme data to the iOS home screen widget via App Groups.
class WidgetService {
  static const _appGroupId = 'group.com.intendedapp.ios';
  static const _iOSBasicWidgetName = 'IntendedBasicWidget';
  static const _iOSPremiumWidgetName = 'IntendedPremiumWidget';
  static const _iOSLockScreenWidgetName = 'IntendedLockScreenWidget';

  static Future<void>? _initFuture;

  /// Call once at startup.
  static Future<void> initialize() {
    _initFuture ??= HomeWidget.setAppGroupId(_appGroupId);
    return _initFuture!;
  }

  /// Push all widget data. Call after habit changes, theme changes, app launch.
  static Future<void> updateWidget({
    required List<String> userHabits,
    required Map<String, String> customHabitFocusAreas,
    required bool isPremium,
    required AppTheme theme,
    required String greeting,
    String locale = 'en',
  }) async {
    await initialize();

    final now = DateTime.now();
    final completedIds = await HabitTracker.allCompletedIdsForDate(now);

    // Build habit list with completion status and focus area color
    final habitDataList = <Map<String, dynamic>>[];
    for (final habit in userHabits) {
      final id = HabitTracker.habitId(habit);
      final done = completedIds.contains(id);
      final category = _categoryForHabit(habit, customHabitFocusAreas);
      final color = category != null
          ? AppColors.categoryColors[category]
          : null;

      habitDataList.add({
        'name': habit,
        'done': done,
        'colorHex': color != null ? _colorToHex(color) : null,
      });
    }

    final completedCount =
        habitDataList.where((h) => h['done'] == true).length;
    final totalCount = userHabits.length;

    // Theme colors for widget rendering
    final colors = AppColors.of(theme);
    final themeData = {
      'id': theme.name,
      'isDark': theme.isDark,
      'bgTop': _colorToHex(colors.bgGradientTop),
      'bgBottom': _colorToHex(colors.bgGradientBottom),
      'textPrimary': _colorToHex(colors.textPrimary),
      'textSecondary': _colorToHex(colors.textSecondary),
      'textTertiary': _colorToHex(colors.textTertiary),
      'accent': _colorToHex(colors.checkmarkFill),
      'cardBg': _colorToHex(colors.cardBackground),
      'cardBgOpacity': colors.cardBackgroundOpacity,
      'checkmark': _colorToHex(colors.checkmarkFill),
    };

    // Write all data to shared UserDefaults
    await Future.wait([
      HomeWidget.saveWidgetData<String>(
          'widget_habits', jsonEncode(habitDataList)),
      HomeWidget.saveWidgetData<int>(
          'widget_completed_count', completedCount),
      HomeWidget.saveWidgetData<int>('widget_total_count', totalCount),
      HomeWidget.saveWidgetData<String>('widget_greeting', greeting),
      HomeWidget.saveWidgetData<bool>('widget_is_premium', isPremium),
      HomeWidget.saveWidgetData<String>('widget_theme', jsonEncode(themeData)),
      HomeWidget.saveWidgetData<String>('widget_locale', locale),
    ]);

    // Tell iOS to reload all widget timelines
    await HomeWidget.updateWidget(iOSName: _iOSBasicWidgetName);
    await HomeWidget.updateWidget(iOSName: _iOSPremiumWidgetName);
    await HomeWidget.updateWidget(iOSName: _iOSLockScreenWidgetName);
  }

  /// Resolves a habit title to its focus area category name.
  static String? _categoryForHabit(
      String habit, Map<String, String> customFocusAreas) {
    for (final entry in OnboardingState.habitsByCategory.entries) {
      if (entry.value.contains(habit)) return entry.key;
    }
    // Custom habits
    return customFocusAreas[habit] ??
        ReflectionService.customHabitFocusAreaFor(habit);
  }

  /// Converts a Color to a hex string like "FF3C342A".
  static String _colorToHex(Color c) {
    final argb = ((c.a * 255).round() << 24) |
        ((c.r * 255).round() << 16) |
        ((c.g * 255).round() << 8) |
        (c.b * 255).round();
    return argb.toRadixString(16).padLeft(8, '0').toUpperCase();
  }
}
