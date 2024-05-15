import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/qr/qr_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/navigation/field_navigator.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';
import '../utils/load_url.dart';
import 'mock_method_channel.dart';
import 'navigator_cubit_qr.dart';

class MockQrUseCase extends Mock implements QrUseCase {}
class MockFieldNavigatorCubit extends Mock implements FieldNavigatorCubit{}
class MockFieldNavigator extends Mock implements FieldNavigator {}
class MockProjectListCubit extends Mock implements ProjectListCubit{}
class DBServiceMock extends Mock implements DBService {}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockQrUseCase mockQrUseCase= MockQrUseCase();
  MockFieldNavigator fieldNavigator = MockFieldNavigator();
  MockProjectListCubit? projectListCubit;
  AConstants.adoddleUrl = 'https://adoddleqaak.asite.com/';
  DBServiceMock? mockDb;
  FieldNavigatorCubit fieldNavigatorCubit = FieldNavigatorCubit(
      qrUseCase: mockQrUseCase,
      objNavigator: fieldNavigator);

  configureDependencies() {
    di.init(test: true);
    fieldNavigatorCubit = MockFieldNavigatorCubit();
    di.getIt.unregister<FieldNavigatorCubit>();
    di.getIt.registerFactory<FieldNavigatorCubit>(() => fieldNavigatorCubit);
    di.getIt.unregister<QrUseCase>();
    di.getIt.registerLazySingleton<QrUseCase>(() => mockQrUseCase);
    projectListCubit = MockProjectListCubit();
    di.getIt.unregister<ProjectListCubit>();
    di.getIt.registerLazySingleton<ProjectListCubit>(() => projectListCubit!);
    fieldNavigator = MockFieldNavigator();
    di.getIt.unregister<FieldNavigator>();
    di.getIt.registerFactory<FieldNavigator>(() => fieldNavigator!);
    mockDb = DBServiceMock();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);

    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }
  tearDownAll(() => mockDb = null);
  setUpAll(()  {
    configureDependencies();
  });

  setUp(() {
    mockQrUseCase = MockQrUseCase();
    fieldNavigatorCubit = FieldNavigatorCubit(qrUseCase:mockQrUseCase,objNavigator:fieldNavigator);
  });

  group("Field Navigator Cubit:", () {
    var expectedError = FAIL<dynamic>('{"key":"do-not-have-permission-project","msg":"Unauthorized! You do not have permission to access this project. Please contact your Workspace Administrator."}', 601);

    test("Initial State", () {
        expect(FieldNavigatorCubit().state, isA<FlowState>());
    });

    blocTest<FieldNavigatorCubit, FlowState>(
      'emits [ErrorState] while check permission QR code',
      build: () => fieldNavigatorCubit,
      act: (cubit) async {
        Project projectVo = Project(projectID: "2089700",dcId: 1);
        when(() => projectListCubit!.getProjectDetailQr("2089700")).thenAnswer((_) => Future.value(projectVo));
        when(() => mockQrUseCase.checkQRCodePermission({"projectId":"2089700","dcId":1,"folderIds":"25047","generateQRCodeFor":"1"})).thenAnswer((_) => Future.value(expectedError));
          await cubit.checkQRCodePermission(QRCodeDataVo(
            qrCodeType: QRCodeType.qrLocation,
            projectId: "2089700",
            locationId: "0",
            folderId: "25047",
            parentLocationId: "0",
            parentFolderId: "105252969",
            revisionId: "0",
            instanceGroupId: null,
            dcId: null,
          ));
        },

      expect: () => [isA<LoadingState>(),isA<ErrorState>()],
    );

    blocTest<FieldNavigatorCubit, FlowState>(
      'emits Scan QR and Navigate to sitetask form',
      build: () => fieldNavigatorCubit,
      act: (cubit) async {
        final successObj = jsonDecode(fixture("object.json"));
        final successResult = SUCCESS(fixture("app_type_vo.json"), null, 200);
        QRCodeDataVo voObject = QRCodeDataVo(
            projectId: "2143261",
            dcId: 1,
            instanceGroupId: "10796415",
            qrCodeType: QRCodeType.qrFormType);
         when(() => mockQrUseCase.getFormPrivilege({"projectId":"2143261","dcId":1,"instanceGroupId": "10796415"})).thenAnswer((_) => Future.value(successResult));
        when(() => fieldNavigator.navigate(voObject, successResult)).thenAnswer((_) => Future.value(successObj));
         await cubit.getFormPrivilege(voObject);
      },
      expect: () => [isA<SuccessState>()]
    );

    blocTest<FieldNavigatorCubit, FlowState>(
        'emits Scan QR and Navigate to Plan',
        build: () => fieldNavigatorCubit,
        act: (cubit) async {
          final successObj = jsonDecode(fixture("navigate_to_plan_arg.json"));
          final successResult = SUCCESS(fixture("get_work_space_data.json"), null, 200);
          QRCodeDataVo voObject = QRCodeDataVo(
            projectId: "2100809",
            dcId: 1,
            folderId: "62705245",
            qrCodeType: QRCodeType.qrLocation,
            revisionId: "0",
            parentLocationId: "21716",
            parentFolderId: "",
            locationId: "21718",
            instanceGroupId: null,
          );

          when(() => mockQrUseCase.getFieldEnableSelectedProjectsAndLocations({
            "isfromfieldfolder" : "true",
            "projectId" : "2100809",
            "folder_id" : "62705245",
            "folderTypeId" : "1",
            "projectIds" : "2100809",
            "checkHashing" : "false",
            "dcId" : 1})).thenAnswer((_) => Future.value(successResult));
          when(() => fieldNavigator.navigate(voObject, successResult)).thenAnswer((_) => Future.value(successObj));
          await cubit.getFieldEnableSelectedProjectsAndLocations(voObject);
        },
        expect: () => [isA<SuccessState>()]
    );
  });
}
