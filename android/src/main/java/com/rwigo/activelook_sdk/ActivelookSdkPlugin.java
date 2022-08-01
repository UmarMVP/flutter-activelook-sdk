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
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private Context context;
  private BinaryMessenger messenger;
  private Sdk activelookSdk = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "activelook_sdk");
    channel.setMethodCallHandler(this);

    this.context = flutterPluginBinding.getApplicationContext();
    this.messenger = flutterPluginBinding.getBinaryMessenger();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      this.log("working function test");
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("initSdk")) {
        String token = (String) call.arguments;
        this.log("initializing SDK with " + token + "...");
        try {
          this.activelookSdk = Sdk.init(this.context, token, new Consumer<GlassesUpdate>() {
            @Override
            public void accept(GlassesUpdate glassesUpdate) {
              invokeMethodOnUiThread("handleUpdateStart", new HashMap());
            }
          }, new Predicate<GlassesUpdate>() {
            @Override
            public boolean test(GlassesUpdate glassesUpdate) {
              invokeMethodOnUiThread("handleUpdateAvailable", new HashMap());
              return false;
            }
          }, new Consumer<GlassesUpdate>() {
            @Override
            public void accept(GlassesUpdate glassesUpdate) {
              invokeMethodOnUiThread("handleUpdateProgress", new HashMap());
            }
          }, new Consumer<GlassesUpdate>() {
            @Override
            public void accept(GlassesUpdate glassesUpdate) {
              invokeMethodOnUiThread("handleUpdateSuccess", new HashMap());
            }
          }, new Consumer<GlassesUpdate>() {
            @Override
            public void accept(GlassesUpdate glassesUpdate) {
              invokeMethodOnUiThread("handleUpdateError", new HashMap());
            }
          });
        } catch (Error err) {
          this.log(err.toString());
        }

        this.log("initialized SDK !");
        result.success("Sdk initialized");
    } else if (call.method.equals("startScan")) {

      this.log("Called start scan");
      if (this.activelookSdk == null) return;
      this.log("Start scanning..." );

      this.activelookSdk.startScan(new Consumer<DiscoveredGlasses>() {
        @Override
        public void accept(DiscoveredGlasses dg) {
          ActivelookSdkPlugin.this.log("Glasses found :" +  dg.getName());
          HashMap<String, Object> args = new HashMap<>();
          args.put("uuid", dg.getAddress());
          args.put("name", dg.getName());
          invokeMethodOnUiThread("handleDiscoveredGlasses", args);
        }
      });
      result.success("Start scanning...");
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  // Sdk callbacks

  // utils

  private void log(String message) {
    Log.d("FLUTTER_ACTIVELOOK", message);
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
