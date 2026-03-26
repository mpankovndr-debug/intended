import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/moment.dart';
import '../models/reflection_data.dart';
import '../utils/habit_l10n.dart';
import '../services/analytics_service.dart';
import '../services/moments_service.dart';
import '../services/reflection_service.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// Unified timeline entry — either a habit moment or a weekly reflection.
class _TimelineEntry {
  final Moment? moment;
  final ReflectionData? reflection;
  final DateTime sortDate;

  _TimelineEntry.habit(this.moment)
      : reflection = null,
        sortDate = moment!.completedAt;

  _TimelineEntry.weeklyReflection(this.reflection)
      : moment = null,
        sortDate = _reflectionSortDate(reflection!);

  bool get isReflection => reflection != null;

  /// Derive a sort date from validUntil (end of Sunday) → use Monday of that week.
  static DateTime _reflectionSortDate(ReflectionData data) {
    if (data.validUntil != null) {
      final until = DateTime.tryParse(data.validUntil!);
      if (until != null) {
        // validUntil = Sunday 23:59:59 → Monday = until - 6 days
        return until.subtract(const Duration(days: 6));
      }
    }
    // Fallback: parse weekRange "Mar 3 – Mar 9" isn't reliable, use epoch.
    return DateTime(2020);
  }
}

class MomentsCollectionScreen extends StatefulWidget {
  const MomentsCollectionScreen({super.key});

  @override
  State<MomentsCollectionScreen> createState() =>
      _MomentsCollectionScreenState();
}

