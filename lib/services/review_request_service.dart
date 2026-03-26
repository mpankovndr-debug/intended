import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import 'package:provider/provider.dart';

/// Handles App Store review request logic.
///
/// Trigger: 7th total habit completion OR first all-habits-done day.
/// Retry: once at 25th completion after first dismissal.
/// After 2 dismissals: never ask again.
class ReviewRequestService {
  ReviewRequestService._();

  static const _requestedKey = 'review_requested';
  static const _dismissedCountKey = 'review_dismissed_count';

  /// Call after each habit completion with the new total count and
  /// whether all habits were just completed today.
  static Future<void> checkAndPrompt(
    BuildContext context, {
    required int totalCompletions,
    required bool allDoneToday,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedCount = prefs.getInt(_dismissedCountKey) ?? 0;

    // After 2 dismissals, never ask again.
    if (dismissedCount >= 2) return;

    final alreadyRequested = prefs.getBool(_requestedKey) ?? false;

    bool shouldShow = false;

    if (!alreadyRequested && dismissedCount == 0) {
      // First trigger: 7th completion OR first all-done day
      if (totalCompletions >= 7 || allDoneToday) {
        shouldShow = true;
      }
    } else if (!alreadyRequested && dismissedCount == 1) {
      // Retry trigger: 25th completion (after first dismissal reset the flag)
      if (totalCompletions >= 25) {
        shouldShow = true;
      }
    }

    if (!shouldShow) return;
    if (!context.mounted) return;

    // Don't show during the same session as a paywall interaction.
    final paywallShown = prefs.getBool('paywall_shown_this_session') ?? false;
    if (paywallShown) return;

    await prefs.setBool(_requestedKey, true);

    if (!context.mounted) return;
    _showPrompt(context);
  }

  static void _showPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;

    showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        content: Text(
          l10n.reviewPromptMessage,
          style: AppTextStyles.body(context).copyWith(
            color: colors.textPrimary,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.reviewPromptNotYet),
            onPressed: () => Navigator.of(ctx).pop('not_yet'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(l10n.reviewPromptRate),
            onPressed: () => Navigator.of(ctx).pop('rate'),
          ),
        ],
      ),
    ).then((result) async {
      if (result == 'rate') {
        try {
          final inAppReview = InAppReview.instance;
          if (await inAppReview.isAvailable()) {
            await inAppReview.requestReview();
            debugPrint('[ReviewRequest] Store review dialog shown');
          } else {
            debugPrint('[ReviewRequest] In-app review not available');
          }
        } catch (e) {
          debugPrint('[ReviewRequest] Error requesting review: $e');
        }
      } else {
        // "Not yet" — increment dismissed count, reset requested flag for retry.
        final prefs = await SharedPreferences.getInstance();
        final count = (prefs.getInt(_dismissedCountKey) ?? 0) + 1;
        await prefs.setInt(_dismissedCountKey, count);
        if (count < 2) {
          // Allow retry at 25th completion.
          await prefs.setBool(_requestedKey, false);
        }
        debugPrint('[ReviewRequest] Dismissed ($count/2)');
      }
    });
  }
}
