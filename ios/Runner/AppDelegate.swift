import Flutter
import UIKit
import CoreHaptics
import HealthKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Pause-feature controllers. All three live in this file on purpose: the
  // Runner group is not filesystem-synchronized, so a new Swift file would
  // mean editing project.pbxproj — the file the widget-extension setup memo
  // says not to touch.
  private let breathHaptics = BreathHapticsController()
  private let healthBridge = HealthBridgeController()
  private let watchInfo = WatchInfoController()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Try rootViewController first, then fall back to registrar's messenger
    let messenger: FlutterBinaryMessenger
    if let controller = window?.rootViewController as? FlutterViewController {
      messenger = controller.binaryMessenger
    } else if let registrar = self.registrar(forPlugin: "AppIconPlugin") {
      messenger = registrar.messenger()
    } else {
      return result
    }

    setUpAppIconChannel(messenger: messenger)
    setUpPauseChannel(messenger: messenger)

    return result
  }

  // MARK: - App icon channel

  private func setUpAppIconChannel(messenger: FlutterBinaryMessenger) {
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

  // MARK: - Pause channel (haptics + HealthKit writes + Watch probe)

  private func setUpPauseChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "com.intendedapp.ios/pause",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "prepareHaptics":
        result(self.breathHaptics.prepare())

      case "playHapticCycle":
        self.breathHaptics.playCycle()
        result(nil)

      case "stopHaptics":
        self.breathHaptics.stop()
        result(nil)

      case "healthIsAvailable":
        result(HKHealthStore.isHealthDataAvailable())

      case "healthRequestWriteAuth":
        self.healthBridge.requestWriteAuthorization { ok in
          DispatchQueue.main.async { result(ok) }
        }

      case "healthWriteMindful":
        if let args = call.arguments as? [String: Any],
           let start = (args["startMs"] as? NSNumber)?.doubleValue,
           let end = (args["endMs"] as? NSNumber)?.doubleValue {
          self.healthBridge.writeMindfulSession(startMs: start, endMs: end)
        }
        result(nil)

      case "healthWriteStateOfMind":
        if #available(iOS 18.0, *),
           let args = call.arguments as? [String: Any],
           let state = args["state"] as? String,
           let dateMs = (args["dateMs"] as? NSNumber)?.doubleValue {
          self.healthBridge.writeStateOfMind(stateKey: state, dateMs: dateMs)
        }
        result(nil)

      case "watchIsPaired":
        self.watchInfo.isPaired { paired in
          DispatchQueue.main.async { result(paired) }
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

// MARK: - Breathing haptics

/// One 12-second breath per play: intensity rises over the 5s inhale and
/// decays over the 7s exhale. Sharpness stays low throughout — mist, not
/// clicks. The Dart side calls playCycle at each visual cycle start so the
/// two clocks can never drift apart.
final class BreathHapticsController {
  private var engine: CHHapticEngine?
  private var player: CHHapticPatternPlayer?

  /// False on iPad and other engine-less hardware — the caller then carries
  /// the rhythm with visuals alone, which every variant must survive.
  func prepare() -> Bool {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
      return false
    }
    do {
      if engine == nil {
        let created = try CHHapticEngine()
        created.resetHandler = { [weak self] in
          try? self?.engine?.start()
        }
        engine = created
      }
      try engine?.start()
      return true
    } catch {
      return false
    }
  }

  func playCycle() {
    guard let engine = engine else { return }
    let inhale = 5.0
    let total = 12.0

    let event = CHHapticEvent(
      eventType: .hapticContinuous,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2),
      ],
      relativeTime: 0,
      duration: total
    )
    // The felt intensity is the event's 0.55 scaled by this curve: a soft
    // rise to the crest at 5s, a brief turn, then a long decay to nothing.
    let curve = CHHapticParameterCurve(
      parameterID: .hapticIntensityControl,
      controlPoints: [
        .init(relativeTime: 0, value: 0.12),
        .init(relativeTime: inhale * 0.85, value: 0.9),
        .init(relativeTime: inhale, value: 1.0),
        .init(relativeTime: inhale + 0.4, value: 0.85),
        .init(relativeTime: total * 0.8, value: 0.25),
        .init(relativeTime: total, value: 0.0),
      ],
      relativeTime: 0
    )

    do {
      let pattern = try CHHapticPattern(events: [event], parameterCurves: [curve])
      player = try engine.makePlayer(with: pattern)
      try player?.start(atTime: CHHapticTimeImmediate)
    } catch {
      // Haptics are an enhancement; a failed cycle is silence, not an error.
    }
  }

  func stop() {
    try? player?.stop(atTime: CHHapticTimeImmediate)
    engine?.stop()
  }
}

