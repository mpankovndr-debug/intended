import '../l10n/app_localizations.dart';

import 'package:flutter/material.dart';

enum IntentionPathId {
  gentleMornings,
  anchorsForHardDays,
  quietFocus,
  windingDown,
  softerNights,
  lookingUp,
  closerToPeople,
  movingALittle,
  throughAHardSeason,

  /// Legacy escape-hatch path. Retained as an enum value so existing code
  /// that switches over [IntentionPathId] still compiles, but [IntentionPath]
  /// no longer surfaces it in the picker (see [IntentionPath.pickerOptions]).
  yourOwnWay;

  String get key => switch (this) {
        IntentionPathId.gentleMornings => 'gentle_mornings',
        IntentionPathId.anchorsForHardDays => 'anchors_for_hard_days',
        IntentionPathId.quietFocus => 'quiet_focus',
        IntentionPathId.windingDown => 'winding_down',
        IntentionPathId.softerNights => 'softer_nights',
        IntentionPathId.lookingUp => 'looking_up',
        IntentionPathId.closerToPeople => 'closer_to_people',
        IntentionPathId.movingALittle => 'moving_a_little',
        IntentionPathId.throughAHardSeason => 'through_a_hard_season',
        IntentionPathId.yourOwnWay => 'your_own_way',
      };

  static IntentionPathId fromKey(String key) {
    return IntentionPathId.values.firstWhere(
      (e) => e.key == key,
      // Default to gentleMornings — the most universal first-pick. Was
      // yourOwnWay historically; that path is no longer in the picker so
      // a sensible visible default is preferable.
      orElse: () => IntentionPathId.gentleMornings,
    );
  }
}

/// New paths speak in an established path's voice until they earn their own
/// copy: notification pools, warmth lines and bloom messages are keyed by the
/// four original paths, and mapping is honest — the borrowed tone actually
/// fits — where five new pools of filler would not be.
extension IntentionPathVoice on IntentionPathId {
  IntentionPathId get voice => switch (this) {
        IntentionPathId.softerNights => IntentionPathId.windingDown,
        IntentionPathId.lookingUp => IntentionPathId.quietFocus,
        IntentionPathId.closerToPeople => IntentionPathId.anchorsForHardDays,
        IntentionPathId.movingALittle => IntentionPathId.gentleMornings,
        IntentionPathId.throughAHardSeason =>
          IntentionPathId.anchorsForHardDays,
        _ => this,
      };
}

class IntentionPath {
  final IntentionPathId id;
  final String iconAsset;
  final String titleKey;
  final String subtitleKey;
  final List<String> defaultFocusAreas;
  final Color accentColor;

  /// Exact actions this path starts someone with.
  ///
  /// The original four seed from the focus-area pools at random; these paths
  /// promise something specific enough — sleep, less scrolling — that a random
  /// draw from "Health" could hand a sleep-seeker a glass of water. Null means
  /// pool generation, a list means the path knows its own actions.
  final List<String>? starterActions;

  const IntentionPath({
    required this.id,
    required this.iconAsset,
    required this.titleKey,
    required this.subtitleKey,
    required this.defaultFocusAreas,
    required this.accentColor,
    this.starterActions,
  });

