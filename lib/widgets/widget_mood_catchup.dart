import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../services/analytics_service.dart';
import '../services/moments_service.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
import '../utils/text_styles.dart';

/// Offers the mood tap to moments that arrived without one (§5.2's data,
/// caught up).
///
/// The home-screen widget records completions but can't ask how they landed,
/// so a heavy widget user's mosaic loses its texture and what-lifts-you
/// starves — the more convenient the path, the worse the data. On the next
/// open, each recent unrated widget moment gets one quiet card: the same
/// three pills, one tap, skippable. Never more than [maxPerOpen], never older
/// than [lookback] — catch-up is a courtesy, not homework.
class WidgetMoodCatchup {
  WidgetMoodCatchup._();

  static const int maxPerOpen = 3;
  static const Duration lookback = Duration(hours: 48);
  static bool _showing = false;

  /// Which moments still owe an answer, oldest first.
  ///
  /// Pulled out of [maybeShow] so it can be tested at all: the rest of that
  /// method needs a BuildContext and a Navigator, which meant the one part
  /// with real rules in it — the source, the lookback, the ordering — had no
  /// way to be checked.
  static List<Moment> pending(List<Moment> all, {DateTime? now}) {
    final cutoff = (now ?? DateTime.now()).toUtc().subtract(lookback);
    return all
        .where((m) =>
            m.source == 'widget' &&
            m.mood == null &&
            m.completedAt.isAfter(cutoff))
        .toList()
      // Oldest first: asked in the order they happened, so the answers line
      // up with the day the person is remembering.
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
  }

  static Future<void> maybeShow(BuildContext context) async {
    if (_showing) return;
    final unrated = pending(await MomentsService.getAll());
    if (unrated.isEmpty) return;

    _showing = true;
    try {
      for (final moment in unrated.take(maxPerOpen)) {
        if (!context.mounted) return;
        await _showOne(context, moment);
      }
    } finally {
      _showing = false;
    }
  }

  static Future<void> _showOne(BuildContext context, Moment moment) {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _CatchupCard(moment: moment),
    );
  }
}

class _CatchupCard extends StatelessWidget {
  const _CatchupCard({required this.moment});

  final Moment moment;

  Future<void> _pick(BuildContext context, MomentMood? mood) async {
    HapticFeedback.selectionClick();
    AnalyticsService.logMoodResponse(mood?.key);
    if (mood != null) {
      await MomentsService.annotate(moment.id, mood: mood);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final local = moment.localWallClock;
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final time =
        '$hour:${local.minute.toString().padLeft(2, '0')} ${local.hour < 12 ? 'AM' : 'PM'}';

    Widget pill(String label, MomentMood mood) => CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          minimumSize: Size.zero,
          borderRadius: BorderRadius.circular(18),
          color: colors.bgGradientTop.withValues(alpha: 0.6),
          onPressed: () => _pick(context, mood),
          child: Text(
            label,
            style: AppTextStyles.body(context).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
        );

    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(28),
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
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.widgetCatchupEyebrow,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: colors.ctaPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  localizeHabitName(moment.habitName, l10n),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2(context).copyWith(fontSize: 19),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.completionHowDidItLand,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 14,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    pill(l10n.completionMoodGlad, MomentMood.gladIDid),
                    pill(l10n.completionMoodNeutral, MomentMood.neutral),
                    pill(l10n.completionMoodTookEffort, MomentMood.tookEffort),
                  ],
                ),
                const SizedBox(height: 6),
                CupertinoButton(
                  onPressed: () => _pick(context, null),
                  child: Text(
                    l10n.completionSkip,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 13,
                      color: colors.textTertiary,
                    ),
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
