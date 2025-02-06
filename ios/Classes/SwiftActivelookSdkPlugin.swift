import ActiveLookSDK
import CoreBluetooth
import Flutter
import Foundation
import UIKit

public class SwiftActivelookSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  override public init() {
    super.init()
  }

  private var sdk: ActiveLookSDK!
  private var discoveredGlasses: DiscoveredGlasses?
  private var scanEventSink: FlutterEventSink?
  private var connectionStatusSink: FlutterEventSink?
  private var discoveredGlassesList: [DiscoveredGlasses] = []
  private var connectedGlassesMap: [String: Glasses] = [:]



  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "ActiveLookSDK", binaryMessenger: registrar.messenger())
    let instance = SwiftActivelookSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    let scanResultsChannel = FlutterEventChannel(
      name: "ActiveLookSDK/scanResults", binaryMessenger: registrar.messenger())
    scanResultsChannel.setStreamHandler(instance)
     let connectionStatusChannel = FlutterEventChannel(
      name: "ActiveLookSDK/connectionStatus", binaryMessenger: registrar.messenger())
    connectionStatusChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    if call.method.elementsEqual("ActiveLookSDK#initSdk") {

      do {
        sdk = try ActiveLookSDK.shared(
          onUpdateStartCallback: { _ in print("update started") },
          onUpdateAvailableCallback: { _, _ in print("update available") },
          onUpdateProgressCallback: { _ in print("update progress") },
          onUpdateSuccessCallback: { _ in print("update success") },
          onUpdateFailureCallback: { _ in print("update fail") }
        )
        result("true")
      }

      catch {
        result(
          FlutterError(code: "SDK_INIT_ERROR", message: error.localizedDescription, details: nil))

      }

    } else if call.method.elementsEqual("ActiveLookSDK#isSdkInitialized") {

      if sdk != nil {
        result("true")
      } else {
        result("false")
      }

    } else if call.method.elementsEqual("ActiveLookSDK#startScan") {

      do {
        sdk.startScanning(
          onGlassesDiscovered: { [weak self] discoveredGlasses in

    self?.discoveredGlassesList.append(discoveredGlasses)

            if let details = self?.getPeripheralDetails(discoveredGlasses) {

              if let sink = self?.scanEventSink {
                sink(details)  
              }
            }

          },
          onScanError: { [weak self] error in
          if let sink = self?.scanEventSink {
    sink(FlutterError(code: "SCAN_ERROR", message: error.localizedDescription, details: nil))
}

          }
        )
               result("true")


      } catch {
        result(
          self.createJsonResponse(
            status: "false", message: "Scan error: \(error.localizedDescription)"))

      }

    } else if call.method.elementsEqual("ActiveLookSDK#connectGlasses") {
       if let arguments = call.arguments as? [String: Any],
     let identifier = arguments["identifier"] as? String {


      guard let glasses = discoveredGlassesList.first(where: { $0.identifier.uuidString == identifier }) else {
        result(self.createJsonResponse(status: "false", message: "Glasses not found"))
        return
    }

      glasses.connect(
        onGlassesConnected: {[weak self]  glasses in
                guard let self = self else { return }


                      self.connectedGlassesMap[identifier] = glasses

    
    if let sink = self.connectionStatusSink {
                sink( self.createJsonResponse(status: "true", message: "Connected to glasses")) 
              } 
        return

        },
        onGlassesDisconnected: {[weak self]  in
                    guard let self = self else { return }

                self.connectedGlassesMap.removeValue(forKey: identifier)

    
       if let sink = self.connectionStatusSink {
                sink( self.createJsonResponse(status: "false", message: "Disconnected from glasses"))  
              }
    
        return

        },
        onConnectionError: {[weak self]  error in
                guard let self = self else { return }

           if let sink = self.connectionStatusSink {
                sink( self.createJsonResponse(status: "false", message: "Error connecting from glasses"))  
              }
        return

        }
      )
       
      } else {
            result(self.createJsonResponse(status: "false", message: "Invalid identifier"))
        return

      }

    } else if call.method.elementsEqual("ActiveLookSDK#stopScan") {
    do {
        sdk.stopScanning()
        result("true")
        return
    } catch {
        result("Error stopping scan: \(error.localizedDescription)")
        return
    }
} else if call.method.elementsEqual("ActiveLookSDK#disconnectGlasses") {
    if let arguments = call.arguments as? [String: Any],
       let identifier = arguments["identifier"] as? String,
       let glasses = connectedGlassesMap[identifier] {

        glasses.disconnect()
        connectedGlassesMap.removeValue(forKey: identifier)
        result("true")
    } else {
        result("Invalid identifier or glasses not found")
    }
}else if call.method.elementsEqual("ActiveLookSDK#dispose") {

    sdk.stopScanning()
    sdk = nil
}else if call.method.elementsEqual("ActiveLookSDK#sendText") {
    if let arguments = call.arguments as? [String: Any],
       let text = arguments["text"] as? String,
       let x = arguments["x"] as? Int16,
       let y = arguments["y"] as? Int16,
       let rotationValue = arguments["rotation"] as? Int,
       let font = arguments["font"] as? UInt8,
       let color = arguments["color"] as? UInt8 {

        let rotation = TextRotation(rawValue: rotationValue) ?? .none  // Assuming .none as default
        txt(x: x, y: y, rotation: rotation, font: font, color: color, string: text)
        result("true")
    } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing parameters", details: nil))
    }
} else {
result(FlutterMethodNotImplemented)

    }
  }

  public func getProperties(of object: Any) -> String {
    let mirror = Mirror(reflecting: object)
    var propertiesString = ""

    for child in mirror.children {
      if let propertyName = child.label {
        propertiesString += "\(propertyName): \(child.value)\n"
      }
    }
    return propertiesString
  }

  public func getPeripheralDetails(_ glasses: DiscoveredGlasses) -> String {
    if let peripheralMirror = Mirror(reflecting: glasses).children.first(where: {
      $0.label == "peripheral"
    })?.value as? CBPeripheral {
      let peripheralDetails: [String: Any] = [
        "identifier": peripheralMirror.identifier.uuidString,
        "name": peripheralMirror.name ?? "Unknown",
        "discoverable_name": glasses.name,
        "manufacturerId": glasses.manufacturerId,
        "state": peripheralMirror.state.rawValue,
        "mtu": peripheralMirror.maximumWriteValueLength(for: .withoutResponse),
        "canSendWriteWithoutResponse": peripheralMirror.canSendWriteWithoutResponse,
      ]
      if let jsonData = try? JSONSerialization.data(
        withJSONObject: peripheralDetails, options: .prettyPrinted),
        let jsonString = String(data: jsonData, encoding: .utf8)
      {
        return jsonString
      }
    }
    return "{\"error\": \"Peripheral details not accessible\"}"
  }

  public func createJsonResponse(status: String, message: String) -> String {
    let response: [String: Any] = ["status": status, "message": message]
    if let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
      let jsonString = String(data: data, encoding: .utf8)
    {
      return jsonString
    }
    return "{\"status\": \"\(status)\", \"message\": \"\(message)\"}"
  }

public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    
    if let argument = arguments as? String {
        switch argument {
        case "scanResults":
            scanEventSink = events
        case "connectionStatus":
            connectionStatusSink = events
        default:
            return FlutterError(code: "INVALID_ARGUMENTS", message: "Unknown stream argument", details: nil)
        }
    } else {
        return FlutterError(code: "MISSING_ARGUMENTS", message: "No arguments provided", details: nil)
    }
    return nil
}

public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    
    if let argument = arguments as? String {
        switch argument {
        case "scanResults":
            scanEventSink = nil
        case "connectionStatus":
            connectionStatusSink = nil
        default:
            return FlutterError(code: "INVALID_ARGUMENTS", message: "Unknown stream argument", details: nil)
        }
    } else {
        return FlutterError(code: "MISSING_ARGUMENTS", message: "No arguments provided", details: nil)
    }
    return nil
}


}
