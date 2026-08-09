import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/season.dart';
import 'moments_service.dart';

/// Computes and stores one season per month (§4.4, §10).
class SeasonService {
  SeasonService._();

  static const String _key = 'seasons_by_month';

  static String monthKeyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// The current month's season, recomputed on every call.
  ///
  /// The open month is deliberately *not* cached: it is still changing, and a
  /// stale reading would tell someone they are "Steady" while they are mid-way
  /// through a burst. Only closed months are frozen — see [closeIfNeeded].
  static Future<Season> currentSeason() async {
    final now = DateTime.now();
    final moments = await MomentsService.momentsForMonth(now);
    return Season.read(monthKeyFor(now), moments);
  }

  /// Freezes any finished month that has not been stored yet.
  ///
  /// Seasons are immutable once a month closes. A season that changed
  /// retroactively would destroy "this is who I was in September" — and that
  /// permanence is exactly what makes the archive worth paying for (§10).
  /// Call on app open.
  static Future<void> closeIfNeeded() async {
    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1, 1);
    final key = monthKeyFor(previous);

    final stored = await archive();
    if (stored.containsKey(key)) return;

    final moments = await MomentsService.momentsForMonth(previous);
    if (moments.isEmpty) return;

    final season = Season.read(key, moments);
    // A month that never reached the threshold has nothing to say; storing a
    // "beginning" forever would put a permanent shrug in the archive.
    if (season.pole == Season.beginning) return;

    await _write({...stored, key: season});
  }

  /// Closed months, newest first. Paid surface (§4.4) — the free tier gets the
  /// current word only.
  static Future<Map<String, Season>> archive() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, Season.fromJson(v as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> _write(Map<String, Season> seasons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(seasons.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }
}
