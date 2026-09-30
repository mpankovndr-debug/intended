import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../utils/text_styles.dart';

/// A button that commits only when held (spec §6, screen 3): it fills over
/// [duration] with a rising count of haptic ticks, and slides back if let go
/// early. The hold turns "continue" into "I mean it".
///
/// It must not lock anyone out: VoiceOver's activate gesture cannot hold a
/// custom control, so the semantic tap confirms at once.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1200),
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool enabled;
  final Duration duration;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill =
      AnimationController(vsync: this, duration: widget.duration)
        ..addListener(_tick)
        ..addStatusListener(_status);

  /// Ticks felt so far on this press: one at each third of the way.
  int _ticks = 0;
  bool _confirmed = false;

  void _tick() {
    setState(() {});
    if (_fill.status != AnimationStatus.forward) return;
    final reached = (_fill.value * 3).floor();
    if (reached > _ticks && reached < 3) {
      _ticks = reached;
      HapticFeedback.selectionClick();
    }
  }

  void _status(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_confirmed) {
      _confirmed = true;
      HapticFeedback.mediumImpact();
      widget.onConfirmed();
    }
  }

  void _press() {
    if (!widget.enabled || _confirmed) return;
    _ticks = 0;
    HapticFeedback.lightImpact();
    _fill.forward();
  }

  void _release() {
    if (_fill.isCompleted) return;
    _fill.animateBack(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _confirmNow() {
    if (!widget.enabled || _confirmed) return;
    _fill.value = 1;
    _status(AnimationStatus.completed);
  }

  @override
  void didUpdateWidget(HoldToConfirmButton old) {
    super.didUpdateWidget(old);
    if (!widget.enabled && _fill.value > 0 && !_fill.isCompleted) {
      _fill.value = 0;
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final enabled = widget.enabled;
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colors.ctaPrimary, colors.ctaSecondary],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? _confirmNow : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(),
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Color.alphaBlend(
              colors.ctaPrimary.withValues(alpha: enabled ? 0.45 : 0.32),
              colors.onboardingBg4,
            ),
            boxShadow: _fill.value > 0
                ? [
                    BoxShadow(
                      color: colors.ctaPrimary
                          .withValues(alpha: 0.35 * _fill.value),
                      blurRadius: 24,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _fill.value,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: gradient),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? const Color(0xFFFFFFFF)
                          : Color.alphaBlend(
                              colors.ctaPrimary.withValues(alpha: 0.65),
                              colors.onboardingBg4,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
