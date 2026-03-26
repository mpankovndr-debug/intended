import 'dart:math' show Random, sin, cos, pi;
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../utils/profanity_filter.dart';
import 'onboarding_state.dart';
import '../features/onboarding/screens/intention_path_screen.dart';
import '../state/user_state.dart';
import '../services/analytics_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

class WelcomeV2Screen extends StatefulWidget {
  const WelcomeV2Screen({super.key});

  @override
  State<WelcomeV2Screen> createState() => _WelcomeV2ScreenState();
}

class _WelcomeV2ScreenState extends State<WelcomeV2Screen>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  late final AnimationController _anim;
  late final Animation<double> _fadeBrand;
  late final Animation<double> _fadeTagline;
  late final Animation<double> _fadeBottom;
  late final Animation<Offset> _slideBottom;

  bool _showNameBlock = false;

  static const int _maxNameLength = 30;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeBrand = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _fadeTagline = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
    );

    _fadeBottom = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
    );

    _slideBottom = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _anim.forward();
    });

    AnalyticsService.logScreenView('welcome');
    AnalyticsService.logOnboardingStarted();
  }

  @override
  void dispose() {
    controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _handleGetStarted() {
    setState(() => _showNameBlock = true);
  }

  void _handleContinue() {
    final name = controller.text.trim();

    if (name.isNotEmpty) {
      if (name.length > _maxNameLength) {
        final l10n = AppLocalizations.of(context);
        _showError(l10n.onboardingNameTooLong(_maxNameLength));
        return;
      }
      if (ProfanityFilter.containsProfanity(name)) {
        final l10n = AppLocalizations.of(context);
        _showError(l10n.onboardingNameInappropriate);
        return;
      }
    }

    _navigateToFocusAreas(name: name.isEmpty ? null : name);
  }

  void _showSignInSheet(
      BuildContext context, AppColorScheme colors, AppLocalizations l10n) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: const Color(0xFF000000).withValues(alpha: 0.4),
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      builder: (_) => _SignInSheet(
        onSignInComplete: (credential) {
          if (credential == null || !mounted) return;

          final displayName = FirebaseAuth.instance.currentUser?.displayName;
          String? firstName;
          if (displayName != null && displayName.isNotEmpty) {
            firstName = displayName.split(' ').first;
            if (firstName.length > _maxNameLength ||
                ProfanityFilter.containsProfanity(firstName)) {
              firstName = null;
            }
          }

          final onboarding = context.read<OnboardingState>();
          if (onboarding.onboardingComplete) {
            if (firstName != null && userNameNotifier.value == null) {
              userNameNotifier.value = firstName;
              onboarding.setName(firstName);
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString('user_name', firstName!);
              });
            }
            context.read<BackupService>().backup();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const MainTabs(),
                transitionDuration: const Duration(milliseconds: 400),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          } else {
            _tryRestore(context, firstName);
          }
        },
      ),
    );
  }

  Future<void> _tryRestore(BuildContext context, String? firstName) async {
    final backupService = context.read<BackupService>();
    final backupInfo = await backupService.checkForBackup();

    if (!mounted) return;

    if (backupInfo == null) {
      _navigateToFocusAreas(name: firstName);
      return;
    }

    final l10n = AppLocalizations.of(context);

    showIntendedDialog(
      context: context,
      title: l10n.restoreBackupTitle,
      subtitle: l10n.restoreBackupMessage,
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () async {
            Navigator.pop(context);
            final success = await backupService.restore();
            if (!mounted) return;
            if (success) {
              final onboarding = context.read<OnboardingState>();
              await onboarding.loadUserHabits();
              final prefs = await SharedPreferences.getInstance();
              final name = prefs.getString('user_name');
              if (name != null) {
                userNameNotifier.value = name;
                onboarding.setName(name);
              }
              final theme = prefs.getString('selected_theme');
              if (theme != null && mounted) {
                context.read<ThemeProvider>().setTheme(
                      AppTheme.values.firstWhere(
                        (t) => t.name == theme,
                        orElse: () => AppTheme.warmClay,
                      ),
                    );
              }
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MainTabs(),
                    transitionDuration: const Duration(milliseconds: 400),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              }
            } else {
              _navigateToFocusAreas(name: firstName);
            }
          },
          child: Text(l10n.restoreBackupConfirm),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
            _navigateToFocusAreas(name: firstName);
          },
          child: Text(l10n.restoreBackupSkip),
        ),
      ],
    );
  }

  void _navigateToFocusAreas({String? name}) {
    FocusScope.of(context).unfocus();

    final state = context.read<OnboardingState>();

    if (name != null && name.isNotEmpty) {
      state.setName(name);
      userNameNotifier.value = name;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('user_name', name);
      });
    }

    state.markWelcomeSeen();

    AnalyticsService.logOnboardingStepCompleted('name_entry');

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const IntentionPathScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showError(String message) {
    final l10n = AppLocalizations.of(context);
    showIntendedDialog(
      context: context,
      title: l10n.onboardingOops,
      subtitle: message,
      actions: [
        CupertinoDialogAction(
          child: Text(l10n.commonOk),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CupertinoPageScaffold(
        backgroundColor: colors.onboardingBg3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.2, -1.0),
                  end: const Alignment(-0.2, 1.0),
                  colors: [
                    colors.onboardingBg1,
                    colors.onboardingBg2,
                    colors.onboardingBg3,
                    colors.onboardingBg4,
                    colors.onboardingBg3,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),

            // Background orbs
            _buildBackgroundOrbs(size, colors),

            // Floating glass cards
            _FloatingCards(size: size),

            // Gradient overlay above keyboard
            if (MediaQuery.of(context).viewInsets.bottom > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
                child: IgnorePointer(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colors.onboardingBg3,
                          colors.onboardingBg3.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                          // Top spacer — shrinks when name block appears
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            height: _showNameBlock ? 80 : 160,
                          ),

                          // Brand group (icon + title)
                          FadeTransition(
                            opacity: _fadeBrand,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 30, sigmaY: 30),
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFFFFFFFF)
                                                .withOpacity(0.35),
                                            colors.surfaceLight
                                                .withOpacity(0.25),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(32),
                                        border: Border.all(
                                          color: const Color(0xFFFFFFFF)
                                              .withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/intended_icon_transparent.png',
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                Text(
                                  l10n.appNameIntended,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Tagline
                          FadeTransition(
                            opacity: _fadeTagline,
                            child: Column(
                              children: [
                                Text(
                                  l10n.onboardingTagline,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily:
                                        AppTextStyles.bodyFont(context),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: colors.ctaSecondary,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.onboardingDescriptor,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily:
                                        AppTextStyles.bodyFont(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: colors.ctaSecondary
                                        .withOpacity(0.7),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Bottom section: fades in on entry, cross-fades between states
                          FadeTransition(
                            opacity: _fadeBottom,
                            child: SlideTransition(
                              position: _slideBottom,
                              child: AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: _showNameBlock
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstCurve: Curves.easeIn,
                                secondCurve: Curves.easeOut,
                                sizeCurve: Curves.easeInOut,
                                firstChild: _buildGetStartedButton(
                                    colors, l10n),
                                secondChild:
                                    _buildNameBlock(colors, l10n),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Terms — always visible, fades in with bottom section
                          FadeTransition(
                            opacity: _fadeBottom,
                            child: _buildTerms(colors, l10n),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(
      AppColorScheme colors, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 384),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.ctaPrimary.withValues(alpha: 0.30),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 5),
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
          onPressed: _handleGetStarted,
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(24),
          child: Text(
            l10n.onboardingLetsGetStarted,
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

  Widget _buildNameBlock(AppColorScheme colors, AppLocalizations l10n) {
    return Column(
      children: [
        // Name input (glassmorphic)
        Container(
          constraints: const BoxConstraints(maxWidth: 384),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.45),
                      colors.surfaceLight.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: l10n.onboardingNamePrompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                  placeholderStyle: TextStyle(
                    fontFamily: AppTextStyles.bodyFont(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary.withOpacity(0.4),
                  ),
                  decoration: const BoxDecoration(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Continue button (always active — name is optional)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 384),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.ctaPrimary.withValues(alpha: 0.30),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 5),
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
              onPressed: _handleContinue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: BorderRadius.circular(24),
              child: Text(
                l10n.commonContinue,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Skip & Sign in row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 12),
              onPressed: () => _navigateToFocusAreas(),
              minimumSize: const Size(0, 0),
              child: Text(
                l10n.onboardingSkipForNow,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.textTertiary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '\u00B7',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.textTertiary.withOpacity(0.5),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 12),
              onPressed: () =>
                  _showSignInSheet(context, colors, l10n),
              minimumSize: const Size(0, 0),
              child: Text(
                l10n.onboardingAlreadyHaveAccount,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTerms(AppColorScheme colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: colors.textTertiary,
            height: 1.4,
          ),
          children: [
            TextSpan(text: l10n.legalDisclaimerPrefix),
            TextSpan(
              text: l10n.legalDisclaimerTerms,
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: colors.textSecondary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(
                      Uri.parse('https://intendedapp.com/terms'),
                      mode: LaunchMode.externalApplication,
                    ),
            ),
            TextSpan(text: l10n.legalDisclaimerAnd),
            TextSpan(
              text: l10n.legalDisclaimerPrivacy,
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: colors.textSecondary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(
                      Uri.parse('https://intendedapp.com/privacy'),
                      mode: LaunchMode.externalApplication,
                    ),
            ),
            TextSpan(text: l10n.legalDisclaimerSuffix),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBackgroundOrbs(Size size, AppColorScheme colors) {
    return Stack(
      children: [
        // Orb 1 - Top Right (largest)
        Positioned(
          top: size.height * -0.1,
          right: size.width * 0.15,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: 288,
              height: 288,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.9,
                  colors: [
                    colors.surfaceLightest.withOpacity(0.8),
                    colors.onboardingBg2.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Orb 2 - Bottom Left
        Positioned(
          bottom: size.height * 0.05,
          left: size.width * -0.08,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.35),
                  radius: 0.9,
                  colors: [
                    colors.onboardingBg1.withOpacity(0.7),
                    colors.onboardingBg4.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Orb 3 - Center Right
        Positioned(
          top: size.height * 0.5,
          left: size.width * 0.6,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.4),
                  radius: 0.9,
                  colors: [
                    colors.surfaceLightest.withOpacity(0.65),
                    colors.onboardingBg4.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Orb 4 - Top Left
        Positioned(
          top: size.height * 0.25,
          left: size.width * 0.1,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.35),
                  radius: 0.9,
                  colors: [
                    colors.onboardingBg1.withOpacity(0.6),
                    colors.onboardingBg4.withOpacity(0.2),
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

class _SignInSheet extends StatefulWidget {
  final void Function(UserCredential? credential) onSignInComplete;

  const _SignInSheet({required this.onSignInComplete});

  @override
  State<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<_SignInSheet> {
  bool _isSigningIn = false;

  Future<void> _handleAppleSignIn() async {
    setState(() => _isSigningIn = true);
    try {
      final credential = await AuthService.signInWithApple();
      if (credential == null) return;
      if (mounted) Navigator.pop(context);
      widget.onSignInComplete(credential);
    } catch (e, stackTrace) {
      debugPrint('Sign in with Apple error: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    try {
      final credential = await AuthService.signInWithGoogle();
      if (mounted) Navigator.pop(context);
      widget.onSignInComplete(credential);
    } catch (e) {
      debugPrint('Sign in with Google error: $e');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(0.0, 2.41),
              end: const Alignment(0.0, -2.41),
              colors: [
                colors.modalBg1.withOpacity(0.96),
                colors.modalBg2.withOpacity(0.93),
                colors.modalBg3.withOpacity(0.95),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.modalShadow.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, -16),
              ),
              BoxShadow(
                color: const Color(0xFFFFFFFF).withOpacity(0.25),
                blurRadius: 0,
                offset: const Offset(0, 1),
                spreadRadius: 0,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textDisabled.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Apple sign-in button
                _buildSignInButton(
                  colors: colors,
                  icon: const Text(
                    '\uF8FF',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  label: l10n.onboardingSignInWithApple,
                  onPressed: _isSigningIn ? null : _handleAppleSignIn,
                  isPrimary: true,
                ),
                const SizedBox(height: 12),

                // Google sign-in button
                _buildSignInButton(
                  colors: colors,
                  icon: Text(
                    'G',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ctaPrimary,
                    ),
                  ),
                  label: l10n.onboardingSignInWithGoogle,
                  onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                  isPrimary: false,
                ),
                const SizedBox(height: 16),

                // Cancel
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.commonCancel,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required AppColorScheme colors,
    required Widget icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.ctaPrimary.withOpacity(0.90),
                    colors.ctaSecondary.withOpacity(0.84),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.ctaPrimary.withOpacity(0.12),
                    colors.ctaSecondary.withOpacity(0.08),
                  ],
                ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPrimary
                ? colors.ctaPrimary.withOpacity(0.35)
                : colors.ctaPrimary.withOpacity(0.30),
            width: isPrimary ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? colors.textPrimary.withOpacity(0.2)
                  : colors.ctaPrimary.withOpacity(0.08),
              blurRadius: 20,
              offset: isPrimary ? const Offset(0, 6) : const Offset(0, 4),
            ),
            if (isPrimary)
              BoxShadow(
                color: const Color(0xFFFFFFFF).withOpacity(0.15),
                blurRadius: 0,
                offset: const Offset(0, 1),
                spreadRadius: 0,
                blurStyle: BlurStyle.inner,
              ),
          ],
        ),
        child: CupertinoButton(
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(24),
          child: _isSigningIn
              ? CupertinoActivityIndicator(
                  color:
                      isPrimary ? const Color(0xFFFFFFFF) : colors.ctaPrimary,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPrimary
                            ? const Color(0xFFFFFFFF)
                            : colors.ctaPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FloatingCards extends StatefulWidget {
  final Size size;
  const _FloatingCards({required this.size});

  @override
  State<_FloatingCards> createState() => _FloatingCardsState();
}

class _FloatingCardsState extends State<_FloatingCards>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;
  late final AnimationController _ctrl4;
  late final AnimationController _ctrl5;
  late final Animation<Offset> _drift1;
  late final Animation<Offset> _drift2;
  late final Animation<Offset> _drift3;
  late final Animation<Offset> _drift4;
  late final Animation<Offset> _drift5;

  @override
  void initState() {
    super.initState();

    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );
    _drift1 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(20, 15),
    ).animate(CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));

    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 11000),
    );
    _drift2 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-15, 20),
    ).animate(CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));

    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9500),
    );
    _drift3 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(12, -10),
    ).animate(CurvedAnimation(parent: _ctrl3, curve: Curves.easeInOut));

    _ctrl4 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _drift4 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-10, 12),
    ).animate(CurvedAnimation(parent: _ctrl4, curve: Curves.easeInOut));

    _ctrl5 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );
    _drift5 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(8, -14),
    ).animate(CurvedAnimation(parent: _ctrl5, curve: Curves.easeInOut));

    _ctrl1.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _ctrl2.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _ctrl3.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) _ctrl4.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _ctrl5.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    _ctrl4.dispose();
    _ctrl5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Stack(
      children: [
        // Card 1 - Top Right
        Positioned(
          top: size.height * 0.15,
          right: size.width * 0.1,
          child: AnimatedBuilder(
            animation: _drift1,
            builder: (context, child) => Transform.translate(
              offset: _drift1.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: 12 * (3.14159 / 180),
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.25),
                      const Color(0xFFFFFFFF).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Card 2 - Bottom Left
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * 0.15,
          child: AnimatedBuilder(
            animation: _drift2,
            builder: (context, child) => Transform.translate(
              offset: _drift2.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: -6 * (3.14159 / 180),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.2),
                      const Color(0xFFFFFFFF).withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.25),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Card 3 - Top Left (small)
        Positioned(
          top: size.height * 0.08,
          left: size.width * 0.12,
          child: AnimatedBuilder(
            animation: _drift3,
            builder: (context, child) => Transform.translate(
              offset: _drift3.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: -18 * (3.14159 / 180),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.2),
                      const Color(0xFFFFFFFF).withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.25),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Card 4 - Mid Right (small)
        Positioned(
          top: size.height * 0.45,
          right: size.width * 0.05,
          child: AnimatedBuilder(
            animation: _drift4,
            builder: (context, child) => Transform.translate(
              offset: _drift4.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: 22 * (3.14159 / 180),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.18),
                      const Color(0xFFFFFFFF).withOpacity(0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Card 5 - Bottom Right (small)
        Positioned(
          bottom: size.height * 0.12,
          right: size.width * 0.2,
          child: AnimatedBuilder(
            animation: _drift5,
            builder: (context, child) => Transform.translate(
              offset: _drift5.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: -10 * (3.14159 / 180),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.22),
                      const Color(0xFFFFFFFF).withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.22),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Floating particles widget (KEEP FROM ORIGINAL)
class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles();

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    final r = Random();

    _particles = List.generate(
      25,
      (_) => _Particle(
        base: Offset(r.nextDouble(), r.nextDouble()),
        radius: r.nextDouble() * 30 + 15,
        speed: r.nextDouble() * 0.5 + 0.3,
        phase: r.nextDouble() * pi * 2,
        opacity: r.nextDouble() * 0.25 + 0.15,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Stack(
              children: _particles.map((p) {
                final dx =
                    sin((_controller.value * 2 * pi * p.speed) + p.phase) * 35;
                final dy =
                    cos((_controller.value * 2 * pi * p.speed) + p.phase) * 35;

                return Positioned(
                  left: p.base.dx * size.width + dx - p.radius,
                  top: p.base.dy * size.height + dy - p.radius,
                  child: Container(
                    width: p.radius * 2,
                    height: p.radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFFFFF).withOpacity(0.0),
                          const Color(0xFFB5C9BA).withOpacity(p.opacity * 0.4),
                          const Color(0xFF9FB5A3).withOpacity(p.opacity),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9FB5A3)
                              .withOpacity(p.opacity * 0.5),
                          blurRadius: p.radius * 1.0,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final Offset base;
  final double radius;
  final double speed;
  final double phase;
  final double opacity;

  _Particle({
    required this.base,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}
