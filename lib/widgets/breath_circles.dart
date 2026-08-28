import 'package:flutter/widgets.dart';

import '../models/pause_check_in.dart';

/// The month's pauses as a row of 30px circles — the moment grid's scale,
/// in the pause's own ink. How much of the circle is filled is how much the
/// minute still weighed afterwards:
///
///   solid            = still tense — a body full of colour is carrying
///                      something;
///   ring, small hole = a little calmer;
///   ring, open       = it lifted — only the outline of it is left.
///
/// A skipped answer takes the middle, not a fourth mark: "you didn't say"
/// is not a fourth kind of feeling and should not look like one — the same
/// rule the grid applies to unrated moments.
///
/// The rings are records, never placeholders: each one is a pause that
/// happened, carrying its answer, so the no-outlines rule (§4.2 — empty
/// slots read as "look how much you haven't done") does not apply to them.
class BreathCircles extends StatelessWidget {
  const BreathCircles({
    super.key,
    required this.checkIns,
    required this.ink,
  });

  final List<PauseCheckIn> checkIns;
  final Color ink;

  static const double circleSize = 30;

  /// Stroke width as a fraction of the diameter; null means filled. Pure and
  /// public so the mapping — the whole meaning of the row — is pinned by a
  /// test, not implied by a painter.
  static double? strokeFraction(PauseState? state) => switch (state) {
        PauseState.tense => null,
        PauseState.calm => 1 / 6,
        _ => 1 / 3,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in checkIns)
          CustomPaint(
            size: const Size.square(circleSize),
            painter: _BreathCirclePainter(
              stroke: strokeFraction(c.state),
              ink: ink,
            ),
          ),
      ],
    );
  }
}

/// The 10px legend-dot version of a breath mark, so the pills teach the
/// row's encoding by wearing it.
class BreathDot extends StatelessWidget {
  const BreathDot({super.key, required this.state, required this.ink});

  final PauseState state;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(10),
      painter: _BreathCirclePainter(
        stroke: BreathCircles.strokeFraction(state),
        ink: ink,
      ),
    );
  }
}

class _BreathCirclePainter extends CustomPainter {
  const _BreathCirclePainter({required this.stroke, required this.ink});

  /// Null = filled disc.
  final double? stroke;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    // The grid tiles carry a slight lift toward the top-left; the circles
    // are made of the same light.
    final hsl = HSLColor.fromColor(ink);
    final lit =
        hsl.withLightness((hsl.lightness + 0.06).clamp(0.0, 1.0)).toColor();
    final shade =
        hsl.withLightness((hsl.lightness - 0.045).clamp(0.0, 1.0)).toColor();
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lit, ink, shade],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect)
      ..isAntiAlias = true;

    final center = size.center(Offset.zero);
    final s = stroke;
    if (s == null) {
      canvas.drawCircle(center, size.width / 2, paint);
    } else {
      final width = size.width * s;
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
      canvas.drawCircle(center, (size.width - width) / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_BreathCirclePainter old) =>
      old.stroke != stroke || old.ink != ink;
}
