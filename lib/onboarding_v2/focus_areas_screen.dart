import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'daily_reminder_screen.dart';
import 'onboarding_state.dart';
// Phase 2: may re-enable philosophy screen
// import '../features/onboarding/screens/philosophy_screen.dart';
import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import '../services/analytics_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/focus_area_card.dart';
import '../widgets/onboarding_progress_bar.dart';

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

  /// Returns the localized subtitle for a focus area identifier.
  static String? localizedAreaSubtitle(AppLocalizations l10n, String area) {
    switch (area) {
      case 'Health':
        return l10n.focusAreaHealthSub;
      case 'Mood':
        return l10n.focusAreaMoodSub;
      case 'Productivity':
        return l10n.focusAreaProductivitySub;
      case 'Home & organization':
        return l10n.focusAreaHomeSub;
      case 'Relationships':
        return l10n.focusAreaRelationshipsSub;
      case 'Creativity':
        return l10n.focusAreaCreativitySub;
      case 'Finances':
        return l10n.focusAreaFinancesSub;
      case 'Self-care':
        return l10n.focusAreaSelfCareSub;
      default:
        return null;
    }
  }

  static String _resolvePathTitle(AppLocalizations l10n, IntentionPath path) {
    switch (path.titleKey) {
      case 'pathGentleMorningsTitle':
        return l10n.pathGentleMorningsTitle;
      case 'pathFindingCalmTitle':
        return l10n.pathFindingCalmTitle;
      case 'pathGratitudeSelfLoveTitle':
        return l10n.pathGratitudeSelfLoveTitle;
      case 'pathWindingDownTitle':
        return l10n.pathWindingDownTitle;
      default:
        return path.titleKey;
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
                        fontFamily: AppTextStyles.bodyFont(context),
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
                        borderRadius: BorderRadius.circular(24),
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
                              borderRadius: BorderRadius.circular(24),
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
                              borderRadius: BorderRadius.circular(24),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                l10n.commonOk,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
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

    final pathKey = state.selectedIntentionPath;
    final isOwnWay = pathKey == IntentionPathId.yourOwnWay.key;
    IntentionPath? selectedPath;
    if (!isOwnWay) {
      selectedPath = IntentionPath.getById(IntentionPathId.fromKey(pathKey));
      // Re-apply defaults whenever the path has changed since last pre-selection.
      // This handles back-navigation: user changes path → comes forward → reset.
      if (pathKey != state.lastPreselectedPathKey &&
          selectedPath.defaultFocusAreas.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          state.applyPathDefaults(selectedPath!.defaultFocusAreas, pathKey);
        });
      }
    }

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
                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: OnboardingProgressBar(
                        currentStep: 2,
                        totalSteps: 4,
                        onBack: () => Navigator.pop(context),
                      ),
                    ),

                    // Title + subtitle (fixed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOwnWay
                                ? (hasName
                                    ? l10n.focusAreasPromptWithName(userName)
                                    : l10n.focusAreasPrompt)
                                : l10n.focusAreasStartingPointsTitle,
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
                            isOwnWay
                                ? l10n.focusAreasChooseCount(selectedCount, maxSelections)
                                : l10n.focusAreasStartingPointsSubtext(
                                    _resolvePathTitle(l10n, selectedPath!)),
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.ctaSecondary,
                            ),
                          ),
                          if (isOwnWay) ...[
                            const SizedBox(height: 6),
                            Text(
                              l10n.focusAreasChangeLater,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
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
                                subtitle: localizedAreaSubtitle(l10n, area),
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
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
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
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: CupertinoButton(
                              onPressed: () => _handleContinue(context),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              borderRadius: BorderRadius.circular(24),
                              child: Text(
                                l10n.commonContinue,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
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
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
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
            ),
          ),
        ),

        // Orb 2 - Bottom Left
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * -0.08,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
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
            ),
          ),
        ),
      ],
    );
  }
}

