import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/screens/habit_completion_modal.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:intended/utils/responsive_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The completion sheet keeps the moment only on Done. People do tap the
/// wrong card, and its X has to leave nothing behind.
void main() {
  final draft = Moment.create(
    habitName: 'Take 3 slow breaths',
    at: DateTime(2026, 10, 10, 9, 5),
  );
  final kept = <Moment>[];
  late bool closed;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    kept.clear();
    closed = false;
  });

  Future<AppLocalizations> open(WidgetTester tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: CupertinoApp(
        navigatorKey: navigator,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          Responsive.init(context);
          return child!;
        },
        home: const CupertinoPageScaffold(child: SizedBox.expand()),
      ),
    ));
    showCupertinoDialog<void>(
      context: navigator.currentContext!,
      builder: (_) => HabitCompletionModal(
        draft: draft,
        monthCategories: [null, draft.category],
        onDone: (answered) async => kept.add(answered),
      ),
    ).then((_) => closed = true);
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(HabitCompletionModal)));
  }

  testWidgets('the X closes the sheet and keeps nothing, answers included',
      (tester) async {
    final l10n = await open(tester);
    await tester.tap(find.text(l10n.completionMoodGlad));
    await tester.pump();

    await tester.tap(find.bySemanticsLabel(l10n.commonClose));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(find.byType(HabitCompletionModal), findsNothing);
    expect(kept, isEmpty);
  });

  testWidgets(
      'Done keeps the draft once, with its mood and note, and the X goes',
      (tester) async {
    final l10n = await open(tester);
    await tester.tap(find.text(l10n.completionMoodGlad));
    await tester.tap(find.text(l10n.completionAddNote));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), 'after lunch');

    await tester.tap(find.text(l10n.commonDone));
    await tester.pump();

    expect(kept, hasLength(1));
    expect(kept.single.id, draft.id);
    expect(kept.single.mood, MomentMood.gladIDid);
    expect(kept.single.note, 'after lunch');
    expect(find.bySemanticsLabel(l10n.commonClose), findsNothing);

    // The landing plays, settles, then the sheet leaves on its own.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(kept, hasLength(1));
  });
}
