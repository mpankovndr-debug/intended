import 'package:flutter/cupertino.dart';

/// A themed collection of existing habits that users can activate as a group.
class CuratedPack {
  final String id;
  final String name;
  final IconData icon;
  final String subtitle;
  final String description;
  final List<String> focusAreas;
  final List<String> habitIds;
  final CuratedPackTier tier;
  final int sortOrder;

  const CuratedPack({
    required this.id,
    required this.name,
    required this.icon,
    required this.subtitle,
    required this.description,
    required this.focusAreas,
    required this.habitIds,
    required this.tier,
    required this.sortOrder,
  });

  bool get isFree => tier == CuratedPackTier.free;
  bool get isPremium => tier == CuratedPackTier.premium;
}

enum CuratedPackTier { free, premium }

/// All curated packs available in the app.
class CuratedPacks {
  CuratedPacks._();

  static const gentleMornings = CuratedPack(
    id: 'gentle_mornings',
    name: 'Gentle Mornings',
    icon: CupertinoIcons.sun_max_fill,
    subtitle:
        "A small morning ritual that doesn't feel like a 5am hustle routine",
    description:
        'Four tiny habits that work as a gentle sequence — hydrate, breathe '
        "fresh air, center yourself, then orient your day. No alarms at dawn "
        'required.',
    focusAreas: ['Health', 'Mood'],
    habitIds: [
      'Drink 3 glasses of water',
      'Step outside for 5 minutes',
      'Take 3 slow breaths',
      'Plan tomorrow in one sentence',
    ],
    tier: CuratedPackTier.free,
    sortOrder: 0,
  );

  static const windingDown = CuratedPack(
    id: 'winding_down',
    name: 'Winding Down',
    icon: CupertinoIcons.moon_fill,
    subtitle: 'An evening decompression set. Intentionally short.',
    description:
        'A small ritual for letting the day go. Stop, reflect, get '
        "comfortable, enjoy one thing. That's the whole evening plan.",
    focusAreas: ['Self-care', 'Mood'],
    habitIds: [
      'Do absolutely nothing for 5 minutes',
      "Name 3 things you're grateful for",
      'Put on something comfortable',
      'Listen to one song you love',
    ],
    tier: CuratedPackTier.premium,
    sortOrder: 1,
  );

  static const tinyResets = CuratedPack(
    id: 'tiny_resets',
    name: 'Tiny Resets',
    icon: CupertinoIcons.arrow_2_circlepath,
    subtitle: 'For mid-week moments when everything feels chaotic',
    description:
        'When overwhelm hits, these four micro-actions create a small pocket '
        'of control. Not a productivity system — a rescue kit.',
    focusAreas: ['Home & organization', 'Health', 'Self-care'],
    habitIds: [
      'Do a 1-minute reset',
      'Tidy one small thing',
      'Take 3 slow breaths',
      'Do one kind thing for yourself',
    ],
    tier: CuratedPackTier.premium,
    sortOrder: 2,
  );

  static const creativeSpark = CuratedPack(
    id: 'creative_spark',
    name: 'Creative Spark',
    icon: CupertinoIcons.paintbrush_fill,
    subtitle: 'Small acts of making. No talent required.',
    description:
        'Three tiny creative habits that get you out of your head and into '
        'your hands. Not about being good — about being playful.',
    focusAreas: ['Creativity'],
    habitIds: [
      'Doodle for 5 minutes',
      "Write down what's in your head",
      'Take one photo of something you like',
    ],
    tier: CuratedPackTier.premium,
    sortOrder: 4,
  );

  static const stayConnected = CuratedPack(
    id: 'stay_connected',
    name: 'Stay Connected',
    icon: CupertinoIcons.heart_fill,
    subtitle: 'The people who matter, one small gesture at a time.',
    description:
        'Four micro-habits for staying close to the people in your life. '
        'Not grand gestures — just showing up.',
    focusAreas: ['Relationships'],
    habitIds: [
      'Send one message to someone you care about',
      'Reach out to someone you miss',
      'Give one genuine compliment',
      'Ask someone how they are',
    ],
    tier: CuratedPackTier.premium,
    sortOrder: 5,
  );

  static const List<CuratedPack> all = [
    gentleMornings,
    windingDown,
    tinyResets,
    creativeSpark,
    stayConnected,
  ];
}
