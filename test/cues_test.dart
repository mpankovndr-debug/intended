import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/action_cue.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/cues_screen.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/services/action_cues.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "After I…" (spec §4, onboarding screen 5): each action tied to something
/// the person already does, stored under the action's title.
void main() {
  const coffee = ActionCue.preset(CuePreset.coffee);
  const bed = ActionCue.preset(CuePreset.bed);

  group('a cue', () {
    test('reads back what was stored', () {
      for (final cue in [coffee, ActionCue.own('  walk the dog ')]) {
        expect(ActionCue.fromJson(jsonDecode(jsonEncode(cue.toJson()))), cue);
      }
      expect(ActionCue.own(' walk the dog ').ownWords, 'walk the dog');
    });

    test('needs words', () {
      expect(() => ActionCue.own('   '), throwsArgumentError);
    });

    test('an unreadable record is no cue', () {
      expect(ActionCue.fromJson({'preset': 'shower'}), isNull);
      expect(ActionCue.fromJson({'own': '  '}), isNull);
      expect(ActionCue.fromJson('coffee'), isNull);
    });

    test('a preset reads in the app\'s language, whichever it was set in', () {
      expect(coffee.label(lookupAppLocalizations(const Locale('en'))),
          'pour my coffee');
      expect(coffee.label(lookupAppLocalizations(const Locale('ru'))),
          'налью кофе');
    });
  });

  group('the store', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('keeps one cue per action', () async {
      await ActionCues.set('Take 3 slow breaths', coffee);
      await ActionCues.set('Light a scented candle', bed);
      await ActionCues.set('Take 3 slow breaths', bed);
      expect(await ActionCues.read(), {
        'Take 3 slow breaths': bed,
        'Light a scented candle': bed,
      });
    });

    test('a cue follows its action across a rename', () async {
      await ActionCues.set('Walk the dog', coffee);
      await ActionCues.rename('Walk the dog', 'Walk Bruno');
      expect(await ActionCues.read(), {'Walk Bruno': coffee});
    });

    test('renaming an action without a cue changes nothing', () async {
      await ActionCues.set('Read', coffee);
      await ActionCues.rename('Walk the dog', 'Walk Bruno');
      expect(await ActionCues.read(), {'Read': coffee});
    });

    test('clearing the last cue leaves nothing behind', () async {
      await ActionCues.set('Read', coffee);
      await ActionCues.clear('Read');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(ActionCues.key), isFalse);
    });

    test('one bad record costs that cue only', () async {
      SharedPreferences.setMockInitialValues({
        ActionCues.key: jsonEncode({
          'Read': {'preset': 'coffee'},
          'Walk': {'preset': 'somersault'},
        }),
      });
      expect(await ActionCues.read(), {'Read': coffee});
    });

    test('an unreadable store reads as empty', () async {
      SharedPreferences.setMockInitialValues({ActionCues.key: '{nope'});
      expect(await ActionCues.read(), isEmpty);
    });

    test('renaming a custom action carries its cue', () async {
      SharedPreferences.setMockInitialValues({
        'user_habits': ['Walk the dog'],
        'custom_habits': ['Walk the dog'],
        'focus_areas': ['Health'],
      });
      final state = OnboardingState();
      await state.loadUserHabits();
      await ActionCues.set('Walk the dog', coffee);
      await state.renameCustomHabit('Walk the dog', 'Walk Bruno');
      expect(await ActionCues.read(), {'Walk Bruno': coffee});
    });
  });

  group('where to be', () {
    const actions = ['a', 'b', 'c'];
    test('opens at the first action without a cue', () {
      expect(CuesScreen.startAt(actions, {}), 0);
      expect(CuesScreen.startAt(actions, {'a': coffee}), 1);
      expect(CuesScreen.startAt(actions, {'a': coffee, 'c': bed}), 1);
      expect(CuesScreen.startAt(actions, {'a': coffee, 'b': bed, 'c': bed}), 0);
    });

    test('Continue needs every action; any one counts as not skipped', () {
      expect(CuesScreen.allSet(actions, {'a': coffee, 'b': bed}), isFalse);
      expect(CuesScreen.allSet(actions, {'a': coffee, 'b': bed, 'c': bed}),
          isTrue);
      expect(CuesScreen.allSet(const [], const {}), isFalse);
      expect(CuesScreen.anySet(actions, {}), isFalse);
      expect(CuesScreen.anySet(actions, {'b': bed}), isTrue);
      expect(CuesScreen.anySet(actions, {'elsewhere': bed}), isFalse);
    });
  });

  group('the screen', () {
    const actions = ['Take 3 slow breaths', 'Light a scented candle'];
    late OnboardingState state;
    late List<bool> continued;
    late int backed;

    Future<void> pump(WidgetTester tester,
        {Locale? locale, Map<String, Object> prefs = const {}}) async {
      SharedPreferences.setMockInitialValues({
        'user_habits': actions,
        'focus_areas': ['Health', 'Mood'],
        ...prefs,
      });
      state = OnboardingState();
      await state.loadUserHabits();
      await state.setSelectedIntentionPath(IntentionPathId.windingDown.key);
      continued = [];
      backed = 0;
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
            home: CuesScreen(
              onContinue: continued.add,
              onBack: () => backed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> choose(WidgetTester tester, String chip) async {
      await tester.tap(find.text(chip));
      await tester.pump();
      await tester.pump(CuesScreen.beat);
      await tester.pumpAndSettle();
    }

    testWidgets('one action at a time, the next after a cue lands',
        (tester) async {
      await pump(tester);
      expect(find.text('After I'), findsOneWidget);
      expect(find.text(actions[0]), findsOneWidget);
      expect(find.text(actions[1]), findsNothing);

      await tester.tap(find.text('pour my coffee'));
      await tester.pump();
      // The chosen words land before anything moves on.
      expect(find.text(actions[0]), findsOneWidget);
      expect(await ActionCues.read(), {actions[0]: coffee});

      await tester.pump(CuesScreen.beat);
      await tester.pumpAndSettle();
      expect(find.text(actions[1]), findsOneWidget);
      expect(find.text(actions[0]), findsNothing);
    });

    testWidgets('Continue waits for every action, then says cues were set',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(continued, isEmpty);

      await choose(tester, 'pour my coffee');
      await choose(tester, 'get into bed');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(continued, [true]);
      expect(await ActionCues.read(), {actions[0]: coffee, actions[1]: bed});
    });

    testWidgets('skipping with no cue lets the flow ask about a reminder',
        (tester) async {
      await pump(tester);
      await tester.tap(find.text('Skip for now'));
      await tester.pump();
      expect(continued, [false]);
    });

    testWidgets('skipping after one cue keeps it', (tester) async {
      await pump(tester);
      await choose(tester, 'brush my teeth');
      await tester.tap(find.text('Skip for now'));
      await tester.pump();
      expect(continued, [true]);
      expect(await ActionCues.read(),
          {actions[0]: const ActionCue.preset(CuePreset.teeth)});
    });

    testWidgets('their own words', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('cue-own-words')), 'feed the cat ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(CuesScreen.beat);
      await tester.pumpAndSettle();
      expect(
          await ActionCues.read(), {actions[0]: ActionCue.own('feed the cat')});
      expect(find.text(actions[1]), findsOneWidget);
    });

    testWidgets('back walks the actions before leaving', (tester) async {
      await pump(tester);
      await choose(tester, 'pour my coffee');
      expect(find.text(actions[1]), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text(actions[0]), findsOneWidget);
      expect(find.text('pour my coffee'), findsNWidgets(2)); // cue and chip
      expect(backed, 0);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(backed, 1);
    });

    testWidgets('coming back opens where they left off', (tester) async {
      await pump(tester, prefs: {
        ActionCues.key: jsonEncode({actions[0]: coffee.toJson()}),
      });
      expect(find.text(actions[1]), findsOneWidget);
    });

    testWidgets('in Russian the cue reads on its own line', (tester) async {
      await pump(tester, locale: const Locale('ru'));
      expect(find.text('После того как'), findsOneWidget);
      expect(find.text('налью кофе'), findsOneWidget);
      expect(find.text('Пропустить'), findsOneWidget);
    });
  });
}
