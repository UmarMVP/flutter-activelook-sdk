
import 'activelook_sdk_platform_interface.dart';

class ActivelookSdk {
  Future<String?> getPlatformVersion() {
    return ActivelookSdkPlatform.instance.getPlatformVersion();
  }
}
