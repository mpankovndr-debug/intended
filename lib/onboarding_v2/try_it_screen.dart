import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/chapter.dart';
import '../models/moment.dart';
import '../screens/habit_completion_modal.dart' show HabitCompletionModal;
import '../services/analytics_service.dart';
import '../services/completion_service.dart';
import '../services/moments_service.dart';
import '../theme/category_colors.dart';
import '../theme/category_glyphs.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
import '../utils/text_styles.dart';
import '../widgets/moment_tile.dart';
import 'onboarding_state.dart';
import 'widgets/blur.dart';
import 'widgets/onboarding_scaffold.dart';

/// Onboarding screen 7, "Try it" (spec §6): the first real moment. Tapping
/// an action records a real completion, and its tile flies into the
/// person's own month and lands with a glow, one faint ghost tile after it.
///
/// A real moment, not a demo: people value what they made only when they
/// finish it, and a demo tile thrown away and then repeated asks for the
/// same tap twice (spec §6, Norton, Mochon & Ariely 2012).
///
/// [onContinue] says whether a moment was recorded. With one, the paywall
/// follows (screen 8); without, the first completion on Today brings it,
/// as before.
class TryItScreen extends StatefulWidget {
  const TryItScreen({
    super.key,
    required this.onContinue,
    this.onBack,
    this.now,
  });

  final ValueChanged<bool> onContinue;
  final VoidCallback? onBack;
  final DateTime Function()? now;

  static const Duration landing = Duration(milliseconds: 1600);

  /// "That's the first square of your chapter." is said only when the
  /// chapter the sentence opens really holds the moment's day.
  static bool opensChapter(Chapter chapter, Moment moment) =>
      chapter.stageOn(moment.localDay) != null;

  /// The moment this screen already recorded, for someone who went back and
  /// returned: the latest one for these actions since the sentence was
  /// sealed. Coming back shows it landed rather than asking for another.
  static Moment? alreadyRecorded(
    List<Moment> all,
    List<String> actions,
    DateTime? sealedAt,
  ) {
    if (sealedAt == null) return null;
    Moment? latest;
    for (final m in all) {
      if (!actions.contains(m.habitName)) continue;
      if (m.completedAt.isBefore(sealedAt)) continue;
      if (latest == null || m.completedAt.isAfter(latest.completedAt)) {
        latest = m;
      }
    }
    return latest;
  }

  @override
  State<TryItScreen> createState() => _TryItScreenState();
}

