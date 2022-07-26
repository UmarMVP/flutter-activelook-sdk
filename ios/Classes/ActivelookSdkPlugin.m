#import "ActivelookSdkPlugin.h"
#if __has_include(<activelook_sdk/activelook_sdk-Swift.h>)
#import <activelook_sdk/activelook_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "activelook_sdk-Swift.h"
#endif

@implementation ActivelookSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftActivelookSdkPlugin registerWithRegistrar:registrar];
}
@end
