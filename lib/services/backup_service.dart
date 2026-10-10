import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService extends ChangeNotifier {
  DateTime? _lastBackupTime;
  bool _isBackingUp = false;
  DateTime? _lastBackupRequest;

  /// The one backup that requests inside the debounce window fold into.
  Timer? _trailing;

  DateTime? get lastBackupTime => _lastBackupTime;
  bool get isBackingUp => _isBackingUp;

  static const _backupTimestampKey = 'last_backup_timestamp';
  static const _minBackupInterval = Duration(seconds: 30);

  // Keys that should NOT be backed up (device-specific or transient)
  static const _excludedKeys = {
    'device_id',
    'first_run',
    'just_completed_onboarding',
    'last_backup_timestamp',
    'flutter.', // Flutter framework internals
  };

  /// Load the last backup timestamp from local prefs on startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString(_backupTimestampKey);
    if (ts != null) {
      _lastBackupTime = DateTime.tryParse(ts);
      notifyListeners();
    }
  }

  /// How long a backup asked for at [now] has to wait, or null to run it
  /// now: the rest of the 30s since [lastRequest], or a full interval while
  /// one is still [busy] past it. [immediately] skips the window, never a
  /// backup in flight.
  @visibleForTesting
  static Duration? deferBy({
    required DateTime? lastRequest,
    required DateTime now,
    required bool busy,
    bool immediately = false,
  }) {
    final since = lastRequest == null ? null : now.difference(lastRequest);
    // A clock set back makes [since] negative. Read that as no recent
    // request: as a wait, it was every backup dropped until the clock
    // caught up again.
    final rest =
        since == null || since.isNegative || since >= _minBackupInterval
            ? null
            : _minBackupInterval - since;
    if (busy) return rest ?? _minBackupInterval;
    return immediately ? null : rest;
  }

  /// Back up all SharedPreferences to Firestore.
  /// Silently no-ops if user is not signed in.
  ///
  /// Debounced: a call within 30s of the last backup is deferred to the end
  /// of that window, folded with every other call inside it. It used to be
  /// dropped, so the cloud copy missed the window's last changes until some
  /// later backup — and a restore before then never brought them back.
  ///
  /// [immediately] skips the window, for the app leaving the foreground and
  /// for "Back up now". A deferred backup's timer doesn't run while iOS has
  /// the app suspended, and is lost if the app is killed.
  Future<void> backup({bool immediately = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final wait = deferBy(
      lastRequest: _lastBackupRequest,
      now: now,
      busy: _isBackingUp,
      immediately: immediately,
    );
    if (wait != null) {
      _trailing ??= Timer(wait, () {
        _trailing = null;
        backup();
      });
      return;
    }
    // This backup reads everything as it is now, so a pending one is moot.
    _trailing?.cancel();
    _trailing = null;
    _lastBackupRequest = now;

    _isBackingUp = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      final data = <String, dynamic>{};
      for (final key in allKeys) {
        if (_shouldExclude(key)) continue;
        data[_sanitizeKey(key)] = prefs.get(key);
      }

      // Store original keys mapping so we can restore sanitized keys
      final keyMap = <String, String>{};
      for (final key in allKeys) {
        if (_shouldExclude(key)) continue;
        final sanitized = _sanitizeKey(key);
        if (sanitized != key) {
          keyMap[sanitized] = key;
        }
      }

      final doc = FirebaseFirestore.instance
          .collection('backups')
          .doc(user.uid);

      await doc.set({
        'data': data,
        'keyMap': keyMap,
        'backupTime': now.toIso8601String(),
        'appVersion': '1.0.1',
      });

      _lastBackupTime = now;
      await prefs.setString(_backupTimestampKey, now.toIso8601String());
      notifyListeners();
    } catch (e) {
      debugPrint('BackupService: backup failed: $e');
    } finally {
      _isBackingUp = false;
      notifyListeners();
    }
  }

  /// Check if a backup exists for the signed-in user.
  Future<BackupInfo?> checkForBackup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('backups')
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      final backupTime = doc.data()?['backupTime'] as String?;
      final data = doc.data()?['data'] as Map<String, dynamic>?;
      if (backupTime == null || data == null) return null;

      final habitCount = data.keys.where((k) => k.startsWith('habit_done_')).length;
      return BackupInfo(
        backupTime: DateTime.tryParse(backupTime) ?? DateTime.now(),
        habitCount: habitCount,
      );
    } catch (e) {
      debugPrint('BackupService: checkForBackup failed: $e');
      return null;
    }
  }

  /// Union of two moments_collection JSON blobs, newest first, local winning
  /// on id conflicts. Both sides may be malformed independently; a side that
  /// fails to parse contributes nothing rather than failing the restore.
  static String _mergeMoments(String? localRaw, String remoteRaw) {
    List<dynamic> parse(String? raw) {
      if (raw == null) return const [];
      try {
        final v = jsonDecode(raw);
        return v is List ? v : const [];
      } catch (_) {
        return const [];
      }
    }

    final byId = <String, dynamic>{};
    for (final m in parse(remoteRaw)) {
      final id = m is Map<String, dynamic> ? m['id'] : null;
      if (id is String) byId[id] = m;
    }
    for (final m in parse(localRaw)) {
      final id = m is Map<String, dynamic> ? m['id'] : null;
      if (id is String) byId[id] = m; // local wins
    }
    final merged = byId.values.toList()
      ..sort((a, b) => ((b['completedAt'] as String?) ?? '')
          .compareTo((a['completedAt'] as String?) ?? ''));
    return jsonEncode(merged);
  }

  /// Union of two string-keyed JSON maps (frozen seasons), local winning —
  /// a season frozen on this device is never replaced by an older reading.
  static String _mergeByKey(String? localRaw, String remoteRaw) {
    Map<String, dynamic> parse(String? raw) {
      if (raw == null) return {};
      try {
        final v = jsonDecode(raw);
        return v is Map<String, dynamic> ? v : {};
      } catch (_) {
        return {};
      }
    }

    return jsonEncode({...parse(remoteRaw), ...parse(localRaw)});
  }

  /// Restore SharedPreferences from a Firestore backup.
  Future<bool> restore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('backups')
          .doc(user.uid)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()?['data'] as Map<String, dynamic>?;
      final keyMap = doc.data()?['keyMap'] as Map<String, dynamic>? ?? {};
      if (data == null) return false;

      final prefs = await SharedPreferences.getInstance();

      // Restore fills what's missing; it never overwrites what exists.
      //
      // The old version blind-set every key, which made signing in *lossy*:
      // a device with 200 local moments joining an account whose backup held
      // an old 20 would wake up with the 20. Now scalar keys only land where
      // the local side has nothing, and the two irreplaceable collections —
      // moments and frozen seasons — are merged as unions, local winning on
      // conflict. Signing in can only ever add.
      for (final entry in data.entries) {
        // Restore original key name if it was sanitized
        final originalKey = keyMap[entry.key] as String? ?? entry.key;
        final value = entry.value;

        try {
          if (originalKey == 'moments_collection' && value is String) {
            await prefs.setString(
              originalKey,
              _mergeMoments(prefs.getString(originalKey), value),
            );
          } else if (originalKey == 'seasons_by_month' && value is String) {
            await prefs.setString(
              originalKey,
              _mergeByKey(prefs.getString(originalKey), value),
            );
          } else if (prefs.containsKey(originalKey)) {
            continue;
          } else if (value is bool) {
            await prefs.setBool(originalKey, value);
          } else if (value is int) {
            await prefs.setInt(originalKey, value);
          } else if (value is double) {
            await prefs.setDouble(originalKey, value);
          } else if (value is String) {
            await prefs.setString(originalKey, value);
          } else if (value is List) {
            await prefs.setStringList(
              originalKey,
              List<String>.from(value.map((e) => e.toString())),
            );
          }
        } catch (e) {
          debugPrint('BackupService: failed to restore key $originalKey: $e');
        }
      }

      // The union this device now holds is richer than either side was;
      // push it up so the next device to sign in gets everything too.
      backup();

      final backupTime = doc.data()?['backupTime'] as String?;
      if (backupTime != null) {
        _lastBackupTime = DateTime.tryParse(backupTime);
        await prefs.setString(_backupTimestampKey, backupTime);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('BackupService: restore failed: $e');
      return false;
    }
  }

  /// Delete backup data from Firestore (for account deletion).
  Future<void> deleteBackup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('backups')
          .doc(user.uid)
          .delete();
    } catch (e) {
      debugPrint('BackupService: deleteBackup failed: $e');
    }
  }

  /// Firestore doesn't allow dots or slashes in field names.
  static String _sanitizeKey(String key) {
    return key.replaceAll('.', '__dot__').replaceAll('/', '__slash__');
  }

  static bool _shouldExclude(String key) {
    for (final excluded in _excludedKeys) {
      if (key == excluded || key.startsWith(excluded)) return true;
    }
    return false;
  }

  @override
  void dispose() {
    _trailing?.cancel();
    super.dispose();
  }
}

class BackupInfo {
  final DateTime backupTime;
  final int habitCount;

  const BackupInfo({required this.backupTime, required this.habitCount});
}
