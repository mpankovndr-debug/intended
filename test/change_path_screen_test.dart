import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/features/profile/change_path_screen.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Changing path from the profile. Both answers to "Update your focus
/// areas?" change the path, so the question needs its own way out for
/// whoever tapped the wrong one.
void main() {
  final current = IntentionPath.getById(IntentionPathId.windingDown);
  final wrong = IntentionPath.getById(IntentionPathId.gentleMornings);
  final right = IntentionPath.getById(IntentionPathId.softerNights);
  final navigator = GlobalKey<NavigatorState>();
  late OnboardingState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = OnboardingState();
    await state.setSelectedIntentionPath(current.id.key);
    await state.applyPathDefaults(current.defaultFocusAreas, current.id.key);
  });

  Future<AppLocalizations> open(WidgetTester tester) async {
    // Tall enough that every path card is built at once.
    tester.view.physicalSize = const Size(393 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: state),
        ],
        child: CupertinoApp(
          navigatorKey: navigator,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CupertinoPageScaffold(child: SizedBox.expand()),
        ),
      ),
    );
    navigator.currentState!.push(
      CupertinoPageRoute<void>(builder: (_) => const ChangePathScreen()),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(ChangePathScreen)));
  }

  Future<void> chooseAndSave(
    WidgetTester tester,
    AppLocalizations l10n,
    IntentionPath path,
  ) async {
    await tester.tap(find.text(path.title(l10n)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonSave));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'the X closes the question without changing anything, and the right '
      'path is then one tap away', (tester) async {
    final l10n = await open(tester);
    final areasBefore = List.of(state.focusAreas);

    await chooseAndSave(tester, l10n, wrong);
    final question =
        find.text(l10n.intentionPathUpdateFocusAreas(wrong.title(l10n)));
    expect(question, findsOneWidget);

    await tester.tap(find.bySemanticsLabel(l10n.commonClose));
    await tester.pumpAndSettle();
    expect(question, findsNothing);
    expect(find.byType(ChangePathScreen), findsOneWidget);
    expect(state.selectedIntentionPath, current.id.key);
    expect(state.focusAreas, areasBefore);

    await chooseAndSave(tester, l10n, right);
    await tester.tap(find.text(l10n.intentionPathUpdateYes));
    await tester.pumpAndSettle();
    expect(state.selectedIntentionPath, right.id.key);
    expect(state.focusAreas, right.defaultFocusAreas);
    expect(find.byType(ChangePathScreen), findsNothing);
  });
}
