package com.asite.asite_plugins


import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** AsitePluginsPlugin */
class AsitePluginsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "asite_plugins")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method.equals(MethodConstants.ENCRYPT) -> {
                val data = call.argument<String>("data")
                val algoType = call.argument<Int>("algoType")?.let { getAlgoType(it) }
                val cipher = algoType?.let { CryptoHelper.encrypt(data, it) }
                result.success(cipher)
            }
            call.method.equals(MethodConstants.DECRYPT) -> {
                val data = call.argument<String>("data")
                val algoType = call.argument<Int>("algoType")?.let { getAlgoType(it) }
                val jsonString = algoType?.let { CryptoHelper.decrypt(data, it) }
                result.success(jsonString)
            }
            call.method.equals(MethodConstants.UNIQUE_ANNOTATION_ID) -> {
                try {
                    result.success(Utils.getUniqueAnnotationId())
                } catch (e: Exception) {
                    result.success(null)
                }
            }
            call.method.equals(MethodConstants.UNIQUE_DEVICE_ID) -> {
                try {
                    result.success(Utils.getUniqueDeviceId(context))
                } catch (e: Exception) {
                    result.success(null)
                }
            }
            call.method.equals(MethodConstants.DEVICE_SDK_INT) -> {
                try {
                    result.success(Utils.getDeviceSdkInt())
                } catch (e: Exception) {
                    result.success(null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    private fun getAlgoType(algoType: Int): CryptoHelper.Companion.EncryptionAlgorithm {
        if (algoType == 1) {
            return CryptoHelper.Companion.EncryptionAlgorithm.CTR
        }
        return CryptoHelper.Companion.EncryptionAlgorithm.ECB
    }
}