// MARK: - HealthKit bridge (write-only in this release)

/// Writes mindful sessions and (iOS 18+) State of Mind samples. Never reads.
/// Every path is guarded twice: hardware availability and per-type sharing
/// authorization — an unauthorized write is a silent no-op, never an error
/// the UI could surface.
final class HealthBridgeController {
  private lazy var store = HKHealthStore()

  private var mindfulType: HKCategoryType? {
    HKObjectType.categoryType(forIdentifier: .mindfulSession)
  }

  func requestWriteAuthorization(completion: @escaping (Bool) -> Void) {
    guard HKHealthStore.isHealthDataAvailable(), let mindful = mindfulType else {
      completion(false)
      return
    }
    var share: Set<HKSampleType> = [mindful]
    if #available(iOS 18.0, *) {
      share.insert(HKSampleType.stateOfMindType())
    }
    store.requestAuthorization(toShare: share, read: nil) { ok, _ in
      completion(ok)
    }
  }

  func writeMindfulSession(startMs: Double, endMs: Double) {
    guard HKHealthStore.isHealthDataAvailable(),
          let mindful = mindfulType,
          store.authorizationStatus(for: mindful) == .sharingAuthorized,
          endMs > startMs else { return }
    let sample = HKCategorySample(
      type: mindful,
      value: HKCategoryValue.notApplicable.rawValue,
      start: Date(timeIntervalSince1970: startMs / 1000),
      end: Date(timeIntervalSince1970: endMs / 1000)
    )
    store.save(sample) { _, _ in }
  }

  @available(iOS 18.0, *)
  func writeStateOfMind(stateKey: String, dateMs: Double) {
    guard HKHealthStore.isHealthDataAvailable(),
          store.authorizationStatus(for: HKSampleType.stateOfMindType()) == .sharingAuthorized
    else { return }

    // Keys are PauseState.key on the Dart side — the two lists move together.
    // The copy is a response scale, not an absolute one: "still tense" /
    // "a little calmer" / "it lifted", so the middle key is mildly positive
    // and the top is relief, not mere calm.
    let valence: Double
    let label: HKStateOfMind.Label
    switch stateKey {
    case "tense":
      valence = -0.4
      label = .stressed
    case "calm":
      valence = 0.6
      label = .relieved
    default:
      valence = 0.2
      label = .calm
    }

    let sample = HKStateOfMind(
      date: Date(timeIntervalSince1970: dateMs / 1000),
      kind: .momentaryEmotion,
      valence: valence,
      labels: [label],
      associations: []
    )
    store.save(sample) { _, _ in }
  }
}

// MARK: - Watch pairing probe

/// Answers whether an Apple Watch is paired — device info for the one-time
/// analytics event that decides the sleep feature. Answers nil on iPad:
/// pairing is an iPhone question, and iPads in the denominator would
/// understate the number.
final class WatchInfoController: NSObject, WCSessionDelegate {
  private var pendingCompletions: [(Bool?) -> Void] = []

  func isPaired(completion: @escaping (Bool?) -> Void) {
    guard UIDevice.current.userInterfaceIdiom == .phone, WCSession.isSupported() else {
      completion(nil)
      return
    }
    let session = WCSession.default
    if session.activationState == .activated {
      completion(session.isPaired)
      return
    }
    // isPaired is only valid after activation completes.
    pendingCompletions.append(completion)
    session.delegate = self
    session.activate()
  }

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    let paired: Bool? = activationState == .activated ? session.isPaired : nil
    let completions = pendingCompletions
    pendingCompletions = []
    DispatchQueue.main.async {
      for complete in completions { complete(paired) }
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) {}
}
