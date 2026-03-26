import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// A full-screen overlay that plays a warm, 4-phase "Quiet Bloom" animation
/// when the user completes every habit for the day.
///
/// Phases:
///   1. Settle  (0–400 ms)   — background dims + blurs, world quiets
///   2. Bloom   (400–1200 ms) — soft radial glow expands from centre
///   3. Message (900–3600 ms) — warm particles drift upward, words appear
///      one by one (~80 ms stagger) with a gentle scale-breathing effect
///   4. Fade    (3600–4600 ms) — everything dissolves, overlay auto-removes
class QuietBloomOverlay extends StatefulWidget {
  final VoidCallback onDismissed;

  const QuietBloomOverlay({super.key, required this.onDismissed});

  // ── Static API (matches WarmthToastOverlay pattern) ──────────────
  static OverlayEntry? _current;

  static Future<void> show(BuildContext context) async {
    debugPrint('[QuietBloom] show() called');
    if (_current != null) {
      debugPrint('[QuietBloom] ❌ Already showing, skipping');
      return;
    }

    if (!context.mounted) {
      debugPrint('[QuietBloom] ❌ Context not mounted');
      return;
    }
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      debugPrint('[QuietBloom] ❌ No Overlay found in context');
      return;
    }

    _current = OverlayEntry(
      builder: (_) => QuietBloomOverlay(
        onDismissed: _remove,
      ),
    );

    overlay.insert(_current!);
    debugPrint('[QuietBloom] ✅ Overlay inserted');
  }

  static void _remove() {
    _current?.remove();
    _current?.dispose();
    _current = null;
  }

  @override
  State<QuietBloomOverlay> createState() => _QuietBloomOverlayState();
}

