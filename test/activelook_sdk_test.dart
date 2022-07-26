import 'package:flutter_test/flutter_test.dart';
import 'package:activelook_sdk/activelook_sdk.dart';
import 'package:activelook_sdk/activelook_sdk_platform_interface.dart';
import 'package:activelook_sdk/activelook_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockActivelookSdkPlatform 
    with MockPlatformInterfaceMixin
    implements ActivelookSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ActivelookSdkPlatform initialPlatform = ActivelookSdkPlatform.instance;

  test('$MethodChannelActivelookSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelActivelookSdk>());
  });

  test('getPlatformVersion', () async {
    ActivelookSdk activelookSdkPlugin = ActivelookSdk();
    MockActivelookSdkPlatform fakePlatform = MockActivelookSdkPlatform();
    ActivelookSdkPlatform.instance = fakePlatform;
  
    expect(await activelookSdkPlugin.getPlatformVersion(), '42');
  });
}
