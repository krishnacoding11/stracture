import 'package:asite_plugins/asite_plugins.dart';
import 'package:asite_plugins/asite_plugins_method_channel.dart';
import 'package:asite_plugins/asite_plugins_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAsitePluginsPlatform
    with MockPlatformInterfaceMixin
    implements AsitePluginsPlatform {
  @override
  Future<String> decrypt(data, EncryptionAlgorithm algorithm) {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  Future<String> encrypt(data, EncryptionAlgorithm algorithm) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }

  @override
  Future<String?> uniqueAnnotationId() {
    // TODO: implement uniqueAnnotationId
    throw UnimplementedError();
  }

  @override
  Future<String?> uniqueDeviceId() {
    // TODO: implement uniqueDeviceId
    throw UnimplementedError();
  }

}

void main() {
  final AsitePluginsPlatform initialPlatform = AsitePluginsPlatform.instance;

  test('$MethodChannelAsitePlugins is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAsitePlugins>());
  });

  test('getPlatformVersion', () async {
    AsitePlugins asitePluginsPlugin = AsitePlugins();
    MockAsitePluginsPlatform fakePlatform = MockAsitePluginsPlatform();
    AsitePluginsPlatform.instance = fakePlatform;

    //expect(await asitePluginsPlugin.getPlatformVersion(), '42');
  });
}
