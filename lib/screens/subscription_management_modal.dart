import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// Modal for managing active Intended+ subscription
/// Shows subscription details and opens App Store for management
class SubscriptionManagementModal extends StatelessWidget {
  final String plan;
  final String price;
  final String renewalDate;

  const SubscriptionManagementModal({
    super.key,
    required this.plan,
    required this.price,
    required this.renewalDate,
  });

  Future<void> _openAppStoreSubscriptions() async {
    HapticFeedback.mediumImpact();

    // iOS App Store subscriptions URL
    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    return Container(
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
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
                  decoration: isDark
                      ? BoxDecoration(
                          color: colors.cardBackground
                              .withOpacity(colors.cardBackgroundOpacity),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: colors.borderCard
                                .withOpacity(colors.borderCardOpacity),
                            width: 1,
                          ),
                        )
                      : BoxDecoration(
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
                            color:
                                const Color(0xFFFFFFFF).withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.modalShadow.withOpacity(0.2),
                              blurRadius: 40,
                              offset: const Offset(0, -16),
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFFFFF)
                                  .withOpacity(0.25),
                              blurRadius: 0,
                              offset: const Offset(0, 1),
                              spreadRadius: 0,
                              blurStyle: BlurStyle.inner,
                            ),
                          ],
                        ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Column(
                        children: [
                          Text(
                            l10n.subscriptionTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: -0.4,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.subscriptionSupporter,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: colors.ctaPrimary,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Plan Details Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: isDark
                                ? BoxDecoration(
                                    color: colors.cardBackground
                                        .withOpacity(colors.cardBackgroundOpacity),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colors.borderCard
                                          .withOpacity(colors.borderCardOpacity),
                                      width: 1,
                                    ),
                                  )
                                : BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFFFFFFF).withOpacity(0.45),
                                        colors.surfaceLight.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFFFFFF).withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.textPrimary.withOpacity(0.06),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFFFFFFF).withOpacity(0.2),
                                        blurRadius: 0,
                                        offset: const Offset(0, 1),
                                        spreadRadius: 0,
                                        blurStyle: BlurStyle.inner,
                                      ),
                                    ],
                                  ),
                            child: Column(
                              children: [
                                // Plan row
                                _buildDetailRow(context, l10n.subscriptionPlan, plan, colors),

                                const SizedBox(height: 16),

                                // Divider
                                Container(
                                  height: 1,
                                  color: colors.ctaPrimary.withOpacity(0.15),
                                ),

                                const SizedBox(height: 16),

                                // Price row
                                _buildDetailRow(context, l10n.subscriptionPrice, price, colors),

                                const SizedBox(height: 16),

                                // Divider
                                Container(
                                  height: 1,
                                  color: colors.ctaPrimary.withOpacity(0.15),
                                ),

                                const SizedBox(height: 16),

                                // Renewal row
                                _buildDetailRow(context, l10n.subscriptionRenews, renewalDate, colors),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Thank you message
                      Text(
                        l10n.subscriptionThankYou,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: colors.ctaPrimary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Primary button - Manage in App Store
                      SizedBox(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colors.ctaPrimary,
                                    colors.ctaSecondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: isDark
                                    ? null
                                    : Border.all(
                                        color: colors.ctaPrimary.withOpacity(0.4),
                                        width: 1,
                                      ),
                                boxShadow: isDark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: colors.ctaPrimary.withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
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
                              child: CupertinoButton(
                                onPressed: _openAppStoreSubscriptions,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                borderRadius: BorderRadius.circular(20),
                                child: Text(
                                  l10n.subscriptionManage,
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
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Close button (ghost)
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l10n.commonClose,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 16,
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
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, AppColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFont(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.ctaPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFont(context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
