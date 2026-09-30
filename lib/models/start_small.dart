import 'intention_path.dart';

/// What "Start small" offers (spec §6, screen 4): a path's own starter
/// actions first, then its focus areas' catalogue in catalogue order, taken
/// in turn from each area so one area cannot crowd out the other.
///
/// Deterministic on purpose: coming back to the screen shows the same
/// actions, so a choice made there is still on it.
class StartSmall {
  StartSmall._();

  /// How many actions the screen offers.
  static const int offered = 6;

  static List<String> candidates({
    required IntentionPath path,
    required List<String> focusAreas,
    required Map<String, List<String>> catalogue,
    int count = offered,
  }) {
    final out = <String>[];
    void add(String action) {
      if (out.length < count && !out.contains(action)) out.add(action);
    }

    for (final action in path.starterActions ?? const <String>[]) {
      add(action);
    }
    final pools = [
      for (final area in focusAreas) catalogue[area] ?? const <String>[],
    ];
    for (var i = 0; out.length < count && pools.any((p) => i < p.length); i++) {
      for (final pool in pools) {
        if (i < pool.length) add(pool[i]);
      }
    }
    return out;
  }
}
