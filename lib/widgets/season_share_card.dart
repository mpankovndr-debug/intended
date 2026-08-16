import 'package:flutter/cupertino.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../theme/app_colors.dart';
import '../theme/category_colors.dart';
import '../utils/habit_l10n.dart';
import '../utils/season_l10n.dart';
import '../utils/text_styles.dart';
import 'moment_grid.dart';

/// The monthly card (§5.5) — a story, literally.
///
/// 9:16, because the place this gets posted is Instagram Stories and TikTok,
/// and a card that needs letterboxing there never gets posted. The layout is
/// the SS4 concept: the month as eyebrow, the season word as hero, the
/// first-person line under it, the grid, the legend, the count — all floating
/// on the theme's own landscape with a soft wash keeping the type legible.
///
/// ⚠️ §5.5: user-generated sharing cannot bootstrap from zero — this card's
/// real near-term job is as *your* marketing asset. Built once. Not tuned.
class SeasonShareCard extends StatelessWidget {
  const SeasonShareCard({
    super.key,
    required this.monthLabel,
    required this.seasonWord,
    required this.seasonPole,
    required this.moments,
    required this.returnCount,
    required this.gapsShortening,
    required this.theme,
    required this.l10n,
  });

  /// Localised, e.g. "August 2026". Rendered uppercased.
  final String monthLabel;
  final String seasonWord;

  /// The stable pole key, so the card can resolve its own first-person line
  /// rather than have the word and the sentence assembled in two places.
  final String seasonPole;

  final List<Moment> moments;
  final int returnCount;
  final bool gapsShortening;
  final AppTheme theme;
  final AppLocalizations l10n;

  /// Story canvas: 9:16, captured at 3x → 1080×1920.
  static const double width = 360;
  static const double height = 640;

  /// Every string on this card is the user's own language, so the face has to
  /// follow the locale — Sora has no Cyrillic, and the whole Russian card was
  /// silently rendering in the iOS system font.
  String get _font => AppTextStyles.displayFontFor(l10n.localeName);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(theme);
    final isDark = theme.isDark;
    // The wash between the landscape and the type — the "internal gradient"
    // every earlier card carried. Light themes breathe white; dark ones
    // deepen their own ground instead of graying it.
    final wash = isDark ? colors.bgGradientTop : const Color(0xFFFFFFFF);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_backgroundForTheme(theme, colors), fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.42, 1.0],
                colors: [
                  wash.withValues(alpha: 0.55),
                  wash.withValues(alpha: 0.14),
                  wash.withValues(alpha: 0.42),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 54, 26, 40),
            child: Column(
              children: [
                // "MY SEASON · AUGUST 2026". The card is read by people who
                // have never opened the app, and a bare noun under a month
                // is not a sentence — naming the thing is what makes «Вечер»
                // legible as a label rather than a random word. It rides in
                // the eyebrow because no other slot fits: the hero can't hold
                // «сезон» without a construction that works for all eight
                // words, and no Russian construction does.
                Text(
                  '${l10n.shareSeasonLabel} · ${monthLabel.toUpperCase()}',
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    color: colors.ctaPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                // Fixed height so the grid lands on the same line every month.
                // Cards posted in a row are the point; a hero that changes
                // height shifts everything under it between posts.
                SizedBox(
                  height: 84,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Three deliberate steps rather than the arbitrary
                      // fractions BoxFit.scaleDown produced — 44.8 and 41.2pt
                      // read as drift, not decisions. FittedBox stays as the
                      // never-clip net for languages not yet measured.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          seasonWord,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: _font,
                            fontSize: heroSizeFor(seasonWord, _font),
                            height: 1.05,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // The sentence that makes the word mean something. It
                      // used to be absent, and the slot held the gaps line —
                      // a finding from a different axis entirely, which read
                      // as an explanation and explained nothing.
                      Text(
                        SeasonL10n.shareLine(seasonPole, l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: _font,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 296,
                    child: MomentGrid(
                      moments: moments,
                      theme: theme,
                      tileSize: 30,
                      spacing: 8,
                      showGhost: false,
                      lightenReturns: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _legend(colors),
                const SizedBox(height: 14),
                Text(
                  returnCount > 0
                      ? '${l10n.shareSeasonMoments(moments.length)} · '
                          '${l10n.shareSeasonReturns(returnCount)}'
                      : l10n.shareSeasonMoments(moments.length),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                // Shortening gaps are a fact *about the returns*, so they sit
                // with the returns and read as the rest of that sentence —
                // rather than under the season word, where they claimed to
                // explain a reading they have nothing to do with.
                if (gapsShortening && returnCount > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    l10n.shareSeasonGaps,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _font,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    _iconAssetForTheme(theme),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'INTENDED',
                  style: TextStyle(
                    // The wordmark, not copy: Latin in every locale, so it
                    // stays in the brand face while the rest follows language.
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 5,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.shareCardTagline,
                  style: TextStyle(
                    fontFamily: _font,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Type steps for the hero, largest first.
  static const List<double> heroSteps = [46, 42, 38];

  /// The width the hero has: the canvas less its padding, less a little air
  /// so a word never touches the edge it technically fits inside.
  static const double heroMaxWidth = 296;

  /// The largest step at which [word] fits [heroMaxWidth], measured.
  ///
  /// Counting characters picks the wrong step: «Постоянство» and
  /// «Возвращение» are both eleven letters and differ by 28pt at the same
  /// size, because «щ» is far wider than «о». One rule would either shrink a
  /// word that fit or clip one that did not.
  ///
  /// A pure static rather than a method needing a BuildContext, so a test can
  /// call it — this is the layout rule, and layout rules are what regress.
  static double heroSizeFor(String word, String fontFamily) {
    for (final size in heroSteps) {
      final painter = TextPainter(
        text: TextSpan(
          text: word,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: size,
            height: 1.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (painter.width <= heroMaxWidth) return size;
    }
    return heroSteps.last;
  }

  /// "● Health 28 · ● Self-care 8 · ● Mood 4" — the grid's own legend, so the
  /// story explains its colours the way the app does (SS4).
  Widget _legend(AppColorScheme colors) {
    final counts = <String, int>{};
    for (final m in moments) {
      final c = m.category;
      if (c != null) counts[c] = (counts[c] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final e in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CategoryColors.of(e.key, theme),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${localizeCategoryName(e.key, l10n)} ${e.value}',
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: 12.5,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// The story's landscape. Iris has a dedicated painting; every other theme
  /// falls back to its own moments-screen art until it gets one.
  static String _backgroundForTheme(AppTheme theme, AppColorScheme colors) =>
      switch (theme) {
        AppTheme.iris => 'assets/images/Iris_share_bg.PNG',
        AppTheme.clearSky => 'assets/images/clearSky_1080x1920.png',
        AppTheme.forestFloor => 'assets/images/forestFloor_1080x1920.png',
        AppTheme.goldenHour => 'assets/images/goldenHour_1080x1920.png',
        AppTheme.morningSlate => 'assets/images/morningSlate_1080x1920.png',
        AppTheme.sandDune => 'assets/images/sandDune_1080x1920.png',
        AppTheme.softDusk => 'assets/images/softDusk_1080x1920.png',
        AppTheme.warmClay => 'assets/images/warmClay_1080x1920.png',
        // The two dark themes still borrow the moments-screen art until their
        // dedicated story canvases land.
        _ => colors.backgroundMs,
      };

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
