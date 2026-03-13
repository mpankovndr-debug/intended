import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Flexible, Wrap, WrapAlignment, WrapCrossAlignment;
import '../widgets/app_toast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/revenue_cat_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

class PaywallScreen extends StatefulWidget {
  final String source;
  const PaywallScreen({super.key, this.source = 'unknown'});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPlan = 'yearly'; // monthly, yearly, lifetime
  bool _isLoading = false;
  late final AnimationController _bulletController;
  late final List<Animation<double>> _bulletAnimations;

  @override
  void initState() {
    super.initState();
    // Defensive check: if user is already subscribed, pop immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rc = context.read<RevenueCatService>();
      if (rc.isPremium) {
        Navigator.of(context).pop();
        return;
      }
      // Lazy-load offerings when the paywall is actually shown
      rc.ensureOfferings();
    });
    AnalyticsService.logScreenView('paywall');
    AnalyticsService.logPaywallShown(widget.source);
    _bulletController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bulletAnimations = [
      CurvedAnimation(parent: _bulletController, curve: const Interval(0.0, 0.50, curve: Curves.easeOut)),
      CurvedAnimation(parent: _bulletController, curve: const Interval(0.12, 0.62, curve: Curves.easeOut)),
      CurvedAnimation(parent: _bulletController, curve: const Interval(0.24, 0.74, curve: Curves.easeOut)),
      CurvedAnimation(parent: _bulletController, curve: const Interval(0.36, 0.86, curve: Curves.easeOut)),
      CurvedAnimation(parent: _bulletController, curve: const Interval(0.48, 1.0, curve: Curves.easeOut)),
    ];
    _bulletController.forward();
  }

  @override
  void dispose() {
    _bulletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 448),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isDark
                          ? const Alignment(-0.4, -1.0)
                          : Alignment.bottomCenter,
                      end: isDark
                          ? const Alignment(0.4, 1.0)
                          : Alignment.topCenter,
                      colors: isDark
                          ? [
                              Color.lerp(colors.onboardingBg1, colors.modalBg1, 0.5)!,
                              Color.lerp(colors.onboardingBg2, colors.modalBg2, 0.5)!,
                              Color.lerp(colors.onboardingBg3, colors.modalBg3, 0.7)!,
                            ]
                          : [
                              colors.modalBg1.withOpacity(0.96),
                              colors.modalBg2.withOpacity(0.96),
                              colors.modalBg3.withOpacity(0.96),
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(36),
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
                        offset: const Offset(0, 16),
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
                      BoxShadow(
                        color: colors.modalInnerShadow.withOpacity(0.1),
                        blurRadius: 0,
                        offset: const Offset(0, -1),
                        spreadRadius: 0,
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.ctaPrimary.withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.ctaPrimary.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.textPrimary.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                CupertinoIcons.xmark,
                                size: 16,
                                color: colors.ctaSecondary,
                              ),
                            ),
                          ),
                        ),
                        _buildTulipIcon(colors, isDark: isDark),
                        const SizedBox(height: 16),
                        Text(
                          l10n.paywallTitle,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.paywallDescription,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary.withOpacity(0.9),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              _buildAnimatedBullet(0, CupertinoIcons.lightbulb, l10n.paywallFeature1),
                              const SizedBox(height: 12),
                              _buildAnimatedBullet(1, CupertinoIcons.rectangle_on_rectangle, l10n.paywallFeature2),
                              const SizedBox(height: 12),
                              _buildAnimatedBullet(2, CupertinoIcons.cube, l10n.paywallFeature3),
                              const SizedBox(height: 12),
                              _buildAnimatedBullet(3, CupertinoIcons.paintbrush, l10n.paywallFeature4),
                              const SizedBox(height: 12),
                              _buildAnimatedBullet(4, CupertinoIcons.star, l10n.paywallFeature5),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPricingOptions(colors, l10n, isDark: isDark),
                        const SizedBox(height: 12),
                        _buildCTAButton(colors, l10n),
                        const SizedBox(height: 8),
                        _buildDisclaimer(colors, l10n),
                        const SizedBox(height: 12),
                        Text(
                          l10n.paywallFooter,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: colors.textTertiary.withOpacity(0.7),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        _buildContinueFreeSection(colors, l10n),
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
  }

  Widget _buildAnimatedBullet(int index, IconData icon, String text) {
    return AnimatedBuilder(
      animation: _bulletAnimations[index],
      builder: (context, child) {
        final value = _bulletAnimations[index].value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _FeatureItem(icon: icon, text: text),
    );
  }

  Widget _buildTulipIcon(AppColorScheme colors, {required bool isDark}) {
    final icon = SizedBox(
      width: 48,
      height: 48,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(colors.ctaPrimary, BlendMode.srcIn),
        child: Image.asset(
          'assets/images/intended_icon_transparent.png',
          width: 48,
          height: 48,
        ),
      ),
    );

    if (isDark) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.surfaceLightest,
              colors.cardBackground,
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.borderCard.withOpacity(0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: icon,
      );
    }

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(255, 255, 255, 0.4),
                Color.fromRGBO(255, 255, 255, 0.2),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: icon,
        ),
      ),
    );
  }

  Widget _buildPricingOptions(AppColorScheme colors, AppLocalizations l10n, {required bool isDark}) {
    final rc = context.read<RevenueCatService>();
    final monthlyPrice = rc.monthlyPriceString ?? l10n.paywallMonthlyPrice;
    final yearlyPrice = rc.yearlyPriceString ?? l10n.paywallYearlyPrice;
    final lifetimePrice = rc.lifetimePriceString ?? l10n.paywallLifetimePrice;
    final savingsPercent = rc.yearlySavingsPercent;
    final saveBadgeText = savingsPercent != null
        ? l10n.paywallSavePercent(savingsPercent)
        : l10n.paywallYearlySave;

    return Column(
      children: [
        // Monthly option
        _buildPricingCard(
          colors: colors,
          plan: 'monthly',
          label: l10n.paywallMonthly,
          price: monthlyPrice,
          pricePerPeriod: l10n.paywallMonthlyPeriod,
          badge: null,
          isSelected: _selectedPlan == 'monthly',
          isDark: isDark,
          onTap: () => setState(() => _selectedPlan = 'monthly'),
        ),

        const SizedBox(height: 12),

        // Yearly option (default selected)
        _buildPricingCard(
          colors: colors,
          plan: 'yearly',
          label: l10n.paywallYearly,
          price: yearlyPrice,
          pricePerPeriod: l10n.paywallYearlyPeriod,
          badge: _PricingBadge(
            text: saveBadgeText,
            primaryColor: colors.ctaPrimary,
            secondaryColor: colors.success,
          ),
          isSelected: _selectedPlan == 'yearly',
          isDark: isDark,
          onTap: () => setState(() => _selectedPlan = 'yearly'),
        ),

        const SizedBox(height: 12),

        // Lifetime option
        _buildPricingCard(
          colors: colors,
          plan: 'lifetime',
          label: l10n.paywallLifetime,
          price: lifetimePrice,
          pricePerPeriod: l10n.paywallLifetimePeriod,
          badge: _PricingBadge(
            text: l10n.paywallLifetimeBadge,
            primaryColor: colors.buttonDark,
            secondaryColor: colors.buttonDark,
          ),
          isSelected: _selectedPlan == 'lifetime',
          isDark: isDark,
          onTap: () => setState(() => _selectedPlan = 'lifetime'),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required AppColorScheme colors,
    required String plan,
    required String label,
    required String price,
    required String pricePerPeriod,
    required _PricingBadge? badge,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    Color borderColor;
    Color backgroundColor;
    Color? priceColor;
    Color? suffixColor;
    List<BoxShadow>? boxShadow;

    if (isSelected) {
      borderColor = isDark
          ? colors.ctaPrimary.withOpacity(0.6)
          : colors.ctaPrimary;
      backgroundColor = isDark
          ? colors.cardBackground.withOpacity(0.85)
          : colors.ctaPrimary.withOpacity(0.12);
      priceColor = colors.ctaPrimary;
      suffixColor = colors.ctaPrimary;
      boxShadow = isDark
          ? null
          : [
              BoxShadow(
                color: colors.ctaPrimary.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ];
    } else {
      borderColor = isDark
          ? colors.borderCard.withOpacity(0.35)
          : colors.ctaPrimary.withOpacity(0.15);
      backgroundColor = isDark
          ? colors.surfaceLight.withOpacity(0.5)
          : const Color(0xFFFFFFFF).withOpacity(0.6);
      priceColor = colors.ctaPrimary;
      suffixColor = colors.textMutedBrown;
      boxShadow = isDark
          ? null
          : [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ];
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: boxShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Label and price
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont(context),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              price,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: priceColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pricePerPeriod,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: suffixColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right: Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colors.ctaPrimary
                          : colors.textDisabled,
                      width: 2,
                    ),
                    color: isSelected
                        ? colors.ctaPrimary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          size: 12,
                          color: Color(0xFFFFFFFF),
                        )
                      : null,
                ),
              ],
            ),
          ),

          // Badge (if present)
          if (badge != null)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(child: badge),
            ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(AppColorScheme colors, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.ctaPrimary.withOpacity(0.92),
                colors.ctaSecondary.withOpacity(0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.ctaPrimary.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.3),
                blurRadius: 24,
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
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            borderRadius: BorderRadius.circular(20),
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    AnalyticsService.logPurchaseStarted(_selectedPlan);
                    try {
                      final success = await context
                          .read<RevenueCatService>()
                          .purchasePlan(_selectedPlan);
                      if (mounted && success) {
                        AnalyticsService.logPurchaseCompleted(_selectedPlan);
                        Navigator.pop(context);
                      } else {
                        AnalyticsService.logPurchaseCancelled();
                      }
                    } catch (_) {
                      AnalyticsService.logPurchaseFailed();
                      if (mounted) {
                        AppToast.show(context, l10n.boostPurchaseError);
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
            child: _isLoading
                ? const CupertinoActivityIndicator(color: Color(0xFFFFFFFF))
                : Text(
                    _selectedPlan == 'lifetime'
                        ? l10n.paywallCtaLifetime
                        : l10n.paywallCtaTrial,
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
    );
  }

  Widget _buildDisclaimer(AppColorScheme colors, AppLocalizations l10n) {
    final rc = context.read<RevenueCatService>();
    final String text;
    if (_selectedPlan == 'lifetime') {
      text = l10n.paywallLifetimeHint;
    } else {
      final price = _selectedPlan == 'yearly'
          ? '${rc.yearlyPriceString ?? l10n.paywallYearlyPrice}/${l10n.paywallYearly.toLowerCase()}'
          : '${rc.monthlyPriceString ?? l10n.paywallMonthlyPrice}/${l10n.paywallMonthly.toLowerCase()}';
      text = l10n.paywallTrialHint(price);
    }
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTextStyles.bodyFont(context),
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.textTertiary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContinueFreeSection(AppColorScheme colors, AppLocalizations l10n) {
    final separatorStyle = TextStyle(
      fontFamily: AppTextStyles.bodyFont(context),
      fontSize: 13,
      color: colors.textTertiary.withOpacity(0.5),
    );
    final linkStyle = TextStyle(
      fontFamily: AppTextStyles.bodyFont(context),
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: colors.textTertiary,
    );

    return Column(
      children: [
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8),
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.paywallContinueFree,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textTertiary,
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          runSpacing: 0,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      AnalyticsService.logRestoreStarted();
                      try {
                        final success = await context
                            .read<RevenueCatService>()
                            .restorePurchases();
                        if (mounted && success) {
                          AnalyticsService.logRestoreCompleted();
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: Text(l10n.restoreError),
                              actions: [
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  child: Text(l10n.ok),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              child: Text(l10n.paywallRestorePurchases, style: linkStyle),
            ),
            Text(' · ', style: separatorStyle),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              onPressed: () => launchUrl(
                Uri.parse('https://intendedapp.com/terms'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(l10n.paywallTerms, style: linkStyle),
            ),
            Text(' · ', style: separatorStyle),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              onPressed: () => launchUrl(
                Uri.parse('https://intendedapp.com/privacy'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(l10n.paywallPrivacy, style: linkStyle),
            ),
          ],
        ),
      ],
    );
  }
}

// Feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 20,
            color: colors.ctaPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont(context),
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: colors.textPrimary,
              height: 1.5,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}

// Pricing badge widget
class _PricingBadge extends StatelessWidget {
  final String text;
  final Color primaryColor;
  final Color secondaryColor;

  const _PricingBadge({
    required this.text,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.92),
            secondaryColor.withOpacity(0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFont(context),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFFFFFF),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
