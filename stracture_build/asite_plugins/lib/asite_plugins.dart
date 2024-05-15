import 'asite_plugins_platform_interface.dart';

class AsitePlugins {
  Future<String> encrypt(data, EncryptionAlgorithm algorithm) async {
    return AsitePluginsPlatform.instance.encrypt(data, algorithm);
  }

  Future<String> decrypt(data, EncryptionAlgorithm algorithm) async {
    return AsitePluginsPlatform.instance.decrypt(data, algorithm);
  }

  Future<String?> getUniqueAnnotationId() async {
    return await AsitePluginsPlatform.instance.uniqueAnnotationId();
  }

  Future<String?> getUniqueDeviceId() async {
    return await AsitePluginsPlatform.instance.uniqueDeviceId();
  }
}
