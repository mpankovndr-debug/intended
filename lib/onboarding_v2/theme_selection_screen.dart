import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'habit_reveal_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/theme_picker.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  double _hintOpacity = 0.0;
  Timer? _hintTimer;

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _showPremiumHintAnimated() {
    _hintTimer?.cancel();
    setState(() => _hintOpacity = 1.0);
    _hintTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _hintOpacity = 0.0);
    });
  }

  void _handleContinue(BuildContext context) {
    HapticFeedback.mediumImpact();

    AnalyticsService.logScreenView('theme_selection');
    AnalyticsService.logOnboardingStepCompleted('theme_selection');

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HabitRevealScreen(),
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
    final colors = context.watch<ThemeProvider>().colors;
    final size = MediaQuery.of(context).size;

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
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 80, 28, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.themeSelectionTitle,
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
                        l10n.themeSelectionSubtitle,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.ctaSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ThemePicker(
                        isPremium: false,
                        onPremiumTap: _showPremiumHintAnimated,
                        onboardingMode: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: AnimatedOpacity(
                          opacity: _hintOpacity,
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.themeSelectionPremiumHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 13,
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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

                // Continue button
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
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
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: CupertinoButton(
                            onPressed: () => _handleContinue(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            borderRadius: BorderRadius.circular(24),
                            child: Text(
                              l10n.themeSelectionConfirm,
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
