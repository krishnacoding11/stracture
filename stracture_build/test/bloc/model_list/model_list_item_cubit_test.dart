import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_state.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/model_list_use_case/model_list_use_case.dart';
import 'package:field/domain/use_cases/online_model_vewer_use_case.dart';
import 'package:field/injection_container.dart' as container;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class MockModelListUseCase extends Mock implements ModelListUseCase {}

class MockModelListCubit extends Mock implements ModelListCubit {}

class MockDatabaseManager extends Mock implements DatabaseManager {}

class DBServiceMock extends Mock implements DBService {}

class MockInternetCubit extends Mock implements InternetCubit {}

class MockModel extends Mock implements Model {}

class MockOnlineModelViewerUseCase extends Mock implements OnlineModelViewerUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ModelListItemCubit itemCubit;
  MockModelListUseCase modelListUseCase = MockModelListUseCase();
  MockDatabaseManager mockDatabaseManager = MockDatabaseManager();
  MockOnlineModelViewerUseCase onlineMOdelViwerUseCase = MockOnlineModelViewerUseCase();
  late MockModelListCubit modelListCubit;
  List<CalibrationDetails> calibList = [];

  late List<BimModel> bimModel;
  DBServiceMock? mockDb;
  late List<FloorDetail> floorList;
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  final mockInternetCubit = MockInternetCubit();
  late Model mockModel;
  setUpAll(() {
    modelListUseCase = MockModelListUseCase();
    modelListCubit = MockModelListCubit();
    itemCubit = ModelListItemCubit();
    mockModel = Model.fromJson({
      "modelId": "46782\$\$z6im76",
      "bimModelId": "46782\$\$z6im76",
      "projectId": "2155366\$\$Hf0srP",
      "projectName": "CBIM_Data_Kajal",
      "bimModelName": "asiteBim_46782",
      "modelDescription": "Test",
      "userModelName": "Apartment A",
      "workPackageId": 2575343,
      "modelCreatorUserId": "2054614\$\$mnV9l3",
      "modelStatus": true,
      "modelCreationDate": "2023-07-19T14:30:13Z",
      "lastUpdateDate": "2023-07-19T14:30:13Z",
      "mergeLevel": 2,
      "isFavoriteModel": 0,
      "dc": "UK",
      "modelViewId": 0,
      "revisionId": "0\$\$1oecqO",
      "folderId": "0\$\$2okRIV",
      "revisionNumber": 0,
      "worksetId": "0\$\$S9js5P",
      "docId": "0\$\$Tew95s",
      "publisher": "kajal#patil#My Asite Organisation",
      "lastUpdatedUserId": "2054614\$\$mnV9l3",
      "lastUpdatedBy": "kajal#patil#My Asite Organisation",
      "lastAccessUserId": "2054614\$\$mnV9l3",
      "lastAccessBy": "kajal#patil#My Asite Organisation",
      "lastAccessModelDate": "2023-08-24T06:10:57Z",
      "modelTypeId": 0,
      "worksetdetails": null,
      "workingFolders": null,
      "generateURI": true,
      "setAsOffline": true,
      "isDropOpen": false,
      "isDownload": false,
      "fileSize": null,
      "modelSupportedOffline": true
    });
    floorList = [
      FloorDetail(
        fileName: 'sample.ifc',
        fileSize: 1024,
        floorNumber: 1,
        levelName: 'Ground Floor',
        isChecked: true,
        isDownloaded: true,
        isDeleteExpanded: false,
        revisionId: 1,
        bimModelId: '123',
        revName: 'Revision 1',
        projectId: 'project_123',
      ),
      FloorDetail(
        fileName: 'samplesss.ifc',
        fileSize: 1025,
        floorNumber: 2,
        levelName: 'Ground Floor',
        isChecked: true,
        isDownloaded: true,
        isDeleteExpanded: false,
        revisionId: 2,
        bimModelId: '123',
        revName: 'Revision 2',
        projectId: 'project_12312',
      ),
    ];
    bimModel = [
      BimModel(
        bimModelIdField: '123',
        name: 'Sample Model',
        fileName: 'sample.ifc',
        ifcName: 'Sample_IFC',
        revId: '1.0',
        isMerged: true,
        disciplineId: 1,
        isLink: false,
        filesize: 1024,
        folderId: 'folder_123',
        fileLocation: '/path/to/sample.ifc',
        isLastUploaded: true,
        bimIssueNumber: 2,
        hsfChecksum: 'abcd1234',
        isChecked: false,
        floorList: floorList,
        bimIssueNumberModel: 3,
        isDocAssociated: true,
        docTitle: 'Sample Document',
        publisherName: 'John Doe',
        orgName: 'Sample Organization',
        isDownloaded: true,
      ),
      BimModel(
        bimModelIdField: '123',
        name: 'Sample Model',
        fileName: 'sample.ifc',
        ifcName: 'Sample_IFC',
        revId: '1.0',
        isMerged: true,
        disciplineId: 1,
        isLink: false,
        filesize: 1024,
        folderId: 'folder_123',
        fileLocation: '/path/to/sample.ifc',
        isLastUploaded: true,
        bimIssueNumber: 2,
        hsfChecksum: 'abcd1234',
        isChecked: false,
        floorList: floorList,
        bimIssueNumberModel: 3,
        isDocAssociated: true,
        docTitle: 'Sample Document',
        publisherName: 'John Doe',
        orgName: 'Sample Organization',
        isDownloaded: true,
      )
    ];
    calibList = [
      CalibrationDetails(
        modelId: "model123",
        revisionId: "revision456",
        calibrationId: "calibration789",
        sizeOf2DFile: 1024,
        createdByUserid: "user123",
        calibratedBy: "calibrator456",
        createdDate: "2023-08-23",
        modifiedDate: "2023-08-24",
        point3D1: "3DPointA",
        point3D2: "3DPointB",
        point2D1: "2DPointA",
        point2D2: "2DPointB",
        depth: 10.5,
        fileName: "file123.txt",
        fileType: "txt",
        isChecked: true,
        documentId: "doc456",
        docRef: "ref789",
        folderPath: "/documents/files/",
        calibrationImageId: 123,
        pageWidth: 800,
        pageHeight: 600,
        pageRotation: 90,
        folderId: "folder789",
        calibrationName: "Calibration 1",
        generateUri: false,
        isDownloaded: true,
        projectId: "project456",
      ),
      CalibrationDetails(
        modelId: "model234",
        revisionId: "revision567",
        calibrationId: "calibration987",
        sizeOf2DFile: 2048,
        createdByUserid: "user234",
        calibratedBy: "calibrator567",
        createdDate: "2023-08-22",
        modifiedDate: "2023-08-25",
        point3D1: "3DPointX",
        point3D2: "3DPointY",
        point2D1: "2DPointX",
        point2D2: "2DPointY",
        depth: 8.2,
        fileName: "data456.csv",
        fileType: "csv",
        isChecked: false,
        documentId: "doc567",
        docRef: "ref123",
        folderPath: "/documents/data/",
        calibrationImageId: 456,
        pageWidth: 1200,
        pageHeight: 900,
        pageRotation: 180,
        folderId: "folder567",
        calibrationName: "Calibration 2",
        generateUri: true,
        isDownloaded: false,
        projectId: "project789",
      ),
    ];
    AppConfigTestData().setupAppConfigTestData();
    CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy", createdDate: "17-Jul-2023#10:52 WET", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2", depth: 3, fileName: "fileName", fileType: "fileType", isChecked: false, documentId: "documentId", docRef: "docRef", folderPath: "folderPath", calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId", calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
    calibList.add(calibrationDetails);
  });
  configureCubitDependencies() {
    mockDb = DBServiceMock();
    container.init(test: true);
    container.getIt.unregister<ModelListUseCase>();
    container.getIt.unregister<ModelListCubit>();
    container.getIt.unregister<OnlineModelViewerUseCase>();
    container.getIt.registerFactory<ModelListUseCase>(() => modelListUseCase);
    container.getIt.registerFactory<ModelListCubit>(() => modelListCubit);
    container.getIt.registerFactory<OnlineModelViewerUseCase>(() => onlineMOdelViwerUseCase);
    container.getIt.unregister<InternetCubit>();
    container.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    AConstants.loadProperty();
  }

  group("Location listing cubit:", () {
    configureCubitDependencies();
    test("Initial state", () {
      isA<ExpandedState>();
    });

    test("initializeVars method test", () {
      itemCubit.initializeVars(modelListCubit, [mockModel], mockModel, (String value) {});
      expect(itemCubit.modelListCubit, isNot(Null));
      expect(itemCubit.selectedProjectModelsList, isNot(Null));
      expect(itemCubit.model, isNot(Null));
      expect(itemCubit.onTap, isNot(Null));
    });

    blocTest<ModelListItemCubit, ModelListItemState>("download progress state",
        build: () {
          return itemCubit;
        },
        act: (cubit) async {
          cubit.downloadProgressState(75);
        },
        expect: () => [isA<DownloadedProgressState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("clear Wrong Check File",
        build: () {
          itemCubit.calibrationList = calibList;
          return itemCubit;
        },
        act: (cubit) async {
          when(() => modelListUseCase.sendModelRequestForOffline(any())).thenAnswer((_) => Future(() {
                return [];
              }));
          cubit.clearWrongCheckFile();
        },
        expect: () => []);

    blocTest<ModelListItemCubit, ModelListItemState>("get Downloaded pdf files",
        build: () {
          //itemCubit.calibrationList = calibList;
          return itemCubit;
        },
        act: (cubit) async {
          cubit.getDownloadedPdfFile("projectId", ['test1', 'tes2']);
        },
        expect: () => []);

    blocTest<ModelListItemCubit, ModelListItemState>("CalibrateFileLoadingState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.loadingCalibrate(true);
        },
        expect: () => [isA<CalibrateFileLoadingState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("fileChoppingState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.fileChoppingState();
        },
        expect: () => [isA<FileChoppingState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("loadingFavCheckState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.loadingFavCheckState();
        },
        expect: () => [isA<LoadingFavCheckState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("favCheckedState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.favCheckedState();
        },
        expect: () => [isA<FavCheckedState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("modelLoadingState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.modelLoadingState(ModelStatus.loading);
        },
        expect: () => [isA<ModelLoadingState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("modelLoadingState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.fileChoppedState();
        },
        expect: () => [isA<FileChoppedState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("unableChoppedState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.unableChoppedState();
        },
        expect: () => [isA<UnableChoppedState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("loadingFloor method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.loadingFloor(true);
        },
        expect: () => [isA<FloorFileLoadingState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("deletedSingleFloorState method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.model = mockModel;
            when(() => modelListUseCase.fetchFloorsByModelId(any())).thenAnswer((invocation) => Future.value(floorList));
            when(() => modelListUseCase.fetchCalibrateByModel(any())).thenAnswer((invocation) => Future.value(calibList));
           cubit.deletedSingleFloorState(true);
        },
        expect: () => [isA<SingleFloorDeletedState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("checkedFloor method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.checkedFloor(true, bimModel[0]);
        },
        expect: () => [isA<FloorCheckedState>(), isA<FloorCheckedState>()]);

    blocTest<ModelListItemCubit, ModelListItemState>("onCalibratedFileClick method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.onCalibratedFileClick(calibList);
        },
        expect: () => [
              isA<CalibrateFileCheckState>(),
            ]);

    blocTest<ModelListItemCubit, ModelListItemState>("onExpansionClick method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.onExpansionClick(true);
        },
        expect: () => [
              isA<ExpandedState>(),
            ]);

    blocTest<ModelListItemCubit, ModelListItemState>("onFloorExpansionClick method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.onFloorExpansionClick(true);
        },
        expect: () => [
              isA<FloorExpandedState>(),
            ]);

    blocTest<ModelListItemCubit, ModelListItemState>("onTabChange method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.onTabChange(true, "123456");
        },
        expect: () => [
              isA<TabChangeState>(),
            ]);

    blocTest<ModelListItemCubit, ModelListItemState>("sendModelOfflineRequest method test",
        build: () {
          return ModelListItemCubit();
        },
        act: (cubit) async {
          cubit.aProgressDialog = null;
          when(() => modelListUseCase.sendModelRequestForOffline(any())).thenAnswer((invocation) => Future.value("Response"));
          await cubit.sendModelOfflineRequest(bimModelId: "46782\$\$z6im76", projectId: "2155366\$\$Hf0srP");
        },
        expect: () => [isA<SendAdministratorState>()]);

    test("getFloorData method test online", () async {
      itemCubit.modelListCubit = modelListCubit;
      itemCubit.model = mockModel;
      when(() => modelListUseCase.getFloorList(any())).thenAnswer((invocation) => Future.value([FloorData(revisionId: 123, floorDetails: floorList)]));
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => modelListUseCase.fetchRevisionId(any())).thenAnswer((invocation) => Future.value(floorList));
      when(() => modelListUseCase.getDownloadedModelsPath(any(), any(), any(), any())).thenAnswer((invocation) => Future.value(["sample.ifc"]));
      var list = await itemCubit.getFloorData("222", bimModel: bimModel[0], isTest: true);
      expect(list.length, 2);
    });

    test("fetchCalibratedFile method test online", () async {
     ModelListItemCubit itemCubit = ModelListItemCubit();

      itemCubit.modelListCubit = modelListCubit;
      itemCubit.model = mockModel;
      when(() => onlineMOdelViwerUseCase.getCalibrationList(any(), any())).thenAnswer((invocation) => Future.value(
            Result(jsonDecode(jsonEncode(calibList))),
          ));
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
       when(() => modelListUseCase.floorSizeByModelId(any())).thenAnswer((invocation) => Future.value(2));
     await itemCubit.fetchCalibratedFile(bimModel[0].revId.toString().plainValue(),isTest:true);
      expect(itemCubit.calibrationList.length,3 );
    });
  });
}
