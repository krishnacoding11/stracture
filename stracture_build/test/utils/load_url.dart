import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockMethodChannelUrl{

  setupBuildFlavorMethodChannel() {
    const channel = MethodChannel(
      "build_flavor",
    );

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getFlavor':
          return "QA";
        default:
      }
    });
  }
}