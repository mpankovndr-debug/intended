import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/main.dart' show HabitsScreen;
import 'package:intended/models/action_cue.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/services/action_cues.dart';
import 'package:intended/services/backup_service.dart';
import 'package:intended/services/revenue_cat_service.dart';
import 'package:intended/state/user_state.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Today with a cue under one action, rendered with real fonts for a human
/// to look at. Skipped unless RENDER_DIR is set.
final _dir = Platform.environment['RENDER_DIR'];
final _boundary = GlobalKey();

Future<void> _family(String name, List<String> files) async {
  final loader = FontLoader(name);
  for (final f in files) {
    loader.addFont(rootBundle.load(f));
  }
  await loader.load();
}

void main() {
  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;
    testWidgets('today with a cue, $lc', (tester) async {
      const f = 'assets/fonts';
      await _family('Sora', [
        for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
          '$f/Sora-$w.ttf'
      ]);
      await _family('DMSans', [
        for (final w in ['Regular', 'Medium', 'SemiBold']) '$f/DMSans-$w.ttf'
      ]);
      await _family('Montserrat', [
        for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
          '$f/Montserrat-$w.ttf'
      ]);
      await _family('packages/cupertino_icons/CupertinoIcons',
          ['packages/cupertino_icons/assets/CupertinoIcons.ttf']);

      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
        'selected_intention_path': 'winding_down',
        'focus_areas': ['Health', 'Mood'],
        'user_habits': [
          'Light a scented candle',
          'Drink something warm',
          'Notice one thing you feel',
        ],
      });
      await ActionCues.set(
          'Drink something warm', const ActionCue.preset(CuePreset.dinner));
      await ActionCues.set(
          'Light a scented candle', const ActionCue.preset(CuePreset.bed));
      final state = OnboardingState();
      await state.loadUserHabits();
      await state.loadSelectedIntentionPath();

      tester.view.physicalSize = const Size(393 * 3, 852 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final user = UserState();
      await tester.pumpWidget(RepaintBoundary(
        key: _boundary,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider.value(value: state),
            ChangeNotifierProvider.value(value: user),
            ChangeNotifierProvider(create: (_) => RevenueCatService(user)),
            ChangeNotifierProvider(create: (_) => BackupService()),
          ],
          child: CupertinoApp(
            debugShowCheckedModeBanner: false,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HabitsScreen(),
          ),
        ),
      ));
      await tester.runAsync(() async {
        final context = tester.element(find.byType(HabitsScreen));
        await precacheImage(
            const AssetImage('assets/images/background_ms_iris.png'), context);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.runAsync(() async {
        final boundary =
            tester.renderObject<RenderRepaintBoundary>(find.byKey(_boundary));
        final image = await boundary.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('$_dir/today_cue_$lc.png');
        await file.create(recursive: true);
        await file.writeAsBytes(png!.buffer.asUint8List());
      });
    }, skip: _dir == null);
  }
}
