import Flutter
import UIKit
import ActiveLookSDK

public class SwiftActivelookSdkPlugin: NSObject, FlutterPlugin {

    override public init() {
        super.init()
    }

    private var sdk: ActiveLookSDK!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ActiveLookSDK", binaryMessenger: registrar.messenger())
        let instance = SwiftActivelookSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method.elementsEqual("ActiveLookSDK#initSdk")) {
            if let token = call.arguments as? String {
                do {
                    sdk = ActiveLookSDK.shared // Initialize the SDK instance first
                    try sdk.initialize(withToken: token, 
                                       onUpdateStartCallback: { _ in print("update started") },
                                       onUpdateAvailableCallback: { _, _ in print("update available") },
                                       onUpdateProgressCallback: { _ in print("update progress") },
                                       onUpdateSuccessCallback: { _ in print("update success") },
                                       onUpdateFailureCallback: { _ in print("update fail") })
                } catch {
                    print("Init error: \(error.localizedDescription)")
                    result(FlutterError(code: "SDK_INIT_ERROR", message: "Failed to initialize SDK", details: nil))
                }
            }
        } else if (call.method.elementsEqual("ActiveLookSDK#startScan")) {
            // Handle startScan
        } else if (call.method.elementsEqual("ActiveLookSDK#connectGlasses")) {
            // Handle connectGlasses
        }
    }
}
