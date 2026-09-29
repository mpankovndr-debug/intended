import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart' show AppBackground;
import '../models/moment.dart';
import '../models/season.dart';
import '../services/moments_service.dart';
import '../services/notification_scheduler.dart';
import '../services/season_service.dart';
import '../state/user_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/season_l10n.dart';
import '../utils/text_styles.dart';
import '../widgets/moment_grid.dart';
import 'insights_screen.dart';
import 'paywall_screen.dart';

/// The months, standing together (§4.4's archive as a place).
///
/// "How far I've come" needs somewhere to stand and look back from — a
/// chevron pressed eleven times is browsing, not standing. One row per month:
/// the frozen season word, the month's grid in miniature, the count. Tap a
/// row and the month page opens on it.
///
/// This replaces the date-indexed moments list, which §4.2 contradicted from
/// the day the grid shipped: it showed the same data as the grid, sorted the
/// way a streak app would sort it.
///
/// The words are the paid archive (§4.4): free sees every month's mass — the
/// grids and counts are "what happened" and stay free — while past words
/// dissolve mid-display the way every locked sentence in this app does.
/// Never a padlock.
class YearInSeasonsScreen extends StatefulWidget {
  const YearInSeasonsScreen({super.key});

  @override
  State<YearInSeasonsScreen> createState() => _YearInSeasonsScreenState();
}

class _MonthRow {
  const _MonthRow({
    required this.anchor,
    required this.moments,
    this.word,
    required this.isCurrent,
  });

  final DateTime anchor;
  final List<Moment> moments;

  /// The season word for the row, or null when the month never earned one.
  final String? word;
  final bool isCurrent;
}

class _YearInSeasonsScreenState extends State<YearInSeasonsScreen> {
  List<_MonthRow>? _rows;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await MomentsService.getAll();
    final archive = await SeasonService.archive();
    final now = DateTime.now();

    // Group by the wall-clock month each moment recorded.
    final byMonth = <String, List<Moment>>{};
    for (final m in all) {
      final local = m.completedAt.add(Duration(minutes: m.tzOffsetMinutes));
      final key = SeasonService.monthKeyFor(local);
      byMonth.putIfAbsent(key, () => []).add(m);
    }

    final currentKey = SeasonService.monthKeyFor(now);
    final keys = {...byMonth.keys, currentKey}.toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    final rows = <_MonthRow>[];
    for (final key in keys) {
      final bits = key.split('-');
      final anchor = DateTime(int.parse(bits[0]), int.parse(bits[1]), 1);
      final moments = (byMonth[key] ?? [])
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
      final isCurrent = key == currentKey;

      // Closed months keep their frozen word; the open month reads live. A
      // closed month that never reached the threshold has no word — the slot
      // stays empty rather than holding a permanent "Beginning" shrug.
      String? pole;
      if (isCurrent) {
        pole = Season.read(key, moments).pole;
        if (pole == Season.beginning) pole = null;
      } else {
        pole = archive[key]?.pole;
      }

      rows.add(_MonthRow(
        anchor: anchor,
        moments: moments,
        word: pole,
        isCurrent: isCurrent,
      ));
    }

    if (!mounted) return;
    setState(() => _rows = rows);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final paid = context.watch<UserState>().hasSubscription;
    final rows = _rows;

    final gutter = (MediaQuery.of(context).size.width - 680) / 2;
    final pad = gutter > 24 ? gutter : 24.0;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: AppBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(pad, 12, pad, 120),
            children: [
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      size: 26,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.yearInSeasonsTitle,
                      style: AppTextStyles.h1(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (rows != null) ...[
                for (var i = 0; i < rows.length; i++) ...[
                  _monthRow(l10n, colors, themeProvider, rows[i],
                      paid: paid),
                  if (i != rows.length - 1) const SizedBox(height: 12),
                ],
                if (!paid && rows.any((r) => !r.isCurrent && r.word != null))
                  _unlockFooter(l10n, colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _monthRow(
    AppLocalizations l10n,
    AppColorScheme colors,
    ThemeProvider themeProvider,
    _MonthRow row, {
    required bool paid,
  }) {
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(row.anchor);
    final word = row.word == null ? null : _seasonWord(l10n, row.word!);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        // The month page opens on this month: hand the anchor to Insights,
        // front its tab, and clear this screen off the stack.
        InsightsScreen.jumpTo.value = row.anchor;
        // Notify even if the value is already 1 — a stale unconsumed 1 from a
        // cold-start notification would otherwise swallow the switch.
        NotificationScheduler.pendingTabSwitch.value = -1;
        NotificationScheduler.pendingTabSwitch.value = 1;
        // One level: this screen was pushed over the tabs. popUntil(isFirst)
        // overshot in the first session, where onboarding leaves routes under
        // MainTabs, and dropped the user back into the path picker.
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.profileCard.withValues(alpha: colors.profileCardOpacity),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    monthLabel,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  l10n.profileMomentsCount(row.moments.length),
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: colors.textSecondary.withValues(alpha: 0.7),
                ),
              ],
            ),
            if (word != null) ...[
              const SizedBox(height: 6),
              // The current word is free (§4.4); the archive of past words is
              // what Intended+ keeps. A locked word dissolves — never a lock.
              paid || row.isCurrent
                  ? Text(
                      word,
                      style: AppTextStyles.h2(context).copyWith(
                        fontSize: 24,
                        color: colors.textPrimary,
                      ),
                    )
                  : ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rect) => const LinearGradient(
                        colors: [Color(0xFF000000), Color(0x00000000)],
                        stops: [0.15, 0.85],
                      ).createShader(rect),
                      child: Text(
                        word,
                        style: AppTextStyles.h2(context).copyWith(
                          fontSize: 24,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
            ],
            if (row.moments.isNotEmpty) ...[
              const SizedBox(height: 12),
              MomentGrid(
                moments: row.moments,
                theme: themeProvider.theme,
                tileSize: 12,
                spacing: 4,
                showGhost: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _unlockFooter(AppLocalizations l10n, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Center(
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          borderRadius: BorderRadius.circular(22),
          color: colors.ctaPrimary,
          minimumSize: Size.zero,
          onPressed: () => showCupertinoModalPopup<void>(
            context: context,
            barrierColor: const Color(0x80000000),
            builder: (_) => const PaywallScreen(source: 'season_archive'),
          ),
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
    );
  }

  String _seasonWord(AppLocalizations l10n, String pole) =>
      SeasonL10n.word(pole, l10n);
}
