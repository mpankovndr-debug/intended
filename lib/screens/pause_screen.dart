import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart' show AppBackground;
import '../models/pause_check_in.dart';
import '../services/analytics_service.dart';
import '../services/health_service.dart';
import '../services/pause_native.dart';
import '../services/pause_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/responsive_utils.dart';
import '../utils/text_styles.dart';

/// A minute of breath: ~5s in, ~7s out, five breaths, then one optional tap.
///
/// Free forever — rescue-shaped surfaces are never paywalled. The rhythm is
/// carried visually (the glow), haptically (Core Haptics, when the hardware
/// has an engine) and — under Reduce Motion — verbally; no single channel is
/// ever the only carrier, because iPad has no engine and Reduce Motion can
/// remove the glow's movement.
///
/// No countdown, no progress, no timer digits: the minute is five breaths and
/// the screen never says so. The status bar hides for the duration — the
/// clock is a countdown in disguise. Leaving early is a first-class exit,
/// not an interruption: it is logged, never questioned, and never recorded
/// as data (an abandoned-pause record would grade the leaving).
class PauseScreen extends StatefulWidget {
  const PauseScreen({super.key, required this.entry});

  /// Where the pause was opened from: 'home' | 'widget' | 'lockscreen' |
  /// 'notification'. Recorded on the check-in and in analytics.
  final String entry;

  // Five 12-second breaths: 5 breaths/min sits in the coherent-breathing
  // band and the exhale stays dominant. Deliberately the floor — longer
  // cycles produce air hunger in exactly the person this screen exists for.
  static const Duration cycleDuration = Duration(seconds: 12);
  static const int totalCycles = 5;

  /// The breath is light, and its colour is set by what it must sit on:
  /// every theme's sky has red in it (the lavenders, the roses, the ambers)
  /// and none has yellow, so the light is warm white leaning rose — the
  /// reference's palette — not the cream-apricot of the first builds, which
  /// fought the lavender the way a complementary does. Theme-invariant,
  /// except the halo, which is fog lit from inside and takes the sky's tint.
  static const Color sunCore = Color(0xFFFFF8F6);
  static const Color sunBody = Color(0xFFFBDFDB);

  /// Ink for the door's words: the same light, darkened into a dusty rose.
  static const Color sunInk = Color(0xFFA4756E);

  /// A deeper rose for the one job brightness can't do: defining the light
  /// against a sky that is already bright and warm.
  static const Color sunShade = Color(0xFFEFC0B4);
  static const Color sunShadeDeep = Color(0xFFE4A697);

  /// Night skies get a moon, not a sun: sunlight through fog is warm, but
  /// moonlight is cool, and the rose light over navy mixed to grey (the
  /// founder's "chalky disc"). Pale periwinkle-white instead.
  static const Color moonCore = Color(0xFFF2F0FF);
  static const Color moonBody = Color(0xFFD6D3F0);

  /// True for skies the light can't out-shine — bright and warm (warmClay,
  /// sandDune, goldenHour, softDusk). The nine-theme sweep showed the
  /// warm-white streak and the pebble's edge both disappearing on them:
  /// there, definition has to come from a slightly deeper tone at the edge
  /// rather than from more light.
  static bool brightWarmSky(AppColorScheme colors) {
    final sky = HSLColor.fromColor(colors.onboardingBg2);
    final warm = sky.hue < 75 || sky.hue > 330;
    return warm && sky.lightness > 0.80;
  }

  /// Fraction of a cycle spent inhaling (5s of 12).
  static const double inhaleFraction = 5 / 12;

  /// The glow's scale between breaths.
  static const double restScale = 0.62;

