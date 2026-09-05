import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intended/models/pause_check_in.dart';
import 'package:intended/screens/pause_screen.dart';
import 'package:intended/services/pause_launcher.dart';
import 'package:intended/services/pause_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PauseState', () {
    test('round-trips every stored key', () {
      for (final state in PauseState.values) {
        expect(PauseState.fromKey(state.key), state);
      }
      expect(PauseState.fromKey(null), isNull);
      expect(PauseState.fromKey('gone'), isNull);
    });
  });

  group('PauseCheckIn', () {
    test('create captures the wall clock, not just UTC', () {
      final at = DateTime(2026, 8, 20, 22, 30);
      final checkIn = PauseCheckIn.create(entry: 'home', at: at);
      expect(checkIn.localHour, 22);
      expect(checkIn.localWeekday, DateTime.thursday);
      expect(checkIn.tzOffsetMinutes, at.timeZoneOffset.inMinutes);
      expect(checkIn.completedAt.isUtc, isTrue);
      expect(checkIn.localWallClock.hour, 22);
    });

    test('JSON round-trip preserves everything, including a skipped state',
        () {
      final full = PauseCheckIn.create(
        entry: 'lockscreen',
        state: PauseState.calm,
        at: DateTime(2026, 8, 20, 8, 5),
      );
      final skipped = PauseCheckIn.create(entry: 'widget');

      for (final original in [full, skipped]) {
        final restored = PauseCheckIn.fromJson(original.toJson());
        expect(restored.id, original.id);
        expect(restored.completedAt, original.completedAt);
        expect(restored.state, original.state);
        expect(restored.entry, original.entry);
        expect(restored.localHour, original.localHour);
        expect(restored.localWeekday, original.localWeekday);
        expect(restored.tzOffsetMinutes, original.tzOffsetMinutes);
      }
    });
  });

  group('PauseService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('stores newest first regardless of arrival order', () async {
      final earlier = PauseCheckIn.create(
          entry: 'home', at: DateTime(2026, 8, 19, 9, 0));
      final later = PauseCheckIn.create(
          entry: 'home', at: DateTime(2026, 8, 20, 9, 0));
      await PauseService.record(later);
      await PauseService.record(earlier);

      final all = await PauseService.getAll();
      expect(all.length, 2);
      expect(all.first.completedAt, later.completedAt);
    });
  });

  group('breath curve', () {
    test('rests at both ends and crests exactly when the inhale ends', () {
      expect(PauseScreen.breathScaleAt(0), closeTo(PauseScreen.restScale, 1e-9));
      expect(PauseScreen.breathScaleAt(PauseScreen.inhaleFraction),
          closeTo(1.0, 1e-9));
      expect(PauseScreen.breathScaleAt(1.0),
          closeTo(PauseScreen.restScale, 1e-9));
    });

    test('rises monotonically through the inhale, falls through the exhale',
        () {
      for (var t = 0.0; t < PauseScreen.inhaleFraction - 0.01; t += 0.01) {
        expect(PauseScreen.breathScaleAt(t + 0.01),
            greaterThan(PauseScreen.breathScaleAt(t)));
      }
      for (var t = PauseScreen.inhaleFraction; t < 0.99; t += 0.01) {
        expect(PauseScreen.breathScaleAt(t + 0.01),
            lessThan(PauseScreen.breathScaleAt(t)));
      }
    });
  });

  group('Reduce Motion words', () {
    test('each word holds during its own phase only', () {
      expect(PauseScreen.inWordOpacityAt(0.2), 1.0);
      expect(PauseScreen.outWordOpacityAt(0.2), 0.0);
      expect(PauseScreen.inWordOpacityAt(0.7), 0.0);
      expect(PauseScreen.outWordOpacityAt(0.7), 1.0);
    });

    test('the words never overlap — one voice at a time', () {
      for (var t = 0.0; t <= 1.0; t += 0.005) {
        final both = PauseScreen.inWordOpacityAt(t) > 0 &&
            PauseScreen.outWordOpacityAt(t) > 0;
        expect(both, isFalse, reason: 'overlap at t=$t');
      }
    });

    test('both words are silent at the cycle boundaries', () {
      expect(PauseScreen.inWordOpacityAt(0.0), 0.0);
      expect(PauseScreen.outWordOpacityAt(1.0), 0.0);
    });
  });

  group('PauseLauncher URI contract', () {
    tearDown(() => PauseLauncher.pending.value = null);

    test('lockscreen and home-screen widgets report distinct entries', () {
      PauseLauncher.handleWidgetUri(
          Uri.parse('homeWidget://pause?src=lockscreen'));
      expect(PauseLauncher.pending.value, 'lockscreen');

      PauseLauncher.pending.value = null;
      PauseLauncher.handleWidgetUri(Uri.parse('homeWidget://pause?src=widget'));
      expect(PauseLauncher.pending.value, 'widget');
    });

    test('foreign or absent URIs are ignored', () {
      PauseLauncher.handleWidgetUri(null);
      expect(PauseLauncher.pending.value, isNull);
      PauseLauncher.handleWidgetUri(Uri.parse('homeWidget://something'));
      expect(PauseLauncher.pending.value, isNull);
    });

    // The Swift side is the other half of the contract. home_widget's
    // SwiftHomeWidgetPlugin.isWidgetUrl forwards a launch URL to Dart only
    // when its query carries an item named `homeWidget`; a URL that lacks it
    // opens the app on Home and this launcher never hears about it (the
    // 2.1.1 build shipped exactly that). Read the extension source and pin
    // both halves on every URL it declares.
    test('every widget URL the extension declares reaches the launcher', () {
      final swift = File('ios/IntendedWidget/IntendedPauseWidget.swift')
          .readAsStringSync();
      final urls = RegExp(r'URL\(string: "([^"]+)"\)')
          .allMatches(swift)
          .map((m) => m.group(1)!)
          .toList();
      expect(urls, hasLength(2), reason: 'one home-screen and one lock-screen URL');
      for (final raw in urls) {
        final uri = Uri.parse(raw);
        expect(uri.queryParameters.containsKey('homeWidget'), isTrue,
            reason: '$raw lacks the homeWidget query key the plugin requires');
        PauseLauncher.pending.value = null;
        PauseLauncher.handleWidgetUri(uri);
        expect(PauseLauncher.pending.value,
            uri.queryParameters['src'] == 'lockscreen' ? 'lockscreen' : 'widget',
            reason: raw);
      }
    });
  });
}
