import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../onboarding_v2/focus_areas_screen.dart';

/// Onboarding philosophy interstitial shown after focus-area selection.
///
/// Renders a frosted-glass card over a blurred replica of the user's
/// focus-area picks, reinforcing the app's gentle, no-pressure ethos.
class PhilosophyScreen extends StatefulWidget {
  final VoidCallback onContinue;

  /// Focus-area identifiers the user selected on the previous screen
  /// (e.g. `['Health', 'Mood']`).
  final List<String> selectedAreas;

  const PhilosophyScreen({
    required this.onContinue,
    required this.selectedAreas,
    super.key,
  });

  @override
  State<PhilosophyScreen> createState() => _PhilosophyScreenState();
}

class _PhilosophyScreenState extends State<PhilosophyScreen>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _animCtrl;

  // Card-level scale + fade
  late final Animation<double> _cardScale;
  late final Animation<double> _cardFade;

  // Staggered content fade-ins
  late final Animation<double> _labelFade;
  late final Animation<double> _headingFade;
  late final Animation<double> _bodyFade;
  late final Animation<double> _ctaFade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final cardCurve = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(cardCurve);
    _cardFade = Tween<double>(begin: 0, end: 1).animate(cardCurve);

    _labelFade = _staggerFade(0.0, 0.5);
    _headingFade = _staggerFade(0.15, 0.65);
    _bodyFade = _staggerFade(0.30, 0.80);
    _ctaFade = _staggerFade(0.45, 1.0);

    _animCtrl.forward();
  }

  Animation<double> _staggerFade(double begin, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.9, -1),
            end: Alignment(0.9, 1),
            colors: [
              Color(0xFFF5EDE0),
              Color(0xFFE8DCC8),
              Color(0xFFDDD1C0),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── LAYER 1: Blurred background pills ──
            _buildBlurredBackground(),

            // ── LAYER 2: Graduated warm fog overlay ──
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x14E6DACA), // 0.08
                    Color(0x38E6DACA), // 0.22
                    Color(0x94E4D7C6), // 0.58
                    Color(0xE0E0D2C0), // 0.88 (0xE0 ≈ 224)
                    Color(0xF8DCCDBA), // 0.97 (0xF8 ≈ 248)
                    Color(0xFFDACCB6), // 1.0
                  ],
                  stops: [0.0, 0.28, 0.50, 0.64, 0.75, 1.0],
                ),
              ),
            ),

            // ── LAYER 3: Label + glassmorphism card ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ScaleTransition(
                scale: _cardScale,
                child: FadeTransition(
                  opacity: _cardFade,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Label
                          FadeTransition(
                            opacity: _labelFade,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                l10n.onboardingPhilosophyLabel.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF8C7A6B),
                                  letterSpacing: 1.9,
                                ),
                              ),
                            ),
                          ),

                          // Card
                          _buildGlassCard(l10n),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Blurred background (actual FocusAreasScreen, non-interactive) ─

  Widget _buildBlurredBackground() {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: const FocusAreasScreen(),
      ),
    );
  }

  // ─── Glassmorphism card ───────────────────────────────────────────

  Widget _buildGlassCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24645541),
            blurRadius: 56,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x0F645541),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 32, 22, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xF0F5EEE5),
                  Color(0xE0EDE4D8),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0x9EFFFFFF),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heading
                FadeTransition(
                  opacity: _headingFade,
                  child: Text(
                    l10n.onboardingPhilosophyHeading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C342A),
                      height: 1.28,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Body
                FadeTransition(
                  opacity: _bodyFade,
                  child: Text(
                    l10n.onboardingPhilosophyBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7A6B5F),
                      height: 1.65,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // CTA button
                FadeTransition(
                  opacity: _ctaFade,
                  child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) {
                    setState(() => _pressed = false);
                    HapticFeedback.mediumImpact();
                    widget.onContinue();
                  },
                  onTapCancel: () => setState(() => _pressed = false),
                  child: AnimatedScale(
                    scale: _pressed ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8B7563),
                            Color(0xFF7A6B5F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x47645541),
                            blurRadius: 18,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.onboardingPhilosophyCta,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
