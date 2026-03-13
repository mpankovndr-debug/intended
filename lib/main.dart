import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Colors;
import 'dart:ui' show ImageFilter;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/analytics_service.dart';
import 'services/app_icon_service.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'utils/habit_l10n.dart';
import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'onboarding_v2/onboarding_state.dart';
import 'onboarding_v2/focus_areas_screen.dart';
import 'onboarding_v2/welcome_v2_screen.dart';
import 'state/user_state.dart';
import 'screens/paywall_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/habit_completion_modal.dart';
import 'models/moment.dart';
import 'services/moments_service.dart';
import 'services/milestone_service.dart';
import 'services/reflection_service.dart';
import 'utils/profanity_filter.dart'; // Add this
import 'utils/responsive_utils.dart';
import 'utils/text_styles.dart';
import 'utils/ios_version.dart';
import 'services/notification_scheduler.dart';
import 'services/notification_preferences_service.dart';
import 'services/revenue_cat_service.dart';
import 'widgets/boost_offer_sheet.dart';
import 'widgets/app_toast.dart';
import 'widgets/tip_banner.dart';
import 'models/curated_pack.dart';
import 'services/tips_service.dart';
import 'services/widget_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// ✅ ADD THIS HELPER HERE (before the main() function):
Future<T?> showIntendedModal<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> actions,
}) {
  final themeP = Provider.of<ThemeProvider>(context, listen: false);
  final colors = themeP.colors;
  final isDark = themeP.theme.isDark;
  return showCupertinoDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        colors.modalBg1.withOpacity(0.96),
                        colors.modalBg2.withOpacity(0.96),
                        colors.modalBg3.withOpacity(0.96),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                          : const Color(0xFFFFFFFF).withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.modalShadow.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                      if (!isDark)
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withOpacity(0.25),
                          blurRadius: 0,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                          blurStyle: BlurStyle.inner,
                        ),
                      if (!isDark)
                        BoxShadow(
                          color: colors.modalInnerShadow.withOpacity(0.1),
                          blurRadius: 0,
                          offset: const Offset(0, -1),
                          spreadRadius: 0,
                          blurStyle: BlurStyle.inner,
                        ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: Spacing.modalPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.h2(context),
                            textAlign: TextAlign.center,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              subtitle,
                              style: AppTextStyles.body(context),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 32),
                          ...actions,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/* -------------------- INTENDED DIALOG BUILDER -------------------- */

void showIntendedDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> actions,
  Widget? content,
}) {
  final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
  showIntendedModal(
    context: context,
    title: title,
    subtitle: subtitle,
    actions: actions.map((action) {
      // Convert CupertinoDialogAction to styled buttons
      if (action is CupertinoDialogAction) {
        return CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 12),
          onPressed: action.onPressed,
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(context),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: action.isDefaultAction
                  ? colors.textSecondary
                  : colors.textPrimary,
            ),
            child: action.child,
          ),
        );
      }
      return action;
    }).toList(),
  );
}

/// Styled popup modal with blur barrier, depth, and fade-in animation.
/// Use for all informational/confirmation modals shown via showCupertinoModalPopup.
Future<T?> showStyledPopup<T>({
  required BuildContext context,
  required Widget child,
}) {
  final themeP2 = Provider.of<ThemeProvider>(context, listen: false);
  final colors = themeP2.colors;
  final isDark = themeP2.theme.isDark;
  return showCupertinoModalPopup<T>(
    context: context,
    barrierColor: colors.barrierColor.withOpacity(isDark ? 0.55 : 0.35),
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (context, value, animChild) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: animChild,
            ),
          );
        },
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.modalBg1,
                    colors.modalBg2,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  if (!isDark)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 0,
                      spreadRadius: 0,
                      offset: const Offset(0, -1),
                    ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Primary filled button for styled popups
Widget styledPrimaryButton({
  required String label,
  required VoidCallback onPressed,
  Color? color,
}) {
  return Builder(
    builder: (ctx) {
      final resolvedColor = color ??
          Provider.of<ThemeProvider>(ctx, listen: false).colors.buttonDark;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: resolvedColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CupertinoButton(
          color: resolvedColor,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: onPressed,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(ctx),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Provider.of<ThemeProvider>(ctx, listen: false)
                  .colors
                  .buttonText,
            ),
          ),
        ),
      );
    },
  );
}

/// Secondary outline button for styled popups
Widget styledSecondaryButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return Builder(
    builder: (ctx) {
      final themeP = Provider.of<ThemeProvider>(ctx, listen: false);
      final colors = themeP.colors;
      final isDark = themeP.theme.isDark;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? colors.cardBackground.withOpacity(colors.cardBackgroundOpacity)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? colors.borderCard.withOpacity(colors.borderCardOpacity) : colors.borderMedium, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(ctx),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
      );
    },
  );
}

/* -------------------- THEME COLORS -------------------- */
// Old module-level constants removed — use colors.buttonDark, colors.surfaceLightest, etc. via ThemeProvider

/* -------------------- APP BACKGROUND -------------------- */

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image — fully visible, barely softened
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Image.asset(
            colors.backgroundSoft,
            fit: BoxFit.cover,
          ),
        ),

        // Warm gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 1.0],
              colors: [
                colors.bgGradientTop.withOpacity(colors.bgGradientTopOpacity),
                colors.bgGradientMid.withOpacity(colors.bgGradientMidOpacity),
                colors.bgGradientBottom.withOpacity(colors.bgGradientBottomOpacity),
              ],
            ),
          ),
        ),

        // Grey wash — desaturates the combined bg + gradient (Iris only)
        if (themeProvider.theme == AppTheme.iris)
          Container(color: const Color(0xFFF0EDF2).withOpacity(0.45)),

        child,
      ],
    );
  }
}

/* -------------------- MODELS -------------------- */

class Habit {
  final String id;
  final String title;
  final String emoji;

  const Habit({
    required this.id,
    required this.title,
    required this.emoji,
  });
}

const List<Habit> habits = [
  Habit(id: 'breath', title: 'Three slow breaths', emoji: '🌬️'),
  Habit(id: 'pause', title: 'Ten-second pause', emoji: '⏸️'),
  Habit(id: 'water', title: 'Mindful water', emoji: '💧'),
  Habit(id: 'stretch', title: 'Gentle stretch', emoji: '🧍'),
  Habit(id: 'priority', title: 'One priority', emoji: '🎯'),
  Habit(id: 'checkin', title: 'Honest check-in', emoji: '💬'),
];

/* -------------------- SERVICES -------------------- */

class HabitTracker {
  /// Normalise a habit title into a stable ID for storage keys.
  static String habitId(String habitTitle) {
    return habitTitle
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static String _key(String habitTitle, DateTime date) {
    final d = date.toIso8601String().substring(0, 10);
    return 'habit_done_${habitId(habitTitle)}_$d';
  }

  static Future<void> markDone(String habitTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(habitTitle, DateTime.now());
    await prefs.setBool(key, true);
    // Store original title so weekly summary can display it after habit changes
    await prefs.setString('habit_title_${habitId(habitTitle)}', habitTitle);
  }

  static Future<bool> wasDone(String habitTitle, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(habitTitle, date);
    final result = prefs.getBool(key) ?? false;
    return result;
  }

  /// Returns all completed habit IDs for a given date by scanning stored keys.
  static Future<List<String>> allCompletedIdsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final d = date.toIso8601String().substring(0, 10);
    final suffix = '_$d';
    const prefix = 'habit_done_';
    final result = <String>[];
    for (final key in prefs.getKeys()) {
      if (key.startsWith(prefix) &&
          key.endsWith(suffix) &&
          prefs.getBool(key) == true) {
        result.add(key.substring(prefix.length, key.length - suffix.length));
      }
    }
    return result;
  }

  /// Get the display title for a habit ID. Falls back to a readable version
  /// of the ID if the original title was never cached.
  static Future<String> titleForId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('habit_title_$id');
    if (stored != null) return stored;
    // Best-effort: capitalise first letter, replace underscores with spaces
    final readable = id.replaceAll('_', ' ');
    return readable.isEmpty
        ? id
        : '${readable[0].toUpperCase()}${readable.substring(1)}';
  }
}

/// Pushes current habit & theme data to the iOS home screen widget.
/// Safe to call from anywhere with a BuildContext.
Future<void> refreshHomeWidget(BuildContext context) async {
  try {
    final onboarding = context.read<OnboardingState>();
    final userState = context.read<UserState>();
    final themeProvider = context.read<ThemeProvider>();
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context);

    // Compute today's greeting (same logic as HabitsScreen)
    final messages = List.generate(23, (i) => [
      l10n.dailyMessage1, l10n.dailyMessage2, l10n.dailyMessage3,
      l10n.dailyMessage4, l10n.dailyMessage5, l10n.dailyMessage6,
      l10n.dailyMessage7, l10n.dailyMessage8, l10n.dailyMessage9,
      l10n.dailyMessage10, l10n.dailyMessage11, l10n.dailyMessage12,
      l10n.dailyMessage13, l10n.dailyMessage14, l10n.dailyMessage15,
      l10n.dailyMessage16, l10n.dailyMessage17, l10n.dailyMessage18,
      l10n.dailyMessage19, l10n.dailyMessage20, l10n.dailyMessage21,
      l10n.dailyMessage22, l10n.dailyMessage23,
    ][i]);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final greeting = messages[dayOfYear % messages.length];

    await WidgetService.updateWidget(
      userHabits: onboarding.userHabits,
      customHabitFocusAreas: onboarding.customHabitFocusAreas,
      isPremium: userState.hasSubscription,
      theme: themeProvider.theme,
      greeting: greeting,
      locale: locale.languageCode,
      l10n: l10n,
    );
  } catch (_) {
    // Widget update is non-critical — never crash the app for it.
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (_) {
        // Already initialized (e.g. hot restart)
      }

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      final prefs = await SharedPreferences.getInstance();

      // Check if this is first run
      final isFirstRun = prefs.getBool('first_run') ?? true;
      if (isFirstRun) {
        // Clear all data on first run
        await prefs.clear();
        await prefs.setBool('first_run', false);
        // Clear stale Firebase Auth session persisted in iOS Keychain
        await FirebaseAuth.instance.signOut();
      }

      // Load saved name
      final savedName = prefs.getString('user_name');

      // VALIDATE SAVED NAME FOR PROFANITY
      if (savedName != null && ProfanityFilter.containsProfanity(savedName)) {
        await prefs.remove('user_name');
        userNameNotifier.value = null;
      } else {
        userNameNotifier.value = savedName;
      }

      // Create OnboardingState instance and load saved habits
      final onboardingState = OnboardingState();
      await onboardingState.loadUserHabits();
      await ReflectionService.loadCustomHabitFocusAreas();

      // Sync the saved name to OnboardingState
      if (savedName != null &&
          savedName.isNotEmpty &&
          !ProfanityFilter.containsProfanity(savedName)) {
        onboardingState.setName(savedName);
      }

      final userState = UserState();
      final revenueCatService = RevenueCatService(userState);

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: onboardingState),
            ChangeNotifierProvider.value(value: userState),
            ChangeNotifierProvider.value(value: revenueCatService),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const IntendedApp(),
        ),
      );

      // Deferred initialization — runs after the first frame is rendered
      // so the UI appears instantly instead of waiting for network calls.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationScheduler.initialize();

        // Re-schedule daily notifications if enabled and running low
        final dailyEnabled = await NotificationPreferencesService.isEnabled();
        if (dailyEnabled) {
          final pending = await NotificationScheduler.pendingDailyCount();
          if (pending < 3) {
            final locale = WidgetsBinding.instance.platformDispatcher.locale;
            final l10n = lookupAppLocalizations(
              locale.languageCode == 'ru'
                  ? const Locale('ru')
                  : const Locale('en'),
            );
            await NotificationScheduler.scheduleDaily(l10n);
          }
        }

        IOSVersion.init();
        WidgetService.initialize();
        final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
        await revenueCatService.init(firebaseUid: firebaseUid);
      });
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class IntendedApp extends StatelessWidget {
  const IntendedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Only use Russian if the device language is explicitly Russian
        if (locale?.languageCode == 'ru') {
          return const Locale('ru');
        }
        // Default to English for all other languages
        return const Locale('en');
      },
      theme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: 'Sora',
            fontFamilyFallback: ['SF Pro', 'SF Pro Rounded'],
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          Responsive.init(context);
          final onboarding = context.read<OnboardingState>();
          if (onboarding.onboardingComplete) {
            return const MainTabs();
          }
          return const WelcomeV2Screen();
        },
      ),
    );
  }
}

