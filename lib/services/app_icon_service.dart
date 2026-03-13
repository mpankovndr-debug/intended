import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available alternate app icons.
enum AppIcon {
  defaultIcon,
  midnight,
  rose,
  forest,
  sky;

  /// The iOS alternate icon name (matches CFBundleAlternateIcons keys).
  /// null = primary icon.
  String? get iosName => switch (this) {
    AppIcon.defaultIcon => null,
    AppIcon.midnight => 'AppIconMidnight',
    AppIcon.rose => 'AppIconRose',
    AppIcon.forest => 'AppIconForest',
    AppIcon.sky => 'AppIconSky',
  };
}

/// Manages alternate app icon switching via a platform method channel.
class AppIconService {
  static const _channel = MethodChannel('com.intendedapp.ios/app_icon');
  static const _prefKey = 'selected_app_icon';

  /// Returns the currently selected icon (from prefs).
  static Future<AppIcon> getCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefKey);
    if (name == null) return AppIcon.defaultIcon;
    return AppIcon.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppIcon.defaultIcon,
    );
  }

  /// Resets to the default icon if the current icon is a premium one.
  static Future<void> resetIfPremium() async {
    final current = await getCurrent();
    if (current != AppIcon.defaultIcon) {
      await setIcon(AppIcon.defaultIcon);
    }
  }

  /// Sets the app icon. Returns true on success.
  /// Saves preference even if the native call fails (e.g. on simulator).
  static Future<bool> setIcon(AppIcon icon) async {
    try {
      await _channel.invokeMethod('setAlternateIcon', {
        'iconName': icon.iosName,
      });
    } catch (_) {
      // Native call may fail on simulator or if channel isn't registered.
      // Still save the preference so the UI reflects the selection.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, icon.name);
    return true;
  }
}
