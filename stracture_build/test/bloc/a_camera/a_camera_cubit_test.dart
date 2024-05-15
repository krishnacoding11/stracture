import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/a_camera/a_camera_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import 'package:mocktail/mocktail.dart';

import '../mock_method_channel.dart';

class MockLocationService extends Mock implements Location{}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setCurrentLocation();
  di.init(test: true);
  late ACameraCubit aCameraCubit;
  MockLocationService locationService = new MockLocationService();

  setUp(() {
    aCameraCubit = ACameraCubit();
  });

  group("Camera cubit test", () {
    test("Initial state", () {
       expect(aCameraCubit.state, isA<FlowState>());
    });

    test("Fetch current location test", () async {
      await aCameraCubit.fetchCurrentLocation();
      when(() => locationService.serviceEnabled()).thenAnswer((_) => Future.value(true));
      when(() => locationService.requestPermission()).thenAnswer((_) => Future.value(PermissionStatus.granted));
      var locationData = LocationData.fromMap({'latitude':78.3434,'longitude':-122.347});
      expect(locationData, isInstanceOf<LocationData>());
    });

    blocTest<ACameraCubit, FlowState>(
        "test set camera type",
        build: () {
          return aCameraCubit;
        },
        act: (c) async {
          c.cameraType = true;
        },
        expect: () => [isA<ContentState>()]
    );

    blocTest<ACameraCubit, FlowState>(
        "test is picture taken or not",
        build: () {
          return aCameraCubit;
        },
        act: (c) async {
          c.isTakePicture = false;
        },
        expect: () => [isA<ContentState>()]
    );

    blocTest<ACameraCubit, FlowState>(
        "test capture image controller is null",
        build: () {
          return aCameraCubit;
        },
        act: (c) async {
          c.takePicture();
        },
        expect: () => [isA<ErrorState>()]
    );
  });
}
