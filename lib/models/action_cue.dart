import '../l10n/app_localizations.dart';

/// The everyday moments offered as cues (spec §4). Stored by [key], so a cue
/// reads in whichever language the app is in, not the one it was set in.
enum CuePreset {
  coffee('coffee'),
  teeth('teeth'),
  dinner('dinner'),
  bed('bed');

  const CuePreset(this.key);
  final String key;

  static CuePreset? fromKey(String? key) {
    for (final preset in values) {
      if (preset.key == key) return preset;
    }
    return null;
  }
}

/// What an action follows: "After I *pour my coffee*" (spec §4). Either one
/// of the [CuePreset]s or the person's own words, never both.
///
/// Named `cue`, not `anchor`: `keepAnchor` already means "your most-done
/// action" in `month_plan.dart`.
class ActionCue {
  const ActionCue.preset(CuePreset this.preset) : ownWords = null;

  ActionCue.own(String words)
      : preset = null,
        ownWords = words.trim() {
    if (ownWords!.isEmpty) {
      throw ArgumentError.value(words, 'words', 'A cue needs words');
    }
  }

  final CuePreset? preset;
  final String? ownWords;

  /// The words after "After I".
  String label(AppLocalizations l10n) => switch (preset) {
        CuePreset.coffee => l10n.cuePresetCoffee,
        CuePreset.teeth => l10n.cuePresetTeeth,
        CuePreset.dinner => l10n.cuePresetDinner,
        CuePreset.bed => l10n.cuePresetBed,
        null => ownWords!,
      };

  Map<String, dynamic> toJson() =>
      preset != null ? {'preset': preset!.key} : {'own': ownWords};

  /// Null for a record this version cannot read, so one bad entry costs
  /// that cue and nothing else.
  static ActionCue? fromJson(Object? json) {
    if (json is! Map) return null;
    final preset = CuePreset.fromKey(json['preset'] as String?);
    if (preset != null) return ActionCue.preset(preset);
    final own = json['own'];
    if (own is String && own.trim().isNotEmpty) return ActionCue.own(own);
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is ActionCue &&
      other.preset == preset &&
      other.ownWords == ownWords;

  @override
  int get hashCode => Object.hash(preset, ownWords);
}
