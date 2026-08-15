import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../state/user_state.dart';
import 'analytics_service.dart';

class RevenueCatService extends ChangeNotifier {
  static const _appleApiKey = 'appl_RPNUxXhvXrpnWAiTvMswDDrigtJ';
  static const entitlementPlus = 'Intended+';
  static const entitlementBoost = 'Intended Boost';
  // The Boost SKU (com.intendedapp.boost) is retired from sale; the
  // entitlement below is still honoured for everyone who bought it.

  final UserState _userState;

  bool _isPremium = false;
  bool _hasBoost = false;
  Offerings? _offerings;
  bool _isInitialized = false;

  RevenueCatService(this._userState);

  bool get isPremium => _isPremium;
  bool get hasBoost => _hasBoost;
  Offerings? get offerings => _offerings;

  // ---------------------------------------------------------------------------
  // Dynamic price strings (user's local currency from App Store)
  // ---------------------------------------------------------------------------

  String? get monthlyPriceString =>
      _findProduct('com.intendedapp.plus.monthly')?.priceString;
  String? get yearlyPriceString =>
      _findProduct('com.intendedapp.plus.yearly')?.priceString;
  String? get lifetimePriceString =>
      _findProduct('com.intendedapp.plus.lifetime')?.priceString;

  double? get _monthlyPrice =>
      _findProduct('com.intendedapp.plus.monthly')?.price;
  double? get _yearlyPrice =>
      _findProduct('com.intendedapp.plus.yearly')?.price;

  /// The yearly price expressed per month (e.g. "€3.75"), for anchoring the
  /// yearly plan against the monthly one. Derived from the live App Store
  /// price so it stays correct if pricing changes. Null until products load.
  String? get yearlyPerMonthString {
    final product = _findProduct('com.intendedapp.plus.yearly');
    final yearly = product?.price;
    if (product == null || yearly == null || yearly <= 0) return null;
    return NumberFormat.simpleCurrency(name: product.currencyCode)
        .format(yearly / 12);
  }

  /// Savings percentage for yearly vs 12×monthly (e.g. 40), or null.
  int? get yearlySavingsPercent {
    final m = _monthlyPrice;
    final y = _yearlyPrice;
    if (m == null || y == null || m <= 0) return null;
    return ((1.0 - y / (m * 12)) * 100).round();
  }

  // ---------------------------------------------------------------------------
  // Free-trial length (from the live App Store intro offer)
  // ---------------------------------------------------------------------------

  /// Shown only until the store answers, exactly like the `paywall*Price`
  /// strings in the ARB files. Mirrors the intro offer configured in App Store
  /// Connect — if you change the trial there, change this one line too.
  static const int defaultTrialDays = 7;

  /// The introductory period expressed in whole days.
  ///
  /// Returns null for month/year units on purpose: a calendar month is 28–31
  /// days, so a day count for one would be a number we can't stand behind.
  /// The app sells day- and week-based trials, where this is exact.
  @visibleForTesting
  static int? introPeriodInDays(PeriodUnit unit, int numberOfUnits) {
    if (numberOfUnits <= 0) return null;
    switch (unit) {
      case PeriodUnit.day:
        return numberOfUnits;
      case PeriodUnit.week:
        return numberOfUnits * 7;
      case PeriodUnit.month:
      case PeriodUnit.year:
      case PeriodUnit.unknown:
        return null;
    }
  }

  int? _trialDaysFor(String id) {
    final intro = _findProduct(id)?.introductoryPrice;
    if (intro == null) return null;
    return introPeriodInDays(intro.periodUnit, intro.periodNumberOfUnits);
  }

  int? get yearlyTrialDays => _trialDaysFor('com.intendedapp.plus.yearly');
  int? get monthlyTrialDays => _trialDaysFor('com.intendedapp.plus.monthly');

  /// Trial length to print in copy. Prefers the yearly plan (the hero), falls
  /// back to monthly, then to [defaultTrialDays] while products load.
  int get trialDays =>
      yearlyTrialDays ?? monthlyTrialDays ?? defaultTrialDays;

  /// Trial length for a specific plan, so the paywall's disclaimer matches the
  /// plan the user actually has selected.
  int trialDaysForPlan(String plan) =>
      (plan == 'monthly' ? monthlyTrialDays : yearlyTrialDays) ??
      defaultTrialDays;

  StoreProduct? _findProduct(String id) {
    for (final p in getPackages()) {
      if (p.storeProduct.identifier == id) return p.storeProduct;
    }
    return null;
  }