  /// The glow's scale at cycle progress [t] (0..1): rest → full → rest,
  /// easeInOutSine both ways so each turn happens at zero velocity — a
  /// breath turning, not an animation bouncing. The final exhale ends at
  /// [restScale], so the settle into the check-in needs no extra animation.
  ///
  /// Pure and static so a test can pin the shape (§code rules: logic that
  /// needs a BuildContext can't be tested, so none of this does).
  static double breathScaleAt(double t) {
    final clamped = t.clamp(0.0, 1.0);
    final double eased;
    if (clamped <= inhaleFraction) {
      final u = clamped / inhaleFraction;
      eased = 0.5 - 0.5 * math.cos(math.pi * u);
    } else {
      final u = (clamped - inhaleFraction) / (1 - inhaleFraction);
      eased = 0.5 + 0.5 * math.cos(math.pi * u);
    }
    return restScale + (1.0 - restScale) * eased;
  }

  /// Reduce Motion replaces the moving glow with words — designed as
  /// carefully as the default: each word fades in over ~600ms, holds for its
  /// phase, and dissolves before the other begins, driven by the same clock
  /// as the haptics so the channels can't drift.
  static double inWordOpacityAt(double t) =>
      _wordOpacityAt(t, 0.0, inhaleFraction);

  static double outWordOpacityAt(double t) =>
      _wordOpacityAt(t, inhaleFraction, 1.0);

  static double _wordOpacityAt(double t, double from, double to) {
    const fade = 0.05; // of the 12s cycle = 600 ms
    if (t <= from || t >= to) return 0;
    if (t < from + fade) return (t - from) / fade;
    if (t > to - fade) return (to - t) / fade;
    return 1;
  }

  /// A soft fade in and out — arriving at this screen should feel like the
  /// app exhaling, not navigating.
  static Route<void> route({required String entry}) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => PauseScreen(entry: entry),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  State<PauseScreen> createState() => _PauseScreenState();
}

enum _Stage { settling, breathing, settlingOut, checkIn }

