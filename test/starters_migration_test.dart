import 'package:flutter_test/flutter_test.dart';
import 'package:intended/models/intention_path.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Four paths gained starter actions in September 2026. Someone already
/// living one of them has their actions; a later focus-area change must
/// bring actions from the areas they chose, not the path's starters.
void main() {
  final windingDown = IntentionPath.getById(IntentionPathId.windingDown);

  Future<OnboardingState> load(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final state = OnboardingState();
    await state.loadUserHabits();
    await state.loadSelectedIntentionPath();
    return state;
  }

  test('an existing user changing focus gets the areas they chose', () async {
    final state = await load({
      'onboarding_complete': true,
      'selected_intention_path': windingDown.id.key,
      'focus_areas': ['Health', 'Mood'],
      'user_habits': ['Drink a glass of water', 'Take 3 slow breaths'],
    });
    await state.changeFocusAreas(['Relationships']);
    final pool = OnboardingState.habitsByCategory['Relationships']!;
    expect(state.userHabits, isNotEmpty);
    expect(state.userHabits.every(pool.contains), isTrue,
        reason: '${state.userHabits}');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('starters_applied_for_path'), windingDown.id.key);
  });

  test('someone new still starts from the path\'s own actions', () async {
    final state = await load({
      'selected_intention_path': windingDown.id.key,
      'focus_areas': ['Health', 'Mood'],
    });
    await state.generateUserHabits();
    expect(state.userHabits, windingDown.starterActions);
  });

  test('a later change of path still seeds that path once', () async {
    final state = await load({
      'onboarding_complete': true,
      'selected_intention_path': windingDown.id.key,
      'focus_areas': ['Health', 'Mood'],
      'user_habits': ['Drink a glass of water'],
    });
    final mornings = IntentionPath.getById(IntentionPathId.gentleMornings);
    await state.setSelectedIntentionPath(mornings.id.key);
    await state.generateUserHabits();
    expect(state.userHabits, mornings.starterActions);
  });
}
