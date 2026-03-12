import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show refreshHomeWidget;
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

/// Describes a theme entry for the picker UI.
typedef _ThemeEntry = ({
  AppTheme theme,
  String name,
  Color swatchColor,
  Color accentColor,
});

class ThemePicker extends StatelessWidget {
  final bool isPremium;
  final bool hasBoost;
  final VoidCallback onPremiumTap;
  final VoidCallback? onBoostTap;
  final bool compact;

  /// When true, only show the 4 onboarding themes (2 free + 2 locked).
  final bool onboardingMode;

  const ThemePicker({
    super.key,
    required this.isPremium,
    required this.onPremiumTap,
    this.hasBoost = false,
    this.onBoostTap,
    this.compact = false,
    this.onboardingMode = false,
  });

  List<_ThemeEntry> _allThemes(AppLocalizations l10n) => [
    // Row 1: warm neutrals
    (theme: AppTheme.warmClay,     name: l10n.themeWarmClay,     swatchColor: const Color(0xFFF2EAE2), accentColor: const Color(0xFF8C6652)),
    (theme: AppTheme.sandDune,     name: l10n.themeSandDune,     swatchColor: const Color(0xFFF0EBE2), accentColor: const Color(0xFF5C4E3E)),
    // Row 2: warm colors
    (theme: AppTheme.softDusk,     name: l10n.themeSoftDusk,     swatchColor: const Color(0xFFF0D4CE), accentColor: const Color(0xFFD4707A)),
    (theme: AppTheme.goldenHour,   name: l10n.themeGoldenHour,   swatchColor: const Color(0xFFF2DFD0), accentColor: const Color(0xFFC07A42)),
    // Row 3: cool colors
    (theme: AppTheme.iris,         name: l10n.themeIris,         swatchColor: const Color(0xFFEAE4F2), accentColor: const Color(0xFF5547A0)),
    (theme: AppTheme.clearSky,     name: l10n.themeClearSky,     swatchColor: const Color(0xFFE8EFF6), accentColor: const Color(0xFF4A7BAD)),
    // Row 4: greens
    (theme: AppTheme.morningSlate, name: l10n.themeMorningSlate, swatchColor: const Color(0xFFE9EEEC), accentColor: const Color(0xFF4E7A75)),
    (theme: AppTheme.forestFloor,  name: l10n.themeForestFloor,  swatchColor: const Color(0xFFF2F5F0), accentColor: const Color(0xFF5A8A5C)),
    // Row 5: dark modes
    (theme: AppTheme.deepFocus,    name: l10n.themeDeepFocus,    swatchColor: const Color(0xFF4A4A50), accentColor: const Color(0xFFC9A96E)),
    (theme: AppTheme.nightBloom,   name: l10n.themeNightBloom,   swatchColor: const Color(0xFF3A3D5A), accentColor: const Color(0xFFB0A2D8)),
  ];

  List<_ThemeEntry> _onboardingThemes(AppLocalizations l10n) => [
    (theme: AppTheme.warmClay,  name: l10n.themeWarmClay,  swatchColor: const Color(0xFFF2EAE2), accentColor: const Color(0xFF8C6652)),
    (theme: AppTheme.iris,      name: l10n.themeIris,      swatchColor: const Color(0xFFEAE4F2), accentColor: const Color(0xFF5547A0)),
    (theme: AppTheme.deepFocus, name: l10n.themeDeepFocus, swatchColor: const Color(0xFF4A4A50), accentColor: const Color(0xFFC9A96E)),
    (theme: AppTheme.softDusk,  name: l10n.themeSoftDusk,  swatchColor: const Color(0xFFF0D4CE), accentColor: const Color(0xFFD4707A)),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.theme;
    final l10n = AppLocalizations.of(context);

    final themes = onboardingMode ? _onboardingThemes(l10n) : _allThemes(l10n);

    if (onboardingMode) {
      return _buildOnboardingGrid(context, themes, themeProvider, currentTheme);
    }

    return _buildFullGrid(context, themes, themeProvider, currentTheme);
  }

  Widget _buildOnboardingGrid(
    BuildContext context,
    List<_ThemeEntry> themes,
    ThemeProvider themeProvider,
    AppTheme currentTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Free themes (top row, larger)
        Row(
          children: [
            for (var i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 0.75,
                  child: _buildCard(
                    context,
                    themes[i],
                    themeProvider,
                    currentTheme,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Locked teaser (bottom row, compact)
        Row(
          children: [
            for (var i = 2; i < 4; i++) ...[
              if (i > 2) const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: _buildCard(
                    context,
                    themes[i],
                    themeProvider,
                    currentTheme,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFullGrid(
    BuildContext context,
    List<_ThemeEntry> themes,
    ThemeProvider themeProvider,
    AppTheme currentTheme,
  ) {
    final rows = <Widget>[];
    for (var i = 0; i < themes.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: compact ? 2.0 : 1.1,
                child: _buildCard(context, themes[i], themeProvider, currentTheme),
              ),
            ),
            const SizedBox(width: 12),
            if (i + 1 < themes.length)
              Expanded(
                child: AspectRatio(
                  aspectRatio: compact ? 2.0 : 1.1,
                  child: _buildCard(context, themes[i + 1], themeProvider, currentTheme),
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildCard(
    BuildContext context,
    _ThemeEntry entry,
    ThemeProvider themeProvider,
    AppTheme currentTheme,
  ) {
    final isSelected = currentTheme == entry.theme;
    final isLocked = themeProvider.isLocked(
      entry.theme,
      hasBoost: hasBoost,
      isPremium: isPremium,
    );
    final isDark = entry.theme.isDark;
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          if (themeProvider.isBoostTheme(entry.theme) && onBoostTap != null) {
            onBoostTap!();
          } else {
            onPremiumTap();
          }
        } else {
          context.read<ThemeProvider>().setTheme(entry.theme);
          // Update home screen widget with new theme
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) refreshHomeWidget(context);
          });
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: entry.swatchColor,
                border: isSelected
                    ? Border.all(color: entry.accentColor, width: 2.5)
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: compact ? 22 : 28,
                        height: compact ? 22 : 28,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: entry.accentColor,
                          ),
                        ),
                      ),
                      SizedBox(width: compact ? 8 : 10),
                      Flexible(
                        child: Text(
                          entry.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 13 : 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.75)
                                : Colors.black.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.accentColor,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: entry.swatchColor,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: compact ? 22 : 28,
                            height: compact ? 22 : 28,
                            child: Center(
                              child: Icon(
                                Icons.lock_rounded,
                                size: compact ? 16 : 18,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.35)
                                    : Colors.black.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          SizedBox(width: compact ? 8 : 10),
                          Flexible(
                            child: Text(
                              entry.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: compact ? 13 : 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.50)
                                    : Colors.black.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
