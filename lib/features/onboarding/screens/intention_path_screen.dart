import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/intention_path.dart';
import '../../../onboarding_v2/focus_areas_screen.dart';
import '../../../onboarding_v2/onboarding_state.dart';
import '../../../onboarding_v2/welcome_v2_screen.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/onboarding_progress_bar.dart';

class IntentionPathScreen extends StatefulWidget {
  const IntentionPathScreen({super.key});

  @override
  State<IntentionPathScreen> createState() => _IntentionPathScreenState();
}

class _IntentionPathScreenState extends State<IntentionPathScreen> {
  IntentionPathId? _selected;

  String _resolveTitle(AppLocalizations l10n, String titleKey) {
    switch (titleKey) {
      case 'pathGentleMorningsTitle':
        return l10n.pathGentleMorningsTitle;
      case 'pathFindingCalmTitle':
        return l10n.pathFindingCalmTitle;
      case 'pathGratitudeSelfLoveTitle':
        return l10n.pathGratitudeSelfLoveTitle;
      case 'pathWindingDownTitle':
        return l10n.pathWindingDownTitle;
      case 'pathYourOwnWayTitle':
        return l10n.pathYourOwnWayTitle;
      default:
        return titleKey;
    }
  }

  String _resolveSubtitle(AppLocalizations l10n, String subtitleKey) {
    switch (subtitleKey) {
      case 'pathGentleMorningsSubtitle':
        return l10n.pathGentleMorningsSubtitle;
      case 'pathFindingCalmSubtitle':
        return l10n.pathFindingCalmSubtitle;
      case 'pathGratitudeSelfLoveSubtitle':
        return l10n.pathGratitudeSelfLoveSubtitle;
      case 'pathWindingDownSubtitle':
        return l10n.pathWindingDownSubtitle;
      case 'pathYourOwnWaySubtitle':
        return l10n.pathYourOwnWaySubtitle;
      default:
        return subtitleKey;
    }
  }

  void _handleContinue(BuildContext context, {IntentionPathId? override}) {
    HapticFeedback.mediumImpact();
    final pathId = override ?? _selected ?? IntentionPathId.yourOwnWay;
    context.read<OnboardingState>().setSelectedIntentionPath(pathId.key);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const FocusAreasScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeV2Screen(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final size = MediaQuery.of(context).size;
    final canContinue = _selected != null;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
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
          _buildOrbs(size, colors),

          // Content
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: OnboardingProgressBar(
                        currentStep: 1,
                        totalSteps: 4,
                        onBack: () => _handleBack(context),
                      ),
                    ),

                    // Headline + subtext
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.intentionPathHeadline,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              height: 1.25,
                            ).copyWith(color: colors.textPrimary),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.intentionPathSubtext,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.ctaSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Cards
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 200),
                        child: Column(
                          children: IntentionPath.all.map((path) {
                            final isSelected = _selected == path.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _IntentionPathCard(
                                path: path,
                                title: _resolveTitle(l10n, path.titleKey),
                                subtitle:
                                    _resolveSubtitle(l10n, path.subtitleKey),
                                selected: isSelected,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selected = path.id);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                // Gradient fade behind button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 160,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.onboardingBg4.withValues(alpha: 0.0),
                            colors.onboardingBg4.withValues(alpha: 0.92),
                            colors.onboardingBg4.withValues(alpha: 0.98),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Continue button
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: 60,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: canContinue
                          ? [
                              BoxShadow(
                                color: colors.ctaPrimary.withValues(alpha: 0.30),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: canContinue
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.ctaPrimary,
                                  colors.ctaSecondary,
                                ],
                              )
                            : null,
                        color: canContinue
                            ? null
                            : Color.alphaBlend(
                                colors.ctaPrimary.withValues(alpha: 0.32),
                                colors.onboardingBg4,
                              ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: CupertinoButton(
                        onPressed:
                            canContinue ? () => _handleContinue(context) : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        borderRadius: BorderRadius.circular(24),
                        child: Text(
                          l10n.commonContinue,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: canContinue
                                ? const Color(0xFFFFFFFF)
                                : Color.alphaBlend(
                                    colors.ctaPrimary.withValues(alpha: 0.65),
                                    colors.onboardingBg4,
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

  Widget _buildOrbs(Size size, dynamic colors) {
    return Stack(
      children: [
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
                    colors.surfaceLightest.withValues(alpha: 0.6),
                    colors.borderMedium.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.25,
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
                    colors.onboardingBg1.withValues(alpha: 0.55),
                    colors.onboardingBg4.withValues(alpha: 0.18),
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

class _IntentionPathCard extends StatefulWidget {
  const _IntentionPathCard({
    required this.path,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IntentionPath path;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_IntentionPathCard> createState() => _IntentionPathCardState();
}

class _IntentionPathCardState extends State<_IntentionPathCard> {
  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final accent = widget.path.accentColor;
    final sel = widget.selected;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: sel
                  ? accent.withValues(alpha: 0.22)
                  : colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: sel ? 22 : 16,
              spreadRadius: sel ? 1 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: sel
                      ? [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.80),
                          accent.withValues(alpha: 0.38),
                        ]
                      : [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.65),
                          colors.surfaceLight.withValues(alpha: 0.60),
                        ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: sel
                      ? accent.withValues(alpha: 0.72)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.40),
                  width: sel ? 2.0 : 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: colors.textPrimary.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sel) ...[
                    const SizedBox(width: 14),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark,
                        size: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
