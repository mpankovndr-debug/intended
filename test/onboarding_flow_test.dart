import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/cues_screen.dart';
import 'package:intended/onboarding_v2/daily_reminder_screen.dart';
import 'package:intended/onboarding_v2/direction_screen.dart';
import 'package:intended/onboarding_v2/onboarding_flow.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/onboarding_v2/start_small_screen.dart';
import 'package:intended/onboarding_v2/try_it_screen.dart';
import 'package:intended/onboarding_v2/widgets/hold_to_confirm_button.dart';
import 'package:intended/screens/onboarding_paywall_screen.dart';
import 'package:intended/services/chapter_service.dart';
import 'package:intended/services/moments_service.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The new onboarding end to end (spec §6): Direction → Say it your way →
/// Start small → After I… → (a reminder only without a cue) → Try it →
/// finish, which writes chapter one and claims the paywall's one showing.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the reminder is asked only when no cue was set', () {
    expect(OnboardingFlow.afterCues(anyCue: true), OnboardingStep.tryIt);
    expect(OnboardingFlow.afterCues(anyCue: false), OnboardingStep.reminder);
  });

  group('finishing', () {
    test('writes chapter one from the sentence, dated from the seal', () async {
      final state = OnboardingState();
      await state.setSelectedIntentionPath(IntentionPathId.windingDown.key);
      final sealed = DateTime(2026, 9, 29, 21);
      await state.sealSentence('let the day go',
          pathKey: IntentionPathId.windingDown.key, at: sealed);

      await OnboardingFlow.complete(state);

      expect(state.onboardingComplete, isTrue);
      final chapter = await ChapterService.current();
      expect(chapter, isNotNull);
      expect(chapter!.sentence, 'let the day go');
      expect(chapter.pathKey, IntentionPathId.windingDown.key);
      expect(chapter.startedAt, sealed.toUtc());
      expect(chapter.months.first, DateTime.utc(2026, 10));
    });

    test('never replaces a chapter that is already open', () async {
      await ChapterService.start(sentence: 'earlier', pathKey: 'quiet_focus');
      final state = OnboardingState();
      await state.sealSentence('later',
          pathKey: IntentionPathId.windingDown.key, at: DateTime.now());

      await OnboardingFlow.complete(state);

      final all = await ChapterService.all();
      expect(all.map((c) => c.sentence), ['earlier']);
    });

    test(
        'the paywall after a first completion shows once, never to a '
        'subscriber', () async {
      expect(
          await OnboardingPaywallScreen.claimFirstCompletion(isPremium: true),
          isFalse);
      expect(
          await OnboardingPaywallScreen.claimFirstCompletion(isPremium: false),
          isTrue);
      expect(
          await OnboardingPaywallScreen.claimFirstCompletion(isPremium: false),
          isFalse);
    });
  });

  group('the flow', () {
    late OnboardingState state;
    late List<bool> finished;

    Future<void> pump(WidgetTester tester) async {
      state = OnboardingState();
      finished = [];
      tester.view.physicalSize = const Size(393 * 3, 852 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: state),
          ],
          child: CupertinoApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OnboardingFlow(
              finish: (context, {required recorded}) async =>
                  finished.add(recorded),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapContinue(WidgetTester tester) async {
      await tester.tap(find.text('Continue').last);
      await tester.pumpAndSettle();
    }

    Future<void> throughStartSmall(WidgetTester tester) async {
      // Direction.
      await tester.tap(find.byWidgetPredicate((w) =>
          w is DirectionCard && w.path.id == IntentionPathId.windingDown));
      await tester.pump();
      await tapContinue(tester);

      // Say it your way: hold, then let the chapter open.
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(HoldToConfirmButton)));
      for (var t = 0; t < 1300; t += 50) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      await tapContinue(tester);

      // Start small: one action.
      expect(find.byType(StartSmallScreen), findsOneWidget);
      await tester.tap(find.byType(ActionCard).first);
      await tester.pump();
      await tapContinue(tester);
      expect(find.byType(CuesScreen), findsOneWidget);
    }

    testWidgets('without a cue: the reminder, then the first moment',
        (tester) async {
      await pump(tester);
      await throughStartSmall(tester);

      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();
      expect(find.byType(DailyReminderScreen), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.byType(TryItScreen), findsOneWidget);

      // Back returns to the step actually taken.
      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.byType(DailyReminderScreen), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(state.userHabits.first));
      await tester.pumpAndSettle();
      await tapContinue(tester);
      expect(finished, [true]);
      expect(await MomentsService.getAll(), hasLength(1));
    });

    testWidgets('with a cue: straight to the first moment', (tester) async {
      await pump(tester);
      await throughStartSmall(tester);

      await tester.tap(find.text('pour my coffee'));
      await tester.pump();
      await tester.pump(CuesScreen.beat);
      await tester.pumpAndSettle();
      await tapContinue(tester);
      expect(find.byType(DailyReminderScreen), findsNothing);
      expect(find.byType(TryItScreen), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.byType(CuesScreen), findsOneWidget);
    });

    testWidgets('later: finishing without a moment', (tester) async {
      await pump(tester);
      await throughStartSmall(tester);
      await tester.tap(find.text('pour my coffee'));
      await tester.pump();
      await tester.pump(CuesScreen.beat);
      await tester.pumpAndSettle();
      await tapContinue(tester);

      await tester.tap(find.text("I'll do it later"));
      await tester.pumpAndSettle();
      expect(finished, [false]);
      expect(await MomentsService.getAll(), isEmpty);
    });

    testWidgets('the button holds still while the content changes',
        (tester) async {
      await pump(tester);
      await tester.tap(find.byWidgetPredicate((w) =>
          w is DirectionCard && w.path.id == IntentionPathId.windingDown));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      // Every frame of the change: some copy of the step bar is fully
      // there, so it never dips.
      for (var t = 0; t <= OnboardingFlow.change.inMilliseconds; t += 40) {
        await tester.pump(const Duration(milliseconds: 40));
        final bars = find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == 'OnboardingProgressBar');
        final solid = bars.evaluate().where((e) {
          final fading = tester
              .widgetList<Opacity>(find.ancestor(
                  of: find.byElementPredicate((x) => x == e),
                  matching: find.byType(Opacity)))
              .where((o) => o.opacity < 1);
          return fading.isEmpty;
        });
        expect(solid, isNotEmpty, reason: 'at $t ms');
      }
    });
  });
}
