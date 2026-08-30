import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/gratitude_cadence.dart';
import '../services/gratitude_preferences_service.dart';
import '../services/notification_scheduler.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import 'gratitude_page_screen.dart';

/// First-run setup for the page: how often it asks, and at what time.
///
/// Shown once, the first time the door is opened — not in main onboarding,
/// which exists to choose an intention and should not grow a second job.
/// Afterwards it lives in Profile with the other notification settings.
///
/// The cadence sets *when the reminder fires* and nothing else. Nowhere does
/// the app count pages against it: the moment "you chose daily" can be put
/// beside "you wrote four times", the chooser has become a streak.
class GratitudeCadenceScreen extends StatefulWidget {
  const GratitudeCadenceScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const GratitudeCadenceScreen(),
      );

  @override
  State<GratitudeCadenceScreen> createState() => _GratitudeCadenceScreenState();
}

class _GratitudeCadenceScreenState extends State<GratitudeCadenceScreen> {
  GratitudeCadence _cadence = GratitudeCadence.daily;
  int _hour = GratitudePreferencesService.defaultHour;
  int _minute = GratitudePreferencesService.defaultMinute;

  Future<void> _start() async {
    await GratitudePreferencesService.setCadence(_cadence);
    await GratitudePreferencesService.setHour(_hour);
    await GratitudePreferencesService.setMinute(_minute);
    await GratitudePreferencesService.setEnabled(true);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    await NotificationScheduler.scheduleGratitude(l10n);
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.of(context).pushReplacement(GratitudePageScreen.route());
  }

  Future<void> _pickTime(dynamic colors) async {
    var temp = DateTime(2026, 1, 1, _hour, _minute);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.modalBg1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SizedBox(
        height: 280,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: temp,
                  backgroundColor: Colors.transparent,
                  onDateTimeChanged: (dt) => temp = dt,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                height: 48,
                decoration: BoxDecoration(
                  color: colors.buttonDark,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).gratitudeDone,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.buttonText,
                    fontFamily: AppTextStyles.bodyFont(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _hour = temp.hour;
      _minute = temp.minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final displayFont = AppTextStyles.displayFontFor(
        Localizations.localeOf(context).languageCode);

    return Scaffold(
      backgroundColor: colors.modalBg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.modalBg1, colors.modalBg2, colors.modalBg3],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded,
                      size: 24, color: colors.checkmarkFill),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.gratitudeCadenceTitle,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            height: 1.2,
                            color: colors.textPrimary,
                            fontFamily: displayFont,
                          )),
                      const SizedBox(height: 12),
                      Text(l10n.gratitudeCadenceBody,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: colors.textSubtitle,
                            fontFamily: AppTextStyles.bodyFont(context),
                          )),
                      const SizedBox(height: 30),
                      _option(colors, GratitudeCadence.daily,
                          l10n.gratitudeCadenceDaily, l10n.gratitudeCadenceDailySub),
                      const SizedBox(height: 12),
                      _option(colors, GratitudeCadence.fewDays,
                          l10n.gratitudeCadenceFew, l10n.gratitudeCadenceFewSub),
                      const SizedBox(height: 12),
                      _option(colors, GratitudeCadence.weekly,
                          l10n.gratitudeCadenceWeekly,
                          l10n.gratitudeCadenceWeeklySub),
                      const SizedBox(height: 26),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _pickTime(colors),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: colors.cardBackground
                                .withOpacity(colors.cardBackgroundOpacity),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: colors.buttonDark.withOpacity(0.10),
                                width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 20, color: colors.accentRegular),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(l10n.gratitudeRemindAt,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textPrimary,
                                      fontFamily:
                                          AppTextStyles.bodyFont(context),
                                    )),
                              ),
                              Text(
                                '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textLabel,
                                  fontFamily: AppTextStyles.bodyFont(context),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(l10n.gratitudeChangeWhenever,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colors.textTertiary,
                        fontFamily: AppTextStyles.bodyFont(context),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: GestureDetector(
                  onTap: _start,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: colors.buttonDark,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    alignment: Alignment.center,
                    child: Text(l10n.gratitudeStart,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.buttonText,
                          fontFamily: AppTextStyles.bodyFont(context),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(
      dynamic colors, GratitudeCadence value, String title, String subtitle) {
    final selected = _cadence == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _cadence = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected
              ? colors.cardPinned.withOpacity(colors.cardPinnedOpacity)
              : colors.cardBackground.withOpacity(colors.cardBackgroundOpacity),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? colors.accentRegular
                : colors.buttonDark.withOpacity(0.10),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        fontFamily: AppTextStyles.bodyFont(context),
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colors.textSubtitle,
                        fontFamily: AppTextStyles.bodyFont(context),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? colors.checkmarkFill : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: selected
                    ? null
                    : Border.all(color: colors.textDisabled, width: 1.5),
              ),
              child: selected
                  ? Icon(Icons.check_rounded,
                      size: 15, color: colors.buttonText)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
