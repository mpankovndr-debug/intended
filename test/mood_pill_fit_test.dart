import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/screens/habit_completion_modal.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:intended/utils/responsive_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The completion sheet's mood pills never break a word inside itself.
/// «Нейтрально» did at 375pt in Russian: «Нейтральн» over «о».
void main() {
  group('pillFontSize', () {
    const style = TextStyle(fontSize: HabitCompletionModal.pillFontSizeMax);
    const one = TextScaler.noScaling;

    double widthOf(String word, double size,
            [TextScaler scaler = TextScaler.noScaling]) =>
        (TextPainter(
          text: TextSpan(text: word, style: style.copyWith(fontSize: size)),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout())
            .width;

    double? fit(List<String> labels, double width,
            [TextScaler scaler = TextScaler.noScaling]) =>
        HabitCompletionModal.pillFontSize(labels, style, width, scaler);

    test('keeps the full size when every word fits', () {
      expect(fit(['Neutral'], widthOf('Neutral', 13)), 13);
    });

    test('a label may wrap between its words, so only words are measured',
        () {
      // Wide enough for "effort", not for "Took effort" on one line.
      expect(fit(['Took effort'], widthOf('effort', 13)), 13);
    });

    test('steps down until the longest word fits, the same size for all', () {
      final width = widthOf('Neutral', 12);
      final size = fit(['Glad I did', 'Neutral', 'Took effort'], width)!;
      expect(size, lessThan(13));
      expect(size, greaterThanOrEqualTo(HabitCompletionModal.pillFontSizeMin));
      expect(widthOf('Neutral', size), lessThanOrEqualTo(width));
      expect(widthOf('Neutral', size + 0.5), greaterThan(width));
    });

    test('gives up below the smallest size, so the pills stack', () {
      expect(fit(['Neutral'], widthOf('Neutral', 10)), isNull);
    });

    test('measures at the reader\'s text size', () {
      final width = widthOf('Neutral', 13);
      const large = TextScaler.linear(1.35);
      expect(fit(['Neutral'], width, one), 13);
      expect(fit(['Neutral'], width, large), isNull);
    });
  });

  group('on the sheet, with the real fonts', () {
    Future<void> pump(WidgetTester tester,
        {required double width, required String locale, double scale = 1}) async {
      for (final family in ['Montserrat', 'Sora']) {
        final loader = FontLoader(family);
        for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
          loader.addFont(rootBundle.load('assets/fonts/$family-$w.ttf'));
        }
        await loader.load();
      }
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = Size(width * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: CupertinoApp(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            Responsive.init(context);
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            );
          },
          home: CupertinoPageScaffold(
            child: HabitCompletionModal(
              draft: Moment.create(
                habitName: 'Take 3 slow breaths',
                category: 'Health',
              ),
              monthCategories: const ['Health'],
              onDone: (_) async {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    RenderParagraph label(WidgetTester tester, String text) =>
        tester.renderObject<RenderParagraph>(find.text(text));

    bool unbroken(RenderParagraph p) =>
        p.getMaxIntrinsicWidth(double.infinity) <= p.constraints.maxWidth;

    testWidgets('Russian at 375pt: one row, «Нейтрально» whole',
        (tester) async {
      await pump(tester, width: 375, locale: 'ru');
      final neutral = label(tester, 'Нейтрально');
      expect(unbroken(neutral), isTrue);
      expect(tester.getTopLeft(find.text('Нейтрально')).dy,
          moreOrLessEquals(tester.getTopLeft(find.text('Стоило того')).dy,
              epsilon: 12));
    });

    testWidgets('Russian at 375pt with large text: one per line, whole',
        (tester) async {
      await pump(tester, width: 375, locale: 'ru', scale: 1.35);
      expect(unbroken(label(tester, 'Нейтрально')), isTrue);
      expect(unbroken(label(tester, 'Было непросто')), isTrue);
      final glad = tester.getTopLeft(find.text('Стоило того')).dy;
      final neutral = tester.getTopLeft(find.text('Нейтрально')).dy;
      final effort = tester.getTopLeft(find.text('Было непросто')).dy;
      expect(glad, lessThan(neutral));
      expect(neutral, lessThan(effort));
    });

    testWidgets('English at 393pt keeps the full size', (tester) async {
      await pump(tester, width: 393, locale: 'en');
      final style = tester.widget<Text>(find.text('Neutral')).style!;
      expect(style.fontSize, HabitCompletionModal.pillFontSizeMax);
    });
  });
}
