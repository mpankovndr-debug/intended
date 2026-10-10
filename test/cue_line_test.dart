import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/action_cue.dart';
import 'package:intended/services/action_cues.dart';
import 'package:intended/widgets/cue_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The quiet line under an action on Today (spec §4).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, String action,
      {Locale? locale}) async {
    await tester.pumpWidget(CupertinoApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Center(
        child: CueLine(action: action, style: const TextStyle(fontSize: 13)),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('no cue, no line', (tester) async {
    await pump(tester, 'Take 3 slow breaths');
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('says what the action follows', (tester) async {
    await ActionCues.set(
        'Take 3 slow breaths', const ActionCue.preset(CuePreset.coffee));
    await pump(tester, 'Take 3 slow breaths');
    expect(find.text('after I pour my coffee'), findsOneWidget);
  });

  testWidgets('in Russian', (tester) async {
    await ActionCues.set('Walk', ActionCue.own('выйду из душа'));
    await pump(tester, 'Walk', locale: const Locale('ru'));
    expect(find.text('после того как я выйду из душа'), findsOneWidget);
  });

  testWidgets('a cue set while the card is on screen appears', (tester) async {
    await pump(tester, 'Read');
    expect(find.byType(Text), findsNothing);
    await tester.runAsync(
        () => ActionCues.set('Read', const ActionCue.preset(CuePreset.bed)));
    await tester.pumpAndSettle();
    expect(find.text('after I get into bed'), findsOneWidget);
  });

  testWidgets('a renamed action keeps its line', (tester) async {
    await ActionCues.set(
        'Walk the dog', const ActionCue.preset(CuePreset.dinner));
    await pump(tester, 'Walk the dog');
    await tester
        .runAsync(() => ActionCues.rename('Walk the dog', 'Walk Bruno'));
    await pump(tester, 'Walk Bruno');
    expect(find.text('after I finish dinner'), findsOneWidget);
  });
}
