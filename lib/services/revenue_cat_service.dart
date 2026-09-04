import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../state/user_state.dart';
import 'analytics_service.dart';

/// Why a purchase can't start right now. [analyticsValue] is the `reason`
/// parameter of the `purchase_unavailable` event, so the dashboard can tell
/// a broken button from a user who closed the App Store sheet — the two
/// used to share the `purchase_cancelled` bucket.
enum PurchaseUnavailableReason {
  /// The SDK never configured: init failed, or the launch step that calls
  /// it never ran.
  notInitialised('not_initialised'),

  /// `getOfferings` threw twice in a row — network, StoreKit, or a bad key.
  fetchFailed('fetch_failed'),

  /// The store answered, but nothing is marked Current in the RevenueCat
  /// dashboard.
  noOffering('no_offering'),

  /// The current offering doesn't carry this plan's product.
  noPackage('no_package');

  const PurchaseUnavailableReason(this.analyticsValue);
  final String analyticsValue;
}

/// Where the offerings request stands. Paywalls paint a loading state for
/// [pending] and [loading], live prices for [loaded], and the retry row for
/// [failed]. A loaded offering can still lack a plan's package — ask
/// [RevenueCatService.unavailableReasonFor] about that.
enum OfferingsStatus { pending, loading, loaded, failed }

/// How a purchase attempt ended.
enum PurchaseOutcome {
  /// The entitlement is active.
  purchased,

  /// The user closed the App Store sheet.
  cancelled,

  /// There was no package to hand to the store;
  /// [RevenueCatService.unavailableReasonFor] says why.
  unavailable,

  /// The store returned without an error, yet the entitlement is not
  /// active — the product isn't attached to it in the RevenueCat dashboard.
  /// The user has been charged, so this is never a cancel.
  entitlementMissing,
}

class RevenueCatService extends ChangeNotifier {
  static const _appleApiKey = 'appl_RPNUxXhvXrpnWAiTvMswDDrigtJ';
  static const entitlementPlus = 'Intended+';
  static const entitlementBoost = 'Intended Boost';
  // The Boost SKU (com.intendedapp.boost) is retired from sale; the
  // entitlement below is still honoured for everyone who bought it.

  static const _productIds = {
    'monthly': 'com.intendedapp.plus.monthly',
    'yearly': 'com.intendedapp.plus.yearly',
    'lifetime': 'com.intendedapp.plus.lifetime',
  };

  /// Pause before the single retry of a failed offerings fetch.
  @visibleForTesting
  static const Duration offeringsRetryDelay = Duration(seconds: 1);

  final UserState _userState;

  bool _isPremium = false;
  bool _hasBoost = false;
  Offerings? _offerings;
  bool _isInitialized = false;
  bool _listenerAttached = false;
  String? _firebaseUid;
  Future<void>? _initInFlight;
  Future<void>? _offeringsInFlight;

  /// True once a load has run to completion this session, loaded or not.
  /// Separates "the fetch failed" from "nobody asked yet".
  bool _offeringsAttempted = false;

  /// The exception behind the current unavailable reason, if any: the last
  /// failed `configure` or `getOfferings` call. Cleared when either
  /// succeeds. Rides along on `purchase_unavailable` as error_code /
  /// error_message.
  Object? _lastUnavailableError;

  RevenueCatService(this._userState);

  bool get isPremium => _isPremium;
  bool get hasBoost => _hasBoost;
  Offerings? get offerings => _offerings;
  bool get isInitialized => _isInitialized;
  Object? get lastUnavailableError => _lastUnavailableError;

  OfferingsStatus get offeringsStatus {
    if (_offeringsInFlight != null || _initInFlight != null) {
      return OfferingsStatus.loading;
    }
    if (_offerings != null) return OfferingsStatus.loaded;
    return _offeringsAttempted
        ? OfferingsStatus.failed
        : OfferingsStatus.pending;
  }

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

  /// Shown by the FAQ and the theme hint until the store answers. Mirrors the
  /// intro offer configured in App Store Connect — if you change the trial
  /// there, change this one line too. The paywalls never use it: a trial
  /// length the store hasn't confirmed is a claim, and they make none.
  static const int defaultTrialDays = 14;

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

  /// Days of free trial in [intro], or null when there is no intro offer,
  /// the offer isn't free (a discounted first period is not a trial), or its
  /// length isn't a whole number of days we can print.
  @visibleForTesting
  static int? freeTrialDays(IntroductoryPrice? intro) {
    if (intro == null || intro.price > 0) return null;
    return introPeriodInDays(intro.periodUnit, intro.periodNumberOfUnits);
  }

