import 'package:flutter_test/flutter_test.dart';

import 'package:intended/services/analytics_service.dart';

/// The name field on the Welcome screen is optional. `name_entry` must fire
/// whether or not a name was typed, and carry `name_provided` so the funnel
/// can tell the two apart. Every other step sends no such parameter.
void main() {
  group('onboardingStepParams', () {
    test('name_entry with a name reports name_provided true', () {
      final params = AnalyticsService.onboardingStepParams(
        'name_entry',
        nameProvided: true,
      );
      expect(params, {'step_name': 'name_entry', 'name_provided': 'true'});
    });

    test('name_entry without a name reports name_provided false', () {
      final params = AnalyticsService.onboardingStepParams(
        'name_entry',
        nameProvided: false,
      );
      expect(params, {'step_name': 'name_entry', 'name_provided': 'false'});
    });

    test('other steps carry only step_name', () {
      for (final step in [
        'tell_us_path',
        'tell_us_focus',
        'commitment',
        'daily_reminder',
        'habit_reveal',
      ]) {
        expect(
          AnalyticsService.onboardingStepParams(step),
          {'step_name': step},
          reason: step,
        );
      }
    });

    test('encodes the flag as a string, never a bool', () {
      // Firebase rejects bool parameter values; the service sends 'true'/'false'.
      final value = AnalyticsService.onboardingStepParams(
        'name_entry',
        nameProvided: true,
      )['name_provided'];
      expect(value, isA<String>());
    });
  });
}
