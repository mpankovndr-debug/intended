import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:intended/services/analytics_service.dart';

/// purchase_failed used to be a bare count. These pin the two parameters it
/// now carries — `error_code` as the PurchasesErrorCode name and
/// `error_message` as the StoreKit text cut to GA4's limit — and the rule
/// behind the `is_tester` property, so a dashboard filter on either can only
/// say what the SDK and the build mode said.
void main() {
  // The plugin rejects every store failure as a PlatformException whose
  // code is the PurchasesErrorCode index as a string, with the StoreKit
  // text under details['underlyingErrorMessage'].
  PlatformException storeError(
    PurchasesErrorCode code, {
    String? message,
    Object? details,
  }) =>
      PlatformException(
        code: code.index.toString(),
        message: message,
        details: details,
      );

  group('purchaseErrorParams', () {
    test('names the RevenueCat error code', () {
      for (final code in [
        PurchasesErrorCode.purchaseNotAllowedError,
        PurchasesErrorCode.storeProblemError,
        PurchasesErrorCode.paymentPendingError,
        PurchasesErrorCode.networkError,
      ]) {
        final params = AnalyticsService.purchaseErrorParams(
          storeError(code, message: 'x'),
        );
        expect(params['error_code'], code.name, reason: code.name);
      }
    });

    test('prefers the StoreKit message over the RevenueCat one', () {
      final params = AnalyticsService.purchaseErrorParams(
        storeError(
          PurchasesErrorCode.storeProblemError,
          message: 'There was a problem with the App Store.',
          details: {
            'underlyingErrorMessage': 'Cannot connect to iTunes Store',
          },
        ),
      );
      expect(params['error_message'], 'Cannot connect to iTunes Store');
    });

    test('falls back to the RevenueCat message, then the raw code', () {
      final withMessage = AnalyticsService.purchaseErrorParams(
        storeError(
          PurchasesErrorCode.purchaseNotAllowedError,
          message: 'The device or user is not allowed to make the purchase.',
          details: {'underlyingErrorMessage': ''},
        ),
      );
      expect(
        withMessage['error_message'],
        'The device or user is not allowed to make the purchase.',
      );

      final bare = AnalyticsService.purchaseErrorParams(
        storeError(PurchasesErrorCode.paymentPendingError),
      );
      expect(
        bare['error_message'],
        PurchasesErrorCode.paymentPendingError.index.toString(),
      );
    });

    test('cuts the message to 100 characters', () {
      final long = 'x' * 250;
      final params = AnalyticsService.purchaseErrorParams(
        storeError(PurchasesErrorCode.storeProblemError, message: long),
      );
      expect((params['error_message'] as String).length, 100);
      expect(params['error_message'], 'x' * 100);

      final exact = AnalyticsService.purchaseErrorParams(
        storeError(PurchasesErrorCode.storeProblemError, message: 'y' * 100),
      );
      expect(exact['error_message'], 'y' * 100);
    });

    test('a code the helper cannot map is unknownError', () {
      for (final code in ['not-a-number', '9999', '-1']) {
        final params = AnalyticsService.purchaseErrorParams(
          PlatformException(code: code, message: 'm'),
        );
        expect(params['error_code'], 'unknownError', reason: code);
        expect(params['error_message'], 'm');
      }
    });

    test('a non-store exception is unknownError with its text', () {
      final params = AnalyticsService.purchaseErrorParams(
        StateError('offerings vanished'),
      );
      expect(params['error_code'], 'unknownError');
      expect(params['error_message'], 'Bad state: offerings vanished');
    });

    test('no error at all reads none for both', () {
      expect(
        AnalyticsService.purchaseErrorParams(null),
        {'error_code': 'none', 'error_message': 'none'},
      );
    });

    test('always carries exactly the two registered parameter names', () {
      for (final error in [
        null,
        storeError(PurchasesErrorCode.storeProblemError),
        ArgumentError('x'),
      ]) {
        expect(
          AnalyticsService.purchaseErrorParams(error).keys.toSet(),
          {'error_code', 'error_message'},
        );
      }
    });
  });

  group('resolveTester', () {
    test('a debug build is always a tester', () {
      expect(AnalyticsService.resolveTester(debug: true, stored: null), isTrue);
      expect(
        AnalyticsService.resolveTester(debug: true, stored: false),
        isTrue,
      );
    });

    test('a release build honours the stored toggle', () {
      expect(
        AnalyticsService.resolveTester(debug: false, stored: null),
        isFalse,
      );
      expect(
        AnalyticsService.resolveTester(debug: false, stored: false),
        isFalse,
      );
      expect(
        AnalyticsService.resolveTester(debug: false, stored: true),
        isTrue,
      );
    });
  });
}
