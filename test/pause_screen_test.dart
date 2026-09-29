import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/screens/pause_screen.dart';
import 'package:intended/theme/theme_provider.dart';

/// The Reduce Motion fallback is a hard product constraint — words replace
/// motion, and the default experience must never show them — so it gets a
/// widget test rather than trusting a manual look. (The simulator would not
/// apply ReduceMotionEnabled without a reboot; this covers it permanently.)
Widget _host({required bool reduceMotion}) {
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: CupertinoApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
          child: const PauseScreen(entry: 'home'),
        ),
      ),
    ),
  );
}

/// The words are always in the tree at some opacity, so presence alone
/// proves nothing — the nearest Opacity ancestor carries the actual signal.
double _wordOpacity(WidgetTester tester, String text) {
  return tester
      .widgetList<Opacity>(
        find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
      )
      .first
      .opacity;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Reduce Motion carries the rhythm with words, one at a time',
      (tester) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 1700)); // settle-in ends
    await tester.pump(const Duration(seconds: 2)); // t ≈ 0.17, mid-inhale
    expect(_wordOpacity(tester, 'in'), greaterThan(0.9));
    expect(_wordOpacity(tester, 'out'), 0.0);
    await tester.pump(const Duration(seconds: 6)); // t ≈ 0.67, mid-exhale
    expect(_wordOpacity(tester, 'in'), 0.0);
    expect(_wordOpacity(tester, 'out'), greaterThan(0.9));
    await tester.pumpWidget(const SizedBox()); // unmount → dispose cleanly
  });

  testWidgets('the default experience never shows the words', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('in'), findsNothing);
    expect(find.text('out'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('five breaths settle into the check-in; the exit becomes skip',
      (tester) async {
    await tester.pumpWidget(_host(reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.text('enough for now'), findsOneWidget);
    for (var i = 0; i < PauseScreen.totalCycles; i++) {
      // Two pumps per cycle: a chained forward() only registers its first
      // ticker tick on the next frame, and elapsed time counts from there.
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(PauseScreen.cycleDuration);
    }
    await tester.pump(const Duration(milliseconds: 1500)); // settle-out
    await tester.pump(const Duration(milliseconds: 600)); // check-in fade
    // The bottom affordance swapping to "skip" is the real stage signal —
    // the check-in block's texts sit in the tree at opacity 0 all along.
    expect(find.text('skip'), findsOneWidget);
    expect(find.text('enough for now'), findsNothing);
    expect(find.text('How are you feeling now?'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
