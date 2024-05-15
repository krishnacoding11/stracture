import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/remote/qr/qr_repository_impl.dart';
import 'package:field/domain/use_cases/qr/qr_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';
import '../../../utils/load_url.dart';

class MockQrRemoteRepository extends Mock implements QRRemoteRepository {}

class MockInternetCubit extends Mock implements InternetCubit {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.getIt.registerLazySingleton<MockQrRemoteRepository>(() => MockQrRemoteRepository());
  late QrUseCase qrUseCase, localQrUseCase;
  late MockQrRemoteRepository repository;
  final mockInternetCubit = MockInternetCubit();

  Map<String, dynamic> getWorkspaceMapData(projectId, folderId) {
    Map<String, dynamic> map = {};
    map["isfromfieldfolder"] = "true";
    map["projectId"] = projectId;
    map["folder_id"] = folderId;
    map["folderTypeId"] = "1";
    map["projectIds"] = projectId;
    map["checkHashing"] = "false";
    return map;
  }

  dynamic getVOFromResponse(dynamic response) {
    try {
      dynamic json = jsonDecode(response);
      var projectList = List<Project>.from(json.map((x) => Project.fromJson(x)));
      List<Project> outputList = projectList.where((o) => o.iProjectId == 0).toList();
      return outputList;
    } catch (error) {
      return null;
    }
    // return response;
  }

  setUpAll(() => () async {
        MockMethodChannel().setNotificationMethodChannel();
        MockMethodChannel().setConnectivityMethodChannel();
        MockMethodChannel().setAsitePluginsMethodChannel();
        MockMethodChannel().setUpGetApplicationDocumentsDirectory();
        await di.init(test: true);
        AppConfigTestData().setupAppConfigTestData();
      });

  setUp(() async {
    qrUseCase = QrUseCase();
    repository = di.getIt<MockQrRemoteRepository>();
    di.getIt.registerFactory<QRRemoteRepository>(() => repository);
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});
    AConstants.loadProperty();
    when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
  });

  tearDown(() {
    di.getIt.unregister<QRRemoteRepository>();
    di.getIt.unregister<InternetCubit>();
  });

  group("QR use case IsNetworkConnected=true:", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {"projectId": "123", "folderIds": "23456", "generateQRCodeFor": "1"};
      Map<String, dynamic> data = {"csrfToken": "shfuicheufhaj38972874837_aw9qr78="};
      when(
        () => repository.checkQRCodePermission(map),
      ).thenAnswer(
        (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await qrUseCase.checkQRCodePermission(map);
      expect(result, isA<Result>());
    });
    test("get Form Privilege IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {"projectId": "2089700", "instanceGroupId": "10443853", "dcId": 1};
      Map<String, dynamic> data = {"formTypeGroupList": "[]"};
      when(
        () => repository.getFormPrivilege(map),
      ).thenAnswer(
        (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await qrUseCase.getFormPrivilege(map);
      expect(result, isA<Result>());
    });

    test("get field enable selected project IsNetworkConnected=true", () async {
      Map<String, dynamic> map = getWorkspaceMapData("1234", "3545217");
      Map<String, dynamic> data = jsonDecode(fixture("project.json"));
      dynamic response = getVOFromResponse(data);
      when(
        () => repository.getFieldEnableSelectedProjectsAndLocations(map),
      ).thenAnswer(
        (_) async => Result<dynamic>(SUCCESS(response, Headers(), 200)),
      );
      final result = await qrUseCase.getFieldEnableSelectedProjectsAndLocations(map);
      expect(result, isA<Result>());
    });

    test("get locationDetails IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {"projectId": "2089700", "locationIds": "177849", "isObservationCountRequired": false};
      Map<String, dynamic> data = {"formTypeGroupList": "[]"};
      when(
        () => repository.getLocationDetails(map),
      ).thenAnswer(
        (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await qrUseCase.getLocationDetails(map);
      expect(result, isA<Result>());
    });
  });
}
