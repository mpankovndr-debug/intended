import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../models/drift.dart';
import '../models/season.dart';
import '../services/season_service.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/moments_service.dart';
import '../services/notification_preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../main.dart' show AppBackground;
import '../theme/category_colors.dart';
import '../widgets/moment_grid.dart';

/// The month view (§5.3, §5.4). Replaces the old progress screen.
///
/// Day one is not a zero state — the user just finished onboarding, so they
/// have an intention and actions even though they have no moments. Showing an
/// empty chart would waste the one screen that can explain the whole system
/// before there is any data to explain it with.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<Moment> _moments = const [];
  String _reminderTime = '';
  Season? _season;
  Drift? _drift;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant InsightsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-read when the tab becomes visible; a moment may have landed since.
    if (widget.isActive && !oldWidget.isActive) _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final moments = await MomentsService.momentsForMonth(now);
    final season = await SeasonService.currentSeason();
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();
    if (!mounted) return;
    setState(() {
      _moments = moments;
      _season = season;
      _drift = Drift.read(moments);
      _reminderTime =
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final onboarding = context.watch<OnboardingState>();

    // Every screen draws the shared background itself; without it this one
    // rendered on bare black.
    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 180),
        children: [
          Text(l10n.insightsTitle, style: AppTextStyles.h1(context)),
          const SizedBox(height: 20),
          if (!_loaded)
            const SizedBox.shrink()
          else ...[
            _monthCard(l10n, colors, themeProvider),
            const SizedBox(height: 16),
            if (_moments.isEmpty) ...[
              _startingWithCard(l10n, colors, onboarding),
              const SizedBox(height: 16),
              _exampleCard(l10n, colors, themeProvider),
              const SizedBox(height: 16),
            ] else ...[
              // Only when there is something honest to say (§6.1).
              if (_drift != null) ...[
                _driftCard(l10n, colors, _drift!),
                const SizedBox(height: 16),
              ],
              _seasonCard(l10n, colors),
              const SizedBox(height: 16),
              _teaserCard(l10n, colors, onboarding),
              const SizedBox(height: 16),
            ],
            ],
          ],
        ),
      ),
    );
  }


  // One type scale for the whole page. Every card draws from these three and
  // nothing overrides them locally — the previous version set sizes and
  // colours per card, which left the season word level with the page title
  // and two different headline colours on one screen.
  //
  // Page title (h1, 34) > season word (30) > card headline (20) > body (15)
  // > meta (13). Header font for the first three, body font for the rest.

  /// Small caps label at the top of every card: THIS MONTH, YOUR SEASON.
  Widget _eyebrow(String text, AppColorScheme colors) => Text(
        text,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: colors.ctaPrimary,
        ),
      );

  TextStyle _cardTitle(AppColorScheme colors) =>
      AppTextStyles.h2(context).copyWith(
        fontSize: 20,
        height: 1.3,
        color: colors.textPrimary,
      );

  TextStyle _cardBody(AppColorScheme colors) =>
      AppTextStyles.body(context).copyWith(
        height: 1.45,
        color: colors.textSecondary,
      );

  TextStyle _cardMeta(AppColorScheme colors) =>
      AppTextStyles.body(context).copyWith(
        fontSize: 13,
        color: colors.textSecondary,
      );

  Widget _card({required AppColorScheme colors, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.borderCard.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _monthCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    ThemeProvider themeProvider,
  ) {
    final now = DateTime.now();
    final monthLabel = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    ).format(now);
    final empty = _moments.isEmpty;

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monthLabel, style: _cardMeta(colors)),
          const SizedBox(height: 12),
          _eyebrow(l10n.insightsThisMonth, colors),
          const SizedBox(height: 8),
          Text(
            empty
                ? l10n.insightsEmptyTitle
                : l10n.insightsDidThings(
                    _moments.length,
                    DateFormat.MMMM(
                      Localizations.localeOf(context).toString(),
                    ).format(now),
                  ),
            style: _cardTitle(colors),
          ),
          const SizedBox(height: 6),
          if (!empty && _dominantPeriod(l10n) != null)
            Text(
              l10n.insightsMostlyAt(_dominantPeriod(l10n)!),
              style: _cardBody(colors),
            ),
          if (empty)
            Text(
              l10n.insightsEmptyBody,
              style: _cardBody(colors),
            ),
          const SizedBox(height: 18),
          // On day one a short row of outlines teaches what will fill. That is
          // the *only* place outlines are allowed — §4.2 forbids them in the
          // real grid, where a field of empty slots reads as "look how much
          // you haven't done."
          if (empty)
            _emptyPrimer(colors)
          else
            MomentGrid(moments: _moments, theme: themeProvider.theme),
          const SizedBox(height: 12),
          Text(
            l10n.insightsGridCaption,
            style: _cardMeta(colors),
          ),
          if (!empty) ...[
            const SizedBox(height: 14),
            _legend(colors, themeProvider),
            if (_returnCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.textSecondary.withValues(alpha: 0.5),
                        width: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      // Never "you missed 4 stretches" — the same fact, told
                      // as a return rather than an absence (§4.3).
                      _gapsShortening
                          ? '${l10n.insightsReturnsLine(_returnCount)} '
                              '${l10n.insightsGapsShortening}'
                          : l10n.insightsReturnsLine(_returnCount),
                      style: _cardMeta(colors),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  int get _returnCount => MomentGrid.returnIndicesFor(_moments).length;

  /// True when each successive gap is no longer than the one before — the
  /// half of §4.3 that turns a count into a direction.
  bool get _gapsShortening {
    final gaps = _gapLengths();
    if (gaps.length < 2) return false;
    for (var i = 1; i < gaps.length; i++) {
      if (gaps[i] > gaps[i - 1]) return false;
    }
    return true;
  }

  List<int> _gapLengths() {
    final gaps = <int>[];
    DateTime? previous;
    for (final m in _moments) {
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      final day = DateTime.utc(local.year, local.month, local.day);
      if (previous != null) {
        final quiet = day.difference(previous).inDays - 1;
        if (quiet >= MomentGrid.gapThresholdDays) gaps.add(quiet);
      }
      previous = day;
    }
    return gaps;
  }

  /// Counts per focus area, largest first — the legend under the grid.
  Widget _legend(AppColorScheme colors, ThemeProvider themeProvider) {
    final counts = <String, int>{};
    for (final m in _moments) {
      final key = m.category;
      if (key == null) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final e in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CategoryColors.of(e.key, themeProvider.theme),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '${e.key} ${e.value}',
                style: _cardMeta(colors),
              ),
            ],
          ),
      ],
    );
  }

  /// The part of day most moments fall in, or null when nothing dominates.
  /// Reads localHour, which is why it had to be stored rather than derived.
  String? _dominantPeriod(AppLocalizations l10n) {
    if (_moments.length < 3) return null;
    final buckets = <String, int>{};
    for (final m in _moments) {
      final h = m.localHour;
      final key = h < 5
          ? 'late'
          : h < 12
              ? 'morning'
              : h < 17
                  ? 'afternoon'
                  : h < 22
                      ? 'evening'
                      : 'late';
      buckets[key] = (buckets[key] ?? 0) + 1;
    }
    final top = buckets.entries.reduce((a, b) => a.value >= b.value ? a : b);
    // Only claim a pattern when it is actually one.
    if (top.value / _moments.length < 0.5) return null;
    return switch (top.key) {
      'morning' => l10n.insightsPeriodMorning,
      'afternoon' => l10n.insightsPeriodAfternoon,
      'evening' => l10n.insightsPeriodEvening,
      _ => l10n.insightsPeriodLateNight,
    };
  }

  Widget _emptyPrimer(AppColorScheme colors) {
    return Row(
      children: List.generate(
        8,
        (i) => Padding(
          padding: EdgeInsets.only(right: i == 7 ? 0 : 8),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: colors.textSecondary.withValues(alpha: 0.30),
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _startingWithCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    OnboardingState onboarding,
  ) {
    final habits = onboarding.userHabits.take(3).toList();
    final areas = onboarding.focusAreas.join(' and ');

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.insightsStartingWith, colors),
          const SizedBox(height: 12),
          for (final habit in habits) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.ctaPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    habit,
                    style: AppTextStyles.body(context)
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          Text(
            l10n.insightsStartingMeta(areas, _reminderTime),
            style: _cardMeta(colors),
          ),
        ],
      ),
    );
  }

  /// Free tier's third card (§5.3): real content that stops mid-thought.
  /// Never a padlock — a lock is a hard metal object in a world of mist and
  /// says *blocked*, where an unfinished sentence says *there is more here*.
  /// True when the focus area the user actually spent the month on is not one
  /// they chose. This is the claim the teaser makes, so it has to be real: a
  /// user whose chosen and lived focus agree would otherwise be told about a
  /// gap that isn't there — the "bought a promise, received a promise" failure
  /// §5.3 warns about.
  bool _hasFocusGap(OnboardingState onboarding) {
    if (_moments.length < 5) return false;
    final counts = <String, int>{};
    for (final m in _moments) {
      final key = m.category;
      if (key != null) counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return false;
    final lived =
        counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return !onboarding.focusAreas.contains(lived);
  }

  Widget _teaserCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    OnboardingState onboarding,
  ) {
    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hasFocusGap(onboarding)
                ? l10n.insightsTeaserBody
                : l10n.insightsTeaserNoGap,
            style: _cardBody(colors),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.center,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              borderRadius: BorderRadius.circular(22),
              color: colors.ctaPrimary,
              minimumSize: Size.zero,
              onPressed: () {},
              child: Text(
                l10n.insightsTeaserCta,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Day one's third card: what this page becomes. Marked EXAMPLE and set at
  /// reduced opacity, because at full strength someone could screenshot it
  /// believing it were their own month.
  Widget _exampleCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    ThemeProvider themeProvider,
  ) {
    // Illustrative only — a plausible spread, not stored data.
    const pattern = [
      'Health', 'Health', 'Health', 'Self-care', 'Health', 'Health',
      'Health', 'Mood', 'Health', 'Health', 'Self-care', 'Mood',
      'Health', 'Health', 'Health', 'Self-care', 'Health', 'Self-care',
      'Self-care', 'Health', 'Mood', 'Health', 'Health', 'Self-care',
      'Health', 'Mood', 'Health', 'Self-care', 'Health', 'Health',
      'Self-care', 'Health', 'Health', 'Health', 'Health', 'Health',
      'Health',
    ];

    return Opacity(
      opacity: 0.72,
      child: _card(
        colors: colors,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.insightsExampleHeader,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: colors.ctaPrimary,
                    ),
                  ),
                ),
                Text(
                  l10n.insightsExampleLabel,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 11,
                    letterSpacing: 1.0,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in pattern)
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: CategoryColors.of(category, themeProvider.theme),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.insightsExampleSummary,
              style: _cardBody(colors),
            ),
            Text(
              l10n.insightsExampleReturns,
              style: _cardBody(colors),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: colors.textDisabled.withValues(alpha: 0.25)),
            const SizedBox(height: 14),
            Text(
              l10n.insightsUnlockNote,
              style: _cardMeta(colors).copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  /// The season word (§4.4). Free tier gets the word and one line; the
  /// explanation and the archive are paid.
  ///
  /// Always phrased as "this month you've been", never "you are" — a reading
  /// that changes each month is an observation, while a permanent label is a
  /// personality test, which is the failure mode this has to avoid.
  Widget _seasonCard(AppLocalizations l10n, AppColorScheme colors) {
    final season = _season;
    if (season == null) return const SizedBox.shrink();

    final forming = season.pole == Season.beginning;
    final (word, line) = switch (season.pole) {
      Season.morning => (l10n.seasonMorning, l10n.seasonMorningLine),
      Season.evening => (l10n.seasonEvening, l10n.seasonEveningLine),
      Season.steady => (l10n.seasonSteady, l10n.seasonSteadyLine),
      Season.bursts => (l10n.seasonBursts, l10n.seasonBurstsLine),
      Season.returning => (l10n.seasonReturning, l10n.seasonReturningLine),
      Season.continuous => (l10n.seasonContinuous, l10n.seasonContinuousLine),
      Season.focused => (l10n.seasonFocused, l10n.seasonFocusedLine),
      Season.wandering => (l10n.seasonWandering, l10n.seasonWanderingLine),
      _ => (
          l10n.seasonBeginning,
          l10n.seasonBeginningLine(season.sampleSize),
        ),
    };

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.seasonLabel, colors),
          const SizedBox(height: 10),
          // Below the page title on purpose: the season is the biggest thing
          // *in* a card, never bigger than the screen it sits on.
          Text(
            word,
            style: AppTextStyles.h1(context).copyWith(
              fontSize: 30,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (!forming)
            Text(
              l10n.seasonPatternThisMonth,
              style: _cardMeta(colors).copyWith(color: colors.ctaPrimary),
            ),
          const SizedBox(height: 4),
          Text(
            line,
            style: _cardBody(colors).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  /// The drift warning (§6.1) — the only forward-looking thing in the app.
  ///
  /// Every competitor reacts to absence, noticing once you have already gone.
  /// This speaks before the gap, while there is still a week left to change.
  /// Measured against the user's own rolling average and never a target: "you
  /// usually collect 6" is an observation about them, where "you should
  /// collect 6" would be a goal, and goals are the pressure this app removes.
  Widget _driftCard(AppLocalizations l10n, AppColorScheme colors, Drift drift) {
    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.driftLabel, colors),
          const SizedBox(height: 10),
          Text(
            l10n.driftBody(drift.thisWeek, drift.usual),
            style: _cardTitle(colors),
          ),
          if (drift.precededQuiet) ...[
            const SizedBox(height: 6),
            Text(l10n.driftFollowed, style: _cardBody(colors)),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _driftAction(l10n.driftActionEase, colors, filled: true),
              _driftAction(l10n.driftActionFine, colors, filled: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _driftAction(String label, AppColorScheme colors, {required bool filled}) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(18),
      color: filled ? colors.cardBackground : null,
      onPressed: () {},
      child: Text(
        label,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
