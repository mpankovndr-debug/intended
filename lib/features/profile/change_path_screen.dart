import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart' show AppBackground;
import '../../models/curated_pack.dart';
import '../../models/intention_path.dart';
import '../../onboarding_v2/onboarding_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../../utils/text_styles.dart';

String _resolvePathTitle(AppLocalizations l10n, String titleKey) {
  switch (titleKey) {
    case 'pathGentleMorningsTitle':
      return l10n.pathGentleMorningsTitle;
    case 'pathAnchorsForHardDaysTitle':
      return l10n.pathAnchorsForHardDaysTitle;
    case 'pathQuietFocusTitle':
      return l10n.pathQuietFocusTitle;
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
    case 'pathAnchorsForHardDaysSubtitle':
      return l10n.pathAnchorsForHardDaysSubtitle;
    case 'pathQuietFocusSubtitle':
      return l10n.pathQuietFocusSubtitle;
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
  /// The band under the Save button, pulled toward the card surface. At the
  /// raw gradient-bottom colour it sat at the background's most saturated
  /// stop and read as a coloured bar rather than a fade (design review, SS7).
  Color _scrim(AppColorScheme colors) =>
      Color.lerp(colors.bgGradientBottom, colors.cardBackground, 0.45)!;

  late IntentionPathId _selected;

  /// Selected curated pack, when the user chose one of the merged intentions
  /// instead of a path. Mutually exclusive with a path change.
  String? _selectedPackId;

  ({String name, String subtitle}) _localizedPack(
    AppLocalizations l10n,
    CuratedPack pack,
  ) =>
      switch (pack.id) {
        'gentle_mornings' => (
            name: l10n.packGentleMorningsName,
            subtitle: l10n.packGentleMorningsSubtitle
          ),
        'winding_down' => (
            name: l10n.packWindingDownName,
            subtitle: l10n.packWindingDownSubtitle
          ),
        'tiny_resets' => (
            name: l10n.packTinyResetsName,
            subtitle: l10n.packTinyResetsSubtitle
          ),
        'creative_spark' => (
            name: l10n.packCreativeSparkName,
            subtitle: l10n.packCreativeSparkSubtitle
          ),
        'stay_connected' => (
            name: l10n.packStayConnectedName,
            subtitle: l10n.packStayConnectedSubtitle
          ),
        _ => (name: pack.name, subtitle: pack.subtitle),
      };

  /// Adopting a pack (§7: packs and paths are one feature). Redirects the
  /// catalog actions and focus areas; customs stay; the Today header keeps
  /// the path phrase — an intention is *why*, a pack is *what this month*.
  Future<void> _adoptPack(CuratedPack pack) async {
    final onboarding = context.read<OnboardingState>();
    HapticFeedback.mediumImpact();

    final catalog = onboarding.userHabits
        .where((h) => !onboarding.isCustomHabit(h))
        .toList();
    await onboarding.setAsideHabits(catalog);
    await onboarding.addHabitsFromPack(pack.habitIds);
    await onboarding.applyPackFocusAreas(pack.focusAreas);

    if (mounted) Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    final currentKey = context.read<OnboardingState>().selectedIntentionPath;
    _selected = IntentionPathId.fromKey(currentKey);
  }

  Future<void> _handleSave() async {
    final onboardingState = context.read<OnboardingState>();
    final currentId = IntentionPathId.fromKey(onboardingState.selectedIntentionPath);

    final packId = _selectedPackId;
    if (packId != null) {
      final pack =
          CuratedPacks.all.where((p) => p.id == packId).firstOrNull;
      if (pack != null) {
        await _adoptPack(pack);
        return;
      }
    }

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
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final path = IntentionPath.pickerOptions[index];
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
                                setState(() {
                                  _selected = path.id;
                                  _selectedPackId = null;
                                });
                              },
                            ),
                          );
                        },
                        childCount: IntentionPath.pickerOptions.length,
                      ),
                    ),
                  ),
                  // §7: packs and onboarding intentions are the same feature
                  // under two names. The packs live here as intentions you can
                  // adopt — same cards, same door. Adopting redirects the
                  // catalog actions and focus areas; it never grows the list.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 18, 24, 12),
                      child: Text(
                        l10n.pathMoreIntentions,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 120 + bottomPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final pack = CuratedPacks.all[index];
                          final lp = _localizedPack(l10n, pack);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _PathCard(
                              title: lp.name,
                              subtitle: lp.subtitle,
                              selected: _selectedPackId == pack.id,
                              isDark: isDark,
                              colors: colors,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedPackId =
                                    _selectedPackId == pack.id
                                        ? null
                                        : pack.id);
                              },
                            ),
                          );
                        },
                        childCount: CuratedPacks.all.length,
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
                            // Full strength at the bottom — a 0.9 stop drew a
                            // seam against the solid band below (SS3).
                            colors: [
                              _scrim(colors).withValues(alpha: 0.0),
                              _scrim(colors),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: _scrim(colors),
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
    this.path,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.isDark,
    required this.colors,
    required this.onTap,
  });

  final IntentionPath? path;
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
    // The theme's own accent, not the path's fixed one. Four fixed hues
    // cannot sit right on ten palettes — an amber card on Iris reads as a
    // visitor from another app. Selection is state, and state speaks in the
    // theme's voice everywhere else; the paths stay distinct by name, which
    // is how they differ anyway (design review, SS2/SS7).
    final accent = widget.colors.ctaPrimary;
    final sel = widget.selected;
    final colors = widget.colors;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        // The profile's glass, flat — no tinted gradient, no blur. The
        // white-to-accent fill read as a stain on most palettes (design
        // review, SS7); selection now speaks entirely through the border and
        // the check, which is how the rest of the app says "chosen".
        decoration: BoxDecoration(
          color: colors.profileCard.withValues(alpha: colors.profileCardOpacity),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: sel
                ? accent.withValues(alpha: 0.85)
                : widget.isDark
                    ? colors.borderCard
                        .withValues(alpha: colors.borderCardOpacity)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.6),
            width: sel ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sel
                  ? accent.withValues(alpha: 0.18)
                  : colors.textPrimary.withValues(alpha: 0.04),
              blurRadius: sel ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
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
    );
  }
}
