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
          let token: String = call.arguments as! String;
          do {
              sdk = try ActiveLookSDK.shared(token: token, onUpdateStartCallback: { _ in print("update started") }, onUpdateAvailableCallback: { _,_ in print("update available") }, onUpdateProgressCallback: { _ in print("update progress") }, onUpdateSuccessCallback: { _ in print("update success") }, onUpdateFailureCallback: { _ in print("update fail") })
          } catch {
              print("init error")
          }
          
      } else if (call.method.elementsEqual("ActiveLookSDK#startScan")) {
          
      } else if (call.method.elementsEqual("ActiveLookSDK#connectGlasses")) {
          
      }
    }
}
