import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// Asks the user for an App Store review at peak emotional moments.
///
/// Architecture:
///   • Multiple peak-moment entry points (habit completions, milestones,
///     weekly reflection, curated pack completion). All share one shown-state
///     so the user is never asked more than once per 30 days.
///   • Tapping "Rate" opens the App Store `?action=write-review` page
///     directly. We deliberately do *not* use the native [InAppReview] modal:
///     Apple's guidelines say not to gate `SKStoreReviewController` behind
///     your own prompt, and it silently no-ops once a user is past its
///     3-per-365-days limit (and throughout TestFlight) — which is what made
///     "Rate" appear to do nothing at all.
///   • Two-strike user dismissals → never ask again.
///   • Each trigger ID is recorded so the same moment never asks twice,
///     even if the user later returns to that screen / hits that count again.
///   • Same-session paywall lockout: if a paywall was shown this session,
///     don't pile a review prompt on top. The session flag lives in memory,
///     not [SharedPreferences], so it resets on cold launch.
class ReviewRequestService {
  ReviewRequestService._();

  // ── Storage keys ──────────────────────────────────────────────
  static const _lastAskKey = 'review_last_ask_at_iso';
  static const _dismissedCountKey = 'review_dismissed_count';
  static const _shownTriggersKey = 'review_shown_triggers';

  // ── Limits ────────────────────────────────────────────────────
  static const _cooldown = Duration(days: 30);
  static const _maxDismissals = 2;

  // App Store ID — used by the URL fallback.
  static const _appStoreId = '6759798275';

  // In-memory session flag. Reset every cold launch.
  static bool _paywallShownThisSession = false;

  /// Call from any paywall's initState so the review prompt knows to
  /// stand down for the rest of the session.
  static void markPaywallShown() {
    _paywallShownThisSession = true;
  }

  // ── Public entry points (peak emotional moments) ──────────────

  /// Habit-completion check. Called after each habit is marked done.
  /// Fires on the first all-habits-done day, the 7th total completion,
  /// or when the user crosses the small "5 completions" habit milestone.
  static Future<void> checkAndPrompt(
    BuildContext context, {
    required int totalCompletions,
    required bool allDoneToday,
  }) async {
    if (allDoneToday) {
      await _maybePrompt(context, trigger: 'all_done_today');
      return;
    }
    if (totalCompletions >= 7) {
      await _maybePrompt(context, trigger: 'completions_7');
      return;
    }
    if (totalCompletions == 5) {
      // Original "5 habit completions" milestone — small but real moment.
      await _maybePrompt(context, trigger: 'milestone_habits_5');
    }
  }

  /// Fired when the user views their weekly reflection for the first time
  /// with real (non-zero) data. The reflection card builds organically on
  /// Sundays — this hook ensures we ask in the moment it lands.
  static Future<void> onFirstWeeklyReflection(BuildContext context) async {
    await _maybePrompt(context, trigger: 'first_weekly_reflection');
  }

  /// Fired when every habit in a curated pack has been completed today.
  /// The [packId] dedupes per pack — completing Gentle Mornings twice
  /// won't ask twice, but completing Gentle Mornings then Winding Down
  /// could (subject to the 30-day cooldown).
  static Future<void> onCuratedPackCompleted(
    BuildContext context, {
    required String packId,
  }) async {
    await _maybePrompt(context, trigger: 'curated_pack:$packId');
  }

  // ── Internal: gating + presentation ───────────────────────────

  static Future<void> _maybePrompt(
    BuildContext context, {
    required String trigger,
  }) async {
    // 1. Block review prompts that share a session with a paywall.
    if (_paywallShownThisSession) return;

    final prefs = await SharedPreferences.getInstance();

    // 2. Hard stop after 2 dismissals.
    final dismissed = prefs.getInt(_dismissedCountKey) ?? 0;
    if (dismissed >= _maxDismissals) return;

    // 3. Each trigger fires at most once.
    final shown = prefs.getStringList(_shownTriggersKey) ?? const [];
    if (shown.contains(trigger)) return;

    // 4. 30-day cooldown across all triggers.
    final lastIso = prefs.getString(_lastAskKey);
    if (lastIso != null) {
      final lastAt = DateTime.tryParse(lastIso);
      if (lastAt != null && DateTime.now().difference(lastAt) < _cooldown) {
        return;
      }
    }

    // 5. Async gap — context may have been disposed.
    if (!context.mounted) return;

    // Persist BEFORE prompting so a crash mid-prompt doesn't double-ask.
    await prefs.setString(_lastAskKey, DateTime.now().toIso8601String());
    await prefs.setStringList(_shownTriggersKey, [...shown, trigger]);

    if (!context.mounted) return;
    await _showPrompt(context);
  }

  static Future<void> _showPrompt(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        content: Text(l10n.reviewPromptMessage),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop('not_yet'),
            child: Text(l10n.reviewPromptNotYet),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop('rate'),
            child: Text(l10n.reviewPromptRate),
          ),
        ],
      ),
    );

    if (result == 'rate') {
      await _openReview();
    } else if (result == 'not_yet') {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_dismissedCountKey) ?? 0) + 1;
      await prefs.setInt(_dismissedCountKey, count);
      debugPrint('[ReviewRequest] Dismissed ($count/$_maxDismissals)');
    }
  }

  /// Opens the App Store review page. The user has already tapped "Rate",
  /// so this must always land somewhere visible — see the class doc for why
  /// the native modal is not used here.
  static Future<void> _openReview() async {
    // itms-apps:// hands off to the App Store app directly. The https://
    // universal link is the fallback: it works, but can bounce through Safari
    // depending on how the device resolves the link.
    final candidates = [
      Uri.parse(
        'itms-apps://apps.apple.com/app/id$_appStoreId?action=write-review',
      ),
      Uri.parse(
        'https://apps.apple.com/app/id$_appStoreId?action=write-review',
      ),
    ];

    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          debugPrint('[ReviewRequest] Opened $uri');
          return;
        }
        debugPrint('[ReviewRequest] launchUrl declined $uri');
      } catch (e) {
        debugPrint('[ReviewRequest] Error opening $uri: $e');
      }
    }

    debugPrint('[ReviewRequest] Could not open the App Store review page');
  }
}
