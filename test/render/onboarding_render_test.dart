import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/cues_screen.dart';
import 'package:intended/onboarding_v2/direction_screen.dart';
import 'package:intended/onboarding_v2/onboarding_flow.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/onboarding_v2/sentence_screen.dart';
import 'package:intended/onboarding_v2/start_small_screen.dart';
import 'package:intended/onboarding_v2/try_it_screen.dart';
import 'package:intended/theme/category_glyphs.dart';
import 'package:intended/onboarding_v2/widgets/hold_to_confirm_button.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/screens/onboarding_paywall_screen.dart';
import 'package:intended/services/moments_service.dart';
import 'package:intended/services/revenue_cat_service.dart';
import 'package:intended/state/user_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the new onboarding screens to PNG so a person can look at them
/// (CLAUDE.md: tests never caught a single design failure). Nothing is
/// compared, so this is not a golden test. Skipped unless RENDER_DIR is set:
///
///   RENDER_DIR=/tmp/shots flutter test test/render/onboarding_render_test.dart
///
/// Real fonts, Iris colours and painting, iPhone 15 size. No status bar, and
/// blur is approximate: a device still has the last word. The `frames/`
/// folder holds the opening animation frame by frame, 20 per second.
final String? _dir = Platform.environment['RENDER_DIR'];
const _boundary = Key('render-boundary');
final _sealedAt = DateTime(2026, 9, 29, 20);

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final file in files) {
      loader.addFont(rootBundle.load(file));
    }
    await loader.load();
  }

  const f = 'assets/fonts';
  await family('Sora', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) '$f/Sora-$w.ttf',
  ]);
  await family('DMSans', [
    for (final w in ['Regular', 'Medium', 'SemiBold']) '$f/DMSans-$w.ttf',
  ]);
  await family('Montserrat', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      '$f/Montserrat-$w.ttf',
  ]);
  await family('packages/cupertino_icons/CupertinoIcons', [
    'packages/cupertino_icons/assets/CupertinoIcons.ttf',
  ]);
}

Future<void> _mount(
  WidgetTester tester,
  Widget screen, {
  required OnboardingState state,
  required Locale locale,
}) async {
  tester.view.physicalSize = const Size(393 * 3, 852 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: state),
        ],
        child: CupertinoApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    ),
  );
  // Decode the painting and every glyph before any picture is taken.
  await tester.runAsync(() async {
    final context = tester.element(find.byType(CupertinoApp));
    await precacheImage(
      const AssetImage('assets/images/background_ms_iris.png'),
      context,
    );
    await precacheImage(
      const AssetImage('assets/images/paywall_sunrise_iris.webp'),
      context,
    );
    for (final path in IntentionPathId.values.map(IntentionPath.getById)) {
      await precacheImage(AssetImage(path.iconAsset), context);
    }
    for (final area in [...OnboardingState.focusAreaOptions, null]) {
      await precacheImage(AssetImage(CategoryGlyphs.of(area)), context);
    }
  });
  await tester.pumpAndSettle();
}

Future<void> _shot(WidgetTester tester, String file, {double ratio = 2}) {
  return tester.runAsync(() async {
    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(_boundary));
    final image = await boundary.toImage(pixelRatio: ratio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(file).create(recursive: true);
    await File(file).writeAsBytes(png!.buffer.asUint8List());
  });
}

Future<OnboardingState> _windingDown() async {
  final state = OnboardingState();
  await state.setSelectedIntentionPath(IntentionPathId.windingDown.key);
  return state;
}

/// Holds the button for 1.3 s, frame by frame, calling [each] every 50 ms.
Future<void> _hold(WidgetTester tester, [Future<void> Function()? each]) async {
  final gesture = await tester
      .startGesture(tester.getCenter(find.byType(HoldToConfirmButton)));
  for (var t = 0; t < 1300; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
    if (each != null) await each();
  }
  await gesture.up();
}

