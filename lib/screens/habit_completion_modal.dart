import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/moment.dart';
import '../services/moments_service.dart';
import '../services/milestone_service.dart';
import '../services/analytics_service.dart';
import '../services/backup_service.dart';
import '../widgets/warmth_toast_overlay.dart';
import '../main.dart';
import '../utils/completion_messages.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// Modal for completing a habit with smooth animations
/// Implements the full completion sequence from design specs
class HabitCompletionModal extends StatefulWidget {
  final String habitTitle;
  final bool isPremium;

  const HabitCompletionModal({
    super.key,
    required this.habitTitle,
    this.isPremium = false,
  });

  @override
  State<HabitCompletionModal> createState() => _HabitCompletionModalState();
}

class _HabitCompletionModalState extends State<HabitCompletionModal>
    with TickerProviderStateMixin {
  late AnimationController _buttonScaleController;
  late AnimationController _colorController;
  late AnimationController _modalExitController;
  late AnimationController _heartScaleController;

  late Animation<double> _buttonScaleAnimation;
  late Animation<Color?> _buttonColorAnimation;
  late Animation<double> _modalScaleAnimation;
  late Animation<double> _modalFadeAnimation;
  // Modal entrance animations
  late AnimationController _modalEntranceController;
  late Animation<double> _modalEntranceScaleAnimation;
  late Animation<double> _modalEntranceFadeAnimation;
  // Content stagger animations
  late AnimationController _contentStaggerController;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<double> _secondaryButtonFadeAnimation;

  late Animation<double> _heartScaleAnimation;

  bool _isPressed = false;
  bool _showCelebration = false;
  String _celebrationTitle = '';
  String _celebrationMessage = '';

  @override
  void initState() {
    super.initState();

    // Button scale animation (95% on press)
    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeOut),
    );

    // Button color transition (brown → dusty rose)
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _buttonColorAnimation = ColorTween(
      begin: context.read<ThemeProvider>().colors.ctaPrimary,
      end: context.read<ThemeProvider>().colors.completionHeart,
    ).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeOut),
    );

    // Modal exit animation (scale down + fade)
    _modalExitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _modalScaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _modalExitController, curve: Curves.easeOut),
    );
    _modalFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _modalExitController, curve: Curves.easeOut),
    );

    // Modal entrance animation (scale 98% → 100% + fade in)
    _modalEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _modalEntranceScaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _modalEntranceController, curve: Curves.easeOutCubic),
    );
    _modalEntranceFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _modalEntranceController, curve: Curves.easeOut),
    );

    // Content stagger animation
    _contentStaggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentStaggerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentStaggerController,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
      ),
    );
    _secondaryButtonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentStaggerController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start entrance animations
    _modalEntranceController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _contentStaggerController.forward();
    });

    // Heart scale animation (celebration)
    _heartScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartScaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _buttonScaleController.dispose();
    _colorController.dispose();
    _modalExitController.dispose();
    _modalEntranceController.dispose();
    _contentStaggerController.dispose();
    _heartScaleController.dispose();
    super.dispose();
  }

  void _handleButtonPress() {
    setState(() {
      _isPressed = true;
    });
    _buttonScaleController.forward();
  }

  void _handleButtonRelease() async {
    if (!_isPressed) return;

    // Release scale animation
    _buttonScaleController.reverse();

    // Start color transition
    _colorController.forward();

    // Premium: satisfying double-tap; Free: single tap
    if (widget.isPremium) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    // Mark as done
    await HabitTracker.markDone(widget.habitTitle);
    AnalyticsService.logHabitCompleted(widget.habitTitle);

    // Record the moment
    await MomentsService.record(
      Moment(
        id: DateTime.now().toUtc().toIso8601String(),
        habitName: widget.habitTitle,
        habitEmoji: '✦',
        completedAt: DateTime.now().toUtc(),
      ),
    );
    MilestoneService.invalidate();
    if (mounted) context.read<BackupService>().backup();

    // Wait for color transition to complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Show celebration
    if (mounted) {
      setState(() {
        _showCelebration = true;
        final l10n = AppLocalizations.of(context);
        _celebrationTitle = CompletionMessages.getCelebrationTitle(l10n);
        _celebrationMessage = CompletionMessages.getMessage(widget.habitTitle, l10n);
      });

      // Start heart animation
      _heartScaleController.forward();

      // Wait to show celebration
      await Future.delayed(const Duration(milliseconds: 1800));

      // Dismiss modal with slide-down animation
      if (mounted) {
        await _modalExitController.forward();
        if (mounted) {
          Navigator.pop(context, true); // Return true = completed
        }
      }
    }
  }

  void _handleNotToday() {
    HapticFeedback.lightImpact();
    final navigatorContext = Navigator.of(context).context;
    Navigator.pop(context, false);
    WarmthToastOverlay.show(navigatorContext);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    final isDark = themeProvider.theme.isDark;
    // isDark used in barrier color below

    return AnimatedBuilder(
      animation: _modalEntranceController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _modalFadeAnimation,
          child: ScaleTransition(
            scale: _modalScaleAnimation,
            child: Container(
              color: (isDark ? colors.barrierColor : colors.textPrimary).withOpacity(
                (isDark ? 0.65 : 0.50) * _modalEntranceFadeAnimation.value,
              ),
              child: FadeTransition(
                opacity: _modalEntranceFadeAnimation,
                child: ScaleTransition(
                  scale: _modalEntranceScaleAnimation,
                  child: Center(
                    child: _showCelebration
                        ? _buildCelebrationView(colors)
                        : _buildQuestionView(colors),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionView(AppColorScheme colors) {
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.theme.isDark;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 384),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.modalShadow.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.0, 1.0),
                end: const Alignment(0.0, -1.0),
                colors: [
                  colors.modalBg1.withOpacity(isDark ? 0.75 : 1.0),
                  colors.modalBg2.withOpacity(isDark ? 0.70 : 1.0),
                  colors.modalBg3.withOpacity(isDark ? 0.75 : 1.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                    : const Color(0xFFFFFFFF).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: const Color(0xFFFFFFFF).withOpacity(0.25),
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
                // Question text
                FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    l10n.completionQuestion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // "I did it" button with animations
                FadeTransition(
                  opacity: _buttonFadeAnimation,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _buttonScaleAnimation,
                      _buttonColorAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _buttonScaleAnimation.value,
                        child: GestureDetector(
                          onTapDown: (_) => _handleButtonPress(),
                          onTapUp: (_) => _handleButtonRelease(),
                          onTapCancel: () {
                            setState(() {
                              _isPressed = false;
                            });
                            _buttonScaleController.reverse();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _buttonColorAnimation.value ?? colors.ctaPrimary,
                                  (_buttonColorAnimation.value ?? colors.ctaPrimary)
                                      .withOpacity(0.88),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: (_buttonColorAnimation.value ?? colors.ctaPrimary)
                                    .withOpacity(0.4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.textPrimary.withOpacity(isDark ? 0.15 : 0.3),
                                  blurRadius: isDark ? 12 : 24,
                                  offset: const Offset(0, 6),
                                ),
                                if (!isDark)
                                  BoxShadow(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.15),
                                    blurRadius: 0,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                    blurStyle: BlurStyle.inner,
                                  ),
                              ],
                            ),
                            child: Text(
                              l10n.completionConfirm,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont(context),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: colors.buttonText,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // "Not today" button
                FadeTransition(
                  opacity: _secondaryButtonFadeAnimation,
                  child: CupertinoButton(
                    onPressed: _handleNotToday,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.completionDecline,
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
    );
  }

  Widget _buildCelebrationView(AppColorScheme colors) {
    final isDark = context.read<ThemeProvider>().theme.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 384),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.modalShadow.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.0, 1.0),
                end: const Alignment(0.0, -1.0),
                colors: [
                  colors.modalBg1.withOpacity(isDark ? 0.75 : 1.0),
                  colors.modalBg2.withOpacity(isDark ? 0.70 : 1.0),
                  colors.modalBg3.withOpacity(isDark ? 0.75 : 1.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? colors.borderCard.withOpacity(colors.borderCardOpacity)
                    : const Color(0xFFFFFFFF).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: const Color(0xFFFFFFFF).withOpacity(0.25),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                  ),
                if (!isDark)
                  BoxShadow(
                    color: colors.modalInnerShadow.withOpacity(0.1),
                    blurRadius: 0,
                    offset: const Offset(0, -1),
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Heart icon with scale animation
            ScaleTransition(
              scale: _heartScaleAnimation,
              child: SizedBox(
                width: 72,
                height: 72,
                child: CustomPaint(
                  painter: _HeartPainter(colors: colors),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Celebration title
            Text(
              _celebrationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont(context),
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: colors.buttonDark,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            // Celebration message
            Text(
              _celebrationMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: colors.textTertiary,
                letterSpacing: -0.1,
                height: 1.5,
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

/// Custom painter for gradient heart icon
class _HeartPainter extends CustomPainter {
  final AppColorScheme colors;

  const _HeartPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.heartHighlight,
          Color.lerp(colors.heartHighlight, colors.heartDeep, 0.5)!,
          colors.heartDeep,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    paint.color = paint.color.withOpacity(0.92);

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Heart shape
    path.moveTo(width * 0.5, height * 0.3);

    // Left curve
    path.cubicTo(
      width * 0.2, height * 0.1,
      width * 0.1, height * 0.3,
      width * 0.1, height * 0.45,
    );
    path.cubicTo(
      width * 0.1, height * 0.7,
      width * 0.5, height * 0.9,
      width * 0.5, height * 0.95,
    );

    // Right curve
    path.cubicTo(
      width * 0.5, height * 0.9,
      width * 0.9, height * 0.7,
      width * 0.9, height * 0.45,
    );
    path.cubicTo(
      width * 0.9, height * 0.3,
      width * 0.8, height * 0.1,
      width * 0.5, height * 0.3,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
