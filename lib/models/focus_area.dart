import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';

/// What the app shows for each focus area beyond its name (which
/// `localizeCategoryName` resolves): an icon and a one-line subtitle. Keyed
/// by the stored English area name, like everything else about areas.
///
/// Lived on the old onboarding focus-areas screen; moved here when that
/// screen was deleted, since Today and Profile still use it.
class FocusArea {
  FocusArea._();

  static const Map<String, IconData> icons = {
    'Health': CupertinoIcons.heart,
    'Mood': CupertinoIcons.smiley,
    'Home & organization': CupertinoIcons.house,
    'Relationships': CupertinoIcons.person_2,
    'Creativity': CupertinoIcons.paintbrush,
    'Self-care': CupertinoIcons.sparkles,
  };

  static String? subtitle(String area, AppLocalizations l10n) =>
      switch (area) {
        'Health' => l10n.focusAreaHealthSub,
        'Mood' => l10n.focusAreaMoodSub,
        'Home & organization' => l10n.focusAreaHomeSub,
        'Relationships' => l10n.focusAreaRelationshipsSub,
        'Creativity' => l10n.focusAreaCreativitySub,
        'Self-care' => l10n.focusAreaSelfCareSub,
        _ => null,
      };
}
