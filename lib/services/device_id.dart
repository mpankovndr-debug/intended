import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// An anonymous id for this install, made once and kept, so RevenueCat can
/// tie a subscription to the device before anyone signs in.
class DeviceId {
  DeviceId._();

  static const String key = 'device_id';

  static Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(key);
    if (id == null) {
      final random = Random.secure();
      id = List.generate(16, (_) => random.nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      await prefs.setString(key, id);
    }
    return id;
  }
}
