import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class FocusAreaCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const FocusAreaCard({
    super.key,
    required this.label,
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
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.selected
                ? [
                    colors.onboardingBg2.withOpacity(0.7),
                    colors.onboardingBg2.withOpacity(0.5),
                  ]
                : [
                    colors.cardBrowse.withOpacity(colors.cardBrowseOpacity),
                    colors.surfaceLight.withOpacity(0.25),
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: widget.selected
                ? colors.ctaPrimary.withOpacity(0.3)
                : const Color(0xFFFFFFFF).withOpacity(0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary
                  .withOpacity(widget.selected ? 0.12 : 0.06),
              blurRadius: widget.selected ? 16 : 10,
              offset:
                  widget.selected ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.selected
                          ? [
                              colors.ctaPrimary.withOpacity(0.2),
                              colors.ctaPrimary.withOpacity(0.1),
                            ]
                          : [
                              colors.borderMedium.withOpacity(0.2),
                              colors.borderMedium.withOpacity(0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color:
                        widget.selected ? colors.ctaPrimary : colors.accentMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (widget.selected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.ctaPrimary,
                      colors.ctaSecondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withOpacity(0.25),
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
    );
  }
}
