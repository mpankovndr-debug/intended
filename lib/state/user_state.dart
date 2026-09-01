import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../services/analytics_service.dart';

class UserState extends ChangeNotifier {
  String? _name;
  List<String> _focusAreas = [];
  bool _hasSubscription = false;
  bool _hasBoost = false;

  // Getters
  String? get name => _name;
  List<String> get focusAreas => List.unmodifiable(_focusAreas);
  bool get hasSubscription => _hasSubscription;
  bool get hasBoost => _hasBoost;

  // Setters
  void setName(String? value) {
    _name = value;
    notifyListeners();
  }

  void setFocusAreas(List<String> areas) {
    _focusAreas = List.from(areas);
    AnalyticsService.setFocusAreaCount(areas.length);
    notifyListeners();
  }

  /// Mirrored to disk so code with no BuildContext — the notification
  /// scheduler, which decides on every app open whether to promise a paid
  /// card — can read the last known answer. Written on change only, like
  /// everything RevenueCat pushes here, so it stays whatever it last was
  /// until the entitlement actually moves.
  static const _persistedKey = 'has_subscription';

  static Future<bool> hasSubscriptionPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_persistedKey) ?? false;
  }

  void setSubscription(bool value) {
    _hasSubscription = value;
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_persistedKey, value));
    notifyListeners();
  }

  void setBoost(bool value) {
    _hasBoost = value;
    notifyListeners();
  }
  
  void updateFromOnboarding(OnboardingState onboardingState) {
    _name = onboardingState.name;
    _focusAreas = List.from(onboardingState.focusAreas);
    AnalyticsService.setFocusAreaCount(_focusAreas.length);
    notifyListeners();
  }
  
  void reset() {
    _name = null;
    _focusAreas = [];
    _hasSubscription = false;
    _hasBoost = false;
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_persistedKey, false));
    notifyListeners();
  }
}

// Keep the ValueNotifier for backwards compatibility
final ValueNotifier<String?> userNameNotifier = ValueNotifier(null);