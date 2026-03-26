import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

class AppToast {
  static OverlayEntry? _current;

  static void show(BuildContext context, String message) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _current = OverlayEntry(
      builder: (_) => _AppToastWidget(
        message: message,
        onDismissed: () {
          _current?.remove();
          _current = null;
        },
      ),
    );

    overlay.insert(_current!);
  }

  /// Show toast using a pre-resolved [OverlayState] (safe to call after pop).
  static void showOnOverlay(OverlayState overlay, String message) {
    _current?.remove();
    _current = null;

    _current = OverlayEntry(
      builder: (_) => _AppToastWidget(
        message: message,
        onDismissed: () {
          _current?.remove();
          _current = null;
        },
      ),
    );

    overlay.insert(_current!);
  }
}

class _AppToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const _AppToastWidget({
    required this.message,
    required this.onDismissed,
  });

  @override
  State<_AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<_AppToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomPadding + 104,
      child: GestureDetector(
        onTap: _dismiss,
        child: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _slide,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: colors.cardBackground
                        .withOpacity(colors.cardBackgroundOpacity),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colors.borderCard
                          .withOpacity(colors.borderCardOpacity),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
