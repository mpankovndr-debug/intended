import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart' show AppBackground;
import '../../models/intention_path.dart';
import '../../onboarding_v2/onboarding_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../../utils/text_styles.dart';

String _resolvePathTitle(AppLocalizations l10n, String titleKey) {
  switch (titleKey) {
    case 'pathGentleMorningsTitle':
      return l10n.pathGentleMorningsTitle;
    case 'pathFindingCalmTitle':
      return l10n.pathFindingCalmTitle;
    case 'pathGratitudeSelfLoveTitle':
      return l10n.pathGratitudeSelfLoveTitle;
    case 'pathWindingDownTitle':
      return l10n.pathWindingDownTitle;
    case 'pathYourOwnWayTitle':
      return l10n.pathYourOwnWayTitle;
    default:
      return titleKey;
  }
}

String _resolvePathSubtitle(AppLocalizations l10n, String subtitleKey) {
  switch (subtitleKey) {
    case 'pathGentleMorningsSubtitle':
      return l10n.pathGentleMorningsSubtitle;
    case 'pathFindingCalmSubtitle':
      return l10n.pathFindingCalmSubtitle;
    case 'pathGratitudeSelfLoveSubtitle':
      return l10n.pathGratitudeSelfLoveSubtitle;
    case 'pathWindingDownSubtitle':
      return l10n.pathWindingDownSubtitle;
    case 'pathYourOwnWaySubtitle':
      return l10n.pathYourOwnWaySubtitle;
    default:
      return subtitleKey;
  }
}

class ChangePathScreen extends StatefulWidget {
  const ChangePathScreen({super.key});

  @override
  State<ChangePathScreen> createState() => _ChangePathScreenState();
}

class _ChangePathScreenState extends State<ChangePathScreen> {
  late IntentionPathId _selected;

  @override
  void initState() {
    super.initState();
    final currentKey = context.read<OnboardingState>().selectedIntentionPath;
    _selected = IntentionPathId.fromKey(currentKey);
  }

  Future<void> _handleSave() async {
    final onboardingState = context.read<OnboardingState>();
    final currentId = IntentionPathId.fromKey(onboardingState.selectedIntentionPath);

    if (_selected == currentId) {
      Navigator.pop(context);
      return;
    }

    final l10n = AppLocalizations.of(context);
    final path = IntentionPath.getById(_selected);
    final pathTitle = _resolvePathTitle(l10n, path.titleKey);

    final shouldUpdateAreas = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.intentionPathUpdateFocusAreas(pathTitle)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.intentionPathUpdateNo),
          ),
          CupertinoDialogAction(
            isDestructiveAction: false,
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.intentionPathUpdateYes),
          ),
        ],
      ),
    );

    if (shouldUpdateAreas == null || !mounted) return;

    HapticFeedback.mediumImpact();

    if (shouldUpdateAreas) {
      onboardingState.applyPathDefaults(path.defaultFocusAreas, path.id.key);
      await onboardingState.setSelectedIntentionPath(path.id.key);
      await onboardingState.generateUserHabits();
    } else {
      await onboardingState.setSelectedIntentionPath(path.id.key);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.transparent,
      child: AppBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, topPadding + 16, 24, 8),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            onPressed: () => Navigator.pop(context),
                            child: Icon(
                              CupertinoIcons.chevron_back,
                              color: colors.ctaPrimary,
                              size: 22,
                            ),
                          ),
                          Text(
                            l10n.profileYourPath,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 120 + bottomPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final path = IntentionPath.all[index];
                          final isSelected = _selected == path.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _PathCard(
                              path: path,
                              title: _resolvePathTitle(l10n, path.titleKey),
                              subtitle: _resolvePathSubtitle(l10n, path.subtitleKey),
                              selected: isSelected,
                              isDark: isDark,
                              colors: colors,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selected = path.id);
                              },
                            ),
                          );
                        },
                        childCount: IntentionPath.all.length,
                      ),
                    ),
                  ),
                ],
              ),

              // Gradient fade + Save button pinned at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IgnorePointer(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors.bgGradientBottom.withValues(alpha: 0.0),
                              colors.bgGradientBottom.withValues(alpha: 0.92),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: colors.bgGradientBottom,
                      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: colors.ctaPrimary,
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: _handleSave,
                          child: Text(
                            l10n.commonSave,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatefulWidget {
  const _PathCard({
    required this.path,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.isDark,
    required this.colors,
    required this.onTap,
  });

  final IntentionPath path;
  final String title;
  final String subtitle;
  final bool selected;
  final bool isDark;
  final AppColorScheme colors;
  final VoidCallback onTap;

  @override
  State<_PathCard> createState() => _PathCardState();
}

class _PathCardState extends State<_PathCard> {
  @override
  Widget build(BuildContext context) {
    final accent = widget.path.accentColor;
    final sel = widget.selected;
    final colors = widget.colors;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: sel
                  ? accent.withValues(alpha: 0.22)
                  : colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: sel ? 22 : 16,
              spreadRadius: sel ? 1 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: sel
                      ? [
                          const Color(0xFFFFFFFF).withValues(
                              alpha: widget.isDark ? 0.18 : 0.80),
                          accent.withValues(alpha: 0.38),
                        ]
                      : [
                          const Color(0xFFFFFFFF).withValues(
                              alpha: widget.isDark ? 0.10 : 0.65),
                          colors.surfaceLight.withValues(alpha: 0.60),
                        ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: sel
                      ? accent.withValues(alpha: 0.72)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.40),
                  width: sel ? 2.0 : 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: colors.textPrimary.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sel) ...[
                    const SizedBox(width: 14),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark,
                        size: 14,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
