import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../screens/paywall_screen.dart';
import '../services/analytics_service.dart';
import '../services/revenue_cat_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// Opens the full paywall modal. Use after [showBoostOfferSheet] returns
/// `'paywall'` to show the paywall from the correct context.
void openPaywallFromContext(BuildContext context, {String source = 'boost', bool triggeredByCeiling = false}) {
  if (!context.mounted) return;
  if (context.read<RevenueCatService>().isPremium) return;
  showCupertinoModalPopup(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    builder: (_) => PaywallScreen(source: source, triggeredByCeiling: triggeredByCeiling),
  );
}

/// Shows the Boost mini-paywall bottom sheet.
///
/// Returns `'paywall'` if the user tapped "Go unlimited", so the caller
/// can handle showing the full paywall from its own context.
Future<String?> showBoostOfferSheet({
  required BuildContext context,
  required String title,
  required String description,
  // Boost is retired from sale (v2 pricing, §8): the mini-tier sold removed
  // restrictions — the exact thing §1 says premium must not be — and its
  // cheap yes cannibalised the trial. Existing owners keep their entitlement;
  // this sheet now only ever opens the door to the real paywall.
  bool showBoostOption = false,
  String source = 'unknown',
}) {
  AnalyticsService.logScreenView('boost_offer_sheet');
  return showCupertinoModalPopup<String>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    builder: (_) => _BoostOfferSheet(
      title: title,
      description: description,
      showBoostOption: false,
      source: source,
    ),
  );
}

class _BoostOfferSheet extends StatefulWidget {
  final String title;
  final String description;
  final bool showBoostOption;
  final String source;

  const _BoostOfferSheet({
    required this.title,
    required this.description,
    required this.showBoostOption,
    required this.source,
  });

  @override
  State<_BoostOfferSheet> createState() => _BoostOfferSheetState();
}

class _BoostOfferSheetState extends State<_BoostOfferSheet> {
  bool _isLoading = false;




  void _openPaywall() {
    Navigator.pop(context, 'paywall');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isDark
                  ? const Alignment(-0.4, -1.0)
                  : const Alignment(0.0, 2.41),
              end: isDark
                  ? const Alignment(0.4, 1.0)
                  : const Alignment(0.0, -2.41),
              colors: isDark
                  ? [
                      Color.lerp(colors.onboardingBg1, colors.modalBg1, 0.5)!,
                      Color.lerp(colors.onboardingBg2, colors.modalBg2, 0.5)!,
                      Color.lerp(colors.onboardingBg3, colors.modalBg3, 0.7)!,
                    ]
                  : [
                      colors.modalBg1.withOpacity(0.96),
                      colors.modalBg2.withOpacity(0.93),
                      colors.modalBg3.withOpacity(0.95),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark
                  ? colors.borderCard.withOpacity(0.4)
                  : const Color(0xFFFFFFFF).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.modalShadow.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, -16),
              ),
              BoxShadow(
                color: isDark
                    ? colors.borderCard.withOpacity(0.12)
                    : const Color(0xFFFFFFFF).withOpacity(0.25),
                blurRadius: 0,
                offset: const Offset(0, 1),
                spreadRadius: 0,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textDisabled.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Go unlimited button
                _buildUnlimitedButton(colors, l10n),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnlimitedButton(AppColorScheme colors, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.ctaPrimary.withOpacity(0.12),
              colors.ctaSecondary.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.ctaPrimary.withOpacity(0.30),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.ctaPrimary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CupertinoButton(
          onPressed: _isLoading ? null : _openPaywall,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          borderRadius: BorderRadius.circular(24),
          child: Text(
            l10n.boostGoUnlimited,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.ctaPrimary,
              letterSpacing: -0.2,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}
