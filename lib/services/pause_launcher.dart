import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'notification_scheduler.dart';

/// Funnels every "open the Pause" request that starts outside the app —
/// widget taps (homeWidget://pause), the notification action button, and
/// cold starts from either — into one notifier the home screen listens to,
/// mirroring [NotificationScheduler.pendingTabSwitch].
class PauseLauncher {
  PauseLauncher._();

  /// The pending entry source ('widget' | 'lockscreen' | 'notification'),
  /// or null. The home screen consumes it and pushes the screen.
  static final ValueNotifier<String?> pending = ValueNotifier<String?>(null);

  static bool _listening = false;

  /// Call once after the first frame: the cold-start checks need the app
  /// group and the notification plugin already initialized.
  static Future<void> init() async {
    if (!_listening) {
      _listening = true;
      HomeWidget.widgetClicked.listen(handleWidgetUri);
    }
    try {
      handleWidgetUri(await HomeWidget.initiallyLaunchedFromHomeWidget());
    } catch (_) {
      // No widget launch to report — nothing to do.
    }
    if (await NotificationScheduler.launchedFromPauseAction()) {
      pending.value = 'notification';
    }
  }

  /// The URI contract with the widget extension:
  /// homeWidget://pause?src=lockscreen|widget. Public and pure so a test can
  /// pin it — the Swift side hardcodes the same strings.
  @visibleForTesting
  static void handleWidgetUri(Uri? uri) {
    if (uri == null || uri.host != 'pause') return;
    pending.value =
        uri.queryParameters['src'] == 'lockscreen' ? 'lockscreen' : 'widget';
  }
}
