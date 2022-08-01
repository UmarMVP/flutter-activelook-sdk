package com.rwigo.activelook_sdk;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.core.util.Predicate;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.activelook.activelooksdk.DiscoveredGlasses;
import com.activelook.activelooksdk.Sdk;
import com.activelook.activelooksdk.types.GlassesUpdate;

import java.util.HashMap;

/** ActivelookSdkPlugin */
public class ActivelookSdkPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  private Context context;
  private BinaryMessenger messenger;
  private Sdk activelookSdk = null;

  // Flutter plugin implementation

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "ActiveLookSDK");
    channel.setMethodCallHandler(this);

    this.context = flutterPluginBinding.getApplicationContext();
    this.messenger = flutterPluginBinding.getBinaryMessenger();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if(call.method.equals("ActiveLookSDK#initSdk")) {
      String token = (String) call.arguments;
      this.initSdk(token);
      result.success("Sdk initialized");
    }
    else if (call.method.equals("ActiveLookSDK#startScan")) {
      this.startScan();
      result.success("Start scanning...");
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  // Sdk methods calls

  private void initSdk(String token) {
    this.activelookSdk = Sdk.init(
            this.context,
            token,
            glassesUpdate -> invokeMethodOnUiThread("handleUpdateStart", new HashMap()),
            glassesUpdate -> {
              invokeMethodOnUiThread("handleUpdateAvailable", new HashMap());
              return false;
            },
            glassesUpdate -> invokeMethodOnUiThread("handleUpdateProgress", new HashMap()),
            glassesUpdate -> invokeMethodOnUiThread("handleUpdateSuccess", new HashMap()),
            glassesUpdate -> invokeMethodOnUiThread("handleUpdateError", new HashMap())
    );
  }

  private void startScan() {
    if (this.activelookSdk == null) return;

    this.activelookSdk.startScan(dg -> {
      HashMap<String, Object> args = new HashMap<>();
      args.put("uuid", dg.getAddress());
      args.put("name", dg.getName());
      invokeMethodOnUiThread("handleDiscoveredGlasses", args);
    });
  }

  // Utils

  private void log(String message) {
    Log.d("FROM_NATIVE", message);
  }

  private void runOnMainThread(final Runnable runnable) {
    if (Looper.getMainLooper().getThread() == Thread.currentThread())
      runnable.run();
    else {
      Handler handler = new Handler(Looper.getMainLooper());
      handler.post(runnable);
    }
  }

  void invokeMethodOnUiThread(final String methodName, final HashMap map) {
    final MethodChannel channel = this.channel;
    runOnMainThread(new Runnable() {
      @Override
      public void run() {
        channel.invokeMethod(methodName, map);
      }
    });
  }
}
