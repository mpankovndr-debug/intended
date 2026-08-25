import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pause_check_in.dart';

/// Stores completed pauses under their own key ('pause_' prefix throughout —
/// the scheduler already uses "check-in" to mean days-active, and one word
/// with two meanings is how data gets misread). The key rides the Firestore
/// prefs backup automatically, so check-ins restore with everything else.
class PauseService {
  static const String _key = 'pause_checkins';
  static const int _maxCheckIns = 1000;

  /// Records one completed pause. Newest first, capped like the moments
  /// collection — the sort is re-established rather than assumed, since
  /// Dart's sort is not stable and a restore can arrive out of order.
  static Future<void> record(PauseCheckIn checkIn) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.insert(0, checkIn);
    all.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    if (all.length > _maxCheckIns) {
      all.removeRange(_maxCheckIns, all.length);
    }
    await prefs.setString(
      _key,
      jsonEncode([for (final c in all) c.toJson()]),
    );
  }

  /// All recorded pauses, newest first.
  static Future<List<PauseCheckIn>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => PauseCheckIn.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<int> getCount() async => (await getAll()).length;
}
