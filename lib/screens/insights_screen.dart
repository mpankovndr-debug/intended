import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/moments_service.dart';
import '../services/notification_preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../main.dart' show AppBackground;
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
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();
    if (!mounted) return;
    setState(() {
      _moments = moments;
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
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
            ],
            ],
          ],
        ),
      ),
    );
  }

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
          Text(
            monthLabel,
            style: AppTextStyles.body(context)
                .copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            empty
                ? l10n.insightsEmptyTitle
                : l10n.insightsDidThings(
                    _moments.length,
                    DateFormat.MMMM(
                      Localizations.localeOf(context).toString(),
                    ).format(now),
                  ),
            style: AppTextStyles.h2(context).copyWith(fontSize: 19),
          ),
          const SizedBox(height: 6),
          if (empty)
            Text(
              l10n.insightsEmptyBody,
              style: AppTextStyles.body(context)
                  .copyWith(color: colors.textSecondary),
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
            style: AppTextStyles.body(context).copyWith(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
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
          Text(
            l10n.insightsStartingWith,
            style: AppTextStyles.body(context).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: colors.ctaPrimary,
            ),
          ),
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
                  child: Text(habit, style: AppTextStyles.body(context)),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          Text(
            l10n.insightsStartingMeta(areas, _reminderTime),
            style: AppTextStyles.body(context).copyWith(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
