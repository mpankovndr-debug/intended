import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analytics_service.dart';
import 'app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.warmClay;

  AppTheme get theme => _theme;
  AppColorScheme get colors => AppColors.of(_theme);

  static const _key = 'selected_theme';

  static const List<AppTheme> boostThemes = [
    AppTheme.deepFocus,
    AppTheme.nightBloom,
  ];

  static const List<AppTheme> premiumThemes = [
    AppTheme.clearSky,
    AppTheme.morningSlate,
    AppTheme.softDusk,
    AppTheme.forestFloor,
    AppTheme.goldenHour,
    AppTheme.sandDune,
  ];

  bool isBoostTheme(AppTheme t) => boostThemes.contains(t);
  bool isPremiumTheme(AppTheme t) => premiumThemes.contains(t);

  /// Returns true if the theme is locked for the user's current tier.
  bool isLocked(AppTheme t, {required bool hasBoost, required bool isPremium}) {
    if (isPremium) return false;
    if (hasBoost && isBoostTheme(t)) return false;
    if (!isBoostTheme(t) && !isPremiumTheme(t)) return false;
    return true;
  }

  /// Returns the tier label for a locked theme.
  String? tierLabel(AppTheme t) {
    if (boostThemes.contains(t)) return 'Boost';
    if (premiumThemes.contains(t)) return 'Intended+';
    return null;
  }

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      _theme = AppTheme.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppTheme.warmClay,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(AppTheme t) async {
    _theme = t;
    notifyListeners();
    AnalyticsService.logThemeChanged(t.name);
    AnalyticsService.setTheme(t.name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, t.name);
  }
}
