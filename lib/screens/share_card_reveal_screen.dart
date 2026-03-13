import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/reflection_data.dart';
import '../services/share_service.dart';
import '../services/week_stats_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import '../widgets/tiered_share_card.dart';

// ---------------------------------------------------------------------------
// Custom route that expands the card from the share-button origin
// ---------------------------------------------------------------------------

class ShareCardRevealRoute extends PageRoute<void> {
  final WeekStats stats;
  final ReflectionData reflection;
  final Rect? originRect;

  ShareCardRevealRoute({
    required this.stats,
    required this.reflection,
    this.originRect,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return ShareCardRevealScreen(
      stats: stats,
      reflection: reflection,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Simple fade — the card preview handles its own scale/reveal internally
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// The reveal screen itself
// ---------------------------------------------------------------------------

class ShareCardRevealScreen extends StatefulWidget {
  final WeekStats stats;
  final ReflectionData reflection;

  const ShareCardRevealScreen({
    super.key,
    required this.stats,
    required this.reflection,
  });

  @override
  State<ShareCardRevealScreen> createState() => _ShareCardRevealScreenState();
}

class _ShareCardRevealScreenState extends State<ShareCardRevealScreen>
    with TickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;
  bool _cardReady = false;

  late final AnimationController _shimmerController;
  late final AnimationController _shareButtonController;

  @override
  void initState() {
    super.initState();

    // Shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Share button entrance
    _shareButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Reveal after shimmer plays
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _shimmerController.stop();
        setState(() => _cardReady = true);
        // Slide in the share button after the card appears
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _shareButtonController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _shareButtonController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    final size = MediaQuery.of(context).size;
    try {
      await WidgetsBinding.instance.endOfFrame;
      await ShareService.shareCard(
        _repaintKey,
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.18),
          child: SafeArea(
            child: Column(
              children: [
                // Top bar — close button
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

                // Hidden full-size card for capture
                ClipRect(
                  child: SizedBox(
                    width: 0,
                    height: 0,
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxWidth: 1080,
                      maxHeight: 1920,
                      child: RepaintBoundary(
                        key: _repaintKey,
                        child: TieredShareCard(
                          stats: widget.stats,
                          reflection: widget.reflection,
                        ),
                      ),
                    ),
                  ),
                ),

                // Card preview with animation
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: _buildCardPreview(),
                    ),
                  ),
                ),

                // Share button — slides up after reveal
                _buildShareButton(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Share button with slide-up entrance
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

    return SlideTransition(
      position: slideUp,
      child: FadeTransition(
        opacity: _shareButtonController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 14),
            onPressed: _isSharing ? null : _share,
            child: _isSharing
                ? CupertinoActivityIndicator(color: colors.textSecondary)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.share,
                        size: 16,
                        color: isDark
                            ? colors.textSecondary
                            : colors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).shareButton,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? colors.textSecondary
                              : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card preview — shimmer → reveal
  // ---------------------------------------------------------------------------

  Widget _buildCardPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cardAspect = 1080 / 1920;
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final previewAspect = maxWidth / maxHeight;

        double previewWidth;
        double previewHeight;

        if (previewAspect > cardAspect) {
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
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _cardReady
              ? _buildRevealCard(previewWidth, previewHeight)
              : _buildShimmerSkeleton(previewWidth, previewHeight),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Reveal: blur → sharp + subtle scale
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FittedBox(
            fit: BoxFit.contain,
            child: TieredShareCard(
              stats: widget.stats,
              reflection: widget.reflection,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shimmer skeleton with floating particles
  // ---------------------------------------------------------------------------

  Widget _buildShimmerSkeleton(double width, double height) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeColors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;

    // Dimmer shimmer for dark themes
    final shimmerPeak = isDark ? const Color(0x28FFFFFF) : const Color(0x55FFFFFF);
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
                // Shimmer sweep
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
                // Placeholder content bars
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.12),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      // Hero number placeholder
                      Container(
                        width: width * 0.35,
                        height: height * 0.07,
                        decoration: BoxDecoration(
                          color: barStrong,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(height: height * 0.025),
                      // Subtitle placeholder
                      Container(
                        width: width * 0.5,
                        height: height * 0.022,
                        decoration: BoxDecoration(
                          color: barLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Spacer(flex: 2),
                      // Message placeholder
                      Container(
                        width: width * 0.65,
                        height: height * 0.018,
                        decoration: BoxDecoration(
                          color: barLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Spacer(flex: 3),
                      // Branding placeholder
                      Container(
                        width: width * 0.38,
                        height: height * 0.022,
                        decoration: BoxDecoration(
                          color: barLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: height * 0.06),
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
}