/* -------------------- WELCOME -------------------- */

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;

      _fadeController.forward();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, animation, __) => const MainTabs(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: colors.surfaceLightest.withOpacity(0.45),
          ),
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(_fadeController),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: userNameNotifier,
                        builder: (context, name, _) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            name == null || name.isEmpty
                                ? l10n.welcomeTitle
                                : l10n.welcomeTitleWithName(name),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w600,
                              height: 1.18,
                              letterSpacing: -0.6,
                              color: colors.textPrimary,
                              fontFamilyFallback: const [
                                'SF Pro Rounded',
                                'SF Pro',
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      Text(
                        AppLocalizations.of(context).welcomeSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          letterSpacing: -0.15,
                          color: colors.textSubtitle,
                          fontFamilyFallback: const [
                            'SF Pro Rounded',
                            'SF Pro',
                          ],
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: const Color(0xFFFFFFFF).withOpacity(0.9),
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              blurRadius: 20,
                              color: colors.surfaceLightest.withOpacity(0.9),
                              offset: const Offset(0, 2),
                            ),
                            Shadow(
                              blurRadius: 30,
                              color: const Color(0xFF000000).withOpacity(0.05),
                              offset: const Offset(0, 6),
                            ),
                          ],
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
    );
  }
}

/* -------------------- TABS -------------------- */

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool? _lastPremiumStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserState>();
      _lastPremiumStatus = userState.hasSubscription;
      userState.addListener(_onSubscriptionChanged);
    });
  }

  void _onSubscriptionChanged() {
    final userState = context.read<UserState>();
    final isPremium = userState.hasSubscription;
    if (_lastPremiumStatus != isPremium) {
      _lastPremiumStatus = isPremium;
      refreshHomeWidget(context);

      // Revert premium-only features when subscription lapses.
      if (!isPremium) {
        context.read<ThemeProvider>().revertIfLocked(
              hasBoost: userState.hasBoost,
              isPremium: false,
            );
        AppIconService.resetIfPremium();
      }
    }
  }

  @override
  void dispose() {
    context.read<UserState>().removeListener(_onSubscriptionChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        NotificationScheduler.refreshTimezone(AppLocalizations.of(context));
      }
      context.read<RevenueCatService>().refreshPurchaseStatus();
      refreshHomeWidget(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Screens
          IndexedStack(
            index: _currentIndex,
            children: [
              const HabitsScreen(),
              ProgressScreen(isActive: _currentIndex == 1),
              const ProfileScreen(),
            ],
          ),

          // Gradient fade behind tab bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.tabBarFade.withOpacity(0.0),
                      colors.tabBarFade.withOpacity(0.85),
                      colors.tabBarFade.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Floating pill tab bar
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: _CustomTabBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
              },
            ),
          ),

          // Welcome-back overlay for long-absence re-entry
          const WelcomeBackOverlay(),
        ],
      ),
    );
  }
}

/* --------------- WELCOME-BACK OVERLAY --------------- */

class WelcomeBackOverlay extends StatefulWidget {
  const WelcomeBackOverlay({super.key});

  @override
  State<WelcomeBackOverlay> createState() => _WelcomeBackOverlayState();
}

class _WelcomeBackOverlayState extends State<WelcomeBackOverlay>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  int _daysAbsent = 0;
  late AnimationController _fadeController;
  late Animation<double> _textFadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _textFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );
    _checkAbsence();
  }

  Future<void> _checkAbsence() async {
    final prefs = await SharedPreferences.getInstance();

    final justCompleted = prefs.getBool('just_completed_onboarding') ?? false;
    if (justCompleted) return;

    final lastDateStr = prefs.getString('last_card_animation_date');
    if (lastDateStr == null) return;

    final lastDate = DateTime.tryParse(lastDateStr);
    if (lastDate == null) return;

    final today = DateTime.now();
    final days = DateTime(today.year, today.month, today.day)
        .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
        .inDays;

    if (days < 3) return;

    if (!mounted) return;
    setState(() {
      _show = true;
      _daysAbsent = days;
    });

    // Fade in text
    _fadeController.forward();

    // Start fade-out after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _show = false);
    });
  }

  String _getMessage() {
    if (_daysAbsent >= 14) return 'Hey, you. We kept the light on.';
    if (_daysAbsent >= 7) {
      final name = context.read<UserState>().name;
      if (name != null && name.isNotEmpty) {
        return 'Hi, $name! You came back — that\'s what\'s important.';
      }
      return 'Hi! You came back — that\'s what\'s important.';
    }
    return 'You\'re back. No catching up needed.';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();

    final colors = context.watch<ThemeProvider>().colors;

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _show ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          onEnd: () {
            if (!_show && mounted) setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.18, -1.0),
                end: const Alignment(-0.18, 1.0),
                colors: [
                  colors.onboardingBg1,
                  colors.onboardingBg2,
                  colors.onboardingBg3,
                  colors.onboardingBg4,
                ],
                stops: const [0.0, 0.35, 0.7, 1.0],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/intended_icon_transparent.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _textFadeIn,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _getMessage(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                          height: 1.4,
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
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceLight.withOpacity(0.96)
                : colors.modalBg1.withOpacity(0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isDark
                  ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                  : const Color(0xFFFFFFFF).withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TabItem(
                  icon: CupertinoIcons.checkmark_circle,
                  iconSelected: CupertinoIcons.checkmark_circle_fill,
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _TabItem(
                  icon: CupertinoIcons.chart_bar,
                  iconSelected: CupertinoIcons.chart_bar_fill,
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onTap),
              _TabItem(
                  icon: CupertinoIcons.person_circle,
                  iconSelected: CupertinoIcons.person_circle_fill,
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData iconSelected;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.icon,
    required this.iconSelected,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? iconSelected : icon,
            key: ValueKey(isSelected),
            size: 24,
            color: isSelected ? colors.ctaPrimary : colors.textDisabled,
          ),
        ),
      ),
    );
  }
}

