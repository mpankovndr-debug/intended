import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Set up app icon method channel
    // Try rootViewController first, then fall back to registrar's messenger
    let messenger: FlutterBinaryMessenger
    if let controller = window?.rootViewController as? FlutterViewController {
      messenger = controller.binaryMessenger
    } else if let registrar = self.registrar(forPlugin: "AppIconPlugin") {
      messenger = registrar.messenger()
    } else {
      return result
    }

    let channel = FlutterMethodChannel(
      name: "com.intendedapp.ios/app_icon",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard call.method == "setAlternateIcon" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: Any?] else {
        result(FlutterError(code: "BAD_ARGS", message: nil, details: nil))
        return
      }
      let iconName = args["iconName"] as? String
      self?.setAlternateIcon(iconName, result: result)
    }

    return result
  }

  private func setAlternateIcon(_ name: String?, result: @escaping FlutterResult) {
    guard UIApplication.shared.supportsAlternateIcons else {
      result(FlutterError(code: "UNSUPPORTED", message: "Alternate icons not supported", details: nil))
      return
    }
    UIApplication.shared.setAlternateIconName(name) { error in
      if let error = error {
        result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
      } else {
        result(nil)
      }
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
