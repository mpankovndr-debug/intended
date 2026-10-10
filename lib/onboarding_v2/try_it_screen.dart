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
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
import '../utils/responsive_utils.dart';
import '../utils/text_styles.dart';
import '../widgets/moment_tile.dart';
import 'onboarding_state.dart';
import 'widgets/blur.dart';
import 'widgets/onboarding_scaffold.dart';

/// Onboarding screen 7, "Try it" (spec §6): the first real moment. Tapping
/// an action records a real completion. The card turns into Today's done
/// card, its tile swells for a beat, then flies into the person's own month
/// and lands with a glow, one faint ghost tile after it (decided 1 Oct).
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

  static const Duration landing = Duration(milliseconds: 2000);

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
  final Map<String, GlobalKey> _tileKeys = {};

  String? _done;
  Moment? _moment;
  List<String?> _tiles = const [];
  Rect? _from;
  Rect? _to;
  bool _landed = false;

  // Beats, as fractions of [TryItScreen.landing]. The tile appears on the
  // card as Today shows it, swells, holds for a breath, then flies; the
  // card keeps a tile of its own, as a done card on Today does.
  static const _appear = Interval(0.0, 0.08, curve: Curves.easeOutBack);
  static const _swell = Interval(0.08, 0.22, curve: Curves.easeOutCubic);
  static const _sheet = Interval(0.18, 0.36, curve: Curves.easeOut);
  static const _flight = Interval(0.28, 0.66, curve: Curves.easeInOutCubic);
  static const _refill = Interval(0.4, 0.56, curve: Curves.easeOut);
  static const _glowIn = Interval(0.66, 0.74, curve: Curves.easeOut);
  static const _glowSettle = Interval(0.74, 1.0, curve: Curves.easeInOut);
  static const _ghost = Interval(0.76, 0.88, curve: Curves.easeOut);
  static const _caption = Interval(0.82, 1.0, curve: Curves.easeOut);

  /// How much larger the tile grows before it flies.
  static const double _swollen = 1.8;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingState>();
    _actions = List.of(state.userHabits);
    for (final a in _actions) {
      _tileKeys[a] = GlobalKey();
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
      _from = _rectOf(_tileKeys[action]!);
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

    // The tile on the done card: in, swollen, gone while it flies, then
    // back at its size as the card keeps its own.
    final double cardTileScale;
    final double cardTileOpacity;
    if (t < _swell.begin) {
      cardTileScale = _appear.transform(t);
      cardTileOpacity = 1;
    } else if (t < _flight.begin) {
      cardTileScale = 1 + (_swollen - 1) * _swell.transform(t);
      cardTileOpacity = 1;
    } else {
      cardTileScale = 1;
      cardTileOpacity = _refill.transform(t);
    }
    final cardTileLift = t < _flight.begin ? _swell.transform(t) : 0.0;

    return OnboardingScaffold(
      place: OnboardingPlace.tryIt,
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
                    tileKey: _tileKeys[action]!,
                    done: _done == action,
                    dimmed: _done != null && _done != action,
                    tileScale: cardTileScale,
                    tileOpacity: cardTileOpacity,
                    tileLift: cardTileLift,
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
          if (flying && !_landed && t >= _flight.begin)
            _flyingTile(_from!, _to!, flight, category, theme.theme),
        ],
      ),
    );
  }

  /// The swollen tile on its way from the card to its place in the month:
  /// a gentle curve, settling to a tile's size and to the month's colour.
  Widget _flyingTile(
      Rect from, Rect to, double p, String? category, AppTheme theme) {
    final size = to.width * (_swollen + (1 - _swollen) * p);
    // Bowed across the path, not above it: the path mostly runs down the
    // screen, and an upward arc on a downward path reads as a hesitation.
    final path = to.center - from.center;
    final across = path.distance == 0
        ? Offset.zero
        : Offset(path.dy, -path.dx) / path.distance;
    final center = Offset.lerp(from.center, to.center, p)! +
        across * (40 * math.sin(math.pi * p));
    final color = Color.lerp(CategoryColors.onCard(category, theme),
        CategoryColors.of(category, theme), p)!;
    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: IgnorePointer(
        child: MomentTile(color: color, size: size, glow: 1 - 0.65 * p),
      ),
    );
  }
}

