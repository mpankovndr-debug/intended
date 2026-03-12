import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../models/moment.dart';
import '../services/moments_service.dart';
import '../services/analytics_service.dart';
import '../services/week_stats_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/weekly_reflection_card.dart';
import 'moments_collection_screen.dart';

class ProgressScreen extends StatefulWidget {
  final bool isActive;
  const ProgressScreen({super.key, this.isActive = true});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('progress');
  }

  @override
  void didUpdateWidget(covariant ProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Tab became active — refresh stats
      final userHabits = context.read<OnboardingState>().userHabits;
      if (userHabits.isNotEmpty) {
        _refreshStats(userHabits);
      }
    }
  }

  Future<WeekStats>? _weekStatsFuture;

  List<String> _getAffirmations(AppLocalizations l10n) => [
    l10n.affirmation1, l10n.affirmation2, l10n.affirmation3,
    l10n.affirmation4, l10n.affirmation5, l10n.affirmation6,
    l10n.affirmation7, l10n.affirmation8, l10n.affirmation9,
    l10n.affirmation10, l10n.affirmation11, l10n.affirmation12,
    l10n.affirmation13, l10n.affirmation14, l10n.affirmation15,
    l10n.affirmation16, l10n.affirmation17, l10n.affirmation18,
    l10n.affirmation19, l10n.affirmation20, l10n.affirmation21,
    l10n.affirmation22, l10n.affirmation23, l10n.affirmation24,
    l10n.affirmation25, l10n.affirmation26, l10n.affirmation27,
    l10n.affirmation28, l10n.affirmation29, l10n.affirmation30,
    l10n.affirmation31, l10n.affirmation32, l10n.affirmation33,
    l10n.affirmation34, l10n.affirmation35,
  ];

  String _getTodaysAffirmation(AppLocalizations l10n) {
    final affirmations = _getAffirmations(l10n);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return affirmations[dayOfYear % affirmations.length];
  }

  void _refreshStats(List<String> habits) {
    setState(() {
      _weekStatsFuture = WeekStatsService.calculate(habits, DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = context.watch<OnboardingState>();
    final userHabits = onboardingState.userHabits;
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    if (_weekStatsFuture == null) {
      _refreshStats(userHabits);
    }

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
            top: false,
            bottom: false,
            child: userHabits.isEmpty
                ? Center(
                    child: Text(
                      l10n.progressOnboardingPrompt,
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSubtitle,
                      ),
                    ),
                  )
                : FutureBuilder<WeekStats>(
                    future: _weekStatsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            l10n.progressWeekBeginning,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.textSubtitle,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }

                      final stats = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header (fixed)
                          Padding(
                            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.progressTitle,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Scrollable content
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                              children: [
                          // 1. Weekly Reflection Card (unified)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: WeeklyReflectionCard(stats: stats),
                          ),

                          // 2. Motivational Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _getTodaysAffirmation(l10n),
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 4. Recent Moment
                          FutureBuilder<List<Moment>>(
                            future: MomentsService.getAll(),
                            builder: (context, snap) {
                              if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final moments = snap.data!;
                              final count = moments.length;
                              final recent = moments.first;
                              return _buildRecentMoment(count, recent, colors, l10n, isDark: isDark);
                            },
                          ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildRecentMoment(int count, Moment recent, AppColorScheme colors, AppLocalizations l10n, {required bool isDark}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final local = recent.completedAt.toLocal();
    final momentDay = DateTime(local.year, local.month, local.day);

    final String timeLabel;
    if (momentDay == today) {
      timeLabel = l10n.progressEarlierToday;
    } else if (momentDay == DateTime(today.year, today.month, today.day - 1)) {
      timeLabel = l10n.progressYesterday;
    } else {
      final diff = today.difference(momentDay).inDays;
      timeLabel = l10n.progressDaysAgo(diff);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressYourMoments,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFont(context),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.ctaPrimary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (_) => const MomentsCollectionScreen(),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.momentsCard.withOpacity(colors.momentsCardOpacity),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                        : const Color(0xFFFFFFFF).withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            l10n.progressMomentsCollected(count),
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· $timeLabel',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
