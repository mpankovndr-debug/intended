import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/coach_mark_overlay.dart';

/// Keys for all coach marks in the app.
class CoachMarkKeys {
  static const String firstCompletion = 'coach_mark_first_completion';
  static const String pinning = 'coach_mark_pinning';
  static const String widget = 'coach_mark_widget';
  static const String weeklyReflection = 'coach_mark_weekly_reflection';
  static const String smartNotifications = 'coach_mark_smart_notifications';
  static const String monthlyReflection = 'coach_mark_monthly_reflection';
  static const String reflectionShare = 'coach_mark_reflection_share';
}

class CoachMarkService {
  CoachMarkService._();
  static final CoachMarkService instance = CoachMarkService._();

  final List<_CoachMarkEntry> _pendingQueue = [];
  bool _isShowing = false;
  int _shownThisSession = 0;
  static const int _maxPerSession = 2;

  // ── SharedPreferences helpers ──────────────────────────────────

  Future<bool> hasBeenSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> markAsSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  /// For testing only — resets all coach mark flags.
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      CoachMarkKeys.firstCompletion,
      CoachMarkKeys.pinning,
      CoachMarkKeys.widget,
      CoachMarkKeys.weeklyReflection,
      CoachMarkKeys.smartNotifications,
      CoachMarkKeys.monthlyReflection,
      CoachMarkKeys.reflectionShare,
    ]) {
      await prefs.remove(key);
    }
    _pendingQueue.clear();
    _isShowing = false;
    _shownThisSession = 0;
  }

  // ── Queue management ───────────────────────────────────────────

  /// Enqueues a coach mark if it has not been seen yet.
  /// Call [showNext] after enqueuing to start the display cycle.
  Future<void> enqueue({
    required String key,
    required GlobalKey targetKey,
    required String title,
    required String body,
    Widget? titleIcon,
  }) async {
    if (await hasBeenSeen(key)) return;
    // Avoid duplicate entries in the queue.
    if (_pendingQueue.any((e) => e.key == key)) return;
    _pendingQueue.add(_CoachMarkEntry(
      key: key,
      targetKey: targetKey,
      title: title,
      body: body,
      titleIcon: titleIcon,
    ));
  }

  /// Shows the next queued coach mark if nothing is currently showing
  /// and the per-session cap has not been reached.
  void showNext(BuildContext context) {
    if (_isShowing) return;
    if (_shownThisSession >= _maxPerSession) return;
    if (_pendingQueue.isEmpty) return;

    final entry = _pendingQueue.removeAt(0);
    _isShowing = true;
    _shownThisSession++;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      _isShowing = false;
      return;
    }

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (_) => CoachMarkOverlay(
        targetKey: entry.targetKey,
        title: entry.title,
        body: entry.body,
        titleIcon: entry.titleIcon,
        onDismiss: () async {
          await markAsSeen(entry.key);
          overlayEntry.remove();
          _isShowing = false;
          // Auto-advance to next queued item.
          if (context.mounted) showNext(context);
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _CoachMarkEntry {
  final String key;
  final GlobalKey targetKey;
  final String title;
  final String body;
  final Widget? titleIcon;

  const _CoachMarkEntry({
    required this.key,
    required this.targetKey,
    required this.title,
    required this.body,
    this.titleIcon,
  });
}
