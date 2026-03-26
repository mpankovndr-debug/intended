import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

class FocusAreaCard extends StatefulWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const FocusAreaCard({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<FocusAreaCard> createState() => _FocusAreaCardState();
}

class _FocusAreaCardState extends State<FocusAreaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final sel = widget.selected;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: sel ? 0.12 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: sel
                      ? [
                          colors.ctaPrimary.withValues(alpha: 0.18),
                          colors.onboardingBg2.withValues(alpha: 0.55),
                        ]
                      : [
                          const Color(0xFFFFFFFF).withValues(alpha: 0.65),
                          colors.surfaceLight.withValues(alpha: 0.60),
                        ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: sel
                      ? colors.ctaPrimary.withValues(alpha: 0.35)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.40),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: sel
                            ? [
                                colors.ctaPrimary,
                                colors.ctaSecondary,
                              ]
                            : [
                                colors.borderMedium.withValues(alpha: 0.20),
                                colors.borderMedium.withValues(alpha: 0.10),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: sel ? const Color(0xFFFFFFFF) : colors.accentMuted,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colors.textPrimary.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (sel)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.ctaPrimary, colors.ctaSecondary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark,
                        size: 13,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
