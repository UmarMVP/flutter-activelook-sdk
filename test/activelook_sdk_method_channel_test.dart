import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:activelook_sdk/activelook_sdk_method_channel.dart';

void main() {
  MethodChannelActivelookSdk platform = MethodChannelActivelookSdk();
  const MethodChannel channel = MethodChannel('activelook_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
