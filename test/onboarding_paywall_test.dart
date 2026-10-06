import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/letter.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/screens/onboarding_paywall_screen.dart';
import 'package:intended/services/moments_service.dart';
import 'package:intended/services/plan_service.dart';
import 'package:intended/services/revenue_cat_service.dart';
import 'package:intended/state/user_state.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The paywall after a first completion (decided 6 Oct): only what
/// Intended+ adds, each with when it arrives, and the timings are the
/// thresholds themselves rather than numbers typed into copy.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester,
      {int moments = 0, Locale? locale}) async {
    for (var i = 0; i < moments; i++) {
      await MomentsService.record(
          Moment.create(habitName: 'Read', at: DateTime(2026, 10, 1, 9 + i)));
    }
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final user = UserState();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RevenueCatService(user)),
      ],
      child: CupertinoApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const OnboardingPaywallScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('says when each part arrives, from the real thresholds',
      (tester) async {
    await pump(tester, moments: 1);
    expect(find.text('See what helps, and what to change.'), findsOneWidget);
    expect(find.text('after your first ${Letter.minMoments}\u00A0moments'),
        findsOneWidget);
    expect(find.text('at the start of each month'), findsOneWidget);
    expect(find.text('${PlanService.windowDays ~/ 7} weeks after each one'),
        findsOneWidget);
    // Nothing on it describes the free mosaic.
    expect(find.textContaining('becomes a square'), findsNothing);
  });

  testWidgets('"Your first moment" only when there is exactly one',
      (tester) async {
    await pump(tester, moments: 1);
    expect(find.text('Your first moment is already yours.'), findsOneWidget);
  });

  testWidgets('no first-moment line once there are more', (tester) async {
    await pump(tester, moments: 3);
    expect(find.text('Your first moment is already yours.'), findsNothing);
  });

  testWidgets('VoiceOver reads the steps in their order, not by position',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, moments: 1);
    final order = tester.semantics
        .simulatedAccessibilityTraversal()
        .map((node) => node.label)
        .toList();
    int at(String text) => order.indexWhere((l) => l.contains(text));
    expect(at('A letter about your month'), greaterThanOrEqualTo(0));
    expect(at('A letter about your month'),
        lessThan(at('A plan for the month ahead')));
    expect(at('A plan for the month ahead'),
        lessThan(at('Whether your changes helped')));
    handle.dispose();
  });

  testWidgets('in Russian', (tester) async {
    await pump(tester, moments: 1, locale: const Locale('ru'));
    expect(find.text('Пойми, что помогает и что поменять.'), findsOneWidget);
    expect(find.text('после первых ${Letter.minMoments}\u00A0моментов'),
        findsOneWidget);
    expect(find.text('Не сейчас, останусь на бесплатной'), findsOneWidget);
  });
}
