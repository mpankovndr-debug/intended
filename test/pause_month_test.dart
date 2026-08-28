import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/pause_check_in.dart';
import 'package:intended/models/pause_month.dart';
import 'package:intended/theme/app_colors.dart';
import 'package:intended/theme/pause_ink.dart';
import 'package:intended/widgets/breath_circles.dart';

void main() {
  PauseCheckIn checkIn(DateTime utc, {PauseState? state, int offset = 0}) =>
      PauseCheckIn(
        id: utc.toIso8601String(),
        completedAt: utc,
        state: state,
        entry: 'home',
        localHour: utc.add(Duration(minutes: offset)).hour,
        localWeekday: utc.add(Duration(minutes: offset)).weekday,
        tzOffsetMinutes: offset,
      );

  group('PauseMonth.forMonth', () {
    test('filters by the recorded wall clock, not the UTC month', () {
      // 23:30 UTC on Aug 31 in a +2 zone is Sep 1 on the user's own clock.
      final lateAugustUtc =
          checkIn(DateTime.utc(2026, 8, 31, 23, 30), offset: 120);
      // 01:30 UTC on Sep 1 in a -3 zone is still Aug 31 where the user was.
      final earlySeptemberUtc =
          checkIn(DateTime.utc(2026, 9, 1, 1, 30), offset: -180);
      final august = PauseMonth.forMonth(
        [lateAugustUtc, earlySeptemberUtc],
        DateTime(2026, 8, 1),
      );
      expect(august, [earlySeptemberUtc]);
    });

    test('orders oldest first with a stable tiebreak', () {
      final a = checkIn(DateTime.utc(2026, 8, 3, 9));
      final b = checkIn(DateTime.utc(2026, 8, 1, 9));
      final c = checkIn(DateTime.utc(2026, 8, 20, 9));
      expect(
        PauseMonth.forMonth([a, c, b], DateTime(2026, 8, 15)),
        [b, a, c],
      );
    });
  });

  group('PauseMonth.answerCounts', () {
    test('counts answers and leaves skips uncounted', () {
      final counts = PauseMonth.answerCounts([
        checkIn(DateTime.utc(2026, 8, 1), state: PauseState.calm),
        checkIn(DateTime.utc(2026, 8, 2), state: PauseState.calm),
        checkIn(DateTime.utc(2026, 8, 3), state: PauseState.tense),
        checkIn(DateTime.utc(2026, 8, 4)),
      ]);
      expect(counts[PauseState.calm], 2);
      expect(counts[PauseState.tense], 1);
      expect(counts.containsKey(PauseState.neutral), isFalse);
      expect(counts.values.fold(0, (a, b) => a + b), 3);
    });
  });

  group('BreathCircles.strokeFraction', () {
    test('the fill is the weight: tense solid, calm barely an outline', () {
      expect(BreathCircles.strokeFraction(PauseState.tense), isNull);
      expect(BreathCircles.strokeFraction(PauseState.calm), 1 / 6);
      expect(BreathCircles.strokeFraction(PauseState.neutral), 1 / 3);
      // Skipped takes the middle, not a fourth mark.
      expect(BreathCircles.strokeFraction(null),
          BreathCircles.strokeFraction(PauseState.neutral));
    });
  });

  group('PauseInk', () {
    test('hits its contrast floor against the card on every theme', () {
      for (final theme in AppTheme.values) {
        final ink = PauseInk.of(theme);
        final cardLum =
            PauseInk.relativeLuminance(AppColors.of(theme).cardBackground);
        final inkLum = PauseInk.relativeLuminance(ink);
        final contrast = theme.isDark
            ? (inkLum + 0.05) / (cardLum + 0.05)
            : (cardLum + 0.05) / (inkLum + 0.05);
        expect(contrast, greaterThan(PauseInk.targetContrast - 0.15),
            reason: '$theme ink sank into its card');
        // Direction: ink darker than a light card, lighter than a dark one.
        expect(theme.isDark ? inkLum > cardLum : inkLum < cardLum, isTrue,
            reason: '$theme ink solved to the wrong side of the card');
      }
    });
  });
}
