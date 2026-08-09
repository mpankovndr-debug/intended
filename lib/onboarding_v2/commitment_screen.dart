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
import '../widgets/onboarding_progress_bar.dart';
import 'daily_reminder_screen.dart';
import 'focus_areas_screen.dart';
import 'onboarding_state.dart';

/// One-way commitment moment between the conversation screen and the
/// daily-reminder step. The user has just told the app what they want to
/// work on; this is the screen that asks them to actually commit.
///
/// Two notes on intent:
///   • The reciprocity echo (italic, small) mirrors the user's path + focus
///     back at them — a "we heard you" beat without faking AI personalization.
///   • [PopScope] blocks system-back and the iOS edge swipe so the commitment
///     is genuinely one-way: the only path forward is the CTA. Behavior-design
///     research consistently shows committed-without-undo lifts D7 retention.
class CommitmentScreen extends StatefulWidget {
  const CommitmentScreen({super.key});

  @override
  State<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends State<CommitmentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView('commitment');

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _handleCommit(BuildContext context) {
    HapticFeedback.mediumImpact();
    AnalyticsService.logOnboardingStepCompleted('commitment');
    // pushReplacement (not push) so the commitment screen leaves the stack
    // entirely after the promise is made. If the user later swipe-backs
    // from DailyReminder, they land on TellUsAboutYou (where edits are still
    // sensible) rather than re-seeing the commitment screen they've already
    // honored.
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DailyReminderScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  /// Builds the italic "we heard you" echo line. Falls back to a focus-only
  /// variant when the user picked "Your Own Way" — there's no path title to
  /// honestly mirror back, and we'd rather say less than fake it.
  String? _reciprocityEcho(BuildContext context, OnboardingState state) {
    final l10n = AppLocalizations.of(context);

    final areaIds = state.focusAreas;
    final areaText = areaIds
        .map((a) => FocusAreasScreen.localizedAreaName(l10n, a))
        .join(', ');
    if (areaText.isEmpty) return null;

    final pathKey = state.selectedIntentionPath;
    if (pathKey == IntentionPathId.yourOwnWay.key) {
      return l10n.commitmentEchoAreasOnly(areaText);
    }

    final path = IntentionPath.getById(IntentionPathId.fromKey(pathKey));
    final pathTitle = _localizedPathTitle(l10n, path);
    return l10n.commitmentEchoFull(pathTitle, areaText);
  }

  static String _localizedPathTitle(AppLocalizations l10n, IntentionPath path) {
    switch (path.titleKey) {
      case 'pathGentleMorningsTitle':
        return l10n.pathGentleMorningsTitle;
      case 'pathAnchorsForHardDaysTitle':
        return l10n.pathAnchorsForHardDaysTitle;
      case 'pathQuietFocusTitle':
        return l10n.pathQuietFocusTitle;
      case 'pathWindingDownTitle':
        return l10n.pathWindingDownTitle;
      case 'pathYourOwnWayTitle':
        return l10n.pathYourOwnWayTitle;
      default:
        return path.titleKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final echo = _reciprocityEcho(context, state);

    return PopScope(
      canPop: false,
      child: CupertinoPageScaffold(
        backgroundColor: colors.onboardingBg3,
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

            _BackgroundOrbs(colors: colors),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Progress bar — currentStep 2 of 3, no back arrow because
                  // commitment is one-way. OnboardingProgressBar hides the
                  // back glyph when onBack is null.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: const OnboardingProgressBar(
                      currentStep: 2,
                      totalSteps: 3,
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const Spacer(flex: 3),

                          FadeTransition(
                            opacity: _fadeIn,
                            child: SlideTransition(
                              position: _slideUp,
                              child: _BrandIcon(colors: colors),
                            ),
                          ),
                          const SizedBox(height: 32),

                          FadeTransition(
                            opacity: _fadeIn,
                            child: SlideTransition(
                              position: _slideUp,
                              child: Text(
                                l10n.commitmentTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          FadeTransition(
                            opacity: _fadeIn,
                            child: SlideTransition(
                              position: _slideUp,
                              child: Text(
                                l10n.commitmentBody,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily:
                                      AppTextStyles.bodyFont(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: colors.textPrimary
                                      .withValues(alpha: 0.78),
                                  height: 1.55,
                                ),
                              ),
                            ),
                          ),

                          // Reciprocity echo (italic, small) — the
                          // "we heard you" beat. Hidden if there's nothing
                          // honest to mirror back.
                          if (echo != null) ...[
                            const SizedBox(height: 22),
                            FadeTransition(
                              opacity: _fadeIn,
                              child: SlideTransition(
                                position: _slideUp,
                                child: Text(
                                  echo,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily:
                                        AppTextStyles.bodyFont(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    color: colors.textTertiary
                                        .withValues(alpha: 0.85),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const Spacer(flex: 4),

                          FadeTransition(
                            opacity: _fadeIn,
                            child: SlideTransition(
                              position: _slideUp,
                              child: _PrimaryCta(
                                colors: colors,
                                label: l10n.commitmentCta,
                                onPressed: () => _handleCommit(context),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(255, 255, 255, 0.4),
                Color.fromRGBO(255, 255, 255, 0.2),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: 56,
            height: 56,
            child: ColorFiltered(
              colorFilter:
                  ColorFilter.mode(colors.ctaPrimary, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/intended_icon_transparent.png',
                width: 56,
                height: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.colors,
    required this.label,
    required this.onPressed,
  });

  final AppColorScheme colors;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 384),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.ctaPrimary.withValues(alpha: 0.30),
            blurRadius: 22,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.ctaPrimary, colors.ctaSecondary],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(24),
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(context),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: size.height * 0.05,
            right: size.width * -0.05,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    radius: 0.9,
                    colors: [
                      colors.surfaceLightest.withValues(alpha: 0.6),
                      colors.onboardingBg2.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            left: size.width * -0.08,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
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