/// An action as Today shows it (decided 1 Oct: no new card for onboarding).
/// Pending: the glass card with its accent bar. Done: a wash and outline in
/// the action's focus-area colour, the bar in that colour too, and the tile
/// on the right, with no checkmark. Mirrors `_HabitCard` in `main.dart`;
/// keep the two in step until that card is extracted.
class _TryCard extends StatelessWidget {
  const _TryCard({
    required this.action,
    required this.category,
    required this.tileKey,
    required this.done,
    required this.dimmed,
    required this.tileScale,
    required this.tileOpacity,
    required this.tileLift,
    required this.onTap,
  });

  final String action;
  final String? category;
  final GlobalKey tileKey;
  final bool done;
  final bool dimmed;
  final double tileScale;
  final double tileOpacity;

  /// 0 to 1: the extra light on the tile as it swells before flying.
  final double tileLift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final colors = provider.colors;
    final isDark = provider.theme.isDark;
    final l10n = AppLocalizations.of(context);
    final onCard = CategoryColors.onCard(category, provider.theme);
    final glass =
        colors.profileCard.withValues(alpha: colors.profileCardOpacity);
    final name = localizeHabitName(action, l10n);

    return Semantics(
      button: !done,
      label: done ? l10n.a11yHabitCardDone(name) : l10n.a11yHabitCardTodo(name),
      excludeSemantics: true,
      child: AnimatedOpacity(
        // Dimmed, never removed (CLAUDE.md): the other actions are still
        // theirs, just not the one done now.
        opacity: dimmed ? 0.38 : 1,
        duration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: done ? null : glass,
                gradient: done
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.alphaBlend(
                              onCard.withValues(alpha: isDark ? 0.13 : 0.18),
                              glass),
                          Color.alphaBlend(
                              onCard.withValues(alpha: isDark ? 0.05 : 0.07),
                              glass),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: done
                      ? onCard.withValues(alpha: 0.35)
                      : isDark
                          ? colors.borderCard
                              .withValues(alpha: colors.borderCardOpacity)
                          : const Color(0xFFFFFFFF).withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary
                        .withValues(alpha: done ? 0.02 : 0.04),
                    blurRadius: done ? 8 : 16,
                    offset: Offset(0, done ? 1 : 2),
                  ),
                  if (!done)
                    BoxShadow(
                      color: const Color(0xFFFFFFFF)
                          .withValues(alpha: isDark ? 0.18 : 0.25),
                      blurRadius: isDark ? 0.5 : 1,
                      offset: const Offset(0, 1),
                      blurStyle: BlurStyle.inner,
                    ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 26,
                    decoration: BoxDecoration(
                      color: done ? onCard : colors.accentRegular,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont(context),
                        // Today's own size; the flow's background has
                        // already initialised the scale.
                        fontSize: Responsive.sp(16),
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (done) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      key: tileKey,
                      width: 26,
                      height: 26,
                      child: Opacity(
                        opacity: tileOpacity,
                        child: Transform.scale(
                          scale: tileScale,
                          child: _CardTile(color: onCard, lift: tileLift),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The tile on a done card, exactly as Today draws it, with [lift] adding
/// light while it swells before flying.
class _CardTile extends StatelessWidget {
  const _CardTile({required this.color, required this.lift});

  final Color color;
  final double lift;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final lit =
        hsl.withLightness((hsl.lightness + 0.07).clamp(0.0, 1.0)).toColor();
    final shade =
        hsl.withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0)).toColor();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lit, color, shade],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45 + 0.35 * lift),
            blurRadius: 14 + 10 * lift,
            spreadRadius: 1 + 2 * lift,
          ),
        ],
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
