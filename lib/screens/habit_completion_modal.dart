import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../services/analytics_service.dart';
import '../services/moments_service.dart';
import '../theme/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/category_colors.dart';
import '../theme/category_glyphs.dart';
import '../utils/habit_l10n.dart';
import '../utils/text_styles.dart';

/// The completion sheet, in two steps (§5.2).
///
/// The old "Did you do this today?" confirmation is gone: nobody taps a habit
/// card by accident, so asking was friction phrased as an interrogation. By
/// the time this opens the moment is already recorded — this sheet only asks
/// how it landed, then shows where it went.
///
/// Step 2 is the part that teaches the whole system. The tile animating in at
/// the end of the row is what explains that completions accumulate into a
/// month; a static row would just be a row. If the animation is ever dropped,
/// drop the row with it and use words only.
///
/// The mood pills select; Done submits. The pills used to submit on tap,
/// which made mood-then-note — the order everyone reaches for — impossible,
/// and left a tiny "skip" a thumb-width from "add a note". Done with nothing
/// selected *is* the skip, so the skip link no longer exists to mis-tap.
class HabitCompletionModal extends StatefulWidget {
  const HabitCompletionModal({
    super.key,
    required this.habitTitle,
    required this.momentId,
    required this.category,
    required this.monthCategories,
    required this.completedAt,
  });

  final String habitTitle;
  final String momentId;
  final String? category;

  /// Categories of this month's moments, oldest first, including the one just
  /// recorded as the final entry — that last tile is the one that animates in.
  final List<String?> monthCategories;

  final DateTime completedAt;

  /// Most recent tiles shown in the step-2 row. Enough to feel like an
  /// accumulation, few enough to stay one glance.
  static const int maxTilesShown = 24;

  @override
  State<HabitCompletionModal> createState() => _HabitCompletionModalState();
}

