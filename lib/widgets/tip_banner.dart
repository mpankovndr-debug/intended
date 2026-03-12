import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/tips_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

class TipBanner extends StatefulWidget {
  final int tipIndex;
  /// Called with the next tip index (or null if tips are done).
  final ValueChanged<int?> onDismissed;

  const TipBanner({
    super.key,
    required this.tipIndex,
    required this.onDismissed,
  });

  @override
  State<TipBanner> createState() => _TipBannerState();
}

class _TipBannerState extends State<TipBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Fade in after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGotIt() async {
    if (_dismissed) return;
    _dismissed = true;
    final nextIndex = await TipsService.dismissCurrentTip();
    await _controller.reverse();
    if (mounted) widget.onDismissed(nextIndex);
  }

  Future<void> _handleSkip() async {
    if (_dismissed) return;
    _dismissed = true;
    await TipsService.skipAllTips();
    await _controller.reverse();
    if (mounted) widget.onDismissed(null);
  }

  String _getTipText(AppLocalizations l10n) {
    switch (widget.tipIndex) {
      case 0:
        return l10n.tipPinHabit;
      case 1:
        return l10n.tipCuratedPack;
      case 2:
        return l10n.tipWidget;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final isLast = TipsService.isLastTip(widget.tipIndex);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                decoration: BoxDecoration(
                  color: colors.ctaPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.ctaPrimary.withOpacity(0.15),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon + text row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            CupertinoIcons.lightbulb,
                            size: 18,
                            color: colors.ctaPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getTipText(l10n),
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                              height: 1.4,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Action buttons
                    Row(
                      children: [
                        _buildGotItButton(colors, l10n),
                        if (!isLast) ...[
                          const SizedBox(width: 12),
                          _buildSkipButton(colors, l10n),
                        ],
                      ],
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

  Widget _buildGotItButton(AppColorScheme colors, AppLocalizations l10n) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      minSize: 0,
      borderRadius: BorderRadius.circular(10),
      color: colors.ctaPrimary.withOpacity(0.15),
      onPressed: _handleGotIt,
      child: Text(
        l10n.tipGotIt,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFont(context),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.ctaPrimary,
        ),
      ),
    );
  }

  Widget _buildSkipButton(AppColorScheme colors, AppLocalizations l10n) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      minSize: 0,
      onPressed: _handleSkip,
      child: Text(
        l10n.tipSkipAll,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFont(context),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colors.textTertiary,
        ),
      ),
    );
  }
}
