import 'dart:convert';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/moment.dart';
import '../models/moment_rollup.dart';

class MomentsService {
  static const String _key = 'moments_collection';
  static const String _rollupKey = 'moments_rollup';
  static const int _maxMoments = 1000;

  /// Records a new moment. Call this every time a habit is completed.
  ///
  /// The rollup is rewritten in the same call so it can never lag behind the
  /// collection it summarises (§10).
  static Future<void> record(Moment moment) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.insert(0, moment); // newest first
    if (all.length > _maxMoments) {
      all.removeRange(_maxMoments, all.length);
    }
    final encoded = jsonEncode(all.map((m) => m.toJson()).toList());
    await prefs.setString(_key, encoded);
    await _writeRollup(prefs, all);
  }

  /// Attaches mood and note to an already-recorded moment — the two-step
  /// completion modal writes the moment first, then the mood tap lands.
  static Future<void> annotate(
    String momentId, {
    MomentMood? mood,
    String? note,
  }) async {
    if (mood == null && note == null) return;
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final index = all.indexWhere((m) => m.id == momentId);
    if (index == -1) return;
    all[index] = all[index].copyWith(mood: mood, note: note);
    await prefs.setString(
      _key,
      jsonEncode(all.map((m) => m.toJson()).toList()),
    );
    await _writeRollup(prefs, all);
  }

  /// Every moment in [anchor]'s calendar month, oldest first. Bucketed by the
  /// offset each moment recorded, not the device's current zone.
  static Future<List<Moment>> momentsForMonth(DateTime anchor) async {
    final all = await getAll();
    final target =
        anchor.add(Duration(minutes: anchor.timeZoneOffset.inMinutes));
    return all.where((m) {
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      return local.year == target.year && local.month == target.month;
    }).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
  }

  /// Categories of every moment in [anchor]'s calendar month, oldest first.
  ///
  /// Drives the tile row in the completion sheet, where the newest entry is
  /// the tile that animates in. Bucketed by the offset each moment recorded,
  /// not the device's current zone.
  static Future<List<String?>> categoriesForMonth(DateTime anchor) async {
    final all = await getAll();
    final target = anchor.add(Duration(minutes: anchor.timeZoneOffset.inMinutes));
    final inMonth = all.where((m) {
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      return local.year == target.year && local.month == target.month;
    }).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return inMonth.map((m) => m.category).toList();
  }

  /// Pre-aggregated counts, gaps and returns. Falls back to computing from
  /// the collection when no rollup has been written yet (existing installs).
  static Future<MomentRollup> getRollup() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_rollupKey);
    if (raw != null) {
      try {
        return MomentRollup.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        // Malformed or from an older shape — rebuild below.
      }
    }
    final all = await getAll();
    final rollup = MomentRollup.from(all);
    await _writeRollup(prefs, all);
    return rollup;
  }

  static Future<void> _writeRollup(
    SharedPreferences prefs,
    List<Moment> all,
  ) async {
    await prefs.setString(
      _rollupKey,
      jsonEncode(MomentRollup.from(all).toJson()),
    );
  }

  /// Returns all moments, newest first.
  static Future<List<Moment>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Moment.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns total number of moments — used on progress page.
  static Future<int> getCount() async {
    final all = await getAll();
    return all.length;
  }

  /// Returns the most recent moment — used on progress page.
  static Future<Moment?> getMostRecent() async {
    final all = await getAll();
    return all.isEmpty ? null : all.first;
  }

  /// Returns moments grouped by month label, e.g. "February 2026".
  static Future<Map<String, List<Moment>>> getGroupedByMonth(AppLocalizations l10n) async {
    final all = await getAll();
    final Map<String, List<Moment>> grouped = {};

    for (final moment in all) {
      final key = _monthLabel(moment.completedAt.toLocal(), l10n);
      grouped.putIfAbsent(key, () => []).add(moment);
    }

    return grouped;
  }

  static String _monthLabel(DateTime date, AppLocalizations l10n) {
    final months = [
      l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch,
      l10n.monthApril, l10n.monthMay, l10n.monthJune,
      l10n.monthJuly, l10n.monthAugust, l10n.monthSeptember,
      l10n.monthOctober, l10n.monthNovember, l10n.monthDecember,
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}