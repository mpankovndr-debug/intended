import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart' show AppBackground, pagePad, styledPrimaryButton;
import '../services/analytics_service.dart';
import '../services/health_service.dart';
import '../services/pause_native.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// Says out loud, in a place anyone can find, that this app writes to Apple
/// Health.
///
/// *Scar:* the only Health surface used to be a soft-ask after a completed
/// pause, on hardware where Health exists. App Review ran 2.1(23) on an iPad
/// Air, never completed a pause, and so met an app carrying HealthKit
/// entitlements with no Health anywhere in its interface — Guideline 2.5.1.
/// A door behind a condition is not identification.
class AppleHealthScreen extends StatefulWidget {
  const AppleHealthScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const AppleHealthScreen());

  @override
  State<AppleHealthScreen> createState() => _AppleHealthScreenState();
}

class _AppleHealthScreenState extends State<AppleHealthScreen> {
  bool? _available;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    PauseNative.healthIsAvailable().then((v) {
      if (mounted) setState(() => _available = v);
    });
    HealthService.hasAnswered().then((v) {
      if (mounted) setState(() => _answered = v);
    });
  }

  Future<void> _connect() async {
    AnalyticsService.logPauseHealthPrompt('accepted_settings');
    // Request first, record second.
    //
    // *Scar:* HealthService already carries this one — marking the question
    // answered before the sheet resolves retires the feature on a tap that
    // decided nothing. Writing it here in the other order would have
    // reproduced it on a second screen.
    await PauseNative.healthRequestWriteAuth();
    await HealthService.markAnswered();
    if (mounted) setState(() => _answered = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.onboardingBg1,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(pagePad(context), 8, pagePad(context), 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.arrow_back_rounded,
                      size: 24, color: colors.checkmarkFill),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(pagePad(context), 24, pagePad(context), 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.healthTitle,
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          fontFamily: AppTextStyles.displayFontFor(
                              Localizations.localeOf(context).languageCode),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.pauseHealthBody,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: colors.textSecondary,
                          fontFamily: AppTextStyles.bodyFont(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_available == false)
                        Text(
                          l10n.healthUnavailable,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: colors.textSecondary,
                            fontFamily: AppTextStyles.bodyFont(context),
                          ),
                        )
                      else if (_available == true)
                        // iOS presents its permission sheet exactly once per
                        // app; every later call returns silently. A button
                        // that still looks tappable after that is a button
                        // that does nothing, so it stands down and says why.
                        _answered
                            ? Text(
                                l10n.healthAnswered,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: colors.textSecondary,
                                  fontFamily: AppTextStyles.bodyFont(context),
                                ),
                              )
                            : styledPrimaryButton(
                                label: l10n.healthConnect,
                                onPressed: _connect,
                              ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.healthManageNote,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: colors.textSubtitle,
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
    );
  }
}
