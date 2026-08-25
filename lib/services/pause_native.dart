import 'package:flutter/services.dart';

/// The single bridge to the native Pause plumbing: Core Haptics for the
/// breathing rhythm, HealthKit writes, and the one-time Watch-pairing probe.
/// The Swift side lives in AppDelegate.swift — deliberately not a separate
/// file, because the Runner group is not filesystem-synchronized and adding
/// files there means editing the fragile project.pbxproj.
///
/// Every call is failure-silent: on Android, in tests, and on hardware
/// without a haptic engine the channel answers false/null and the screen
/// carries on. Haptics and Health are enhancements, never carriers — the
/// breathing rhythm must survive with visuals alone (iPad has no engine).
class PauseNative {
  PauseNative._();

  static const MethodChannel _channel =
      MethodChannel('com.intendedapp.ios/pause');

  /// Starts the haptic engine. False means "no haptics this session" —
  /// unsupported hardware, Android, or an engine that refused to start.
  static Future<bool> prepareHaptics() async {
    try {
      return await _channel.invokeMethod<bool>('prepareHaptics') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Plays one 10-second breath cycle: a soft rise over the inhale, a long
  /// decay over the exhale. Called at the start of each visual cycle so the
  /// two can never drift apart.
  static Future<void> playHapticCycle() async {
    try {
      await _channel.invokeMethod<void>('playHapticCycle');
    } catch (_) {}
  }

  static Future<void> stopHaptics() async {
    try {
      await _channel.invokeMethod<void>('stopHaptics');
    } catch (_) {}
  }

  /// HealthKit exists on this device (false on iPads before iPadOS 17).
  static Future<bool> healthIsAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('healthIsAvailable') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Shows the system write-authorization sheet for mindful sessions (and
  /// State of Mind on iOS 18+). Write-only: no read types are ever requested
  /// in this release.
  static Future<bool> healthRequestWriteAuth() async {
    try {
      return await _channel.invokeMethod<bool>('healthRequestWriteAuth') ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> healthWriteMindful(DateTime start, DateTime end) async {
    try {
      await _channel.invokeMethod<void>('healthWriteMindful', {
        'startMs': start.toUtc().millisecondsSinceEpoch,
        'endMs': end.toUtc().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  /// [stateKey] is a PauseState.key ('tense' | 'neutral' | 'calm'). A silent
  /// no-op below iOS 18, where HKStateOfMind does not exist.
  static Future<void> healthWriteStateOfMind(
      String stateKey, DateTime at) async {
    try {
      await _channel.invokeMethod<void>('healthWriteStateOfMind', {
        'state': stateKey,
        'dateMs': at.toUtc().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  /// Whether an Apple Watch is paired. Null when the question does not apply
  /// (iPad, Android, tests) so callers can keep the denominator honest.
  static Future<bool?> watchIsPaired() async {
    try {
      return await _channel.invokeMethod<bool?>('watchIsPaired');
    } catch (_) {
      return null;
    }
  }
}
