import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import '../fixtures/fixture_reader.dart';

const TEST_MOCK_STORAGE = './test/fixtures';

class MockMethodChannel {
  setUpGetApplicationDocumentsDirectory() {
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
          return "$TEST_MOCK_STORAGE";
        default:
      }
    });
  }

  setAsitePluginsMethodChannel() {
    const MethodChannel('asite_plugins')
        .setMockMethodCallHandler((call) async {
          if(call.method.contains("uniqueAnnotationId")) {
            return "4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919";
          }
          if(call.method.contains("encrypt") || call.method.contains("decrypt")){
            return call.arguments["data"];
          } else {
            return fixture("user_data.json");
          }
        },);
  }

  setConnectivity() {
    const MethodChannel('dev.fluttercommunity.plus/connectivity')
        .setMockMethodCallHandler((call) async => "mobile");
  }

  setNotificationMethodChannel() {
    const MethodChannel('dexterous.com/flutter/local_notifications')
        .setMockMethodCallHandler((call) async => true);
  }

  setConnectivityMethodChannel() {
    const MethodChannel('dev.fluttercommunity.plus/connectivity')
        .setMockMethodCallHandler((call) async => '');
  }

  void setGetFreeSpaceMethodChannel() {
    const MethodChannel('storage_space')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getFreeSpace':
          return 3000000000;
        case 'getTotalSpace':
          return 4000000000;
      }
    });
  }

  setBuildFlavorMethodChannel(){
    const MethodChannel('build_flavor')
        .setMockMethodCallHandler((call) async => "QA");
  }

setUpCheckPermissionStatus() {
  const channel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'checkPermissionStatus':
        return 1;
      default:
    }
  });
}
  setgetapplabel() {
    const channel = MethodChannel(
      'flutter.native/getapplabel',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async => '');
  }

  setPermissionStatusMethodChannel({
    bool checkPermissionStatusGranted = true,
    bool requestPermissionsGranted = true,
    bool shouldShowRequestPermissionRationaleGranted = true
  }) {
    const MethodChannel('flutter.baseflow.com/permissions/methods')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch(methodCall.method){
        case "checkPermissionStatus":
          return checkPermissionStatusGranted ? 1: 0;
        case "requestPermissions":
          return {1: requestPermissionsGranted ? 1 : 0};
        case "shouldShowRequestPermissionRationale":
          return shouldShowRequestPermissionRationaleGranted;
        default:
      }
    });
  }

  setCurrentLocation() {
    const channel = MethodChannel(
      'lyokone/location',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async => Future(() => LocationData.fromMap({})));
  }
}