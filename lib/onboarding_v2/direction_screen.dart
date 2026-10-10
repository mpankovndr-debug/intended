import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/intention_path.dart';
import '../services/analytics_service.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';
import 'onboarding_state.dart';
import 'widgets/onboarding_scaffold.dart';

/// Onboarding, screen 2 (spec §6): pick a direction.
///
/// One of the nine paths; "Your own way" stays out of the picker (decided
/// 30 Sep). The choice sets the default focus areas and pre-fills the
/// sentence on the next screen. Focus areas are no longer a screen of their
/// own: they follow the path, and can be changed on "Start small".
class DirectionScreen extends StatefulWidget {
  const DirectionScreen({super.key, required this.onContinue, this.onBack});

  /// Called once the choice is saved. The flow decides what comes next.
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  @override
  State<DirectionScreen> createState() => _DirectionScreenState();
}

class _DirectionScreenState extends State<DirectionScreen> {
  IntentionPathId? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Coming back to this screen keeps the choice already made.
    final previous = context.read<OnboardingState>().lastPreselectedPathKey;
    if (previous != null) _selected = IntentionPathId.fromKey(previous);
  }

  Future<void> _continue() async {
    final id = _selected;
    if (id == null || _saving) return;
    _saving = true;
    HapticFeedback.mediumImpact();
    final state = context.read<OnboardingState>();
    await state.setSelectedIntentionPath(id.key);
    // Re-choosing the same path keeps focus areas the person already changed.
    if (state.lastPreselectedPathKey != id.key) {
      await state.applyPathDefaults(
        IntentionPath.getById(id).defaultFocusAreas,
        id.key,
      );
    }
    AnalyticsService.logOnboardingStepCompleted('direction');
    _saving = false;
    if (mounted) widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingScaffold(
      place: OnboardingPlace.direction,
      onBack: widget.onBack,
      title: l10n.onboardingDirectionTitle,
      subtitle: l10n.onboardingDirectionSubtitle,
      ctaLabel: l10n.commonContinue,
      onCta: _selected == null ? null : _continue,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          28,
          24,
          28,
          OnboardingScaffold.contentBottomPadding,
        ),
        children: [
          for (final path in IntentionPath.pickerOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DirectionCard(
                path: path,
                title: path.title(l10n),
                subtitle: path.subtitle(l10n),
                selected: _selected == path.id,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selected = path.id);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// One direction: its glyph, title and subtitle on glass tinted with the
/// path's own colour, which deepens when chosen.
class DirectionCard extends StatelessWidget {
  const DirectionCard({
    super.key,
    required this.path,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IntentionPath path;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final accent = path.accentColor;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? accent.withValues(alpha: 0.22)
                    : colors.textPrimary.withValues(alpha: 0.08),
                blurRadius: selected ? 22 : 16,
                spreadRadius: selected ? 1 : 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: selected
                        ? [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.80),
                            accent.withValues(alpha: 0.38),
                          ]
                        : [
                            const Color(0xFFFFFFFF).withValues(alpha: 0.65),
                            colors.surfaceLight.withValues(alpha: 0.60),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected
                        ? accent.withValues(alpha: 0.72)
                        : const Color(0xFFFFFFFF).withValues(alpha: 0.40),
                    width: selected ? 2.0 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(path.iconAsset, width: 52, height: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: colors.textPrimary.withValues(alpha: 0.55),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 12),
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
      ),
    );
  }
}
