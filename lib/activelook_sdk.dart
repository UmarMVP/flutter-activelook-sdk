import 'activelook_sdk_platform_interface.dart';

class ActivelookSdk {
  Future<String?> getPlatformVersion() {
    return ActivelookSdkPlatform.instance.getPlatformVersion();
  }

  Future<String?> initSdk() {
    return ActivelookSdkPlatform.instance.initSdk();
  }

  Future<String?> startScan() {
    return ActivelookSdkPlatform.instance.startScan();
  }
}
