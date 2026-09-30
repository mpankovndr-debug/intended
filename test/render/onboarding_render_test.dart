import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/direction_screen.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/onboarding_v2/sentence_screen.dart';
import 'package:intended/onboarding_v2/widgets/hold_to_confirm_button.dart';
import 'package:intended/theme/theme_provider.dart';
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
    for (final path in IntentionPathId.values.map(IntentionPath.getById)) {
      await precacheImage(AssetImage(path.iconAsset), context);
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
}
