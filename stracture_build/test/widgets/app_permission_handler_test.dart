import 'package:field/widgets/app_permission_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setPermissionStatusMethodChannel();

  late PermissionHandlerPermissionService permissionHandler;

  setUp(() async {
    permissionHandler = PermissionHandlerPermissionService();
  });

  group("test permissionHandlerPermissionService", () {
    test("test requestCameraPermission expected status granted", () async {
      PermissionStatus status = await permissionHandler.requestCameraPermission();
      expect(status, PermissionStatus.granted);
    });

    test("test requestPhotosPermission expected status denied", () async {
      PermissionStatus status = await permissionHandler.requestPhotosPermission();
      expect(status, PermissionStatus.denied);
    });

    test("test isDeniedCameraPermission expected false", () async {
      bool isDenied = await permissionHandler.isDeniedCameraPermission();
      expect(isDenied, false);
    });

    test("test isGrantedCameraPermission expected true", () async {
      bool isGranted = await permissionHandler.isGrantedCameraPermission();
      expect(isGranted, true);
    });

    test("test isDeniedStoragePermission expected false", () async {
      bool isDenied = await permissionHandler.isDeniedStoragePermission();
      expect(isDenied, false);
    });

    test("test isGrantedStoragePermission expected true", () async {
      bool isGranted = await permissionHandler.isGrantedStoragePermission();
      expect(isGranted, true);
    });

    test("test checkAndRequestCameraPermission with granted all permission expected true", () async {
      permissionHandler.checkAndRequestCameraPermission((bool isGranted) {
        expect(isGranted, true);
      });
    });

    test("test checkAndRequestCameraPermission with denied checkPermission and rationale permission expected true", () async {
      MockMethodChannel().setPermissionStatusMethodChannel(checkPermissionStatusGranted: false, shouldShowRequestPermissionRationaleGranted: false);

      permissionHandler.checkAndRequestCameraPermission((bool isGranted) {
        expect(isGranted, true);
      });
    });

    test("test checkAndRequestCameraPermission with denied all permission expected false", () async {
      MockMethodChannel().setPermissionStatusMethodChannel(checkPermissionStatusGranted: false, requestPermissionsGranted: false, shouldShowRequestPermissionRationaleGranted: false);

      permissionHandler.checkAndRequestCameraPermission((bool isGranted) {
        expect(isGranted, false);
      });
    });

    test("test checkAndRequestCameraPermission with denied checkPermission permission expected true", () async {
      MockMethodChannel().setPermissionStatusMethodChannel(checkPermissionStatusGranted: false);

      permissionHandler.checkAndRequestCameraPermission((bool isGranted) {
        expect(isGranted, true);
      });
    });

    test("test checkAndRequestCameraPermission with denied checkPermission permission expected true", () async {
      MockMethodChannel().setPermissionStatusMethodChannel(
          checkPermissionStatusGranted: false,
          requestPermissionsGranted: false
      );

      permissionHandler.checkAndRequestCameraPermission((bool isGranted) {
        expect(isGranted, false);
      });
    });

  });
}
