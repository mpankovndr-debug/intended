import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:intended/services/revenue_cat_service.dart';

/// The purchase button used to fail silently: with no package to sell,
/// purchasePlan returned false and both paywalls logged that as a user
/// cancel. These pin the two pure decisions behind the fix — why a plan
/// can't be bought, and when a trial may be claimed — so the dashboard's
/// `reason` values and the copy's trial length can only say what the SDK
/// state says.
void main() {
  const yearly = 'com.intendedapp.plus.yearly';
  const monthly = 'com.intendedapp.plus.monthly';

  PurchaseUnavailableReason? reason({
    bool initialised = true,
    bool attempted = true,
    bool offeringsLoaded = true,
    bool hasCurrentOffering = true,
    Iterable<String> productIds = const [yearly, monthly],
    String productId = yearly,
  }) =>
      RevenueCatService.unavailableReason(
        initialised: initialised,
        attempted: attempted,
        offeringsLoaded: offeringsLoaded,
        hasCurrentOffering: hasCurrentOffering,
        productIds: productIds,
        productId: productId,
      );

  group('unavailableReason', () {
    test('a purchasable plan has no reason', () {
      expect(reason(), isNull);
      expect(reason(productId: monthly), isNull);
    });

    test('an SDK that never configured outranks everything else', () {
      // Even a loaded offering means nothing without a configured SDK:
      // purchasePackage would throw before reaching the store.
      expect(
        reason(initialised: false),
        PurchaseUnavailableReason.notInitialised,
      );
    });

    test('attempted and empty is a fetch that threw twice', () {
      expect(
        reason(offeringsLoaded: false, hasCurrentOffering: false),
        PurchaseUnavailableReason.fetchFailed,
      );
    });

    test('not yet attempted and empty is not blamed on the network', () {
      expect(
        reason(
          attempted: false,
          offeringsLoaded: false,
          hasCurrentOffering: false,
        ),
        PurchaseUnavailableReason.noOffering,
      );
    });

    test('loaded with nothing marked Current in the dashboard', () {
      expect(
        reason(hasCurrentOffering: false, productIds: const []),
        PurchaseUnavailableReason.noOffering,
      );
    });

    test("a current offering without this plan's product", () {
      expect(
        reason(productIds: const [monthly]),
        PurchaseUnavailableReason.noPackage,
      );
      expect(
        reason(productIds: const []),
        PurchaseUnavailableReason.noPackage,
      );
    });

    test('the reason words are the ones the dashboard filters on', () {
      expect(
        PurchaseUnavailableReason.values.map((r) => r.analyticsValue),
        ['not_initialised', 'fetch_failed', 'no_offering', 'no_package'],
      );
    });
  });

  group('freeTrialDays', () {
    IntroductoryPrice intro(double price, PeriodUnit unit, int units) =>
        IntroductoryPrice(price, '€$price', 'P', 1, unit, units);

    test('no intro offer means no trial claim', () {
      expect(RevenueCatService.freeTrialDays(null), isNull);
    });

    test('a discounted first period is not a free trial', () {
      expect(
        RevenueCatService.freeTrialDays(intro(1.99, PeriodUnit.week, 2)),
        isNull,
      );
    });

    test('a free two-week offer is fourteen days', () {
      expect(
        RevenueCatService.freeTrialDays(intro(0, PeriodUnit.week, 2)),
        14,
      );
      expect(
        RevenueCatService.freeTrialDays(intro(0, PeriodUnit.day, 7)),
        7,
      );
    });

    test('a free month is a trial we cannot count in days, so no claim', () {
      expect(
        RevenueCatService.freeTrialDays(intro(0, PeriodUnit.month, 1)),
        isNull,
      );
    });
  });
}