class _MomentsCollectionScreenState extends State<MomentsCollectionScreen> {
  Map<String, List<_TimelineEntry>> _grouped = {};
  bool _loading = true;
  bool _didLoad = false;
  final Set<String> _expandedMonths = {};
  final Set<String> _expandedReflections = {};
  bool _currentMonthShowAll = false;
  static const int _initialVisibleCount = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      AnalyticsService.logScreenView('moments_collection');
      _load();
    }
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    final moments = await MomentsService.getAll();
    final reflections = await ReflectionService.getReflectionHistory();

    // Build unified timeline entries.
    final entries = <_TimelineEntry>[
      ...moments.map((m) => _TimelineEntry.habit(m)),
      ...reflections.map((r) => _TimelineEntry.weeklyReflection(r)),
    ];

    // Sort newest first.
    entries.sort((a, b) => b.sortDate.compareTo(a.sortDate));

    // Group by month label.
    final Map<String, List<_TimelineEntry>> grouped = {};
    for (final entry in entries) {
      final key = _monthLabel(entry.sortDate.toLocal(), l10n);
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    if (mounted) {
      setState(() {
        _grouped = grouped;
        _loading = false;
      });
    }
  }

  static String _monthLabel(DateTime date, AppLocalizations l10n) {
    final months = [
      l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch,
      l10n.monthApril, l10n.monthMay, l10n.monthJune,
      l10n.monthJuly, l10n.monthAugust, l10n.monthSeptember,
      l10n.monthOctober, l10n.monthNovember, l10n.monthDecember,
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return CupertinoPageScaffold(
      backgroundColor: colors.modalBg2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image — barely softened
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Image.asset(
                colors.backgroundMs,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Warm gradient overlay — matches Habits screen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    colors.bgGradientTop.withOpacity(colors.bgGradientTopOpacity),
                    colors.bgGradientMid.withOpacity(colors.bgGradientMidOpacity),
                    colors.bgGradientBottom.withOpacity(colors.bgGradientBottomOpacity),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          _loading
              ? const Center(child: CupertinoActivityIndicator())
              : _grouped.isEmpty
                  ? _buildEmptyState(colors)
                  : _buildList(colors),

          // Bottom fade above tab bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.tabBarFade.withOpacity(0.0),
                      colors.tabBarFade.withOpacity(0.85),
                      colors.tabBarFade.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _currentMonthKey(AppLocalizations l10n) {
    final now = DateTime.now();
    final months = [
      l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch,
      l10n.monthApril, l10n.monthMay, l10n.monthJune,
      l10n.monthJuly, l10n.monthAugust, l10n.monthSeptember,
      l10n.monthOctober, l10n.monthNovember, l10n.monthDecember,
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  void _toggleMonth(String month) {
    setState(() {
      if (_expandedMonths.contains(month)) {
        _expandedMonths.remove(month);
      } else {
        _expandedMonths.add(month);
      }
    });
  }

  /// Returns the most frequent habit name. Ties broken by most recent completion.
  String _mostFrequentIntention(List<Moment> moments) {
    final counts = <String, int>{};
    for (final m in moments) {
      counts[m.habitName] = (counts[m.habitName] ?? 0) + 1;
    }
    final maxCount = counts.values.reduce((a, b) => a > b ? a : b);
    // moments are newest-first, so first match wins the tiebreak
    for (final m in moments) {
      if (counts[m.habitName] == maxCount) return m.habitName;
    }
    return moments.firstOrNull?.habitName ?? '';
  }

  Widget _buildList(AppColorScheme colors) {
    final l10n = AppLocalizations.of(context);
    final months = _grouped.keys.toList();
    final currentMonthKey = _currentMonthKey(l10n);

    return CustomScrollView(
      slivers: [
        // Pinned Header
        SliverPersistentHeader(
          pinned: true,
          delegate: _MomentsHeaderDelegate(
            topPadding: MediaQuery.of(context).padding.top,
            onBack: () => Navigator.pop(context),
          ),
        ),

        // Month sections
        for (final month in months) ...[
          // Month header — tappable for past months
          SliverToBoxAdapter(
            child: _buildMonthHeader(month, month == currentMonthKey, colors),
          ),

          // Current or expanded month → entry list (capped for current month)
          if (month == currentMonthKey || _expandedMonths.contains(month)) ...[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = _grouped[month]![index];
                  if (entry.isReflection) {
                    return _ReflectionRow(
                      reflection: entry.reflection!,
                      isExpanded: _expandedReflections.contains(entry.reflection!.weekRange),
                      onTap: () {
                        setState(() {
                          final key = entry.reflection!.weekRange;
                          if (_expandedReflections.contains(key)) {
                            _expandedReflections.remove(key);
                          } else {
                            _expandedReflections.add(key);
                          }
                        });
                      },
                    );
                  }
                  return _MomentRow(moment: entry.moment!);
                },
                childCount: (month == currentMonthKey && !_currentMonthShowAll && _grouped[month]!.length > _initialVisibleCount)
                    ? _initialVisibleCount
                    : _grouped[month]!.length,
              ),
            ),
            // "Show all" button when current month is capped
            if (month == currentMonthKey && !_currentMonthShowAll && _grouped[month]!.length > _initialVisibleCount)
              SliverToBoxAdapter(
                child: _buildShowAllButton(_grouped[month]!.length, colors, l10n),
              ),
          ]
          // Past collapsed month → summary card
          else
            SliverToBoxAdapter(
              child: _buildSummaryCard(month, _grouped[month]!, colors, l10n),
            ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  Widget _buildMonthHeader(String month, bool isCurrentMonth, AppColorScheme colors) {
    final isExpanded = _expandedMonths.contains(month);

    return GestureDetector(
      onTap: isCurrentMonth ? null : () => _toggleMonth(month),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                month.toUpperCase(),
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.ctaPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            if (!isCurrentMonth)
              Icon(
                isExpanded
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 14,
                color: colors.ctaPrimary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowAllButton(int totalCount, AppColorScheme colors, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMonthShowAll = true;
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: colors.cardBackground.withOpacity(colors.cardBackgroundOpacity * 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.borderCard.withOpacity(colors.borderCardOpacity),
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              l10n.momentsShowAll(totalCount),
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.ctaPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String month,
    List<_TimelineEntry> entries,
    AppColorScheme colors,
    AppLocalizations l10n,
  ) {
    final isDark = context.watch<ThemeProvider>().theme.isDark;
    final moments = entries.where((e) => !e.isReflection).toList();
    final momentCount = moments.length;
    final intentionCount = moments.map((m) => m.moment!.habitName).toSet().length;
    final topIntention = momentCount > 0
        ? _mostFrequentIntention(moments.map((e) => e.moment!).toList())
        : '';

    return GestureDetector(
      onTap: () => _toggleMonth(month),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.momentsCard.withOpacity(colors.momentsCardOpacity)
                    : const Color(0xFFFFFFFF).withOpacity(0.30),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                      : const Color(0xFFFFFFFF).withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.monthSummaryMoments(momentCount, month),
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.monthSummaryIntentions(intentionCount),
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.monthSummaryTopIntention(localizeHabitName(topIntention, l10n)),
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Back button row — matches _MomentsHeaderDelegate style
        Padding(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.cardBackground.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.borderCard.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        size: 20,
                        color: colors.textSubtitle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Centered empty state content
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✦',
                    style: TextStyle(
                      fontSize: 36,
                      color: colors.ctaPrimary.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.momentsEmptyTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: colors.ctaPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.momentsEmptyMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.accentMuted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MomentsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final VoidCallback onBack;

  _MomentsHeaderDelegate({required this.topPadding, required this.onBack});

  double get _headerHeight => topPadding + 16 + 72 + 8; // top padding + 16 gap + content + 8 bottom

  @override
  double get maxExtent => _headerHeight;

  @override
  double get minExtent => _headerHeight;

  @override
  bool shouldRebuild(covariant _MomentsHeaderDelegate oldDelegate) =>
      topPadding != oldDelegate.topPadding;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.bgGradientTop.withOpacity(colors.bgGradientTopOpacity * 0.7),
                colors.bgGradientTop.withOpacity(colors.bgGradientTopOpacity * 0.4),
                colors.bgGradientTop.withOpacity(0.0),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.cardBackground.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.borderCard.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        size: 20,
                        color: colors.textSubtitle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.momentsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.momentsSubtitle,
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentRow extends StatelessWidget {
  final Moment moment;

  const _MomentRow({required this.moment});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final local = moment.completedAt.toLocal();
    final momentDay = DateTime(local.year, local.month, local.day);

    final String dateStr;
    if (momentDay == today) {
      dateStr = '${l10n.momentsToday} · ${DateFormat('h:mm a').format(local)}';
    } else if (momentDay == DateTime(today.year, today.month, today.day - 1)) {
      dateStr = '${l10n.momentsYesterday} · ${DateFormat('h:mm a').format(local)}';
    } else {
      dateStr = DateFormat('MMM d · h:mm a').format(local);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.momentsCard.withOpacity(colors.momentsCardOpacity)
                  : const Color(0xFFFFFFFF).withOpacity(0.30),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                    : const Color(0xFFFFFFFF).withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Focus area color dot
                Builder(builder: (context) {
                  final category = context
                      .read<OnboardingState>()
                      .getCategoryForHabit(moment.habitName);
                  final catColor = category != null
                      ? AppColors.categoryColors[category]
                      : null;
                  if (catColor == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: catColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
                // Symbol
                Text(
                  moment.habitEmoji,
                  style: TextStyle(
                    fontSize: 18,
                    color: colors.ctaPrimary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 16),
                // Name + timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizeHabitName(moment.habitName, l10n),
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReflectionRow extends StatelessWidget {
  final ReflectionData reflection;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ReflectionRow({
    required this.reflection,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    final activity = reflection.dailyActivity ?? List.filled(7, false);
    final dayLabels = [
      l10n.dayShortMon, l10n.dayShortTue, l10n.dayShortWed,
      l10n.dayShortThu, l10n.dayShortFri, l10n.dayShortSat,
      l10n.dayShortSun,
    ];

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.momentsCard.withValues(alpha: colors.momentsCardOpacity)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? colors.borderCard.withValues(alpha: colors.borderCardOpacity)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: icon + "Weekly Reflection · Mar 3 – Mar 9"
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        size: 18,
                        color: colors.ctaPrimary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${l10n.reflectionTitle} · ${reflection.weekRange}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? CupertinoIcons.chevron_up
                            : CupertinoIcons.chevron_down,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Anchor text (Section 1 copy)
                  Text(
                    _anchorText(l10n, reflection),
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Day dots row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final active = i < activity.length && activity[i];
                      return Column(
                        children: [
                          Container(
                            width: active ? 10 : 6,
                            height: active ? 10 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? colors.ctaAlternative
                                  : colors.textDisabled.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayLabels[i],
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: active
                                  ? colors.textSecondary
                                  : colors.textDisabled,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  // Expanded sections (focus, reframe, pattern)
                  if (isExpanded) ...[
                    if (reflection.topFocusArea != null) ...[
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: 0.85,
                        child: Text(
                          _focusText(l10n, reflection),
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: colors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    if (reflection.hasPatternData && reflection.bestDay != null) ...[
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: 0.85,
                        child: Text(
                          _patternText(l10n, reflection),
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: colors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _localizedDay(AppLocalizations l10n, String englishDay) {
    return switch (englishDay) {
      'Monday' => l10n.dayMonday,
      'Tuesday' => l10n.dayTuesday,
      'Wednesday' => l10n.dayWednesday,
      'Thursday' => l10n.dayThursday,
      'Friday' => l10n.dayFriday,
      'Saturday' => l10n.daySaturday,
      'Sunday' => l10n.daySunday,
      _ => englishDay,
    };
  }

  String _anchorText(AppLocalizations l10n, ReflectionData data) {
    final n = data.daysActive;
    if (n == 7) return l10n.reflectionAnchor7;
    if (n >= 5) return l10n.reflectionAnchor56(n);
    if (n >= 3) return l10n.reflectionAnchor34(n);
    if (n >= 1) return l10n.reflectionAnchor12(n);
    return l10n.reflectionAnchor0;
  }

  String _focusText(AppLocalizations l10n, ReflectionData data) {
    if (data.secondFocusArea != null) {
      return l10n.reflectionFocusBalanced(
          data.topFocusArea!, data.secondFocusArea!);
    }
    return l10n.reflectionFocusDominant(data.topFocusArea!);
  }

  String _patternText(AppLocalizations l10n, ReflectionData data) {
    if (data.bestDay != null && data.secondBestDay != null) {
      return l10n.reflectionPatternTwoDays(
        _localizedDay(l10n, data.bestDay!),
        _localizedDay(l10n, data.secondBestDay!),
      );
    }
    if (data.bestDay != null) {
      return l10n.reflectionPatternOneDay(
        _localizedDay(l10n, data.bestDay!),
      );
    }
    return l10n.reflectionPatternNone;
  }
}
