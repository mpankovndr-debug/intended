import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/theme/app_colors.dart';
import 'package:intended/widgets/moment_grid.dart';

Moment _at(String iso, {String? category}) {
  final t = DateTime.parse(iso);
  return Moment.create(habitName: 'x', category: category, at: t);
}

void main() {
  group('returns are detected, absences are not represented', () {
    test('a single missed day is not a gap', () {
      // Lally: missing one opportunity does not materially affect habit
      // formation. Treating it as a break would rebuild streak logic.
      final moments = [
        _at('2026-08-01T09:00:00'),
        _at('2026-08-03T09:00:00'), // one quiet day between
      ];
      expect(MomentGrid.returnIndicesFor(moments), isEmpty);
    });

    test('two or more quiet days marks the next moment as a return', () {
      final moments = [
        _at('2026-08-01T09:00:00'),
        _at('2026-08-05T09:00:00'), // three quiet days
        _at('2026-08-06T09:00:00'),
      ];
      expect(MomentGrid.returnIndicesFor(moments), {1});
    });

    test('several moments on one day never count as a gap', () {
      final moments = [
        _at('2026-08-01T08:00:00'),
        _at('2026-08-01T21:00:00'),
      ];
      expect(MomentGrid.returnIndicesFor(moments), isEmpty);
    });

    test('the first moment is never a return', () {
      expect(MomentGrid.returnIndicesFor([_at('2026-08-01T09:00:00')]), isEmpty);
    });
  });

  group('one row of the grid', () {
    test('holds eight tiles on a 393pt phone and seven on a 375pt one', () {
      // What the Progress card leaves the grid on those two: 303pt and 285pt.
      expect(MomentGrid.tilesPerRow(303, atMost: 8), 8);
      expect(MomentGrid.tilesPerRow(285, atMost: 8), 7);
    });

    test('an exact fit fits, and a hair less does not', () {
      // Eight 30pt tiles and the seven 8pt gaps between them: 296.
      expect(MomentGrid.tilesPerRow(296, atMost: 99), 8);
      expect(MomentGrid.tilesPerRow(295.9, atMost: 99), 7);
    });

    test('is capped, and a width with no bound holds the cap', () {
      expect(MomentGrid.tilesPerRow(1000, atMost: 8), 8);
      expect(MomentGrid.tilesPerRow(double.infinity, atMost: 8), 8);
      expect(MomentGrid.tilesPerRow(10, atMost: 8), 0);
    });

    testWidgets('and is the row the grid itself lays out', (tester) async {
      final moments = [
        for (var day = 1; day <= 12; day++)
          _at('2026-08-${day.toString().padLeft(2, '0')}T09:00:00'),
      ];
      for (final width in [232.0, 285.0, 296.0, 303.0, 327.0]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: MomentGrid(
                  moments: moments,
                  theme: AppTheme.values.first,
                  showGhost: false,
                ),
              ),
            ),
          ),
        );
        final tops = [
          for (final tile in tester
              .renderObjectList<RenderBox>(find.byType(GestureDetector)))
            tile.localToGlobal(Offset.zero).dy,
        ];
        expect(tops, hasLength(moments.length));
        expect(
          tops.where((y) => y == tops.first).length,
          MomentGrid.tilesPerRow(width, atMost: moments.length),
          reason: 'in ${width}pt',
        );
      }
    });
  });
}
