import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'activelook_sdk_method_channel.dart';

abstract class ActivelookSdkPlatform extends PlatformInterface {
  /// Constructs a ActivelookSdkPlatform.
  ActivelookSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static ActivelookSdkPlatform _instance = MethodChannelActivelookSdk();

  /// The default instance of [ActivelookSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelActivelookSdk].
  static ActivelookSdkPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ActivelookSdkPlatform] when
  /// they register themselves.
  static set instance(ActivelookSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