void main() {
  setUpAll(() async {
    if (_dir != null) await _loadFonts();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;

    testWidgets('direction, $lc', (tester) async {
      await _mount(tester, DirectionScreen(onContinue: () {}),
          state: OnboardingState(), locale: locale);
      await tester.tap(find.byWidgetPredicate((w) =>
          w is DirectionCard && w.path.id == IntentionPathId.windingDown));
      await tester.pumpAndSettle();
      await _shot(tester, '$_dir/onboarding_2_direction_$lc.png');
    }, skip: _dir == null);

    testWidgets('sentence, $lc', (tester) async {
      await _mount(
          tester, SentenceScreen(onContinue: () {}, now: () => _sealedAt),
          state: await _windingDown(), locale: locale);
      await _shot(tester, '$_dir/onboarding_3_sentence_$lc.png');
    }, skip: _dir == null);

    testWidgets('chapter, $lc', (tester) async {
      await _mount(
          tester, SentenceScreen(onContinue: () {}, now: () => _sealedAt),
          state: await _windingDown(), locale: locale);
      await _hold(tester);
      await tester.pumpAndSettle();
      await _shot(tester, '$_dir/onboarding_3_chapter_$lc.png');
    }, skip: _dir == null);
  }

  testWidgets('the opening, frame by frame', (tester) async {
    await _mount(
        tester, SentenceScreen(onContinue: () {}, now: () => _sealedAt),
        state: await _windingDown(), locale: const Locale('en'));
    var frame = 0;
    Future<void> capture() => _shot(
        tester, '$_dir/frames/${(frame++).toString().padLeft(3, '0')}.png',
        ratio: 1);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      await capture(); // a still beat before the finger lands
    }
    await _hold(tester, capture);
    for (var t = 0; t < SentenceScreen.opening.inMilliseconds + 600; t += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      await capture();
    }
  }, skip: _dir == null);

  Future<OnboardingState> sealed(DateTime at) async {
    final state = await _windingDown();
    final path = IntentionPath.getById(IntentionPathId.windingDown);
    await state.applyPathDefaults(path.defaultFocusAreas, path.id.key);
    await state.sealSentence('let the day go before I sleep',
        pathKey: path.id.key, at: at);
    return state;
  }

  Future<void> chooseTwo(WidgetTester tester) async {
    final cards = tester.widgetList<ActionCard>(find.byType(ActionCard));
    for (final action in cards.take(3).skip(1).map((c) => c.action).toList()) {
      await tester.tap(
          find.byWidgetPredicate((w) => w is ActionCard && w.action == action));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;
    testWidgets('start small, $lc', (tester) async {
      await _mount(tester, StartSmallScreen(onContinue: () {}),
          state: await sealed(DateTime(2026, 9, 1, 12)), locale: locale);
      await chooseTwo(tester);
      await _shot(tester, '$_dir/onboarding_4_start_small_$lc.png');
    }, skip: _dir == null);

    testWidgets('start small, short month, $lc', (tester) async {
      await _mount(tester, StartSmallScreen(onContinue: () {}),
          state: await sealed(DateTime(2026, 9, 11, 12)), locale: locale);
      await chooseTwo(tester);
      await _shot(tester, '$_dir/onboarding_4_start_small_short_$lc.png');
    }, skip: _dir == null);
  }

  Future<OnboardingState> withActions() async {
    final state = await sealed(DateTime(2026, 9, 1, 12));
    await state.adoptChosenActions(const [
      'Light a scented candle',
      'Drink something warm',
      'Notice one thing you feel',
    ]);
    return state;
  }

  Finder chip(int i) => find
      .descendant(of: find.byType(Wrap), matching: find.byType(GestureDetector))
      .at(i);

  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;
    testWidgets('cues, $lc', (tester) async {
      await _mount(tester, CuesScreen(onContinue: (_) {}),
          state: await withActions(), locale: locale);
      await _shot(tester, '$_dir/onboarding_5_cues_blank_$lc.png');

      // The chosen words land; the action has not moved on yet.
      await tester.tap(chip(3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));
      await _shot(tester, '$_dir/onboarding_5_cues_landed_$lc.png');

      // The rest, until every action has a cue.
      for (final i in [0, 1]) {
        await tester.pump(CuesScreen.beat);
        await tester.pumpAndSettle();
        await tester.tap(chip(i));
        await tester.pump();
      }
      await tester.pump(CuesScreen.beat);
      await tester.pumpAndSettle();
      await _shot(tester, '$_dir/onboarding_5_cues_all_$lc.png');
    }, skip: _dir == null);
  }

  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;
    testWidgets('try it, $lc', (tester) async {
      final state = await withActions();
      await _mount(tester, TryItScreen(onContinue: (_) {}),
          state: state, locale: locale);
      await _shot(tester, '$_dir/onboarding_7_try_before_$lc.png');

      final first = tester.widget<Text>(find
          .descendant(of: find.byType(ListView), matching: find.byType(Text))
          .first);
      await tester.tap(find.text(first.data!));
      // The recording is real storage work: let it finish off the fake clock.
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pump();
      }
      var frame = 0;
      for (var t = 0; t <= TryItScreen.landing.inMilliseconds; t += 50) {
        if (lc == 'en') {
          await _shot(tester,
              '$_dir/try_frames/f_${(frame++).toString().padLeft(3, '0')}.png',
              ratio: 1);
        }
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      await _shot(tester, '$_dir/onboarding_7_try_landed_$lc.png');
    }, skip: _dir == null);
  }

  testWidgets('flow, changing screens', (tester) async {
    await _mount(
        tester, OnboardingFlow(finish: (_, {required recorded}) async {}),
        state: OnboardingState(), locale: const Locale('en'));
    await tester.tap(find.byWidgetPredicate(
        (w) => w is DirectionCard && w.path.id == IntentionPathId.windingDown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    var frame = 0;
    for (var t = 0; t <= OnboardingFlow.change.inMilliseconds + 80; t += 40) {
      await _shot(tester,
          '$_dir/flow_frames/f_${(frame++).toString().padLeft(3, '0')}.png',
          ratio: 1);
      await tester.pump(const Duration(milliseconds: 40));
    }
  }, skip: _dir == null);

  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;
    testWidgets('paywall after the first moment, $lc', (tester) async {
      await MomentsService.record(
          Moment.create(habitName: 'Light a scented candle'));
      await _mount(
          tester,
          ChangeNotifierProvider(
            create: (_) => RevenueCatService(UserState()),
            child: const OnboardingPaywallScreen(),
          ),
          state: OnboardingState(),
          locale: locale);
      await _shot(tester, '$_dir/onboarding_8_paywall_$lc.png');
    }, skip: _dir == null);
  }

  testWidgets('cues, own words', (tester) async {
    await _mount(tester, CuesScreen(onContinue: (_) {}),
        state: await withActions(), locale: const Locale('en'));
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    await _shot(tester, '$_dir/onboarding_5_cues_own_en.png');
  }, skip: _dir == null);

  testWidgets('start small, focus sheet', (tester) async {
    await _mount(tester, StartSmallScreen(onContinue: () {}),
        state: await sealed(DateTime(2026, 9, 1, 12)),
        locale: const Locale('en'));
    await tester.tap(find.text('change'));
    await tester.pumpAndSettle();
    await _shot(tester, '$_dir/onboarding_4_focus_sheet_en.png');
  }, skip: _dir == null);
}
