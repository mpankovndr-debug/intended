import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/monthly_reflection_data.dart';
import '../models/reflection_data.dart';
import '../onboarding_v2/onboarding_state.dart';
import 'reflection_service.dart';

/// Generates monthly reflections by aggregating weekly reflection history
/// and raw completion data across an entire month.
class MonthlyReflectionService {
  static const _currentCardKey = 'monthly_reflection_current';
  static const _previousMonthDaysKey = 'monthly_reflection_prev_days';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns cached monthly reflection if still valid, otherwise generates fresh.
  static Future<MonthlyReflectionData?> getCurrentReflection() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_currentCardKey);
    final now = DateTime.now();

    if (cached != null) {
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        final data = MonthlyReflectionData.fromJson(json);

        // Same month → return cached
        if (data.monthRange == _monthRange(now)) return data;

        // Different month but still within validUntil → keep showing
        if (data.validUntil != null) {
          final until = DateTime.tryParse(data.validUntil!);
          if (until != null && now.isBefore(until)) return data;
        }
      } catch (_) {
        // Corrupted cache — regenerate
      }
    }

    // Only generate if user has been around for 30+ days
    final firstLaunch = prefs.getString('first_launch_date');
    if (firstLaunch == null) return null;
    final daysSinceFirst = now.difference(DateTime.parse(firstLaunch)).inDays;
    if (daysSinceFirst < 30) return null;

    return generateReflection();
  }

  /// Whether a new monthly reflection should be generated.
  /// Returns true on the 1st-3rd of each month if no current reflection exists.
  static Future<bool> shouldGenerateNewReflection() async {
    final now = DateTime.now();
    if (now.day > 3) return false;

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_currentCardKey);
    if (cached == null) return true;

    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final data = MonthlyReflectionData.fromJson(json);
      return data.monthRange != _monthRange(now);
    } catch (_) {
      return true;
    }
  }

  /// Generates a monthly reflection from the previous month's data.
  static Future<MonthlyReflectionData> generateReflection() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // Analyze the previous month
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfPrevMonth = DateTime(now.year, now.month, 0);
    final totalDays = lastDayOfPrevMonth.day;

    // 1. Count active days and habit completions
    int daysActive = 0;
    final Map<String, int> habitCounts = {};
    final Map<String, int> areaCounts = {};

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(prevMonth.year, prevMonth.month, day);
      final completedIds = await HabitTracker.allCompletedIdsForDate(date);
      if (completedIds.isNotEmpty) daysActive++;

      for (final id in completedIds) {
        final title = await HabitTracker.titleForId(id);
        habitCounts[title] = (habitCounts[title] ?? 0) + 1;
        final area = _categoryForHabit(title);
        if (area != null) {
          areaCounts[area] = (areaCounts[area] ?? 0) + 1;
        }
      }
    }

    // 2. Find most consistent habit
    String? mostConsistentHabit;
    if (habitCounts.isNotEmpty) {
      final sorted = habitCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (sorted.first.value >= 3) {
        mostConsistentHabit = sorted.first.key;
      }
    }

    // 3. Top focus area
    String? topFocusArea;
    if (areaCounts.isNotEmpty) {
      final totalCompletions = areaCounts.values.fold(0, (a, b) => a + b);
      if (totalCompletions >= 5) {
        final sorted = areaCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topFocusArea = sorted.first.key;
      }
    }

    // 4. Best week from weekly reflection history
    String? bestWeekRange;
    int? bestWeekDays;
    final List<int> weeklyActivity = [];

    final history = await ReflectionService.getReflectionHistory();
    for (final week in history) {
      // Check if this week falls in the previous month
      if (_weekBelongsToMonth(week.weekRange, prevMonth)) {
        weeklyActivity.add(week.daysActive);
        if (bestWeekDays == null || week.daysActive > bestWeekDays) {
          bestWeekDays = week.daysActive;
          bestWeekRange = week.weekRange;
        }
      }
    }

    // 5. Growth comparison
    final previousMonthDays = prefs.getInt(_previousMonthDaysKey) ?? -1;
    String growth;
    if (previousMonthDays < 0) {
      growth = 'first';
    } else if (daysActive > previousMonthDays + 2) {
      growth = 'up';
    } else if (daysActive < previousMonthDays - 2) {
      growth = 'down';
    } else {
      growth = 'steady';
    }

    // Store current month's days for next comparison
    await prefs.setInt(_previousMonthDaysKey, daysActive);

    // 6. validUntil = 7th of current month (gives a week to see the reflection)
    final validUntil = DateTime(now.year, now.month, 7, 23, 59, 59);

    final reflection = MonthlyReflectionData(
      daysActive: daysActive,
      totalDays: totalDays,
      monthRange: _monthRange(prevMonth),
      validUntil: validUntil.toIso8601String(),
      topFocusArea: topFocusArea,
      mostConsistentHabit: mostConsistentHabit,
      bestWeekRange: bestWeekRange,
      bestWeekDays: bestWeekDays,
      weeklyActivity: weeklyActivity,
      growth: growth,
      isFirstMonth: previousMonthDays < 0,
    );

    await prefs.setString(_currentCardKey, jsonEncode(reflection.toJson()));
    return reflection;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static String _monthRange(DateTime date) {
    final fmt = DateFormat('MMMM yyyy');
    return fmt.format(date);
  }

  static bool _weekBelongsToMonth(String weekRange, DateTime month) {
    // weekRange is like "Mar 3 – Mar 9"
    // Check if the month name matches
    final monthAbbr = DateFormat('MMM').format(month);
    return weekRange.contains(monthAbbr);
  }

  static String? _categoryForHabit(String habit) {
    for (final entry in OnboardingState.habitsByCategory.entries) {
      if (entry.value.contains(habit)) return entry.key;
    }
    return ReflectionService.customHabitFocusAreaFor(habit);
  }
}
