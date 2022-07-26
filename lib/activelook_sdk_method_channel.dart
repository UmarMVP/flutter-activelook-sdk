import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'activelook_sdk_platform_interface.dart';

/// An implementation of [ActivelookSdkPlatform] that uses method channels.
class MethodChannelActivelookSdk extends ActivelookSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('activelook_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
