import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/chapter.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/onboarding_v2/sentence_screen.dart';
import 'package:intended/onboarding_v2/widgets/hold_to_confirm_button.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screen 3: the sentence in the person's own words, sealed by a
/// hold, then the first chapter with its end date.
void main() {
  // 29 September, evening: the start folds into October, so the chapter
  // runs to 31 December (spec §2.1).
  final now = DateTime(2026, 9, 29, 20);
  const windingDown = 'let the day go before I sleep';

  late OnboardingState state;
  late int continued;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = OnboardingState();
    await state.setSelectedIntentionPath(IntentionPathId.windingDown.key);
    continued = 0;
  });

  Future<void> pump(WidgetTester tester) async {
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
          home: SentenceScreen(
            onContinue: () => continued++,
            onBack: () {},
            now: () => now,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String field(WidgetTester tester) => tester
      .widget<CupertinoTextField>(find.byType(CupertinoTextField))
      .controller!
      .text;

  /// Press, keep the finger down for [howLong] frame by frame (the fill is
  /// an animation, so time has to pass in frames), then let go.
  Future<void> hold(WidgetTester tester, Duration howLong) async {
    final gesture = await tester
        .startGesture(tester.getCenter(find.byType(HoldToConfirmButton)));
    for (var t = 0; t < howLong.inMilliseconds; t += 50) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('starts from the path\'s own words', (tester) async {
    await pump(tester);
    expect(field(tester), windingDown);
  });

  testWidgets('an idea replaces the sentence', (tester) async {
    await pump(tester);
    await tester.tap(find.text('sleep a bit earlier'));
    await tester.pump();
    expect(field(tester), 'sleep a bit earlier');
  });

  testWidgets('letting go early seals nothing', (tester) async {
    await pump(tester);
    await hold(tester, const Duration(milliseconds: 600));
    expect(state.sentence, isNull);
    expect(find.text('CHAPTER ONE'), findsNothing);
  });

  testWidgets('a full hold seals the words and shows the chapter',
      (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(CupertinoTextField), 'rest  ');
    await hold(tester, const Duration(milliseconds: 1300));

    expect(state.sentence, 'rest');
    expect(state.sentencePathKey, IntentionPathId.windingDown.key);
    expect(state.sentenceSealedAt, now.toUtc());
    expect(find.text('CHAPTER ONE'), findsOneWidget);
    expect(find.textContaining('Until 31\u00A0December.'), findsOneWidget);
    expect(find.text('“I want to rest”'), findsOneWidget);
    expect(find.text('October'), findsOneWidget);
    expect(find.text('Try a few'), findsOneWidget);
    expect(find.text('December'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(continued, 1);
  });

  testWidgets('an empty sentence cannot be sealed', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(CupertinoTextField), '   ');
    await tester.pump();
    await hold(tester, const Duration(milliseconds: 1300));
    expect(state.sentence, isNull);
  });

  testWidgets('VoiceOver can confirm without holding', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    tester.semantics.tap(find.semantics.byLabel('Hold to make it yours'));
    await tester.pumpAndSettle();
    expect(state.sentence, windingDown);
    semantics.dispose();
  });

  testWidgets('back from the chapter returns to the words', (tester) async {
    await pump(tester);
    await hold(tester, const Duration(milliseconds: 1300));
    expect(find.text('CHAPTER ONE'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('CHAPTER ONE'), findsNothing);
    expect(field(tester), windingDown);
  });

  testWidgets('their own words come back; a new direction starts over',
      (tester) async {
    await state.sealSentence('my own words',
        pathKey: IntentionPathId.windingDown.key, at: now);
    await pump(tester);
    expect(field(tester), 'my own words');
  });

  testWidgets('words written under another direction are not reused',
      (tester) async {
    await state.sealSentence('sleep through the night',
        pathKey: IntentionPathId.softerNights.key, at: now);
    await pump(tester);
    expect(field(tester), windingDown);
  });

  test('the sealed sentence survives a relaunch', () async {
    await state.sealSentence('  my words ',
        pathKey: IntentionPathId.windingDown.key, at: now);
    final reloaded = OnboardingState();
    await reloaded.loadSentence();
    expect(reloaded.sentence, 'my words');
    expect(reloaded.sentencePathKey, IntentionPathId.windingDown.key);
    expect(reloaded.sentenceSealedAt, now.toUtc());
  });

  group('every direction has words to start from', () {
    for (final locale in const [Locale('en'), Locale('ru')]) {
      test(locale.languageCode, () {
        final l10n = lookupAppLocalizations(locale);
        for (final path in IntentionPath.pickerOptions) {
          final sentence = path.sentence(l10n);
          final ideas = path.sentenceIdeas(l10n);
          expect(sentence, isNotEmpty, reason: path.id.key);
          expect(ideas, hasLength(3), reason: path.id.key);
          expect({sentence, ...ideas}, hasLength(4), reason: path.id.key);
          for (final s in [sentence, ...ideas]) {
            expect(s.length, lessThanOrEqualTo(SentenceScreen.maxLength));
          }
        }
        final ownWay = IntentionPath.getById(IntentionPathId.yourOwnWay);
        expect(ownWay.sentence(l10n), isEmpty);
        expect(ownWay.sentenceIdeas(l10n), isEmpty);
      });
    }
  });

  test('a chapter\'s months are its three stages', () {
    final c = Chapter.start(
      id: 'c',
      sentence: 's',
      pathKey: 'p',
      startedAt: DateTime.utc(2026, 9, 29, 12),
      offsetMinutes: 0,
    );
    expect(c.months, [
      DateTime.utc(2026, 10),
      DateTime.utc(2026, 11),
      DateTime.utc(2026, 12),
    ]);
  });
}