// [Rest of your screens remain the same - HabitsScreen, HabitActionScreen, HabitResultScreen, ProgressScreen, ProfileScreen]

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  String? _lastKnownPinned;
  String? _justUnpinnedHabit;

  // Day-change detection — forces all habit cards to rebuild on new day
  String _currentDateStr = DateTime.now().toIso8601String().substring(0, 10);

  // Tips system
  int? _currentTipIndex;

  // Unified entrance animation (staggered, like welcome screen)
  late AnimationController _entranceController;
  late Animation<double> _fadeHeader;
  late Animation<double> _fadeMiddle;
  late Animation<double> _fadeContent;
  late Animation<Offset> _slideContent;

  static List<String> _getDailyMessages(AppLocalizations l10n) => [
        l10n.dailyMessage1,
        l10n.dailyMessage2,
        l10n.dailyMessage3,
        l10n.dailyMessage4,
        l10n.dailyMessage5,
        l10n.dailyMessage6,
        l10n.dailyMessage7,
        l10n.dailyMessage8,
        l10n.dailyMessage9,
        l10n.dailyMessage10,
        l10n.dailyMessage11,
        l10n.dailyMessage12,
        l10n.dailyMessage13,
        l10n.dailyMessage14,
        l10n.dailyMessage15,
        l10n.dailyMessage16,
        l10n.dailyMessage17,
        l10n.dailyMessage18,
        l10n.dailyMessage19,
        l10n.dailyMessage20,
        l10n.dailyMessage21,
        l10n.dailyMessage22,
        l10n.dailyMessage23,
      ];

  String _getTodaysMessage(AppLocalizations l10n) {
    final messages = _getDailyMessages(l10n);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return messages[dayOfYear % messages.length];
  }

  Future<void> _checkAndTriggerEntrance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // Check if we just completed onboarding (skip animation)
    final justCompletedOnboarding =
        prefs.getBool('just_completed_onboarding') ?? false;
    if (justCompletedOnboarding) {
      await prefs.setBool('just_completed_onboarding', false);
      return; // controller already at 1.0
    }

    // Check last animation date
    final lastAnimationDate = prefs.getString('last_card_animation_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastAnimationDate != today) {
      // First open of the day — reset to invisible, then animate in
      await prefs.setString('last_card_animation_date', today);
      if (!mounted) return;
      _entranceController.value = 0.0;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _entranceController.forward();
      });
    }
    // Otherwise controller stays at 1.0 (already visible, no flash)
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AnalyticsService.logScreenView('habits');
    _loadCurrentTip();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
      value: 1.0, // start visible — no flash on hot restart
    );

    // Staggered intervals (gentle cascade with heavy overlap)
    _fadeHeader = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _fadeMiddle = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
    );
    _fadeContent = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
    );
    _slideContent = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
    ));

    _checkAndTriggerEntrance();

    // Refresh home screen widget on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) refreshHomeWidget(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entranceController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDayChange();
    }
  }

  /// Forces all habit cards to rebuild when the calendar date changes.
  void _checkDayChange() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (today != _currentDateStr) {
      _currentDateStr = today;
      setState(() {}); // Cascade rebuild to all habit cards
      refreshHomeWidget(context);
    }
  }

  void _showBrowseHabits(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(colors.barrierOpacity),
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      builder: (context) => const BrowseHabitsSheet(),
    );
  }

  Future<void> _loadCurrentTip() async {
    final index = await TipsService.getCurrentTipIndex();
    if (mounted && index != _currentTipIndex) {
      setState(() => _currentTipIndex = index);
    }
  }

  void _createCustomHabit(BuildContext context) {
    final onboardingState = context.read<OnboardingState>();
    final userState = context.read<UserState>();

    if (!userState.hasSubscription &&
        !onboardingState.canAddCustomHabit()) {
      final l10n = AppLocalizations.of(context);
      showBoostOfferSheet(
        context: context,
        title: l10n.boostOfferHabitTitle,
        description: l10n.boostOfferHabitDesc,
        showBoostOption: false,
        source: 'custom_habit_limit',
      ).then((result) {
        if (result == 'paywall') openPaywallFromContext(context, source: 'custom_habit_limit');
      });
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const _CreateCustomHabitScreen(),
      ),
    );
  }

  int _getAvailableHabitsCount(BuildContext context) {
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    // Check for day change on every build (catches midnight crossing)
    _checkDayChange();

    Responsive.init(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final onboardingState = context.watch<OnboardingState>();
    final l10n = AppLocalizations.of(context);
    final allHabits = onboardingState.userHabits;
    final pinnedHabit = onboardingState.pinnedHabit;

    // Detect pin/unpin transitions (for arrival animations)
    final isNewPin = pinnedHabit != null && pinnedHabit != _lastKnownPinned;
    final isNewUnpin = pinnedHabit == null && _lastKnownPinned != null;
    final unpinnedHabit = isNewUnpin ? _lastKnownPinned : _justUnpinnedHabit;
    if (pinnedHabit != _lastKnownPinned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isNewUnpin) {
          _justUnpinnedHabit = _lastKnownPinned;
          HapticFeedback.lightImpact();
        } else {
          _justUnpinnedHabit = null;
        }
        _lastKnownPinned = pinnedHabit;
        if (isNewPin) HapticFeedback.lightImpact();
      });
    }

    // Split habits into pinned and unpinned
    final pinned = pinnedHabit != null && allHabits.contains(pinnedHabit)
        ? [pinnedHabit]
        : <String>[];
    final unpinnedAll = allHabits.where((h) => h != pinnedHabit).toList();
    // Sort: unpinned custom habits first, then standard/completed
    final unpinnedCustom =
        unpinnedAll.where((h) => onboardingState.isCustomHabit(h)).toList();
    final unpinnedStandard =
        unpinnedAll.where((h) => !onboardingState.isCustomHabit(h)).toList();
    final unpinned = [...unpinnedCustom, ...unpinnedStandard];

    final now = DateTime.now();
    final dateStr =
        '${_getDayName(now.weekday, l10n)}, ${_getMonthName(now.month, l10n)} ${now.day}';

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with date (stagger 1: fades in first)
                  FadeTransition(
                    opacity: _fadeHeader,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          24, MediaQuery.of(context).padding.top + 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTodaysMessage(l10n),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              fontFamily: 'Sora',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.checkmarkFill,
                              fontFamily: AppTextStyles.bodyFont(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Habits content
                  if (allHabits.isEmpty)
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeContent,
                        child: Center(
                          child: Text(
                            l10n.habitsCompleteOnboarding,
                            style: AppTextStyles.buttonSecondary(context),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // Tip banner (above pinned section)
                    if (_currentTipIndex != null)
                      FadeTransition(
                        opacity: _fadeMiddle,
                        child: TipBanner(
                          key: ValueKey('tip_$_currentTipIndex'),
                          tipIndex: _currentTipIndex!,
                          onDismissed: (nextIndex) {
                            setState(() => _currentTipIndex = nextIndex);
                          },
                        ),
                      ),

                    // Pinned section (stagger 2: fades in second)
                    if (pinned.isNotEmpty)
                      FadeTransition(
                        opacity: _fadeMiddle,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  l10n.habitsPinned,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.ctaPrimary,
                                    letterSpacing: 1.0,
                                    fontFamily: AppTextStyles.bodyFont(context),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...pinned.asMap().entries.map((entry) {
                                final habit = entry.value;
                                final habitCard = _HabitCard(
                                  key: ValueKey(habit),
                                  habitTitle: habit,
                                  isPinned: true,
                                  accentColor: colors.accentPinned,
                                );
                                if (!isNewPin) return habitCard;
                                // Arrival animation: slide up + scale + fade in
                                return TweenAnimationBuilder<double>(
                                  key: ValueKey('pin_arrive_$habit'),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 550),
                                  curve: Curves.easeOutBack,
                                  builder: (context, progress, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 60 * (1 - progress)),
                                      child: Opacity(
                                        opacity: progress.clamp(0.0, 1.0),
                                        child: Transform.scale(
                                          scale: 0.88 + 0.12 * progress,
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: habitCard,
                                );
                              }),
                              const SizedBox(height: 24),
                              Container(
                                height: 1,
                                color: colors.borderWarm,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Scrollable section (stagger 3: fades + slides in last)
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeContent,
                        child: SlideTransition(
                          position: _slideContent,
                          child: ListView(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                pinned.isNotEmpty ? 24 : 16,
                                24,
                                140,
                              ),
                              children: [
                                // Today's Suggestions section
                                if (unpinned.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      l10n.habitsSuggestions,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colors.ctaPrimary,
                                        letterSpacing: 1.0,
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...unpinned.asMap().entries.map((entry) {
                                    final habit = entry.value;
                                    final habitCard = _HabitCard(
                                      key: ValueKey(habit),
                                      habitTitle: habit,
                                      accentColor:
                                          colors.accentRegular, // Warm taupe
                                    );
                                    if (habit != unpinnedHabit) {
                                      return habitCard;
                                    }
                                    // Arrival animation for card returning from pinned section
                                    return TweenAnimationBuilder<double>(
                                      key: ValueKey('unpin_arrive_$habit'),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeOutBack,
                                      builder: (context, progress, child) {
                                        return Transform.translate(
                                          offset:
                                              Offset(0, -60 * (1 - progress)),
                                          child: Opacity(
                                            opacity: progress.clamp(0.0, 1.0),
                                            child: Transform.scale(
                                              scale: 0.88 + 0.12 * progress,
                                              child: child,
                                            ),
                                          ),
                                        );
                                      },
                                      child: habitCard,
                                    );
                                  }),
                                ],

                                // CREATE CUSTOM HABIT BUTTON / LOCKED SLOT
                                const SizedBox(height: 16),

                                Builder(builder: (context) {
                                  final customCount =
                                      onboardingState.customHabits.length;
                                  final userSt = context.read<UserState>();
                                  final isDark = context.read<ThemeProvider>().theme.isDark;
                                  final maxCustom =
                                      onboardingState.maxCustomHabits();

                                  if (customCount < maxCustom ||
                                      userSt.hasSubscription) {
                                    return GestureDetector(
                                        onTap: () =>
                                            _createCustomHabit(context),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 12, sigmaY: 12),
                                            child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              radius: const Radius.circular(24),
                                              dashPattern: const [8, 4],
                                              color: colors.ctaPrimary
                                                  .withOpacity(0.20),
                                              strokeWidth: 2,
                                              child: Container(
                                                width: double.infinity,
                                                height: 96,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      colors.modalBg1
                                                          .withOpacity(0.40),
                                                      colors.modalBg1
                                                          .withOpacity(0.20),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: isDark
                                                            ? colors.ctaPrimary.withOpacity(0.15)
                                                            : const Color(0xFFFFFFFF).withOpacity(0.50),
                                                      ),
                                                      child: Icon(
                                                        CupertinoIcons.add,
                                                        size: 18,
                                                        color:
                                                            colors.ctaPrimary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      l10n.habitsCreateCustom,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            colors.ctaPrimary,
                                                        fontFamily:
                                                            AppTextStyles
                                                                .bodyFont(
                                                                    context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    );
                                  }

                                  // Limit reached & not subscribed: show locked slot
                                  return GestureDetector(
                                      onTap: () {
                                        if (context.read<RevenueCatService>().isPremium) return;
                                        showCupertinoModalPopup(
                                          context: context,
                                          barrierColor:
                                              Colors.black.withOpacity(0.5),
                                          filter: ImageFilter.blur(
                                              sigmaX: 5, sigmaY: 5),
                                          builder: (context) =>
                                              const PaywallScreen(
                                                  source: 'browse_habits'),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          border: Border.all(
                                            color: colors.ctaPrimary
                                                .withOpacity(0.10),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 12, sigmaY: 12),
                                            child: Container(
                                              width: double.infinity,
                                              height: 96,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    colors.modalBg1
                                                        .withOpacity(0.9),
                                                    colors.modalBg1
                                                        .withOpacity(0.7),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: isDark
                                                      ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                                      : const Color(0xFFFFFFFF).withOpacity(0.6),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: colors.ctaPrimary
                                                        .withOpacity(0.10),
                                                    blurRadius: 32,
                                                  ),
                                                  BoxShadow(
                                                    color: colors.ctaPrimary
                                                        .withOpacity(0.10),
                                                    blurRadius: 0,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                clipBehavior: Clip.hardEdge,
                                                children: [
                                                  Positioned(
                                                    bottom: -20,
                                                    right: -20,
                                                    child: Container(
                                                      width: 128,
                                                      height: 128,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        gradient:
                                                            RadialGradient(
                                                          colors: [
                                                            colors.ctaPrimary
                                                                .withOpacity(
                                                                    0.10),
                                                            colors.ctaPrimary
                                                                .withOpacity(
                                                                    0.0),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 36,
                                                          height: 36,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: isDark
                                                                ? colors.ctaPrimary.withOpacity(0.15)
                                                                : const Color(0xFFFFFFFF).withOpacity(0.5),
                                                          ),
                                                          child: Icon(
                                                            CupertinoIcons.lock,
                                                            size: 16,
                                                            color: colors
                                                                .ctaPrimary,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(
                                                          l10n.habitsCreateCustom,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: colors
                                                                .textPrimary
                                                                .withOpacity(
                                                                    0.60),
                                                            fontFamily:
                                                                AppTextStyles
                                                                    .bodyFont(
                                                                        context),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  );
                                }),

                                // BROWSE ALL HABITS CARD
                                const SizedBox(height: 16),

                                GestureDetector(
                                    onTap: () => _showBrowseHabits(context),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 22, sigmaY: 22),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: colors.cardBrowse
                                                .withOpacity(
                                                    colors.cardBrowseOpacity),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDark
                                                  ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                                  : const Color(0xFFFFFFFF).withOpacity(0.20),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.textPrimary
                                                    .withOpacity(0.04),
                                                blurRadius: 16,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    l10n.habitsBrowseAll,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: colors.textPrimary,
                                                      fontFamily: AppTextStyles
                                                          .bodyFont(context),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    l10n.habitsMoreAvailable(
                                                        _getAvailableHabitsCount(
                                                            context)),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          colors.textSecondary,
                                                      fontFamily: AppTextStyles
                                                          .bodyFont(context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Icon(
                                                CupertinoIcons.chevron_right,
                                                size: 18,
                                                color: colors.textSecondary,
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
                        ),
                      ),
                  ],
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday, AppLocalizations l10n) {
    final days = [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    final months = [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];
    return months[month - 1];
  }
}

// ============================================================
// CREATE CUSTOM HABIT SCREEN
// ============================================================

class _CreateCustomHabitScreen extends StatefulWidget {
  const _CreateCustomHabitScreen();

  @override
  State<_CreateCustomHabitScreen> createState() =>
      _CreateCustomHabitScreenState();
}

class _CreateCustomHabitScreenState extends State<_CreateCustomHabitScreen> {
  final _controller = TextEditingController();
  String? _selectedFocusArea;

  bool get _canSave {
    final text = _controller.text.trim();
    return text.isNotEmpty &&
        text.length >= 3 &&
        text.length <= 50 &&
        !ProfanityFilter.containsProfanity(text);
  }

  @override
  void initState() {
    super.initState();
    // Default to first category
    final allCategories =
        OnboardingState.habitsByCategory.keys.toList();
    if (allCategories.isNotEmpty) {
      _selectedFocusArea = allCategories.first;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    final habitTitle = _controller.text.trim();
    if (!_canSave) return;

    final onboardingState = context.read<OnboardingState>();
    final navigator = Navigator.of(context);
    final navContext = navigator.context;

    await onboardingState.addCustomHabit(habitTitle,
        focusArea: _selectedFocusArea);
    AnalyticsService.logCustomHabitCreated(habitTitle);

    if (!mounted) return;

    navigator.pop();

    await Future.delayed(const Duration(milliseconds: 100));

    final l10nNav = AppLocalizations.of(navContext);
    showStyledPopup(
      context: navContext,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10nNav.customHabitCreatedTitle,
            style: AppTextStyles.h2(navContext),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10nNav.customHabitCreatedMessage(habitTitle),
            style: AppTextStyles.body(navContext),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          styledPrimaryButton(
            label: '${l10nNav.commonGreat}!',
            onPressed: () => Navigator.pop(navContext),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    return CupertinoPageScaffold(
      // Use AppBackground for consistent warm background
      child: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ============================================================
              // CUSTOM NAVIGATION BAR
              // ============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.commonCancel,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: colors.buttonDark,
                          fontFamily: AppTextStyles.bodyFont(context),
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      l10n.customHabitTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        fontFamily: AppTextStyles.bodyFont(context),
                      ),
                    ),
                    // Spacer to balance the row
                    const SizedBox(width: 80),
                  ],
                ),
              ),

              // ============================================================
              // MAIN CONTENT
              // ============================================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      // Title
                      Text(
                        l10n.customHabitPrompt,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          fontFamily: 'Sora',
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        l10n.customHabitHint,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                          fontFamily: AppTextStyles.bodyFont(context),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ============================================================
                      // TEXT INPUT FIELD
                      // ============================================================
                      CupertinoTextField(
                        controller: _controller,
                        placeholder: l10n.customHabitPlaceholder,
                        autofocus: true,
                        maxLength: 50,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          fontSize: 17,
                          color: colors.textPrimary,
                          fontFamily: AppTextStyles.bodyFont(context),
                        ),
                        placeholderStyle: TextStyle(
                          fontSize: 17,
                          color: colors.textSecondary,
                          fontFamily: AppTextStyles.bodyFont(context),
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colors.cardBackground.withOpacity(colors.cardBackgroundOpacity)
                              : const Color(0xFFFFFFFF).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                : colors.buttonDark.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Character count
                      Text(
                        l10n.customHabitCharCount(_controller.text.length),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                          fontFamily: AppTextStyles.bodyFont(context),
                        ),
                      ),

                      // ============================================================
                      // FOCUS AREA PICKER
                      // ============================================================
                      Builder(builder: (context) {
                        final allCategories =
                            OnboardingState.habitsByCategory.keys.toList();
                        if (allCategories.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),
                            Text(
                              l10n.customHabitFocusAreaLabel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                                fontFamily: AppTextStyles.bodyFont(context),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: allCategories.map((area) {
                                final isSelected =
                                    _selectedFocusArea == area;
                                final catColor =
                                    AppColors.categoryColors[area] ??
                                        colors.accentMuted;
                                final icon =
                                    FocusAreasScreen.areaIcons[area];
                                return GestureDetector(
                                  onTap: () {
                                    setState(
                                        () => _selectedFocusArea = area);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? catColor.withOpacity(0.18)
                                          : isDark
                                              ? Color.lerp(colors.cardBackground,
                                                  catColor, 0.08)!
                                                  .withOpacity(colors
                                                      .cardBackgroundOpacity)
                                              : Color.lerp(const Color(0xFFFFFFFF),
                                                  catColor, 0.10)!
                                                  .withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? catColor.withOpacity(0.5)
                                            : isDark
                                                ? colors.borderCard
                                                    .withOpacity(colors
                                                        .borderCardOpacity)
                                                : colors.buttonDark
                                                    .withOpacity(0.12),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (icon != null) ...[
                                          Icon(
                                            icon,
                                            size: 16,
                                            color: isSelected
                                                ? catColor
                                                : colors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(
                                          localizeCategoryName(
                                              area, l10n),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colors.textPrimary
                                                : colors.textSecondary,
                                            fontFamily:
                                                AppTextStyles.bodyFont(
                                                    context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ============================================================
                      // SUBMIT BUTTON
                      // ============================================================
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              onPressed: _canSave ? _saveHabit : null,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              color: _canSave
                                  ? colors.buttonDark
                                  : isDark
                                      ? colors.cardBackground.withOpacity(0.6)
                                      : const Color(0xFFFFFFFF).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              child: Text(
                                l10n.customHabitSubmit,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _canSave
                                      ? colors.surfaceLightest
                                      : colors.textSecondary,
                                  fontFamily: AppTextStyles.bodyFont(context),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends StatefulWidget {
  final String habitTitle;
  final bool isPinned;
  final Color? accentColor;

  const _HabitCard({
    super.key,
    required this.habitTitle,
    this.isPinned = false,
    this.accentColor, // Default resolved from theme in build
  });

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  bool _isDoneToday = false;
  bool _isAnimating = false;
  String _lastCheckedDate = '';
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Pin departure animation controllers
  late AnimationController _departureController;
  late Animation<double> _departureScale;
  late Animation<double> _departureFade;

  // Checkmark animation controllers
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _checkmarkFadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIfDone();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _departureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _departureScale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _departureController, curve: Curves.easeIn),
    );

    _departureFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _departureController, curve: Curves.easeIn),
    );

    // Checkmark animation (scale from 80% to 100% with easeOutBack curve)
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _checkmarkScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeOutBack),
    );

    _checkmarkFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeOut),
    );

    _textFadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scaleController.dispose();
    _departureController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfDone();
    }
  }

  Future<void> _checkIfDone() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final done = await HabitTracker.wasDone(widget.habitTitle, DateTime.now());
    if (mounted) {
      _lastCheckedDate = today;
      if (done != _isDoneToday) {
        setState(() {
          _isDoneToday = done;
        });
        if (done) {
          _checkmarkController.forward();
        } else {
          _checkmarkController.reset();
        }
      }
    }
  }

  void _handleTap() async {
    if (_isDoneToday) return; // Don't open modal if already done

    HapticFeedback.lightImpact();

    final isPremium = context.read<RevenueCatService>().isPremium;

    // Show modal dialog
    final completed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => HabitCompletionModal(
        habitTitle: widget.habitTitle,
        isPremium: isPremium,
      ),
    );

    // If completed, animate checkmark and refresh widget
    if (completed == true && mounted) {
      setState(() {
        _isDoneToday = true;
      });

      // Trigger checkmark animation
      _checkmarkController.forward();

      // Update home screen widget with new completion state
      refreshHomeWidget(context);

      // Premium "all done" haptic — heavy thud when last habit is completed
      if (isPremium) {
        _checkAllDoneHaptic();
      }
    }
  }

  /// Checks if all habits are now complete; if so, fires a heavy haptic.
  Future<void> _checkAllDoneHaptic() async {
    final onboarding = context.read<OnboardingState>();
    final habits = onboarding.userHabits;
    if (habits.isEmpty) return;
    final completedIds = await HabitTracker.allCompletedIdsForDate(DateTime.now());
    final allDone = habits.every(
      (h) => completedIds.contains(HabitTracker.habitId(h)),
    );
    if (allDone) {
      HapticFeedback.heavyImpact();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    _showContextMenu();
  }

  // Action methods:
  // _showContextMenu(), _handlePinToggle(), _animatePin(),
  // _showReplacePinConfirmation(), _handleSwap(),
  // _showSwapDialog(), _performSwap(), _showSwapLimitDialog(),
  // _showNoAlternativesDialog(), _showDeleteConfirmation(), _showUpgradeScreen()

  void _showContextMenu() {
    final onboardingState = context.read<OnboardingState>();
    final isPinned = onboardingState.pinnedHabit == widget.habitTitle;
    final isCustom = onboardingState.isCustomHabit(widget.habitTitle);
    final category = onboardingState.getCategoryForHabit(widget.habitTitle);
    final themeP = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(isDark ? 0.45 : 0.28),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-0.3, -0.5),
                            end: const Alignment(0.3, 0.5),
                            colors: [
                              colors.modalBg1.withOpacity(isDark ? 0.75 : 0.96),
                              colors.modalBg2.withOpacity(isDark ? 0.70 : 0.93),
                              colors.modalBg3.withOpacity(isDark ? 0.75 : 0.95),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                : Colors.white.withOpacity(0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pin / Unpin
                            _buildActionRow(
                              icon: isPinned
                                  ? CupertinoIcons.pin_slash
                                  : CupertinoIcons.pin,
                              label:
                                  isPinned ? l10n.menuUnpin : l10n.menuPinToTop,
                              onTap: () {
                                Navigator.pop(context);
                                _handlePinToggle();
                              },
                            ),

                            // Swap — only for curated habits with a category
                            if (category != null)
                              _buildActionRow(
                                icon: CupertinoIcons.arrow_2_squarepath,
                                label: l10n.menuSwap,
                                onTap: () {
                                  Navigator.pop(context);
                                  _handleSwap();
                                },
                                showDivider: true,
                              ),

                            // Edit — only for custom habits
                            if (isCustom)
                              _buildActionRow(
                                icon: CupertinoIcons.pencil,
                                label: l10n.editHabitTitle,
                                onTap: () {
                                  Navigator.pop(context);
                                  _showEditDialog();
                                },
                                showDivider: true,
                              ),

                            // Delete — only for custom habits
                            if (isCustom)
                              _buildActionRow(
                                icon: CupertinoIcons.trash,
                                label: l10n.commonDelete,
                                isDestructive: true,
                                onTap: () {
                                  Navigator.pop(context);
                                  _showDeleteConfirmation();
                                },
                                showDivider: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Cancel button — separate pill
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-0.3, -0.5),
                            end: const Alignment(0.3, 0.5),
                            colors: [
                              colors.modalBg1.withOpacity(isDark ? 0.75 : 0.97),
                              colors.modalBg2.withOpacity(isDark ? 0.70 : 0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                : Colors.white.withOpacity(0.5),
                            width: 1.0,
                          ),
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.commonCancel,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
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
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showDivider = false,
  }) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final iconColor = isDestructive ? colors.destructive : colors.ctaPrimary;
    final textColor = isDestructive ? colors.destructive : colors.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 0.5,
              color: colors.borderMedium.withOpacity(0.6),
            ),
          ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          onPressed: onTap,
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePinToggle() async {
    final onboardingState = context.read<OnboardingState>();
    final isPinned = onboardingState.pinnedHabit == widget.habitTitle;

    if (isPinned) {
      await _animateUnpin();
    } else {
      final isPremium = context.read<UserState>().hasSubscription;
      if (onboardingState.pinnedHabit != null) {
        if (isPremium) {
          // Premium users pin directly — no confirmation needed
          await _animatePin();
        } else {
          // Free users go straight to replace confirmation (one step)
          _showReplacePinConfirmation();
        }
      } else {
        await _animatePin();
      }
    }
  }

  Future<void> _animatePin() async {
    if (_isAnimating || !mounted) return;

    setState(() {
      _isAnimating = true;
    });

    final onboardingState = context.read<OnboardingState>();

    // Lift animation (scale down slightly to create "picked up" feel)
    if (!mounted) return;
    await _scaleController.forward();
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    // Small pause at the "lifted" state
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    // Departure: shrink + fade out
    await _departureController.forward();
    if (!mounted) return;

    // Pin the habit — triggers parent rebuild, this widget may be disposed
    await onboardingState.pinHabit(widget.habitTitle);
    AnalyticsService.logHabitPinned();
    // Widget likely disposed after this — don't access state
  }

  Future<void> _animateUnpin() async {
    if (_isAnimating || !mounted) return;

    setState(() {
      _isAnimating = true;
    });

    final onboardingState = context.read<OnboardingState>();

    // Lift
    await _scaleController.forward();
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    // Departure: shrink + fade out (same animation as pin)
    await _departureController.forward();
    if (!mounted) return;

    // Unpin — triggers parent rebuild, this widget may be disposed
    await onboardingState.unpinHabit();
    AnalyticsService.logHabitUnpinned();
  }

  Future<void> _showReplacePinConfirmation() async {
    final onboardingState = context.read<OnboardingState>();
    final currentPinned = onboardingState.pinnedHabit;
    final themeP = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(0.28),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 384),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
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
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark
                              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                              : const Color(0xFFFFFFFF).withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.modalShadow.withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                          if (!isDark)
                            BoxShadow(
                              color: const Color(0xFFFFFFFF).withOpacity(0.25),
                              blurRadius: 0,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                              blurStyle: BlurStyle.inner,
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            l10n.replacePinTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            l10n.replacePinDescription(
                                localizeHabitName(currentPinned!, l10n),
                                localizeHabitName(widget.habitTitle, l10n)),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: colors.ctaPrimary,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Replace pin button
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
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
                              boxShadow: [
                                BoxShadow(
                                  color: colors.textPrimary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                l10n.replacePinConfirm,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Cancel
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              l10n.commonCancel,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.textTertiary,
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
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _animatePin();
    }
  }

  void _handleSwap() async {
    final onboardingState = context.read<OnboardingState>();
    final category = onboardingState.getCategoryForHabit(widget.habitTitle);

    if (category == null) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showIntendedModal(
          context: context,
          title: l10n.swapCantTitle,
          subtitle: l10n.swapCantMessage,
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => Navigator.pop(context),
              child: Builder(
                builder: (ctx) {
                  final clr =
                      Provider.of<ThemeProvider>(ctx, listen: false).colors;
                  return Text(
                    l10n.commonOk,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(ctx),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: clr.ctaPrimary,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
      return;
    }

    final isPremium = context.read<UserState>().hasSubscription;
    if (!isPremium &&
        !onboardingState.canSwapInCategory(category)) {
      _showSwapLimitDialog(category);
      return;
    }

    final alternatives =
        onboardingState.getAlternativeHabits(widget.habitTitle);

    if (alternatives.isEmpty) {
      _showNoAlternativesDialog();
      return;
    }

    _showSwapDialog(category, alternatives);
  }

  void _showSwapDialog(String category, List<String> alternatives) {
    final onboardingState = context.read<OnboardingState>();
    final isPremium = context.read<UserState>().hasSubscription;
    final remaining =
        onboardingState.getRemainingSwaps(category);
    final themeP = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(0.28),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 384),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
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
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark
                              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                              : const Color(0xFFFFFFFF).withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.modalShadow.withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                          if (!isDark)
                            BoxShadow(
                              color: const Color(0xFFFFFFFF).withOpacity(0.25),
                              blurRadius: 0,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                              blurStyle: BlurStyle.inner,
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            l10n.swapTitle(
                                localizeHabitName(widget.habitTitle, l10n)),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: -0.3,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description (REVERTED to DM Sans)
                          Text(
                            l10n.swapCategoryHabits(
                                localizeCategoryName(category, l10n)),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: colors.ctaPrimary,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Habit alternatives buttons
                          ...alternatives.map((habit) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.buttonDark
                                              .withOpacity(0.1),
                                          blurRadius: 12,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 20, sigmaY: 20),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: isDark
                                                  ? [
                                                      colors.cardBackground.withOpacity(colors.cardBackgroundOpacity),
                                                      colors.cardBackground.withOpacity(colors.cardBackgroundOpacity * 0.85),
                                                    ]
                                                  : [
                                                      Colors.white.withOpacity(0.65),
                                                      colors.surfaceLight
                                                          .withOpacity(0.50),
                                                    ],
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                                  : Colors.white.withOpacity(0.45),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: CupertinoButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _performSwap(habit);
                                            },
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 20),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            child: Text(
                                              localizeHabitName(habit, l10n),
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.bodyFont(
                                                        context),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: colors.textPrimary,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )),

                          const SizedBox(height: 28),

                          // Free swaps remaining (hide for premium)
                          if (!isPremium)
                            Text(
                              l10n.swapFreeRemaining(remaining),
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                              ),
                            ),

                          const SizedBox(height: 26),

                          // Cancel button (ghost)
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              onPressed: () => Navigator.pop(context),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                l10n.commonCancel,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textTertiary,
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
          ),
        ),
      ),
    );
  }

  Future<void> _performSwap(String newHabit) async {
    final onboardingState = context.read<OnboardingState>();
    final userState = context.read<UserState>();
    final isPremium = userState.hasSubscription;
    // Capture context values before await — the card may be deactivated
    // after swapHabit calls notifyListeners() and the parent rebuilds.
    final navigator = Navigator.of(context);
    final themeP = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final l10n = AppLocalizations.of(context);

    final success = await onboardingState.swapHabit(widget.habitTitle, newHabit,
        isPremium: isPremium);

    if (success) {
      AnalyticsService.logHabitSwapped();
      HapticFeedback.mediumImpact();

      navigator.push(CupertinoDialogRoute(
        context: navigator.context,
        barrierDismissible: true,
        builder: (context) => Container(
          color: colors.barrierColor.withOpacity(0.28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 384),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: colors.modalShadow.withOpacity(0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.3, -0.5),
                          end: const Alignment(0.3, 0.5),
                          colors: [
                            colors.modalBg1.withOpacity(0.96),
                            colors.modalBg2.withOpacity(0.93),
                            colors.modalBg3.withOpacity(0.95),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark
                              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                              : Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              l10n.swapSuccessTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                                letterSpacing: -0.4,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              l10n.swapSuccessMessage(
                                  localizeHabitName(newHabit, l10n)),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colors.textSubtitle,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Primary button (Great)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.textPrimary.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CupertinoButton(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  l10n.commonGreat,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.bodyFont(context),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
            ),
          ),
        ),
      ));
    }
  }

  void _showSwapLimitDialog(String category) {
    AnalyticsService.logHabitSwapLimitReached();
    final l10n = AppLocalizations.of(context);
    showBoostOfferSheet(
      context: context,
      title: l10n.boostOfferSwapTitle,
      description: l10n.boostOfferSwapDesc,
      showBoostOption: false,
      source: 'swap_limit',
    ).then((result) {
      if (result == 'paywall') openPaywallFromContext(context, source: 'swap_limit');
    });
  }

  void _showNoAlternativesDialog() {
    final l10n = AppLocalizations.of(context);
    showIntendedDialog(
      context: context,
      title: l10n.swapNoAltTitle,
      subtitle: l10n.swapNoAltMessage,
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }

  void _showEditDialog() {
    final onboardingState = context.read<OnboardingState>();
    final themeP = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final l10n = AppLocalizations.of(context);
    final editController = TextEditingController(text: widget.habitTitle);

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final text = editController.text.trim();
            final canSave = text.isNotEmpty &&
                text.length >= 3 &&
                text.length <= 50 &&
                text != widget.habitTitle &&
                !ProfanityFilter.containsProfanity(text);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(dialogContext),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 24,
                  bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 24,
                  left: 24,
                  right: 24,
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                    constraints: const BoxConstraints(maxWidth: 384),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: colors.modalShadow.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: const Alignment(-0.3, -0.5),
                              end: const Alignment(0.3, 0.5),
                              colors: [
                                colors.modalBg1.withOpacity(0.96),
                                colors.modalBg2.withOpacity(0.93),
                                colors.modalBg3.withOpacity(0.95),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark
                                  ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                  : Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.editHabitTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 27,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.4,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CupertinoTextField(
                                  controller: editController,
                                  autofocus: true,
                                  maxLength: 50,
                                  onChanged: (_) => setDialogState(() {}),
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: colors.textPrimary,
                                    fontFamily: AppTextStyles.bodyFont(dialogContext),
                                  ),
                                  placeholderStyle: TextStyle(
                                    fontSize: 17,
                                    color: colors.textSecondary,
                                    fontFamily: AppTextStyles.bodyFont(dialogContext),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? colors.cardBackground.withOpacity(colors.cardBackgroundOpacity)
                                        : const Color(0xFFFFFFFF).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                          : colors.buttonDark.withOpacity(0.12),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.customHabitCharCount(editController.text.length),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textSecondary,
                                    fontFamily: AppTextStyles.bodyFont(dialogContext),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: canSave
                                          ? [
                                              colors.ctaPrimary.withOpacity(0.92),
                                              colors.ctaSecondary.withOpacity(0.88),
                                            ]
                                          : [
                                              colors.textDisabled.withOpacity(0.3),
                                              colors.textDisabled.withOpacity(0.2),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    onPressed: canSave
                                        ? () async {
                                            Navigator.pop(dialogContext);
                                            await onboardingState.renameCustomHabit(
                                                widget.habitTitle, text);
                                          }
                                        : null,
                                    child: Text(
                                      l10n.editHabitSave,
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.bodyFont(dialogContext),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: canSave
                                            ? Colors.white
                                            : colors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                CupertinoButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Text(
                                      l10n.commonCancel,
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.bodyFont(dialogContext),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: colors.textTertiary,
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
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    final onboardingState = context.read<OnboardingState>();
    final themeP = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: colors.modalShadow.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-0.3, -0.5),
                        end: const Alignment(0.3, 0.5),
                        colors: [
                          colors.modalBg1.withOpacity(0.96),
                          colors.modalBg2.withOpacity(0.93),
                          colors.modalBg3.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark
                            ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                            : Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            l10n.deleteHabitTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Text(
                            l10n.deleteHabitMessage(
                                localizeHabitName(widget.habitTitle, l10n)),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.textSubtitle,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Delete button (muted red)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.destructive.withOpacity(0.92),
                                  colors.destructiveDark.withOpacity(0.88),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colors.destructiveDark.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              onPressed: () async {
                                Navigator.pop(context);
                                await onboardingState
                                    .removeCustomHabit(widget.habitTitle);
                                AnalyticsService.logCustomHabitRemoved();
                              },
                              child: Text(
                                l10n.commonDelete,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Cancel button
                          CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              l10n.commonCancel,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.textTertiary,
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    // Re-check completion status if the calendar date has changed
    // (handles midnight crossing while app is open)
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastCheckedDate.isNotEmpty && _lastCheckedDate != today) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfDone());
    }

    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);
    final isCustom =
        context.read<OnboardingState>().isCustomHabit(widget.habitTitle);

    // Determine accent color based on state
    final Color effectiveAccentColor;
    if (widget.isPinned) {
      effectiveAccentColor = colors.pinnedAccent; // Theme-aware pinned accent
    } else if (isCustom) {
      // Use focus area color for custom habits
      final customArea = context
          .read<OnboardingState>()
          .customHabitFocusAreas[widget.habitTitle];
      effectiveAccentColor = customArea != null
          ? (AppColors.categoryColors[customArea] ??
              colors.accentCustom)
          : colors.accentCustom;
    } else {
      effectiveAccentColor =
          widget.accentColor ?? colors.accentRegular; // Warm taupe
    }

    Widget card = FadeTransition(
      opacity: _departureFade,
      child: ScaleTransition(
        scale: _departureScale,
        child: GestureDetector(
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: IntrinsicHeight(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: _isDoneToday ? 64 : 72),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // LEFT ACCENT BAR (only show if not completed)
                  if (!_isDoneToday)
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: effectiveAccentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),

                  // Spacing between accent bar and card
                  SizedBox(width: _isDoneToday ? 20 : 16),

                  // CARD
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: _isDoneToday ? 20 : 25,
                          sigmaY: _isDoneToday ? 20 : 25,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: _isDoneToday ? 20 : 24,
                          ),
                          decoration: BoxDecoration(
                            // Glassmorphism background (pinned = lighter/cooler + accent tint, regular = warmer)
                            color: _isDoneToday
                                ? colors.cardDone
                                    .withOpacity(colors.cardDoneOpacity)
                                : widget.isPinned
                                    ? colors.cardPinned.withOpacity(colors.cardPinnedOpacity)
                                    : colors.cardBackground.withOpacity(colors.cardBackgroundOpacity),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _isDoneToday
                                  ? colors.borderCard.withOpacity(0.10)
                                  : colors.borderCard
                                      .withOpacity(colors.borderCardOpacity),
                              width: 0.5,
                            ),
                            boxShadow: [
                              // Outer shadow for depth
                              BoxShadow(
                                color: colors.textPrimary.withOpacity(
                                  _isDoneToday
                                      ? 0.02
                                      : widget.isPinned
                                          ? 0.06
                                          : 0.04,
                                ),
                                blurRadius: _isDoneToday
                                    ? 8
                                    : widget.isPinned
                                        ? 20
                                        : 16,
                                offset: Offset(
                                    0,
                                    _isDoneToday
                                        ? 1
                                        : widget.isPinned
                                            ? 4
                                            : 2),
                              ),
                              // Top-edge bevel: light highlight for glassmorphism edge
                              if (!_isDoneToday)
                                BoxShadow(
                                  color: const Color(0xFFFFFFFF)
                                      .withOpacity(isDark ? 0.18 : 0.25),
                                  blurRadius: isDark ? 0.5 : 1,
                                  offset: Offset(0, isDark ? 1 : 1),
                                  blurStyle: BlurStyle.inner,
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Checkmark (only when completed) with animation
                              if (_isDoneToday) ...[
                                FadeTransition(
                                  opacity: _checkmarkFadeAnimation,
                                  child: ScaleTransition(
                                    scale: _checkmarkScaleAnimation,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.checkmarkBackground
                                            .withOpacity(0.40),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.checkmark,
                                        size: 12,
                                        color: colors.checkmarkFill,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],

                              // Habit title with animated fade
                              Expanded(
                                child: AnimatedBuilder(
                                  animation: _textFadeAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _isDoneToday
                                          ? _textFadeAnimation.value
                                          : 1.0,
                                      child: Text(
                                        localizeHabitName(
                                            widget.habitTitle, l10n),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: _isDoneToday ? 15 : 16,
                                          fontWeight: FontWeight.w500,
                                          color: _isDoneToday
                                              ? colors.textSecondary
                                              : colors.textPrimary,
                                          fontFamily:
                                              AppTextStyles.bodyFont(context),
                                          decoration: _isDoneToday
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          decorationColor: colors.textSecondary,
                                        ),
                                      ),
                                    );
                                  },
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
            ),
          ),
        ),
      ),
    );

    final wrappedCard = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isCustom
          ? Slidable(
              key: ValueKey('slidable_${widget.habitTitle}'),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.32,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) {},
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _showEditDialog,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(CupertinoIcons.pencil, size: 20, color: colors.textSecondary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showDeleteConfirmation,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: colors.destructive.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colors.destructive.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(CupertinoIcons.trash, size: 20, color: colors.destructive.withOpacity(0.7)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              child: card,
            )
          : card,
    );

    return wrappedCard;
  }
}

// ============================================================
// BROWSE HABITS BOTTOM SHEET
// ============================================================

class BrowseHabitsSheet extends StatefulWidget {
  const BrowseHabitsSheet({super.key});

  @override
  State<BrowseHabitsSheet> createState() => _BrowseHabitsSheetState();
}

class _BrowseHabitsSheetState extends State<BrowseHabitsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Category accent colors — use shared map from AppColors
  static const Map<String, Color> categoryColors = AppColors.categoryColors;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('browse_habits');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addHabit(String habit) {
    final onboardingState = context.read<OnboardingState>();
    final l10n = AppLocalizations.of(context);

    // Check if habit is already in user's list
    if (onboardingState.userHabits.contains(habit)) {
      // Show already added message
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.browseAlreadyAddedTitle,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.browseAlreadyAddedMessage(localizeHabitName(habit, l10n)),
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: l10n.commonOk,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Always show swap confirmation when adding from Browse
    _showSwapConfirmation(habit);
  }

  void _showSwapConfirmation(String newHabit) {
    final onboardingState = context.read<OnboardingState>();
    final userState = context.read<UserState>();
    final isPremium = userState.hasSubscription;
    final canSwap =
        isPremium || onboardingState.canSwapFromBrowse();
    final remainingSwaps =
        onboardingState.getRemainingBrowseSwaps();
    final l10n = AppLocalizations.of(context);

    if (!canSwap) {
      showBoostOfferSheet(
        context: context,
        title: l10n.boostOfferSwapTitle,
        description: l10n.boostOfferSwapDesc,
        showBoostOption: false,
        source: 'browse_swap_limit',
      ).then((result) {
        if (result == 'paywall') openPaywallFromContext(context, source: 'browse_swap_limit');
      });
      return;
    }

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.browseSwapConfirmTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isPremium
                ? l10n
                    .browseSwapConfirmMessage(localizeHabitName(newHabit, l10n))
                : '${l10n.browseSwapConfirmMessage(localizeHabitName(newHabit, l10n))}\n\n${l10n.browseSwapRemainingCount(remainingSwaps)}',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          styledPrimaryButton(
            label: l10n.browseChooseHabitToSwap,
            onPressed: () {
              Navigator.pop(context);
              _showHabitSelection(newHabit);
            },
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Builder(
              builder: (ctx) {
                final clr =
                    Provider.of<ThemeProvider>(ctx, listen: false).colors;
                return Text(
                  l10n.commonCancel,
                  style: TextStyle(
                    fontSize: 16,
                    color: clr.ctaPrimary,
                    fontFamily: AppTextStyles.bodyFont(ctx),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showHabitSelection(String newHabit) {
    final onboardingState = context.read<OnboardingState>();
    final currentHabits = onboardingState.userHabits;
    final themeP = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeP.colors;
    final isDark = themeP.theme.isDark;
    final l10n = AppLocalizations.of(context);

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.browseWhichToReplace,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.browseChooseToReplaceMessage(
                localizeHabitName(newHabit, l10n)),
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...currentHabits.map((oldHabit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context);
                    _performSwap(oldHabit, newHabit);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colors.cardBackground.withOpacity(colors.cardBackgroundOpacity)
                          : const Color(0xFFFFFFFF).withOpacity(0.45),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                            : const Color(0xFFFFFFFF).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      localizeHabitName(oldHabit, l10n),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(
                fontSize: 16,
                color: colors.ctaPrimary,
                fontFamily: AppTextStyles.bodyFont(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSwap(String oldHabit, String newHabit) async {
    final onboardingState = context.read<OnboardingState>();
    final userState = context.read<UserState>();
    final success = await onboardingState.swapHabit(oldHabit, newHabit,
        isPremium: userState.hasSubscription);

    if (success && mounted) {
      AnalyticsService.logHabitSwapped();
      HapticFeedback.mediumImpact();
      final themeP = Provider.of<ThemeProvider>(context, listen: false);
      final colors = themeP.colors;
      final isDark = themeP.theme.isDark;
      final l10n = AppLocalizations.of(context);

      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Container(
          color: colors.barrierColor.withOpacity(0.28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 384),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
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
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.modalShadow.withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                          if (!isDark)
                            BoxShadow(
                              color: const Color(0xFFFFFFFF).withOpacity(0.25),
                              blurRadius: 0,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                              blurStyle: BlurStyle.inner,
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            l10n.swapSuccessTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description (Sora to match Unpin modal)
                          Text(
                            l10n.swapSuccessMessage(
                                localizeHabitName(newHabit, l10n)),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.textSubtitle,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // OK button
                          SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
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
                                    border: Border.all(
                                      color: colors.ctaPrimary.withOpacity(0.4),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            colors.textPrimary.withOpacity(0.3),
                                        blurRadius: 24,
                                        offset: const Offset(0, 6),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFFFFFFF)
                                            .withOpacity(0.15),
                                        blurRadius: 0,
                                        offset: const Offset(0, 1),
                                        spreadRadius: 0,
                                        blurStyle: BlurStyle.inner,
                                      ),
                                    ],
                                  ),
                                  child: CupertinoButton(
                                    onPressed: () => Navigator.pop(context),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Text(
                                      l10n.commonGreat,
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFFFFF),
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
          ),
        ),
      );
    } else if (mounted) {
      final l10nErr = AppLocalizations.of(context);
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10nErr.swapErrorTitle,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10nErr.swapErrorMessage,
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: l10nErr.commonOk,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _showPackDetail(CuratedPack pack) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(colors.barrierOpacity),
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      builder: (context) => _PackDetailSheet(pack: pack),
    );
  }

  void _performDirectAdd(String habit) {
    final onboardingState = context.read<OnboardingState>();
    onboardingState.addHabitFromBrowse(habit);
    HapticFeedback.mediumImpact();

    // Close sheet and show confirmation
    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.browseHabitAddedTitle,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.browseHabitAddedMessage(localizeHabitName(habit, l10n)),
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: l10n.browseHabitAddedConfirm,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final onboardingState = context.watch<OnboardingState>();
    final l10n = AppLocalizations.of(context);

    // Get habits organized by category
    // Adjust this based on your actual data model
    final Map<String, List<String>> habitsByCategory =
        _getHabitsByCategory(onboardingState);

    // Filter by search query
    final filteredCategories = <String, List<String>>{};
    for (final entry in habitsByCategory.entries) {
      final filtered = entry.value
          .where((h) =>
              h.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              localizeHabitName(h, l10n)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
      if (filtered.isNotEmpty) {
        filteredCategories[entry.key] = filtered;
      }
    }

    // Count total available habits
    int totalHabits = 0;
    for (final habits in habitsByCategory.values) {
      totalHabits += habits.length;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surfaceLight, // Sheet top
            colors.modalBg2, // Sheet bottom
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================================
          // HANDLE BAR
          // ============================================================
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.buttonDark.withOpacity(0.25),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          // ============================================================
          // HEADER
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.browseHabitsTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: colors.ctaPrimary,
                        letterSpacing: -0.5,
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.browseHabitsAvailable(totalHabits),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.commonClose,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // SEARCH BAR
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.cardBackground.withOpacity(colors.cardBackgroundOpacity)
                    : const Color(0xFFFFFFFF).withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                      : colors.buttonDark.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withOpacity(0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: colors.textSecondary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoTextField(
                      controller: _searchController,
                      placeholder: l10n.browseHabitsSearch,
                      padding: EdgeInsets.zero,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                        fontFamily: 'DMSans',
                      ),
                      placeholderStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary.withOpacity(0.6),
                        fontFamily: 'DMSans',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================================
          // SCROLLABLE CONTENT
          // ============================================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              children: [
                // ========================================================
                // CURATED PACKS SECTION
                // ========================================================
                if (_searchQuery.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 14),
                    child: Text(
                      l10n.packSectionHeader,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.buttonDark,
                        letterSpacing: 0.5,
                        fontFamily: AppTextStyles.bodyFont(context),
                      ),
                    ),
                  ),
                  Builder(builder: (context) {
                    final userHabits = context.watch<OnboardingState>().userHabits;
                    bool isPackActive(CuratedPack p) =>
                        p.habitIds.every((h) => userHabits.contains(h));
                    final sortedPacks = List<CuratedPack>.from(CuratedPacks.all)
                      ..sort((a, b) {
                        final aActive = isPackActive(a);
                        final bActive = isPackActive(b);
                        if (aActive != bActive) return aActive ? -1 : 1;
                        return a.sortOrder.compareTo(b.sortOrder);
                      });
                    return SizedBox(
                      height: 158,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: sortedPacks.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final pack = sortedPacks[index];
                            final active = isPackActive(pack);
                            return _CuratedPackCard(
                              pack: pack,
                              isActive: active,
                              onTap: () => _showPackDetail(pack),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // ========================================================
                // HABIT CATEGORIES
                // ========================================================
                ...filteredCategories.entries.map((entry) {
                  final category = entry.key;
                  final habits = entry.value;
                  final accentColor =
                      categoryColors[category] ?? colors.accentMuted;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 14),
                          child: Text(
                            localizeCategoryName(category, l10n).toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.buttonDark,
                              letterSpacing: 0.5,
                              fontFamily: AppTextStyles.bodyFont(context),
                            ),
                          ),
                        ),
                        ...habits.map((habit) {
                          final isCustomActive = onboardingState
                              .isCustomHabit(habit);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BrowseHabitCard(
                              habitTitle: habit,
                              accentColor: accentColor,
                              onAdd: isCustomActive
                                  ? null
                                  : () => _addHabit(habit),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER: Get habits organized by category
  // Adjust this based on your actual OnboardingState data model
  // ============================================================
  Map<String, List<String>> _getHabitsByCategory(OnboardingState state) {
    // Get habits only from user's selected focus areas
    final Map<String, List<String>> result = {};

    for (final category in state.focusAreas) {
      final habits = OnboardingState.habitsByCategory[category];
      if (habits != null) {
        // Filter out habits the user already has
        final availableHabits =
            habits.where((habit) => !state.userHabits.contains(habit)).toList();

        if (availableHabits.isNotEmpty) {
          result[category] = availableHabits;
        }
      }

      // Add custom habits assigned to this category (already active ones)
      for (final customHabit in state.customHabits) {
        final area = state.customHabitFocusAreas[customHabit];
        if (area == category && state.userHabits.contains(customHabit)) {
          result.putIfAbsent(category, () => []).insert(0, customHabit);
        }
      }
    }

    return result;
  }
}

// ============================================================
// BROWSE HABIT CARD (for the bottom sheet)
// ============================================================

class _BrowseHabitCard extends StatelessWidget {
  final String habitTitle;
  final Color accentColor;
  final VoidCallback? onAdd;

  const _BrowseHabitCard({
    required this.habitTitle,
    required this.accentColor,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isDark = context.watch<ThemeProvider>().theme.isDark;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
              : const Color(0xFFFFFFFF).withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored left stripe - integrated into the card
              Container(
                width: 4,
                color: accentColor,
              ),

              // Card content with gradient background
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              colors.cardBackground.withOpacity(colors.cardBackgroundOpacity),
                              colors.cardBackground.withOpacity(colors.cardBackgroundOpacity * 0.85),
                            ]
                          : [
                              const Color(0xFFFFFFFF).withOpacity(0.7),
                              const Color(0xFFFFFFFF).withOpacity(0.5),
                            ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Habit title
                      Expanded(
                        child: Text(
                          localizeHabitName(habitTitle, l10n),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                            height: 1.5,
                            fontFamily: 'DMSans',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add button or Active badge
                      if (onAdd != null)
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: colors.ctaPrimary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.ctaPrimary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              CupertinoIcons.plus,
                              size: 20,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.packHabitActive,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PACK LOCALIZATION HELPER
// ============================================================

({String name, String subtitle, String description}) _localizedPack(
  AppLocalizations l10n,
  CuratedPack pack,
) {
  return switch (pack.id) {
    'gentle_mornings' => (
      name: l10n.packGentleMorningsName,
      subtitle: l10n.packGentleMorningsSubtitle,
      description: l10n.packGentleMorningsDescription,
    ),
    'winding_down' => (
      name: l10n.packWindingDownName,
      subtitle: l10n.packWindingDownSubtitle,
      description: l10n.packWindingDownDescription,
    ),
    'tiny_resets' => (
      name: l10n.packTinyResetsName,
      subtitle: l10n.packTinyResetsSubtitle,
      description: l10n.packTinyResetsDescription,
    ),
    'creative_spark' => (
      name: l10n.packCreativeSparkName,
      subtitle: l10n.packCreativeSparkSubtitle,
      description: l10n.packCreativeSparkDescription,
    ),
    'stay_connected' => (
      name: l10n.packStayConnectedName,
      subtitle: l10n.packStayConnectedSubtitle,
      description: l10n.packStayConnectedDescription,
    ),
    _ => (
      name: pack.name,
      subtitle: pack.subtitle,
      description: pack.description,
    ),
  };
}

// ============================================================
// CURATED PACK CARD (for the Browse sheet)
// ============================================================

class _CuratedPackCard extends StatelessWidget {
  final CuratedPack pack;
  final VoidCallback onTap;
  final bool isActive;

  const _CuratedPackCard({
    required this.pack,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isDark = context.watch<ThemeProvider>().theme.isDark;
    final l10n = AppLocalizations.of(context);
    final lp = _localizedPack(l10n, pack);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? colors.ctaPrimary.withOpacity(0.5)
                : isDark
                    ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                    : const Color(0xFFFFFFFF).withOpacity(0.8),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        colors.cardBackground.withOpacity(colors.cardBackgroundOpacity),
                        colors.cardBackground.withOpacity(colors.cardBackgroundOpacity * 0.85),
                      ]
                    : [
                        const Color(0xFFFFFFFF).withOpacity(0.7),
                        const Color(0xFFFFFFFF).withOpacity(0.5),
                      ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Pack icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.ctaPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        pack.icon,
                        size: 18,
                        color: colors.ctaPrimary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: colors.textSecondary.withOpacity(0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lp.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    fontFamily: 'Sora',
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.packHabitsCount(pack.habitIds.length),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lp.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textSecondary.withOpacity(0.7),
                    fontFamily: 'DMSans',
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                _PackTierBadge(pack: pack, isActive: isActive),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PACK TIER BADGE
// ============================================================

class _PackTierBadge extends StatelessWidget {
  final CuratedPack pack;
  final bool isActive;

  const _PackTierBadge({required this.pack, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final isFree = pack.isFree;
    final l10n = AppLocalizations.of(context);

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.ctaPrimary.withOpacity(0.20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colors.ctaPrimary.withOpacity(0.35),
            width: 1,
          ),
        ),
        child: Text(
          l10n.packActiveBadge,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.ctaPrimary,
            fontFamily: 'DMSans',
            letterSpacing: 0.1,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFree
            ? colors.ctaPrimary.withOpacity(0.10)
            : colors.ctaPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFree
              ? colors.ctaPrimary.withOpacity(0.20)
              : colors.ctaPrimary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Text(
        isFree ? l10n.packFreeBadge : 'Intended+',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.ctaPrimary,
          fontFamily: 'DMSans',
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ============================================================
// PACK DETAIL SHEET
// ============================================================

class _PackDetailSheet extends StatelessWidget {
  final CuratedPack pack;

  const _PackDetailSheet({required this.pack});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final onboardingState = context.watch<OnboardingState>();
    final l10n = AppLocalizations.of(context);
    final lp = _localizedPack(l10n, pack);

    // Count how many habits are already active
    final alreadyActive =
        pack.habitIds.where((h) => onboardingState.userHabits.contains(h)).length;
    final allActive = alreadyActive == pack.habitIds.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surfaceLight,
            colors.modalBg2,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1F000000),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.buttonDark.withOpacity(0.25),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              children: [
                // Pack emoji + name
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.ctaPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      pack.icon,
                      size: 32,
                      color: colors.ctaPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lp.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          fontFamily: 'Sora',
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _PackTierBadge(pack: pack, isActive: allActive),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lp.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                    fontFamily: 'DMSans',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lp.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary.withOpacity(0.8),
                    fontFamily: 'DMSans',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Habits list header
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 14),
                  child: Text(
                    l10n.packHabitsInPack,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.buttonDark,
                      letterSpacing: 0.5,
                      fontFamily: AppTextStyles.bodyFont(context),
                    ),
                  ),
                ),

                // Habit list
                ...pack.habitIds.map((habitId) {
                  final category =
                      OnboardingState.habitsByCategory.entries
                          .where((e) => e.value.contains(habitId))
                          .map((e) => e.key)
                          .firstOrNull;
                  final accentColor = category != null
                      ? (AppColors.categoryColors[category] ??
                          colors.accentMuted)
                      : colors.accentMuted;
                  final isActive = onboardingState.userHabits.contains(habitId);
                  final l10n = AppLocalizations.of(context);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                              : const Color(0xFFFFFFFF).withOpacity(0.8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(width: 4, color: accentColor),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? [
                                              colors.cardBackground.withOpacity(colors.cardBackgroundOpacity),
                                              colors.cardBackground.withOpacity(colors.cardBackgroundOpacity * 0.85),
                                            ]
                                          : [
                                              const Color(0xFFFFFFFF)
                                                  .withOpacity(0.7),
                                              const Color(0xFFFFFFFF)
                                                  .withOpacity(0.5),
                                            ],
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          localizeHabitName(habitId, l10n),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textPrimary,
                                            fontFamily: 'DMSans',
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      if (isActive)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: colors.ctaPrimary
                                                .withOpacity(0.10),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            l10n.packHabitActive,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: colors.ctaPrimary,
                                              fontFamily: 'DMSans',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Bottom button area
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
            child: _PackStartButton(
              pack: pack,
              allActive: allActive,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PACK START BUTTON
// ============================================================

class _PackStartButton extends StatelessWidget {
  final CuratedPack pack;
  final bool allActive;

  const _PackStartButton({
    required this.pack,
    required this.allActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    if (allActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.ctaPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.ctaPrimary.withOpacity(0.15),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context).packAllActive,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFont(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.ctaPrimary.withOpacity(0.6),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
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
              border: Border.all(
                color: colors.ctaPrimary.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
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
              onPressed: () => _startPack(context),
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: BorderRadius.circular(20),
              child: Text(
                AppLocalizations.of(context).packStartButton(_localizedPack(AppLocalizations.of(context), pack).name),
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
      ),
    );
  }

  Future<void> _startPack(BuildContext context) async {
    final userState = context.read<UserState>();
    final onboardingState = context.read<OnboardingState>();

    // Premium gating — packs are an Intended+ feature
    if (pack.isPremium && !userState.hasSubscription) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close detail sheet
      showCupertinoModalPopup(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        builder: (_) => PaywallScreen(source: 'curated_pack_${pack.id}'),
      );
      return;
    }

    // Count how many new habits would be added
    final newHabits = pack.habitIds
        .where((h) => !onboardingState.userHabits.contains(h))
        .toList();

    // Habits that exist but aren't part of this pack (candidates to swap out)
    final habitsOutsidePack = onboardingState.userHabits
        .where((h) => !pack.habitIds.contains(h))
        .where((h) => !onboardingState.customHabits.contains(h))
        .toList();

    // Show swap flow whenever user has habits outside the pack
    if (habitsOutsidePack.isNotEmpty && newHabits.isNotEmpty) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close detail sheet
      showCupertinoModalPopup(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => _PackSwapSheet(
          pack: pack,
          newHabitsCount: newHabits.length,
        ),
      );
      return;
    }

    // Grab root overlay before async gap
    final rootOverlay = Overlay.of(context, rootOverlay: true);
    final nav = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final lp = _localizedPack(l10n, pack);

    // No conflicts — add directly
    final added = await onboardingState.addHabitsFromPack(pack.habitIds);
    await onboardingState.applyPackFocusAreas(pack.focusAreas);

    HapticFeedback.mediumImpact();

    final alreadyActive = pack.habitIds.length - added;
    final message = alreadyActive > 0
        ? '$added new habits added ($alreadyActive already active)'
        : '${lp.name} added — $added habits ready to go';

    nav.pop(); // Close detail sheet
    AppToast.showOnOverlay(rootOverlay, message);
  }
}

// ============================================================
// PACK SWAP SHEET — "Make room" flow
// ============================================================

class _PackSwapSheet extends StatefulWidget {
  final CuratedPack pack;
  final int newHabitsCount;

  const _PackSwapSheet({
    required this.pack,
    required this.newHabitsCount,
  });

  @override
  State<_PackSwapSheet> createState() => _PackSwapSheetState();
}

class _PackSwapSheetState extends State<_PackSwapSheet> {
  final Set<String> _selected = {};

  /// Swappable habits: current habits that are NOT in the pack
  /// and NOT custom habits.
  List<String> _swappableHabits(OnboardingState state) {
    return state.userHabits
        .where((h) => !widget.pack.habitIds.contains(h))
        .where((h) => !state.customHabits.contains(h))
        .toList();
  }


  Future<void> _confirm() async {
    final state = context.read<OnboardingState>();
    final l10n = AppLocalizations.of(context);
    final lp = _localizedPack(l10n, widget.pack);

    // Set aside selected habits
    await state.setAsideHabits(_selected.toList());

    // Add pack habits
    final added = await state.addHabitsFromPack(widget.pack.habitIds);

    // Update focus areas to match the pack
    await state.applyPackFocusAreas(widget.pack.focusAreas);

    if (!mounted) return;

    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    final message = added > 0
        ? '${lp.name} ${l10n.packSwapAdded(added)}'
        : l10n.packSwapAllActive;
    AppToast.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final swappable = _swappableHabits(state);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.5),
              width: 1.5,
            ),
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

                // Title
                Text(
                  l10n.packSwapTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l10n.packSwapSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Habit list
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final habit in swappable)
                          _buildHabitRow(habit, colors, l10n),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.ctaPrimary.withOpacity(
                                  _selected.isNotEmpty ? 0.92 : 0.4),
                              colors.ctaSecondary.withOpacity(
                                  _selected.isNotEmpty ? 0.88 : 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CupertinoButton(
                          onPressed: _selected.isNotEmpty
                              ? _confirm
                              : null,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(20),
                          child: Text(
                            l10n.packSwapConfirm(
                                _selected.length, _localizedPack(l10n, widget.pack).name),
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selected.isNotEmpty
                                  ? const Color(0xFFFFFFFF)
                                  : colors.textDisabled,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitRow(String habit, AppColorScheme colors, AppLocalizations l10n) {
    final isChecked = _selected.contains(habit);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isChecked) {
            _selected.remove(habit);
          } else {
            _selected.add(habit);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked
              ? colors.ctaPrimary.withOpacity(0.08)
              : colors.cardBackground.withOpacity(colors.cardBackgroundOpacity * 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isChecked
                ? colors.ctaPrimary.withOpacity(0.25)
                : colors.borderCard.withOpacity(colors.borderCardOpacity * 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked
                    ? colors.ctaPrimary
                    : colors.checkmarkBackground
                        .withOpacity(colors.checkmarkBackgroundOpacity),
              ),
              child: isChecked
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      size: 13,
                      color: Color(0xFFFFFFFF),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizeHabitName(habit, l10n),
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isChecked
                      ? colors.textSecondary
                      : colors.textPrimary,
                  decoration:
                      isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitActionScreen extends StatefulWidget {
  final String habitTitle;

  const HabitActionScreen({super.key, required this.habitTitle});

  @override
  State<HabitActionScreen> createState() => _HabitActionScreenState();
}

class _HabitActionScreenState extends State<HabitActionScreen> {
  bool _isDone = false;
  bool _isProcessing = false;
  String _supportWord = '';

  // Warm, gentle support words
  static const List<String> _supportWords = [
    'Nice',
    'Well done',
    'You did it',
    'Great',
    'Way to go',
    'Good job',
    'Lovely',
    'That counts',
  ];

  Future<void> _markAsDone() async {
    if (_isProcessing) return;

    // Pick random support word
    final random = Random();
    _supportWord = _supportWords[random.nextInt(_supportWords.length)];

    setState(() {
      _isProcessing = true;
      _isDone = true;
    });

    HapticFeedback.heavyImpact();
    await HabitTracker.markDone(widget.habitTitle);
    AnalyticsService.logHabitCompleted(widget.habitTitle);

    // Record the moment
    await MomentsService.record(
      Moment(
        id: DateTime.now().toUtc().toIso8601String(),
        habitName: widget.habitTitle,
        habitEmoji: '✦',
        completedAt: DateTime.now().toUtc(),
      ),
    );
    MilestoneService.invalidate();

    // Update home screen widget
    if (mounted) refreshHomeWidget(context);

    // Show heart + support for 1 second
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _skipForToday() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    return CupertinoPageScaffold(
      backgroundColor: colors.surfaceLightest, // Match app background
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.surfaceLightest,
                colors.modalBg2,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Did you do this today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sora',
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: CupertinoButton(
                      color: _isDone ? colors.success : colors.buttonDark,
                      borderRadius:
                          BorderRadius.circular(ComponentSizes.buttonRadius),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      onPressed: _isDone ? null : _markAsDone,
                      child: _isDone
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '❤️',
                                  style: TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _supportWord,
                                  style: TextStyle(
                                    color: colors.surfaceLightest,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Sora',
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'I did it',
                              style: AppTextStyles.buttonPrimary(context),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (!_isDone)
                    CupertinoButton(
                      color: colors.surfaceLightest,
                      borderRadius:
                          BorderRadius.circular(ComponentSizes.buttonRadius),
                      onPressed: _skipForToday,
                      child: Text(
                        'Not today',
                        style: TextStyle(
                          color: colors.buttonDark,
                          fontFamily: AppTextStyles.bodyFont(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
