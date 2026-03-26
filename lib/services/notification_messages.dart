import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';

class NotificationMessages {
  NotificationMessages._();

  /// Generic daily messages (path-agnostic fallback pool).
  static List<String> daily(AppLocalizations l10n) => [
    l10n.notifMsg1,
    l10n.notifMsg2,
    l10n.notifMsg3,
    l10n.notifMsg4,
    l10n.notifMsg6,
    l10n.notifMsg8,
    l10n.notifMsg9,
    l10n.notifMsg10,
    l10n.notifMsg11,
    l10n.notifMsg13,
    l10n.notifMsg14,
    l10n.notifMsg15,
    l10n.notifMsg16,
    l10n.notifMsg17,
    l10n.notifMsg18,
    l10n.notifMsg19,
    l10n.notifMsg20,
    l10n.notifMsg21,
    l10n.notifMsg22,
    l10n.notifMsg23,
    l10n.notifMsg24,
    l10n.notifMsg25,
    l10n.notifMsg26,
    l10n.notifMsg27,
    l10n.notifMsg28,
    l10n.notifMsg29,
    l10n.notifMsg30,
    l10n.notifMsg31,
    l10n.notifMsg32,
    l10n.notifMsg34,
    l10n.notifMsg35,
    l10n.notifMsg37,
    l10n.notifMsg38,
    l10n.notifMsg39,
    l10n.notifMsg41,
    l10n.notifMsg42,
    l10n.notifMsg44,
    l10n.notifMsg45,
    l10n.notifMsg46,
    l10n.notifMsg47,
    l10n.notifMsg48,
    l10n.notifMsg49,
    l10n.notifMsg50,
    l10n.notifMsg51,
    l10n.notifMsg53,
    l10n.notifMsg54,
    l10n.notifMsg55,
    l10n.notifMsg56,
    l10n.notifMsg58,
    l10n.notifMsg60,
  ];

  /// Path-specific notification messages (6 per path).
  /// Mixed with generic pool for variety: path messages appear ~40% of the time.
  static List<String> forPath(AppLocalizations l10n, IntentionPathId pathId) {
    return switch (pathId) {
      IntentionPathId.gentleMornings => [
        l10n.notifPathGentleMornings1,
        l10n.notifPathGentleMornings2,
        l10n.notifPathGentleMornings3,
        l10n.notifPathGentleMornings4,
        l10n.notifPathGentleMornings5,
        l10n.notifPathGentleMornings6,
      ],
      IntentionPathId.findingCalm => [
        l10n.notifPathFindingCalm1,
        l10n.notifPathFindingCalm2,
        l10n.notifPathFindingCalm3,
        l10n.notifPathFindingCalm4,
        l10n.notifPathFindingCalm5,
        l10n.notifPathFindingCalm6,
      ],
      IntentionPathId.gratitudeSelfLove => [
        l10n.notifPathGratitudeSelfLove1,
        l10n.notifPathGratitudeSelfLove2,
        l10n.notifPathGratitudeSelfLove3,
        l10n.notifPathGratitudeSelfLove4,
        l10n.notifPathGratitudeSelfLove5,
        l10n.notifPathGratitudeSelfLove6,
      ],
      IntentionPathId.windingDown => [
        l10n.notifPathWindingDown1,
        l10n.notifPathWindingDown2,
        l10n.notifPathWindingDown3,
        l10n.notifPathWindingDown4,
        l10n.notifPathWindingDown5,
        l10n.notifPathWindingDown6,
      ],
      IntentionPathId.yourOwnWay => [
        l10n.notifPathYourOwnWay1,
        l10n.notifPathYourOwnWay2,
        l10n.notifPathYourOwnWay3,
        l10n.notifPathYourOwnWay4,
        l10n.notifPathYourOwnWay5,
        l10n.notifPathYourOwnWay6,
      ],
    };
  }

  /// Returns a merged pool: path-specific messages first, then generic.
  /// This ensures path messages appear more frequently at the start of rotation.
  static List<String> dailyForPath(AppLocalizations l10n, IntentionPathId pathId) {
    final pathMessages = forPath(l10n, pathId);
    final genericMessages = daily(l10n);
    return [...pathMessages, ...genericMessages];
  }

  /// Path-specific weekly reflection notification message.
  /// Falls back to generic notifWeeklyBody if no path is set.
  static String weeklyForPath(AppLocalizations l10n, IntentionPathId pathId) {
    return switch (pathId) {
      IntentionPathId.gentleMornings => l10n.notifWeeklyPathGentleMornings,
      IntentionPathId.findingCalm => l10n.notifWeeklyPathFindingCalm,
      IntentionPathId.gratitudeSelfLove => l10n.notifWeeklyPathGratitudeSelfLove,
      IntentionPathId.windingDown => l10n.notifWeeklyPathWindingDown,
      IntentionPathId.yourOwnWay => l10n.notifWeeklyPathYourOwnWay,
    };
  }

  /// Adaptive notification messages for re-engagement.
  static String reengageMessage(AppLocalizations l10n) => l10n.adaptiveNotifReengageBody;
  static String silentMessage(AppLocalizations l10n) => l10n.adaptiveNotifSilentBody;
}
