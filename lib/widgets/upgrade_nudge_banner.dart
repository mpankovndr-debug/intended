import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../screens/paywall_screen.dart';
import '../services/app_usage_service.dart';
import '../state/user_state.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// A gentle, one-shot upgrade nudge banner for the home screen.
///
/// Triggers after the 5th habit completion if the user hasn't already
/// seen the paywall or dismissed this banner. Once dismissed (or tapped
/// "Learn more"), it never returns.
class UpgradeNudgeBanner extends StatefulWidget {
  const UpgradeNudgeBanner({super.key});

  @override
  State<UpgradeNudgeBanner> createState() => _UpgradeNudgeBannerState();
}

class _UpgradeNudgeBannerState extends State<UpgradeNudgeBanner>
    with SingleTickerProviderStateMixin {
  static const _shownKey = 'upgrade_nudge_shown';

  bool _visible = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    final prefs = await SharedPreferences.getInstance();

    // Already dismissed → never show again.
    if (prefs.getBool(_shownKey) == true) return;

    // Premium users don't need this.
    if (!mounted) return;
    final isPremium = context.read<UserState>().hasSubscription;
    if (isPremium) return;

    // Only show after 5+ total completions.
    final count = await AppUsageService.getTotalHabitsCompleted();
    if (count < 5) return;

    // Don't show if user already saw the paywall (they already know about Plus).
    final paywallSeen = prefs.getBool('paywall_shown_this_session') ?? false;
    if (paywallSeen) return;

    if (!mounted) return;
    setState(() => _visible = true);
    _animController.forward();
  }

  Future<void> _dismiss() async {
    await _animController.reverse();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shownKey, true);
    if (mounted) setState(() => _visible = false);
  }

  void _openPaywall() {
    _dismiss();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => const PaywallScreen(source: 'upgrade_nudge'),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    final isDark = context.read<ThemeProvider>().theme.isDark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? colors.cardBackground.withOpacity(colors.cardBackgroundOpacity)
                      : CupertinoColors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.ctaPrimary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    // Body text
                    Expanded(
                      child: Text(
                        l10n.upgradeNudgeBody,
                        style: AppTextStyles.body(context).copyWith(
                          color: colors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // "Learn more" link
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minSize: 0,
                      onPressed: _openPaywall,
                      child: Text(
                        l10n.upgradeNudgeLearnMore,
                        style: AppTextStyles.caption(context).copyWith(
                          color: colors.ctaPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Close button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 28,
                      onPressed: _dismiss,
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                    ),
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
