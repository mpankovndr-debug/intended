import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/direction_screen.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screen 2: one of nine directions, saved with its focus areas.
void main() {
  late OnboardingState state;
  late int continued;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    state = OnboardingState();
    continued = 0;
  });

  Future<void> pump(WidgetTester tester) async {
    // Tall enough that all nine cards are built at once.
    tester.view.physicalSize = const Size(393 * 3, 2000 * 3);
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
          home: DirectionScreen(onContinue: () => continued++),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Iterable<DirectionCard> cards(WidgetTester tester) =>
      tester.widgetList<DirectionCard>(find.byType(DirectionCard));

  testWidgets('offers the nine paths, and not "Your own way"', (tester) async {
    await pump(tester);
    final ids = cards(tester).map((c) => c.path.id).toList();
    expect(ids, hasLength(9));
    expect(ids, isNot(contains(IntentionPathId.yourOwnWay)));
    expect(ids.toSet(), IntentionPath.pickerOptions.map((p) => p.id).toSet());
  });

  testWidgets('nothing is chosen and Continue does nothing until one is',
      (tester) async {
    await pump(tester);
    expect(cards(tester).where((c) => c.selected), isEmpty);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(continued, 0);
  });

  testWidgets('choosing saves the path and its focus areas, then continues',
      (tester) async {
    await pump(tester);
    final path = IntentionPath.getById(IntentionPathId.softerNights);
    await tester.tap(find
        .byWidgetPredicate((w) => w is DirectionCard && w.path.id == path.id));
    await tester.pumpAndSettle();
    expect(cards(tester).singleWhere((c) => c.selected).path.id, path.id);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(continued, 1);
    expect(state.selectedIntentionPath, path.id.key);
    expect(state.focusAreas, path.defaultFocusAreas);
  });

  testWidgets(
      'coming back keeps the choice, and the focus areas already '
      'changed on it', (tester) async {
    final path = IntentionPath.getById(IntentionPathId.windingDown);
    await state.setSelectedIntentionPath(path.id.key);
    await state.applyPathDefaults(path.defaultFocusAreas, path.id.key);
    await state.applyPathDefaults(const ['Mood'], path.id.key); // changed

    await pump(tester);
    expect(cards(tester).singleWhere((c) => c.selected).path.id, path.id);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(continued, 1);
    expect(state.focusAreas, ['Mood']);
  });
}
