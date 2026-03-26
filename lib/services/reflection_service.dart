import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/reflection_data.dart';
import '../onboarding_v2/onboarding_state.dart';

class ReflectionService {
  static const _historyKey = 'reflection_weekly_history';
  static const _lastWeekDaysKey = 'reflection_last_week_days';
  static const _currentCardKey = 'reflection_current_card';
  static const _weeklyRefreshesKey = 'reflection_weekly_refreshes';
  static const _weeklySwapsKey = 'reflection_weekly_swaps';
  static const _weeklyCounterWeekKey = 'reflection_weekly_counter_week';
  static const _reflectionHistoryKey = 'reflection_history';

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns cached reflection if still valid (same week or within validUntil),
  /// otherwise generates a fresh one.
  static Future<ReflectionData> getCurrentReflection() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final cached = prefs.getString(_currentCardKey);
    if (cached != null) {
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        final data = ReflectionData.fromJson(json);
        // Same week → return cached (will be refreshed via generateReflection
        // when stats change).
        if (data.weekRange == _weekRange(now)) return data;
        // Different week but still within validUntil → keep showing last week.
        if (data.validUntil != null) {
          final until = DateTime.tryParse(data.validUntil!);
          if (until != null && now.isBefore(until)) return data;
        }
      } catch (_) {
        // Corrupted cache – regenerate.
      }
    }
    return generateReflection();
  }

  /// Computes a fresh [ReflectionData], caches it, and archives the week's
  /// daily-activity for pattern detection.
  ///
  /// Before overwriting the cache, archives the previous week's reflection
  /// to [_reflectionHistoryKey] if it belongs to a different week.
  static Future<ReflectionData> generateReflection() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // Archive outgoing reflection before overwriting.
    await _archivePreviousReflection(prefs, now);

    final startOfWeek = _startOfWeek(now);

    // 1. Compute daily activity & focus-area counts for the current week.
    final dailyActivity = List<bool>.filled(7, false);
    final Map<String, int> areaCounts = {};
    final Map<String, int> habitCounts = {};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      if (date.isAfter(now)) break;

      final completedIds = await HabitTracker.allCompletedIdsForDate(date);
      if (completedIds.isNotEmpty) dailyActivity[i] = true;

      for (final id in completedIds) {
        final title = await HabitTracker.titleForId(id);
        habitCounts[title] = (habitCounts[title] ?? 0) + 1;
        final area = _categoryForHabit(title);
        if (area != null) {
          areaCounts[area] = (areaCounts[area] ?? 0) + 1;
        }
      }
    }

    final daysActive = dailyActivity.where((d) => d).length;

    // Sort habits by completion count descending.
    final sortedHabits = habitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final completedHabits = sortedHabits.map((e) => e.key).toList();

    // 2. Focus areas – only surface when data is meaningful.
    //    Dominant: one area has 60%+ of total completions AND ≥ 3 total.
    //    Balanced: no area > 60%, exactly 2-3 areas, AND ≥ 5 total.
    //    Otherwise: don't pretend the data means something.
    String? topFocusArea;
    String? secondFocusArea;
    final totalCompletions = areaCounts.values.fold(0, (a, b) => a + b);
    if (areaCounts.isNotEmpty && totalCompletions >= 3) {
      final sorted = areaCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topRatio = sorted.first.value / totalCompletions;
      if (topRatio >= 0.6) {
        // Dominant area — one clear gravitational pull.
        topFocusArea = sorted.first.key;
      } else if (sorted.length >= 2 &&
          sorted.length <= 3 &&
          totalCompletions >= 5) {
        // Balanced across 2-3 areas with enough data.
        topFocusArea = sorted[0].key;
        secondFocusArea = sorted[1].key;
      }
      // 4+ areas with small counts, or < 5 completions spread thin → skip.
    }

    // 3. Archive current week & load history for pattern detection.
    await _archiveWeek(prefs, dailyActivity, startOfWeek);
    final history = _loadHistory(prefs);

    // 4. Best day detection (needs ≥ 3 weeks).
    String? bestDay;
    String? secondBestDay;
    final hasPatternData = history.length >= 3;
    if (hasPatternData) {
      final dayTotals = List<int>.filled(7, 0);
      for (final week in history) {
        for (int i = 0; i < 7 && i < week.length; i++) {
          if (week[i]) dayTotals[i]++;
        }
      }
      final maxCount = dayTotals.reduce((a, b) => a > b ? a : b);
      if (maxCount > 0) {
        final bestIdx = dayTotals.indexOf(maxCount);
        bestDay = _dayNames[bestIdx];
        // Surface second best if within 1 of top.
        int secondMax = 0;
        int secondIdx = -1;
        for (int i = 0; i < 7; i++) {
          if (i != bestIdx && dayTotals[i] > secondMax) {
            secondMax = dayTotals[i];
            secondIdx = i;
          }
        }
        if (secondIdx >= 0 && maxCount - secondMax <= 1) {
          secondBestDay = _dayNames[secondIdx];
        }
      }
    }

    // 5. Comeback detection — only meaningful if last week was 0-1 days
    //    AND this week has 3+ active days. Coming back with 1-2 days
    //    after a quiet week isn't really a comeback.
    final lastWeekDays = prefs.getInt(_lastWeekDaysKey) ?? -1;
    final isComeback = lastWeekDays >= 0 && lastWeekDays <= 1 && daysActive >= 3;

    // Store current daysActive for next week's comeback check.
    await prefs.setInt(_lastWeekDaysKey, daysActive);

    // 6. Weekly refresh & swap counts.
    _ensureWeeklyCounterReset(prefs, startOfWeek);
    final refreshCount = prefs.getInt(_weeklyRefreshesKey) ?? 0;
    final swapCount = prefs.getInt(_weeklySwapsKey) ?? 0;

    // 7. validUntil = end of Sunday (23:59:59) of the current week.
    final endOfSunday = startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // 8. Build result.
    final reflection = ReflectionData(
      daysActive: daysActive,
      topFocusArea: topFocusArea,
      secondFocusArea: secondFocusArea,
      bestDay: bestDay,
      secondBestDay: secondBestDay,
      refreshCount: refreshCount,
      swapCount: swapCount,
      hasPatternData: hasPatternData,
      isComeback: isComeback,
      weekRange: _weekRange(now),
      validUntil: endOfSunday.toIso8601String(),
      dailyActivity: dailyActivity,
      completedHabits: completedHabits,
    );

    // Cache the card.
    final previousCache = prefs.getString(_currentCardKey);
    await prefs.setString(_currentCardKey, jsonEncode(reflection.toJson()));

    // Flag unseen reflection if this is a new week's data.
    if (previousCache != null) {
      try {
        final prevJson = jsonDecode(previousCache) as Map<String, dynamic>;
        final prevRange = prevJson['weekRange'] as String?;
        if (prevRange != reflection.weekRange && reflection.daysActive > 0) {
          await prefs.setBool('has_unseen_reflection', true);
        }
      } catch (_) {
        // Corrupted previous cache — treat as new week.
        if (reflection.daysActive > 0) {
          await prefs.setBool('has_unseen_reflection', true);
        }
      }
    } else if (reflection.daysActive > 0) {
      // First reflection ever.
      await prefs.setBool('has_unseen_reflection', true);
    }

    return reflection;
  }

  /// Whether a new reflection should be generated now.
  ///
  /// Returns `true` if it's Sunday after 8 PM or Monday, AND no cached
  /// reflection exists for this week.
  static Future<bool> shouldGenerateNewReflection() async {
    final now = DateTime.now();
    final isSundayEvening = now.weekday == DateTime.sunday && now.hour >= 20;
    final isMonday = now.weekday == DateTime.monday;

    if (!isSundayEvening && !isMonday) return false;

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_currentCardKey);
    if (cached == null) return true;

    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final data = ReflectionData.fromJson(json);
      return data.weekRange != _weekRange(now);
    } catch (_) {
      return true;
    }
  }

  // ---------------------------------------------------------------------------
  // Reflection history (past reflections saved to Moments)
  // ---------------------------------------------------------------------------

  /// Returns past weekly reflections, newest first. Max 12 entries (3 months).
  static Future<List<ReflectionData>> getReflectionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_reflectionHistoryKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => ReflectionData.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Weekly swap / refresh counter helpers
  // ---------------------------------------------------------------------------

  /// Call this whenever a habit refresh happens to track the weekly count.
  static Future<void> incrementRefreshCount() async {
    final prefs = await SharedPreferences.getInstance();
    _ensureWeeklyCounterReset(prefs, _startOfWeek(DateTime.now()));
    final current = prefs.getInt(_weeklyRefreshesKey) ?? 0;
    await prefs.setInt(_weeklyRefreshesKey, current + 1);
  }

  /// Call this whenever a habit swap happens to track the weekly count.
  static Future<void> incrementSwapCount() async {
    final prefs = await SharedPreferences.getInstance();
    _ensureWeeklyCounterReset(prefs, _startOfWeek(DateTime.now()));
    final current = prefs.getInt(_weeklySwapsKey) ?? 0;
    await prefs.setInt(_weeklySwapsKey, current + 1);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Saves the outgoing cached reflection to history if it belongs to a
  /// different week than [now]. Keeps the last 12 entries.
  static Future<void> _archivePreviousReflection(
    SharedPreferences prefs,
    DateTime now,
  ) async {
    final cached = prefs.getString(_currentCardKey);
    if (cached == null) return;
    try {
      final json = jsonDecode(cached) as Map<String, dynamic>;
      final old = ReflectionData.fromJson(json);
      // Only archive if it's from a different week and had activity.
      if (old.weekRange == _weekRange(now)) return;
      if (old.daysActive == 0) return;

      final raw = prefs.getString(_reflectionHistoryKey);
      List<Map<String, dynamic>> history = [];
      if (raw != null) {
        try {
          history = (jsonDecode(raw) as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } catch (_) {}
      }
      // Don't duplicate — check if this weekRange is already archived.
      if (history.any((h) => h['weekRange'] == old.weekRange)) return;
      // Insert newest first.
      history.insert(0, old.toJson());
      // Keep last 12 weeks (3 months).
      if (history.length > 12) {
        history = history.sublist(0, 12);
      }
      await prefs.setString(_reflectionHistoryKey, jsonEncode(history));
    } catch (_) {
      // Corrupted cache, skip archiving.
    }
  }

  /// Monday 00:00 of the week containing [date].
  static DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  /// Formatted week range like "Mar 3 – Mar 9".
  static String _weekRange(DateTime date) {
    final start = _startOfWeek(date);
    final end = start.add(const Duration(days: 6));
    final fmt = DateFormat('MMM d');
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  /// Maps a habit title to its focus-area category.
  /// For custom habits, looks up their assigned focus area from prefs.
  static String? _categoryForHabit(String habit) {
    for (final entry in OnboardingState.habitsByCategory.entries) {
      if (entry.value.contains(habit)) return entry.key;
    }
    // Check custom habit focus areas from persisted data
    return _customHabitFocusAreas[habit];
  }

  static Map<String, String> _customHabitFocusAreas = {};

  /// Public accessor for other services (e.g. MilestoneService).
  static String? customHabitFocusAreaFor(String habit) =>
      _customHabitFocusAreas[habit];

  /// Call once at startup or before reflection calculation to load custom
  /// habit focus area mappings.
  static Future<void> loadCustomHabitFocusAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('custom_habit_focus_areas');
    if (json != null) {
      try {
        _customHabitFocusAreas =
            Map<String, String>.from(jsonDecode(json) as Map);
      } catch (_) {
        _customHabitFocusAreas = {};
      }
    }
  }

  /// Stores the current week's [dailyActivity] in the rolling 4-week history.
  static Future<void> _archiveWeek(
    SharedPreferences prefs,
    List<bool> dailyActivity,
    DateTime startOfWeek,
  ) async {
    final weekKey = startOfWeek.toIso8601String().substring(0, 10);
    final raw = prefs.getString(_historyKey);
    List<List<dynamic>> entries = [];
    if (raw != null) {
      try {
        entries = (jsonDecode(raw) as List)
            .map((e) => (e as List).cast<dynamic>())
            .toList();
      } catch (_) {}
    }

    // Remove existing entry for this week.
    entries.removeWhere(
        (e) => e.isNotEmpty && e[0].toString() == weekKey);
    // Add current week.
    entries.add([weekKey, ...dailyActivity]);
    // Keep only last 4 weeks.
    if (entries.length > 4) {
      entries = entries.sublist(entries.length - 4);
    }

    await prefs.setString(_historyKey, jsonEncode(entries));
  }

  /// Loads the rolling history as a list of daily-activity lists (newest last).
  static List<List<bool>> _loadHistory(SharedPreferences prefs) {
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final entries = (jsonDecode(raw) as List)
          .map((e) => (e as List).cast<dynamic>())
          .toList();
      // Each entry is [weekKey, bool, bool, ...].
      return entries.map((e) {
        return e.skip(1).map((v) => v == true).toList();
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Resets weekly swap/refresh counters when a new week starts.
  static void _ensureWeeklyCounterReset(
    SharedPreferences prefs,
    DateTime startOfWeek,
  ) {
    final weekKey = startOfWeek.toIso8601String().substring(0, 10);
    final storedWeek = prefs.getString(_weeklyCounterWeekKey);
    if (storedWeek != weekKey) {
      prefs.setInt(_weeklyRefreshesKey, 0);
      prefs.setInt(_weeklySwapsKey, 0);
      prefs.setString(_weeklyCounterWeekKey, weekKey);
    }
  }
}
