import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../main.dart' show styledPrimaryButton;
import '../services/analytics_service.dart';
import '../services/notification_scheduler.dart';
import '../services/return_note_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// The one-time offer to turn on the come-back note, shown on a return day
/// to users whose notification permission is off. Rules in
/// [ReturnNoteOffer], storage in [ReturnNoteService]; this is only the
/// surface.
///
/// Both buttons are final answers. The dismiss is a complete sentence the
/// card respects — there is no "maybe later" that guarantees a re-ask.
class ReturnNoteOfferCard extends StatefulWidget {
  const ReturnNoteOfferCard({super.key, required this.onDone});

  /// Called when the card has been answered and should leave the screen.
  final VoidCallback onDone;

  @override
  State<ReturnNoteOfferCard> createState() => _ReturnNoteOfferCardState();
}

class _ReturnNoteOfferCardState extends State<ReturnNoteOfferCard> {
  @override
  void initState() {
    super.initState();
    // An appearance counts against [ReturnNoteOffer.maxOffers] whether or
    // not it is answered — three ignored returns retire the offer.
    ReturnNoteService.recordOffer();
    AnalyticsService.logReturnNoteOffer('shown');
  }

  Future<void> _accept() async {
    final l10n = AppLocalizations.of(context);
    await ReturnNoteService.markAnswered();
    await ReturnNoteService.setEnabled(true);
    AnalyticsService.logReturnNoteOffer('accepted');

    final granted = await NotificationScheduler.requestPermission();
    if (granted) {
      // The promise is one note after a quiet stretch, nothing more: the
      // daily-reminder system stays exactly as the user left it.
      await NotificationScheduler.scheduleReturnNote(l10n);
    }
    if (!mounted) return;
    if (!granted) {
      // Permission was denied before, so iOS will not re-prompt — the only
      // road is Settings. Same dialog the Profile toggle uses.
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(l10n.profileNotifDeniedTitle),
          content: Text(l10n.profileNotifDeniedMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                launchUrl(Uri.parse('app-settings:'));
              },
              child: Text(l10n.profileNotifOpenSettings),
            ),
          ],
        ),
      );
    }
    if (mounted) widget.onDone();
  }

  Future<void> _dismiss() async {
    await ReturnNoteService.markAnswered();
    AnalyticsService.logReturnNoteOffer('declined');
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final bodyFont = AppTextStyles.bodyFont(context);

    // The stale nudge's panel recipe: ctaPrimary (solved for foreground use
    // in all ten themes) tinting the theme's own card colour — a surface the
    // text sits on, not a wash the landscape reads through.
    final accent = colors.ctaPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            accent.withOpacity(isDark ? 0.20 : 0.15),
            colors.profileCard,
          ).withOpacity(isDark ? 0.95 : 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accent.withOpacity(isDark ? 0.26 : 0.20),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.returnOfferTitle,
              style: TextStyle(
                fontSize: 16.5,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                fontFamily: bodyFont,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.returnOfferBody,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: colors.textSecondary,
                fontFamily: bodyFont,
              ),
            ),
            const SizedBox(height: 16),
            styledPrimaryButton(
              label: l10n.returnOfferAccept,
              onPressed: _accept,
              color: accent,
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10),
              onPressed: _dismiss,
              child: Text(
                l10n.returnOfferDismiss,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                  fontFamily: bodyFont,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
