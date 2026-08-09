import 'package:flutter/material.dart';

enum IntentionPathId {
  gentleMornings,
  anchorsForHardDays,
  quietFocus,
  windingDown,

  /// Legacy escape-hatch path. Retained as an enum value so existing code
  /// that switches over [IntentionPathId] still compiles, but [IntentionPath]
  /// no longer surfaces it in the picker (see [IntentionPath.pickerOptions]).
  yourOwnWay;

  String get key => switch (this) {
        IntentionPathId.gentleMornings => 'gentle_mornings',
        IntentionPathId.anchorsForHardDays => 'anchors_for_hard_days',
        IntentionPathId.quietFocus => 'quiet_focus',
        IntentionPathId.windingDown => 'winding_down',
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

class IntentionPath {
  final IntentionPathId id;
  final String iconAsset;
  final String titleKey;
  final String subtitleKey;
  final List<String> defaultFocusAreas;
  final Color accentColor;

  const IntentionPath({
    required this.id,
    required this.iconAsset,
    required this.titleKey,
    required this.subtitleKey,
    required this.defaultFocusAreas,
    required this.accentColor,
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
}
