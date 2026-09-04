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
      // copy makes no numeric claim instead.
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

      expect(l.paywallTimelineRenewsYearly(14, '€44.99'),
          'Day 14 — €44.99/year, renews automatically unless you cancel.');
      expect(l.paywallTimelineRenewsMonthly(7, '€5.99'),
          'Day 7 — €5.99/month, renews automatically unless you cancel.');
    });

    test('singular does not read "1 days"', () {
      expect(
        l.themeSelectionPremiumHint(1),
        contains('Try it free for 1 day after setup'),
      );
    });

    test('the trial timeline prints the store\'s own zero price', () {
      // The "Today" line takes the intro offer's formatted price verbatim —
      // whatever currency and format the store used for the plan itself.
      expect(l.paywallTimelineToday(r'$0.00'),
          r'Today — $0.00. Full access, nothing charged.');
      expect(l.paywallTimelineToday('0,00 €'), startsWith('Today — 0,00 €.'));
      expect(l.paywallTimelineCancel, 'Cancel anytime in Settings.');
    });

    test('the no-trial onboarding disclaimer still carries the per-month figure',
        () {
      expect(
        l.onboardingPaywallDisclaimerNoTrial('€44.99', '€3.75'),
        '€44.99/year — about €3.75 a month. Renews automatically until you cancel.',
      );
    });
  });

  group('Russian trial copy declines correctly', () {
    final l = AppLocalizationsRu();

    test('the timeline names the day, so no plural is needed', () {
      expect(l.paywallTimelineRenewsYearly(14, '€44,99'),
          'День 14 — €44,99 в год, продлевается автоматически, если не отменишь.');
      expect(l.paywallTimelineRenewsYearly(1, 'X'), startsWith('День 1 —'));
      expect(l.paywallTimelineToday('0,00 €'),
          'Сегодня — 0,00 €. Полный доступ, ничего не списывается.');
    });

    test('the billing period is a Russian phrase, never a slashed adverb', () {
      // The bug this replaces: the screen composed the price by gluing it to
      // the lowercased plan label, so Russian read «€44,99/ежегодно» — an
      // adverb where a period belongs, which no native reader can parse.
      expect(
          l.paywallTimelineRenewsYearly(14, '€44,99'), contains('€44,99 в год'));
      expect(l.paywallTimelineRenewsMonthly(14, '€5,99'),
          contains('€5,99 в месяц'));

      for (final text in [
        l.paywallTimelineRenewsYearly(14, '€44,99'),
        l.paywallTimelineRenewsMonthly(14, '€5,99'),
      ]) {
        expect(text, isNot(contains('ежегодно')));
        expect(text, isNot(contains('ежемесячно')));
        expect(text, isNot(contains('/')));
      }
    });

    test('the CTA adjective is invariant across lengths', () {
      expect(l.paywallCtaTrial(7), 'Начать 7-дневный пробный период');
      expect(l.paywallCtaTrial(14), 'Начать 14-дневный пробный период');
    });

    test('the no-trial disclaimer takes a localised per-month figure', () {
      expect(
        l.onboardingPaywallDisclaimerNoTrial('€44,99', '€3,75'),
        allOf(startsWith('€44,99 в год'), contains('около €3,75')),
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

    test('names a trial without measuring it until the store confirms', () {
      expect(
        AppLocalizationsEn().faqPricingAnswerUnspecified('€5.99', '€44.99', '€49.99'),
        endsWith('Both subscriptions start with a free trial.'),
      );
      expect(
        AppLocalizationsRu().faqPricingAnswerUnspecified('€5,99', '€44,99', '€49,99'),
        endsWith('с бесплатного пробного периода.'),
      );
      for (final text in [
        AppLocalizationsEn().faqPricingAnswerUnspecified('a', 'b', 'c'),
        AppLocalizationsRu().faqPricingAnswerUnspecified('a', 'b', 'c'),
        AppLocalizationsEn().faqPricingAnswerNoTrial('a', 'b', 'c'),
        AppLocalizationsRu().faqPricingAnswerNoTrial('a', 'b', 'c'),
        AppLocalizationsEn().themeSelectionPremiumHintUnspecified,
        AppLocalizationsRu().themeSelectionPremiumHintUnspecified,
        AppLocalizationsEn().themeSelectionPremiumHintNoTrial,
        AppLocalizationsRu().themeSelectionPremiumHintNoTrial,
      ]) {
        expect(text, isNot(matches(RegExp(r'\d'))), reason: text);
      }
    });

    test('says nothing about a trial once the store has said there is none',
        () {
      for (final text in [
        AppLocalizationsEn().faqPricingAnswerNoTrial('a', 'b', 'c'),
        AppLocalizationsEn().themeSelectionPremiumHintNoTrial,
      ]) {
        expect(text.toLowerCase(), isNot(contains('trial')));
        expect(text.toLowerCase(), isNot(contains('free')));
      }
      for (final text in [
        AppLocalizationsRu().faqPricingAnswerNoTrial('a', 'b', 'c'),
        AppLocalizationsRu().themeSelectionPremiumHintNoTrial,
      ]) {
        expect(text, isNot(contains('пробн')));
        expect(text, isNot(contains('бесплатн')));
      }
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

  group('price + period is a phrase, on every surface that prints one', () {
    // Profile → Manage subscription built this the same broken way the paywall
    // did, so a Russian subscriber read «€44,99/ежегодно» there too.
    test('English', () {
      final l = AppLocalizationsEn();
      expect(l.paywallPricePerYear('€44.99'), '€44.99/year');
      expect(l.paywallPricePerMonth('€5.99'), '€5.99/month');
    });

    test('Russian takes a preposition, not a slashed adverb', () {
      final l = AppLocalizationsRu();
      expect(l.paywallPricePerYear('€44,99'), '€44,99 в год');
      expect(l.paywallPricePerMonth('€5,99'), '€5,99 в месяц');
    });
  });

  group('every purchase surface discloses auto-renewal', () {
    // App Store guideline 3.1.2 wants the renewal terms in the binary, not
    // only in the store listing. "Cancel anytime" implies it; it does not say
    // it. Both paywalls — onboarding and main — have to carry the sentence,
    // with and without a trial.
    test('English', () {
      final l = AppLocalizationsEn();
      for (final text in [
        l.paywallHintYearlyNoTrial('€44.99'),
        l.paywallHintMonthlyNoTrial('€5.99'),
        l.onboardingPaywallDisclaimerNoTrial('€44.99', '€3.75'),
        l.paywallTimelineRenewsYearly(14, '€44.99'),
        l.paywallTimelineRenewsMonthly(14, '€5.99'),
      ]) {
        expect(text.toLowerCase(), contains('renews automatically'));
      }
    });

    test('Russian, in «ты»', () {
      final l = AppLocalizationsRu();
      for (final text in [
        l.paywallHintYearlyNoTrial('€44,99'),
        l.paywallHintMonthlyNoTrial('€5,99'),
        l.onboardingPaywallDisclaimerNoTrial('€44,99', '€3,75'),
        l.paywallTimelineRenewsYearly(14, '€44,99'),
        l.paywallTimelineRenewsMonthly(14, '€5,99'),
        l.paywallTimelineCancel,
      ]) {
        expect(text.toLowerCase(), contains('отмен'));
        expect(text, isNot(contains('отмените')));
      }
      for (final text in [
        l.paywallHintYearlyNoTrial('€44,99'),
        l.paywallHintMonthlyNoTrial('€5,99'),
        l.onboardingPaywallDisclaimerNoTrial('€44,99', '€3,75'),
        l.paywallTimelineRenewsYearly(14, '€44,99'),
        l.paywallTimelineRenewsMonthly(14, '€5,99'),
      ]) {
        expect(text.toLowerCase(), contains('продлевается автоматически'));
      }
    });
  });

  group('freeTrialPriceString', () {
    IntroductoryPrice intro(double price, String priceString) => IntroductoryPrice(
        price, priceString, 'P2W', 1, PeriodUnit.week, 2);

    test('is the store\'s own string for a free intro offer', () {
      expect(RevenueCatService.freeTrialPriceString(intro(0, r'$0.00')),
          r'$0.00');
      expect(RevenueCatService.freeTrialPriceString(intro(0, '0,00 €')),
          '0,00 €');
    });

    test('is null wherever freeTrialDays is null, so the two only print together',
        () {
      expect(RevenueCatService.freeTrialPriceString(null), isNull);
      // A discounted first period is not a trial.
      expect(RevenueCatService.freeTrialPriceString(intro(1.99, r'$1.99')),
          isNull);
      // A month-long offer has no printable day count.
      expect(
        RevenueCatService.freeTrialPriceString(
            const IntroductoryPrice(0, r'$0.00', 'P1M', 1, PeriodUnit.month, 1)),
        isNull,
      );
    });

    test('an empty price string renders nothing rather than "Today — ."', () {
      expect(RevenueCatService.freeTrialPriceString(intro(0, '')), isNull);
    });
  });

  group('trial claims outside the paywalls', () {
    // There is no typed-in trial length anywhere any more. Before the store
    // answers a surface may say "free trial"; after it answers, it says the
    // store's number or nothing.
    test('a confirmed length is printed whatever the status', () {
      for (final status in OfferingsStatus.values) {
        expect(
          RevenueCatService.resolveTrialClaim(status: status, days: 14),
          TrialClaim.days,
          reason: status.name,
        );
      }
    });

    test('an unknown length is unspecified until the store has loaded', () {
      for (final status in [
        OfferingsStatus.pending,
        OfferingsStatus.loading,
        OfferingsStatus.failed,
      ]) {
        expect(
          RevenueCatService.resolveTrialClaim(status: status, days: null),
          TrialClaim.unspecified,
          reason: status.name,
        );
      }
      expect(
        RevenueCatService.resolveTrialClaim(
            status: OfferingsStatus.loaded, days: null),
        TrialClaim.none,
      );
    });

    test('"both subscriptions" only gets a number both plans share', () {
      expect(RevenueCatService.sharedTrialDays(14, 14), 14);
      expect(RevenueCatService.sharedTrialDays(14, 7), isNull);
      expect(RevenueCatService.sharedTrialDays(14, null), isNull);
      expect(RevenueCatService.sharedTrialDays(null, 14), isNull);
      expect(RevenueCatService.sharedTrialDays(null, null), isNull);
    });
  });
}
