import '../onboarding_v2/onboarding_state.dart';
import 'app_usage_service.dart';
import 'moments_service.dart';
import 'reflection_service.dart';

/// Holds computed milestone data, cached per session.
class MilestoneData {
  final int weekCount;
  final String? topArea; // null if all habits are custom
  final String? topHabitName; // null if no moments yet
  final int topHabitCount;

  const MilestoneData({
    required this.weekCount,
    this.topArea,
    this.topHabitName,
    this.topHabitCount = 0,
  });
}

class MilestoneService {
  static MilestoneData? _cache;

  /// Clears the cached data (call on app resume or new completion).
  static void invalidate() => _cache = null;

  static String? _categoryForHabit(String habit) {
    for (final entry in OnboardingState.habitsByCategory.entries) {
      if (entry.value.contains(habit)) return entry.key;
    }
    // An action from a retired focus area, still held by whoever had it.
    final retired = OnboardingState.retiredHabitCategories[habit];
    if (retired != null) return retired;
    // Check custom habit focus areas (loaded by ReflectionService)
    return ReflectionService.customHabitFocusAreaFor(habit);
  }

  /// Returns milestone data, computing once per session.
  static Future<MilestoneData> get() async {
    if (_cache != null) return _cache!;

    final weekCount = await AppUsageService.getWeekCount();
    final moments = await MomentsService.getAll();

    String? topArea;
    String? topHabitName;
    int topHabitCount = 0;

    if (moments.isNotEmpty) {
      // Group by habit name → find most completed
      final Map<String, int> habitCounts = {};
      for (final m in moments) {
        habitCounts[m.habitName] = (habitCounts[m.habitName] ?? 0) + 1;
      }
      if (habitCounts.isNotEmpty) {
        final topEntry =
            habitCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
        topHabitName = topEntry.key;
        topHabitCount = topEntry.value;
      }

      // Group by area → find most repeated (skip custom habits with null area)
      final Map<String, int> areaCounts = {};
      for (final m in moments) {
        final area = _categoryForHabit(m.habitName);
        if (area != null) {
          areaCounts[area] = (areaCounts[area] ?? 0) + 1;
        }
      }
      if (areaCounts.isNotEmpty) {
        topArea =
            areaCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }
    }

    _cache = MilestoneData(
      weekCount: weekCount,
      topArea: topArea,
      topHabitName: topHabitName,
      topHabitCount: topHabitCount,
    );
    return _cache!;
  }
}
