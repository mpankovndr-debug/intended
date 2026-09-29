import 'package:flutter_test/flutter_test.dart';
import 'package:intended/l10n/app_localizations_en.dart';
import 'package:intended/l10n/app_localizations_ru.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/services/reflection_service.dart';
import 'package:intended/utils/habit_l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Finances stopped being a focus area. What a user already had — their saved
/// selection, the actions they were holding, the moments they recorded — is
/// storage that outlives the catalogue, so the migration is the part worth
/// pinning down.
Future<OnboardingState> _boot({
  required List<String> focusAreas,
  List<String> habits = const [],
  List<String> customs = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    'user_habits': habits,
    'custom_habits': customs,
    'focus_areas': focusAreas,
    'onboarding_complete': true,
  });
  final s = OnboardingState();
  await s.loadUserHabits();
  return s;
}

Future<List<String>?> _saved() async =>
    (await SharedPreferences.getInstance()).getStringList('focus_areas');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('focus_areas migration', () {
    test('a lone Finances becomes Home & organization', () async {
      final s = await _boot(focusAreas: ['Finances']);
      expect(s.focusAreas, ['Home & organization']);
      expect(await _saved(), ['Home & organization']);
    });

    test('Finances alongside another area keeps both, in place', () async {
      final s = await _boot(focusAreas: ['Finances', 'Health']);
      expect(s.focusAreas, ['Home & organization', 'Health']);
      expect(await _saved(), ['Home & organization', 'Health']);
    });

    test('the replacement already selected leaves one area, not a duplicate',
        () async {
      final s = await _boot(focusAreas: ['Finances', 'Home & organization']);
      expect(s.focusAreas, ['Home & organization']);
    });

    test('and the same when the order is reversed', () async {
      final s = await _boot(focusAreas: ['Home & organization', 'Finances']);
      expect(s.focusAreas, ['Home & organization']);
    });

    test('a saved Productivity becomes Self-care', () async {
      // Productivity was first *renamed* to Doing one thing, then that area
      // was removed outright. The alias must skip the dead middle step: a
      // replacement that is itself retired resolves to a category with no
      // hue, no legend chip and no swap pool.
      final s = await _boot(focusAreas: ['Productivity', 'Health']);
      expect(s.focusAreas, ['Self-care', 'Health']);
      expect(await _saved(), ['Self-care', 'Health']);
    });

    test('a saved Doing one thing becomes Self-care', () async {
      final s = await _boot(focusAreas: ['Doing one thing', 'Health']);
      expect(s.focusAreas, ['Self-care', 'Health']);
    });

    test('neither old area name is assignable', () async {
      for (final name in ['Productivity', 'Doing one thing']) {
        expect(OnboardingState.habitsByCategory.keys, isNot(contains(name)));
      }
    });

    test('a selection without Finances is left exactly as it was', () async {
      final s = await _boot(focusAreas: ['Health', 'Mood']);
      expect(s.focusAreas, ['Health', 'Mood']);
    });

    test('every migrated area still generates actions', () async {
      // The failure this prevents: `habitsByCategory[area] ?? []` returns
      // nothing for a category that no longer exists, so a user whose only
      // area was Finances would refresh into an empty home screen.
      final s = await _boot(focusAreas: ['Finances']);
      for (final area in s.focusAreas) {
        expect(OnboardingState.habitsByCategory[area], isNotEmpty,
            reason: '$area generates no actions');
      }
    });

    test('every replacement is a real focus area', () async {
      for (final replacement in OnboardingState.retiredFocusAreas.values) {
        expect(OnboardingState.habitsByCategory.keys, contains(replacement));
      }
    });
  });

  group('a held action from the retired area', () {
    const held = 'Set one small savings goal';

    test('stays in user_habits — a card in use is not removed', () async {
      final s = await _boot(focusAreas: ['Finances'], habits: [held]);
      expect(s.userHabits, contains(held));
      expect(s.visibleHabits(), contains(held));
    });

    test('resolves to a category, so it can still be swapped', () async {
      // Null here is the dead-end: `_handleSwap` shows "can't swap" and
      // returns, leaving the card unremovable except by a global refresh.
      final s = await _boot(focusAreas: ['Finances'], habits: [held]);
      expect(s.getCategoryForHabit(held), 'Home & organization');
      expect(s.getAlternativeHabits(held), isNotEmpty);
    });

    test('every retired action resolves to its declared area, never null',
        () async {
      final s = await _boot(focusAreas: ['Health']);
      for (final entry in OnboardingState.retiredHabitCategories.entries) {
        expect(s.getCategoryForHabit(entry.key), entry.value,
            reason: '${entry.key} resolves to nothing');
      }
    });

    test('every inheriting area is a real focus area', () {
      // The map is only useful if what it points at still exists: a
      // replacement that is itself retired resolves to a category with no
      // hue, no legend chip and no swap pool.
      for (final area in OnboardingState.retiredHabitCategories.values) {
        expect(OnboardingState.habitsByCategory.keys, contains(area));
      }
    });

    test('a new moment records the inheriting area, never null', () {
      // ReflectionService is what main.dart consults when writing a moment;
      // null would write a grey square with no legend chip.
      for (final entry in OnboardingState.retiredHabitCategories.entries) {
        expect(ReflectionService.categoryForHabit(entry.key), entry.value);
      }
    });
  });

  group('history is not rewritten', () {
    test('the Finances label still localizes for old moments', () {
      // The legend, the filter header, the widget and the season share card
      // all render a stored moment's own category string. Dropping the getter
      // would ship raw Latin "Finances" into an otherwise Russian screen —
      // and a Finances moment recorded in August 2026 is there forever.
      expect(localizeCategoryName('Finances', AppLocalizationsRu()), 'Финансы');
      expect(localizeCategoryName('Finances', AppLocalizationsEn()), 'Finances');
    });

    test('both the old and new area names localize', () {
      // A moment recorded before the rename carries category 'Productivity',
      // one recorded after it carries 'Doing one thing', and neither is ever
      // rewritten — so the legend, filter header, widget and season share card
      // must still resolve both. The area is no longer offered, but like
      // Finances it keeps its own label for the months it was lived in.
      for (final name in ['Productivity', 'Doing one thing']) {
        expect(localizeCategoryName(name, AppLocalizationsEn()),
            'Doing one thing');
        expect(localizeCategoryName(name, AppLocalizationsRu()), 'Одно дело');
      }
    });

    test('a retired action name no longer localizes, and falls through', () {
      // The twelve habit strings are gone from both ARBs. Nothing renders them
      // any more except a card someone is still holding, which shows the
      // stored English — acceptable, and the reason they stay resolvable as a
      // *category* above.
      expect(
        localizeHabitName('Set one small savings goal', AppLocalizationsRu()),
        'Set one small savings goal',
      );
    });
  });
}
