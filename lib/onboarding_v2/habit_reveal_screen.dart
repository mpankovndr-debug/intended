import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/intention_path.dart';
import '../services/analytics_service.dart';
import '../services/backup_service.dart';
import '../services/revenue_cat_service.dart';
import '../utils/habit_l10n.dart';
import 'onboarding_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/onboarding_progress_bar.dart';

class HabitRevealScreen extends StatefulWidget {
  const HabitRevealScreen({super.key});

  @override
  State<HabitRevealScreen> createState() => _HabitRevealScreenState();
}

class _HabitRevealScreenState extends State<HabitRevealScreen>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<double>> _fadeAnimations = [];
  List<Animation<Offset>> _slideAnimations = [];
  List<Animation<double>> _scaleAnimations = [];
  bool _allCardsRevealed = false;

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView('habit_reveal');

    // Generate habits first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final state = context.read<OnboardingState>();
      await state.generateUserHabits();

      if (!mounted) return;
      // Initialize animations after habits are generated
      _initializeAnimations();
    });
  }

  void _initializeAnimations() {
    final state = context.read<OnboardingState>();
    final habitCount = state.userHabits.length;

    _controllers = List.generate(
      habitCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: index == 0 ? 900 : 650),
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _slideAnimations = _controllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Tween<Offset>(
        begin: Offset(0, index == 0 ? 0.5 : 0.25),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    _scaleAnimations = _controllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Tween<double>(
        begin: index == 0 ? 0.9 : 1.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
    }).toList();

    // Listen for last card animation to complete
    if (_controllers.isNotEmpty) {
      _controllers.last.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _allCardsRevealed = true);
        }
      });
    }

    // Start staggered animations after 800ms anticipation
    Future.delayed(const Duration(milliseconds: 800), () {
      for (var i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 300), () {
          if (mounted) {
            HapticFeedback.lightImpact();
            _controllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  static String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = _generateDeviceId();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  void _handleContinue() async {
    HapticFeedback.mediumImpact();

    final state = context.read<OnboardingState>();
    final revenueCat = context.read<RevenueCatService>();
    await state.completeOnboarding();

    AnalyticsService.logOnboardingStepCompleted('habit_reveal');
    AnalyticsService.logOnboardingCompleted();

    // Link device to RevenueCat for subscription tracking
    final deviceId = await getOrCreateDeviceId();
    await revenueCat.logIn(deviceId);

    if (mounted) {
      context.read<BackupService>().backup();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainTabs(),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final colors = context.watch<ThemeProvider>().colors;
    final size = MediaQuery.of(context).size;

    if (state.userHabits.isEmpty) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background - same as Focus Areas / Reminder
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
                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: OnboardingProgressBar(
                    currentStep: 4,
                    totalSteps: 4,
                    onBack: () => Navigator.pop(context),
                  ),
                ),

                // Scrollable content
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 68, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              l10n.habitRevealTitle,
                              textAlign: TextAlign.center,
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
                            _buildSubheading(state, colors),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Habits list (animated)
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 280),
                          itemCount: state.userHabits.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildAnimatedHabitCard(
                                state.userHabits[index],
                                index,
                                state,
                                colors,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Gradient overlay
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
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Buttons
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: 93,
                  child: Column(
                    children: [
                      // Reassurance message
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFFFFFF).withOpacity(0.60),
                                  colors.surfaceLight.withOpacity(0.50),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFFFFFF).withOpacity(0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.textPrimary.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              l10n.habitRevealDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors.ctaSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CTA button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colors.textPrimary.withOpacity(0.35),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _allCardsRevealed
                                      ? [
                                          colors.ctaAlternative.withOpacity(0.9),
                                          colors.ctaAlternative.withOpacity(0.85),
                                        ]
                                      : [
                                          colors.ctaPrimary.withOpacity(0.9),
                                          colors.ctaSecondary.withOpacity(0.85),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _allCardsRevealed
                                      ? colors.ctaAlternative.withOpacity(0.6)
                                      : colors.ctaPrimary.withOpacity(0.4),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.textPrimary.withOpacity(0.25),
                                    blurRadius: 24,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CupertinoButton(
                                onPressed: _allCardsRevealed ? _handleContinue : null,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                borderRadius: BorderRadius.circular(24),
                                child: Text(
                                  l10n.habitRevealBegin,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubheading(OnboardingState state, AppColorScheme colors) {
    final l10n = AppLocalizations.of(context);
    final pathKey = state.selectedIntentionPath;
    final isOwnWay = pathKey == IntentionPathId.yourOwnWay.key;

    String subtitle;
    if (!isOwnWay) {
      final path = IntentionPath.getById(IntentionPathId.fromKey(pathKey));
      final title = _resolvePathTitle(l10n, path);
      subtitle = l10n.habitRevealSubtitlePath(title);
    } else {
      subtitle = l10n.habitRevealSubtitleOwnWay;
    }

    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: AppTextStyles.bodyFont(context),
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: colors.ctaSecondary,
        height: 1.5,
      ),
    );
  }

  String _resolvePathTitle(AppLocalizations l10n, IntentionPath path) {
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

  Widget _buildAnimatedHabitCard(String habit, int index, OnboardingState state, AppColorScheme colors) {
    if (_controllers.isEmpty || index >= _controllers.length) {
      return const SizedBox();
    }

    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: ScaleTransition(
          scale: _scaleAnimations[index],
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  localizeHabitName(habit, l10n),
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
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
