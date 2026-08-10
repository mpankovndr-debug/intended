import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../theme/app_colors.dart';
import 'moment_grid.dart';

/// The monthly card (§5.5) — rare, event-like, one a month.
///
/// The other share card is the workhorse: humble, weekly, fifty-two chances a
/// year. This one is the occasion, and it is built to a different brief.
///
/// **The season word is the hero, not the number.** A big "37" invites
/// comparison — with other people, and with your own last month — and
/// comparison is the thing this app removed. A word invites nothing; it just
/// says what the month was.
///
/// **"intention, not perfection" is at legible size.** It was the smallest
/// text on the previous card while being the strongest line on it, which is
/// backwards for the one element that has to survive being seen at thumbnail
/// size in someone else's feed.
///
/// ⚠️ §5.5 is explicit that user-generated sharing cannot bootstrap from zero:
/// one person posting to two hundred followers gets a couple of likes, where
/// Wrapped works because millions post at once. The card's real near-term job
/// is as *your* marketing asset — you post it. So it is built once, cheaply,
/// and then left alone. Resist tuning it.
class SeasonShareCard extends StatelessWidget {
  const SeasonShareCard({
    super.key,
    required this.seasonWord,
    required this.moments,
    required this.returnCount,
    required this.theme,
    required this.l10n,
  });

  final String seasonWord;
  final List<Moment> moments;
  final int returnCount;
  final AppTheme theme;
  final AppLocalizations l10n;

  /// Fixed canvas. A share card is an image, not a layout — it must render the
  /// same on every device, so nothing here reads MediaQuery.
  static const double width = 1080;
  static const double height = 1350;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(theme);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(90, 110, 90, 80),
      decoration: BoxDecoration(gradient: _background(colors)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.seasonLabel,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 30,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: colors.ctaPrimary,
            ),
          ),
          const SizedBox(height: 26),
          // The hero. One word, and nothing on the card competes with it.
          Text(
            seasonWord,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 132,
              height: 1.05,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 64),
          MomentGrid(
            moments: moments,
            theme: theme,
            tileSize: 62,
            spacing: 16,
            showGhost: false,
          ),
          const SizedBox(height: 34),
          Text(
            l10n.insightsGridCaption,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 26,
              color: colors.textSecondary,
            ),
          ),
          const Spacer(),
          // First person, because this is the user speaking to their own feed
          // — and no habit names, ever. The weekly card asks before including
          // them; this one goes to a wider room than that consent covers.
          Text(
            returnCount > 0
                ? '${l10n.shareSeasonMoments(moments.length)} · '
                    '${l10n.shareSeasonReturns(returnCount)}'
                : l10n.shareSeasonMoments(moments.length),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 54),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  _iconAssetForTheme(theme),
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'INTENDED',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Legible, finally. This is the line that has to work at
                  // thumbnail size in a stranger's feed.
                  Text(
                    l10n.shareCardTagline,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _background(AppColorScheme colors) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.bgGradientTop,
          colors.bgGradientMid,
          colors.bgGradientBottom,
        ],
      );

  static String _iconAssetForTheme(AppTheme theme) => switch (theme) {
        AppTheme.warmClay => 'assets/images/intended-icon-warmclay-1024.png',
        AppTheme.iris => 'assets/images/intended-icon-iris-1024.png',
        AppTheme.clearSky => 'assets/images/intended-icon-clearsky-1024.png',
        AppTheme.morningSlate =>
          'assets/images/intended-icon-morningslate-1024.png',
        AppTheme.softDusk => 'assets/images/intended-icon-softdusk-1024.png',
        AppTheme.forestFloor =>
          'assets/images/intended-icon-forestfloor-1024.png',
        AppTheme.goldenHour => 'assets/images/intended-icon-goldenhour-1024.png',
        AppTheme.sandDune => 'assets/images/intended-icon-sanddune-1024.png',
        AppTheme.deepFocus => 'assets/images/intended-icon-deepfocus-1024.png',
        AppTheme.nightBloom => 'assets/images/intended-icon-nightbloom-1024.png',
      };
}
