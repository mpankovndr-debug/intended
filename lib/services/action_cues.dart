import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/action_cue.dart';

/// Each action's cue, keyed by the action's title like everything else the
/// app stores about an action (`custom_habits`, `pinned_habit`).
///
/// Backed up with the rest of the preferences by `BackupService`, and part
/// of the export.
class ActionCues {
  ActionCues._();

  static const String key = 'action_cues';

  static Future<Map<String, ActionCue>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(key));
  }

  static Future<void> set(String action, ActionCue cue) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decode(prefs.getString(key))..[action] = cue;
    await _write(prefs, all);
  }

  static Future<void> clear(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decode(prefs.getString(key));
    if (all.remove(action) == null) return;
    await _write(prefs, all);
  }

  /// Carries a cue across a rename. Rewording an action does not change
  /// what it follows; without this the stored title matches nothing and the
  /// cue quietly disappears.
  static Future<void> rename(String from, String to) async {
    if (from == to) return;
    final prefs = await SharedPreferences.getInstance();
    final all = _decode(prefs.getString(key));
    final cue = all.remove(from);
    if (cue == null) return;
    all[to] = cue;
    await _write(prefs, all);
  }

  static Map<String, dynamic> toJson(Map<String, ActionCue> cues) =>
      cues.map((action, cue) => MapEntry(action, cue.toJson()));

  static Map<String, ActionCue> _decode(String? raw) {
    if (raw == null) return {};
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return {};
    }
    if (json is! Map) return {};
    return {
      for (final entry in json.entries)
        if (entry.key is String && ActionCue.fromJson(entry.value) != null)
          entry.key as String: ActionCue.fromJson(entry.value)!,
    };
  }

  static Future<void> _write(
      SharedPreferences prefs, Map<String, ActionCue> all) async {
    if (all.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode(toJson(all)));
    }
  }
}
