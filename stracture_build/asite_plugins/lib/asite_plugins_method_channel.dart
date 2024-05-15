import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'asite_plugins_platform_interface.dart';

/// An implementation of [AsitePluginsPlatform] that uses method channels.
class MethodChannelAsitePlugins extends AsitePluginsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('asite_plugins');

  @override
  Future<String> encrypt(data, EncryptionAlgorithm algorithm) async {
    var methodName = 'encrypt';
    var algoType = EncryptionAlgorithm.ecb.value;
    if (algorithm == EncryptionAlgorithm.ctr) {
      algoType = EncryptionAlgorithm.ctr.value;
    }
    try {
      var result = await methodChannel.invokeMethod(
        methodName,
        {'data': data, "algoType": algoType},
      );
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('${e.message}');
      }
      return '';
    }
  }

  @override
  Future<String> decrypt(data, EncryptionAlgorithm algorithm) async {
    var methodName = 'decrypt';
    var algoType = EncryptionAlgorithm.ecb.value;
    if (algorithm == EncryptionAlgorithm.ctr) {
      algoType = EncryptionAlgorithm.ctr.value;
    }
    try {
      var result = await methodChannel.invokeMethod(
          methodName, <String, dynamic>{'data': data, "algoType": algoType});
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('${e.message}');
      }
      return '';
    }
  }

  @override
  Future<String?> uniqueAnnotationId() async {
    try {
      var result = await methodChannel.invokeMethod("uniqueAnnotationId");
      return result;
    } on PlatformException catch (_) {
      return '';
    }
  }
  @override
  Future<String?> uniqueDeviceId() async {
    try {
      var result = await methodChannel.invokeMethod("uniqueDeviceId");
      return result;
    } on PlatformException catch (_) {
      return '';
    }
  }
  @override
  Future<int> deviceSdkInt() async {
    try {
      var result = await methodChannel.invokeMethod("deviceSdkInt");
      return result;
    } on PlatformException catch (_) {
      return 0;
    }
  }
}
