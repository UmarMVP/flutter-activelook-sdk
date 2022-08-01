import 'dart:developer';

import 'package:flutter/services.dart';

class ActiveLookSDKChannel {
  static ActiveLookSDKChannel shared = ActiveLookSDKChannel();

  final methodChannel = const MethodChannel('ActiveLookSDK');

  MethodChannelActivelookSdk() {
    methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<String?> initSdk() async {
    final status = await methodChannel.invokeMethod<String?>(
        "ActiveLookSDK#initSdk", "bdjZ3ulWitvUzVtUHevbll1AiOANEfPYsv5u6RaGcxk");
    print(status!);
  }

  Future<String?> startScan() async {
    final status =
        await methodChannel.invokeMethod<String?>("ActiveLookSDK#startScan");
    print(status!);
  }

  Future<String?> connectGlasses() async {
    final status = await methodChannel
        .invokeMethod<String?>("ActiveLookSDK#connectGlasses");
    print(status!);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'handleUpdateStart':
        log("Update started !");
        break;
      case 'handleUpdateAvailable':
        log("Update available !");
        break;
      case 'handleUpdateProgress':
        log("Update progress !");
        break;
      case 'handleUpdateSuccess':
        log("Update SUCCESS !");
        break;
      case 'handleUpdateError':
        log("Update ERROR !");
        break;
      case 'handleDiscoveredGlasses':
        Map<String, dynamic> args = call.arguments.cast<String, dynamic>();
        String glassesName = args["name"];
        String glassesUUID = args["uuid"];
        print(
          'Discovered glasses :  $glassesName, $glassesUUID',
        );
        break;
      case 'handleConnectedGlasses':
        log("Connected to glasses !");
        break;
      case 'handleConnectionFail':
        log("Connection failed !");
        break;
      case 'handleDisconnectedGlasses':
        log("Disconnected from glasses !");
        break;
      default:
        log("UNKNOWN METHOD");
    }
  }
}
