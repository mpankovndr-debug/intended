// The Firebase mock ships inside a package this app only depends on
// transitively.
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/features/onboarding/screens/intention_path_screen.dart';
import 'package:intended/features/onboarding/screens/philosophy_screen.dart';
import 'package:intended/features/profile/change_path_screen.dart';
import 'package:intended/features/profile/faq_screen.dart';
import 'package:intended/l10n/app_localizations.dart';
import 'package:intended/main.dart' show HabitsScreen, IntendedApp;
import 'package:intended/models/intention_path.dart';
import 'package:intended/models/moment.dart';
import 'package:intended/onboarding_v2/commitment_screen.dart';
import 'package:intended/onboarding_v2/daily_reminder_screen.dart';
import 'package:intended/onboarding_v2/focus_areas_screen.dart';
import 'package:intended/onboarding_v2/habit_reveal_screen.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/onboarding_v2/tell_us_about_you_screen.dart';
import 'package:intended/onboarding_v2/theme_selection_screen.dart';
import 'package:intended/onboarding_v2/welcome_v2_screen.dart';
import 'package:intended/screens/insights_screen.dart';
import 'package:intended/screens/onboarding_paywall_screen.dart';
import 'package:intended/screens/paywall_screen.dart';
import 'package:intended/screens/profile_screen.dart';
import 'package:intended/screens/subscription_management_modal.dart';
import 'package:intended/screens/year_in_seasons_screen.dart';
import 'package:intended/services/backup_service.dart';
import 'package:intended/services/revenue_cat_service.dart';
import 'package:intended/state/user_state.dart';
import 'package:intended/theme/theme_provider.dart';
import 'package:intended/utils/habit_l10n.dart';
import 'package:intended/utils/responsive_utils.dart';
import 'package:intended/widgets/app_icon_picker.dart';
import 'package:intended/widgets/boost_offer_sheet.dart';
import 'package:intended/widgets/coach_mark_overlay.dart';
import 'package:intended/widgets/theme_picker.dart';
import 'package:intended/widgets/upgrade_nudge_banner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the app's screens in English and Russian with the real fonts,
/// for a person to look at (CLAUDE.md: tests never caught a single design
/// failure). Nothing is compared, so this is not a golden test. Skipped
/// unless RENDER_DIR is set:
///
///   RENDER_DIR=/tmp/shots flutter test test/render/screens_render_test.dart
///
/// iPhone 15 size unless RENDER_SIZE says otherwise (`RENDER_SIZE=375x667`
/// for the narrowest phone, where a wide word bites first). Iris, free tier,
/// no status bar; blur is approximate and a device still has the last word.
/// Not reachable from here: a paywall price, which is only drawn once a store
/// has answered.
///
/// Beside each PNG sits a `.spans.txt`: every piece of text on the screen
/// with the font family it resolved to. A test binding has no system fonts,
/// so a glyph the named family cannot draw shows as a box — which is how
/// Russian set in Sora announces itself here, where a device would quietly
/// substitute its own face. Layout errors go to `.errors.txt` and text that
/// did not fit to `.cut.txt`; neither file exists for a clean screen.
final String? _dir = Platform.environment['RENDER_DIR'];
final Size _size = () {
  final raw = Platform.environment['RENDER_SIZE'];
  if (raw == null) return const Size(393, 852);
  final sides = raw.split('x').map(double.parse).toList();
  return Size(sides[0], sides[1]);
}();
const _boundary = Key('render-boundary');
const _home = Key('render-home');

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
  await family('Montserrat', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      '$f/Montserrat-$w.ttf',
  ]);
  await family('packages/cupertino_icons/CupertinoIcons', [
    'packages/cupertino_icons/assets/CupertinoIcons.ttf',
  ]);
}