  /// Free-trial length for [plan] from the live store product, or null —
  /// and null means the paywall makes no trial claim at all. Never falls
  /// back to [defaultTrialDays]: before the store answers there is nothing
  /// to claim, and after it answers a missing offer *is* the answer.
  int? freeTrialDaysForPlan(String plan) =>
      freeTrialDays(_findProduct(_productIdFor(plan))?.introductoryPrice);

  int? _trialDaysFor(String id) {
    final intro = _findProduct(id)?.introductoryPrice;
    if (intro == null) return null;
    return introPeriodInDays(intro.periodUnit, intro.periodNumberOfUnits);
  }

  int? get yearlyTrialDays => _trialDaysFor('com.intendedapp.plus.yearly');
  int? get monthlyTrialDays => _trialDaysFor('com.intendedapp.plus.monthly');

  /// Trial length to print in copy that has to say *something* before the
  /// store answers (the FAQ, the theme hint). Prefers the yearly plan (the
  /// hero), falls back to monthly, then to [defaultTrialDays]. Not for
  /// paywalls — see [freeTrialDaysForPlan].
  int get trialDays =>
      yearlyTrialDays ?? monthlyTrialDays ?? defaultTrialDays;

  StoreProduct? _findProduct(String id) {
    for (final p in getPackages()) {
      if (p.storeProduct.identifier == id) return p.storeProduct;
    }
    return null;
  }

  static String _productIdFor(String plan) =>
      _productIds[plan] ?? (throw ArgumentError('Unknown plan: $plan'));

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Initialize RevenueCat SDK (iOS only for now).
  /// Pass [firebaseUid] to configure with the user's identity upfront,
  /// avoiding an anonymous→identified migration later.
  ///
  /// Safe to call again after a failure — [ensureOfferings] does, from the
  /// paywall — and a call that overlaps an in-flight one just joins it.
  Future<void> init({String? firebaseUid}) {
    if (firebaseUid != null) _firebaseUid = firebaseUid;
    if (_isInitialized) return Future.value();
    final inFlight = _initInFlight;
    if (inFlight != null) return inFlight;
    final run = _configure();
    _initInFlight = run;
    return run.whenComplete(() => _initInFlight = null);
  }