class _PauseScreenState extends State<PauseScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _cycle;
  late final DateTime _startedAt;

  _Stage _stage = _Stage.settling;
  DateTime? _breathEndedAt;
  int _cyclesDone = 0;
  bool _haptics = false;
  bool _entered = false;
  bool _closing = false;
  Timer? _settleTimer;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    AnalyticsService.logPauseStarted(widget.entry);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _cycle = AnimationController(vsync: this, duration: PauseScreen.cycleDuration)
      ..addStatusListener(_onCycleStatus);

    PauseNative.prepareHaptics().then((ok) {
      if (mounted) _haptics = ok;
    });

    // A settle-in beat, then the breathing starts on its own: asking an
    // overwhelmed person for a tap is one more demand, and there is nothing
    // here to tap anyway — you arrive, and the room is already breathing.
    _settleTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted || _closing) return;
      setState(() => _stage = _Stage.breathing);
      _startCycle();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  void _startCycle() {
    if (_haptics) PauseNative.playHapticCycle();
    _cycle.forward(from: 0);
  }

  void _onCycleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _closing) return;
    _cyclesDone++;
    if (_cyclesDone < PauseScreen.totalCycles) {
      _startCycle();
      return;
    }
    // The minute is over because the fifth exhale ended — never mid-breath.
    // This instant, not the check-in tap, closes the mindful session: idle
    // time spent looking at the question is not mindfulness, and writing it
    // as such would be fabricated health data (the first simulator run
    // logged "4 min" for one minute of breath).
    _breathEndedAt = DateTime.now();
    AnalyticsService.logPauseCompleted(widget.entry);
    setState(() => _stage = _Stage.settlingOut);
    _settleTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted && !_closing) setState(() => _stage = _Stage.checkIn);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding mid-breath ends the pause quietly: resuming into a
    // half-finished cycle with drifted haptics would be worse than leaving.
    // The check-in survives a detour — a question can wait.
    if (state == AppLifecycleState.paused && _stage != _Stage.checkIn) {
      _leaveEarly();
    }
  }

  void _leaveEarly() {
    if (_closing) return;
    _closing = true;
    _settleTimer?.cancel();
    _cycle.stop();
    PauseNative.stopHaptics();
    AnalyticsService.logPauseLeftEarly(
        DateTime.now().difference(_startedAt).inSeconds);
    if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitCheckIn(PauseState? state) async {
    if (_closing) return;
    _closing = true;
    HapticFeedback.selectionClick();
    AnalyticsService.logPauseCheckIn(state?.key ?? 'skipped');

    await PauseService.record(
      PauseCheckIn.create(state: state, entry: widget.entry),
    );
    await _maybeOfferHealthSave();
    await HealthService.saveCompletedPause(
      start: _startedAt,
      end: _breathEndedAt ?? DateTime.now(),
      state: state,
    );

    if (!mounted) return;
    // A State stays mounted for the whole exit transition, so after the
    // awaits above only the current route may pop itself (§code rules).
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      Navigator.of(context).pop();
    }
  }

  /// The one-time contextual soft-ask, shown right after the first completed
  /// pause — never in onboarding. Declining is final for this release; the
  /// system sheet appears only after an explicit yes.
  ///
  /// A sheet dismissed by tapping outside answers `null`, and that is not a
  /// decision: it neither settles the question nor counts as a refusal in the
  /// numbers. It comes back on the next pause, up to HealthService's cap.
  Future<void> _maybeOfferHealthSave() async {
    if (!await HealthService.shouldOfferSave()) return;
    await HealthService.markOffered();
    if (!mounted) return;
    final colors = context.read<ThemeProvider>().colors;
    final answer = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor:
          colors.barrierColor.withValues(alpha: colors.barrierOpacity),
      builder: (_) => const _HealthAskSheet(),
    );
    if (answer == null) {
      AnalyticsService.logPauseHealthPrompt('dismissed');
      return;
    }
    await HealthService.markAnswered();
    AnalyticsService.logPauseHealthPrompt(answer ? 'accepted' : 'declined');
    if (answer) await PauseNative.healthRequestWriteAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settleTimer?.cancel();
    _cycle.dispose();
    PauseNative.stopHaptics();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Text styles read Responsive before AppBackground below gets a chance
    // to initialize it — on a cold tree (tests, deep links) nothing else has.
    Responsive.init(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isCheckIn = _stage == _Stage.checkIn;

    return AppBackground(
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 4),
            _breathGlow(colors, l10n, reduceMotion, isDark),
            const Spacer(flex: 2),
            // Laid out from the start at opacity 0 so its arrival never
            // reflows the glow above it.
            AnimatedOpacity(
              opacity: isCheckIn ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: !isCheckIn,
                child: _checkInBlock(colors, l10n),
              ),
            ),
            const Spacer(flex: 1),
            _bottomAffordance(colors, l10n, isCheckIn),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _breathGlow(AppColorScheme colors, AppLocalizations l10n,
      bool reduceMotion, bool isDark) {
    // Sized to the screen, capped by height: shortestSide alone overflows
    // the column in short viewports (iPad split view, tests).
    final screen = MediaQuery.of(context).size;
    final box = math.min(screen.shortestSide * 0.78, screen.height * 0.46);
    return AnimatedOpacity(
      opacity: _entered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      child: SizedBox(
        width: box,
        height: box,
        child: AnimatedBuilder(
          animation: _cycle,
          builder: (context, _) {
            // Under Reduce Motion the glow holds still and the words carry
            // the rhythm; otherwise scale tracks the breath curve, which
            // also covers every non-breathing stage (value 0 and 1 are both
            // rest).
            final scale = reduceMotion
                ? 0.8
                : PauseScreen.breathScaleAt(_cycle.value);
            final n = reduceMotion
                ? 0.5
                : ((scale - PauseScreen.restScale) /
                        (1.0 - PauseScreen.restScale))
                    .clamp(0.0, 1.0);
            // The morph clock runs only while breathing — it freezes with
            // the breath, and Reduce Motion pins it at zero.
            final morphT = reduceMotion
                ? 0.0
                : (_cyclesDone + _cycle.value) *
                    PauseScreen.cycleDuration.inSeconds;
            final dim = isDark ? 0.62 : 1.0;
            final warmSky = PauseScreen.brightWarmSky(colors);
            final core = isDark ? PauseScreen.moonCore : PauseScreen.sunCore;
            final body = isDark ? PauseScreen.moonBody : PauseScreen.sunBody;
            // The halo is lighter than the light's own body: tinting it
            // toward the sky (an earlier pass) made it duller than the
            // sky around it, which is the opposite of a glow.
            final fog = Color.lerp(body, core, 0.5)!;
            // The halo shares the painter's hum (see _SunPebblePainter).
            final hum =
                morphT == 0 ? 0.0 : math.sin(2 * math.pi * morphT / 1.6);
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.scale(
                    scale: scale, child: _halo(box, n, dim, fog, hum)),
                CustomPaint(
                  size: Size.square(box),
                  painter: _SunPebblePainter(
                      scale: scale,
                      n: n,
                      t: morphT,
                      dim: dim,
                      // A moon behind thin cloud: on a dark sky an opaque
                      // disc is a spotlight, so the body thins and the
                      // halo carries the glow.
                      bodyDim: isDark ? 0.48 : 1.0,
                      core: core,
                      body: body,
                      defineEdge: warmSky),
                ),
                if (reduceMotion && _stage == _Stage.breathing) ...[
                  _breathWord(
                      l10n.pauseBreathIn,
                      PauseScreen.inWordOpacityAt(_cycle.value),
                      colors,
                      l10n),
                  _breathWord(
                      l10n.pauseBreathOut,
                      PauseScreen.outWordOpacityAt(_cycle.value),
                      colors,
                      l10n),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// The light soaking outward into the fog, behind the pebble. Diffuse
  /// enough that it can stay a circle while the body above it morphs.
  /// [n] is 0 at rest, 1 at the crest — it brightens as the breath fills.
  Widget _halo(double box, double n, double dim, Color fog, double hum) {
    // Wider than the body by half again: the reference's glow lifts the
    // landscape around the light, not just its edge.
    dim *= 1 + 0.05 * hum;
    return Container(
      width: box * 1.4,
      height: box * 1.4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          // The body's edge sits at ~0.63 of this radius; the stops keep
          // the glow dense just outside it and let it fade over the
          // remaining third — a gradient, so it stays cheap per frame.
          colors: [
            fog.withValues(alpha: (0.60 + 0.10 * n) * dim),
            fog.withValues(alpha: 0.45 * dim),
            fog.withValues(alpha: 0.20 * dim),
            fog.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 0.78, 1.0],
        ),
      ),
    );
  }

  Widget _breathWord(String word, double opacity, AppColorScheme colors,
      AppLocalizations l10n) {
    return Opacity(
      opacity: opacity,
      child: Text(
        word,
        style: TextStyle(
          // Sora has no Cyrillic — the display face must switch by locale.
          fontFamily: AppTextStyles.displayFontFor(l10n.localeName),
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: colors.textPrimary.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _checkInBlock(AppColorScheme colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.pauseCheckInQuestion,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(context)
                .copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          // Same quiet fill and stretch-row as the completion moods: one
          // vocabulary for one gesture. No colour scale across the three —
          // a warm-to-cool ramp would make "calm" the visually right answer.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: _statePill(
                        l10n.pauseCheckInTense, PauseState.tense, colors)),
                const SizedBox(width: 8),
                Expanded(
                    child: _statePill(
                        l10n.pauseCheckInNeutral, PauseState.neutral, colors)),
                const SizedBox(width: 8),
                Expanded(
                    child: _statePill(
                        l10n.pauseCheckInCalm, PauseState.calm, colors)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statePill(String label, PauseState state, AppColorScheme colors) {
    // The home cards' own glass — a translucent wash and a white hairline —
    // rather than a solid tint. Solid pills read as controls dropped onto
    // the landscape; glass reads as part of it.
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: () => _submitCheckIn(state),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: colors.cardBackground.withValues(
              alpha: (colors.cardBackgroundOpacity + 0.12).clamp(0.0, 1.0)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// One quiet word, visible the whole time. During the breath it is the
  /// exit ("enough for now" — sufficiency, not abandonment); at the check-in
  /// the same slot becomes the skip, so leaving never moves or changes
  /// weight.
  Widget _bottomAffordance(
      AppColorScheme colors, AppLocalizations l10n, bool isCheckIn) {
    return CupertinoButton(
      minimumSize: const Size(44, 44),
      onPressed: isCheckIn ? () => _submitCheckIn(null) : _leaveEarly,
      child: Text(
        isCheckIn ? l10n.completionSkip : l10n.pauseLeave,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 14,
          color: colors.textSecondary.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

/// The lit pebble: pebble geometry — an organic, slowly morphing edge — in
/// sun material. Resolves the orb-versus-pebble question both ways at once:
/// a soft glow has a gradient for an edge, so its growth reads as
/// brightening, while a dark pebble has the crispest edge but is the first
/// heavy object in a world of mist and dies on dark themes. A luminous body
/// with a defined rim keeps the legible edge breath entrainment needs, and
/// two slow sine lobes (17s and 23s periods, never visibly looping) deform
/// it by a few percent so no two breaths share a silhouette.
///
/// Under Reduce Motion the clock is pinned at zero: organic, but still.
class _SunPebblePainter extends CustomPainter {
  const _SunPebblePainter({
    required this.scale,
    required this.n,
    required this.t,
    required this.dim,
    required this.bodyDim,
    required this.core,
    required this.body,
    required this.defineEdge,
  });

  /// Breath scale (restScale..1), brightness lift (0..1), morph clock in
  /// seconds, the dark-theme dimmer for the glow layers, a separate one
  /// for the body (thinner than the glow on night skies), the light's two
  /// colours (sun by day, moon by night), and whether the sky is too bright
  /// and warm for light alone to draw the edge.
  final double scale;
  final double n;
  final double t;
  final double dim;
  final double bodyDim;
  final Color core;
  final Color body;
  final bool defineEdge;

  Path _pebble(Offset c, double r) {
    final phi2 = 2 * math.pi * t / 17.0;
    final phi3 = 2 * math.pi * t / 23.0;
    final path = Path();
    const steps = 72;
    for (var i = 0; i <= steps; i++) {
      final theta = 2 * math.pi * i / steps;
      // The fifth lobe is the hum: a ripple far too small to read as
      // motion, present only while the clock runs (Reduce Motion pins t).
      final wobble = 1 +
          0.05 * math.sin(2 * theta + phi2) +
          0.04 * math.sin(3 * theta + phi3 + 1.7) +
          (t == 0 ? 0 : 0.006 * math.sin(5 * theta + 2 * math.pi * t / 2.1));
      final x = c.dx + r * wobble * math.cos(theta);
      final y = c.dy + r * wobble * math.sin(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Rises a little on the inhale and settles on the exhale, as a chest
    // does.
    final c = size.center(Offset(0, -size.height * 0.02 * n));
    final r = size.shortestSide * 0.44 * scale;
    final bodyPath = _pebble(c, r);

    // Every layer that touches the edge must be *lighter* than the body.
    // An earlier pass let the body go translucent at its edge and drew a
    // salmon rim over it; the lavender bled through the one and the other
    // was darker than the body, and together they read as a dark contour —
    // the opposite of the reference, where the edge is the brightest part.
    final white = const Color(0xFFFFFFFF);
    final edgeLight = Color.lerp(core, white, 0.6)!;
    // A slow luminance hum (~1.6s) on the glow layers: an ember, not a
    // lamp. Felt more than seen; zero under Reduce Motion.
    final hum = t == 0 ? 0.0 : math.sin(2 * math.pi * t / 1.6);

    // Outer glow: a wide, heavily blurred skirt around the silhouette.
    canvas.drawPath(
      _pebble(c, r * 1.15),
      Paint()
        ..color = body.withValues(alpha: 0.45 * dim)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.30),
    );

    // On a bright warm sky the glow has nothing to be brighter than, so a
    // faint deeper-rose shade just outside the edge gives the form back
    // its silhouette — a shadow in the fog rather than more light.
    if (defineEdge) {
      canvas.drawPath(
        _pebble(c, r * 1.06),
        Paint()
          ..color = PauseScreen.sunShade.withValues(alpha: 0.55 * dim)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.10),
      );
    }

    // Light spilling outward from the edge, both sides of the boundary.
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.14
        ..color = edgeLight.withValues(alpha: 0.35 * (1 + 0.06 * hum) * dim)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );

    // Body: luminous, with a little air at the edge — more at the bottom
    // than the top, since the light sits above centre. Never below ~0.7
    // alpha there: past that the lavender wins and the edge turns into a
    // dark contour (the bug this painter has already had once). The inner
    // glow below is what keeps the airy edge lighter than the body.
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = ui.Gradient.radial(
          c.translate(0, -r * 0.10),
          r * 1.10,
          [
            core.withValues(alpha: 0.96 * bodyDim),
            body.withValues(alpha: (0.90 + 0.04 * n) * bodyDim),
            body.withValues(alpha: (0.86 + 0.04 * n) * bodyDim),
            Color.lerp(body, core, 0.35)!.withValues(alpha: 0.74 * bodyDim),
          ],
          const [0.0, 0.50, 0.82, 1.0],
        ),
    );

    // Lit from above its centre: a soft highlight sits high, so the lower
    // body reads a touch softer without ever going translucent.
    canvas.drawCircle(
      c.translate(0, -r * 0.22),
      r * 0.55,
      Paint()
        ..shader = ui.Gradient.radial(
          c.translate(0, -r * 0.22),
          r * 0.55,
          [
            white.withValues(alpha: 0.55 * dim),
            white.withValues(alpha: 0.0),
          ],
        ),
    );

    // Inner glow: a luminous band just inside the edge, clipped to the
    // body so it reads as light gathering at the rim, not an outline.
    canvas.save();
    canvas.clipPath(bodyPath);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.20
        ..color = edgeLight.withValues(
            alpha: (0.38 + 0.10 * n) * (1 + 0.08 * hum) * dim)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.09),
    );
    canvas.restore();

    // The boundary itself: a whisper of a line — defined, not drawn.
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.02
        ..color = white.withValues(alpha: 0.18 * dim)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.02),
    );
  }

  @override
  bool shouldRepaint(_SunPebblePainter old) =>
      old.scale != scale || old.n != n || old.t != t || old.dim != dim;
}

/// The door's light as the reference draws it: a streak with a faint
/// lightning-like waver, brightest at the middle (near white under the
/// words) and warming toward rose as it fades out at the edges. Brightness,
/// not hue, carries it — which is why the same streak reads on every
/// wallpaper, warm ones included.
class _HorizonPainter extends CustomPainter {
  const _HorizonPainter({
    required this.night,
    required this.warmSky,
    required this.sky,
  });

  /// Night skies: moonlight, dimmer, and fading in from the edges so the
  /// line rests under the words instead of sweeping the full width.
  final bool night;

  /// Bright warm skies: no light is brighter than them, and a rose line on
  /// a rose sky (softDusk) vanished completely. The structure that works on
  /// the dark themes — a bright core inside a soft glow — is kept; the glow
  /// is the sky's own colour, saturated.
  final bool warmSky;
  final Color sky;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(-8, h * 0.56)
      ..cubicTo(w * 0.22, h * 0.30, w * 0.40, h * 0.60, w * 0.56, h * 0.40)
      ..quadraticBezierTo(w * 0.80, h * 0.20, w + 8, h * 0.50);

    // Per mode: the wide glow's colour and [edge, middle] alphas, the core
    // line's colour and alphas, and how far in from the edges it fades.
    final Color glow;
    final Color line;
    final List<double> glowA;
    final List<double> lineA;
    final List<double> stops;
    if (night) {
      glow = PauseScreen.moonBody;
      line = PauseScreen.moonCore;
      glowA = const [0.10, 0.26];
      lineA = const [0.18, 0.62];
      stops = const [0.0, 0.30, 0.5, 0.70, 1.0];
    } else if (warmSky) {
      // The sky's own hue, saturated into a sunset band: visible against
      // a pale warm sky by saturation, where white has no contrast left
      // and a darker tone only smudges. Same two strokes as the night
      // version — the structure the founder pointed at — different glow.
      // Pulled toward rose first: the beige skies (warmClay, sandDune)
      // sit near 38° and saturate to gold, and gold is the one colour this
      // app's light must never be. Rose-peach keeps it in the pebble's
      // own family on every warm theme.
      final skyHue = HSLColor.fromColor(sky).hue;
      final signedHue = skyHue > 330 ? skyHue - 360 : skyHue;
      final roseHue = (signedHue * 0.4 + 12 * 0.6 + 360) % 360;
      glow = HSLColor.fromAHSL(1, roseHue, 0.72, 0.70).toColor();
      line = const Color(0xFFFFFFFF);
      glowA = const [0.26, 0.50];
      lineA = const [0.45, 1.0];
      stops = const [0.0, 0.22, 0.5, 0.78, 1.0];
    } else {
      glow = PauseScreen.sunBody;
      line = PauseScreen.sunCore;
      glowA = const [0.42, 0.80];
      lineA = const [0.45, 1.0];
      stops = const [0.0, 0.15, 0.5, 0.85, 1.0];
    }
    ui.Shader along(Color c, List<double> a) => ui.Gradient.linear(
          Offset.zero,
          Offset(w, 0),
          [
            c.withValues(alpha: 0),
            c.withValues(alpha: a[0]),
            c.withValues(alpha: a[1]),
            c.withValues(alpha: a[0]),
            c.withValues(alpha: 0),
          ],
          stops,
        );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.80
        ..shader = along(glow, glowA)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.14
        ..shader = along(line, lineA)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(_HorizonPainter old) =>
      old.night != night || old.warmSky != warmSky || old.sky != sky;
}

/// The home screen's door to the Pause: the entry line riding a horizon of
/// the same warm light the screen behind it breathes, so the door and the
/// room share one thread. Centered and letterspaced like a whisper, sitting
/// between the date and the day's actions as a threshold — sky, not
/// furniture — and sized to absorb the header's whitespace rather than add
/// to it, so a pinned habit loses nothing. The tap target is the full band.
class PauseDoor extends StatelessWidget {
  const PauseDoor({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.theme.isDark;
    final colors = themeProvider.colors;
    final warmSky = PauseScreen.brightWarmSky(colors);
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          Navigator.of(context).push(PauseScreen.route(entry: 'home')),
      child: SizedBox(
        // The light lives in the upper part; the lower 8–10pt are air, so
        // the section label under it belongs to its card, not to the door.
        height: 56,
        width: double.infinity,
        child: Stack(
          alignment: const Alignment(0, -0.2),
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HorizonPainter(
                    night: isDark,
                    warmSky: warmSky,
                    sky: colors.onboardingBg2),
              ),
            ),
            Text(
              l10n.pauseEntryTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 3.0,
                // Ink to match the light it sits on, leaning on the theme's
                // own text colour for contrast — dusty rose on a rose sky
                // (softDusk) was the weakest text in the nine-theme sweep.
                color: isDark
                    ? PauseScreen.moonBody
                    : Color.lerp(PauseScreen.sunInk, colors.textPrimary,
                        warmSky ? 0.45 : 0.2)!,
                fontFamily: AppTextStyles.bodyFont(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The contextual Health soft-ask. A sheet in the app's own voice before any
/// system dialog: the system sheet appears only after an explicit yes, so
/// nobody meets an OS permission prompt they didn't invite.
class _HealthAskSheet extends StatelessWidget {
  const _HealthAskSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.modalBg1, colors.modalBg2],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pauseHealthTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.pauseHealthBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(context)
                  .copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size.zero,
                borderRadius: BorderRadius.circular(18),
                color: colors.buttonDark,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  l10n.pauseHealthSave,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.buttonText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            CupertinoButton(
              minimumSize: const Size(44, 44),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.commonNotNow,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
