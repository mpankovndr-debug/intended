import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/main.dart' show IntendedApp;
import 'package:intended/theme/theme_provider.dart';
import 'package:intended/utils/responsive_utils.dart';
import 'package:intended/utils/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mounts [home] under what `IntendedApp` hands its `CupertinoApp` — the
/// app's own theme, builder and locale rules — on a device set to [device].
///
/// The configuration is read off the real widget rather than copied here, so
/// these tests fail if `main.dart` stops installing the default; the first
/// screen is swapped out because it boots the whole app.
Future<void> _pumpApp(WidgetTester tester, Locale device, Widget home) async {
  tester.platformDispatcher.localesTestValue = [device];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(const SizedBox());
  final app = const IntendedApp().build(tester.element(find.byType(SizedBox)))
      as CupertinoApp;

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: CupertinoApp(
        localizationsDelegates: app.localizationsDelegates,
        supportedLocales: app.supportedLocales,
        localeResolutionCallback: app.localeResolutionCallback,
        theme: app.theme,
        builder: app.builder,
        home: Builder(
          builder: (context) {
            Responsive.init(context);
            return home;
          },
        ),
      ),
    ),
  );
  await tester.pump();
}

/// The family [text] is actually laid out in.
String? _familyOf(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.fontFamily;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // A device in any language but Russian gets the English app, so German
  // stands in for "everything else".
  for (final (device, family) in const [
    (Locale('ru', 'RU'), 'Montserrat'),
    (Locale('en', 'US'), 'Sora'),
    (Locale('de', 'DE'), 'Sora'),
  ]) {
    testWidgets('text that names no family is set in $family on $device',
        (tester) async {
      late BuildContext page;
      await _pumpApp(
        tester,
        device,
        Builder(
          builder: (context) {
            page = context;
            // Styled, but with no family: the theme picker's exact case.
            return const Text('Тёплый песок', style: TextStyle(fontSize: 14));
          },
        ),
      );

      expect(_familyOf(tester, 'Тёплый песок'), family);
      // Cupertino buttons and fields take theirs from the theme instead.
      expect(CupertinoTheme.of(page).textTheme.textStyle.fontFamily, family);
    });
  }

  testWidgets('a sheet pushed over the page inherits the default',
      (tester) async {
    late BuildContext page;
    await _pumpApp(
      tester,
      const Locale('ru', 'RU'),
      Builder(
        builder: (context) {
          page = context;
          return const SizedBox();
        },
      ),
    );

    // A route is a sibling of the page under the Navigator, not its child:
    // a default wrapped around `home` alone would stop at the page's edge.
    showCupertinoModalPopup<void>(
      context: page,
      builder: (_) => const Text('Ночное небо'),
    );
    await tester.pumpAndSettle();

    expect(_familyOf(tester, 'Ночное небо'), 'Montserrat');
  });

  testWidgets('English keeps exactly the default it had', (tester) async {
    late BuildContext page;
    await _pumpApp(
      tester,
      const Locale('en', 'US'),
      Builder(
        builder: (context) {
          page = context;
          return const SizedBox();
        },
      ),
    );

    // What `CupertinoApp.theme` carried before the default moved below
    // Localizations, to the letter.
    const before = TextStyle(
      fontFamily: 'Sora',
      fontFamilyFallback: ['SF Pro', 'SF Pro Rounded'],
    );
    expect(DefaultTextStyle.of(page).style, before);
    expect(CupertinoTheme.of(page).textTheme.textStyle, before);
  });

  for (final (device, family) in const [
    (Locale('ru', 'RU'), 'Montserrat'),
    (Locale('en', 'US'), 'Sora'),
  ]) {
    testWidgets('every header style is set in $family on $device',
        (tester) async {
      late BuildContext page;
      await _pumpApp(
        tester,
        device,
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox();
          },
        ),
      );

      // These were Sora "always", which in Russian meant the system face:
      // «Твой месяц» at the top of Insights, in a typeface found nowhere
      // else on the page.
      final headers = {
        'display': AppTextStyles.display(page),
        'h1': AppTextStyles.h1(page),
        'h2': AppTextStyles.h2(page),
        'h3': AppTextStyles.h3(page),
        'categoryHeader': AppTextStyles.categoryHeader(page),
        'sectionLabel': AppTextStyles.sectionLabel(page),
        'summaryLarge': AppTextStyles.summaryLarge(page),
      };
      for (final MapEntry(key: name, value: style) in headers.entries) {
        expect(style.fontFamily, family, reason: name);
      }
    });
  }
}
