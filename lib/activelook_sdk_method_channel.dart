import 'dart:developer';

import 'package:flutter/services.dart';

class ActiveLookSDKChannel {
  static ActiveLookSDKChannel shared = ActiveLookSDKChannel();

  final methodChannel = const MethodChannel('ActiveLookSDK');
  static const EventChannel _scanResultsChannel =
      EventChannel('ActiveLookSDK/scanResults');
  static const EventChannel _connectionStatusChannel =
      EventChannel('ActiveLookSDK/connectionStatus');

  // MethodChannelActivelookSdk() {
  //   methodChannel.setMethodCallHandler(_handleMethod);
  // }

  Future<bool?> initSdk() async {
    try {
      final status =
          await methodChannel.invokeMethod<String?>("ActiveLookSDK#initSdk");
      if (status != "true") {
        log(status.toString());
      }
      return status == "true";
    } on PlatformException catch (e) {
      log('Error initializing SDK: ${e.message}');
      return false;
    }
  }

  Future<bool?> startScan() async {
    try {
      final status =
          await methodChannel.invokeMethod<String?>("ActiveLookSDK#startScan");

      if (status != "true") {
        log(status.toString());
      }
      return status == "true";
    } on PlatformException catch (e) {
      log('Error initializing SDK: ${e.message}');
      return false;
    }
  }

  Future<void> connectGlasses(String identifier) async {
    try {
      final status = await methodChannel.invokeMethod<String?>(
        "ActiveLookSDK#connectGlasses",
        {"identifier": identifier},
      );
    } on PlatformException catch (e) {
      log('Error initializing SDK: ${e.message}');
    }
  }

  Future<bool?> isSdkInitialized() async {
    try {
      final status = await methodChannel
          .invokeMethod<String?>("ActiveLookSDK#isSdkInitialized");
      return status == "true";
    } on PlatformException catch (e) {
      log('Error initializing SDK: ${e.message}');
      return false;
    }
  }

  Future<bool?> stopScan() async {
    try {
      final status =
          await methodChannel.invokeMethod<String?>("ActiveLookSDK#stopScan");
      if (status != "true") {
        log(status.toString());
      }
      return status == "true";
    } on PlatformException catch (e) {
      log('Stop scan error: ${e.message}');
      return false;
    }
  }

  Future<bool?> disconnectGlasses(String identifier) async {
    try {
      final status = await methodChannel.invokeMethod<String?>(
        "ActiveLookSDK#disconnectGlasses",
        {"identifier": identifier},
      );
      if (status != "true") {
        log(status.toString());
      }
      return status == "true";
    } on PlatformException catch (e) {
      log('Disconnect error: ${e.message}');
      return false;
    }
  }

  void listenToScanResults(
      Function(dynamic) onData, Function(dynamic) onError) {
    _scanResultsChannel.receiveBroadcastStream("scanResults").listen(
      onData,
      onError: (error) {
        log('Scan error: $error');
        onError(error);
      },
    );
  }
   Future<void> sendTextToGlasses(
      String text, int x, int y, int rotation, int font, int color) async {
    try {
      final result = await methodChannel.invokeMethod('ActiveLookSDK#sendText', {
        'text': text,
        'x': x,
        'y': y,
        'rotation': rotation,
        'font': font,
        'color': color,
      });
      print(result);
    } catch (e) {
      print("Error sending text: $e");
    }
  }

  void listenToConnectionStatus(
      Function(dynamic) onData, Function(dynamic) onError) {
    _connectionStatusChannel.receiveBroadcastStream("connectionStatus").listen(
      onData,
      onError: (error) {
        log('Connection status error: $error');
        onError(error);
      },
    );
  }
    void dispose() {
    stopScan();
    methodChannel.invokeMethod("ActiveLookSDK#dispose");
    methodChannel.setMethodCallHandler(null);
  }
}
