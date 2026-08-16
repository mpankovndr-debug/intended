import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A rounded rectangle drawn as a dashed outline, wrapped around [child].
///
/// The example month on Insights needs a boundary that says "this is not
/// yours" before anything is read. Reduced opacity alone did not do it: the
/// card helper it sits inside returns its child untouched, so the sample sat
/// on the bare page with only a small ПРИМЕР / EXAMPLE label to separate it
/// from the real card above — close enough to screenshot by mistake, which is
/// exactly what §5.4 warns about.
///
/// The border is deliberately drawn outside any opacity applied to the
/// content: the sample fades, its frame does not.
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 20,
    this.dash = 6,
    this.gap = 5,
    this.strokeWidth = 1.2,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedRRectPainter(
          color: color,
          radius: radius,
          dash: dash,
          gap: gap,
          strokeWidth: strokeWidth,
        ),
        child: Padding(padding: padding, child: child),
      );
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth;
}