/// Screens log their own views, and `FirebaseAnalytics.instance` throws in a
/// binding with no Firebase app — mid-build, which paints the red error
/// screen instead of the page. A mock app and an analytics channel that
/// answers "done" to everything are enough.
Future<void> _fakeFirebase() async {
  setupFirebaseCoreMocks();
  await Firebase.initializeApp();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const api =
      'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi';
  for (final method in const [
    'logEvent',
    'setUserId',
    'setUserProperty',
    'setAnalyticsCollectionEnabled',
    'setDefaultEventParameters',
  ]) {
    messenger.setMockMessageHandler(
      '$api.$method',
      (_) async => const StandardMessageCodec().encodeMessage(<Object?>[]),
    );
  }

  // Profile asks who is signed in. Nobody is: the two listeners get a stream
  // that never speaks.
  const auth =
      'dev.flutter.pigeon.firebase_auth_platform_interface.FirebaseAuthHostApi';
  for (final listener in const [
    'registerIdTokenListener',
    'registerAuthStateListener',
  ]) {
    final events = 'render/$listener';
    messenger.setMockMessageHandler(
      '$auth.$listener',
      (_) async => const StandardMessageCodec().encodeMessage(<Object?>[events]),
    );
    messenger.setMockStreamHandler(
      EventChannel(events),
      MockStreamHandler.inline(onListen: (_, __) {}),
    );
  }
  PackageInfo.setMockInitialValues(
    appName: 'Intended',
    packageName: 'render',
    version: '0.0.0',
    buildNumber: '0',
    buildSignature: '',
  );
}