class _HabitCompletionModalState extends State<HabitCompletionModal>
    with TickerProviderStateMixin {
  late final AnimationController _tileController;
  late final Animation<double> _tileScale;
  late final Animation<double> _glow;

  bool _showStep2 = false;
  bool _noteOpen = false;
  bool _tileLanded = false;

  /// Set once Done has written mood + note. Guards the dispose-time
  /// save below from writing a second time.
  bool _annotated = false;
  MomentMood? _mood;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tileController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    // One light tap at the overshoot apex (~55% of the tween), so the body
    // feels the tile land in the month. Light, not medium: Done already
    // fired medium, and two equal impacts in a second read as a stutter.
    _tileController.addListener(() {
      if (!_tileLanded && _tileController.value >= 0.55) {
        _tileLanded = true;
        HapticFeedback.lightImpact();
      }
    });
    // Overshoot slightly so the tile lands rather than merely appears.
    _tileScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
    ]).animate(_tileController);
    // Glow blooms with the landing, then fades — a held glow would read as an
    // alert rather than a moment of arrival.
    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 65,
      ),
    ]).animate(_tileController);
  }

  @override
  void dispose() {
    // A note typed and then dismissed by tapping the barrier used to vanish:
    // the moment was already recorded, so there was no second chance to
    // attach it. Fire-and-forget is safe here — annotate only touches
    // storage, never this context. The mood needs no salvage: it was
    // persisted on tap. Log it here so analytics matches storage.
    if (!_annotated) {
      if (_mood != null) {
        AnalyticsService.logMoodResponse(_mood!.key);
      }
      if (_noteController.text.trim().isNotEmpty) {
        MomentsService.annotate(widget.momentId, note: _noteController.text);
      }
    }
    _tileController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _pickMood(MomentMood mood) {
    if (_showStep2) return;
    HapticFeedback.selectionClick();
    setState(() => _mood = mood);
    // Persisted on tap, not on Done: the sheet is barrier-dismissible, and
    // an answer given then swiped away should still count. `annotate` keeps
    // the old mood when passed null, so switching pills simply overwrites —
    // there is no deselect back to none.
    MomentsService.annotate(widget.momentId, mood: mood);
  }

  Future<void> _submit() async {
    if (_showStep2) return;
    HapticFeedback.mediumImpact();
    AnalyticsService.logMoodResponse(_mood?.key);
    setState(() => _showStep2 = true);

    _annotated = true;
    await MomentsService.annotate(
      widget.momentId,
      mood: _mood,
      note: _noteController.text,
    );

    if (!mounted) return;
    await _tileController.forward();
    // Let the landing settle before the sheet leaves.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    // `mounted` is not enough: the sheet is barrier-dismissible, and a State
    // stays mounted for the whole exit transition. A pop fired then would
    // land on the route *below* — in the first session that route is
    // MainTabs, and the user would be thrown back into leftover onboarding.
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.of(context).pop();
  }

  String _timeLabel() {
    final local = widget.completedAt.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    // Follow the device's clock convention: «10:57 PM» on an otherwise
    // Russian sheet reads as foreign as an untranslated word would.
    if (MediaQuery.of(context).alwaysUse24HourFormat) {
      return '${local.hour}:$minute';
    }
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final suffix = local.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  String? _moodLabel(AppLocalizations l10n) => switch (_mood) {
        MomentMood.gladIDid => l10n.completionMoodGlad,
        MomentMood.neutral => l10n.completionMoodNeutral,
        MomentMood.tookEffort => l10n.completionMoodTookEffort,
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final theme = themeProvider.theme;

    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: GestureDetector(
        // Anywhere in the sheet, not just the return key — the iOS habit.
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(28),
                // Volume (design review): flat against the dimmed backdrop the
                // sheet read as a label, not an object. A drop shadow below
                // and a hairline of light along the top edge lift it off.
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.55),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.18),
                    blurRadius: 36,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.30),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: _showStep2
                  ? _buildStep2(l10n, colors, theme)
                  : _buildStep1(l10n, colors),
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l10n, AppColorScheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step 1 only: step 2's hero is the landing tile, and on small
        // phones the sheet plus keyboard needs the height back.
        Image.asset(
          CategoryGlyphs.of(widget.category),
          width: 54,
          height: 54,
        ),
        const SizedBox(height: 8),
        Text(
          // The stored name is a canonical English ID; render through the
          // resolver or a Russian sheet shows the raw English string.
          localizeHabitName(widget.habitTitle, l10n),
          textAlign: TextAlign.center,
          style: AppTextStyles.h2(context),
        ),
        const SizedBox(height: 6),
        Text(
          _timeLabel(),
          style: AppTextStyles.body(context).copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: colors.textDisabled.withValues(alpha: 0.3)),
        const SizedBox(height: 20),
        Text(
          l10n.completionHowDidItLand,
          style: AppTextStyles.body(context).copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        // IntrinsicHeight + stretch: «Было непросто» wraps to two lines and
        // its pill towered over the other two until all three shared height.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _moodPill(l10n.completionMoodGlad, MomentMood.gladIDid, colors)),
              const SizedBox(width: 8),
              Expanded(child: _moodPill(l10n.completionMoodNeutral, MomentMood.neutral, colors)),
              const SizedBox(width: 8),
              Expanded(child: _moodPill(l10n.completionMoodTookEffort, MomentMood.tookEffort, colors)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_noteOpen)
          CupertinoTextField(
            controller: _noteController,
            maxLength: Moment.maxNoteLength,
            maxLines: 3,
            minLines: 1,
            autofocus: true,
            // Return closes the keyboard instead of adding a line: the
            // keyboard can cover the Done button, and a 280-character note
            // doesn't need paragraphs; it needs a door.
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            placeholder: l10n.completionNoteHint,
            style: AppTextStyles.body(context),
            decoration: BoxDecoration(
              color: _themedFill(colors).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          )
        else
          // A full-width outlined target, not a text link: the old link sat
          // millimetres above "skip" and the two were routinely confused.
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => setState(() => _noteOpen = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Color.lerp(
                    colors.textDisabled,
                    colors.ctaPrimary,
                    0.3,
                  )!
                      .withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.pencil,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.completionAddNote,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        // Deliberately quiet — the same tint as an unselected pill, so the
        // darkest thing on the sheet is the mood the user chose, not the
        // exit. A dark primary button here shouted over the answer.
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: Size.zero,
            borderRadius: BorderRadius.circular(18),
            color: _themedFill(colors).withValues(alpha: 0.55),
            onPressed: _submit,
            child: Text(
              l10n.commonDone,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Quiet fills lean toward the theme's own hue: bgGradientTop faded over
  /// the near-white card washes out to grey. 12% of ctaPrimary restores the
  /// tint (violet, blue, warm) without competing with the selected pill.
  Color _themedFill(AppColorScheme colors) =>
      Color.lerp(colors.bgGradientTop, colors.ctaPrimary, 0.12)!;

  Widget _moodPill(String label, MomentMood mood, AppColorScheme colors) {
    final selected = _mood == mood;
    final fg = selected ? colors.buttonText : colors.textPrimary;
    // Words only, no faces: a frown on "took effort" graded hard-but-worth-it
    // as a wrong answer, which is the judgement this worth scale exists to
    // avoid (see MomentMood). The month grid already carries the answer as
    // a tint; the pill needs nothing but its label.
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(16),
      color: selected
          ? colors.buttonDark
          : _themedFill(colors).withValues(alpha: 0.55),
      onPressed: () => _pickMood(mood),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildStep2(
    AppLocalizations l10n,
    AppColorScheme colors,
    AppTheme theme,
  ) {
    final tiles = widget.monthCategories.length > HabitCompletionModal.maxTilesShown
        ? widget.monthCategories
            .sublist(widget.monthCategories.length - HabitCompletionModal.maxTilesShown)
        : widget.monthCategories;
    final total = widget.monthCategories.length;
    final moodLabel = _moodLabel(l10n);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _tileController,
          builder: (context, _) {
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < tiles.length; i++)
                  _tile(
                    tiles[i],
                    theme,
                    isNewest: i == tiles.length - 1,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          localizeHabitName(widget.habitTitle, l10n),
          textAlign: TextAlign.center,
          style: AppTextStyles.h2(context),
        ),
        const SizedBox(height: 6),
        Text(
          moodLabel == null ? _timeLabel() : '${_timeLabel()} · $moodLabel',
          style: AppTextStyles.body(context).copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          total <= 1 ? l10n.completionKeptOne : l10n.completionKept(total),
          textAlign: TextAlign.center,
          style: AppTextStyles.body(context).copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _tile(String? category, AppTheme theme, {required bool isNewest}) {
    final color = CategoryColors.of(category, theme);
    final scale = isNewest ? _tileScale.value : 1.0;
    final glow = isNewest ? _glow.value : 0.0;
    // The grid's own inner gradient, so the tile that lands here is literally
    // the tile the month page shows.
    final hsl = HSLColor.fromColor(color);
    final lit =
        hsl.withLightness((hsl.lightness + 0.07).clamp(0.0, 1.0)).toColor();
    final shade =
        hsl.withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0)).toColor();

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lit, color, shade],
            stops: const [0.0, 0.55, 1.0],
          ),
          borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}
