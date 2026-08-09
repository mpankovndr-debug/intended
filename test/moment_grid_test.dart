import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/moment.dart';
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
}