/// Mounts [home] the way `IntendedApp` would: same providers, and the theme
/// and builder read off the real widget rather than copied here, so the
/// app-wide default text style in these pictures is the app's own.
Future<void> _mount(
  WidgetTester tester,
  Locale locale,
  Widget home, {
  Map<String, Object> prefs = const {},
}) async {
  await _loadFonts();
  await _fakeFirebase();
  SharedPreferences.setMockInitialValues({
    'onboarding_complete': true,
    'selected_intention_path': 'winding_down',
    'focus_areas': ['Health', 'Mood'],
    'user_habits': [
      'Light a scented candle',
      'Drink something warm',
      'Notice one thing you feel',
    ],
    ...prefs,
  });
  final state = OnboardingState();
  await state.loadUserHabits();
  await state.loadSelectedIntentionPath();
  state.setName('Alex');
  final user = UserState();

  tester.view.physicalSize = _size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const SizedBox());
  final app = const IntendedApp().build(tester.element(find.byType(SizedBox)))
      as CupertinoApp;

  await tester.pumpWidget(
    RepaintBoundary(
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
          theme: app.theme,
          builder: app.builder,
          home: Builder(
            builder: (context) {
              Responsive.init(context);
              return KeyedSubtree(key: _home, child: home);
            },
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    final context = tester.element(find.byType(CupertinoApp));
    await precacheImage(
      const AssetImage('assets/images/background_ms_iris.png'),
      context,
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await _settle(tester);
}

/// Entrance animations run for a few seconds and some screens never settle
/// (a spinner, a breathing glow), so this steps a fixed distance instead.
Future<void> _settle(WidgetTester tester, {int frames = 30}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

bool _isPrivateUse(int rune) => rune >= 0xE000 && rune <= 0xF8FF;

/// Every piece of text on screen, with the family its style resolved to.
String _spans(WidgetTester tester) {
  final lines = <String>[];
  void walk(InlineSpan span, TextStyle? inherited) {
    final style = inherited == null ? span.style : inherited.merge(span.style);
    if (span is! TextSpan) return;
    final text = span.text;
    if (text != null &&
        text.trim().isNotEmpty &&
        !text.runes.every(_isPrivateUse)) {
      lines.add(
        '${(style?.fontFamily ?? '(none)').padRight(22)} '
        '${(style?.fontSize ?? 0).toStringAsFixed(1).padLeft(5)} '
        'w${style?.fontWeight?.value ?? 400}  '
        '${text.replaceAll('\n', '⏎')}',
      );
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      walk(child, style);
    }
  }

  // One entry per element comes back, so a `Text` and the `RichText` under it
  // both hand over the same paragraph: the set keeps each once, in order.
  for (final object in {...tester.allRenderObjects}) {
    if (object is RenderParagraph) {
      walk(object.text, null);
    } else if (object is RenderEditable && object.text != null) {
      walk(object.text!, null);
    }
  }
  return lines.join('\n');
}

/// Text that did not fit: cut short by `maxLines`, or laid out larger than
/// the box it was given. Neither raises an error, and both are what a wider
/// face does to a line that used to fit.
String _cuts(WidgetTester tester) {
  final lines = <String>[];
  for (final object in {...tester.allRenderObjects}) {
    if (object is! RenderParagraph || !object.hasSize) continue;
    final text = object.text.toPlainText().replaceAll('\n', '⏎');
    if (text.trim().isEmpty || text.runes.every(_isPrivateUse)) continue;
    // An ellipsis with no `maxLines` still means one line, so it has to be
    // replayed here or those labels pass for text that simply wrapped.
    final ellipsized = object.overflow == TextOverflow.ellipsis;
    final painter = TextPainter(
      text: object.text,
      textAlign: object.textAlign,
      textDirection: object.textDirection,
      textScaler: object.textScaler,
      maxLines: object.maxLines,
      ellipsis: ellipsized ? '…' : null,
      locale: object.locale,
      strutStyle: object.strutStyle,
      textWidthBasis: object.textWidthBasis,
      textHeightBehavior: object.textHeightBehavior,
    )..layout(
        minWidth: object.constraints.minWidth,
        maxWidth: object.constraints.maxWidth,
      );
    if (painter.didExceedMaxLines) {
      // How far off it is: the same text on one unbounded line.
      final whole = TextPainter(
        text: object.text,
        textDirection: object.textDirection,
        textScaler: object.textScaler,
        maxLines: 1,
      )..layout();
      lines.add(
        'cut at ${object.maxLines ?? 1} line(s), needs '
        '${whole.width.toStringAsFixed(1)} of '
        '${object.constraints.maxWidth.toStringAsFixed(1)}  $text',
      );
      whole.dispose();
    } else if (object.textSize.width > object.size.width + 0.5 ||
        object.textSize.height > object.size.height + 0.5) {
      lines.add('larger than its box  $text');
    }
    painter.dispose();
  }
  return lines.join('\n');
}

Future<void> _shot(WidgetTester tester, String name, List<String> errors) async {
  await tester.runAsync(() async {
    final boundary =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(_boundary));
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_dir/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(png!.buffer.asUint8List());
  });
  File('$_dir/$name.spans.txt').writeAsStringSync('${_spans(tester)}\n');
  void note(String suffix, String body) {
    final file = File('$_dir/$name.$suffix.txt');
    if (body.isNotEmpty) {
      file.writeAsStringSync('$body\n');
    } else if (file.existsSync()) {
      file.deleteSync();
    }
  }

  note('errors', errors.join('\n'));
  note('cut', _cuts(tester));
}

/// One screen, both languages. Layout errors are written beside the picture
/// rather than failing the run: this is a tool for looking, and an overflow
/// is exactly the thing worth looking at.
void _render(
  String name,
  Widget Function() build, {
  Future<void> Function(WidgetTester tester, AppLocalizations l10n)? then,
  Map<String, Object> Function(Locale locale)? prefs,
}) {
  for (final locale in const [Locale('en'), Locale('ru')]) {
    final lc = locale.languageCode;
    testWidgets('$name, $lc', (tester) async {
      final errors = <String>[];
      final binding = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details.exceptionAsString().split('\n').take(3).join(' / '));
      };
      try {
        await _mount(tester, locale, build(), prefs: prefs?.call(locale) ?? {});
        if (then != null) {
          await then(
            tester,
            AppLocalizations.of(tester.element(find.byKey(_home))),
          );
          await _settle(tester, frames: 12);
        }
        await _shot(tester, '${name}_$lc', errors);
        // Unmount and let every delayed callback run out.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 30));
      } finally {
        FlutterError.onError = binding;
      }
    }, skip: _dir == null);
  }
}

/// A plain page for widgets that are not screens.
Widget _page(Widget child) => CupertinoPageScaffold(
      backgroundColor: const Color(0xFFEAE4F2),
      child: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );

/// Long-presses a card on Today, which opens its menu.
Future<void> _menu(WidgetTester tester, String habit) async {
  await tester.longPress(find.text(habit).first);
  await _settle(tester, frames: 8);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder, warnIfMissed: false);
  await _settle(tester, frames: 8);
}

/// An action the user wrote themselves, so Edit and Delete exist in the menu.
/// It is their own words, so each language gets its own.
String _own(String languageCode) =>
    languageCode == 'ru' ? 'Читать перед сном' : 'Read before bed';

