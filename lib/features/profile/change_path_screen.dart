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


/// Packs that duplicate a path stay out of MORE INTENTIONS: Gentle Mornings
/// and Winding Down were promoted into paths, and Stay Connected became the
/// Closer to People path — listing them twice read as a bug, because it was
/// one (design review, SS2).
const Set<String> _packsPromotedToPaths = {
  'gentle_mornings',
  'winding_down',
  'stay_connected',
};

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

  /// The path saved when the screen opened. Ordering pivots on this, not on
  /// [_selected]: reshuffling the list under the user's finger as they tap
  /// alternatives would move the thing they are about to tap again.
  late IntentionPathId _openedWith;

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
    _openedWith = _selected;
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
    final pathTitle = path.title(l10n);

    // The app's own glass, not the system alert — the one native dialog in
    // this flow looked borrowed (design review, SS1). Mirrors the profile
    // page's modal: blurred barrier, modal gradient, one gradient CTA and a
    // ghost decline.
    final themeProvider = context.read<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final shouldUpdateAreas = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Container(
        color: colors.barrierColor.withOpacity(colors.barrierOpacity),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 384),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(0.0, 2.41),
                        end: const Alignment(0.0, -2.41),
                        colors: [
                          colors.modalBg1.withOpacity(0.96),
                          colors.modalBg2.withOpacity(0.93),
                          colors.modalBg3.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark
                            ? colors.borderCard
                                .withOpacity(colors.borderCardOpacity)
                            : const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.modalShadow.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.intentionPathUpdateFocusAreas(pathTitle),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.2,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.ctaPrimary.withOpacity(0.92),
                                  colors.ctaSecondary.withOpacity(0.88),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: colors.ctaPrimary.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: CupertinoButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              borderRadius: BorderRadius.circular(24),
                              child: Text(
                                l10n.intentionPathUpdateYes,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Text(
                              l10n.intentionPathUpdateNo,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (shouldUpdateAreas == null || !mounted) return;

    HapticFeedback.mediumImpact();

    if (shouldUpdateAreas) {
      await onboardingState.applyPathDefaults(
          path.defaultFocusAreas, path.id.key);
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
                          final path = IntentionPath.getById(_openedWith);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _PathCard(
                              path: path,
                              title: path.title(l10n),
                              subtitle: path.subtitle(l10n),
                              selected: _selected == path.id &&
                                  _selectedPackId == null,
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
                        childCount: 1,
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
                          final others = IntentionPath.pickerOptions
                              .where((p) => p.id != _openedWith)
                              .toList();
                          final packs = CuratedPacks.all
                              .where((p) =>
                                  !_packsPromotedToPaths.contains(p.id))
                              .toList();
                          if (index < others.length) {
                            final path = others[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _PathCard(
                                path: path,
                                title: path.title(l10n),
                                subtitle: path.subtitle(l10n),
                                selected: _selected == path.id &&
                                    _selectedPackId == null,
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
                          }
                          final pack = packs[index - others.length];
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
                        childCount: IntentionPath.pickerOptions.length -
                            1 +
                            CuratedPacks.all
                                .where((p) =>
                                    !_packsPromotedToPaths.contains(p.id))
                                .length,
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
