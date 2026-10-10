import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chapter.dart';

/// Stores the person's chapters (spec §2): at most one open, the rest closed
/// and immutable.
///
/// Nothing is cached. Every read goes to preferences, so a chapter written
/// mid-session is what the next screen sees (CLAUDE.md: static caches must
/// refresh on write). The backup copies every preferences key, so chapters
/// ride along with it; the export in Profile lists them explicitly.
class ChapterService {
  ChapterService._();

  static const String _key = 'chapters';

  /// Every chapter, oldest first. A record that cannot be read is dropped
  /// rather than guessed at.
  static Future<List<Chapter>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Chapter.fromJson)
          .whereType<Chapter>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// The open chapter, or null when there is none.
  static Future<Chapter?> current() async {
    for (final chapter in (await all()).reversed) {
      if (!chapter.isClosed) return chapter;
    }
    return null;
  }

  /// Starts a chapter [now] on the person's clock.
  ///
  /// Throws [StateError] while another chapter is open: a chapter ends with
  /// the person's own answer (§2.3), never as a side effect of starting the
  /// next one.
  static Future<Chapter> start({
    required String sentence,
    required String pathKey,
    DateTime? now,
  }) async {
    final chapters = await all();
    if (chapters.any((c) => !c.isClosed)) {
      throw StateError('A chapter is already open');
    }
    // The one place the device's zone is read: at creation, to record what
    // the person's clock said — the same as a moment records its own offset.
    final local = (now ?? DateTime.now()).toLocal();
    final chapter = Chapter.start(
      id: local.toUtc().toIso8601String(),
      sentence: sentence,
      pathKey: pathKey,
      startedAt: local.toUtc(),
      offsetMinutes: local.timeZoneOffset.inMinutes,
    );
    await _write([...chapters, chapter]);
    return chapter;
  }

  /// Replaces the open chapter's sentence. Throws [StateError] when no
  /// chapter is open.
  static Future<Chapter> updateSentence(String sentence) async {
    return _replaceOpen((open) => open.withSentence(sentence));
  }

  /// Closes the open chapter with the person's [answer] and optional [note].
  /// Throws [StateError] when no chapter is open.
  static Future<Chapter> closeCurrent({
    required ChapterAnswer answer,
    String? note,
    DateTime? now,
  }) async {
    final trimmed = note?.trim();
    return _replaceOpen(
      (open) => open.closedWith(ChapterClose(
        closedAt: (now ?? DateTime.now()).toUtc(),
        answer: answer,
        note: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      )),
    );
  }

  static Future<Chapter> _replaceOpen(Chapter Function(Chapter) change) async {
    final chapters = await all();
    final index = chapters.lastIndexWhere((c) => !c.isClosed);
    if (index < 0) throw StateError('No chapter is open');
    final changed = change(chapters[index]);
    chapters[index] = changed;
    await _write(chapters);
    return changed;
  }

  static Future<void> _write(List<Chapter> chapters) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final c in chapters) c.toJson()]),
    );
  }
}
