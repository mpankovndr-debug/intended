import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../models/drift.dart';
import '../models/first_week.dart';
import '../models/letter.dart';
import '../models/lift.dart';
import '../models/month_plan.dart';
import '../models/season.dart';
import '../services/season_service.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/moments_service.dart';
import '../services/notification_preferences_service.dart';
import '../services/notification_scheduler.dart';
import '../services/plan_service.dart';
import 'paywall_screen.dart';
import 'season_share_screen.dart';
import '../state/user_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
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

  /// Last month's moments — the evidence the plan is read from (§6.2). The
  /// plan itself is derived in build, so accepting a nudge that changes the
  /// habit list or the pin is reflected without another round trip to disk.
  List<Moment> _lastMonth = const [];

  String _reminderTime = '';
  int _reminderHour = 9;
  bool _remindersEnabled = false;
  Season? _season;
  Map<String, Season> _archive = const {};
  Drift? _drift;
  Letter? _letter;
  Lift? _lift;
  FirstWeek? _firstWeek;
  int _liftWeeksRemaining = 0;
  Set<String> _declinedNudges = const {};
  AcceptedNudge? _acceptedThisMonth;
  PlanProof? _proof;
  bool _showAllNudges = false;
  bool _accepting = false;
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
    final monthKey = SeasonService.monthKeyFor(now);
    final moments = await MomentsService.momentsForMonth(now);
    // DateTime normalises month 0 to December of the previous year, so this
    // holds across a January boundary.
    final lastMonth =
        await MomentsService.momentsForMonth(DateTime(now.year, now.month - 1, 1));
    final season = await SeasonService.currentSeason();
    final archive = await SeasonService.archive();
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();
    final remindersEnabled = await NotificationPreferencesService.isEnabled();
    final allMoments = await MomentsService.getAll();
    final declined = await PlanService.declinedFor(monthKey);
    final accepted = await PlanService.acceptedFor(monthKey);
    final proof = await PlanService.proof();
    if (!mounted) return;
    setState(() {
      _moments = moments;
      _lastMonth = lastMonth;
      _season = season;
      _archive = archive;
      _drift = Drift.read(moments);
      // Given the season and the reminder so it can avoid repeating the
      // card above it, and can ask a question with a real alternative in it.
      _letter = Letter.read(
        moments,
        seasonPole: season.pole,
        reminderHour: hour,
      );
      _reminderHour = hour;
      _remindersEnabled = remindersEnabled;
      _declinedNudges = declined;
      _acceptedThisMonth = accepted;
      _proof = proof;
      // Ranked from the full history, not the month: eight weeks of taps
      // straddle a month boundary by definition.
      _lift = Lift.read(
        allMoments,
        activeHabits: context.read<OnboardingState>().userHabits,
      );
      _liftWeeksRemaining = Lift.weeksRemaining(allMoments);
      _firstWeek = FirstWeek.read(allMoments);
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
    final paid = context.watch<UserState>().hasSubscription;
    final plan = _plan(onboarding);

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
          else
            // One sheet of glass for the whole month — grid, week one,
            // season, readings, all of it joined by the profile's dividers.
            // The only thing that stands apart is the upsell below: it is not
            // the user's data, so it doesn't get to sit inside it.
            ...[
            _shell(colors, sections: [
              _monthCard(l10n, colors, themeProvider, paid: paid),
              // The early days, on both tiers (§12) — week one is when every
              // pattern section is still null, so these two carry it.
              if (_moments.isNotEmpty) ...[
                if (_firstWeek != null) _firstWeekCard(l10n, colors, _firstWeek!),
                if (_moments.length < Letter.minMoments)
                  _soFarCard(l10n, colors),
              ],
              // Day one belongs to neither tier (§5.4): nothing is behind a
              // lock yet, so the Day-0 window stays with the onboarding
              // paywall.
              if (_moments.isEmpty) ...[
                _startingWithCard(l10n, colors, onboarding),
                _exampleCard(l10n, colors, themeProvider),
              ] else if (paid) ...[
                // Free and paid share the same sections and the same quality;
                // paid has more of them (§5.3). Each returns null when it has
                // nothing true to say, and then simply isn't on the page.
                if (_drift != null) _driftCard(l10n, colors, _drift!),
                _seasonCard(l10n, colors, paid: paid),
                if (_letter != null) _letterCard(l10n, colors, _letter!),
                if (!plan.isEmpty || _acceptedThisMonth != null)
                  _planCard(l10n, colors, plan),
                if (_lift != null) _liftCard(l10n, colors, _lift!, plan),
              ] else ...[
                _seasonCard(l10n, colors, paid: paid),
              ],
            ]),
            if (!paid && _moments.isNotEmpty) ...[
              const SizedBox(height: 12),
              _shell(colors, sections: [
                _teaserCard(l10n, colors, onboarding),
              ]),
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

  /// One card for the whole month (design review): every section lives in a
  /// single sheet of the profile's glass, separated by the profile's own
  /// dividers. Share then reads as sharing *this* — the month a user is
  /// looking at — rather than one tile among many.
  ///
  /// [emphasis] is kept in the signature so call sites don't churn, but a
  /// single card has no louder card to be; prominence now comes from order.
  Widget _card({
    required AppColorScheme colors,
    required Widget child,
    bool emphasis = false,
  }) =>
      child;

  /// The one decorated surface on the page.
  Widget _shell(AppColorScheme colors, {required List<Widget> sections}) {
    final isDark = context.read<ThemeProvider>().theme.isDark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.profileCard.withValues(alpha: colors.profileCardOpacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? colors.borderCard.withValues(alpha: colors.borderCardOpacity)
              : const Color(0xFFFFFFFF).withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            sections[i],
            if (i != sections.length - 1) _divider(colors),
          ],
        ],
      ),
    );
  }

  /// The profile card's row divider.
  Widget _divider(AppColorScheme colors) => Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        height: 1,
        color: colors.textDisabled.withValues(alpha: 0.22),
      );

  Widget _monthCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    ThemeProvider themeProvider, {
    required bool paid,
  }) {
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
                      _returnsLine(l10n, paid),
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

  /// Free is told how many times; paid is told how far apart (§5.3).
  ///
  /// The intervals are the half that turns a count into a direction — "9, 6,
  /// 4, 2" is a person whose quiet stretches are closing, and that is a thing
  /// only their own history can say.
  String _returnsLine(AppLocalizations l10n, bool paid) {
    final base = l10n.insightsReturnsLine(_returnCount);
    final gaps = _gapLengths();
    if (paid && gaps.length >= 2) {
      return '$base ${l10n.insightsReturnGaps(gaps.reversed.join(', '))}';
    }
    return _gapsShortening ? '$base ${l10n.insightsGapsShortening}' : base;
  }

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
    // The plan, not the letter. Free already tells you what happened — the
    // grid, the returns, the season word. What it cannot tell you is what to
    // do next, and that gap is the whole reason the tier exists (§4.5). So the
    // teaser shows one real suggestion, computed from their own last month,
    // and lets the second dissolve.
    //
    // When there is no plan yet — a first month, or nothing worth proposing —
    // it falls back to naming what this card becomes, because a fade with
    // nothing behind it is a padlock with extra steps.
    final plan = _plan(onboarding);
    final shown = plan.shown;

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shown.isNotEmpty) ...[
            _eyebrow(l10n.planPreviewLabel, colors),
            const SizedBox(height: 12),
          ],
          if (shown.isEmpty)
            Text(
              _hasFocusGap(onboarding)
                  ? l10n.insightsTeaserBody
                  : l10n.insightsTeaserNoGap,
              style: _cardBody(colors),
            )
          else ...[
            Text(
              _nudgeText(l10n, shown.first),
              style: _cardBody(colors).copyWith(color: colors.textPrimary),
            ),
            if (shown.length > 1) ...[
              const SizedBox(height: 8),
              _fadingLine(_nudgeText(l10n, shown[1]), colors),
            ],
          ],
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.center,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              borderRadius: BorderRadius.circular(22),
              color: colors.ctaPrimary,
              minimumSize: Size.zero,
              onPressed: _showPaywall,
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

  /// Same presentation as the profile's "Try Intended+": the page dims and
  /// blurs behind the sheet, so the paywall arrives over the app rather than
  /// replacing it. This button did nothing at all until the design review
  /// caught it.
  Future<void> _showPaywall() {
    return showCupertinoModalPopup(
      context: context,
      barrierColor: const Color(0x80000000),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) => const PaywallScreen(source: 'insights_teaser'),
    );
  }

  /// A real sentence that runs out of ink partway across.
  ///
  /// Never a padlock. A lock is a hard metal object in a world of mist and
  /// glass — the one element that looks borrowed from another app — and it
  /// says *blocked*. A sentence dissolving says *there is more here*, which is
  /// the difference between a barrier and an invitation (§5.3).
  Widget _fadingLine(String text, AppColorScheme colors) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF000000), Color(0x00000000)],
        stops: [0.45, 0.95],
      ).createShader(rect),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
        style: _cardBody(colors).copyWith(color: colors.textPrimary),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
  Widget _seasonCard(
    AppLocalizations l10n,
    AppColorScheme colors, {
    required bool paid,
  }) {
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
          // The word is free; the reading behind it and the archive are what
          // is paid for (§4.4). Free is not shown a worse version of the
          // explanation — it is shown the word, which is the whole of what it
          // was promised.
          if (paid) ...[
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
            if (_pastSeasons(l10n).isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: colors.textDisabled.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 12),
              Text(_pastSeasons(l10n), style: _cardMeta(colors)),
            ],
          ],
          // Free on purpose (§4.4): the word is the shareable thing, and the
          // explanation and the archive are what's paid for. A month still
          // forming has no word yet, so there is nothing to share.
          if (!forming) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                onPressed: () => _shareSeason(word),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.share,
                      size: 17,
                      color: colors.ctaPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.shareButton,
                      style: _cardBody(colors).copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.ctaPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Opens the monthly card (§5.5).
  ///
  /// A different object from the card on screen: season word as hero, the
  /// grid, the count, the wordmark, and "intention, not perfection" at a size
  /// that survives a thumbnail. What is worth reading in the app and what is
  /// worth posting are not the same picture.
  Future<void> _shareSeason(String seasonWord) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => SeasonShareScreen(
          seasonWord: seasonWord,
          moments: _moments,
          returnCount: _returnCount,
          gapsShortening: _gapsShortening,
        ),
      ),
    );
  }

  /// The letter (§5.3) — three observations and a question.
  ///
  /// This slot used to hold a stock quote ("Consistency is important, but so is
  /// self-compassion"), which was true of everyone and therefore about no one.
  /// Every line here comes from the user's own month, and any line whose data
  /// isn't there is simply absent rather than softened into a generality.
  ///
  /// All four lines are one size. The question carries in full-strength text
  /// against the observations' secondary, so it lands as the point of the card
  /// without being a headline — it is a line of a letter, not a banner.
  Widget _letterCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    Letter letter,
  ) {
    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.letterLabel, colors),
          const SizedBox(height: 14),
          for (final line in letter.lines) ...[
            Text(_letterLine(l10n, line), style: _letterStyle(colors)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          Text(
            _letterQuestion(l10n, letter),
            style: _letterStyle(colors).copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  /// Italic throughout, and looser than the rest of the page.
  ///
  /// The whole card has to read as one voice rather than a list of findings —
  /// the observations and the question are the same person talking. A serif
  /// would carry this better; the app ships only Sora and Montserrat, so
  /// italic and air are what is available.
  TextStyle _letterStyle(AppColorScheme colors) =>
      _cardBody(colors).copyWith(height: 1.6, fontStyle: FontStyle.italic);

  String _letterLine(AppLocalizations l10n, LetterLine line) {
    return switch (line.kind) {
      LetterLineKind.openedQuietly => l10n.letterOpenedQuietly,
      LetterLineKind.openedFull => l10n.letterOpenedFull,
      LetterLineKind.cameBack => l10n.letterCameBack(line.count),
      LetterLineKind.mostlyChose =>
        l10n.letterMostlyChose(localizeCategoryName(line.focusArea!, l10n)),
      LetterLineKind.anchor => l10n.letterAnchor(
          localizeHabitName(line.habitName!, l10n),
          line.count,
        ),
      LetterLineKind.mood => line.secondCount == 0
          ? l10n.letterMoodGladOnly(line.count)
          : line.count == 0
              ? l10n.letterMoodEffortOnly(line.secondCount)
              : l10n.letterMood(line.count, line.secondCount),
      LetterLineKind.showedUp => l10n.letterShowedUp(line.count),
    };
  }

  /// The closing question, which always names the month ahead.
  ///
  /// Reading it needs next month's name, so it is built here rather than in
  /// the model — the same split every other localised string on this page
  /// uses.
  String _letterQuestion(AppLocalizations l10n, Letter letter) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final month =
        DateFormat.LLLL(locale).format(DateTime(now.year, now.month + 1, 1));

    return switch (letter.question) {
      LetterQuestion.planForPart => l10n.letterQuestionPlanForPart(
          month,
          _partName(l10n, letter.part!.lived),
          _partName(l10n, letter.part!.planned),
        ),
      LetterQuestion.shorterQuiet => l10n.letterQuestionShorterQuiet(month),
      LetterQuestion.moreOfWhat => l10n.letterQuestionMoreOfWhat(month),
    };
  }

  String _partName(AppLocalizations l10n, DayPart part) => switch (part) {
        DayPart.mornings => l10n.letterPartMornings,
        DayPart.afternoons => l10n.letterPartAfternoons,
        DayPart.evenings => l10n.letterPartEvenings,
        DayPart.nights => l10n.letterPartNights,
      };

  /// This month's plan, read from last month (§6.2).
  ///
  /// Derived in build rather than stored, so the moment a nudge is accepted —
  /// a habit set aside, an action pinned, a focus area adopted — the card
  /// re-reads the state that just changed and the suggestion disappears
  /// because it is no longer true, not because it was crossed off a list.
  MonthPlan _plan(OnboardingState onboarding) {
    return MonthPlan.read(
      monthKey: SeasonService.monthKeyFor(DateTime.now()),
      lastMonth: _lastMonth,
      activeHabits: onboarding.userHabits,
      customHabits: onboarding.customHabits,
      focusAreas: onboarding.focusAreas,
      reminderHour: _reminderHour,
      remindersEnabled: _remindersEnabled,
      hasPinnedHabit: onboarding.pinnedHabit != null,
      declinedIds: _declinedNudges,
    );
  }

  /// The plan (§6.2) — the card that changes the subscription from reviewing
  /// the past to planning the next month.
  ///
  /// It opens with proof, when there is any: whatever the user changed last
  /// time, and what happened over the four weeks that followed (§6.3). That is
  /// the thing that still has something to say in month eight, once the
  /// observations have stopped being novel.
  ///
  /// One decision, not three. The top-ranked suggestion is the whole card;
  /// the others wait behind a line the user has to ask for. Three nudges and
  /// six buttons read as a dashboard demanding optimisation, which is the
  /// pressure this app exists to remove.
  Widget _planCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    MonthPlan plan,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.LLLL(locale).format(DateTime.now());
    final accepted = _acceptedThisMonth;

    return _card(
      colors: colors,
      emphasis: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.planLabel(month.toUpperCase()), colors),
          const SizedBox(height: 12),
          if (_proof != null) ...[
            Text(_proofLines(l10n, _proof!), style: _cardBody(colors)),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: colors.textDisabled.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
          ],
          if (accepted != null)
            // One plan a month. Something has already been changed, so the
            // card stops proposing and waits to see what it did.
            Text(
              l10n.planDone,
              style: _cardBody(colors).copyWith(color: colors.textPrimary),
            )
          else ...[
            if (plan.topAction != null)
              _planGroup(l10n, colors, l10n.planActionsHeader, plan.topAction!),
            if (plan.topRhythm != null)
              _planGroup(l10n, colors, l10n.planRhythmHeader, plan.topRhythm!),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _planAction(
                  l10n.planUse,
                  colors,
                  filled: true,
                  onPressed: () => _acceptAll(plan.shown, l10n),
                ),
                _planAction(
                  l10n.planAdjust,
                  colors,
                  filled: false,
                  onPressed: () =>
                      setState(() => _showAllNudges = !_showAllNudges),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// One half of the plan: its sub-header and the suggestion under it.
  ///
  /// Adjust opens per-item controls rather than a second screen. "Accept or
  /// adjust" means the user can take half a plan — the alternative is a single
  /// all-or-nothing button, which turns a declined rhythm change into a
  /// declined month.
  Widget _planGroup(
    AppLocalizations l10n,
    AppColorScheme colors,
    String header,
    PlanNudge nudge,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.ctaPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _nudgeText(l10n, nudge),
                style: _cardBody(colors).copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        if (_showAllNudges) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Wrap(
              spacing: 8,
              children: [
                _planAction(
                  _acceptLabel(l10n, nudge.kind),
                  colors,
                  filled: false,
                  onPressed: () => _acceptAll([nudge], l10n),
                ),
                _planAction(
                  l10n.planSkip,
                  colors,
                  filled: false,
                  onPressed: () => _decline(nudge),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _planAction(
    String label,
    AppColorScheme colors, {
    required bool filled,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(18),
      color: filled ? colors.ctaPrimary : null,
      onPressed: _accepting ? null : onPressed,
      child: Text(
        label,
        style: AppTextStyles.body(context).copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: filled ? const Color(0xFFFFFFFF) : colors.textPrimary,
        ),
      ),
    );
  }

  String _nudgeText(AppLocalizations l10n, PlanNudge nudge) {
    final locale = Localizations.localeOf(context).toString();
    return switch (nudge.kind) {
      NudgeKind.moveReminder => l10n.planNudgeMoveReminder(
          DateFormat.jm(locale).format(DateTime(2000, 1, 1, nudge.hour!)),
        ),
      NudgeKind.setAside => l10n.planNudgeSetAside(
          localizeHabitName(nudge.habitName!, l10n),
          nudge.count,
        ),
      NudgeKind.keepAnchor => l10n.planNudgeKeepAnchor(
          localizeHabitName(nudge.habitName!, l10n),
          nudge.count,
        ),
      NudgeKind.addFocusArea => l10n.planNudgeAddFocus(
          localizeCategoryName(nudge.focusArea!, l10n),
          nudge.count,
        ),
    };
  }

  String _acceptLabel(AppLocalizations l10n, NudgeKind kind) {
    return switch (kind) {
      NudgeKind.moveReminder => l10n.planAcceptMoveReminder,
      NudgeKind.setAside => l10n.planAcceptSetAside,
      NudgeKind.keepAnchor => l10n.planAcceptKeepAnchor,
      NudgeKind.addFocusArea => l10n.planAcceptAddFocus,
    };
  }

  /// "In July you moved your reminder to 10pm. 22 moments since, up from 14."
  ///
  /// Reports a fall as plainly as a rise. A measurement that only ever
  /// confirms the change was good is not a measurement, and the user would
  /// work that out by month three.
  String _proofLines(AppLocalizations l10n, PlanProof proof) {
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.MMMMd(locale).format(proof.acceptedOn);
    final what = switch (proof.kind) {
      NudgeKind.moveReminder => l10n.planProofMovedReminder(
          date,
          DateFormat.jm(locale).format(
            DateTime(2000, 1, 1, int.tryParse(proof.subject) ?? 0),
          ),
        ),
      NudgeKind.setAside =>
        l10n.planProofSetAside(date, localizeHabitName(proof.subject, l10n)),
      NudgeKind.keepAnchor =>
        l10n.planProofPinned(date, localizeHabitName(proof.subject, l10n)),
      NudgeKind.addFocusArea => l10n.planProofAddedFocus(
          date,
          localizeCategoryName(proof.subject, l10n),
        ),
    };

    final result = proof.after > proof.before
        ? l10n.planProofUp(proof.after, proof.before)
        : proof.after < proof.before
            ? l10n.planProofDown(proof.after, proof.before)
            : l10n.planProofSame(proof.after);

    return '$what $result';
  }

  /// Applies every suggestion the user took, then records each one with the
  /// count it will be measured against (§6.3).
  Future<void> _acceptAll(
    List<PlanNudge> nudges,
    AppLocalizations l10n,
  ) async {
    if (_accepting || nudges.isEmpty) return;
    setState(() => _accepting = true);

    final onboarding = context.read<OnboardingState>();
    final monthKey = SeasonService.monthKeyFor(DateTime.now());

    for (final nudge in nudges) {
      await _applyAndRecord(nudge, monthKey, onboarding, l10n);
    }

    if (!mounted) return;
    setState(() {
      _accepting = false;
      _showAllNudges = false;
    });
    await _load();
  }

  Future<void> _applyAndRecord(
    PlanNudge nudge,
    String monthKey,
    OnboardingState onboarding,
    AppLocalizations l10n,
  ) async {
    switch (nudge.kind) {
      case NudgeKind.moveReminder:
        await NotificationPreferencesService.setHour(nudge.hour!);
        await NotificationPreferencesService.setMinute(0);
        await NotificationScheduler.rescheduleAll(l10n);
      case NudgeKind.setAside:
        await onboarding.setAsideHabits([nudge.habitName!]);
      case NudgeKind.keepAnchor:
        await onboarding.pinHabit(nudge.habitName!);
      case NudgeKind.addFocusArea:
        await onboarding.adoptFocusArea(nudge.focusArea!);
    }

    // Recorded after the write, so a failure to change the setting can never
    // leave a measurement running against a change that didn't happen.
    await PlanService.accept(nudge, monthKey);
  }

  Future<void> _decline(PlanNudge nudge) async {
    await PlanService.decline(
      nudge,
      SeasonService.monthKeyFor(DateTime.now()),
    );
    if (!mounted) return;
    await _load();
  }

  /// Closed months, newest first: "July · Steady · June · Emerging".
  ///
  /// The archive is the reason a season is frozen once its month ends (§10).
  /// A word that changed retroactively would destroy "this was who I was in
  /// September", and that permanence is the thing being paid for — so this row
  /// is the only place it is visible, and it was dead storage until now.
  String _pastSeasons(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final keys = _archive.keys.toList()..sort((a, b) => b.compareTo(a));

    final parts = <String>[];
    for (final key in keys.take(_archiveMonths)) {
      final season = _archive[key]!;
      final bits = key.split('-');
      if (bits.length != 2) continue;
      final month = DateFormat.LLLL(locale).format(
        DateTime(int.parse(bits[0]), int.parse(bits[1])),
      );
      parts.add('$month · ${_seasonWord(l10n, season.pole)}');
    }
    return parts.join('  ·  ');
  }

  /// Four is enough to show the archive is real without turning the card into
  /// a history page.
  static const int _archiveMonths = 4;

  String _seasonWord(AppLocalizations l10n, String pole) => switch (pole) {
        Season.morning => l10n.seasonMorning,
        Season.evening => l10n.seasonEvening,
        Season.steady => l10n.seasonSteady,
        Season.bursts => l10n.seasonBursts,
        Season.returning => l10n.seasonReturning,
        Season.continuous => l10n.seasonContinuous,
        Season.focused => l10n.seasonFocused,
        Season.wandering => l10n.seasonWandering,
        _ => l10n.seasonBeginning,
      };

  /// The so-far card: every moment named in full, while that is possible.
  ///
  /// At four moments the app can be completely specific in a way it never can
  /// again — the exact evening, the exact action, how it landed. This is
  /// §5.3's honest-partial rule promoted to a card: real content with real
  /// confidence, in place of pattern cards that would otherwise be silent for
  /// a week. It retires itself the day the letter can exist, at eight.
  Widget _soFarCard(AppLocalizations l10n, AppColorScheme colors) {
    final locale = Localizations.localeOf(context).toString();

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.soFarLabel, colors),
          const SizedBox(height: 14),
          // Rows, not prose (design review, SS8): the action carries the
          // line, and the when-and-how sits under it in meta. Five sentences
          // in a row read as a wall; five named things read as a list of
          // things you did.
          for (final m in _moments) ...[
            Builder(builder: (context) {
              // Rebuilt as UTC-flagged wall clock; formatted without
              // conversion so it shows the user's own clock at the time.
              final local =
                  m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
              final meta = [
                DateFormat.EEEE(locale).format(local),
                DateFormat.jm(locale).format(local),
                switch (m.mood) {
                  MomentMood.gladIDid => l10n.soFarGlad,
                  MomentMood.tookEffort => l10n.soFarEffort,
                  _ => null,
                },
              ].whereType<String>().join(' · ');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizeHabitName(m.habitName, l10n),
                    style: _cardBody(colors).copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(meta, style: _cardMeta(colors)),
                ],
              );
            }),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 2),
          Text(l10n.soFarClosing, style: _cardMeta(colors)),
        ],
      ),
    );
  }

  /// The first-week keepsake (§12). Appears when the week completes, leaves a
  /// week later on its own — an event, not a fixture.
  Widget _firstWeekCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    FirstWeek week,
  ) {
    final part = week.dominantPart;

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.firstWeekLabel, colors),
          const SizedBox(height: 10),
          Text(
            l10n.firstWeekCount(week.momentCount),
            style: _cardTitle(colors),
          ),
          if (part != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.insightsMostlyAt(_partPeriodName(l10n, part)),
              style: _cardBody(colors),
            ),
          ],
          if (week.gladdestHabit != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n.firstWeekGladdest(
                localizeHabitName(week.gladdestHabit!, l10n),
              ),
              style: _cardBody(colors),
            ),
          ],
        ],
      ),
    );
  }

  /// The month card's period strings, reused so the first week and the month
  /// can never disagree about what "in the evening" means.
  String _partPeriodName(AppLocalizations l10n, DayPart part) =>
      switch (part) {
        DayPart.mornings => l10n.insightsPeriodMorning,
        DayPart.afternoons => l10n.insightsPeriodAfternoon,
        DayPart.evenings => l10n.insightsPeriodEvening,
        DayPart.nights => l10n.insightsPeriodLateNight,
      };

  /// What actually lifts you (§6.4) — actions ranked by how they land.
  ///
  /// The one card built before its data exists: mood taps started with v2,
  /// the ranking needs ~8 weeks of them, and shipping it later would mean the
  /// users whose data matured first needed an app update to see it. Forming
  /// state shows one real reading and an honest ask-me-later; the ranking
  /// appears when it can actually rank.
  ///
  /// Its button follows §4.5 — when the bottom action clearly isn't landing,
  /// setting it aside is one tap, recorded through the same accept path the
  /// plan uses so §6.3 can measure what followed. Suppressed whenever the
  /// plan is already proposing an action change: two cards asking for
  /// decisions is the dashboard §5.3 forbids.
  Widget _liftCard(
    AppLocalizations l10n,
    AppColorScheme colors,
    Lift lift,
    MonthPlan plan,
  ) {
    final worst = lift.worst;
    final planProposesAction =
        _acceptedThisMonth == null && plan.topAction != null;
    final showSetAside = worst != null && !planProposesAction;

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(l10n.liftLabel, colors),
          const SizedBox(height: 12),
          for (final r in lift.readings) ...[
            Text(
              l10n.liftLine(
                localizeHabitName(r.habitName, l10n),
                r.gladCount,
                r.ratedCount,
              ),
              style: _cardBody(colors).copyWith(
                color: r == lift.readings.first
                    ? colors.textPrimary
                    : colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (!lift.mature) ...[
            const SizedBox(height: 2),
            Text(
              l10n.liftForming(_liftWeeksRemaining),
              style: _cardMeta(colors),
            ),
          ],
          if (showSetAside) ...[
            const SizedBox(height: 6),
            Text(l10n.liftWorstLead, style: _cardMeta(colors)),
            const SizedBox(height: 12),
            _planAction(
              l10n.planAcceptSetAside,
              colors,
              filled: false,
              onPressed: () => _acceptAll(
                [
                  PlanNudge(
                    kind: NudgeKind.setAside,
                    confidence: 1 - worst.gladShare,
                    count: worst.ratedCount,
                    habitName: worst.habitName,
                  ),
                ],
                l10n,
              ),
            ),
          ],
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
          const SizedBox(height: 12),
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