  static final List<IntentionPath> _all = [
    IntentionPath(
      id: IntentionPathId.gentleMornings,
      iconAsset: 'assets/icons/path_gentle_mornings.svg',
      titleKey: 'pathGentleMorningsTitle',
      subtitleKey: 'pathGentleMorningsSubtitle',
      defaultFocusAreas: const ['Health', 'Productivity'],
      accentColor: const Color(0xFFE09A4A), // warm amber — sunrise
    ),
    IntentionPath(
      id: IntentionPathId.anchorsForHardDays,
      iconAsset: 'assets/icons/path_anchors_for_hard_days.svg',
      titleKey: 'pathAnchorsForHardDaysTitle',
      subtitleKey: 'pathAnchorsForHardDaysSubtitle',
      defaultFocusAreas: const ['Mood', 'Self-care'],
      accentColor: const Color(0xFF7AA090), // sage teal — stillness
    ),
    IntentionPath(
      id: IntentionPathId.quietFocus,
      iconAsset: 'assets/icons/path_quiet_focus.svg',
      titleKey: 'pathQuietFocusTitle',
      subtitleKey: 'pathQuietFocusSubtitle',
      defaultFocusAreas: const ['Productivity', 'Self-care'],
      accentColor: const Color(0xFF6E8FB5), // muted blue — focused stillness
    ),
    IntentionPath(
      id: IntentionPathId.windingDown,
      iconAsset: 'assets/icons/path_winding_down.svg',
      titleKey: 'pathWindingDownTitle',
      subtitleKey: 'pathWindingDownSubtitle',
      defaultFocusAreas: const ['Health', 'Mood'],
      accentColor: const Color(0xFF9285B5), // dusty lavender — dusk
    ),
    IntentionPath(
      id: IntentionPathId.softerNights,
      iconAsset: 'assets/icons/path_winding_down.svg',
      titleKey: 'pathSofterNightsTitle',
      subtitleKey: 'pathSofterNightsSubtitle',
      defaultFocusAreas: const ['Health', 'Self-care'],
      accentColor: const Color(0xFF5E6FA3), // deep indigo — night sky
      starterActions: const [
        'Screens away 20 minutes before bed',
        'Dim the lights an hour before sleep',
        'Take 5 deep belly breaths',
        'Do absolutely nothing for 30 seconds',
      ],
    ),
    IntentionPath(
      id: IntentionPathId.lookingUp,
      iconAsset: 'assets/icons/path_finding_calm.svg',
      titleKey: 'pathLookingUpTitle',
      subtitleKey: 'pathLookingUpSubtitle',
      defaultFocusAreas: const ['Mood', 'Productivity'],
      accentColor: const Color(0xFF6FA08B), // fresh green — eyes off glass
      starterActions: const [
        'Look away from your screen for 10 seconds',
        'One meal without your phone',
        'Turn off one notification',
        'Step outside for 30 seconds',
      ],
    ),
    IntentionPath(
      id: IntentionPathId.closerToPeople,
      iconAsset: 'assets/icons/path_gratitude_self_love.svg',
      titleKey: 'pathCloserToPeopleTitle',
      subtitleKey: 'pathCloserToPeopleSubtitle',
      defaultFocusAreas: const ['Relationships', 'Mood'],
      accentColor: const Color(0xFFC08A93), // soft rose — warmth
      starterActions: const [
        'Send one message to someone',
        'Ask someone how they are',
        'Think of one person you appreciate',
        'Reach out to someone you miss',
      ],
    ),
    IntentionPath(
      id: IntentionPathId.movingALittle,
      iconAsset: 'assets/icons/path_gentle_mornings.svg',
      titleKey: 'pathMovingALittleTitle',
      subtitleKey: 'pathMovingALittleSubtitle',
      defaultFocusAreas: const ['Health', 'Self-care'],
      accentColor: const Color(0xFFC98F6B), // warm clay — body in motion
      starterActions: const [
        'Stretch for 10 seconds',
        'Stand up and roll your shoulders',
        'Walk to the window and back',
        '10 minutes of gentle movement',
      ],
    ),
    IntentionPath(
      id: IntentionPathId.throughAHardSeason,
      iconAsset: 'assets/icons/path_finding_calm.svg',
      titleKey: 'pathThroughAHardSeasonTitle',
      subtitleKey: 'pathThroughAHardSeasonSubtitle',
      defaultFocusAreas: const ['Self-care', 'Mood'],
      accentColor: const Color(0xFF8A7295), // muted plum — shelter
      starterActions: const [
        'Drink water slowly',
        'Rest for 2 minutes',
        'Place hand on heart for a moment',
        'Give yourself permission to rest',
      ],
    ),
    // Kept for back-compat resolution (e.g. legacy stored prefs values).
    // Not surfaced in [pickerOptions].
    IntentionPath(
      id: IntentionPathId.yourOwnWay,
      iconAsset: 'assets/icons/path_your_own_way.svg',
      titleKey: 'pathYourOwnWayTitle',
      subtitleKey: 'pathYourOwnWaySubtitle',
      defaultFocusAreas: const [],
      accentColor: const Color(0xFFB8A080), // warm stone — open path
    ),
  ];

  /// All paths, including legacy ones kept only for back-compat resolution.
  /// Prefer [pickerOptions] when rendering a selection UI.
  static List<IntentionPath> get all => _all;

  /// Paths to surface in the onboarding picker and the change-path screen.
  /// Excludes [IntentionPathId.yourOwnWay] — it remains a valid enum value
  /// for legacy data, but new users no longer pick it.
  static List<IntentionPath> get pickerOptions =>
      _all.where((p) => p.id != IntentionPathId.yourOwnWay).toList();

  static IntentionPath getById(IntentionPathId id) {
    return _all.firstWhere((p) => p.id == id);
  }

  /// The user's intention, phrased as something they're doing — this is what
  /// heads the Today screen (§4.1).
  ///
  /// Deliberately not the path's own title: "Anchors for Hard Days" reads as a
  /// product category, while "Steadier on hard days" reads as an aim someone
  /// holds. §4.1's claim is that seeing your *own* intention creates
  /// attachment, so testing it with a feature name would test a weaker thing
  /// and tell us nothing when it doesn't move.
  static String phraseFor(IntentionPathId id, AppLocalizations l10n) {
    return switch (id) {
      IntentionPathId.gentleMornings => l10n.intentionGentleMornings,
      IntentionPathId.anchorsForHardDays => l10n.intentionAnchorsForHardDays,
      IntentionPathId.quietFocus => l10n.intentionQuietFocus,
      IntentionPathId.windingDown => l10n.intentionWindingDown,
      IntentionPathId.softerNights => l10n.intentionSofterNights,
      IntentionPathId.lookingUp => l10n.intentionLookingUp,
      IntentionPathId.closerToPeople => l10n.intentionCloserToPeople,
      IntentionPathId.movingALittle => l10n.intentionMovingALittle,
      IntentionPathId.throughAHardSeason => l10n.intentionThroughAHardSeason,
      IntentionPathId.yourOwnWay => l10n.intentionYourOwnWay,
    };
  }
}
