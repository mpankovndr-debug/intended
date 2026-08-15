import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/widgets/widget_mood_catchup.dart';

final _now = DateTime(2026, 8, 15, 12);

Moment _m({
  required int hoursAgo,
  String? source = 'widget',
  MomentMood? mood,
  String habit = 'Take 3 slow breaths',
}) =>
    Moment.create(
      habitName: habit,
      category: 'Health',
      mood: mood,
      source: source,
      at: _now.subtract(Duration(hours: hoursAgo)),
      id: '$habit-$hoursAgo-$source-${mood?.key}',
    );

void main() {
  group('what the catch-up asks about', () {
    test('a widget completion with no mood is owed a question', () {
      expect(WidgetMoodCatchup.pending([_m(hoursAgo: 3)], now: _now).length, 1);
    });

    test('a tap inside the app is not — that sheet already asked', () {
      // In-app completions get the two-step sheet at the moment they happen.
      // Asking again later would be the same question twice.
      expect(
        WidgetMoodCatchup.pending([_m(hoursAgo: 3, source: null)], now: _now),
        isEmpty,
      );
    });

    test('an answered one is never asked again', () {
      expect(
        WidgetMoodCatchup.pending(
          [_m(hoursAgo: 3, mood: MomentMood.tookEffort)],
          now: _now,
        ),
        isEmpty,
      );
    });

    test('beyond two days it stops asking', () {
      // "How did Tuesday land?" on Friday is a memory test, and a wrong
      // answer is worse than no answer — the ranking reads these as fact.
      expect(WidgetMoodCatchup.pending([_m(hoursAgo: 49)], now: _now), isEmpty);
      expect(
        WidgetMoodCatchup.pending([_m(hoursAgo: 47)], now: _now).length,
        1,
      );
    });

    test('asks oldest first, so the answers follow the days', () {
      final ordered = WidgetMoodCatchup.pending(
        [_m(hoursAgo: 2, habit: 'newest'), _m(hoursAgo: 30, habit: 'oldest')],
        now: _now,
      );

      expect(ordered.first.habitName, 'oldest');
      expect(ordered.last.habitName, 'newest');
    });

    test('never asks about more than three in one sitting', () {
      // Five dialogs in a row on app open is an interrogation, not a
      // catch-up. The rest keep until the next open, inside the window.
      final many = [for (var i = 1; i <= 5; i++) _m(hoursAgo: i)];
      final asked =
          WidgetMoodCatchup.pending(many, now: _now).take(WidgetMoodCatchup.maxPerOpen);

      expect(WidgetMoodCatchup.maxPerOpen, 3);
      expect(asked.length, 3);
    });

    test('a quiet history asks nothing at all', () {
      expect(WidgetMoodCatchup.pending(const [], now: _now), isEmpty);
    });
  });
}
