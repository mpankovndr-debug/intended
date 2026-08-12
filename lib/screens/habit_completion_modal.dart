import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../services/moments_service.dart';
import '../theme/theme_provider.dart';
import '../theme/app_colors.dart';
import '../theme/category_colors.dart';
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
  MomentMood? _mood;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tileController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
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
    _tileController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectMood(MomentMood? mood) async {
    if (_showStep2) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _mood = mood;
      _showStep2 = true;
    });

    await MomentsService.annotate(
      widget.momentId,
      mood: mood,
      note: _noteController.text,
    );

    if (!mounted) return;
    await _tileController.forward();
    // Let the landing settle before the sheet leaves.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.of(context).maybePop();
  }

  String _timeLabel() {
    final local = widget.completedAt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
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
    );
  }

  Widget _buildStep1(AppLocalizations l10n, AppColorScheme colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.habitTitle,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: _moodPill(l10n.completionMoodGlad, MomentMood.gladIDid, colors)),
            const SizedBox(width: 8),
            Expanded(child: _moodPill(l10n.completionMoodNeutral, MomentMood.neutral, colors)),
            const SizedBox(width: 8),
            Expanded(child: _moodPill(l10n.completionMoodTookEffort, MomentMood.tookEffort, colors)),
          ],
        ),
        const SizedBox(height: 18),
        if (_noteOpen)
          CupertinoTextField(
            controller: _noteController,
            maxLength: Moment.maxNoteLength,
            maxLines: 3,
            minLines: 1,
            autofocus: true,
            placeholder: l10n.completionNoteHint,
            style: AppTextStyles.body(context),
            decoration: BoxDecoration(
              color: colors.bgGradientTop.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          )
        else
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => setState(() => _noteOpen = true),
            child: Text(
              l10n.completionAddNote,
              style: AppTextStyles.body(context).copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => _selectMood(null),
          child: Text(
            l10n.completionSkip,
            style: AppTextStyles.body(context).copyWith(
              fontSize: 14,
              color: colors.textDisabled,
            ),
          ),
        ),
      ],
    );
  }

  Widget _moodPill(String label, MomentMood mood, AppColorScheme colors) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(16),
      color: colors.bgGradientTop.withValues(alpha: 0.55),
      onPressed: () => _selectMood(mood),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
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
          widget.habitTitle,
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
