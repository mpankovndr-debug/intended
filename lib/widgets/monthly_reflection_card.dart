import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/monthly_reflection_data.dart';
import '../screens/paywall_screen.dart';
import '../services/monthly_reflection_service.dart';
import '../state/user_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
import '../utils/text_styles.dart';

/// Monthly reflection card — premium-only feature.
/// Appears on the Progress tab after 30+ days of use.
class MonthlyReflectionCard extends StatefulWidget {
  const MonthlyReflectionCard({super.key});

  @override
  State<MonthlyReflectionCard> createState() => _MonthlyReflectionCardState();
}

class _MonthlyReflectionCardState extends State<MonthlyReflectionCard>
    with SingleTickerProviderStateMixin {
  MonthlyReflectionData? _data;
  bool _loading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _load();
  }

  Future<void> _load() async {
    final data = await MonthlyReflectionService.getCurrentReflection();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
    if (data != null && !_animController.isCompleted) {
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _data == null) return const SizedBox.shrink();

    final userState = context.watch<UserState>();
    final isPremium = userState.hasSubscription;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: isPremium
            ? _buildFullCard(context, _data!)
            : _buildTeaserCard(context, _data!),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Full card (Intended+ users)
  // ---------------------------------------------------------------------------

  Widget _buildFullCard(BuildContext context, MonthlyReflectionData data) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().theme.isDark
                ? colors.cardBackground.withValues(alpha: colors.cardBackgroundOpacity)
                : CupertinoColors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: context.watch<ThemeProvider>().theme.isDark
                  ? colors.borderCard.withValues(alpha: colors.borderCardOpacity)
                  : CupertinoColors.white.withValues(alpha: 0.45),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month range header
              Text(
                data.monthRange,
                style: AppTextStyles.caption(context),
              ),
              const SizedBox(height: 12),

              // Section 1: THIS MONTH
              _buildSectionLabel(l10n.monthlyReflectionSectionOverview, colors),
              const SizedBox(height: 8),
              _reflectionText(
                context,
                l10n.monthlyReflectionOverview(data.daysActive, data.totalDays),
                colors,
              ),

              // Weekly activity dots
              if (data.weeklyActivity != null && data.weeklyActivity!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildWeeklyDots(colors, data.weeklyActivity!),
              ],

              // Section 2: TRENDS
              if (data.bestWeekRange != null && data.bestWeekDays != null) ...[
                const SizedBox(height: 16),
                _buildSectionDivider(colors),
                const SizedBox(height: 16),
                _buildSectionLabel(l10n.monthlyReflectionSectionTrends, colors),
                const SizedBox(height: 8),
                _reflectionText(
                  context,
                  l10n.monthlyReflectionBestWeek(data.bestWeekRange!, data.bestWeekDays!),
                  colors,
                ),
              ],

              // Most consistent habit
              if (data.mostConsistentHabit != null) ...[
                const SizedBox(height: 8),
                _reflectionText(
                  context,
                  l10n.monthlyReflectionConsistentHabit(
                    localizeHabitName(data.mostConsistentHabit!, l10n),
                  ),
                  colors,
                ),
              ],

              // Top focus area
              if (data.topFocusArea != null) ...[
                const SizedBox(height: 16),
                _buildSectionDivider(colors),
                const SizedBox(height: 16),
                _buildSectionLabel(l10n.monthlyReflectionSectionNotice, colors),
                const SizedBox(height: 8),
                _reflectionText(
                  context,
                  l10n.monthlyReflectionTopArea(
                    localizeCategoryName(data.topFocusArea!, l10n),
                  ),
                  colors,
                ),
              ],

              // Section 3: GROWTH
              const SizedBox(height: 16),
              _buildSectionDivider(colors),
              const SizedBox(height: 16),
              _buildSectionLabel(l10n.monthlyReflectionSectionGrowth, colors),
              const SizedBox(height: 8),
              _reflectionText(
                context,
                _growthText(l10n, data),
                colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Teaser card (free users)
  // ---------------------------------------------------------------------------

  Widget _buildTeaserCard(BuildContext context, MonthlyReflectionData data) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().theme.isDark
                ? colors.cardBackground.withValues(alpha: colors.cardBackgroundOpacity)
                : CupertinoColors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: context.watch<ThemeProvider>().theme.isDark
                  ? colors.borderCard.withValues(alpha: colors.borderCardOpacity)
                  : CupertinoColors.white.withValues(alpha: 0.45),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.monthRange,
                style: AppTextStyles.caption(context),
              ),
              const SizedBox(height: 12),
              _buildSectionLabel(l10n.monthlyReflectionSectionOverview, colors),
              const SizedBox(height: 8),
              _reflectionText(
                context,
                l10n.monthlyReflectionOverview(data.daysActive, data.totalDays),
                colors,
              ),
              const SizedBox(height: 16),
              // Blurred premium hint
              Text(
                l10n.monthlyReflectionNoData,
                style: AppTextStyles.body(context).copyWith(
                  color: colors.textPrimary.withValues(alpha: 0.45),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              // Unlock button
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.5),
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      builder: (_) =>
                          const PaywallScreen(source: 'monthly_reflection'),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.ctaPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.monthlyReflectionUnlock,
                          style: AppTextStyles.caption(context).copyWith(
                            color: colors.ctaPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 12,
                          color: colors.ctaPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared building blocks
  // ---------------------------------------------------------------------------

  Widget _buildSectionLabel(String label, AppColorScheme colors) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: colors.textSecondary,
      ),
    );
  }

  Widget _buildSectionDivider(AppColorScheme colors) {
    return Container(
      height: 0.5,
      color: colors.divider.withValues(alpha: colors.dividerOpacity),
    );
  }

  Widget _reflectionText(BuildContext context, String text, AppColorScheme colors) {
    return Text(
      text,
      style: AppTextStyles.body(context).copyWith(
        color: colors.textPrimary,
        height: 1.55,
      ),
    );
  }

  /// Mini bar chart showing active days per week across the month.
  Widget _buildWeeklyDots(AppColorScheme colors, List<int> weeklyActivity) {
    final maxDays = 7;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weeklyActivity.map((days) {
        final fraction = days / maxDays;
        return Column(
          children: [
            Container(
              width: 24,
              height: 40,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 24,
                height: (fraction * 40).clamp(4, 40),
                decoration: BoxDecoration(
                  color: colors.ctaAlternative.withValues(alpha: 0.3 + fraction * 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$days',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _growthText(AppLocalizations l10n, MonthlyReflectionData data) {
    return switch (data.growth) {
      'up' => l10n.monthlyReflectionGrowthUp,
      'down' => l10n.monthlyReflectionGrowthDown,
      'steady' => l10n.monthlyReflectionGrowthSteady,
      'first' => l10n.monthlyReflectionFirstMonth,
      _ => l10n.monthlyReflectionGrowthSteady,
    };
  }
}
