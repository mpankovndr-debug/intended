import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'theme_selection_screen.dart';
import 'onboarding_state.dart';
import '../services/analytics_service.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

class DailyReminderScreen extends StatefulWidget {
  const DailyReminderScreen({super.key});

  @override
  State<DailyReminderScreen> createState() => _DailyReminderScreenState();
}

class _DailyReminderScreenState extends State<DailyReminderScreen> {
  late TextEditingController _timeController;
  bool _permissionDenied = false;
  bool _weeklyEnabled = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingState>();
    _timeController = TextEditingController(
      text: state.reminderTime ?? '09:00',
    );

    AnalyticsService.logScreenView('daily_reminder');
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.mediumImpact();

    final state = context.read<OnboardingState>();
    AnalyticsService.logOnboardingStepCompleted('daily_reminder');
    AnalyticsService.logDailyReminderToggled(state.dailyReminderEnabled);

    // Navigate to Habit Reveal screen
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ThemeSelectionScreen(),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base gradient background
            Container(
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
            ),

            // Background orbs
            RepaintBoundary(
              child: _buildBackgroundOrbs(size, colors),
            ),

            // Content
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Column with Header + Expanded ScrollView
                  Column(
                    children: [
                      // Header with back button and label
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Label (centered)
                            Center(
                              child: Text(
                                l10n.reminderTitle,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textLabel,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),

                            // Back button (left aligned)
                            Positioned(
                              left: 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFFFFFFFF)
                                              .withOpacity(0.35),
                                          const Color(0xFFFFFFFF)
                                              .withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFFFFFF)
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.textPrimary
                                              .withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => Navigator.pop(context),
                                      child: Icon(
                                        CupertinoIcons.back,
                                        size: 20,
                                        color: colors.ctaPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Consumer<OnboardingState>(
                            builder: (context, state, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  Text(
                                    l10n.reminderSubtitle,
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
                                    l10n.reminderDescription,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: colors.ctaSecondary,
                                    ),
                                  ),

                                  const SizedBox(height: 60),

                                  // Toggle card
                                  _buildToggleCard(state, colors, l10n),

                                  const SizedBox(height: 16),

                                  // Weekly summary toggle
                                  _buildWeeklySummaryCard(state, colors, l10n),

                                  // Helper message when OFF
                                  if (!state.dailyReminderEnabled &&
                                      !_permissionDenied)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 4, bottom: 20),
                                      child: Center(
                                        child: Text(
                                          l10n.reminderSwitchHint,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textTertiary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Permission denied message
                                  if (_permissionDenied)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 4, bottom: 20),
                                      child: Center(
                                        child: Text(
                                          l10n.reminderNoWorries,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textTertiary,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 160),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Gradient overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomInset,
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
                    bottom: 34 + bottomInset,
                    child: Consumer<OnboardingState>(
                      builder: (context, state, _) {
                        final userName = state.name;
                        final hasName = userName != null && userName.isNotEmpty;
                        return Column(
                          children: [
                            // Start button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.textPrimary.withOpacity(0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                                      onPressed: _handleContinue,
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(
                                        hasName
                                            ? l10n.reminderLetsGo(userName)
                                            : l10n.commonStart,
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
                            const SizedBox(height: 16),
                            // Skip button
                            CupertinoButton(
                              padding: const EdgeInsets.all(12),
                              onPressed: _handleContinue,
                              child: Text(
                                l10n.commonSkip,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget _buildBackgroundOrbs(Size size, AppColorScheme colors) {
    return Stack(
      children: [
        // Orb 1 - Top Left
        Positioned(
          top: size.height * 0.05,
          left: size.width * -0.1,
          child: Container(
            width: 288,
            height: 288,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  colors.surfaceLightest.withOpacity(0.65),
                  colors.borderMedium.withOpacity(0.22),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Orb 2 - Bottom Right
        Positioned(
          bottom: size.height * 0.15,
          right: size.width * -0.08,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                radius: 0.9,
                colors: [
                  colors.onboardingBg1.withOpacity(0.6),
                  colors.onboardingBg4.withOpacity(0.2),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 58, sigmaY: 58),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(
      OnboardingState state, AppColorScheme colors, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFFFFF).withOpacity(0.65),
                colors.surfaceLight.withOpacity(0.60),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.4),
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
          child: Column(
            children: [
              // Top section - Toggle
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.reminderDailyToggle,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.reminderAroundTime(_timeController.text),
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.textLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildToggleSwitch(state, colors),
                  ],
                ),
              ),

              // Divider and time picker (when ON)
              if (state.dailyReminderEnabled) ...[
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        colors.borderMedium.withOpacity(0),
                        colors.borderMedium.withOpacity(0.3),
                        colors.borderMedium.withOpacity(0),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        l10n.reminderTimeLabel,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.buttonDark,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 48),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFFFFFF).withOpacity(0.6),
                                  const Color(0xFFFFFFFF).withOpacity(0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.borderMedium.withOpacity(0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.textPrimary.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CupertinoTextField(
                              controller: _timeController,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                              decoration: const BoxDecoration(),
                              onTap: () async {
                                DateTime tempTime =
                                    _parseTime(_timeController.text);

                                await showCupertinoModalPopup(
                                  context: context,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  filter:
                                      ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  builder: (context) => Container(
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(32)),
                                      child: Container(
                                          height: 340,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                colors.modalBg1
                                                    .withOpacity(0.98),
                                                colors.modalBg2
                                                    .withOpacity(0.96),
                                                colors.modalBg3
                                                    .withOpacity(0.98),
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(32)),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              // Handle bar
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 12),
                                                width: 36,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: colors.ctaPrimary
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),

                                              // Header with Done button
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        24, 16, 16, 12),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      l10n.reminderTimePicker,
                                                      style: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            colors.textPrimary,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        HapticFeedback
                                                            .lightImpact();
                                                        setState(() {
                                                          _timeController.text =
                                                              '${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}';
                                                          context
                                                              .read<
                                                                  OnboardingState>()
                                                              .setReminderTime(
                                                                  _timeController
                                                                      .text);
                                                        });
                                                        Navigator.pop(context);
                                                        await NotificationPreferencesService
                                                            .setHour(
                                                                tempTime.hour);
                                                        await NotificationPreferencesService
                                                            .setMinute(tempTime
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
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 24,
                                                                vertical: 12),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                              colors.ctaPrimary
                                                                  .withOpacity(
                                                                      0.92),
                                                              colors
                                                                  .ctaSecondary
                                                                  .withOpacity(
                                                                      0.88),
                                                            ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: colors
                                                                  .textPrimary
                                                                  .withOpacity(
                                                                      0.2),
                                                              blurRadius: 8,
                                                              offset:
                                                                  const Offset(
                                                                      0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          l10n.commonDone,
                                                          style: TextStyle(
                                                            fontFamily: 'Sora',
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Subtle divider
                                              Container(
                                                height: 1,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      colors.ctaPrimary
                                                          .withOpacity(0.0),
                                                      colors.ctaPrimary
                                                          .withOpacity(0.15),
                                                      colors.ctaPrimary
                                                          .withOpacity(0.0),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Time picker with custom styling
                                              Expanded(
                                                child: CupertinoTheme(
                                                  data: CupertinoThemeData(
                                                    textTheme:
                                                        CupertinoTextThemeData(
                                                      dateTimePickerTextStyle:
                                                          TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            colors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  child: CupertinoDatePicker(
                                                    mode:
                                                        CupertinoDatePickerMode
                                                            .time,
                                                    use24hFormat: true,
                                                    initialDateTime: tempTime,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    onDateTimeChanged:
                                                        (DateTime newTime) {
                                                      tempTime = newTime;
                                                    },
                                                  ),
                                                ),
                                              ),

                                              // Bottom safe area padding
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .padding
                                                          .bottom +
                                                      8),
                                            ],
                                          ),
                                        ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard(
      OnboardingState state, AppColorScheme colors, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFFFFF).withOpacity(0.65),
                colors.surfaceLight.withOpacity(0.60),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.4),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reminderWeeklySummary,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.reminderWeeklySubtitle,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    final value = !_weeklyEnabled;

                    if (value) {
                      final granted =
                          await NotificationScheduler.requestPermission();
                      if (!granted) return;
                    }

                    setState(() => _weeklyEnabled = value);
                    await NotificationPreferencesService.setWeeklyEnabled(
                        value);
                    final l10n = AppLocalizations.of(context);
                    if (value) {
                      if (state.dailyReminderEnabled) {
                        await NotificationScheduler.rescheduleAll(l10n);
                      }
                    } else {
                      await NotificationScheduler.rescheduleAll(l10n);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    height: 32,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _weeklyEnabled
                            ? [
                                colors.ctaPrimary.withOpacity(0.9),
                                colors.ctaSecondary.withOpacity(0.85),
                              ]
                            : [
                                colors.onboardingBg3.withOpacity(0.8),
                                colors.onboardingBg3.withOpacity(0.7),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _weeklyEnabled
                            ? colors.ctaPrimary.withOpacity(0.3)
                            : colors.borderMedium.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.textPrimary
                              .withOpacity(_weeklyEnabled ? 0.2 : 0.08),
                          blurRadius: _weeklyEnabled ? 8 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          left: _weeklyEnabled ? 22 : 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
  }

  Widget _buildToggleSwitch(OnboardingState state, AppColorScheme colors) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.selectionClick();
        final enabling = !state.dailyReminderEnabled;

        if (enabling) {
          final granted = await NotificationScheduler.requestPermission();
          if (granted) {
            await NotificationPreferencesService.setEnabled(true);
            final time = _parseTime(_timeController.text);
            await NotificationPreferencesService.setHour(time.hour);
            await NotificationPreferencesService.setMinute(time.minute);
            final l10n = AppLocalizations.of(context);
            await NotificationScheduler.scheduleDaily(l10n);
            if (mounted) {
              setState(() => _permissionDenied = false);
              context.read<OnboardingState>().setDailyReminder(true);
            }
          } else {
            await NotificationPreferencesService.setEnabled(false);
            if (mounted) {
              setState(() => _permissionDenied = true);
            }
          }
        } else {
          await NotificationPreferencesService.setEnabled(false);
          await NotificationScheduler.cancelAll();
          if (mounted) {
            setState(() => _permissionDenied = false);
            context.read<OnboardingState>().setDailyReminder(false);
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: state.dailyReminderEnabled
                ? [
                    colors.ctaPrimary.withOpacity(0.9),
                    colors.ctaSecondary.withOpacity(0.85),
                  ]
                : [
                    colors.onboardingBg3.withOpacity(0.8),
                    colors.onboardingBg3.withOpacity(0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.dailyReminderEnabled
                ? colors.ctaPrimary.withOpacity(0.3)
                : colors.borderMedium.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary
                  .withOpacity(state.dailyReminderEnabled ? 0.2 : 0.08),
              blurRadius: state.dailyReminderEnabled ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: state.dailyReminderEnabled ? 22 : 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
