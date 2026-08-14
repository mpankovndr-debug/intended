import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import '../services/analytics_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/app_toast.dart';
import '../widgets/focus_area_card.dart';
import '../widgets/onboarding_progress_bar.dart';
import 'commitment_screen.dart';
import 'focus_areas_screen.dart';
import 'onboarding_state.dart';
import 'welcome_v2_screen.dart';

/// Conversation-style onboarding step that hosts the path picker (Phase A)
/// and the focus-area picker (Phase B) on a single Navigator route.
///
/// The two phases swap via [AnimatedCrossFade] so the user perceives one
/// continuous "tell us about you" moment rather than two separate forms.
/// Going back from Phase B returns to Phase A on the same route — only
/// from Phase A does back leave this screen entirely.
///
/// Replaces the old `IntentionPathScreen` → `FocusAreasScreen` two-route
/// flow in onboarding. Both old screens still exist (focus-area picker
/// constants are reused by Profile) but are no longer reached during
/// first-run onboarding.
class TellUsAboutYouScreen extends StatefulWidget {
  const TellUsAboutYouScreen({super.key});

  @override
  State<TellUsAboutYouScreen> createState() => _TellUsAboutYouScreenState();
}

enum _Phase { path, focus }

class _TellUsAboutYouScreenState extends State<TellUsAboutYouScreen> {
  _Phase _phase = _Phase.path;
  IntentionPathId? _selectedPath;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('tell_us_about_you');
  }

  // ── Navigation handlers ───────────────────────────────────────

  void _handleBack() {
    HapticFeedback.selectionClick();
    if (_phase == _Phase.focus) {
      // Move back to Phase A within this route — no Navigator pop.
      setState(() => _phase = _Phase.path);
      return;
    }
    // Phase A → leave the screen entirely. pushReplacement matches the
    // existing welcome-to-onboarding navigation idiom.
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

  void _handleContinue() {
    HapticFeedback.mediumImpact();

    if (_phase == _Phase.path) {
      // Defensive default — the continue button is gated on _selectedPath
      // != null, so this fallback should never fire in practice.
      // gentleMornings (the most universal first-pick) is the right safety
      // net now that yourOwnWay is hidden from the picker.
      final pathId = _selectedPath ?? IntentionPathId.gentleMornings;
      final state = context.read<OnboardingState>();

      state.setSelectedIntentionPath(pathId.key);
      AnalyticsService.logOnboardingStepCompleted('tell_us_path');

      // Apply path defaults the first time we land on Phase B for this path.
      // The state tracks which path was last applied, so flipping back to
      // Phase A and changing the path re-runs this on the next forward.
      final path = IntentionPath.getById(pathId);
      if (state.lastPreselectedPathKey != pathId.key) {
        state.applyPathDefaults(path.defaultFocusAreas, pathId.key);
      }

      setState(() => _phase = _Phase.focus);
      return;
    }

    // Phase B → push CommitmentScreen.
    AnalyticsService.logOnboardingStepCompleted('tell_us_focus');
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CommitmentScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // ── Phase B helpers ──────────────────────────────────────────

  void _toggleFocusArea(String area) {
    final state = context.read<OnboardingState>();
    if (!state.isSelected(area) &&
        state.focusAreas.length >= FocusAreasScreen.maxSelections) {
      // A haptic alone read as "nothing happened" on device (SS3). The toast
      // names the rule and the way past it, without a dialog mid-onboarding.
      HapticFeedback.lightImpact();
      AppToast.show(context, AppLocalizations.of(context).focusAreasLimitToast);
      return;
    }
    HapticFeedback.selectionClick();
    state.toggleFocusArea(area);
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final size = MediaQuery.of(context).size;
    final state = context.watch<OnboardingState>();
    final canContinue = _phase == _Phase.path
        ? _selectedPath != null
        : state.focusAreas.isNotEmpty;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
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

          _BackgroundOrbs(size: size, colors: colors),

          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: OnboardingProgressBar(
                        // Both phases share progress step 1/3 — the user
                        // perceives the conversation as one onboarding step.
                        currentStep: 1,
                        totalSteps: 3,
                        onBack: _handleBack,
                      ),
                    ),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                                position: offset, child: child),
                          );
                        },
                        child: _phase == _Phase.path
                            ? _PhasePath(
                                key: const ValueKey('phase_path'),
                                selected: _selectedPath,
                                onSelect: (id) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedPath = id);
                                },
                                bottomPadding: 200,
                              )
                            : _PhaseFocus(
                                key: const ValueKey('phase_focus'),
                                state: state,
                                onToggle: _toggleFocusArea,
                                bottomPadding: 200,
                              ),
                      ),
                    ),
                  ],
                ),

                // Bottom gradient fade behind the CTA.
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
                                color: colors.ctaPrimary
                                    .withValues(alpha: 0.30),
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
                        onPressed: canContinue ? _handleContinue : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        borderRadius: BorderRadius.circular(24),
                        child: Text(
                          AppLocalizations.of(context).commonContinue,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: canContinue
                                ? const Color(0xFFFFFFFF)
                                : Color.alphaBlend(
                                    colors.ctaPrimary
                                        .withValues(alpha: 0.65),
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
}

// ─── Phase A: path picker ───────────────────────────────────────

class _PhasePath extends StatelessWidget {
  const _PhasePath({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.bottomPadding,
  });

  final IntentionPathId? selected;
  final ValueChanged<IntentionPathId> onSelect;
  final double bottomPadding;


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tellUsAboutPathHeadline,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  height: 1.25,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.tellUsAboutPathSubtext,
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
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(28, 0, 28, bottomPadding),
            child: Column(
              children: IntentionPath.pickerOptions.map((path) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PathCard(
                    path: path,
                    title: path.title(l10n),
                    subtitle: path.subtitle(l10n),
                    selected: selected == path.id,
                    onTap: () => onSelect(path.id),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
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
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final accent = path.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? accent.withValues(alpha: 0.22)
                  : colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: selected ? 22 : 16,
              spreadRadius: selected ? 1 : 0,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
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
                  color: selected
                      ? accent.withValues(alpha: 0.72)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.40),
                  width: selected ? 2.0 : 1.5,
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
                          title,
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
                          subtitle,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color:
                                colors.textPrimary.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected) ...[
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

// ─── Phase B: focus areas picker ────────────────────────────────

class _PhaseFocus extends StatelessWidget {
  const _PhaseFocus({
    super.key,
    required this.state,
    required this.onToggle,
    required this.bottomPadding,
  });

  final OnboardingState state;
  final ValueChanged<String> onToggle;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tellUsAboutFocusHeadline,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  height: 1.25,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                // "Pick up to 2" was a lie by omission when the path had
                // already picked them (SS3): the screen now says who chose
                // and hands over the swap.
                switch (context.watch<OnboardingState>().lastPreselectedPathKey) {
                  final String key
                      when key != IntentionPathId.yourOwnWay.key =>
                    l10n.focusAreasFromPath(
                        IntentionPath.getById(IntentionPathId.fromKey(key))
                            .title(l10n)),
                  _ => l10n.tellUsAboutFocusSubtext,
                },
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
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(28, 0, 28, bottomPadding),
            child: Column(
              children: FocusAreasScreen.areas.map((area) {
                final selected = state.isSelected(area);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FocusAreaCard(
                    label: FocusAreasScreen.localizedAreaName(l10n, area),
                    subtitle:
                        FocusAreasScreen.localizedAreaSubtitle(l10n, area),
                    icon: FocusAreasScreen.areaIcons[area]!,
                    selected: selected,
                    onTap: () => onToggle(area),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Background ────────────────────────────────────────────────

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs({required this.size, required this.colors});
  final Size size;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
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
      ),
    );
  }
}
