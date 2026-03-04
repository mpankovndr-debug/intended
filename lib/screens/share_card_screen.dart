import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/habit_l10n.dart';
import '../models/share_card_type.dart';
import '../services/milestone_service.dart';
import '../services/share_service.dart';
import '../services/week_stats_service.dart';
import '../state/user_state.dart';
import '../theme/theme_provider.dart';
import '../widgets/intention_share_card.dart';
import '../widgets/milestone_share_card.dart';

class ShareCardScreen extends StatefulWidget {
  final WeekStats stats;
  final ShareCardSelection selection;
  final MilestoneData milestoneData;

  const ShareCardScreen({
    super.key,
    required this.stats,
    required this.selection,
    required this.milestoneData,
  });

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;
  bool _cardReady = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _shimmerController.stop();
        setState(() => _cardReady = true);
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final size = MediaQuery.of(context).size;
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
          color: Colors.black.withOpacity(0.18),
          child: SafeArea(
          child: Column(
            children: [
              // Top bar — close button only
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
                      child: _buildCaptureCard(),
                    ),
                  ),
                ),
              ),

              // Card preview
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: _buildCardPreview(),
                  ),
                ),
              ),

              // Share button — theme-aware
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.buttonDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(20),
                    onPressed: _isSharing ? null : _share,
                    child: _isSharing
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.share,
                                size: 18,
                                color: CupertinoColors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Share',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildCaptureCard() {
    final l10n = AppLocalizations.of(context);

    if (!widget.selection.isMilestone) {
      return IntentionShareCard(
        completionCount: widget.stats.completionCount,
        showedUpPhrase: l10n.shareCardShowedUpPhrase,
        timesText: l10n.shareCardTimes,
        descriptorText: l10n.shareCardDescriptor,
        userName: userNameNotifier.value,
      );
    }

    final variant = widget.selection.milestoneVariant!;
    final data = widget.milestoneData;

    final String heroText;
    final String subtitleText;
    switch (variant) {
      case MilestoneVariant.showingUp:
        heroText = l10n.milestoneShowingUpHero(data.weekCount);
        subtitleText = l10n.milestoneShowingUpSubtitle;
        break;
      case MilestoneVariant.area:
        heroText = l10n.milestoneAreaHero(data.topArea ?? '');
        subtitleText = l10n.milestoneAreaSubtitle;
        break;
      case MilestoneVariant.identity:
        heroText = l10n.milestoneIdentityHero(localizeHabitName(data.topHabitName ?? '', l10n));
        subtitleText = l10n.milestoneIdentitySubtitle;
        break;
    }

    return MilestoneShareCard(
      heroText: heroText,
      subtitleText: subtitleText,
      descriptorText: l10n.shareCardDescriptor,
      userName: userNameNotifier.value,
      variant: variant,
    );
  }

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
          duration: const Duration(milliseconds: 600),
          child: _cardReady
              ? _buildRevealCard(previewWidth, previewHeight)
              : _buildShimmerSkeleton(previewWidth, previewHeight),
        );
      },
    );
  }

  Widget _buildRevealCard(double width, double height) {
    return TweenAnimationBuilder<double>(
      key: const ValueKey('card'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, progress, child) {
        final sigma = 20.0 * (1.0 - progress);
        return Opacity(
          opacity: progress,
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
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FittedBox(
            fit: BoxFit.contain,
            child: _buildCaptureCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton(double width, double height) {
    return AnimatedBuilder(
      key: const ValueKey('shimmer'),
      animation: _shimmerController,
      builder: (context, _) {
        final pos = _shimmerController.value;
        final themeColors = context.watch<ThemeProvider>().colors;
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
                        colors: const [
                          Color(0x00FFFFFF),
                          Color(0x55FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                // Placeholder content bars
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.12,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      // Hero number placeholder
                      Container(
                        width: width * 0.35,
                        height: height * 0.07,
                        decoration: BoxDecoration(
                          color: const Color(0x15000000),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      SizedBox(height: height * 0.025),
                      // Subtitle placeholder
                      Container(
                        width: width * 0.5,
                        height: height * 0.022,
                        decoration: BoxDecoration(
                          color: const Color(0x0D000000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Spacer(flex: 2),
                      // Message placeholder
                      Container(
                        width: width * 0.65,
                        height: height * 0.018,
                        decoration: BoxDecoration(
                          color: const Color(0x0D000000),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Spacer(flex: 3),
                      // Branding placeholder
                      Container(
                        width: width * 0.38,
                        height: height * 0.022,
                        decoration: BoxDecoration(
                          color: const Color(0x0D000000),
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
