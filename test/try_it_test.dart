import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/chapter.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/onboarding_v2/try_it_screen.dart';
import 'package:intended/services/moments_service.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screen 7: the first real moment, landing in the person's own
/// month.
void main() {
  const actions = ['Light a scented candle', 'Drink something warm'];

  group('what it may say', () {
    // Sealed 29 September: the chapter folds its last days into October.
    final chapter = Chapter.start(
      id: 'c',
      sentence: 'let the day go',
      pathKey: 'winding_down',
      startedAt: DateTime.utc(2026, 9, 29, 18),
      offsetMinutes: 0,
    );

    test('a moment on the day of the seal is the chapter\'s first', () {
      final moment = Moment.create(
          habitName: actions[0], at: DateTime.utc(2026, 9, 29, 19));
      expect(TryItScreen.opensChapter(chapter, moment), isTrue);
    });

    test('a moment before the chapter is not claimed for it', () {
      final moment = Moment.create(
          habitName: actions[0], at: DateTime.utc(2026, 9, 20, 12));
      expect(TryItScreen.opensChapter(chapter, moment), isFalse);
    });
  });

  group('coming back', () {
    final sealed = DateTime.utc(2026, 9, 29, 18);
    Moment at(String habit, int hour) =>
        Moment.create(habitName: habit, at: DateTime.utc(2026, 9, 29, hour));

    test('finds the moment made here, the latest since the seal', () {
      final first = at(actions[0], 19);
      final later = at(actions[1], 20);
      expect(
          TryItScreen.alreadyRecorded(
              [first, later, at('Something else', 21)], actions, sealed),
          later);
    });

    test('ignores moments from before the seal', () {
      expect(TryItScreen.alreadyRecorded([at(actions[0], 17)], actions, sealed),
          isNull);
      expect(TryItScreen.alreadyRecorded([at(actions[0], 19)], actions, null),
          isNull);
    });
  });

  group('the screen', () {
    late OnboardingState state;
    late List<bool> continued;

    Future<void> pump(
      WidgetTester tester, {
      Locale? locale,
      bool reduceMotion = false,
      List<Moment> before = const [],
    }) async {
      if (reduceMotion) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
            tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      }
      SharedPreferences.setMockInitialValues({});
      for (final m in before) {
        await MomentsService.record(m);
      }
      state = OnboardingState();
      await state.setSelectedIntentionPath(IntentionPathId.windingDown.key);
      await state.sealSentence('let the day go',
          pathKey: IntentionPathId.windingDown.key,
          at: DateTime.now().subtract(const Duration(minutes: 1)));
      await state.adoptChosenActions(actions);
      continued = [];
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
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TryItScreen(onContinue: continued.add),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// On screen and fully shown: nothing above it is still fading it in.
    void shown(WidgetTester tester, String text) {
      final found = find.text(text);
      expect(found, findsOneWidget, reason: text);
      final fading = tester
          .widgetList<Opacity>(
              find.ancestor(of: found, matching: find.byType(Opacity)))
          .where((o) => o.opacity < 1);
      expect(fading, isEmpty, reason: text);
    }

    Future<void> tapAction(WidgetTester tester, String action) async {
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
    }

    testWidgets('a tap is a real moment, and it lands in the month',
        (tester) async {
      await pump(tester);
      expect(
          find.text("That's the first square of your chapter."), findsNothing);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(continued, isEmpty);

      await tapAction(tester, actions[0]);
      final all = await MomentsService.getAll();
      expect(all.map((m) => m.habitName), [actions[0]]);
      expect(find.text("That's the first square of your chapter."),
          findsOneWidget);
      expect(
          find.textContaining('marks the return, not the gap'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(continued, [true]);
    });

    testWidgets('one moment here, not one per tap', (tester) async {
      await pump(tester);
      await tapAction(tester, actions[0]);
      await tapAction(tester, actions[1]);
      await tapAction(tester, actions[0]);
      expect(await MomentsService.getAll(), hasLength(1));
    });

    testWidgets('later records nothing and says so', (tester) async {
      await pump(tester);
      await tester.tap(find.text("I'll do it later"));
      await tester.pump();
      expect(continued, [false]);
      expect(await MomentsService.getAll(), isEmpty);
    });

    testWidgets('coming back shows the moment landed, and asks no more',
        (tester) async {
      await pump(tester, before: []);
      await tapAction(tester, actions[1]);

      // Back, then forward again: a fresh screen over the same storage.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: state),
          ],
          child: CupertinoApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TryItScreen(onContinue: continued.add),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("That's the first square of your chapter."),
          findsOneWidget);
      await tapAction(tester, actions[0]);
      expect(await MomentsService.getAll(), hasLength(1));
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(continued, [true]);
    });

    testWidgets('with Reduce Motion it simply lands', (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.tap(find.text(actions[0]));
      // No time passes: only the frames the recording itself needs.
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      shown(tester, "That's the first square of your chapter.");
    });

    testWidgets('without it, the caption waits for the tile', (tester) async {
      await pump(tester);
      await tester.tap(find.text(actions[0]));
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      final caption = find.text("That's the first square of your chapter.");
      final fading = tester
          .widgetList<Opacity>(
              find.ancestor(of: caption, matching: find.byType(Opacity)))
          .where((o) => o.opacity < 1);
      expect(fading, isNotEmpty);
      await tester.pumpAndSettle();
      shown(tester, "That's the first square of your chapter.");
    });

    testWidgets('in Russian', (tester) async {
      await pump(tester, locale: const Locale('ru'));
      await tapAction(tester, 'Зажги аромасвечу');
      expect(find.text('Это первый квадрат твоей главы.'), findsOneWidget);
      expect(find.text('Сделаю позже'), findsOneWidget);
    });
  });
}
