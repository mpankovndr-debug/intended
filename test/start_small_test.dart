import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/models/start_small.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/onboarding_v2/start_small_screen.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screen 4: a few small actions, chosen by the person. The
/// suggested number is a suggestion (decided 30 Sep); Today's size is the
/// only cap, and it is said out loud.
void main() {
  const catalogue = OnboardingState.habitsByCategory;

  group('what is offered', () {
    test('a path\'s own actions come first, then its areas in turn', () {
      final path = IntentionPath.getById(IntentionPathId.softerNights);
      final offered = StartSmall.candidates(
        path: path,
        focusAreas: path.defaultFocusAreas,
        catalogue: catalogue,
      );
      expect(offered, hasLength(StartSmall.offered));
      expect(offered.take(path.starterActions!.length), path.starterActions);
      expect(offered.toSet(), hasLength(offered.length));
    });

    test('without actions of its own, the areas take turns', () {
      final path = IntentionPath.getById(IntentionPathId.yourOwnWay);
      const areas = ['Health', 'Mood'];
      final offered = StartSmall.candidates(
        path: path,
        focusAreas: areas,
        catalogue: catalogue,
      );
      expect(offered, [
        catalogue[areas[0]]![0],
        catalogue[areas[1]]![0],
        catalogue[areas[0]]![1],
        catalogue[areas[1]]![1],
        catalogue[areas[0]]![2],
        catalogue[areas[1]]![2],
      ]);
    });

    test('the same question gets the same answer', () {
      final path = IntentionPath.getById(IntentionPathId.yourOwnWay);
      List<String> ask() => StartSmall.candidates(
          path: path, focusAreas: const ['Mood'], catalogue: catalogue);
      expect(ask(), ask());
      expect(ask(), catalogue['Mood']!.take(StartSmall.offered));
    });
  });

  test('every direction brings actions of its own, all in the catalogue', () {
    final catalogued = {
      for (final pool in catalogue.values) ...pool,
    };
    for (final path in IntentionPath.pickerOptions) {
      final own = path.starterActions;
      expect(own, isNotNull, reason: path.id.key);
      expect(own, hasLength(4), reason: path.id.key);
      for (final action in own!) {
        expect(catalogued, contains(action), reason: '${path.id.key}: $action');
      }
    }
  });

  group('the screen', () {
    late OnboardingState state;
    late int continued;

    Future<void> setUpState(DateTime sealedAt) async {
      SharedPreferences.setMockInitialValues({});
      state = OnboardingState();
      final path = IntentionPath.getById(IntentionPathId.windingDown);
      await state.setSelectedIntentionPath(path.id.key);
      await state.applyPathDefaults(path.defaultFocusAreas, path.id.key);
      await state.sealSentence('let the day go',
          pathKey: path.id.key, at: sealedAt);
      continued = 0;
    }

    Future<void> pump(WidgetTester tester, {Locale? locale}) async {
      tester.view.physicalSize = const Size(393 * 3, 1400 * 3);
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
            home: StartSmallScreen(onContinue: () => continued++),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    List<ActionCard> cards(WidgetTester tester) =>
        tester.widgetList<ActionCard>(find.byType(ActionCard)).toList();

    Future<void> tapCard(WidgetTester tester, String action) async {
      await tester.tap(
          find.byWidgetPredicate((w) => w is ActionCard && w.action == action));
      await tester.pump();
    }

    testWidgets('a full first month suggests three', (tester) async {
      await setUpState(DateTime(2026, 9, 1, 12));
      await pump(tester);
      expect(find.text('Start with three small things.'), findsOneWidget);
      expect(cards(tester), hasLength(StartSmall.offered));
    });

    testWidgets('a short first month suggests two, and says why',
        (tester) async {
      await setUpState(DateTime(2026, 9, 11, 12)); // 20 days left
      await pump(tester);
      expect(find.text('Start with two small things.'), findsOneWidget);
      expect(find.text('You have 20 days until October.'), findsOneWidget);
    });

    testWidgets('in Russian the month bends after «до»', (tester) async {
      await setUpState(DateTime(2026, 9, 11, 12));
      await pump(tester, locale: const Locale('ru'));
      expect(find.text('До октября 20 дней.'), findsOneWidget);
    });

    testWidgets('nothing chosen, nothing to continue with', (tester) async {
      await setUpState(DateTime(2026, 9, 1, 12));
      await pump(tester);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(continued, 0);
    });

    testWidgets('more than suggested is allowed, and saved in order',
        (tester) async {
      await setUpState(DateTime(2026, 9, 11, 12)); // suggests two
      await pump(tester);
      final offered = cards(tester).map((c) => c.action).toList();
      for (final action in offered.take(4)) {
        await tapCard(tester, action);
      }
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(continued, 1);
      expect(state.userHabits, offered.take(4).toList());
    });

    testWidgets('Today\'s size is the only cap, and it is said out loud',
        (tester) async {
      await setUpState(DateTime(2026, 9, 1, 12));
      await pump(tester);
      final first = cards(tester).map((c) => c.action).toList();
      for (final action in first) {
        await tapCard(tester, action);
      }
      expect(first, hasLength(OnboardingState.maxActiveHabits));
      expect(find.text("That's as many as Today holds."), findsNothing);

      // New areas bring new actions; the chosen six stay on screen.
      for (final area in List.of(state.focusAreas)) {
        state.toggleFocusArea(area);
      }
      state.toggleFocusArea('Creativity');
      await tester.pump();
      final now = cards(tester).map((c) => c.action).toList();
      expect(now, containsAll(first));
      final fresh = now.firstWhere((a) => !first.contains(a));
      await tapCard(tester, fresh);
      expect(find.text("That's as many as Today holds."), findsOneWidget);
      expect(
          cards(tester).where((c) => c.selected).map((c) => c.action).toList(),
          unorderedEquals(first));
    });

    testWidgets('coming back keeps the choice', (tester) async {
      await setUpState(DateTime(2026, 9, 1, 12));
      final path = IntentionPath.getById(IntentionPathId.windingDown);
      final offered = StartSmall.candidates(
          path: path, focusAreas: state.focusAreas, catalogue: catalogue);
      await state.adoptChosenActions([offered[1], offered[3]]);
      await pump(tester);
      expect(cards(tester).where((c) => c.selected).map((c) => c.action),
          unorderedEquals([offered[1], offered[3]]));
    });
  });
}
