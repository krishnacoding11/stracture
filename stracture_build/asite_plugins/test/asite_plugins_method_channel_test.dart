import 'package:asite_plugins/asite_plugins_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MethodChannelAsitePlugins platform = MethodChannelAsitePlugins();
  const MethodChannel channel = MethodChannel('asite_plugins');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await platform.getPlatformVersion(), '42');
  });
}
