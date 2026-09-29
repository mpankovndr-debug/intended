import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intended/services/health_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The soft-ask's own rules. They live in HealthService rather than the pause
/// screen precisely so they can be tested without a Navigator — the sheet
/// itself needs a BuildContext, these do not.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.intendedapp.ios/pause');
  var healthAvailable = true;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    healthAvailable = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'healthIsAvailable') return healthAvailable;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('offers after the first completed pause', () async {
    expect(await HealthService.shouldOfferSave(), isTrue);
  });

  test('a dismissal is not an answer — the ask returns next pause', () async {
    // The scar: this used to set the answered flag, so a tap on the barrier
    // retired Health permanently with no way back.
    await HealthService.markOffered();
    expect(await HealthService.shouldOfferSave(), isTrue);
  });

  test('retires after three unanswered appearances rather than nagging',
      () async {
    for (var i = 1; i <= 3; i++) {
      expect(await HealthService.shouldOfferSave(), isTrue, reason: 'offer $i');
      await HealthService.markOffered();
    }
    expect(await HealthService.shouldOfferSave(), isFalse);
  });

  test('an explicit answer settles it on the spot', () async {
    await HealthService.markOffered();
    await HealthService.markAnswered();
    expect(await HealthService.shouldOfferSave(), isFalse);
  });

  test('an explicit "not now" is as final as a yes', () async {
    await HealthService.markAnswered();
    expect(await HealthService.shouldOfferSave(), isFalse);
  });

  test('never asks where Health does not exist', () async {
    healthAvailable = false;
    expect(await HealthService.shouldOfferSave(), isFalse);
  });

  test('an unavailable-Health device does not burn its three offers',
      () async {
    healthAvailable = false;
    for (var i = 0; i < 5; i++) {
      expect(await HealthService.shouldOfferSave(), isFalse);
    }
    healthAvailable = true;
    expect(await HealthService.shouldOfferSave(), isTrue);
  });
}
