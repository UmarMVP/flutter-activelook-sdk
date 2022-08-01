import 'package:activelook_sdk/activelook_sdk_method_channel.dart';

class ActivelookSdk {
  Future<String?> initSdk() {
    return ActiveLookSDKChannel.shared.initSdk();
  }

  Future<String?> startScan() {
    return ActiveLookSDKChannel.shared.startScan();
  }

  Future<String?> connectGlasses() {
    return ActiveLookSDKChannel.shared.connectGlasses();
  }
}
