import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:activelook_sdk/activelook_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _activelookSdkPlugin = ActivelookSdk();

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> perms = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse
    ].request();
    print(perms);
  }

  Future<void> startScan() async {
    try {
      _activelookSdkPlugin.startScan();
    } on PlatformException {
      log("Failed to start scan");
    }
  }

  Future<void> initSdk() async {
    try {
      await _activelookSdkPlugin.initSdk();
    } on PlatformException {
      log("Failed to init SDK");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(onPressed: initSdk, child: const Text('initSdk')),
              ElevatedButton(
                  onPressed: startScan, child: const Text('startScan'))
            ],
          ),
        ),
      ),
    );
  }
}
