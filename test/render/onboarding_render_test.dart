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
/// Real fonts, Iris colours, iPhone 15 size. No animation, no status bar,
/// and blur is approximate: a device still has the last word.
final String? _dir = Platform.environment['RENDER_DIR'];
const _boundary = Key('render-boundary');

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

Future<void> _render(
  WidgetTester tester,
  String name,
  Widget screen, {
  required OnboardingState state,
  Locale locale = const Locale('en'),
  Future<void> Function(WidgetTester)? arrange,
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
  // Decode every glyph before the picture is taken.
  await tester.runAsync(() async {
    final context = tester.element(find.byType(CupertinoApp));
    for (final path in IntentionPathId.values.map(IntentionPath.getById)) {
      await precacheImage(AssetImage(path.iconAsset), context);
    }
  });
  await tester.pumpAndSettle();
  if (arrange != null) await arrange(tester);
  await tester.runAsync(() async {
    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(_boundary));
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$_dir/$name.png').writeAsBytes(png!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    if (_dir != null) await _loadFonts();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> chooseWindingDown(WidgetTester tester) async {
    await tester.tap(find.byWidgetPredicate(
        (w) => w is DirectionCard && w.path.id == IntentionPathId.windingDown));
    await tester.pumpAndSettle();
  }

  for (final locale in const [Locale('en'), Locale('ru')]) {
    testWidgets('direction, ${locale.languageCode}', (tester) async {
      await _render(
        tester,
        'onboarding_2_direction_${locale.languageCode}',
        DirectionScreen(onContinue: () {}),
        state: OnboardingState(),
        locale: locale,
        arrange: chooseWindingDown,
      );
    }, skip: _dir == null);
  }

  Future<OnboardingState> windingDownState() async {
    final state = OnboardingState();
    await state.setSelectedIntentionPath(IntentionPathId.windingDown.key);
    return state;
  }

  Future<void> holdToSeal(WidgetTester tester) async {
    final gesture = await tester
        .startGesture(tester.getCenter(find.byType(HoldToConfirmButton)));
    for (var t = 0; t < 1300; t += 50) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;
    testWidgets('sentence, $lc', (tester) async {
      await _render(
        tester,
        'onboarding_3_sentence_$lc',
        SentenceScreen(onContinue: () {}, now: () => DateTime(2026, 9, 29, 20)),
        state: await windingDownState(),
        locale: locale,
      );
    }, skip: _dir == null);

    testWidgets('chapter, $lc', (tester) async {
      await _render(
        tester,
        'onboarding_3_chapter_$lc',
        SentenceScreen(onContinue: () {}, now: () => DateTime(2026, 9, 29, 20)),
        state: await windingDownState(),
        locale: locale,
        arrange: holdToSeal,
      );
    }, skip: _dir == null);
  }
}
