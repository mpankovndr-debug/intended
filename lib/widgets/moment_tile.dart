import 'package:flutter/widgets.dart';

/// One moment as a square: plain colour with the grid's own inner gradient,
/// never an icon. Shared by the completion sheet and onboarding's first
/// moment, so the tile that lands there is literally the tile the month
/// page shows.
class MomentTile extends StatelessWidget {
  const MomentTile({
    super.key,
    required this.color,
    this.glow = 0,
    this.size = 26,
  });

  final Color color;

  /// 0 to 1: the soft light around a tile that has just landed.
  final double glow;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final lit =
        hsl.withLightness((hsl.lightness + 0.07).clamp(0.0, 1.0)).toColor();
    final shade =
        hsl.withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0)).toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lit, color, shade],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(size * 8 / 26),
        boxShadow: glow > 0
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.7 * glow),
                  blurRadius: 16 * glow,
                  spreadRadius: 3 * glow,
                ),
              ]
            : null,
      ),
    );
  }
}