Map<String, Object> _withOwnAction(Locale locale) {
  final own = _own(locale.languageCode);
  return {
    'user_habits': [
      'Light a scented candle',
      'Drink something warm',
      'Notice one thing you feel',
      own,
    ],
    'custom_habits': [own],
    'custom_habit_focus_areas': jsonEncode({own: 'Mood'}),
    'pinned_habit': 'Drink something warm',
  };
}

void main() {
  _render('today', () => const HabitsScreen());

  // What a card on Today opens. Each of these is a dialog with a heading
  // that used to be Sora.
  _render(
    'today_swap',
    () => const HabitsScreen(),
    then: (tester, l10n) async {
      await _menu(tester, localizeHabitName('Light a scented candle', l10n));
      await _tap(tester, find.text(l10n.menuSwap).last);
    },
  );
  // …and taken through. The alternatives are the dialog's only 15pt lines,
  // and the dialog is the last route in the tree, so the last one is one of
  // them.
  _render(
    'today_swap_done',
    () => const HabitsScreen(),
    then: (tester, l10n) async {
      await _menu(tester, localizeHabitName('Light a scented candle', l10n));
      await _tap(tester, find.text(l10n.menuSwap).last);
      final offered = find.byWidgetPredicate(
        (w) => w is Text && w.style?.fontSize == 15,
      );
      await _tap(tester, offered.last);
    },
  );
  _render(
    'today_replace_pin',
    () => const HabitsScreen(),
    prefs: _withOwnAction,
    then: (tester, l10n) async {
      await _menu(tester, localizeHabitName('Light a scented candle', l10n));
      await _tap(tester, find.text(l10n.menuPinToTop).last);
    },
  );
  _render(
    'today_edit',
    () => const HabitsScreen(),
    prefs: _withOwnAction,
    then: (tester, l10n) async {
      await _menu(tester, _own(l10n.localeName));
      await _tap(tester, find.text(l10n.editHabitTitle).last);
    },
  );
  _render(
    'today_delete',
    () => const HabitsScreen(),
    prefs: _withOwnAction,
    then: (tester, l10n) async {
      await _menu(tester, _own(l10n.localeName));
      await _tap(tester, find.text(l10n.commonDelete).last);
    },
  );
  _render(
    'today_create',
    () => const HabitsScreen(),
    then: (tester, l10n) => _tap(tester, find.text(l10n.habitsAddYourOwn)),
  );
  // Nine quiet days: the reduced screen, with the rescue card's heading.
  _render(
    'today_rescue',
    () => const HabitsScreen(),
    prefs: (_) => {
      'moments_collection': jsonEncode([
        Moment(
          id: 'render',
          habitName: 'Drink something warm',
          habitEmoji: '',
          completedAt:
              DateTime.now().toUtc().subtract(const Duration(days: 9)),
          localHour: 20,
          localWeekday: 5,
          tzOffsetMinutes: 0,
        ).toJson(),
      ]),
    },
  );
  _render(
    'upgrade_nudge',
    () => _page(const Align(
      alignment: Alignment.topCenter,
      child: UpgradeNudgeBanner(),
    )),
    prefs: (_) => {'total_habits_completed': 12},
  );

  _render('profile', () => const ProfileScreen());
  _render(
    'profile_change_focus',
    () => const ProfileScreen(),
    then: (tester, l10n) async {
      // Two pencils: the name's, then the focus areas'.
      final pencil = find.byIcon(CupertinoIcons.pencil).at(1);
      await tester.ensureVisible(pencil);
      await _tap(tester, pencil);
    },
  );

  _render(
    'profile_focus_change',
    () => const ProfileScreen(),
    then: (tester, l10n) async {
      final pencil = find.byIcon(CupertinoIcons.pencil).at(1);
      await tester.ensureVisible(pencil);
      await _tap(tester, pencil);
      await _tap(tester, find.text(l10n.profileChangeAreas));
    },
  );

  _render('faq', () => const FaqScreen());
  // Each category page carries its title as a one-line heading.
  for (var i = 0; i < 8; i++) {
    _render(
      'faq_category_$i',
      () => const FaqScreen(),
      then: (tester, _) async {
        final cards = find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_CategoryCard',
        );
        await tester.ensureVisible(cards.at(i));
        await _tap(tester, cards.at(i));
      },
    );
  }
  _render('change_path', () => const ChangePathScreen());
  _render(
    'change_path_confirm',
    () => const ChangePathScreen(),
    then: (tester, l10n) async {
      final other = IntentionPath.getById(IntentionPathId.gentleMornings);
      await _tap(tester, find.text(other.title(l10n)));
      await _tap(tester, find.text(l10n.commonSave));
    },
  );
  _render('paywall', () => const PaywallScreen());
  _render(
    'subscription',
    () => const CupertinoPageScaffold(
      backgroundColor: Color(0xFFEAE4F2),
      child: Center(
        child: SubscriptionManagementModal(
          plan: 'Yearly',
          price: '€44.99',
          renewalDate: '1 Oct 2027',
        ),
      ),
    ),
  );

  _render('onb_welcome', () => const WelcomeV2Screen());
  _render(
    'onb_sign_in',
    () => const WelcomeV2Screen(),
    then: (tester, l10n) async {
      // The link only exists on the name step.
      await _tap(tester, find.text(l10n.onboardingLetsGetStarted));
      await _tap(tester, find.text(l10n.onboardingAlreadyHaveAccount));
    },
  );
  _render(
    'onb_philosophy',
    () => PhilosophyScreen(
      onContinue: () {},
      selectedAreas: const ['Health', 'Mood'],
    ),
  );
  _render('onb_intention_path', () => const IntentionPathScreen());
  _render('onb_tell_us', () => const TellUsAboutYouScreen());
  _render('onb_focus_areas', () => const FocusAreasScreen());
  // Two areas come chosen, which is the allowance: a third is refused, with
  // a dialog.
  _render(
    'onb_focus_limit',
    () => const FocusAreasScreen(),
    then: (tester, l10n) async {
      final third = find.text(localizeCategoryName('Relationships', l10n));
      await tester.ensureVisible(third);
      await _tap(tester, third);
    },
  );
  _render('onb_theme', () => const ThemeSelectionScreen());
  _render('onb_habit_reveal', () => const HabitRevealScreen());
  _render('onb_commitment', () => const CommitmentScreen());
  _render('onb_reminder', () => const DailyReminderScreen());
  _render('onb_paywall', () => const OnboardingPaywallScreen());

  _render('insights', () => const InsightsScreen());
  _render('year_in_seasons', () => const YearInSeasonsScreen());

  // The two pickers name no family at all: whatever they show is the app-wide
  // default.
  _render(
    'pickers',
    () => _page(
      SingleChildScrollView(
        child: ThemePicker(isPremium: false, onPremiumTap: () {}),
      ),
    ),
  );
  _render(
    'icon_picker',
    () => _page(
      Align(
        alignment: Alignment.topCenter,
        child: AppIconPicker(isPremium: false, onPremiumTap: () {}),
      ),
    ),
  );

  // The mark measures its target as it builds and bows out if there is nothing
  // to measure yet, so it arrives a frame after the page — as it does in the
  // app, where a service raises it once the screen is up.
  final target = GlobalKey();
  final raised = ValueNotifier(false);
  _render(
    'coach_mark',
    () {
      raised.value = false;
      return Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Stack(
            children: [
              _page(
                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(key: target, width: 200, height: 60),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: raised,
                builder: (_, show, __) => show
                    ? CoachMarkOverlay(
                        targetKey: target,
                        title: l10n.coachMarkWidgetTitle,
                        body: l10n.coachMarkWidgetBody,
                        onDismiss: () {},
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      );
    },
    then: (tester, _) async => raised.value = true,
  );

  _render(
    'boost_offer',
    () => Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return _page(
          Center(
            child: CupertinoButton(
              key: const Key('open'),
              onPressed: () => showBoostOfferSheet(
                context: context,
                title: l10n.profileChangeFocusTitle,
                description: l10n.profileChangeFocusMessage,
                source: 'render',
              ),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        );
      },
    ),
    then: (tester, _) => tester.tap(find.byKey(const Key('open'))),
  );
}
