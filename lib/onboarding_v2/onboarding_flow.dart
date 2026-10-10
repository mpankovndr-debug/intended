import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../main.dart' show AppBackground, MainTabs, refreshHomeWidget;
import '../screens/onboarding_paywall_screen.dart';
import '../services/analytics_service.dart';
import '../services/backup_service.dart';
import '../services/chapter_service.dart';
import '../services/device_id.dart';
import '../services/revenue_cat_service.dart';
import 'cues_screen.dart';
import 'daily_reminder_screen.dart';
import 'direction_screen.dart';
import 'onboarding_state.dart';
import 'sentence_screen.dart';
import 'start_small_screen.dart';
import 'try_it_screen.dart';
import 'widgets/onboarding_scaffold.dart';

/// The screens after Welcome, in order (spec §6). The reminder is asked
/// only when no action was tied to a cue; the paywall follows only a real
/// first moment.
enum OnboardingStep { direction, sentence, startSmall, cues, reminder, tryIt }

typedef OnboardingFinish = Future<void> Function(
  BuildContext context, {
  required bool recorded,
});

/// Runs the new onboarding as one route: the painting is drawn once, the
/// step bar and button hold still, and only each screen's content blurs
/// out and the next one's blurs in. Back walks the steps actually taken.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, this.finish = OnboardingFlow.finishInApp});

  /// What happens when the last screen is done. Replaced in tests.
  final OnboardingFinish finish;

  static const Duration change = Duration(milliseconds: 520);

  /// After "After I…": a reminder only for someone who tied nothing to a
  /// cue (spec §6, screen 6).
  static OnboardingStep afterCues({required bool anyCue}) =>
      anyCue ? OnboardingStep.tryIt : OnboardingStep.reminder;

  /// Writes what onboarding made: completion, and chapter one from the
  /// sealed sentence, dated from the moment of sealing so it matches what
  /// the chapter page showed. An open chapter is never replaced: a chapter
  /// ends with the person's own answer (spec §2.3).
  static Future<void> complete(OnboardingState state) async {
    await state.completeOnboarding();
    final sentence = state.sentence;
    if (sentence == null) return;
    if (await ChapterService.current() != null) return;
    await ChapterService.start(
      sentence: sentence,
      pathKey: state.sentencePathKey ?? state.selectedIntentionPath,
      now: state.sentenceSealedAt,
    );
  }

  /// Completes onboarding and opens the app; with a first moment just made,
  /// the paywall follows over Today, so closing it shows the done card.
  static Future<void> finishInApp(
    BuildContext context, {
    required bool recorded,
  }) async {
    final state = context.read<OnboardingState>();
    final revenueCat = context.read<RevenueCatService>();
    final backup = context.read<BackupService>();
    final navigator = Navigator.of(context);

    await complete(state);
    AnalyticsService.logOnboardingCompleted();
    // Link the device to RevenueCat for subscription tracking.
    await revenueCat.logIn(await DeviceId.getOrCreate());
    backup.backup();
    if (context.mounted) refreshHomeWidget(context);

    final pitch = recorded &&
        await OnboardingPaywallScreen.claimFirstCompletion(
            isPremium: revenueCat.isPremium);

    // The whole onboarding goes, so no overshooting pop can land back in it.
    navigator.pushAndRemoveUntil(_fade(const MainTabs()), (_) => false);
    if (pitch) navigator.push(_fade(const OnboardingPaywallScreen()));
  }

  static Route<void> _fade(Widget page) => PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      );

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  OnboardingStep _step = OnboardingStep.direction;
  final List<OnboardingStep> _taken = [];
  bool _finishing = false;

  void _go(OnboardingStep next) {
    setState(() {
      _taken.add(_step);
      _step = next;
    });
  }

  void _back() {
    if (_taken.isEmpty) return;
    setState(() => _step = _taken.removeLast());
  }

  Future<void> _finish(bool recorded) async {
    if (_finishing) return;
    _finishing = true;
    await widget.finish(context, recorded: recorded);
  }

  Widget _screen(OnboardingStep step) => switch (step) {
        OnboardingStep.direction => DirectionScreen(
            onContinue: () => _go(OnboardingStep.sentence),
          ),
        OnboardingStep.sentence => SentenceScreen(
            onContinue: () => _go(OnboardingStep.startSmall),
            onBack: _back,
          ),
        OnboardingStep.startSmall => StartSmallScreen(
            onContinue: () => _go(OnboardingStep.cues),
            onBack: _back,
          ),
        OnboardingStep.cues => CuesScreen(
            onContinue: (anyCue) =>
                _go(OnboardingFlow.afterCues(anyCue: anyCue)),
            onBack: _back,
          ),
        OnboardingStep.reminder => DailyReminderScreen(
            onContinue: () => _go(OnboardingStep.tryIt),
            onBack: _back,
          ),
        OnboardingStep.tryIt => TryItScreen(
            onContinue: _finish,
            onBack: _back,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return PopScope(
      // The system back gesture walks the steps, like the chevron; on the
      // first step it does what it does anywhere else.
      canPop: _taken.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AppBackground(
        child: AnimatedSwitcher(
          duration: still ? Duration.zero : OnboardingFlow.change,
          transitionBuilder: (child, animation) => AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final leaving = animation.status == AnimationStatus.reverse ||
                  animation.status == AnimationStatus.dismissed;
              return IgnorePointer(
                ignoring: leaving,
                child: OnboardingStepScope(
                  value: animation.value,
                  leaving: leaving,
                  child: child,
                ),
              );
            },
          ),
          child: KeyedSubtree(key: ValueKey(_step), child: _screen(_step)),
        ),
      ),
    );
  }
}
