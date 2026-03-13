import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/reflection_data.dart';
import '../services/week_stats_service.dart';
import '../state/user_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';

/// Determines which tier to render.
enum ShareCardTier { tier1, tier2, tier3 }

ShareCardTier determineTier(WeekStats stats, ReflectionData? reflection) {
  final daysActive = stats.dailyActivity.where((d) => d).length;
  final completionCount = stats.completionCount;
  final hasPatternData = reflection?.hasPatternData ?? false;
  final hasFocusData = reflection?.topFocusArea != null;

  if (daysActive <= 2 || completionCount < 3) return ShareCardTier.tier1;
  if (daysActive >= 5 || hasPatternData || hasFocusData) return ShareCardTier.tier3;
  return ShareCardTier.tier2;
}

/// 1080×1920 share card with 3 tiers based on user activity.
class TieredShareCard extends StatelessWidget {
  final WeekStats stats;
  final ReflectionData? reflection;

  const TieredShareCard({
    super.key,
    required this.stats,
    this.reflection,
  });

  @override
  Widget build(BuildContext context) {
    final tier = determineTier(stats, reflection);
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.theme;
    final colors = themeProvider.colors;
    final l10n = AppLocalizations.of(context);
    final userName = userNameNotifier.value;
    final daysActive = stats.dailyActivity.where((d) => d).length;

    // Number gradient colors per theme
    final numberGradient = _numberGradientForTheme(theme);
    final t1 = colors.textPrimary;
    final t2 = colors.textSecondary;
    final t3 = colors.textTertiary;
    final accent = colors.ctaPrimary;

    return SizedBox(
      width: 1080,
      height: 1920,
      child: Stack(
        children: [
          // Background
          _buildBackground(colors, accent),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 72, 72, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: "Your week" + date range
                _buildHeader(l10n, colors, accent, t1, t2),

                // Header divider
                const SizedBox(height: 36),
                Container(
                  height: 3,
                  color: accent.withValues(alpha:0.6),
                ),

                // Main content varies by tier
                Expanded(
                  child: _buildTierContent(
                    tier: tier,
                    theme: theme,
                    l10n: l10n,
                    colors: colors,
                    t1: t1,
                    t2: t2,
                    t3: t3,
                    accent: accent,
                    numberGradient: numberGradient,
                    daysActive: daysActive,
                    userName: userName,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Background
  // ---------------------------------------------------------------------------

  Widget _buildBackground(AppColorScheme colors, Color accent) {
    final bg1 = colors.onboardingBg1;
    final bg2 = colors.onboardingBg2;
    final bg3 = colors.onboardingBg3;

    return Stack(
      children: [
        // Base linear gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.4, -1.0),
                end: const Alignment(0.4, 1.0),
                colors: [bg1, bg2, bg3],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Radial glow in center — gives depth and warmth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.1),
                radius: 0.9,
                colors: [
                  accent.withValues(alpha: 0.18),
                  accent.withValues(alpha: 0.06),
                  const Color(0x00000000),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(AppLocalizations l10n, AppColorScheme colors,
      Color accent, Color t1, Color t2) {
    final weekRange = reflection?.weekRange ?? _fallbackWeekRange();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          l10n.progressTitle,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: t1,
            letterSpacing: -0.02 * 56,
          ),
        ),
        Text(
          weekRange,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 38,
            fontWeight: FontWeight.w500,
            color: t2,
          ),
        ),
      ],
    );
  }

  String _fallbackWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[monday.month - 1]} ${monday.day} \u2013 ${months[sunday.month - 1]} ${sunday.day}';
  }

  // ---------------------------------------------------------------------------
  // Tier content
  // ---------------------------------------------------------------------------

  Widget _buildTierContent({
    required ShareCardTier tier,
    required AppTheme theme,
    required AppLocalizations l10n,
    required AppColorScheme colors,
    required Color t1,
    required Color t2,
    required Color t3,
    required Color accent,
    required List<Color> numberGradient,
    required int daysActive,
    required String? userName,
  }) {
    switch (tier) {
      case ShareCardTier.tier1:
        return _buildTier1(l10n, t1, t2, t3, accent, numberGradient, daysActive, userName, theme);
      case ShareCardTier.tier2:
        return _buildTier2(l10n, colors, t1, t2, t3, accent, numberGradient, daysActive, userName, theme);
      case ShareCardTier.tier3:
        return _buildTier3(l10n, colors, t1, t2, t3, accent, numberGradient, daysActive, userName, theme);
    }
  }

  // ---------------------------------------------------------------------------
  // Tier 1 — "The Number"
  // ---------------------------------------------------------------------------

  Widget _buildTier1(AppLocalizations l10n, Color t1, Color t2, Color t3,
      Color accent, List<Color> numberGradient, int daysActive, String? userName, AppTheme theme) {
    final subtitleText = daysActive == 1
        ? l10n.shareCardSubtitleSingular
        : l10n.shareCardSubtitlePlural;

    return Column(
      children: [
        // Dynamically centered hero number
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero number — 280px
                _buildGradientNumber('$daysActive', 280, numberGradient),
                const SizedBox(height: 24),
                // Subtitle — 48px
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: t2,
                  ),
                ),
                const SizedBox(height: 160),
                // Day dots
                _buildDayDots(t3, accent),
              ],
            ),
          ),
        ),

        // Bottom section
        _buildBottomBranding(userName, t1, t2, accent, theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tier 2 — "The Story"
  // ---------------------------------------------------------------------------

  Widget _buildTier2(AppLocalizations l10n, AppColorScheme colors,
      Color t1, Color t2, Color t3, Color accent, List<Color> numberGradient,
      int daysActive, String? userName, AppTheme theme) {

    return Column(
      children: [
        const SizedBox(height: 140),
        // Hero number — 200px
        _buildGradientNumber('$daysActive', 200, numberGradient),
        const SizedBox(height: 24),
        // Subtitle — 42px
        Text(
          l10n.shareCardSubtitleDays,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 42,
            fontWeight: FontWeight.w400,
            color: t2,
          ),
        ),
        const SizedBox(height: 160),
        // Habit list
        _buildHabitList(l10n, t1, accent, 46, 40, 3, 36),
        const Spacer(),
        // Day dots
        _buildDayDots(t3, accent),
        const SizedBox(height: 140),
        // Bottom branding
        _buildBottomBranding(userName, t1, t2, accent, theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tier 3 — "The Reflection"
  // ---------------------------------------------------------------------------

  Widget _buildTier3(AppLocalizations l10n, AppColorScheme colors,
      Color t1, Color t2, Color t3, Color accent, List<Color> numberGradient,
      int daysActive, String? userName, AppTheme theme) {

    final insightLine = _getInsightLine(l10n);

    return Column(
      children: [
        const SizedBox(height: 80),
        // Hero number — 160px
        _buildGradientNumber('$daysActive', 160, numberGradient),
        const SizedBox(height: 20),
        // Subtitle — 42px
        Text(
          l10n.shareCardSubtitleDays,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 42,
            fontWeight: FontWeight.w400,
            color: t2,
          ),
        ),
        const SizedBox(height: 120),
        // Habit list
        _buildHabitList(l10n, t1, accent, 42, 36, 3, 32),
        const Spacer(),
        // Day dots
        _buildDayDots(t3, accent),

        // Insight section
        if (insightLine != null) ...[
          const SizedBox(height: 80),
          // Insight divider
          Container(
            height: 2,
            color: t1.withValues(alpha:0.1),
          ),
          const SizedBox(height: 80),
          // Insight text — italic, 48px
          Text(
            '"$insightLine"',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 48,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: t1,
              height: 1.4,
            ),
          ),
        ],

        const SizedBox(height: 40),
        // Bottom branding
        _buildBottomBranding(userName, t1, t2, accent, theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared components
  // ---------------------------------------------------------------------------

  Widget _buildGradientNumber(String text, double fontSize, List<Color> gradient) {
    // Convert 135deg to start/end offsets
    // 135deg = top-left to bottom-right
    final rad = 135 * math.pi / 180;
    final dx = math.cos(rad);
    final dy = math.sin(rad);

    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        foreground: Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(fontSize * dx, fontSize * dy),
            gradient,
          ),
        height: 0.9,
      ),
    );
  }

  Widget _buildDayDots(Color t3, Color accent) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final activity = stats.dailyActivity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) {
        final isActive = i < activity.length && activity[i];
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 42 / 2),
          child: Column(
            children: [
              Text(
                labels[i],
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: isActive ? accent : t3.withValues(alpha:0.5),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? accent : t3.withValues(alpha: 0.3),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.5),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: accent.withValues(alpha: 0.25),
                            blurRadius: 32,
                            spreadRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHabitList(AppLocalizations l10n, Color t1, Color accent,
      double textSize, double checkSize, double strokeWidth, double rowSpacing) {
    final habits = stats.completedHabits;
    if (habits.isEmpty) return const SizedBox.shrink();

    final habitsToShow = habits.take(3).toList();
    final hiddenCount = habits.length - 3;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...habitsToShow.map((habit) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowSpacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Checkmark box
                  Container(
                    width: checkSize + 12,
                    height: checkSize + 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: accent.withValues(alpha:0.15),
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: Size(checkSize * 0.55, checkSize * 0.55),
                        painter: _CheckmarkPainter(
                          color: accent,
                          strokeWidth: strokeWidth,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      localizeHabitName(habit, l10n),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: textSize,
                        fontWeight: FontWeight.w500,
                        color: t1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (hiddenCount > 0)
            Padding(
              padding: EdgeInsets.only(left: checkSize + 12 + 24),
              child: Text(
                l10n.progressMore(hiddenCount),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: textSize - 4,
                  fontWeight: FontWeight.w400,
                  color: t1.withValues(alpha:0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBranding(String? userName, Color t1, Color t2, Color accent, AppTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // P.S. {name}
        if (userName != null && userName.isNotEmpty) ...[
          Text(
            'P.S. $userName',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 36,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: t2,
            ),
          ),
          const SizedBox(height: 40),
        ],
        // App icon — use midnight variant for dark themes
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            _iconAssetForTheme(theme),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        // "INTENDED" wordmark
        Text(
          'INTENDED',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 42,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15 * 42,
            color: t1,
          ),
        ),
        const SizedBox(height: 16),
        // Tagline
        Text(
          'intention, not perfection',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 32,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.02 * 32,
            color: t2,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Insight line
  // ---------------------------------------------------------------------------

  String? _getInsightLine(AppLocalizations l10n) {
    if (reflection == null) return null;
    final data = reflection!;

    // Priority: pattern > focus
    if (data.hasPatternData) {
      return _patternInsight(l10n, data);
    }
    if (data.topFocusArea != null) {
      return _focusInsight(l10n, data);
    }
    return null;
  }

  String? _patternInsight(AppLocalizations l10n, ReflectionData data) {
    if (data.bestDay != null && data.secondBestDay != null) {
      final d1 = _localizedDay(l10n, data.bestDay!);
      final d2 = _localizedDay(l10n, data.secondBestDay!);
      return l10n.shareCardInsightTwoDays(d1, d2);
    }
    if (data.bestDay != null) {
      return l10n.shareCardInsightOneDay(_localizedDay(l10n, data.bestDay!));
    }
    return null;
  }

  String? _focusInsight(AppLocalizations l10n, ReflectionData data) {
    if (data.topFocusArea != null) {
      return l10n.shareCardInsightFocus(data.topFocusArea!);
    }
    return null;
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

  // ---------------------------------------------------------------------------
  // Theme-specific number gradient colors (135deg)
  // ---------------------------------------------------------------------------

  static String _iconAssetForTheme(AppTheme theme) {
    return switch (theme) {
      AppTheme.warmClay =>     'assets/images/intended-icon-warmclay-1024.png',
      AppTheme.iris =>         'assets/images/intended-icon-iris-1024.png',
      AppTheme.clearSky =>     'assets/images/intended-icon-clearsky-1024.png',
      AppTheme.morningSlate => 'assets/images/intended-icon-morningslate-1024.png',
      AppTheme.softDusk =>     'assets/images/intended-icon-softdusk-1024.png',
      AppTheme.forestFloor =>  'assets/images/intended-icon-forestfloor-1024.png',
      AppTheme.goldenHour =>   'assets/images/intended-icon-goldenhour-1024.png',
      AppTheme.sandDune =>     'assets/images/intended-icon-sanddune-1024.png',
      AppTheme.deepFocus =>    'assets/images/intended-icon-deepfocus-1024.png',
      AppTheme.nightBloom =>   'assets/images/intended-icon-nightbloom-1024.png',
    };
  }

  static List<Color> _numberGradientForTheme(AppTheme theme) {
    return switch (theme) {
      AppTheme.warmClay =>    [const Color(0xFF8B7355), const Color(0xFF6A563D)],
      AppTheme.iris =>        [const Color(0xFF6B5B95), const Color(0xFF5A4A80)],
      AppTheme.clearSky =>    [const Color(0xFF4A7A9B), const Color(0xFF3A6A88)],
      AppTheme.morningSlate => [const Color(0xFF5A7A72), const Color(0xFF4A6A60)],
      AppTheme.softDusk =>    [const Color(0xFFD4707A), const Color(0xFFC45A65)],
      AppTheme.forestFloor => [const Color(0xFF5A8A5C), const Color(0xFF4A7A4C)],
      AppTheme.goldenHour =>  [const Color(0xFFC07A42), const Color(0xFFA86830)],
      AppTheme.sandDune =>    [const Color(0xFF5C4E3E), const Color(0xFF4A3E30)],
      AppTheme.deepFocus =>   [const Color(0xFFC9A96E), const Color(0xFFB89858)],
      AppTheme.nightBloom =>  [const Color(0xFFE0DCF0), const Color(0xFFC2B8E6)],
    };
  }
}

/// Draws a checkmark icon.
class _CheckmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _CheckmarkPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.50)
      ..lineTo(size.width * 0.40, size.height * 0.80)
      ..lineTo(size.width * 0.85, size.height * 0.20);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
