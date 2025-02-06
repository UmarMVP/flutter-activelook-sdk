import 'package:activelook_sdk/activelook_sdk_method_channel.dart';
import 'package:flutter/services.dart';

class ActivelookSdk {
  Future<bool?> initSdk() {
    return ActiveLookSDKChannel.shared.initSdk();
  }

  Future<bool?> startScan() {
    return ActiveLookSDKChannel.shared.startScan();
  }

  Future<void> connectGlasses(String identifier) {
    ActiveLookSDKChannel.shared.connectGlasses(identifier);
    return Future.value();
  }

  Future<bool?> isSdkInitialized() {
    return ActiveLookSDKChannel.shared.isSdkInitialized();
  }

  void listenToScanResults(
      Function(dynamic) onData, Function(dynamic) onError) {
    ActiveLookSDKChannel.shared.listenToScanResults(onData, onError);
  }

  Future<bool?> stopScan() {
    return ActiveLookSDKChannel.shared.stopScan();
  }

  Future<bool?> disconnectGlasses(String identifier) {
    return ActiveLookSDKChannel.shared.disconnectGlasses(identifier);
  }

    Future<void> sendTextToGlasses(
      String text, int x, int y, int rotation, int font, int color) {
    ActiveLookSDKChannel.shared
        .sendTextToGlasses(text, x, y, rotation, font, color);
    return Future.value();
  }


  void listenToConnectionStatus(
      Function(dynamic) onData, Function(dynamic) onError) {
    ActiveLookSDKChannel.shared.listenToConnectionStatus(onData, onError);
  }
  void dispose() {
    ActiveLookSDKChannel.shared.dispose();
  }
}
