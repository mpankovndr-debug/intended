import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../models/drift.dart';
import '../models/letter.dart';
import '../models/month_plan.dart';
import '../models/season.dart';
import '../services/season_service.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/moments_service.dart';
import '../services/notification_preferences_service.dart';
import '../services/notification_scheduler.dart';
import '../services/plan_service.dart';
import '../services/share_service.dart';
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
  Drift? _drift;
  Letter? _letter;
  Set<String> _declinedNudges = const {};
  AcceptedNudge? _acceptedThisMonth;
  PlanProof? _proof;
  bool _showAllNudges = false;
  bool _accepting = false;
  bool _loaded = false;

  /// Wraps the season card so Share can capture exactly what is on screen.
  final GlobalKey _seasonKey = GlobalKey();

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
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();
    final remindersEnabled = await NotificationPreferencesService.isEnabled();
    final declined = await PlanService.declinedFor(monthKey);
    final accepted = await PlanService.acceptedFor(monthKey);
    final proof = await PlanService.proof();
    if (!mounted) return;
    setState(() {
      _moments = moments;
      _lastMonth = lastMonth;
      _season = season;
      _drift = Drift.read(moments);
      _letter = Letter.read(moments);
      _reminderHour = hour;
      _remindersEnabled = remindersEnabled;
      _declinedNudges = declined;
      _acceptedThisMonth = accepted;
      _proof = proof;
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
          else ...[
            _monthCard(l10n, colors, themeProvider),
            const SizedBox(height: 12),
            // Day one belongs to neither tier. There is genuinely nothing
            // behind a lock yet, so upgrading here would unlock three empty
            // cards — the Day-0 conversion window belongs to the onboarding
            // paywall instead (§5.4).
            if (_moments.isEmpty) ...[
              _startingWithCard(l10n, colors, onboarding),
              const SizedBox(height: 12),
              _exampleCard(l10n, colors, themeProvider),
              const SizedBox(height: 12),
            ] else if (paid) ...[
              // Free and paid share the same cards and the same quality; paid
              // has more of them (§5.3). Nothing here is a degraded copy of
              // something better.
              //
              // Each of these returns null when it has nothing true to say, and
              // then simply isn't on the screen. A section that appears with a
              // reworded promise inside it is the failure §5.3 names: the user
              // bought a promise and received a promise.
              if (_drift != null) ...[
                _driftCard(l10n, colors, _drift!),
                const SizedBox(height: 12),
              ],
              _seasonCard(l10n, colors),
              const SizedBox(height: 12),
              if (_letter != null) ...[
                _letterCard(l10n, colors, _letter!),
                const SizedBox(height: 12),
              ],
              if (!plan.isEmpty || _acceptedThisMonth != null) ...[
                _planCard(l10n, colors, plan),
                const SizedBox(height: 12),
              ],
            ] else ...[
              _seasonCard(l10n, colors),
              const SizedBox(height: 12),
              _teaserCard(l10n, colors, onboarding),
              const SizedBox(height: 12),
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

  /// [emphasis] is the plan card's only distinction (§5.3 calls it the most
  /// prominent card on the screen): a denser glass and a brighter edge. It buys
  /// prominence without a fourth text size, which is what the last redesign
  /// spent it on and had to take back.
  Widget _card({
    required AppColorScheme colors,
    required Widget child,
    bool emphasis = false,
  }) {
    // Real frost, not a flat translucent fill: the blur is what makes the
    // landscape behind the card read as *behind* it. Without it the cards sit
    // on the background like stickers, which is what the first version did.
    return Container(
      // The shadow has to sit outside the clip — inside, the ClipRRect eats
      // it and the card goes back to lying flat on the wallpaper. The lift is
      // half of what makes frosted glass read as glass.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // A vertical lift rather than a flat fill: light catches the top
              // edge of real glass, and a single alpha never does that.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.cardBackground
                      .withValues(alpha: emphasis ? 0.86 : 0.72),
                  colors.cardBackground
                      .withValues(alpha: emphasis ? 0.70 : 0.54),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    colors.borderCard.withValues(alpha: emphasis ? 0.9 : 0.55),
                width: emphasis ? 1.0 : 0.7,
              ),
            ),
            child: child,
          ),
        ),
      ),
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
    // The strongest possible tease is the paid content itself, since it is
    // already computed and already about them. A free user gets the first true
    // line of their own letter, and then watches the question dissolve.
    //
    // Anything else here is a claim about content rather than the content, and
    // a claim is what the reader has to take on trust — which is the whole
    // reason the old sentence didn't work.
    final letter = _letter;
    final lead = letter != null
        ? _letterLine(l10n, letter.lines.first)
        : _hasFocusGap(onboarding)
            ? l10n.insightsTeaserBody
            : l10n.insightsTeaserNoGap;

    return _card(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lead, style: _cardBody(colors)),
          if (letter != null) ...[
            const SizedBox(height: 8),
            _fadingLine(_letterQuestion(l10n, letter.question), colors),
          ],
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

    return RepaintBoundary(
      key: _seasonKey,
      child: _card(
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
                onPressed: _shareSeason,
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
    ),
    );
  }

  /// Shares the season card as it appears.
  ///
  /// §5.5's designed monthly card — season word as hero, the grid, the moment
  /// count, the logo, "intention, not perfection" at legible size — is step 7
  /// and is a different object from this. This shares what is on screen, which
  /// is honest and works today; it is not yet the marketing asset §5.5 wants.
  Future<void> _shareSeason() async {
    final size = MediaQuery.of(context).size;
    await ShareService.shareCard(
      _seasonKey,
      sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
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
            Text(
              _letterLine(l10n, line),
              style: _cardBody(colors).copyWith(height: 1.5),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Text(
            _letterQuestion(l10n, letter.question),
            style: _cardBody(colors).copyWith(
              height: 1.5,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _letterLine(AppLocalizations l10n, LetterLine line) {
    final locale = Localizations.localeOf(context).toString();
    return switch (line.kind) {
      // Two forms of the same day, because the languages need different ones:
      // English can say "on Friday", Russian cannot put a nominative weekday
      // there, so it names the date. Each locale's string uses one and ignores
      // the other.
      LetterLineKind.cameBack => l10n.letterCameBack(
          DateFormat.EEEE(locale).format(line.day!),
          DateFormat.MMMMd(locale).format(line.day!),
          line.count,
        ),
      LetterLineKind.anchor => l10n.letterAnchor(
          localizeHabitName(line.habitName!, l10n),
          line.count,
        ),
      LetterLineKind.mood => line.secondCount == 0
          ? l10n.letterMoodGladOnly(line.count)
          : line.count == 0
              ? l10n.letterMoodEffortOnly(line.secondCount)
              : l10n.letterMood(line.count, line.secondCount),
      LetterLineKind.oneBigDay => l10n.letterOneBigDay(
          DateFormat.MMMMd(locale).format(line.day!),
          line.count,
        ),
      LetterLineKind.showedUp => l10n.letterShowedUp(line.count),
    };
  }

  String _letterQuestion(AppLocalizations l10n, LetterQuestion question) {
    return switch (question) {
      LetterQuestion.whatBroughtYouBack => l10n.letterQuestionBroughtBack,
      LetterQuestion.whatMakesItEasier => l10n.letterQuestionEasier,
      LetterQuestion.whatDoTheyShare => l10n.letterQuestionShare,
      LetterQuestion.whatWasDifferent => l10n.letterQuestionDifferent,
      LetterQuestion.whatWouldYouMiss => l10n.letterQuestionMiss,
    };
  }

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
    final remaining = accepted == null && plan.nudges.isNotEmpty
        ? plan.nudges.length - 1
        : plan.nudges.length;

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
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: colors.textDisabled.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
          ],
          if (accepted != null)
            // One decision a month. Something has already been changed, so the
            // card stops asking and waits to see what it did.
            Text(
              l10n.planDone,
              style: _cardBody(colors).copyWith(color: colors.textPrimary),
            )
          else
            _nudge(l10n, colors, plan.nudges.first),
          if (remaining > 0) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _showAllNudges = !_showAllNudges),
              child: Text(
                l10n.planMore(remaining),
                style: _cardMeta(colors).copyWith(color: colors.ctaPrimary),
              ),
            ),
            if (_showAllNudges)
              for (final nudge
                  in plan.nudges.skip(accepted == null ? 1 : 0)) ...[
                const SizedBox(height: 18),
                _nudge(l10n, colors, nudge),
              ],
          ],
        ],
      ),
    );
  }

  Widget _nudge(
    AppLocalizations l10n,
    AppColorScheme colors,
    PlanNudge nudge,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_nudgeText(l10n, nudge), style: _cardTitle(colors)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _planAction(
              _acceptLabel(l10n, nudge.kind),
              colors,
              filled: true,
              onPressed: () => _accept(nudge, l10n),
            ),
            _planAction(
              l10n.planDecline,
              colors,
              filled: false,
              onPressed: () => _decline(nudge),
            ),
          ],
        ),
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

  /// Accepting writes the setting, then records the change and the count it
  /// will be measured against (§6.3).
  Future<void> _accept(PlanNudge nudge, AppLocalizations l10n) async {
    if (_accepting) return;
    setState(() => _accepting = true);

    final onboarding = context.read<OnboardingState>();
    final monthKey = SeasonService.monthKeyFor(DateTime.now());

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
    if (!mounted) return;
    setState(() {
      _accepting = false;
      _showAllNudges = false;
    });
    await _load();
  }

  Future<void> _decline(PlanNudge nudge) async {
    await PlanService.decline(
      nudge,
      SeasonService.monthKeyFor(DateTime.now()),
    );
    if (!mounted) return;
    await _load();
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