class _TryItScreenState extends State<TryItScreen>
    with SingleTickerProviderStateMixin {
  late final List<String> _actions;
  late final AnimationController _land;
  final _scroll = ScrollController();
  final _stackKey = GlobalKey();
  final _slotKey = GlobalKey();
  final _captionKey = GlobalKey();
  final Map<String, GlobalKey> _glyphKeys = {};

  String? _done;
  Moment? _moment;
  List<String?> _tiles = const [];
  Rect? _from;
  Rect? _to;
  bool _landed = false;

  // Beats, as fractions of [TryItScreen.landing].
  static const _sheet = Interval(0.0, 0.25, curve: Curves.easeOut);
  static const _flight = Interval(0.15, 0.6, curve: Curves.easeInOutCubic);
  static const _glowIn = Interval(0.6, 0.7, curve: Curves.easeOut);
  static const _glowSettle = Interval(0.7, 1.0, curve: Curves.easeInOut);
  static const _ghost = Interval(0.7, 0.85, curve: Curves.easeOut);
  static const _caption = Interval(0.78, 1.0, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingState>();
    _actions = List.of(state.userHabits);
    for (final a in _actions) {
      _glyphKeys[a] = GlobalKey();
    }
    _land = AnimationController(vsync: this, duration: TryItScreen.landing)
      ..addListener(_onTick);

    MomentsService.getAll().then((all) async {
      final earlier =
          TryItScreen.alreadyRecorded(all, _actions, state.sentenceSealedAt);
      if (earlier == null || !mounted) return;
      final tiles =
          await MomentsService.categoriesForMonth(earlier.localWallClock);
      if (!mounted) return;
      setState(() {
        _done = earlier.habitName;
        _moment = earlier;
        _tiles = tiles;
        _landed = true;
      });
      _land.value = 1;
    });
  }

  @override
  void dispose() {
    _land.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!_landed && _land.value >= _flight.end) {
      _landed = true;
      HapticFeedback.lightImpact();
    }
    setState(() {});
  }

  Future<void> _do(String action) async {
    if (_done != null) return;
    HapticFeedback.mediumImpact();
    setState(() => _done = action);

    final moment = await CompletionService.record(action);
    final tiles =
        await MomentsService.categoriesForMonth(moment.localWallClock);
    if (!mounted) return;
    setState(() {
      _moment = moment;
      _tiles = tiles;
    });

    // The sheet is laid out now: bring it into view if a long list pushed
    // it under the button, then measure where the tile flies from and to.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final still = MediaQuery.of(context).disableAnimations;
      await _bringIntoView(still);
      if (!mounted) return;
      _from = _rectOf(_glyphKeys[action]!);
      _to = _rectOf(_slotKey);
      if (still || _from == null || _to == null) {
        _landed = true;
        _land.value = 1;
      } else {
        _land.forward();
      }
    });
  }

  Future<void> _bringIntoView(bool still) async {
    final caption = _captionKey.currentContext?.findRenderObject();
    final stack = _stackKey.currentContext?.findRenderObject();
    if (caption is! RenderBox || stack is! RenderBox) return;
    final bottom = caption
        .localToGlobal(Offset(0, caption.size.height), ancestor: stack)
        .dy;
    final limit =
        stack.size.height - OnboardingScaffold.contentBottomPadding + 32;
    if (bottom <= limit || !_scroll.hasClients) return;
    final target = (_scroll.offset + bottom - limit)
        .clamp(0.0, _scroll.position.maxScrollExtent);
    if (still) {
      _scroll.jumpTo(target);
    } else {
      await _scroll.animateTo(target,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    final stack = _stackKey.currentContext?.findRenderObject();
    if (box is! RenderBox || stack is! RenderBox) return null;
    return box.localToGlobal(Offset.zero, ancestor: stack) & box.size;
  }

  void _finish(bool recorded) {
    AnalyticsService.logOnboardingStepCompleted('try_it');
    widget.onContinue(recorded);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors;
    final body = AppTextStyles.bodyFont(context);
    final t = _land.value;
    final flight = _flight.transform(t);
    final flying = _land.isAnimating && _from != null && _to != null;
    final glow = t < _glowIn.begin
        ? 0.0
        : t < _glowSettle.begin
            ? _glowIn.transform(t)
            : 1 - 0.55 * _glowSettle.transform(t);
    final moment = _moment;
    final category = _done == null ? null : state.getCategoryForHabit(_done!);
    final tint = CategoryColors.of(category, theme.theme);

    return OnboardingScaffold(
      step: 3,
      onBack: widget.onBack,
      title: l10n.onboardingTryTitle,
      subtitle: l10n.onboardingTrySubtitle,
      ctaLabel: l10n.commonContinue,
      onCta: moment == null ? null : () => _finish(true),
      // Kept in place once a moment lands, only hidden, so the button above
      // does not jump.
      footer: IgnorePointer(
        ignoring: _done != null,
        child: AnimatedOpacity(
          opacity: _done == null ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(44, 36),
            onPressed: () => _finish(false),
            child: Text(
              l10n.onboardingTryLater,
              style: TextStyle(
                fontFamily: body,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
      child: Stack(
        key: _stackKey,
        children: [
          Positioned.fill(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                  24, 28, 24, OnboardingScaffold.contentBottomPadding),
              children: [
                for (final action in _actions) ...[
                  _TryCard(
                    action: action,
                    category: state.getCategoryForHabit(action),
                    glyphKey: _glyphKeys[action]!,
                    done: _done == action,
                    dimmed: _done != null && _done != action,
                    onTap: () => _do(action),
                  ),
                  const SizedBox(height: 10),
                ],
                if (moment != null) ...[
                  const SizedBox(height: 14),
                  BlurVeil(
                    amount: 1 - _sheet.transform(t),
                    child: _Sheet(
                      tiles: _tiles,
                      slotKey: _slotKey,
                      showNewest: _landed,
                      glow: glow,
                      ghost: _ghost.transform(t),
                    ),
                  ),
                  const SizedBox(height: 18),
                  BlurAppear(
                    amount: _caption.transform(t),
                    child: Column(
                      key: _captionKey,
                      children: [
                        if (TryItScreen.opensChapter(
                            state.previewChapter(now: widget.now), moment))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              l10n.onboardingTryFirst,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: body,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        Text(
                          l10n.onboardingTryReturn,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: body,
                            fontSize: 14,
                            height: 1.45,
                            color: colors.textPrimary.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (flying && !_landed) _flyingTile(_from!, _to!, flight, tint),
        ],
      ),
    );
  }

  /// The tile on its way from the action's glyph to its place in the month:
  /// a gentle curve, growing from the glyph's size to a tile's.
  Widget _flyingTile(Rect from, Rect to, double p, Color color) {
    final size = 20 + (to.width - 20) * p;
    // Bowed across the path, not above it: the path mostly runs down the
    // screen, and an upward arc on a downward path reads as a hesitation.
    final path = to.center - from.center;
    final across = path.distance == 0
        ? Offset.zero
        : Offset(path.dy, -path.dx) / path.distance;
    final center = Offset.lerp(from.center, to.center, p)! +
        across * (40 * math.sin(math.pi * p));
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: IgnorePointer(
        child: MomentTile(color: color, size: size, glow: 0.35),
      ),
    );
  }
}

class _TryCard extends StatelessWidget {
  const _TryCard({
    required this.action,
    required this.category,
    required this.glyphKey,
    required this.done,
    required this.dimmed,
    required this.onTap,
  });

  final String action;
  final String? category;
  final GlobalKey glyphKey;
  final bool done;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors;
    final tint = CategoryColors.of(category, theme.theme);
    final name = localizeHabitName(action, AppLocalizations.of(context));

    return Semantics(
      button: true,
      selected: done,
      label: name,
      excludeSemantics: true,
      child: AnimatedOpacity(
        // Dimmed, never removed (CLAUDE.md): the other actions are still
        // theirs, just not the one done now.
        opacity: dimmed ? 0.38 : 1,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: done
                  ? Color.alphaBlend(tint.withValues(alpha: 0.28),
                      const Color(0xFFFFFFFF).withValues(alpha: 0.7))
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.55),
              border: Border.all(
                color: done
                    ? tint.withValues(alpha: 0.7)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.7),
                width: done ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Image.asset(CategoryGlyphs.of(category),
                    key: glyphKey, width: 32, height: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: done ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tint,
                    ),
                    child: const Icon(CupertinoIcons.checkmark,
                        size: 14, color: Color(0xFFFFFFFF)),
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

/// The person's month so far, in a small glass sheet: their tiles, the new
/// one landing in the next spot, and exactly one faint ghost after it
/// (spec §6). Never a row of empty slots.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.tiles,
    required this.slotKey,
    required this.showNewest,
    required this.glow,
    required this.ghost,
  });

  final List<String?> tiles;
  final GlobalKey slotKey;
  final bool showNewest;
  final double glow;
  final double ghost;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final shown = tiles.length > HabitCompletionModal.maxTilesShown
        ? tiles.sublist(tiles.length - HabitCompletionModal.maxTilesShown)
        : tiles;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.45),
          border:
              Border.all(color: const Color(0xFFFFFFFF).withValues(alpha: 0.7)),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < shown.length; i++)
              if (i < shown.length - 1)
                MomentTile(color: CategoryColors.of(shown[i], theme.theme))
              else
                SizedBox(
                  key: slotKey,
                  width: 26,
                  height: 26,
                  child: showNewest
                      ? MomentTile(
                          color: CategoryColors.of(shown[i], theme.theme),
                          glow: glow,
                        )
                      : null,
                ),
            // One faint, solid ghost: where the next one goes. Never
            // outlined, never more than one.
            Opacity(
              opacity: ghost,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colors.textPrimary.withValues(alpha: 0.07),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