  /// Initialize RevenueCat SDK (iOS only for now).
  /// Pass [firebaseUid] to configure with the user's identity upfront,
  /// avoiding an anonymous→identified migration later.
  Future<void> init({String? firebaseUid}) async {
    if (_isInitialized) return;

    if (!Platform.isIOS && !Platform.isMacOS) {
      // Android support will be added later
      _isInitialized = true;
      return;
    }

    try {
      final configuration = PurchasesConfiguration(_appleApiKey);
      if (firebaseUid != null) {
        configuration.appUserID = firebaseUid;
      }
      await Purchases.configure(configuration);

      // Listen for customer info changes (e.g. subscription renewals, expirations)
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Check current entitlement status
      await refreshPurchaseStatus();

      // Don't pre-fetch offerings here — it triggers an App Store sign-in
      // dialog. Offerings will be loaded lazily when the paywall is shown.

      _isInitialized = true;
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
      _isInitialized = false;
      // App continues in free mode — purchases will be unavailable
      // Next app launch will retry
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _updatePremiumStatus(customerInfo);
  }

  void _updatePremiumStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[entitlementPlus];
    final boostEntitlement = customerInfo.entitlements.all[entitlementBoost];
    final wasPremium = _isPremium;
    final hadBoost = _hasBoost;
    _isPremium = entitlement?.isActive ?? false;
    _hasBoost = boostEntitlement?.isActive ?? false;

    if (wasPremium != _isPremium || hadBoost != _hasBoost) {
      _userState.setSubscription(_isPremium);
      _userState.setBoost(_hasBoost);
      final status = _isPremium ? 'premium' : _hasBoost ? 'boost' : 'free';
      AnalyticsService.setSubscriptionStatus(status);
      notifyListeners();
    }
  }

  /// Refresh purchase status from RevenueCat
  Future<void> refreshPurchaseStatus() async {
    if (!_isInitialized) return;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
    } catch (e) {
      debugPrint('RevenueCat: Failed to get customer info: $e');
    }
  }

  /// Load available offerings (lazy — only called when needed)
  Future<void> loadOfferings() async {
    if (_offerings != null) return;
    try {
      _offerings = await Purchases.getOfferings();
      notifyListeners();
    } catch (e) {
      debugPrint('RevenueCat: Failed to load offerings: $e');
    }
  }

  /// Ensure offerings are loaded before showing the paywall.
  Future<void> ensureOfferings() async {
    if (_offerings == null && _isInitialized) {
      await loadOfferings();
    }
  }

  /// Get the default offering's available packages
  List<Package> getPackages() {
    return _offerings?.current?.availablePackages ?? [];
  }

  /// Find a specific package by product identifier
  Package? getPackageByProductId(String productId) {
    final packages = getPackages();
    try {
      return packages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Purchase a specific package
  /// Returns true if purchase succeeded, false otherwise.
  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _updatePremiumStatus(result.customerInfo);
      return _isPremium;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled — not an error
        return false;
      }
      debugPrint('RevenueCat: Purchase error: $e');
      rethrow;
    }
  }

  /// Purchase the Intended Boost (one-time, non-consumable).
  /// Returns true if the boost entitlement is active after purchase.

  /// Purchase by plan name (monthly, yearly, lifetime)
  /// Maps plan names to RevenueCat product IDs.
  Future<bool> purchasePlan(String plan) async {
    final productId = switch (plan) {
      'monthly' => 'com.intendedapp.plus.monthly',
      'yearly' => 'com.intendedapp.plus.yearly',
      'lifetime' => 'com.intendedapp.plus.lifetime',
      _ => throw ArgumentError('Unknown plan: $plan'),
    };

    final package = getPackageByProductId(productId);
    if (package == null) {
      debugPrint('RevenueCat: Package not found for $productId');
      return false;
    }

    return purchasePackage(package);
  }

  /// Log in to RevenueCat with a user identifier (Firebase UID).
  /// RevenueCat handles identity switching and merges anonymous purchases
  /// automatically, so no manual logOut is needed before logIn.
  /// Also restores purchases to catch Apple ID entitlements on new devices.
  Future<void> logIn(String userId) async {
    if (!_isInitialized) return;
    try {
      final result = await Purchases.logIn(userId);
      _updatePremiumStatus(result.customerInfo);

      // Restore purchases to pick up Apple ID entitlements that RevenueCat
      // may not yet have associated with this user (e.g. new device).
      await restorePurchases();
    } catch (e) {
      debugPrint('RevenueCat: logIn failed: $e');
    }
  }

  /// Log out from RevenueCat (revert to anonymous user)
  Future<void> logOut() async {
    if (!_isInitialized) return;
    try {
      final customerInfo = await Purchases.logOut();
      _updatePremiumStatus(customerInfo);
    } catch (e) {
      debugPrint('RevenueCat: logOut failed: $e');
    }
  }

  /// Restore purchases
  /// Returns true if user has active premium or boost after restore.
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatus(customerInfo);
      return _isPremium || _hasBoost;
    } catch (e) {
      debugPrint('RevenueCat: Restore failed: $e');
      rethrow;
    }
  }
}
