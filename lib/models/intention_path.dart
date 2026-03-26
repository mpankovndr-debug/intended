import 'package:flutter/material.dart';

enum IntentionPathId {
  gentleMornings,
  findingCalm,
  gratitudeSelfLove,
  windingDown,
  yourOwnWay;

  String get key => switch (this) {
        IntentionPathId.gentleMornings => 'gentle_mornings',
        IntentionPathId.findingCalm => 'finding_calm',
        IntentionPathId.gratitudeSelfLove => 'gratitude_self_love',
        IntentionPathId.windingDown => 'winding_down',
        IntentionPathId.yourOwnWay => 'your_own_way',
      };

  static IntentionPathId fromKey(String key) {
    return IntentionPathId.values.firstWhere(
      (e) => e.key == key,
      orElse: () => IntentionPathId.yourOwnWay,
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
      id: IntentionPathId.findingCalm,
      iconAsset: 'assets/icons/path_finding_calm.svg',
      titleKey: 'pathFindingCalmTitle',
      subtitleKey: 'pathFindingCalmSubtitle',
      defaultFocusAreas: const ['Mood', 'Self-care'],
      accentColor: const Color(0xFF7AA090), // sage teal — stillness
    ),
    IntentionPath(
      id: IntentionPathId.gratitudeSelfLove,
      iconAsset: 'assets/icons/path_gratitude_self_love.svg',
      titleKey: 'pathGratitudeSelfLoveTitle',
      subtitleKey: 'pathGratitudeSelfLoveSubtitle',
      defaultFocusAreas: const ['Mood', 'Self-care'],
      accentColor: const Color(0xFFBF7880), // dusty rose — warmth & care
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
      id: IntentionPathId.yourOwnWay,
      iconAsset: 'assets/icons/path_your_own_way.svg',
      titleKey: 'pathYourOwnWayTitle',
      subtitleKey: 'pathYourOwnWaySubtitle',
      defaultFocusAreas: const [],
      accentColor: const Color(0xFFB8A080), // warm stone — open path
    ),
  ];

  static List<IntentionPath> get all => _all;

  static IntentionPath getById(IntentionPathId id) {
    return _all.firstWhere((p) => p.id == id);
  }
}