class _QuietBloomOverlayState extends State<QuietBloomOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // ── Timeline (ms) ──────────────────────────────────────────────
  //   0–400     Settle: bg dims + blur
  //   400–1200  Bloom: radial glow expands
  //   400–3600  Floating particles drift upward (staggered spawns)
  //   900+      Words stagger in (~80ms apart) with scale breathing
  //   –3200     Hold
  //   3200–3600 Message fades out
  //   3600–4600 Full overlay fade-out
  static const _total = 4600.0;

  // Phase 1 – Settle: background dims + blurs
  late final Animation<double> _bgOpacity;

  // Phase 2 – Bloom: radial glow scale + opacity
  late final Animation<double> _bloomScale;
  late final Animation<double> _bloomOpacity;

  // Phase 3a – Floating particles
  late final List<_Particle> _particles;

  // Phase 3b – Message: overall envelope (words stagger within this)
  late final Animation<double> _messageEnvelope;

  // Phase 3c – Text scale: subtle breathing 1.04 → 1.0
  late final Animation<double> _textScale;

  // Phase 4 – Fade-out: everything
  late final Animation<double> _fadeAll;

  String _bloomMessage = '';
  List<String> _words = [];

  // Per-word stagger: each word starts appearing at an offset
  static const _wordDelayMs = 80.0;
  // Words start appearing at this point in the timeline
  static const _wordsStartMs = 900.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );

    // Phase 1: Settle — bg dims from 0→0.45 over 0–400 ms
    _bgOpacity = Tween<double>(begin: 0, end: 0.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, 400 / _total, curve: Curves.easeOut),
      ),
    );

    // Phase 2: Bloom — radial glow 0.3→1.0 over 400–1200 ms
    _bloomScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(400 / _total, 1200 / _total, curve: Curves.easeOutCubic),
      ),
    );
    _bloomOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.55), weight: 800),
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.55), weight: 2000),
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 0), weight: 1400),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(400 / _total, 1.0),
      ),
    );

    // Phase 3a: Floating particles — 10 warm circles that drift upward
    final rng = Random();
    _particles = List.generate(10, (_) => _Particle(rng));

    // Phase 3b: Message envelope — controls the overall fade-out of all text
    // (Individual word fade-ins are computed manually in build)
    _messageEnvelope = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1), weight: 2300), // 900–3200: hold
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 400),  // 3200–3600: fade out
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(_wordsStartMs / _total, 3600 / _total),
      ),
    );

    // Phase 3c: Text scale — subtle breathing 1.04→1.0 over 900–1400ms
    _textScale = Tween<double>(begin: 1.04, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(900 / _total, 1400 / _total, curve: Curves.easeOut),
      ),
    );

    // Phase 4: Full overlay fade-out 3600–4600
    _fadeAll = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(3600 / _total, 1.0, curve: Curves.easeIn),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessageAndPlay());
  }

  /// Compute per-word opacity based on current controller time.
  double _wordOpacity(int wordIndex) {
    final currentMs = _controller.value * _total;
    final wordStartMs = _wordsStartMs + (wordIndex * _wordDelayMs);
    const wordFadeDuration = 200.0; // each word fades in over 200ms
    if (currentMs < wordStartMs) return 0;
    if (currentMs > wordStartMs + wordFadeDuration) return 1;
    return Curves.easeOut
        .transform((currentMs - wordStartMs) / wordFadeDuration);
  }

  Future<void> _loadMessageAndPlay() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final prefs = await SharedPreferences.getInstance();
    final pathKey = prefs.getString('selected_intention_path') ?? 'your_own_way';
    final pathId = IntentionPathId.fromKey(pathKey);
    final index = Random().nextInt(5) + 1;

    setState(() {
      _bloomMessage = _getBloomMessage(l10n, pathId, index);
      _words = _bloomMessage.split(' ');
    });

    // Soft haptic at the bloom moment
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.mediumImpact();
    });

    _controller.forward().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  String _getBloomMessage(AppLocalizations l10n, IntentionPathId pathId, int index) {
    return switch (pathId) {
      IntentionPathId.gentleMornings => switch (index) {
        1 => l10n.bloomGentleMornings1,
        2 => l10n.bloomGentleMornings2,
        3 => l10n.bloomGentleMornings3,
        4 => l10n.bloomGentleMornings4,
        _ => l10n.bloomGentleMornings5,
      },
      IntentionPathId.findingCalm => switch (index) {
        1 => l10n.bloomFindingCalm1,
        2 => l10n.bloomFindingCalm2,
        3 => l10n.bloomFindingCalm3,
        4 => l10n.bloomFindingCalm4,
        _ => l10n.bloomFindingCalm5,
      },
      IntentionPathId.gratitudeSelfLove => switch (index) {
        1 => l10n.bloomGratitudeSelfLove1,
        2 => l10n.bloomGratitudeSelfLove2,
        3 => l10n.bloomGratitudeSelfLove3,
        4 => l10n.bloomGratitudeSelfLove4,
        _ => l10n.bloomGratitudeSelfLove5,
      },
      IntentionPathId.windingDown => switch (index) {
        1 => l10n.bloomWindingDown1,
        2 => l10n.bloomWindingDown2,
        3 => l10n.bloomWindingDown3,
        4 => l10n.bloomWindingDown4,
        _ => l10n.bloomWindingDown5,
      },
      IntentionPathId.yourOwnWay => switch (index) {
        1 => l10n.bloomYourOwnWay1,
        2 => l10n.bloomYourOwnWay2,
        3 => l10n.bloomYourOwnWay3,
        4 => l10n.bloomYourOwnWay4,
        _ => l10n.bloomYourOwnWay5,
      },
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final size = MediaQuery.of(context).size;
    final bloomRadius = size.shortestSide * 0.9;
    final textColor = Colors.white.withOpacity(0.94);
    final textStyle = AppTextStyles.h2(context).copyWith(
      color: textColor,
      letterSpacing: -0.3,
      fontWeight: FontWeight.w500,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAll,
          child: GestureDetector(
            // Tap to skip / dismiss early
            onTap: () {
              if (_controller.isAnimating) {
                _controller.stop();
                widget.onDismissed();
              }
            },
            child: SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Phase 1: Blurred + dimmed background
                  AnimatedBuilder(
                    animation: _bgOpacity,
                    builder: (context, _) {
                      final blurSigma = (_bgOpacity.value / 0.45) * 18.0;
                      return BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: blurSigma,
                          sigmaY: blurSigma,
                        ),
                        child: Container(
                          color: Colors.black.withOpacity(_bgOpacity.value),
                        ),
                      );
                    },
                  ),

                  // Phase 2: Radial bloom glow
                  AnimatedBuilder(
                    animation: _bloomScale,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _bloomScale.value,
                        child: Container(
                          width: bloomRadius,
                          height: bloomRadius,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                colors.ctaPrimary.withOpacity(_bloomOpacity.value),
                                colors.ctaPrimary.withOpacity(_bloomOpacity.value * 0.3),
                                colors.ctaPrimary.withOpacity(0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Phase 3a: Floating particles
                  ..._particles.map((p) {
                    final progress = p.progressAt(_controller.value, _total);
                    if (progress <= 0) return const SizedBox.shrink();
                    // Opacity: fade in 0→0.15, hold, fade out last 20%
                    final opacity = progress < 0.15
                        ? (progress / 0.15)
                        : progress > 0.8
                            ? (1.0 - progress) / 0.2
                            : 1.0;
                    // Vertical drift: start from p.startY, drift up by ~30% of screen
                    final dy = size.height * (p.startY - progress * 0.30);
                    final dx = size.width * p.startX +
                        sin(progress * pi * 2 * p.swayCycles) * p.swayAmount;
                    return Positioned(
                      left: dx - p.radius,
                      top: dy - p.radius,
                      child: Opacity(
                        opacity: (opacity * p.maxOpacity).clamp(0.0, 1.0),
                        child: Container(
                          width: p.radius * 2,
                          height: p.radius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.ctaPrimary,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Phase 3b: Staggered words with scale breathing — centred
                  Opacity(
                    opacity: _messageEnvelope.value,
                    child: Transform.scale(
                      scale: _textScale.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            for (int i = 0; i < _words.length; i++)
                              Opacity(
                                opacity: _wordOpacity(i),
                                child: Text(
                                  '${_words[i]}${i < _words.length - 1 ? ' ' : ''}',
                                  style: textStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Particle data ──────────────────────────────────────────────────
/// A single floating particle with randomised position, size, and drift.
class _Particle {
  /// Horizontal start position (0–1, fraction of screen width).
  final double startX;

  /// Vertical start position (0–1, fraction of screen height).
  final double startY;

  /// Radius in logical pixels (2–5).
  final double radius;

  /// Peak opacity (0.12–0.35) — keeps particles subtle.
  final double maxOpacity;

  /// How far the particle sways horizontally (pixels).
  final double swayAmount;

  /// Number of sway half-cycles over the particle's lifetime.
  final double swayCycles;

  /// When this particle first appears in the timeline (ms).
  final double spawnMs;

  /// How long this particle lives (ms).
  final double lifetimeMs;

  _Particle(Random rng)
      : startX = 0.15 + rng.nextDouble() * 0.70, // avoid edges
        startY = 0.40 + rng.nextDouble() * 0.35,  // cluster around centre
        radius = 2.0 + rng.nextDouble() * 3.0,
        maxOpacity = 0.12 + rng.nextDouble() * 0.23,
        swayAmount = 8.0 + rng.nextDouble() * 16.0,
        swayCycles = 0.5 + rng.nextDouble() * 1.5,
        spawnMs = 400 + rng.nextDouble() * 600,   // stagger spawns 400–1000ms
        lifetimeMs = 2000 + rng.nextDouble() * 1200; // live 2–3.2s

  /// Returns 0→1 progress for this particle, or ≤0 if not yet spawned.
  double progressAt(double controllerValue, double totalMs) {
    final currentMs = controllerValue * totalMs;
    if (currentMs < spawnMs) return 0;
    return ((currentMs - spawnMs) / lifetimeMs).clamp(0.0, 1.0);
  }
}
