import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gratitude_entry.dart';
import '../models/gratitude_month.dart';

/// Stores pages under their own key, separate from moments and pauses. The
/// key rides the Firestore prefs backup automatically, so pages restore with
/// everything else.
class GratitudeService {
  GratitudeService._();

  static const String _key = 'gratitude_entries';

  /// Capped like the other collections. At one page a day this holds nearly
  /// three years, against the eight to eleven months the same cap buys the
  /// moments collection at three or four moments a day — which is the whole
  /// reason pages are not moments.
  static const int maxEntries = 1000;

  /// Writes [entry], replacing any page already written on the same local
  /// day. One page per day: reopening tonight's page adds lines to it rather
  /// than starting a second one under the same date.
  ///
  /// An empty page is never stored, and storing an empty one over an existing
  /// page deletes it instead — clearing every line is how you take something
  /// back, and leaving a dated blank behind would misread as a failed night.
  static Future<void> save(GratitudeEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((e) => e.localDay == entry.localDay);
    if (!entry.isEmpty) all.add(entry);
    // Re-established by sorting rather than assumed from insertion: a restore
    // can arrive out of order, and Dart's sort is not stable, so the id
    // breaks ties. Without this the cap trim below could drop a *recent* page
    // off a mis-ordered tail.
    all.sort((a, b) {
      final byTime = b.completedAt.compareTo(a.completedAt);
      return byTime != 0 ? byTime : b.id.compareTo(a.id);
    });
    if (all.length > maxEntries) {
      all.removeRange(maxEntries, all.length);
    }
    await prefs.setString(
      _key,
      jsonEncode([for (final e in all) e.toJson()]),
    );
  }

  /// All pages, newest first.
  static Future<List<GratitudeEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return [
        for (final e in decoded)
          if (e is Map<String, dynamic>) GratitudeEntry.fromJson(e),
      ];
    } catch (_) {
      // Malformed or from an older shape — an unreadable store must not take
      // the screen down with it.
      return [];
    }
  }

  /// The page for [day] (default: today, on the device's current clock), or
  /// null when nothing has been written.
  static Future<GratitudeEntry?> forDay([DateTime? day]) async {
    final local = (day ?? DateTime.now()).toLocal();
    return GratitudeMonth.forDay(await getAll(), local);
  }

  /// Whether a page exists for today. What the scheduler asks before it
  /// leaves tonight's reminder in the queue.
  static Future<bool> writtenToday() async => (await forDay()) != null;

  static Future<int> getCount() async => (await getAll()).length;
}
