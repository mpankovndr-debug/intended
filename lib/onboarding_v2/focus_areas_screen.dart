import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'daily_reminder_screen.dart';
import 'onboarding_state.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../widgets/focus_area_card.dart';

class FocusAreasScreen extends StatelessWidget {
  const FocusAreasScreen({super.key});

  static const List<String> areas = [
    'Health',
    'Mood',
    'Productivity',
    'Home & organization',
    'Relationships',
    'Creativity',
    'Finances',
    'Self-care',
  ];

  static const Map<String, IconData> areaIcons = {
    'Health': CupertinoIcons.heart,
    'Mood': CupertinoIcons.smiley,
    'Productivity': CupertinoIcons.checkmark_circle,
    'Home & organization': CupertinoIcons.house,
    'Relationships': CupertinoIcons.person_2,
    'Creativity': CupertinoIcons.paintbrush,
    'Finances': CupertinoIcons.money_dollar_circle,
    'Self-care': CupertinoIcons.sparkles,
  };

  static const int maxSelections = 2;

  /// Returns the localized display name for a focus area identifier.
  static String localizedAreaName(AppLocalizations l10n, String area) {
    switch (area) {
      case 'Health':
        return l10n.focusAreaHealth;
      case 'Mood':
        return l10n.focusAreaMood;
      case 'Productivity':
        return l10n.focusAreaProductivity;
      case 'Home & organization':
        return l10n.focusAreaHome;
      case 'Relationships':
        return l10n.focusAreaRelationships;
      case 'Creativity':
        return l10n.focusAreaCreativity;
      case 'Finances':
        return l10n.focusAreaFinances;
      case 'Self-care':
        return l10n.focusAreaSelfCare;
      default:
        return area;
    }
  }

  void _handleAreaTap(BuildContext context, String area) {
    HapticFeedback.selectionClick();

    final state = context.read<OnboardingState>();

    if (state.isSelected(area) || state.focusAreas.length < maxSelections) {
      state.toggleFocusArea(area);
    } else {
      _showLimitReached(context);
    }
  }

  void _showLimitReached(BuildContext context) {
    final colors = context.read<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    HapticFeedback.lightImpact();
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.symmetric(horizontal: 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.88),
                      colors.surfaceLight.withOpacity(0.82),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.45),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.focusAreasLimitTitle,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.focusAreasLimitMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.ctaSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.ctaPrimary.withOpacity(0.85),
                                  colors.ctaSecondary.withOpacity(0.75),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.ctaPrimary.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.textPrimary.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              borderRadius: BorderRadius.circular(16),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                l10n.commonOk,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    HapticFeedback.mediumImpact();

    AnalyticsService.logScreenView('focus_areas');
    AnalyticsService.logOnboardingStepCompleted('focus_areas');

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DailyReminderScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final colors = context.watch<ThemeProvider>().colors;
    final canContinue = state.focusAreas.isNotEmpty;
    final selectedCount = state.focusAreas.length;
    final size = MediaQuery.of(context).size;

    final userName = state.name;
    final hasName = userName != null && userName.isNotEmpty;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.15, -1.0),
                end: const Alignment(-0.15, 1.0),
                colors: [
                  colors.onboardingBg1,
                  colors.onboardingBg2,
                  colors.onboardingBg3,
                  colors.onboardingBg4,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Background orbs
          _buildBackgroundOrbs(size, colors),

          // Content
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // Scrollable content
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
                      child: Center(
                        child: Text(
                          l10n.focusAreasTitle,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.textLabel,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    // Title + subtitle (fixed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasName
                                ? l10n.focusAreasPromptWithName(userName)
                                : l10n.focusAreasPrompt,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              height: 1.3,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.focusAreasChooseCount(selectedCount, maxSelections),
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.ctaSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.focusAreasChangeLater,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Cards (scrollable)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 160),
                        child: Column(
                          children: areas.map((area) {
                            final selected = state.isSelected(area);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: FocusAreaCard(
                                label: localizedAreaName(l10n, area),
                                icon: areaIcons[area]!,
                                selected: selected,
                                onTap: () => _handleAreaTap(context, area),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                // Gradient overlay (behind button)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 180,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.onboardingBg4.withOpacity(0.0),
                            colors.onboardingBg4.withOpacity(0.92),
                            colors.onboardingBg4.withOpacity(0.98),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Continue button (on top)
                if (canContinue)
                  Positioned(
                    left: 28,
                    right: 28,
                    bottom: 95,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.ctaPrimary.withOpacity(0.92),
                                  colors.ctaSecondary.withOpacity(0.88),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CupertinoButton(
                              onPressed: () => _handleContinue(context),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              borderRadius: BorderRadius.circular(20),
                              child: Text(
                                l10n.commonContinue,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOrbs(Size size, AppColorScheme colors) {
    return Stack(
      children: [
        // Orb 1 - Top Right
        Positioned(
          top: size.height * 0.1,
          right: size.width * -0.05,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  colors.surfaceLightest.withOpacity(0.6),
                  colors.borderMedium.withOpacity(0.2),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Orb 2 - Bottom Left
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * -0.08,
          child: Container(
            width: 224,
            height: 224,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  colors.onboardingBg1.withOpacity(0.55),
                  colors.onboardingBg4.withOpacity(0.18),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}

