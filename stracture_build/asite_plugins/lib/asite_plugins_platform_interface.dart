import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'asite_plugins_method_channel.dart';

enum EncryptionAlgorithm {
  ecb(0),
  ctr(1);

  const EncryptionAlgorithm(this.value);

  final int value;
}

abstract class AsitePluginsPlatform extends PlatformInterface {
  /// Constructs a AsitePluginsPlatform.
  AsitePluginsPlatform() : super(token: _token);

  static final Object _token = Object();

  static AsitePluginsPlatform _instance = MethodChannelAsitePlugins();

  /// The default instance of [AsitePluginsPlatform] to use.
  ///
  /// Defaults to [MethodChannelAsitePlugins].
  static AsitePluginsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AsitePluginsPlatform] when
  /// they register themselves.
  static set instance(AsitePluginsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> decrypt(data, EncryptionAlgorithm algorithm) async {
    throw UnimplementedError('decrypt() has not been implemented.');
  }

  Future<String> encrypt(data, EncryptionAlgorithm algorithm) async {
    throw UnimplementedError('encrypt() has not been implemented.');
  }

  Future<String?> uniqueAnnotationId() async {
    throw UnimplementedError('getUniqueAnnotationId() has not been implemented.');
  }
  Future<String?> uniqueDeviceId() async {
    throw UnimplementedError('getUniqueDeviceId() has not been implemented.');
  }
}
