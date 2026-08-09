import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarmthMessageService {
  static const String _indexKey = 'warmth_message_index';

  /// Generic warmth messages (path-agnostic).
  static List<String> _messages(AppLocalizations l10n) => [
    l10n.warmthMsg1,
    l10n.warmthMsg2,
    l10n.warmthMsg4,
    l10n.warmthMsg6,
    l10n.warmthMsg7,
    l10n.warmthMsg8,
    l10n.warmthMsg9,
    l10n.warmthMsg10,
    l10n.warmthMsg11,
    l10n.warmthMsg13,
    l10n.warmthMsg15,
  ];

  /// Path-specific warmth messages (6 per path).
  static List<String> _pathMessages(AppLocalizations l10n, IntentionPathId pathId) {
    return switch (pathId) {
      IntentionPathId.gentleMornings => [
        l10n.warmthPathGentleMornings1,
        l10n.warmthPathGentleMornings2,
        l10n.warmthPathGentleMornings3,
        l10n.warmthPathGentleMornings4,
        l10n.warmthPathGentleMornings5,
        l10n.warmthPathGentleMornings6,
      ],
      IntentionPathId.anchorsForHardDays => [
        l10n.warmthPathAnchorsForHardDays1,
        l10n.warmthPathAnchorsForHardDays2,
        l10n.warmthPathAnchorsForHardDays3,
        l10n.warmthPathAnchorsForHardDays4,
        l10n.warmthPathAnchorsForHardDays5,
        l10n.warmthPathAnchorsForHardDays6,
      ],
      IntentionPathId.quietFocus => [
        l10n.warmthPathQuietFocus1,
        l10n.warmthPathQuietFocus2,
        l10n.warmthPathQuietFocus3,
        l10n.warmthPathQuietFocus4,
        l10n.warmthPathQuietFocus5,
        l10n.warmthPathQuietFocus6,
      ],
      IntentionPathId.windingDown => [
        l10n.warmthPathWindingDown1,
        l10n.warmthPathWindingDown2,
        l10n.warmthPathWindingDown3,
        l10n.warmthPathWindingDown4,
        l10n.warmthPathWindingDown5,
        l10n.warmthPathWindingDown6,
      ],
      IntentionPathId.yourOwnWay => [
        l10n.warmthPathYourOwnWay1,
        l10n.warmthPathYourOwnWay2,
        l10n.warmthPathYourOwnWay3,
        l10n.warmthPathYourOwnWay4,
        l10n.warmthPathYourOwnWay5,
        l10n.warmthPathYourOwnWay6,
      ],
    };
  }

  /// Returns the next message in the rotation, persisted across sessions.
  /// Alternates between path-specific and generic messages.
  static Future<String> getNext(AppLocalizations l10n) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_indexKey) ?? 0;

    // Load user's intention path
    final pathKey = prefs.getString('selected_intention_path') ?? 'gentle_mornings';
    final pathId = IntentionPathId.fromKey(pathKey);

    // Merge: path-specific first, then generic
    final pathMsgs = _pathMessages(l10n, pathId);
    final genericMsgs = _messages(l10n);
    final allMessages = [...pathMsgs, ...genericMsgs];

    final message = allMessages[current % allMessages.length];
    await prefs.setInt(_indexKey, current + 1);
    return message;
  }
}