  Future<void> _configure() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      // Android support will be added later
      _isInitialized = true;
      return;
    }

    try {
      final configuration = PurchasesConfiguration(_appleApiKey);
      if (_firebaseUid != null) {
        configuration.appUserID = _firebaseUid;
      }
      await Purchases.configure(configuration);

      // Listen for customer info changes (e.g. subscription renewals,
      // expirations). Once: a re-init after a failure must not stack a
      // second copy of the listener.
      if (!_listenerAttached) {
        Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
        _listenerAttached = true;
      }

      // Configured is what "initialised" means, and refreshPurchaseStatus
      // guards on it — so the flag comes first. It used to be set last,
      // which made the entitlement read below a silent no-op on every
      // launch; the status only ever arrived through the listener.
      _isInitialized = true;
      _lastUnavailableError = null;
      await refreshPurchaseStatus();

      // Don't pre-fetch offerings here — they load lazily when a paywall is
      // shown, which is also where a failure has somewhere to be reported.
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
      _isInitialized = false;
      _lastUnavailableError = e;
      // App continues in free mode — purchases will be unavailable until a
      // paywall retries the configuration.
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

  // ---------------------------------------------------------------------------
  // Offerings
  // ---------------------------------------------------------------------------

  /// Makes sure offerings are loaded before a paywall paints a price —
  /// configuring the SDK first if launch never managed to — and reports why
  /// [plan] still can't be bought, if it can't. A failed fetch is retried
  /// once. Whatever reason remains is logged as `purchase_unavailable`
  /// (stage `load`), so a paywall that opened broken is counted even when
  /// nobody taps it. Returns null when [plan] is purchasable.
  Future<PurchaseUnavailableReason?> ensureOfferings({
    String plan = 'yearly',
  }) async {
    if (!_isInitialized || _offerings == null) {
      if (!_isInitialized) {
        // Launch configures the SDK after the first frame. If that step
        // never ran — an earlier startup await threw — this is the retry.
        final initRun = init();
        notifyListeners();
        await initRun;
      }
      if (_isInitialized && _offerings == null) {
        await _loadOfferings();
      }
      _offeringsAttempted = true;
      notifyListeners();
    }
    final reason = unavailableReasonFor(plan);
    if (reason != null) {
      AnalyticsService.logPurchaseUnavailable(
        reason.analyticsValue,
        stage: 'load',
        error: _lastUnavailableError,
      );
    }
    return reason;
  }

  /// The paywall's retry button. Drops whatever was loaded so a fetch
  /// actually happens, then runs the same path as [ensureOfferings].
  Future<PurchaseUnavailableReason?> retryOfferings({String plan = 'yearly'}) {
    _offerings = null;
    _offeringsAttempted = false;
    return ensureOfferings(plan: plan);
  }

  Future<void> _loadOfferings() {
    final inFlight = _offeringsInFlight;
    if (inFlight != null) return inFlight;
    final run = _fetchOfferings();
    _offeringsInFlight = run;
    notifyListeners();
    return run.whenComplete(() {
      _offeringsInFlight = null;
      notifyListeners();
    });
  }

  /// One fetch, one retry. Both failures stay quiet here; the caller turns
  /// the empty result into a reason.
  Future<void> _fetchOfferings() async {
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        _offerings = await Purchases.getOfferings();
        _lastUnavailableError = null;
        return;
      } catch (e) {
        debugPrint('RevenueCat: offerings fetch $attempt failed: $e');
        _lastUnavailableError = e;
        if (attempt == 1) await Future.delayed(offeringsRetryDelay);
      }
    }
  }

  /// Why [plan] can't be bought right now, or null when it can.
  PurchaseUnavailableReason? unavailableReasonFor(String plan) {
    final current = _offerings?.current;
    return unavailableReason(
      initialised: _isInitialized,
      attempted: _offeringsAttempted,
      offeringsLoaded: _offerings != null,
      hasCurrentOffering: current != null,
      productIds: (current?.availablePackages ?? const <Package>[])
          .map((p) => p.storeProduct.identifier),
      productId: _productIdFor(plan),
    );
  }

  /// The decision behind [unavailableReasonFor], with no SDK state in it so
  /// it can be tested as a truth table.
  @visibleForTesting
  static PurchaseUnavailableReason? unavailableReason({
    required bool initialised,
    required bool attempted,
    required bool offeringsLoaded,
    required bool hasCurrentOffering,
    required Iterable<String> productIds,
    required String productId,
  }) {
    if (!initialised) return PurchaseUnavailableReason.notInitialised;
    if (!offeringsLoaded) {
      // Attempted and empty means the fetch threw twice. Not yet attempted
      // is a tap that beat the load — the disabled button makes that all
      // but impossible — and it gets "no offering" rather than a blame on
      // the network that never got asked.
      return attempted
          ? PurchaseUnavailableReason.fetchFailed
          : PurchaseUnavailableReason.noOffering;
    }
    if (!hasCurrentOffering) return PurchaseUnavailableReason.noOffering;
    return productIds.contains(productId)
        ? null
        : PurchaseUnavailableReason.noPackage;
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

  // ---------------------------------------------------------------------------
  // Purchasing
  // ---------------------------------------------------------------------------

  /// Hands [package] to the store. A closed sheet is an outcome, not an
  /// error; anything else the store refuses is rethrown for the caller's
  /// error path.
  Future<PurchaseOutcome> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _updatePremiumStatus(result.customerInfo);
      return _isPremium
          ? PurchaseOutcome.purchased
          : PurchaseOutcome.entitlementMissing;
    } on PlatformException catch (e) {
      // The plugin reports every store error as a PlatformException. This
      // used to be `on PurchasesErrorCode catch`, which can never match —
      // so a closed sheet reached the screens as an exception, was logged
      // as purchase_failed, and showed "something went wrong".
      if (_errorCode(e) == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseOutcome.cancelled;
      }
      debugPrint('RevenueCat: Purchase error: ${e.code} ${e.message}');
      rethrow;
    }
  }

  static PurchasesErrorCode _errorCode(PlatformException e) {
    try {
      return PurchasesErrorHelper.getErrorCode(e);
    } catch (_) {
      // A non-numeric code is nothing the helper can map.
      return PurchasesErrorCode.unknownError;
    }
  }

  /// Purchase by plan name (monthly, yearly, lifetime).
  /// Maps plan names to RevenueCat product IDs.
  Future<PurchaseOutcome> purchasePlan(String plan) async {
    final package = getPackageByProductId(_productIdFor(plan));
    if (package == null) {
      debugPrint('RevenueCat: Package not found for $plan');
      return PurchaseOutcome.unavailable;
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
