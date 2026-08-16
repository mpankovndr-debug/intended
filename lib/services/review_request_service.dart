import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Asks for an App Store review at peak moments, through Apple's own sheet.
///
/// Why the native sheet now: [InAppReview.requestReview] lets someone leave a
/// rating without leaving the app — one tap on a star. What this replaces
/// showed a dialog of ours and, on "Rate", opened the write-review page in the
/// App Store. That path costs a tap, an app switch, and then a *written*
/// review, and almost nobody reaches the end of it.
///
/// The scar behind the old design was real: the native sheet silently no-ops
/// throughout TestFlight and once someone is past Apple's 3-per-365-days
/// ceiling, which is what made "Rate" look like it did nothing. Two things
/// settle it. We never gate the sheet behind a prompt of our own, so no button
/// of ours can appear broken; and Profile carries a plain "Rate Intended" row
/// that opens the App Store directly for anyone who goes looking. The sheet is
/// opportunistic, the Profile row is reliable.
///
/// Everything deciding *whether* to ask is a pure static below. A policy that
/// needs a BuildContext can't be tested, and this one went untested for a
/// whole release.
class ReviewRequestService {
  ReviewRequestService._();

  // ── Storage keys ──────────────────────────────────────────────
  static const _lastAskKey = 'review_last_ask_at_iso';
  static const _shownTriggersKey = 'review_shown_triggers';

  /// Written only by the dialog this service no longer shows. Still read, so
  /// that anyone who told the old prompt "Not yet" twice stays opted out —
  /// they made a choice and it should survive the rewrite. Nobody can add to
  /// this count any more.
  static const _legacyDismissedKey = 'review_dismissed_count';
  static const legacyMaxDismissals = 2;

  // ── Limits ────────────────────────────────────────────────────
  /// Ours, on top of Apple's own 3-per-365-days. Apple counts sheets it chose
  /// to render; we count times we asked, which is the number we can act on.
  static const cooldown = Duration(days: 30);

  static const appStoreId = '6759798275';

  // ── Trigger ids. Persisted — never rename. ────────────────────
  static const triggerAllDoneToday = 'all_done_today';
  static const triggerCompletions7 = 'completions_7';
  static const triggerMilestone5 = 'milestone_habits_5';

  /// The month read itself back to you. In v2 this is the peak moment in the
  /// app — a season is a sentence about who you were, and the letter ends in a
  /// question. Every other trigger here is someone ticking a box.
  static const triggerSeasonRead = 'season_read';
  static const triggerLetterRead = 'letter_read';

  // In-memory session flag. Reset every cold launch.
  static bool _paywallShownThisSession = false;

  /// Call from any paywall's initState so the review ask stands down for the
  /// rest of the session. Nobody should be asked to rate an app in the same
  /// sitting they were asked to pay for it.
  static void markPaywallShown() => _paywallShownThisSession = true;

  @visibleForTesting
  static void resetSessionForTest() => _paywallShownThisSession = false;

  // ── Pure policy ───────────────────────────────────────────────

  /// Which trigger a completion earns, or null for none.
  ///
  /// Order matters: finishing the day outranks any count, and the 7th
  /// completion is checked before the 5th, so once someone is past 7 the
  /// smaller milestone can no longer fire behind them.
  @visibleForTesting
  static String? triggerForCompletion({
    required int totalCompletions,
    required bool allDoneToday,
  }) {
    if (allDoneToday) return triggerAllDoneToday;
    if (totalCompletions >= 7) return triggerCompletions7;
    if (totalCompletions == 5) return triggerMilestone5;
    return null;
  }

  /// Which trigger a month page earns, or null.
  ///
  /// The letter outranks the season: it's the longer read and it lands last.
  /// Both are gated on the month having actually resolved — a "Beginning"
  /// season is the app saying it doesn't know you yet, which is the worst
  /// possible moment to ask for five stars.
  @visibleForTesting
  static String? triggerForMonthRead({
    required bool seasonResolved,
    required bool letterShown,
  }) {
    if (letterShown) return triggerLetterRead;
    if (seasonResolved) return triggerSeasonRead;
    return null;
  }

  /// Whether we may ask right now. Pure, so the whole policy is testable.
  @visibleForTesting
  static bool mayAsk({
    required String trigger,
    required bool paywallShownThisSession,
    required List<String> shownTriggers,
    required int legacyDismissedCount,
    required DateTime? lastAskAt,
    required DateTime now,
  }) {
    if (paywallShownThisSession) return false;
    if (legacyDismissedCount >= legacyMaxDismissals) return false;
    if (shownTriggers.contains(trigger)) return false;
    if (lastAskAt != null && now.difference(lastAskAt) < cooldown) return false;
    return true;
  }

  // ── Entry points ──────────────────────────────────────────────

  /// After a habit completion. No BuildContext: the native sheet doesn't need
  /// one, and not taking one is what let the policy above become testable.
  static Future<void> checkAndPrompt({
    required int totalCompletions,
    required bool allDoneToday,
  }) async {
    final trigger = triggerForCompletion(
      totalCompletions: totalCompletions,
      allDoneToday: allDoneToday,
    );
    if (trigger == null) return;
    await _maybeAsk(trigger);
  }

  /// After the month page has loaded and rendered a real reading.
  static Future<void> onMonthRead({
    required bool seasonResolved,
    required bool letterShown,
  }) async {
    final trigger = triggerForMonthRead(
      seasonResolved: seasonResolved,
      letterShown: letterShown,
    );
    if (trigger == null) return;
    await _maybeAsk(trigger);
  }

  static Future<void> _maybeAsk(String trigger) async {
    final prefs = await SharedPreferences.getInstance();
    final allowed = mayAsk(
      trigger: trigger,
      paywallShownThisSession: _paywallShownThisSession,
      shownTriggers: prefs.getStringList(_shownTriggersKey) ?? const [],
      legacyDismissedCount: prefs.getInt(_legacyDismissedKey) ?? 0,
      lastAskAt: DateTime.tryParse(prefs.getString(_lastAskKey) ?? ''),
      now: DateTime.now(),
    );
    if (!allowed) return;

    final review = InAppReview.instance;
    if (!await review.isAvailable()) {
      debugPrint('[ReviewRequest] sheet unavailable, skipping "$trigger"');
      return;
    }

    // Record before asking: a crash mid-sheet must not earn a second ask, and
    // Apple may decline to render without telling us either way.
    final shown = prefs.getStringList(_shownTriggersKey) ?? const [];
    await prefs.setStringList(_shownTriggersKey, [...shown, trigger]);
    await prefs.setString(_lastAskKey, DateTime.now().toIso8601String());

    await review.requestReview();
    debugPrint('[ReviewRequest] requested on "$trigger"');
  }

  /// The reliable path: opens the App Store review page directly. Wired to a
  /// Profile row, so someone who decides to rate is never at the mercy of
  /// whether Apple felt like showing the sheet.
  static Future<void> openStoreListing() async {
    final candidates = [
      Uri.parse(
        'itms-apps://apps.apple.com/app/id$appStoreId?action=write-review',
      ),
      Uri.parse(
        'https://apps.apple.com/app/id$appStoreId?action=write-review',
      ),
    ];

    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
        debugPrint('[ReviewRequest] launchUrl declined $uri');
      } catch (e) {
        debugPrint('[ReviewRequest] error opening $uri: $e');
      }
    }
    debugPrint('[ReviewRequest] could not open the App Store review page');
  }
}
