import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/moment.dart';
import '../services/share_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/season_share_card.dart';

/// Presents the monthly story the way the weekly reveal always has: the page
/// stays live behind it — dimmed and blurred by the modal barrier, exactly
/// like the paywall — a shimmer skeleton "generates" for a beat, the card
/// resolves from blur to sharp, and only then does Share slide up.
///
/// The pause is not decoration. A card that pops instantly reads as a
/// template; one that takes a moment reads as *made from your month* — which
/// it is. Same timings as the weekly reveal, so the two ceremonies feel like
/// one ritual.
class SeasonShareScreen extends StatefulWidget {
  const SeasonShareScreen({
    super.key,
    required this.seasonWord,
    required this.seasonPole,
    required this.month,
    required this.moments,
    required this.returnCount,
    required this.gapsShortening,
  });

  final String seasonWord;
  final String seasonPole;

  /// First day of the month being shared — the pager can share past months,
  /// so "now" is not necessarily the month on the card (review finding #10).
  final DateTime month;

  final List<Moment> moments;
  final int returnCount;
  final bool gapsShortening;

  @override
  State<SeasonShareScreen> createState() => _SeasonShareScreenState();
}

class _SeasonShareScreenState extends State<SeasonShareScreen>
    with TickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _cardReady = false;

  late final AnimationController _shimmerController;
  late final AnimationController _shareButtonController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shareButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // The weekly reveal's clock, tightened a notch on request: shimmer for
    // 1.2s, then the card, then the button a beat later.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _shimmerController.stop();
      setState(() => _cardReady = true);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _shareButtonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _shareButtonController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_sharing || !_cardReady) return;
    setState(() => _sharing = true);
    final size = MediaQuery.of(context).size;
    try {
      await WidgetsBinding.instance.endOfFrame;
      await ShareService.shareCard(
        _cardKey,
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      // Presented via showCupertinoModalPopup with the paywall's barrier:
      // the Insights page itself stays behind this, dimmed and blurred by the
      // route — real depth, not repainted scenery.
      child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 22,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        child: _buildCardPreview(),
                      ),
                    ),
                  ),
                  _buildShareButton(colors),
                ],
              ),
      ),
    );
  }

  Widget _buildCardPreview() {
    const cardAspect = SeasonShareCard.width / SeasonShareCard.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        double previewWidth;
        double previewHeight;
        if (maxWidth / maxHeight > cardAspect) {
          previewHeight = maxHeight;
          previewWidth = previewHeight * cardAspect;
        } else {
          previewWidth = maxWidth;
          previewHeight = previewWidth / cardAspect;
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _cardReady
              ? _buildRevealCard(previewWidth, previewHeight)
              : _buildShimmerSkeleton(previewWidth, previewHeight),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Reveal: blur → sharp + subtle scale, same curve as the weekly card
  // ---------------------------------------------------------------------------

  Widget _buildRevealCard(double width, double height) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('card'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        final sigma = 24.0 * (1.0 - progress);
        final scale = 0.92 + 0.08 * progress;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: sigma > 0.5
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: sigma,
                      sigmaY: sigma,
                      tileMode: TileMode.decal,
                    ),
                    child: child,
                  )
                : child,
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 40,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Rounded for the preview only — the clip sits outside the
        // RepaintBoundary, so the exported story stays a clean 9:16 rectangle.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FittedBox(
            fit: BoxFit.contain,
            child: RepaintBoundary(
              key: _cardKey,
              child: Builder(builder: (context) {
                final l10n = AppLocalizations.of(context);
                final themeProvider = context.watch<ThemeProvider>();
                final locale = Localizations.localeOf(context).toString();
                return SeasonShareCard(
                  // Standalone month + year, not yMMMM: Russian's yMMMM ends
                  // in « г.», which uppercases to a stray "Г." in a headline.
                  monthLabel: '${DateFormat.LLLL(locale).format(widget.month)} '
                      '${widget.month.year}',
                  seasonWord: widget.seasonWord,
                  seasonPole: widget.seasonPole,
                  moments: widget.moments,
                  returnCount: widget.returnCount,
                  gapsShortening: widget.gapsShortening,
                  theme: themeProvider.theme,
                  l10n: l10n,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shimmer skeleton — the "being made" beat, borrowed whole from the weekly
  // ---------------------------------------------------------------------------

  Widget _buildShimmerSkeleton(double width, double height) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeColors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;

    final shimmerPeak =
        isDark ? const Color(0x28FFFFFF) : const Color(0x55FFFFFF);
    final barStrong = isDark ? const Color(0x0A000000) : const Color(0x15000000);
    final barLight = isDark ? const Color(0x06000000) : const Color(0x0D000000);

    return AnimatedBuilder(
      key: const ValueKey('shimmer'),
      animation: _shimmerController,
      builder: (context, _) {
        final pos = _shimmerController.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                themeColors.surfaceLightest,
                themeColors.surfaceLight,
                themeColors.surfaceLightest,
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.5 + 3.0 * pos, -0.3),
                        end: Alignment(-0.5 + 3.0 * pos, 0.3),
                        colors: [
                          const Color(0x00FFFFFF),
                          shimmerPeak,
                          const Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                // Ghost of the story's layout: eyebrow, hero word, grid rows,
                // stats, branding.
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.12),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.09),
                      Container(
                        width: width * 0.35,
                        height: height * 0.018,
                        decoration: BoxDecoration(
                          color: barLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Container(
                        width: width * 0.6,
                        height: height * 0.055,
                        decoration: BoxDecoration(
                          color: barStrong,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      // The tiles breathe in sequence — the month being
                      // laid down one square at a time, not a static ghost.
                      for (var row = 0; row < 2; row++) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < 6; i++)
                              Builder(builder: (context) {
                                final phase =
                                    (pos * 2 * math.pi) - (row * 6 + i) * 0.55;
                                final breath =
                                    0.45 + 0.55 * (0.5 + 0.5 * math.sin(phase));
                                return Opacity(
                                  opacity: breath,
                                  child: Container(
                                    width: width * 0.085,
                                    height: width * 0.085,
                                    margin: EdgeInsets.all(width * 0.011),
                                    decoration: BoxDecoration(
                                      color: barStrong,
                                      borderRadius:
                                          BorderRadius.circular(width * 0.024),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ],
                      SizedBox(height: height * 0.04),
                      Container(
                        width: width * 0.55,
                        height: height * 0.016,
                        decoration: BoxDecoration(
                          color: barLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: width * 0.38,
                        height: height * 0.02,
                        decoration: BoxDecoration(
                          color: barLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: height * 0.07),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Share — slides up once the card exists
  // ---------------------------------------------------------------------------

  Widget _buildShareButton(dynamic colors) {
    final slideUp = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _shareButtonController,
      curve: Curves.easeOutCubic,
    ));
    final isDark = context.watch<ThemeProvider>().theme.isDark;

    // A light pill (SS1): on the deep-dimmed barrier a bare label sank into
    // the dark; a filled light button reads as the one thing left to do.
    return SlideTransition(
      position: slideUp,
      child: FadeTransition(
        opacity: _shareButtonController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: CupertinoButton(
            padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
            borderRadius: BorderRadius.circular(26),
            color: isDark
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.18)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.94),
            onPressed: _sharing ? null : _share,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.share,
                  size: 20,
                  color: isDark ? colors.textPrimary : colors.buttonDark,
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context).shareButton,
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark ? colors.textPrimary : colors.buttonDark,
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
