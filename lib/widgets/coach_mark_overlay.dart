import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

class CoachMarkOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final String title;
  final String body;
  final VoidCallback onDismiss;
  /// Optional icon rendered inline after the title text.
  final Widget? titleIcon;

  const CoachMarkOverlay({
    super.key,
    required this.targetKey,
    required this.title,
    required this.body,
    required this.onDismiss,
    this.titleIcon,
  });

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse(
      from: _controller.value,
    );
    widget.onDismiss();
  }

  /// Returns the Rect of the target widget in global coordinates, or null.
  Rect? _targetRect() {
    final ctx = widget.targetKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final screenSize = MediaQuery.of(context).size;
    final targetRect = _targetRect();

    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: Stack(
          children: [
            // Subtle background blur — excludes the highlighted cutout area
            // so only the dimmed background is blurred, not the target element.
            ClipPath(
              clipper: _BlurClipper(targetRect: targetRect),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: const SizedBox.expand(),
              ),
            ),
            // Dimmed overlay with cutout
            CustomPaint(
              size: screenSize,
              painter: _CutoutPainter(targetRect: targetRect),
            ),
            // Tooltip card
            if (targetRect != null)
              _buildCard(context, colors, screenSize, targetRect),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    AppColorScheme colors,
    Size screenSize,
    Rect targetRect,
  ) {
    const cardMinWidth = 260.0;
    const cardMaxWidth = 320.0;
    const arrowSize = 8.0;
    const distanceFromTarget = 8.0;
    const cardPadding = 16.0;

    // Decide: below or above?
    final spaceBelow = screenSize.height - targetRect.bottom;
    final placeBelow = spaceBelow >= 120;

    // Horizontal position: centre on target, clamped to screen edges.
    double cardLeft = targetRect.center.dx - cardMaxWidth / 2;
    cardLeft = cardLeft.clamp(12.0, screenSize.width - cardMaxWidth - 12.0);

    final double cardTop = placeBelow
        ? targetRect.bottom + distanceFromTarget + arrowSize
        : targetRect.top - distanceFromTarget - arrowSize - 120;

    // Arrow horizontal position relative to card
    final double arrowCenterX =
        (targetRect.center.dx - cardLeft).clamp(arrowSize + 8, cardMaxWidth - arrowSize - 8);

    // Opaque card colour — clamp to at least 0.88 so the card is always
    // clearly legible against the dimmed overlay.
    final cardColor = colors.cardBackground
        .withOpacity(colors.cardBackgroundOpacity.clamp(0.88, 1.0));

    return Positioned(
      left: cardLeft,
      top: placeBelow ? cardTop : null,
      bottom: placeBelow ? null : screenSize.height - targetRect.top + distanceFromTarget + arrowSize,
      child: GestureDetector(
        // Prevent taps on the card from bubbling to the dismiss handler.
        onTap: () {},
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: cardMinWidth,
              maxWidth: cardMaxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (placeBelow)
                  _Arrow(
                    pointUp: true,
                    offsetX: arrowCenterX,
                    color: cardColor,
                  ),
                _CardBody(
                  title: widget.title,
                  titleIcon: widget.titleIcon,
                  body: widget.body,
                  onDismiss: _dismiss,
                  cardPadding: cardPadding,
                  colors: colors,
                  cardColor: cardColor,
                ),
                if (!placeBelow)
                  _Arrow(
                    pointUp: false,
                    offsetX: arrowCenterX,
                    color: cardColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card body ──────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  final String title;
  final Widget? titleIcon;
  final String body;
  final VoidCallback onDismiss;
  final double cardPadding;
  final AppColorScheme colors;
  final Color cardColor;

  const _CardBody({
    required this.title,
    required this.body,
    required this.onDismiss,
    required this.cardPadding,
    required this.colors,
    required this.cardColor,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.borderCard.withOpacity(
                  (colors.borderCardOpacity * 2.0).clamp(0.0, 0.5)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row — optional icon inline after title text
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (titleIcon != null) ...[
                    const SizedBox(width: 6),
                    titleIcon!,
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary.withOpacity(0.72),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.ctaPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Arrow triangle ─────────────────────────────────────────────────────────────

class _Arrow extends StatelessWidget {
  final bool pointUp;
  final double offsetX;
  final Color color;

  const _Arrow({
    required this.pointUp,
    required this.offsetX,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: CustomPaint(
        painter: _ArrowPainter(
          pointUp: pointUp,
          offsetX: offsetX,
          color: color,
        ),
        size: const Size(double.infinity, 8),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool pointUp;
  final double offsetX;
  final Color color;

  const _ArrowPainter({
    required this.pointUp,
    required this.offsetX,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const halfBase = 8.0;
    final cx = offsetX;

    final path = Path();
    if (pointUp) {
      path.moveTo(cx, 0);
      path.lineTo(cx - halfBase, size.height);
      path.lineTo(cx + halfBase, size.height);
    } else {
      path.moveTo(cx - halfBase, 0);
      path.lineTo(cx + halfBase, 0);
      path.moveTo(cx, size.height);
      path.lineTo(cx - halfBase, 0);
      path.lineTo(cx + halfBase, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.pointUp != pointUp ||
      old.offsetX != offsetX ||
      old.color != color;
}

// ── Dimmed overlay with rectangular cutout ─────────────────────────────────────

class _CutoutPainter extends CustomPainter {
  final Rect? targetRect;

  const _CutoutPainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x99000000); // black 60%

    if (targetRect == null) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    const radius = 14.0;
    final cutout = RRect.fromRectAndRadius(
      targetRect!.inflate(8),
      const Radius.circular(radius),
    );

    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRRect(cutout);
    final combined = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_CutoutPainter old) => old.targetRect != targetRect;
}

// ── Blur clipper — covers entire screen minus the highlighted cutout ────────────

class _BlurClipper extends CustomClipper<Path> {
  final Rect? targetRect;

  const _BlurClipper({this.targetRect});

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Offset.zero & size);
    if (targetRect == null) return full;
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(
        targetRect!.inflate(8),
        const Radius.circular(14),
      ));
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(_BlurClipper old) => old.targetRect != targetRect;
}
