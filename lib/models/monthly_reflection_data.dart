class MonthlyReflectionData {
  final int daysActive;
  final int totalDays;
  final String monthRange; // e.g. "March 2026"
  final String? validUntil; // ISO 8601 — end of first week of next month
  final String? topFocusArea;
  final String? mostConsistentHabit;
  final String? bestWeekRange;
  final int? bestWeekDays;
  final List<int>? weeklyActivity; // active days per week (up to 5 entries)
  final String growth; // 'up', 'steady', 'down', 'first'
  final bool isFirstMonth;

  const MonthlyReflectionData({
    required this.daysActive,
    required this.totalDays,
    required this.monthRange,
    this.validUntil,
    this.topFocusArea,
    this.mostConsistentHabit,
    this.bestWeekRange,
    this.bestWeekDays,
    this.weeklyActivity,
    required this.growth,
    required this.isFirstMonth,
  });

  Map<String, dynamic> toJson() => {
    'daysActive': daysActive,
    'totalDays': totalDays,
    'monthRange': monthRange,
    'validUntil': validUntil,
    'topFocusArea': topFocusArea,
    'mostConsistentHabit': mostConsistentHabit,
    'bestWeekRange': bestWeekRange,
    'bestWeekDays': bestWeekDays,
    'weeklyActivity': weeklyActivity,
    'growth': growth,
    'isFirstMonth': isFirstMonth,
  };

  factory MonthlyReflectionData.fromJson(Map<String, dynamic> json) =>
      MonthlyReflectionData(
        daysActive: json['daysActive'] as int,
        totalDays: json['totalDays'] as int,
        monthRange: json['monthRange'] as String,
        validUntil: json['validUntil'] as String?,
        topFocusArea: json['topFocusArea'] as String?,
        mostConsistentHabit: json['mostConsistentHabit'] as String?,
        bestWeekRange: json['bestWeekRange'] as String?,
        bestWeekDays: json['bestWeekDays'] as int?,
        weeklyActivity: (json['weeklyActivity'] as List?)
            ?.map((e) => e as int)
            .toList(),
        growth: json['growth'] as String? ?? 'first',
        isFirstMonth: json['isFirstMonth'] as bool? ?? true,
      );
}
