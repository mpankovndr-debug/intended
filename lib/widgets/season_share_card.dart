import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../theme/app_colors.dart';
import 'moment_grid.dart';

/// The monthly card (§5.5) — rare, event-like, one a month.
///
/// Built to the concept the weekly card already follows: a light frosted card
/// floating over the app's own landscape, not a full-bleed poster. The first
/// version was a flat gradient sheet and looked like it came from another app
/// — this one shares its glass with every other card in the product.
///
/// **The season word is the hero, not the number.** A big "37" invites
/// comparison, and comparison is the thing this app removed. The one italic
/// line under it is first-person and only appears when it is true of this
/// user's month.
///
/// ⚠️ §5.5: user-generated sharing cannot bootstrap from zero — the card's
/// real near-term job is as *your* marketing asset. Built once. Not tuned.
class SeasonShareCard extends StatelessWidget {
  const SeasonShareCard({
    super.key,
    required this.monthLabel,
    required this.seasonWord,
    required this.moments,
    required this.returnCount,
    required this.gapsShortening,
    required this.theme,
    required this.l10n,
  });

  /// Localised, e.g. "August 2026". Rendered uppercased.
  final String monthLabel;
  final String seasonWord;
  final List<Moment> moments;
  final int returnCount;

  /// Shows the "my gaps are getting shorter" line — only when the month
  /// actually says so.
  final bool gapsShortening;
  final AppTheme theme;
  final AppLocalizations l10n;

  /// Design width. Captured at 3x → a 1080-wide image.
  static const double width = 360;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(theme);
    final isDark = theme.isDark;

    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
      decoration: BoxDecoration(
        // The weekly reveal card's surface: modal glass, not poster ink.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.modalBg1.withValues(alpha: 0.97),
            colors.modalBg2.withValues(alpha: 0.94),
            colors.modalBg3.withValues(alpha: 0.97),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? colors.borderCard.withValues(alpha: colors.borderCardOpacity)
              : const Color(0xFFFFFFFF).withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.modalShadow.withValues(alpha: 0.18),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            monthLabel.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: colors.ctaPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            seasonWord,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 44,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          if (gapsShortening) ...[
            const SizedBox(height: 6),
            Text(
              l10n.shareSeasonGaps,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 26),
          // Centred like the concept — the grid is the artefact here, not a
          // data readout hugging a margin.
          Center(
            child: SizedBox(
              width: 296,
              child: MomentGrid(
                moments: moments,
                theme: theme,
                tileSize: 30,
                spacing: 8,
                showGhost: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.insightsGridCaption,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              color: colors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            returnCount > 0
                ? '${l10n.shareSeasonMoments(moments.length)} · '
                    '${l10n.shareSeasonReturns(returnCount)}'
                : l10n.shareSeasonMoments(moments.length),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              _iconAssetForTheme(theme),
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'INTENDED',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.shareCardTagline,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

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
