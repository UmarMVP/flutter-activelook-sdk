import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'activelook_sdk_platform_interface.dart';

/// An implementation of [ActivelookSdkPlatform] that uses method channels.
class MethodChannelActivelookSdk extends ActivelookSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('activelook_sdk');

  MethodChannelActivelookSdk() {
    methodChannel.setMethodCallHandler(_handleMethod);
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> initSdk() async {
    final status = await methodChannel.invokeMethod<String?>(
        "initSdk", "bdjZ3ulWitvUzVtUHevbll1AiOANEfPYsv5u6RaGcxk");
    log(status!);
  }

  @override
  Future<String?> startScan() async {
    final status = await methodChannel.invokeMethod<String?>("startScan");
    print('TEST SCAN');
    print(status!);
  }

  Future<Null> _handleMethod(MethodCall call) async {
    print('call from SDK');
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
        log('Discovered glasses :  ${args["name"]}');
        break;
      default:
        log("UNKNOWN METHOD");
    }
  }
}
