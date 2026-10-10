import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import '../models/start_small.dart';
import '../services/analytics_service.dart';
import '../theme/category_colors.dart';
import '../theme/category_glyphs.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
import '../utils/text_styles.dart';
import 'onboarding_state.dart';
import 'widgets/onboarding_scaffold.dart';

/// Onboarding, screen 4 (spec §6): start small.
///
/// The path's own actions, then its focus areas' catalogue. The first
/// chapter's length suggests how many: three, or two when month 1 is under
/// three weeks ("You have 16 days until October"). It is a suggestion, not
/// a limit (decided 30 Sep): a person may pick more. The only cap is how
/// many actions Today holds, and it is said out loud when reached.
class StartSmallScreen extends StatefulWidget {
  const StartSmallScreen({
    super.key,
    required this.onContinue,
    this.onBack,
    this.now,
  });

  /// Called once the choice is saved. The flow decides what comes next.
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  /// The clock, for when no sentence has been sealed yet (tests, renders).
  final DateTime Function()? now;

  @override
  State<StartSmallScreen> createState() => _StartSmallScreenState();
}

class _StartSmallScreenState extends State<StartSmallScreen> {
  /// Chosen actions, in the order they were chosen.
  final _chosen = <String>[];
  bool _atCap = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Coming back keeps what was chosen.
    final state = context.read<OnboardingState>();
    _chosen
        .addAll(state.userHabits.where((h) => !state.customHabits.contains(h)));
  }

  IntentionPath _path(OnboardingState state) => IntentionPath.getById(
      IntentionPathId.fromKey(state.selectedIntentionPath));

  /// What is on offer, plus anything chosen that no longer is (after a focus
  /// change): a chosen action is never hidden (CLAUDE.md).
  List<String> _shown(OnboardingState state) {
    final path = _path(state);
    final offered = StartSmall.candidates(
      path: path,
      focusAreas:
          state.focusAreas.isEmpty ? path.defaultFocusAreas : state.focusAreas,
      catalogue: OnboardingState.habitsByCategory,
    );
    return [
      ..._chosen.where((a) => !offered.contains(a)),
      ...offered,
    ];
  }

  void _toggle(String action) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_chosen.remove(action)) {
        _atCap = false;
      } else if (_chosen.length >= OnboardingState.maxActiveHabits) {
        _atCap = true;
      } else {
        _chosen.add(action);
      }
    });
  }

  Future<void> _continue() async {
    if (_saving || _chosen.isEmpty) return;
    _saving = true;
    HapticFeedback.mediumImpact();
    await context.read<OnboardingState>().adoptChosenActions(List.of(_chosen));
    AnalyticsService.logOnboardingStepCompleted('start_small');
    _saving = false;
    if (mounted) widget.onContinue();
  }

  Future<void> _changeFocus() async {
    HapticFeedback.selectionClick();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => const _FocusSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final colors = context.watch<ThemeProvider>().colors;
    final locale = Localizations.localeOf(context).toString();
    final chapter = state.previewChapter(now: widget.now);
    final short = chapter.suggestedFirstActions < 3;
    final shown = _shown(state);
    final body = AppTextStyles.bodyFont(context);

    return OnboardingScaffold(
      place: OnboardingPlace.startSmall,
      onBack: widget.onBack,
      title:
          short ? l10n.onboardingStartTitleTwo : l10n.onboardingStartTitleThree,
      subtitle: short
          ? l10n.onboardingStartShortMonth(
              chapter.firstMonthDays,
              // The month as it reads after "until": Russian needs the
              // genitive («до октября»), and 'MMMM' alone is a skeleton that
              // intl turns into the nominative.
              DateFormat('MMMM', locale)
                  .dateSymbols
                  .MONTHS[chapter.months[1].month - 1],
            )
          : l10n.onboardingStartSubtitle,
      ctaLabel: l10n.commonContinue,
      onCta: _chosen.isEmpty ? null : _continue,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          28,
          16,
          28,
          OnboardingScaffold.contentBottomPadding,
        ),
        children: [
          // Says where the areas came from (10 Oct): the direction set
          // them. One paragraph, so a long line wraps with "change" still
          // after the areas; the whole line opens the sheet, so the target
          // is never just one small word. Russian reads the areas in lower
          // case after a colon.
          Semantics(
            button: true,
            child: GestureDetector(
              key: const Key('start-small-focus'),
              behavior: HitTestBehavior.opaque,
              onTap: _changeFocus,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: body,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: colors.textPrimary.withValues(alpha: 0.65),
                    ),
                    children: [
                      TextSpan(
                        text: l10n.onboardingStartFocusLine(
                          _path(state).title(l10n),
                          Localizations.localeOf(context).languageCode == 'ru'
                              ? localizeCategoryList(state.focusAreas, l10n)
                                  .toLowerCase()
                              : localizeCategoryList(state.focusAreas, l10n),
                        ),
                      ),
                      // Non-breaking: a wrap takes the last area along, never
                      // leaves the dot or "change" alone.
                      const TextSpan(text: '\u00A0\u00B7\u00A0'),
                      TextSpan(
                        text: l10n.onboardingStartFocusChange,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.ctaPrimary,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              colors.ctaPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < shown.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _card(state, shown[i])),
                    const SizedBox(width: 12),
                    Expanded(
                      child: i + 1 < shown.length
                          ? _card(state, shown[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          if (_atCap)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.onboardingStartCap,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: body,
                  fontSize: 13,
                  color: colors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(OnboardingState state, String action) => ActionCard(
        action: action,
        category: state.getCategoryForHabit(action),
        selected: _chosen.contains(action),
        onTap: () => _toggle(action),
      );
}

/// One small action on glass: its focus area's glyph and its name. Chosen,
/// it takes on the focus area's colour, the colour its squares will be.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.action,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final String action;
  final String? category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors;
    final tint = CategoryColors.of(category, theme.theme);
    final name = localizeHabitName(action, AppLocalizations.of(context));

    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.82),
                          tint.withValues(alpha: 0.34),
                        ]
                      : [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.6),
                          colors.surfaceLight.withValues(alpha: 0.5),
                        ],
                ),
                border: Border.all(
                  color: selected
                      ? tint.withValues(alpha: 0.75)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.55),
                  width: selected ? 1.8 : 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(CategoryGlyphs.of(category),
                          width: 40, height: 40),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: selected ? 1 : 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: tint),
                          child: const Icon(
                            CupertinoIcons.checkmark,
                            size: 13,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Choosing the focus areas the actions come from. They follow the path by
/// default; this is the way to change them (decided 30 Sep, option A).
class _FocusSheet extends StatefulWidget {
  const _FocusSheet();

  @override
  State<_FocusSheet> createState() => _FocusSheetState();
}

class _FocusSheetState extends State<_FocusSheet> {
  bool _atLimit = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<OnboardingState>();
    final colors = context.watch<ThemeProvider>().colors;
    final locale = Localizations.localeOf(context).toString();
    final body = AppTextStyles.bodyFont(context);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          color: colors.onboardingBg1.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tellUsAboutFocusHeadline,
              style: TextStyle(
                fontFamily: AppTextStyles.displayFontFor(locale),
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 6),
            // Also the reason a third tap does nothing: said, not silent.
            Text(
              l10n.tellUsAboutFocusSubtext,
              style: TextStyle(
                fontFamily: body,
                fontSize: 14,
                color: colors.ctaSecondary,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final area in OnboardingState.focusAreaOptions)
                  _AreaChip(
                    area: area,
                    selected: state.isSelected(area),
                    onTap: () {
                      // At two, a third tap says why nothing changed: a
                      // vibration alone reads as "nothing happened" (the
                      // old focus screen learned this on device). Said
                      // here, under the chips, like the cap on actions: a
                      // toast would sit on top of them.
                      if (!state.isSelected(area) &&
                          state.focusAreas.length >= state.maxFocusAreas()) {
                        HapticFeedback.lightImpact();
                        setState(() => _atLimit = true);
                        return;
                      }
                      HapticFeedback.selectionClick();
                      setState(() => _atLimit = false);
                      state.toggleFocusArea(area);
                    },
                  ),
              ],
            ),
            if (_atLimit)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  l10n.focusAreasLimitToast,
                  style: TextStyle(
                    fontFamily: body,
                    fontSize: 13,
                    color: colors.textPrimary.withValues(alpha: 0.6),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            OnboardingCta(
              label: l10n.commonDone,
              onPressed: state.focusAreas.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({
    required this.area,
    required this.selected,
    required this.onTap,
  });

  final String area;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final tint = CategoryColors.of(area, theme.theme);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: selected
                ? tint.withValues(alpha: 0.22)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.6),
            border: Border.all(
              color: selected
                  ? tint.withValues(alpha: 0.8)
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.8),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(CategoryGlyphs.of(area), width: 28, height: 28),
              const SizedBox(width: 6),
              Text(
                localizeCategoryName(area, AppLocalizations.of(context)),
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colors.textPrimary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
