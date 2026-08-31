import 'package:flutter_test/flutter_test.dart';
import 'package:intended/onboarding_v2/onboarding_state.dart';
import 'package:intended/utils/habit_l10n.dart';

/// The guard that was missing.
///
/// `localizeHabitName` returns the raw English name for anything it does not
/// know. That fallback has to exist — it is what protects a habit someone
/// typed themselves, and what keeps an old saved moment readable after its
/// habit leaves the catalog. But it cannot tell "the user's own words" from
/// "we forgot this one", so a missing translation and a working one are
/// identical to every other check: analyze sees a valid map lookup, gen-l10n
/// sees no absent ARB key, and nothing fails.
///
/// Sixteen live habits and twenty-eight retired ones rendered in English to
/// Russian readers from February to August because of that silence. It took
/// someone looking at a screenshot to notice.
void main() {
  group('every habit the app can show is translatable', () {
    test('the live catalog is fully covered', () {
      final live = <String>{
        for (final habits in OnboardingState.habitsByCategory.values) ...habits,
      };
      final missing = live.difference(localisedHabitNames).toList()..sort();
      expect(
        missing,
        isEmpty,
        reason: 'These are offered to users today and would render in raw '
            'English for every non-English locale:\n  ${missing.join("\n  ")}',
      );
    });

    test('retired habits stay translatable for whoever still holds one', () {
      // Retiring a habit removes it from the pool, not from the phones of
      // people who already chose it. Their card still renders every day.
      final retired = OnboardingState.retiredHabitCategories.keys.toSet();
      final missing = retired.difference(localisedHabitNames).toList()..sort();
      expect(
        missing,
        isEmpty,
        reason: 'Still on existing users\' home screens, untranslated:\n  '
            '${missing.join("\n  ")}',
      );
    });
  });
}
