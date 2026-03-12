import 'dart:async';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircleAvatar, Colors, NetworkImage;
import '../widgets/app_toast.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// sign_in_with_apple and sign_in_button packages available for auth implementation

import '../main.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/analytics_service.dart';
import '../onboarding_v2/welcome_v2_screen.dart';
import '../state/user_state.dart';
import '../utils/profanity_filter.dart';
import '../utils/text_styles.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'paywall_screen.dart';
import 'subscription_management_modal.dart';
import '../widgets/theme_picker.dart';
import '../services/auth_service.dart';
import '../services/revenue_cat_service.dart';
import '../services/moments_service.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_preferences_service.dart';
import 'moments_collection_screen.dart';
import '../widgets/app_icon_picker.dart';
import '../widgets/boost_offer_sheet.dart';
import '../widgets/focus_area_card.dart';
import '../onboarding_v2/focus_areas_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = TextEditingController();
  bool _isEditing = false;

  bool _isSigningIn = false;

  // Auth state
  User? _currentUser;
  late final StreamSubscription<User?> _authSub;

  // Notification prefs state
  bool _dailyEnabled = false;
  int _notifHour = 9;
  int _notifMinute = 0;
  bool _weeklyEnabled = false;
  bool _notifPermissionDenied = false;
  bool _notifPrefsLoaded = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('profile');
    controller.addListener(() {
      setState(() {});
    });
    _currentUser = FirebaseAuth.instance.currentUser;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) setState(() => _currentUser = user);
    });
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final enabled = await NotificationPreferencesService.isEnabled();
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();
    final weeklyEnabled =
        await NotificationPreferencesService.isWeeklyEnabled();
    if (mounted) {
      setState(() {
        _dailyEnabled = enabled;
        _notifHour = hour;
        _notifMinute = minute;
        _weeklyEnabled = weeklyEnabled;
        _notifPrefsLoaded = true;
      });
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() => _isSigningIn = true);
    try {
      final credential = await AuthService.signInWithGoogle();
      if (credential?.user != null && context.mounted) {
        await context.read<RevenueCatService>().logIn(credential!.user!.uid);
      }
    } catch (e) {
      if (context.mounted) {
        _showSignInError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    setState(() => _isSigningIn = true);
    try {
      final credential = await AuthService.signInWithApple();
      if (credential?.user != null && context.mounted) {
        await context.read<RevenueCatService>().logIn(credential!.user!.uid);
      }
    } catch (e, stackTrace) {
      debugPrint('Sign in with Apple error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        _showSignInError(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  void _showSignInError(BuildContext context, Object error) {
    debugPrint('Sign in error details: $error');
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sign in failed'),
        content: Text(
          kDebugMode
              ? 'Something went wrong. Please try again.\n\nDebug: $error'
              : 'Something went wrong. Please try again.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void dispose() {
    _authSub.cancel();
    controller.dispose();
    super.dispose();
  }

  String _localizedAreaName(AppLocalizations l10n, String area) {
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

  bool get canSave {
    final text = controller.text.trim();
    final currentName = userNameNotifier.value;
    if (text.isEmpty) return false;
    if (text == currentName) return false;
    return true;
  }

  Future<void> _saveName() async {
    final name = controller.text.trim();
    if (!canSave) return;

    if (ProfanityFilter.containsProfanity(name)) {
      final l10n = AppLocalizations.of(context);
      showIntendedDialog(
        context: context,
        title: l10n.profileNameError,
        subtitle: l10n.profileNameErrorMessage,
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.commonOk),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    userNameNotifier.value = name;
    AnalyticsService.logProfileNameEdited();

    if (mounted) {
      context.read<OnboardingState>().setName(name);
    }

    controller.clear();
    setState(() {
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      controller.text = userNameNotifier.value ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      controller.clear();
    });
  }

  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@intendedapp.com',
      query: 'subject=Intended App — Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final colors =
            Provider.of<ThemeProvider>(context, listen: false).colors;
        showIntendedModal(
          context: context,
          title: l10n.profileCannotOpenEmail,
          subtitle: l10n.profileEmailFallback,
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      borderRadius: BorderRadius.circular(16),
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
        );
      }
    }
  }

  void _changeFocusAreas() {
    final onboardingState = context.read<OnboardingState>();
    final userState = context.read<UserState>();

    // Subscription users bypass the monthly focus area change limit
    if (!userState.hasSubscription &&
        !onboardingState.canChangeFocusAreas()) {
      AnalyticsService.logFocusAreaChangeLimitShown();
      _showFocusAreaLimitDialog();
      return;
    }

    _showChangeFocusAreasConfirmation();
  }

  void _showChangeFocusAreasConfirmation() {
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    final colors = tp.colors;
    final isDarkDialog = tp.theme.isDark;
    final l10n = AppLocalizations.of(context);

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Container(
        color: colors.barrierColor.withOpacity(colors.barrierOpacity),
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
                        color: isDarkDialog
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
                        if (!isDarkDialog)
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
                          l10n.profileChangeFocusTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          l10n.profileChangeFocusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Primary button
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) =>
                                            _FocusAreaChangeScreen(),
                                      ),
                                    );
                                  },
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Text(
                                    l10n.profileChangeAreas,
                                    style: TextStyle(
                                      fontFamily:
                                          AppTextStyles.bodyFont(context),
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

                        const SizedBox(height: 16),

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
    );
  }

  void _showFocusAreaLimitDialog() {
    final l10n = AppLocalizations.of(context);
    showBoostOfferSheet(
      context: context,
      title: l10n.boostOfferFocusTitle,
      description: l10n.boostOfferFocusDesc,
      showBoostOption: false,
      source: 'focus_area_limit',
    );
  }

  Future<void> _showUpgradeScreen() {
    if (context.read<RevenueCatService>().isPremium) return Future.value();
    return showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) => const PaywallScreen(source: 'profile'),
    );
  }

  String _localizedThemeName(AppTheme theme, AppLocalizations l10n) {
    return switch (theme) {
      AppTheme.warmClay => l10n.themeWarmClay,
      AppTheme.iris => l10n.themeIris,
      AppTheme.clearSky => l10n.themeClearSky,
      AppTheme.morningSlate => l10n.themeMorningSlate,
      AppTheme.softDusk => l10n.themeSoftDusk,
      AppTheme.deepFocus => l10n.themeDeepFocus,
      AppTheme.forestFloor => l10n.themeForestFloor,
      AppTheme.goldenHour => l10n.themeGoldenHour,
      AppTheme.nightBloom => l10n.themeNightBloom,
      AppTheme.sandDune => l10n.themeSandDune,
    };
  }

  void _showAppearancePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userState = Provider.of<UserState>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final colors = themeProvider.colors;
          return ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.modalBg1.withOpacity(0.98),
                    colors.modalBg2.withOpacity(0.96),
                    colors.modalBg3.withOpacity(0.98),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        l10n.profileChangeSpace,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Theme picker
                      ThemePicker(
                        isPremium: userState.hasSubscription,
                        hasBoost: userState.hasBoost,
                        compact: true,
                        onPremiumTap: () {
                          Navigator.pop(context);
                          _showUpgradeScreen().then((_) {
                            if (mounted) _showAppearancePicker(this.context);
                          });
                        },
                        onBoostTap: () {
                          Navigator.pop(context);
                          final l10n = AppLocalizations.of(this.context);
                          showBoostOfferSheet(
                            context: this.context,
                            title: l10n.boostOfferThemeTitle,
                            description: l10n.boostOfferThemeDesc,
                            showBoostOption: true,
                            source: 'theme_picker',
                          ).then((result) {
                            if (!mounted) return;
                            if (result == 'paywall') {
                              _showUpgradeScreen().then((_) {
                                if (mounted) _showAppearancePicker(this.context);
                              });
                            } else {
                              _showAppearancePicker(this.context);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // App icon picker
                      AppIconPicker(
                        isPremium: userState.hasSubscription,
                        onPremiumTap: () {
                          Navigator.pop(context);
                          _showUpgradeScreen().then((_) {
                            if (mounted) _showAppearancePicker(this.context);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showSubscriptionManagement() async {
    final l10n = AppLocalizations.of(context);
    final rc = context.read<RevenueCatService>();
    String plan = '';
    String price = '';
    String renewalDate = '—';

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[RevenueCatService.entitlementPlus];
      if (entitlement != null && entitlement.isActive) {
        final productId = entitlement.productIdentifier;
        if (productId.contains('monthly')) {
          plan = l10n.paywallMonthly;
          final monthlyPrice =
              rc.monthlyPriceString ?? l10n.paywallMonthlyPrice;
          price = '$monthlyPrice/${l10n.paywallMonthly.toLowerCase()}';
        } else if (productId.contains('yearly')) {
          plan = l10n.paywallYearly;
          final yearlyPrice = rc.yearlyPriceString ?? l10n.paywallYearlyPrice;
          price = '$yearlyPrice/${l10n.paywallYearly.toLowerCase()}';
        }
        final expDate = entitlement.expirationDate;
        if (expDate != null) {
          final dt = DateTime.tryParse(expDate);
          if (dt != null) {
            renewalDate =
                '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
          }
        }
      }
    } catch (e) {
      debugPrint('Subscription info error: $e');
    }

    // Fallback for lifetime or when entitlement lookup failed
    if (plan.isEmpty) {
      plan = l10n.paywallLifetime;
      price = rc.lifetimePriceString ?? l10n.paywallLifetimePrice;
    }

    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SubscriptionManagementModal(
        plan: plan,
        price: price,
        renewalDate: renewalDate,
      ),
    );
  }

  void _showRefreshConfirmation() {
    final l10n = AppLocalizations.of(context);
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileRefreshTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileRefreshMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: l10n.commonRefresh,
            onPressed: () async {
              Navigator.pop(context);
              final onboardingState = context.read<OnboardingState>();
              await onboardingState.refreshHabits();
              AnalyticsService.logHabitRefreshed();
              if (mounted) {
                _showRefreshSuccess();
              }
            },
          ),
          const SizedBox(height: 14),
          styledSecondaryButton(
            label: l10n.commonCancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showRefreshSuccess() {
    final l10n = AppLocalizations.of(context);
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileRefreshSuccessTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileRefreshSuccessMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: l10n.commonGreat,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshHabits() async {
    final onboardingState = context.read<OnboardingState>();
    final userState = context.read<UserState>();

    if (!userState.hasSubscription && !onboardingState.canRefreshHabits()) {
      AnalyticsService.logHabitRefreshLimitReached();
      final l10n = AppLocalizations.of(context);
      showIntendedDialog(
        context: context,
        title: l10n.profileDailyLimitTitle,
        subtitle: l10n.profileDailyLimitMessage,
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.commonOk),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }

    _showRefreshConfirmation();
  }

  void _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://intendedapp.com/privacy');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showIntendedDialog(
          context: context,
          title: l10n.profileCannotOpenLink,
          subtitle: l10n.profilePrivacyFallback,
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        );
      }
    }
  }

  void _openTermsOfService() async {
    final Uri url = Uri.parse('https://intendedapp.com/terms');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showIntendedDialog(
          context: context,
          title: l10n.profileCannotOpenLink,
          subtitle: l10n.profileTermsFallback,
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        );
      }
    }
  }

  void _showDeleteError(AppLocalizations l10n) {
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.swapErrorTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileDeleteErrorMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          styledSecondaryButton(
            label: l10n.commonOk,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<bool> _reauthenticateAndDelete(
    User user,
    AppLocalizations l10n,
    AppColorScheme colors,
  ) async {
    final isApple = AuthService.isAppleUser;
    final isGoogle = AuthService.isGoogleUser;

    if (!isApple && !isGoogle) {
      _showDeleteError(l10n);
      return false;
    }

    // Show re-auth explanation dialog and wait for user action
    final shouldReauth = await showStyledPopup<bool>(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileReauthTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileReauthMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.ctaPrimary.withOpacity(0.92),
                  colors.ctaPrimary.withOpacity(0.88),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.ctaPrimary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n.profileReauthButton,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          styledSecondaryButton(
            label: l10n.commonCancel,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );

    if (shouldReauth != true || !mounted) return false;

    try {
      final success = isApple
          ? await AuthService.reauthenticateWithApple()
          : await AuthService.reauthenticateWithGoogle();
      if (!success) return false;
      await user.delete();
      try {
        FirebaseAnalytics.instance.logEvent(name: 'account_deleted');
      } catch (_) {}
      return true;
    } catch (_) {
      if (mounted) _showDeleteError(l10n);
      return false;
    }
  }

  void _deleteProfileData() {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileDeleteAllTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileDeleteAllMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
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
                  color: colors.destructiveDark.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: () async {
                final onboarding = context.read<OnboardingState>();
                final userState = context.read<UserState>();
                final themeProvider = context.read<ThemeProvider>();
                final nav = Navigator.of(context);
                Navigator.pop(context);

                // Delete server-side data if user is signed in
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final revenueCat = context.read<RevenueCatService>();
                  try {
                    // Apple users: always re-auth first to revoke token
                    // (App Store requirement + solves requires-recent-login)
                    if (AuthService.isAppleUser) {
                      final success =
                          await AuthService.reauthenticateWithApple();
                      if (!success) return; // User cancelled
                    }

                    await revenueCat.logOut();
                    await user.delete();
                    try {
                      FirebaseAnalytics.instance
                          .logEvent(name: 'account_deleted');
                    } catch (_) {}
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'requires-recent-login' && mounted) {
                      // Google users: re-auth on demand
                      final deleted =
                          await _reauthenticateAndDelete(user, l10n, colors);
                      if (!deleted) return;
                    } else {
                      if (mounted) _showDeleteError(l10n);
                      return;
                    }
                  } catch (_) {
                    if (mounted) _showDeleteError(l10n);
                    return;
                  }
                }

                await NotificationScheduler.cancelAll();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                await onboarding.reset();
                userState.reset();
                userNameNotifier.value = null;
                themeProvider.setTheme(AppTheme.warmClay);

                nav.pushAndRemoveUntil(
                  CupertinoPageRoute(
                    builder: (_) => const WelcomeV2Screen(),
                  ),
                  (route) => false,
                );
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
          styledSecondaryButton(
            label: l10n.commonCancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboardingState = context.watch<OnboardingState>();
    final hasHabits = onboardingState.userHabits.isNotEmpty;
    final focusAreas = onboardingState.focusAreas;
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (fixed)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24, MediaQuery.of(context).padding.top + 24, 24, 20),
                child: Text(
                  l10n.profileTitle,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                  children: [
                    // Profile Info Card (Main Card with 4 sections)
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Your Name
                          Text(
                            l10n.profileYourName,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (!_isEditing) ...[
                            ValueListenableBuilder<String?>(
                              valueListenable: userNameNotifier,
                              builder: (context, name, _) {
                                final displayName =
                                    (name != null && name.isNotEmpty)
                                        ? name
                                        : l10n.profileAddName;
                                final hasName = name != null && name.isNotEmpty;

                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontFamily:
                                              AppTextStyles.bodyFont(context),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: hasName
                                              ? colors.textPrimary
                                              : colors.textDisabled,
                                        ),
                                      ),
                                    ),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: _startEditing,
                                      child: Icon(
                                        CupertinoIcons.pencil,
                                        size: 20,
                                        color: colors.ctaPrimary,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ] else ...[
                            CupertinoTextField(
                              controller: controller,
                              placeholder: l10n.profileEnterName,
                              autofocus: true,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                              placeholderStyle: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 17,
                                color: colors.textDisabled,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceLightest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.borderWarm,
                                  width: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CupertinoButton(
                                    color: canSave
                                        ? colors.buttonDark
                                        : colors.borderMedium,
                                    borderRadius: BorderRadius.circular(12),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    onPressed: canSave ? _saveName : null,
                                    child: Text(
                                      l10n.commonSave,
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: canSave
                                            ? colors.surfaceLightest
                                            : colors.textDisabled,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  onPressed: _cancelEditing,
                                  child: Text(
                                    l10n.commonCancel,
                                    style: TextStyle(
                                      fontFamily:
                                          AppTextStyles.bodyFont(context),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: colors.ctaPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Divider
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
                          ),
                          const SizedBox(height: 24),

                          // Section 2: Plan
                          Text(
                            l10n.profilePlan,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: Consumer<UserState>(
                                  builder: (context, userState, child) {
                                    return Text(
                                      userState.hasSubscription
                                          ? l10n.appNameIntendedPlus
                                          : userState.hasBoost
                                              ? l10n.appPlanBoost
                                              : l10n.appPlanCore,
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: colors.textPrimary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Consumer<UserState>(
                                builder: (context, userState, child) {
                                  if (userState.hasSubscription) {
                                    // Show "Manage" button for subscribed users
                                    return CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: _showSubscriptionManagement,
                                      child: Text(
                                        l10n.profileManage,
                                        style: TextStyle(
                                          fontFamily:
                                              AppTextStyles.bodyFont(context),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colors.ctaPrimary,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Show "UNLOCK INTENDED+" button for free users
                                    return CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: _showUpgradeScreen,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.accentRegular
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                            color: colors.accentRegular
                                                .withOpacity(0.6),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          l10n.profileUnlockPlus,
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.bodyFont(context),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: colors.ctaPrimary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),

                          if (focusAreas.isNotEmpty) ...[
                            // Divider
                            const SizedBox(height: 24),
                            Container(
                              height: 1,
                              color: colors.ctaPrimary.withOpacity(0.1),
                            ),
                            const SizedBox(height: 24),

                            // Section 3: Focus Areas
                            Text(
                              l10n.profileFocusAreas,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    focusAreas
                                        .map((a) => _localizedAreaName(l10n, a))
                                        .join(', '),
                                    style: TextStyle(
                                      fontFamily:
                                          AppTextStyles.bodyFont(context),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _changeFocusAreas,
                                  child: Icon(
                                    CupertinoIcons.pencil,
                                    size: 20,
                                    color: colors.ctaPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Divider
                          const SizedBox(height: 24),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
                          ),
                          const SizedBox(height: 24),

                          // Section: Your Moments
                          Text(
                            l10n.profileYourMoments,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          FutureBuilder<int>(
                            future: MomentsService.getCount(),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              final label = count == 0
                                  ? l10n.profileMomentsNone
                                  : l10n.profileMomentsCount(count);
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) =>
                                              const MomentsCollectionScreen(),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 20,
                                      color: colors.ctaPrimary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SETTINGS label
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(
                        l10n.profileSettings,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Notifications Card
                    _GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          // Row 1: Daily reminders toggle
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.ctaPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  CupertinoIcons.bell,
                                  size: 18,
                                  color: colors.textMutedBrown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.profileDailyReminders,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.bodyFont(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              CupertinoSwitch(
                                value: _dailyEnabled,
                                activeTrackColor: colors.ctaPrimary,
                                thumbColor: const Color(0xFFFFFFFF),
                                onChanged: (value) async {
                                  final l10n = AppLocalizations.of(context);
                                  if (value) {
                                    final granted = await NotificationScheduler
                                        .requestPermission();
                                    if (granted) {
                                      await NotificationPreferencesService
                                          .setEnabled(true);
                                      await NotificationScheduler.scheduleDaily(
                                          l10n);
                                      AnalyticsService.logDailyReminderToggled(
                                          true);
                                      if (mounted) {
                                        setState(() {
                                          _dailyEnabled = true;
                                          _notifPermissionDenied = false;
                                        });
                                      }
                                    } else {
                                      await NotificationPreferencesService
                                          .setEnabled(false);
                                      if (mounted) {
                                        setState(() {
                                          _notifPermissionDenied = true;
                                        });
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (ctx) =>
                                              CupertinoAlertDialog(
                                            title: Text(
                                                l10n.profileNotifDeniedTitle),
                                            content: Text(
                                                l10n.profileNotifDeniedMessage),
                                            actions: [
                                              CupertinoDialogAction(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text(l10n.commonCancel),
                                              ),
                                              CupertinoDialogAction(
                                                isDefaultAction: true,
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  launchUrl(Uri.parse(
                                                      'app-settings:'));
                                                },
                                                child: Text(l10n
                                                    .profileNotifOpenSettings),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    await NotificationPreferencesService
                                        .setEnabled(false);
                                    await NotificationScheduler.cancelAll();
                                    AnalyticsService.logDailyReminderToggled(
                                        false);
                                    if (mounted) {
                                      setState(() {
                                        _dailyEnabled = false;
                                        _notifPermissionDenied = false;
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),

                          // Time picker row (visible when daily is ON)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            child: _dailyEnabled
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 52),
                                        Expanded(
                                          child: Text(
                                            l10n.profileRemindAt,
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.bodyFont(
                                                      context),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: colors.ctaPrimary,
                                            ),
                                          ),
                                        ),
                                        CupertinoButton(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          onPressed: () {
                                            DateTime tempTime = DateTime(
                                              2024,
                                              1,
                                              1,
                                              _notifHour,
                                              _notifMinute,
                                            );
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder: (ctx) => Container(
                                                height: 280,
                                                color: colors.modalBg1,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        CupertinoButton(
                                                          child: Text(
                                                            l10n.commonDone,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppTextStyles
                                                                      .bodyFont(
                                                                          context),
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: colors
                                                                  .ctaPrimary,
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            Navigator.pop(ctx);
                                                            await NotificationPreferencesService
                                                                .setHour(
                                                                    tempTime
                                                                        .hour);
                                                            await NotificationPreferencesService
                                                                .setMinute(
                                                                    tempTime
                                                                        .minute);
                                                            final enabled =
                                                                await NotificationPreferencesService
                                                                    .isEnabled();
                                                            if (enabled) {
                                                              final l10n =
                                                                  AppLocalizations
                                                                      .of(context);
                                                              await NotificationScheduler
                                                                  .rescheduleAll(
                                                                      l10n);
                                                            }
                                                            AnalyticsService
                                                                .logReminderTimeChanged();
                                                            if (mounted) {
                                                              setState(() {
                                                                _notifHour =
                                                                    tempTime
                                                                        .hour;
                                                                _notifMinute =
                                                                    tempTime
                                                                        .minute;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: CupertinoTheme(
                                                        data:
                                                            CupertinoThemeData(
                                                          textTheme:
                                                              CupertinoTextThemeData(
                                                            dateTimePickerTextStyle:
                                                                TextStyle(
                                                              fontFamily:
                                                                  AppTextStyles
                                                                      .bodyFont(
                                                                          context),
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: colors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        child:
                                                            CupertinoDatePicker(
                                                          mode:
                                                              CupertinoDatePickerMode
                                                                  .time,
                                                          initialDateTime:
                                                              tempTime,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          onDateTimeChanged:
                                                              (dt) {
                                                            tempTime = dt;
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          minimumSize: Size(0, 0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: colors.borderWarm,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              _formatTime(
                                                  _notifHour, _notifMinute),
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.bodyFont(
                                                        context),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              height: 1,
                              color: colors.ctaPrimary.withOpacity(0.1),
                            ),
                          ),

                          // Row 2: Weekly summary toggle
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.ctaPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  CupertinoIcons.calendar,
                                  size: 18,
                                  color: colors.textMutedBrown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.profileWeeklySummary,
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.profileWeeklySubtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily:
                                            AppTextStyles.bodyFont(context),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CupertinoSwitch(
                                value: _weeklyEnabled,
                                activeTrackColor: colors.ctaPrimary,
                                thumbColor: const Color(0xFFFFFFFF),
                                onChanged: (value) async {
                                  final l10n = AppLocalizations.of(context);
                                  if (value) {
                                    final granted = await NotificationScheduler
                                        .requestPermission();
                                    if (granted) {
                                      await NotificationPreferencesService
                                          .setWeeklyEnabled(true);
                                      await NotificationScheduler.rescheduleAll(
                                          l10n);
                                      if (mounted) {
                                        setState(() {
                                          _weeklyEnabled = true;
                                          _notifPermissionDenied = false;
                                        });
                                      }
                                    } else {
                                      await NotificationPreferencesService
                                          .setWeeklyEnabled(false);
                                      if (mounted) {
                                        setState(() {
                                          _notifPermissionDenied = true;
                                        });
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (ctx) =>
                                              CupertinoAlertDialog(
                                            title: Text(
                                                l10n.profileNotifDeniedTitle),
                                            content: Text(
                                                l10n.profileNotifDeniedMessage),
                                            actions: [
                                              CupertinoDialogAction(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text(l10n.commonCancel),
                                              ),
                                              CupertinoDialogAction(
                                                isDefaultAction: true,
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  launchUrl(Uri.parse(
                                                      'app-settings:'));
                                                },
                                                child: Text(l10n
                                                    .profileNotifOpenSettings),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    await NotificationPreferencesService
                                        .setWeeklyEnabled(false);
                                    await NotificationScheduler.rescheduleAll(
                                        l10n);
                                    if (mounted) {
                                      setState(() {
                                        _weeklyEnabled = false;
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),

                          // Permission denied message
                          if (_notifPermissionDenied)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                l10n.profileNotifDenied,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: colors.textTertiary,
                                  height: 1.5,
                                ),
                              ),
                            ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              height: 1,
                              color: colors.ctaPrimary.withOpacity(0.1),
                            ),
                          ),

                          // Row 3: Appearance
                          GestureDetector(
                            onTap: () => _showAppearancePicker(context),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colors.ctaPrimary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.paintbrush,
                                    size: 18,
                                    color: colors.textMutedBrown,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.profileAppearance,
                                        style: TextStyle(
                                          fontFamily:
                                              AppTextStyles.bodyFont(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _localizedThemeName(context.watch<ThemeProvider>().theme, l10n),
                                        style: TextStyle(
                                          fontFamily:
                                              AppTextStyles.bodyFont(context),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 16,
                                  color: colors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // SUPPORT label
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text(
                        l10n.profileSupport,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Support Card (Multi-Item)
                    Container(
                      decoration: BoxDecoration(
                        color: colors.profileCard
                            .withOpacity(colors.profileCardOpacity),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                              : const Color(0xFFFFFFFF).withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.accentRegular.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  CupertinoIcons.question_circle,
                                  size: 20,
                                  color: colors.textMutedBrown,
                                ),
                              ),
                              title: l10n.profileHelpSupport,
                              onTap: _contactSupport,
                            ),
                          ),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.accentRegular.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  CupertinoIcons.arrow_2_circlepath,
                                  size: 20,
                                  color: colors.textMutedBrown,
                                ),
                              ),
                              title: l10n.paywallRestorePurchases,
                              onTap: () async {
                                try {
                                  final result = await context
                                      .read<RevenueCatService>()
                                      .restorePurchases();
                                  if (mounted) {
                                    AppToast.show(
                                        context,
                                        result
                                            ? l10n.restoreSuccess
                                            : l10n.restoreNotFound);
                                  }
                                } catch (_) {
                                  if (mounted) {
                                    AppToast.show(
                                        context, l10n.restoreNotFound);
                                  }
                                }
                              },
                            ),
                          ),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.ctaPrimary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  CupertinoIcons.shield,
                                  size: 20,
                                  color: colors.ctaPrimary,
                                ),
                              ),
                              title: l10n.profilePrivacy,
                              onTap: _openPrivacyPolicy,
                            ),
                          ),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.textSecondary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  CupertinoIcons.doc_text,
                                  size: 20,
                                  color: colors.textSecondary,
                                ),
                              ),
                              title: l10n.profileTerms,
                              onTap: _openTermsOfService,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CONNECT ACCOUNT label
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 4),
                      child: Text(
                        l10n.profileConnectAccount,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Sign-In / Account Card
                    Container(
                      decoration: BoxDecoration(
                        color: colors.profileCard
                            .withOpacity(colors.profileCardOpacity),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                              : const Color(0xFFFFFFFF).withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _currentUser != null
                          // Already signed in — show account info
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        colors.ctaPrimary.withOpacity(0.15),
                                    backgroundImage: _currentUser?.photoURL !=
                                            null
                                        ? NetworkImage(_currentUser!.photoURL!)
                                        : null,
                                    child: _currentUser?.photoURL == null
                                        ? Icon(
                                            CupertinoIcons.person_fill,
                                            size: 20,
                                            color: colors.ctaPrimary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  // Name, email, provider
                                  Expanded(
                                    child: Builder(builder: (context) {
                                      final isApple = _currentUser?.providerData
                                              .any((p) =>
                                                  p.providerId ==
                                                  'apple.com') ??
                                          false;
                                      final isGoogle =
                                          _currentUser?.providerData.any((p) =>
                                                  p.providerId ==
                                                  'google.com') ??
                                              false;
                                      final hasDisplayName =
                                          _currentUser?.displayName != null &&
                                              _currentUser!
                                                  .displayName!.isNotEmpty;
                                      final email = _currentUser?.email;
                                      final isRelayEmail = email != null &&
                                          email.contains(
                                              'privaterelay.appleid.com');
                                      final hasUsableEmail =
                                          email != null && !isRelayEmail;

                                      final providerLabel = isApple
                                          ? l10n.profileSignedInApple
                                          : isGoogle
                                              ? l10n.profileSignedInGoogle
                                              : l10n.profileSignedInApple;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Primary line: displayName, or email
                                          // as fallback
                                          if (hasDisplayName)
                                            Text(
                                              _currentUser!.displayName!,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.bodyFont(
                                                        context),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: colors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          else if (hasUsableEmail)
                                            Text(
                                              email,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.bodyFont(
                                                        context),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: colors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          // Secondary line: email (only when
                                          // displayName is the primary line)
                                          if (hasDisplayName && hasUsableEmail)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Text(
                                                email,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTextStyles.bodyFont(
                                                          context),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: colors.textSecondary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          // Provider label — never just
                                          // "Connected"
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              providerLabel,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.bodyFont(
                                                        context),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: colors.ctaPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  Icon(
                                    CupertinoIcons.checkmark_shield_fill,
                                    size: 20,
                                    color: colors.ctaPrimary,
                                  ),
                                ],
                              ),
                            )
                          // Not signed in — show sign-in buttons
                          : Column(
                              children: [
                                // Google Sign In Button
                                CupertinoButton(
                                  padding: const EdgeInsets.all(16),
                                  onPressed: _isSigningIn
                                      ? null
                                      : () => _signInWithGoogle(context),
                                  child: _isSigningIn
                                      ? const CupertinoActivityIndicator()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/images/google_logo.svg',
                                              width: 22,
                                              height: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              l10n.profileSignInGoogle,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.bodyFont(
                                                        context),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                Container(
                                  height: 1,
                                  color: colors.ctaPrimary.withOpacity(0.1),
                                ),
                                // Apple Sign In Button
                                CupertinoButton(
                                  padding: const EdgeInsets.all(16),
                                  onPressed: _isSigningIn
                                      ? null
                                      : () => _signInWithApple(context),
                                  child: _isSigningIn
                                      ? const CupertinoActivityIndicator()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '\uF8FF',
                                              style: TextStyle(
                                                fontSize: 22,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              l10n.profileSignInApple,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.bodyFont(
                                                        context),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Footer Section
                    Column(
                      children: [
                        // Sign Out Button (only when signed in)
                        if (_currentUser != null)
                          Container(
                            decoration: BoxDecoration(
                              color: colors.profileCard
                                  .withOpacity(colors.profileCardOpacity),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: isDark
                                    ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                                    : const Color(0xFFFFFFFF).withOpacity(0.6),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.textPrimary.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              onPressed: () {
                                showStyledPopup(
                                  context: context,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.signOutWarningTitle,
                                        style: AppTextStyles.h2(context),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.signOutWarningMessage,
                                        style: AppTextStyles.body(context),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),
                                      styledPrimaryButton(
                                        label: l10n.profileSignOut,
                                        color: colors.destructive,
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          final revenueCat =
                                              context.read<RevenueCatService>();
                                          final userState =
                                              context.read<UserState>();
                                          final themeProvider =
                                              context.read<ThemeProvider>();
                                          final nav = Navigator.of(context);

                                          await revenueCat.logOut();
                                          await AuthService.signOut();

                                          await NotificationScheduler
                                              .cancelAll();

                                          // Clear only auth-related prefs, preserve habits/theme/onboarding
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.remove('user_name');

                                          userState.reset();
                                          userNameNotifier.value = null;

                                          // Reset to default theme if current theme requires a paid tier
                                          if (themeProvider.isPremiumTheme(
                                                  themeProvider.theme) ||
                                              themeProvider.isBoostTheme(
                                                  themeProvider.theme)) {
                                            themeProvider
                                                .setTheme(AppTheme.warmClay);
                                          }

                                          nav.pushAndRemoveUntil(
                                            CupertinoPageRoute(
                                              builder: (_) => const MainTabs(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 14),
                                      styledSecondaryButton(
                                        label: l10n.commonCancel,
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.arrow_right_square,
                                    size: 18,
                                    color: colors.textMutedBrown,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.profileSignOut,
                                    style: TextStyle(
                                      fontFamily:
                                          AppTextStyles.bodyFont(context),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textMutedBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Delete Profile Data Link (always visible)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _deleteProfileData,
                          child: Text(
                            l10n.profileDeleteData,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Local data note
                        Text(
                          l10n.profileLocalDataNote,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 11,
                            color: colors.textMutedBrown.withValues(alpha: 0.5),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Version Label
                        Text(
                          l10n.profileVersion,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.textMutedBrown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.profileCard.withOpacity(colors.profileCardOpacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? colors.borderCard.withOpacity(colors.borderCardOpacity)
              : const Color(0xFFFFFFFF).withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final Widget iconContainer;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.iconContainer,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: [
          iconContainer,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 20,
            color: colors.ctaPrimary,
          ),
        ],
      ),
    );
  }
}

// Focus Area Change Screen (preserved from original)
class _FocusAreaChangeScreen extends StatefulWidget {
  const _FocusAreaChangeScreen();

  @override
  State<_FocusAreaChangeScreen> createState() => _FocusAreaChangeScreenState();
}

class _FocusAreaChangeScreenState extends State<_FocusAreaChangeScreen> {
  final List<String> _selectedAreas = [];

  @override
  void initState() {
    super.initState();
    final onboardingState = context.read<OnboardingState>();
    _selectedAreas.addAll(onboardingState.focusAreas);
  }

  int _getMaxAreas() {
    final userState = context.read<UserState>();
    final onboardingState = context.read<OnboardingState>();
    return userState.hasSubscription
        ? 8
        : onboardingState.maxFocusAreas();
  }

  void _toggleArea(String area) {
    final userState = context.read<UserState>();
    HapticFeedback.selectionClick();

    setState(() {
      if (_selectedAreas.contains(area)) {
        _selectedAreas.remove(area);
      } else {
        final maxAreas = _getMaxAreas();
        if (_selectedAreas.length < maxAreas) {
          _selectedAreas.add(area);
          // Paid user nudge: show once when selecting 4th area
          if (userState.hasSubscription && _selectedAreas.length == 4) {
            _showLessIsMoreNudge();
          }
        } else {
          // Free/boost user hit the limit — show upgrade modal
          HapticFeedback.lightImpact();
          _showFreeUserLimitModal();
        }
      }
    });
  }

  void _showFreeUserLimitModal() {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);
    showIntendedModal(
      context: context,
      title: l10n.focusLimitFreeTitle,
      subtitle: l10n.focusLimitFreeMessage,
      actions: [
        // Upgrade button
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
                      colors.ctaPrimary.withOpacity(0.92),
                      colors.ctaSecondary.withOpacity(0.88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (context.read<RevenueCatService>().isPremium) return;
                    showCupertinoModalPopup(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.5),
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      builder: (_) =>
                          const PaywallScreen(source: 'focus_area_limit'),
                    );
                  },
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(20),
                  child: Text(
                    l10n.focusLimitFreeUpgrade,
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
        const SizedBox(height: 12),
        // Dismiss button
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            onPressed: () => Navigator.pop(context),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.commonDismiss,
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
    );
  }

  Future<void> _showLessIsMoreNudge() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('focus_nudge_shown') == true) return;

    if (!mounted) return;
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    await prefs.setBool('focus_nudge_shown', true);

    if (!mounted) return;
    showIntendedModal(
      context: context,
      title: l10n.focusNudgeTitle,
      subtitle: l10n.focusNudgeMessage,
      actions: [
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
                      colors.ctaPrimary.withOpacity(0.92),
                      colors.ctaSecondary.withOpacity(0.88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(20),
                  child: Text(
                    l10n.focusNudgeGotIt,
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
    );
  }

  Future<void> _saveAreas() async {
    if (_selectedAreas.isEmpty) return;

    final onboardingState = context.read<OnboardingState>();

    await onboardingState.changeFocusAreas(_selectedAreas);
    AnalyticsService.logFocusAreasChanged(_selectedAreas);
    AnalyticsService.setFocusAreaCount(_selectedAreas.length);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildBackgroundOrbs(Size size, AppColorScheme colors) {
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
                    colors.surfaceLightest.withOpacity(0.6),
                    colors.borderMedium.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final maxAreas = _getMaxAreas();
    final selectedCount = _selectedAreas.length;
    final canSave = _selectedAreas.isNotEmpty;
    final size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient background (same as onboarding)
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
                Column(
                  children: [
                    // Header with back button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 28, 0),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            onPressed: () => Navigator.pop(context),
                            child: Icon(
                              CupertinoIcons.chevron_left,
                              size: 22,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Title + subtitle
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profileChangeFocusAreasScreenTitle,
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
                            l10n.focusAreasChooseCount(selectedCount, maxAreas),
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.ctaSecondary,
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
                          children: FocusAreasScreen.areas.map((area) {
                            final selected = _selectedAreas.contains(area);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: FocusAreaCard(
                                label: FocusAreasScreen.localizedAreaName(
                                    l10n, area),
                                subtitle: FocusAreasScreen.localizedAreaSubtitle(
                                    l10n, area),
                                icon: FocusAreasScreen.areaIcons[area]!,
                                selected: selected,
                                onTap: () => _toggleArea(area),
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

                // Save button
                if (canSave)
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
                          onPressed: _saveAreas,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(20),
                          child: Text(
                            l10n.profileSaveChanges,
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
}
