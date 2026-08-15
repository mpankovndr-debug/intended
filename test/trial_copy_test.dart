import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:intended/l10n/app_localizations_en.dart';
import 'package:intended/l10n/app_localizations_ru.dart';
import 'package:intended/services/revenue_cat_service.dart';

/// The trial length and the three prices used to be typed into the ARB files.
/// They drifted: the FAQ shipped €6.99 / €49.99 / €89.99 against a real
/// €5.99 / €44.99 / €49.99, and every trial string said "7 days" regardless of
/// what App Store Connect was actually selling. These tests pin the derivation
/// so the copy can only ever say what the store says.
void main() {
  group('introPeriodInDays', () {
    test('day periods pass through', () {
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.day, 3), 3);
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.day, 14), 14);
    });

    test('week periods convert — this is how Apple returns 7 and 14 days', () {
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.week, 1), 7);
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.week, 2), 14);
    });

    test('month and year return null rather than a number we can not defend',
        () {
      // A calendar month is 28–31 days. Printing "30 days free" for a 1-month
      // intro offer would be a sentence the app cannot stand behind, so the
      // copy falls back to defaultTrialDays instead.
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.month, 1), isNull);
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.year, 1), isNull);
      expect(
          RevenueCatService.introPeriodInDays(PeriodUnit.unknown, 7), isNull);
    });

    test('non-positive unit counts are rejected', () {
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.day, 0), isNull);
      expect(RevenueCatService.introPeriodInDays(PeriodUnit.week, -1), isNull);
    });
  });

  group('English trial copy carries the real length', () {
    final l = AppLocalizationsEn();

    test('CTA and hints render 14 as readily as 7', () {
      expect(l.paywallCtaTrial(7), 'Start 7-day free trial');
      expect(l.paywallCtaTrial(14), 'Start 14-day free trial');

      expect(l.paywallTrialHint(14, '€44.99/yearly'),
          '14 days free, then €44.99/yearly. Cancel anytime.');
    });

    test('singular does not read "1 days"', () {
      expect(l.paywallTrialHint(1, '€5.99/monthly'),
          '1 day free, then €5.99/monthly. Cancel anytime.');
      expect(
        l.themeSelectionPremiumHint(1),
        contains('Try it free for 1 day after setup'),
      );
    });

    test('the onboarding disclaimer no longer hardcodes €3.75', () {
      final text = l.onboardingPaywallDisclaimer(14, '€44.99', '€3.75');
      expect(text,
          '14 days free, then €44.99/year — about €3.75 a month. Cancel anytime.');

      // A different currency must survive end to end.
      expect(
        l.onboardingPaywallDisclaimer(7, r'$49.99', r'$4.17'),
        contains(r'about $4.17 a month'),
      );
    });
  });

  group('Russian trial copy declines correctly', () {
    final l = AppLocalizationsRu();

    test('one / few / many forms', () {
      expect(l.paywallTrialHint(1, 'X'), startsWith('1 день'));
      expect(l.paywallTrialHint(3, 'X'), startsWith('3 дня'));
      expect(l.paywallTrialHint(7, 'X'), startsWith('7 дней'));
      expect(l.paywallTrialHint(14, 'X'), startsWith('14 дней'));
      expect(l.paywallTrialHint(21, 'X'), startsWith('21 день'));
    });

    test('the CTA adjective is invariant across lengths', () {
      expect(l.paywallCtaTrial(7), 'Начать 7-дневный пробный период');
      expect(l.paywallCtaTrial(14), 'Начать 14-дневный пробный период');
    });

    test('disclaimer takes a localised per-month figure', () {
      expect(
        l.onboardingPaywallDisclaimer(14, '€44,99', '€3,75'),
        allOf(startsWith('14 дней бесплатно'), contains('около €3,75')),
      );
    });
  });

  group('FAQ pricing answer quotes live figures', () {
    test('English', () {
      expect(
        AppLocalizationsEn()
            .faqPricingAnswer('€5.99', '€44.99', '€49.99', 14),
        'Monthly: €5.99. Yearly: €44.99. Lifetime: €49.99, one-time. '
        'Both subscriptions start with a 14-day free trial.',
      );
    });

    test('Russian', () {
      expect(
        AppLocalizationsRu()
            .faqPricingAnswer('€5,99', '€44,99', '€49,99', 7),
        allOf(
          contains('Навсегда: €49,99, разовая покупка'),
          contains('7-дневного бесплатного периода'),
        ),
      );
    });

    test('no euro sign is baked into either answer', () {
      // The bug this replaces: the FAQ printed euros to every user on earth,
      // while the paywall beside it showed their own currency.
      for (final text in [
        AppLocalizationsEn().faqPricingAnswer(r'$5.99', r'$44.99', r'$49.99', 7),
        AppLocalizationsRu().faqPricingAnswer(r'$5,99', r'$44,99', r'$49,99', 7),
      ]) {
        expect(text, isNot(contains('€')));
      }
    });
  });

  test('defaultTrialDays matches what App Store Connect currently sells', () {
    // If you change the intro offer in ASC, change this constant to match.
    // It is only ever shown in the window before products resolve.
    expect(RevenueCatService.defaultTrialDays, 14);
  });
}
