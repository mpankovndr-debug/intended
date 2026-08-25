import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/models/widget_month_summary.dart';
import 'package:intended/theme/app_colors.dart';

Moment _m(String habit, String? category, DateTime utc, {int offset = 180}) =>
    Moment(
      id: '${habit}_${utc.millisecondsSinceEpoch}',
      habitName: habit,
      habitEmoji: '✦',
      completedAt: utc,
      category: category,
      localHour: (utc.hour + offset ~/ 60) % 24,
      localWeekday: utc.weekday,
      tzOffsetMinutes: offset,
    );

void main() {
  group('legend', () {
    test('ranks by count, breaks ties by name, caps at five', () {
      final moments = [
        for (var i = 0; i < 3; i++)
          _m('a', 'Mood', DateTime.utc(2026, 8, 1 + i, 9)),
        for (var i = 0; i < 3; i++)
          _m('b', 'Health', DateTime.utc(2026, 8, 1 + i, 10)),
        _m('c', 'Finances', DateTime.utc(2026, 8, 2, 11)),
        _m('d', 'Creativity', DateTime.utc(2026, 8, 2, 12)),
        _m('e', 'Home & organization', DateTime.utc(2026, 8, 2, 13)),
        _m('f', 'Relationships', DateTime.utc(2026, 8, 2, 14)),
        _m('g', null, DateTime.utc(2026, 8, 2, 15)),
      ];
      final legend = WidgetMonthSummary.legend(moments);
      expect(legend.length, 5);
      // Health and Mood tie on 3; Health sorts first by name, every time.
      expect(legend[0].category, 'Health');
      expect(legend[0].count, 3);
      expect(legend[1].category, 'Mood');
      expect(legend.map((e) => e.category), isNot(contains(null)));
      expect(legend.last.category, 'Home & organization');
    });

    test('is empty for an empty month', () {
      expect(WidgetMonthSummary.legend(const []), isEmpty);
    });
  });

  group('latestTodayFor', () {
    test('reads the wall clock from the moment, not the device zone', () {
      // 22:30 UTC on Aug 22 is 01:30 on Aug 23 in Moscow (+3).
      final late = _m('Walk', 'Health', DateTime.utc(2026, 8, 22, 22, 30));
      final earlier = _m('Walk', 'Health', DateTime.utc(2026, 8, 23, 5, 10));
      final other = _m('Read', 'Mood', DateTime.utc(2026, 8, 23, 6));
      final when = WidgetMonthSummary.latestTodayFor(
        [late, earlier, other],
        'Walk',
        DateTime(2026, 8, 23),
      );
      expect(when, isNotNull);
      expect(when!.day, 23);
      expect(when.hour, 8); // 05:10 UTC + 3h — the later of the two
      expect(when.minute, 10);
    });

    test('is null when the habit has no moment today', () {
      final yesterday = _m('Walk', 'Health', DateTime.utc(2026, 8, 22, 8));
      expect(
        WidgetMonthSummary.latestTodayFor([yesterday], 'Walk', DateTime(2026, 8, 23)),
        isNull,
      );
    });
  });

  group('art', () {
    test('every theme resolves to its own widget painting, centred', () {
      for (final theme in AppTheme.values) {
        final art = WidgetArt.forTheme(theme)!;
        final key = theme.name.toLowerCase();
        expect(art.square, 'assets/images/widget_sq_$key.jpg',
            reason: '${theme.name} square');
        expect(art.wide, 'assets/images/widget_hor_$key.jpg',
            reason: '${theme.name} wide');
        // Composed for the frame, so no above-centre rescue crop is needed.
        expect(art.squareAlign, Alignment.center, reason: theme.name);
        expect(art.wideAlign, Alignment.center, reason: theme.name);
      }
    });

    test('every painting a theme names is actually on disk', () {
      // The bug this catches has no other symptom: a missing asset throws
      // inside the off-screen render, the service swallows it, and the widget
      // simply keeps its gradient. It shipped once as `clear_sky` against a
      // file named `clearsky`, and again as `.PNG` after the JPEG conversion.
      final missing = <String>[];
      for (final theme in AppTheme.values) {
        final art = WidgetArt.forTheme(theme)!;
        for (final path in [art.square, art.wide]) {
          if (!File(path).existsSync()) missing.add('${theme.name}: $path');
        }
      }
      expect(missing, isEmpty, reason: missing.join('\n'));
    });

    test('no theme is left without art', () {
      for (final theme in AppTheme.values) {
        expect(WidgetArt.forTheme(theme), isNotNull, reason: theme.name);
      }
    });
  });
}
