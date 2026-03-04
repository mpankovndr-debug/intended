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

/// Shows the Boost mini-paywall bottom sheet.
///
/// [title] and [description] are contextual to the feature gate.
/// [showBoostOption] should be false if the user already owns Boost.
/// [source] is for analytics tracking.
Future<void> showBoostOfferSheet({
  required BuildContext context,
  required String title,
  required String description,
  bool showBoostOption = true,
  String source = 'unknown',
}) {
  AnalyticsService.logScreenView('boost_offer_sheet');
  return showCupertinoModalPopup(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    builder: (_) => _BoostOfferSheet(
      title: title,
      description: description,
      showBoostOption: showBoostOption,
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

  Future<void> _purchaseBoost() async {
    setState(() => _isLoading = true);
    AnalyticsService.logPurchaseStarted('boost');
    try {
      final success = await context.read<RevenueCatService>().purchaseBoost();
      if (mounted && success) {
        AnalyticsService.logPurchaseCompleted('boost');
        Navigator.pop(context);
      } else {
        AnalyticsService.logPurchaseCancelled();
      }
    } catch (_) {
      AnalyticsService.logPurchaseFailed();
      if (mounted) {
        _showErrorDialog();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog() {
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.swapErrorTitle),
        content: Text(l10n.boostPurchaseError),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
  }

  void _openPaywall() {
    Navigator.pop(context);
    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (_) => PaywallScreen(source: widget.source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.modalShadow.withOpacity(0.4),
                blurRadius: 70,
                offset: const Offset(0, -25),
              ),
              BoxShadow(
                color: const Color(0xFFFFFFFF).withOpacity(0.6),
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
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Boost card (if applicable)
                if (widget.showBoostOption) ...[
                  _buildBoostCard(colors, l10n),
                  const SizedBox(height: 20),
                  _buildOrDivider(colors, l10n),
                  const SizedBox(height: 20),
                ],

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

  Widget _buildBenefitRow(
    AppColorScheme colors,
    String benefit,
    String? detail,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                '\u2713',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            benefit,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFFFFF),
              height: 1.3,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(width: 6),
            Text(
              detail,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFFFFFFF).withOpacity(0.55),
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoostCard(AppColorScheme colors, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isLoading ? null : _purchaseBoost,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.ctaPrimary.withOpacity(0.90),
                  colors.ctaSecondary.withOpacity(0.84),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.ctaPrimary.withOpacity(0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFFFFFFFF).withOpacity(0.15),
                  blurRadius: 0,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                  blurStyle: BlurStyle.inner,
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child:
                          CupertinoActivityIndicator(color: Color(0xFFFFFFFF)),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.boostCardTitle,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.boostCardSubtitle,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFFFFFFF).withOpacity(0.70),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Benefits list
                      _buildBenefitRow(
                          colors, l10n.boostBenefit1, l10n.boostBenefit1Detail),
                      _buildBenefitRow(
                          colors, l10n.boostBenefit2, l10n.boostBenefit2Detail),
                      _buildBenefitRow(
                          colors, l10n.boostBenefit3, l10n.boostBenefit3Detail),
                      _buildBenefitRow(colors, l10n.boostBenefit4, null),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(AppColorScheme colors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 0.5,
            color: colors.divider.withOpacity(colors.dividerOpacity),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            l10n.boostOrDivider,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 0.5,
            color: colors.divider.withOpacity(colors.dividerOpacity),
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(20),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          borderRadius: BorderRadius.circular(20),
          child: Text(
            l10n.boostGoUnlimited,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.ctaPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
