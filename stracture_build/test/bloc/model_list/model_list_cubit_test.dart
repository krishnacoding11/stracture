import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/bim_request_data.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/online_model_viewer_request_model.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/revision_data.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/model_list_use_case/model_list_use_case.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/actionIdConstants.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class MockModelListUseCase extends Mock implements ModelListUseCase {}

class MockProjectListUseCase extends Mock implements ProjectListUseCase {}

class DBServiceMock extends Mock implements DBService {}

class MockInternetCubit extends Mock implements InternetCubit {}

class MockModel extends Mock implements Model {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ModelListCubit modelListCubit;
  MockModelListUseCase mockModelListUseCase = MockModelListUseCase();
  MockProjectListUseCase mockProjectListUseCase = MockProjectListUseCase();
  MockMethodChannel().setNotificationMethodChannel();
  final mockInternetCubit = MockInternetCubit();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setAsitePluginsMethodChannel();
  late List<BimModel> bimModel;
  DBServiceMock? mockDb;
  List<Model> allItems = <Model>[];
  late List<FloorDetail> floorList;
  late List<CalibrationDetails> calibList;
  late Model mockModel;
  setUp(() {
    modelListCubit = ModelListCubit();
    mockModel = Model(
      modelId: '123123',
      bimModelId: '123132',
      projectId: '12313231',
      projectName: 'Sample Project',
      fileSize: '10 MB',
      downloadProgress: '50%',
      bimModelName: 'Sample BIM Model',
      modelDescription: 'This is a sample model.',
      userModelName: 'Sample User',
      workPackageId: 123,
      modelCreatorUserId: 'sampleCreatorUserId',
      modelStatus: true,
      modelCreationDate: '2023-08-11',
      lastUpdateDate: '2023-08-12',
      mergeLevel: 1,
      isFavoriteModel: 1,
      dc: 'sampleDC',
      modelViewId: 456,
      revisionId: 'sampleRevisionId',
      folderId: 'sampleFolderId',
      revisionNumber: 2,
      worksetId: 'sampleWorksetId',
      docId: 'sampleDocId',
      publisher: 'Sample Publisher',
      lastUpdatedUserId: 'sampleLastUpdatedUserId',
      lastUpdatedBy: 'Sample Last Updated By',
      lastAccessUserId: 'sampleLastAccessUserId',
      lastAccessBy: 'Sample Last Access By',
      lastAccessModelDate: '2023-08-13',
      modelTypeId: 789,
      generateUri: true,
      setAsOffline: true,
      isDropOpen: false,
      isDownload: true,
    );
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
  });

  configureCubitDependencies() {
    mockDb = DBServiceMock();
    init(test: true);
    getIt.unregister<ModelListUseCase>();
    getIt.registerFactory<ModelListUseCase>(() => mockModelListUseCase);
    getIt.unregister<InternetCubit>();
    getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    AppConfigTestData().setupAppConfigTestData();
    AConstants.loadProperty();
  }

  group("Model list", () {
    configureCubitDependencies();

    test("Initial state", () {
      isA<PaginationListInitial>();
    });

    blocTest<ModelListCubit, ModelListState>("Add Recent Project Search",
        build: () {
          return modelListCubit;
        },
        act: (cubit) async {
          cubit.addRecentModel(newSearch: "abed");
        },
        expect: () => []);

    blocTest<ModelListCubit, ModelListState>("get Recent Project Search",
        build: () {
          return modelListCubit;
        },
        act: (cubit) async {
          cubit.getRecentModel();
        },
        expect: () => []);

    blocTest<ModelListCubit, ModelListState>("emitPaginationListInitialState method test",
        build: () {
          return modelListCubit;
        },
        act: (cubit) async {
          cubit.emitPaginationListInitialState();
        },
        expect: () => [isA<PaginationListInitial>()]);

    test("get projectId method test", () async {
      String projectId = "1231231";
      when(() => mockModelListUseCase.getProjectFromProjectDetailsTable(any(), any())).thenAnswer((project) => Future.value(projectId));
      String tempId = await modelListCubit.getProjectId("2134298", false);
      expect(tempId, projectId);
    });

    test("selectedFloors method test", () async {
      expect(modelListCubit.selectedFloors, []);
    });

    test("checkFromLocalModel method test", () async {
      when(() => mockModelListUseCase.floorSizeByModelId(any())).thenAnswer((invocation) => Future.value(2));
      var model = await modelListCubit.checkFromLocalModel(mockModel);
      expect(mockModel, model);
      when(() => mockModelListUseCase.floorSizeByModelId(any())).thenAnswer((invocation) => Future.value(0));
      model = await modelListCubit.checkFromLocalModel(mockModel);
      expect(mockModel, model);
    });

    test("processChoppedFile method test", () async {
      when(() => mockModelListUseCase.processChoppedFile(any())).thenAnswer((invocation) => Future.value(Result(mockModel)));
      var result = await modelListCubit.processChoppedFile({});
      expect(result, isNot(Null));
    });

    test("addFloorData method test", () async {
      modelListCubit.addFloorData(floorList);
      expect(modelListCubit.floorListDB.length, floorList.length);
      modelListCubit.addFloorData(floorList);
      expect(modelListCubit.floorListDB, floorList);
    });

    test("addRemoveCaliList method test", () async {
      modelListCubit.addRemoveCaliList(calibList[0]);
      expect(modelListCubit.caliRemoveList.length, 1);
      modelListCubit.addRemoveCaliList(calibList[0]);
      expect(modelListCubit.caliRemoveList.length, 1);
      modelListCubit.addRemoveCaliList(calibList[1]);
      expect(modelListCubit.caliRemoveList.length, 2);
    });

    test("addRemoveList method test", () async {
      modelListCubit.addRemoveList(floorList[0]);
      expect(modelListCubit.removeList.length, 1);
      modelListCubit.addRemoveList(floorList[0]);
      expect(modelListCubit.removeList.length, 1);
      modelListCubit.addRemoveList(floorList[1]);
      expect(modelListCubit.removeList.length, 2);
    });

    test("dispose method test", () async {
      modelListCubit.dispose("");
      expect(modelListCubit.isAnyItemChecked, false);
    });

    test("getCurrentDate method test", () async {
      var date = modelListCubit.getCurrentDate();
      var dateNow = DateTime.now();
      final DateFormat formatter = DateFormat('dd-MMM-yyyy');
      expect(date, formatter.format(dateNow).toString());
    });

    test("deleteFiles method test", () async {
      Map<String, dynamic> params = {
        RequestConstants.projectId: mockModel.projectId,
        RequestConstants.revisionId: "123132",
        RequestConstants.floorList: floorList,
        RequestConstants.modelId: mockModel.modelId,
      };

      var deleted = await modelListCubit.deleteFiles(params);

      expect(deleted, false);
    });

    test("deleteFiles with floor list null method test", () async {
      Map<String, dynamic> params = {
        RequestConstants.projectId: mockModel.projectId,
        RequestConstants.revisionId: "123132",
        "fileName": "sample.ifc",
        RequestConstants.floorList: null,
        RequestConstants.modelId: mockModel.modelId,
      };

      var deleted = await modelListCubit.deleteFiles(params);

      expect(deleted, false);
    });

    test("addCalibratedList method test", () async {
      modelListCubit.addCalibratedList(calibList[0]);
      expect(modelListCubit.selectedCalibrate.length, 1);
      calibList[0].isChecked = false;
      modelListCubit.addCalibratedList(calibList[0]);
      expect(modelListCubit.selectedCalibrate.length, 0);
    });

    test(' getRequestMapDataForAuditTrail method test', () {
      final projectId = 'proj123';
      final remarks = 'Test remarks';
      final actionId = 1;
      final modelId = 'model456';
      final objectId = 'obj789';
      final revisionId = 'rev987';

      final expectedMap = {
        'project_id': projectId,
        'remarks': remarks,
        'action_id': actionId,
        'model_id': modelId,
        'objectId': objectId,
        'revision_id': revisionId,
      };

      final result = modelListCubit.getRequestMapDataForAuditTrail(
        projectId,
        remarks,
        actionId,
        modelId,
        objectId,
        revisionId,
      );

      expect(result, equals(expectedMap));
    });

    test('Test getFavouriteModelMapData with isFavorite 0', () {
      final project = Model(bimModelId: 'model123');
      final isFavorite = 0;

      final expectedMap = {
        'action_id': ActionConstants.actionId612,
        'model_id': project.bimModelId,
        'isFavorite': 1,
      };

      final result = modelListCubit.getFavouriteModelMapData(project, isFavorite);

      expect(result, equals(expectedMap));
    });

    test('Test getFavouriteModelMapData with isFavorite 1', () {
      final project = Model(bimModelId: 'model456');
      final isFavorite = 1;

      final expectedMap = {
        'action_id': ActionConstants.actionId612,
        'model_id': project.bimModelId,
        'isFavorite': 0,
      };

      final result = modelListCubit.getFavouriteModelMapData(project, isFavorite);

      expect(result, equals(expectedMap));
    });

    blocTest<ModelListCubit, ModelListState>("insertDownloadModelFileAuditTrail method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      when(() => mockModelListUseCase.setParallelViewAuditTrail(any(), any())).thenAnswer((project) => Future.value(""));
      await cubit.insertDownloadModelFileAuditTrail("1111", "1111", "1111", "1111", "1111", "1111", isItemForUpdate: false);
    }, expect: () {
      return [isA<ShowSnackBarState>()];
    });

    blocTest<ModelListCubit, ModelListState>("insertDownloadModelCalibrateFileAuditTrail method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      when(() => mockModelListUseCase.setParallelViewAuditTrail(any(), any())).thenAnswer((project) => Future.value(""));
      cubit.selectedCalibrate = calibList;
      cubit.selectedFloorList = {};
      await cubit.insertDownloadModelCalibrateFileAuditTrail("1111", "1111", "1111", "1111", "1111", "1111", isItemForUpdate: false);
    }, expect: () {
      return [isA<ShowSnackBarState>()];
    });

    blocTest<ModelListCubit, ModelListState>("calibratedItemSelect method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.calibratedItemSelect(calibList, true, calibList[0], mockModel);
    }, expect: () {
      return [];
    });

    blocTest<ModelListCubit, ModelListState>("changeDropdown method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      modelListCubit.allItems = [mockModel];
      cubit.changeDropdown(0);
    }, expect: () {
      return [isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("setSearchMode method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      modelListCubit.allItems = [mockModel];
      cubit.setSearchMode = SearchMode.suggested;
    }, expect: () {
      return [isA<SearchModelState>()];
    });

    blocTest<ModelListCubit, ModelListState>("emitDeleteModelListState method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.emitDeleteModelListState();
    }, expect: () {
      return [isA<ProjectLoadingState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("clearData method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      modelListCubit.allItems = [mockModel];
      cubit.clearData();
    }, expect: () {
      return [isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("toggleIsLoading method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.toggleIsLoading();
    }, expect: () {
      return [isA<ShowProgressBar>()];
    });

    blocTest<ModelListCubit, ModelListState>("localModelItemSort true method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.localModelItemSort(false);
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("localModelItemSort false method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.localModelItemSort(false);
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("getFavouriteModelsLocal false method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.getFavouriteModelsLocal();
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("getFavouriteModelsLocal true method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      modelListCubit.isFavorite = true;
      cubit.getFavouriteModelsLocal();
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("searchLocalModel method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.searchLocalModel("test");
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("itemDropdownClick method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      modelListCubit.allItems = [mockModel];
      cubit.itemDropdownClick(0);
    }, expect: () {
      return [isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("itemDropdownClick with cancel true method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      modelListCubit.allItems = [mockModel];
      when(() => mockModelListUseCase.fetchAllFloors(any())).thenAnswer((invocation) => Future.value(floorList));
      when(() => mockModelListUseCase.fetchAllCalibrates(any())).thenAnswer((invocation) => Future.value(calibList));
      cubit.itemDropdownClick(0, isCancel: true);
    }, expect: () {
      return [isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("allProjectState method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.allProjectState();
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("emitOpenButtonModelLoadingState method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.emitOpenButtonModelLoadingState(true);
    }, expect: () {
      return [isA<OpenButtonLoadingState>()];
    });

    blocTest<ModelListCubit, ModelListState>("emitAllModelSuccessState method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.emitAllModelSuccessState();
    }, expect: () {
      expect(modelListCubit.allItems, []);
      return [isA<AllModelSuccessState>()];
    });

    test('Test getRequestMapDataForModel', () {
      final projectID = 'proj123';
      final pageNumber = 1;
      final startedFrom = 0;
      final isFavoriteValue = 1;
      final modelName = 'Test Model';
      final expectedMap = {
        'projectId': projectID,
        'action_id': ActionConstants.actionId601,
        'recordStartFrom': startedFrom,
        'listingType': '47',
        'xhr': 'false',
        'active': true,
        'recordBatchSize': '50',
        'isFavorite': isFavoriteValue,
        'currentPageNo': pageNumber,
        'modelName': modelName,
        'favorite': 'true',
      };
      final result = modelListCubit.getRequestMapDataForModel(projectID, pageNumber, startedFrom, isFavoriteValue, modelName);
      expect(result, equals(expectedMap));
    });

    test('Test getFilteredListByModelName', () {
      final modelName = 'Filter Model';
      final favValue = 0;
      final expectedMap = {
        'favorite': 'false',
        'modelName': modelName,
        'sortOrder': 'asc',
        'sortField': 'userModelName',
      };

      final result = modelListCubit.getFilteredListByModelName(modelName, favValue);
      expect(result, equals(expectedMap));
    });

    test('Test getRequestSortedMapDataForModel', () {
      final projectID = 'proj456';
      final sortOrder = 'asc';
      final startedFrom = 0;
      final modelName = 'Sorted Model';

      final expectedMap = {
        'recordStartFrom': startedFrom,
        'recordBatchSize': '50',
        'sortOrder': sortOrder,
        'sortField': 'userModelName',
        'sortFieldType': 'text',
        'favorite': 'false',
        'modelName': modelName,
        'isFavorite': "0",
      };

      final result = modelListCubit.getRequestSortedMapDataForModel(
        projectID,
        sortOrder,
        startedFrom,
        modelName,
      );
      expect(result, equals(expectedMap));
    });

    test('Test setFloorData', () {
      modelListCubit.setFloorData(bimModel[0], true, mockModel);
      expect(modelListCubit.selectedFloorList.isEmpty, false);
      modelListCubit.setFloorData(bimModel[0], true, mockModel);
      expect(modelListCubit.selectedFloorList.isEmpty, true);
    });

    blocTest<ModelListCubit, ModelListState>("dropdownStateEmit method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.dropdownStateEmit(true, true);
    }, expect: () {
      expect(modelListCubit.isOpened, true);
      expect(modelListCubit.isUpdated, true);
      return [isA<DropdownOpenState>()];
    });

    blocTest<ModelListCubit, ModelListState>("toggleColor method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      cubit.toggleColor(OnlineViewerModelRequestModel(isSelectedModel: true));
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    test('Test buildBimRequestBody', () {
      final index = 0;
      final selectedProjectModelsList = [
        Model(
          bimModelId: 'model123',
          bimModelName: 'Test Model',
          userModelName: 'userModel123',
          projectId: 'proj456',
        ),
      ];
      final selectedProject = Project(projectID: 'proj456');

      final expectedRequestBody = BimProjectModelRequestModel(
        actionId: ActionConstants.actionId714,
        modelId: selectedProjectModelsList[index].bimModelId,
        projectId: selectedProject.projectID,
        modelName: selectedProjectModelsList[index].bimModelName,
        modelVersionID: ActionConstants.modelVersionId,
        fileName: selectedProjectModelsList[index].userModelName.toString(),
      );

      final result = modelListCubit.buildBimRequestBody(index, selectedProjectModelsList, selectedProject);

      expect(result, equals(expectedRequestBody));
    });

    test('Test addUpdateFavouriteDataList with isFavorite 0', () {
      final model = Model(
        bimModelId: 'model456',
        bimModelName: 'Another Model',
        userModelName: 'userModel456',
        isFavoriteModel: 0,
      );
      final isFavorite = 0;

      final allItems = [
        Model(
          bimModelId: 'model123',
          bimModelName: 'Test Model',
          userModelName: 'userModel123',
          isFavoriteModel: 1,
        ),
        Model(
          bimModelId: 'model456',
          bimModelName: 'Another Model',
          userModelName: 'userModel456',
          isFavoriteModel: 0,
        ),
        // Add more items to the list as needed
      ];

      final favItems = [
        Model(
          bimModelId: 'model123',
          bimModelName: 'Test Model',
          userModelName: 'userModel123',
          isFavoriteModel: 1,
        ),
        // Add more items to the list as needed
      ];

      modelListCubit.addUpdateFavouriteDataList(model, isFavorite);

      expect(model.isFavoriteModel, equals(isFavorite));
      expect(allItems.firstWhere((element) => element.bimModelId == model.bimModelId).isFavoriteModel, equals(0));
      expect(favItems.length, equals(1));
      expect(favItems.any((element) => element.bimModelId == model.bimModelId), isFalse);
    });

    test('Test addUpdateFavouriteDataList with isFavorite 1', () {
      final model = Model(
        bimModelId: 'model456',
        bimModelName: 'Another Model',
        userModelName: 'userModel456',
        isFavoriteModel: 0,
      );
      final isFavorite = 1;

      final allItems = [
        Model(
          bimModelId: 'model123',
          bimModelName: 'Test Model',
          userModelName: 'userModel123',
          isFavoriteModel: 1,
        ),
        Model(
          bimModelId: 'model456',
          bimModelName: 'Another Model',
          userModelName: 'userModel456',
          isFavoriteModel: 0,
        ),
        // Add more items to the list as needed
      ];

      final favItems = [
        Model(
          bimModelId: 'model123',
          bimModelName: 'Test Model',
          userModelName: 'userModel123',
          isFavoriteModel: 1,
        ),
        // Add more items to the list as needed
      ];

      modelListCubit.addUpdateFavouriteDataList(model, isFavorite);
      expect(model.isFavoriteModel, equals(isFavorite));
      expect(allItems.firstWhere((element) => element.bimModelId == model.bimModelId).isFavoriteModel, equals(0));
      expect(favItems.any((element) => element.bimModelId == model.bimModelId), isFalse);
    });

    test('Test favouriteModel ', () async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockModelListUseCase.addModelAsFav(any(), any())).thenAnswer((invocation) => Future.value(
            FAIL("failed", 401),
          ));
      await modelListCubit.favouriteModel(mockModel, 1);
      expect(mockModel.isFavoriteModel, 0);
    });

    test('Test getSuggestedSearchModelList ', () async {
      when(() => mockModelListUseCase.getModelListFromServer(any(), any())).thenAnswer((invocation) => Future.value([mockModel]));
      var model = await modelListCubit.getSuggestedSearchModelList(1, true, true, "searchValue", "22666", 0, true, "Asc", "modelname");
      expect(model.length, 0);
    });

    blocTest<ModelListCubit, ModelListState>("getFilteredList method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockModelListUseCase.getFilteredList(any(), any(), any())).thenAnswer((invocation) => Future.value([mockModel]));
      when(() => mockModelListUseCase.floorSizeByModelId(any())).thenAnswer((invocation) => Future.value(2));
      await cubit.getFilteredList(
        1,
        true,
        "searchValue",
        "22666",
        0,
      );
    }, expect: () {
      return [isA<ProjectLoadingState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("getFilteredList in offline method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
      when(() => mockModelListUseCase.getFilteredList(any(), any(), any())).thenAnswer((invocation) => Future.value([mockModel]));
      when(() => mockModelListUseCase.floorSizeByModelId(any())).thenAnswer((invocation) => Future.value(2));
      await cubit.getFilteredList(1, true, "searchValue", "22666", 0, isTest: true);
    }, expect: () {
      return [isA<ProjectLoadingState>(), isA<AllModelSuccessState>()];
    });

    test('Test fetchChoppedFileStatus ', () async {
      var data = [
        {"revisionId": 26845231, "status": "Completed"},
        {"revisionId": 26845232, "status": "Completed"},
      ];
      when(() => mockModelListUseCase.getChoppedStatus(any())).thenAnswer((invocation) => Future.value(Result(data, responseCode: 200)));
      List<RevisionId> revIds = await modelListCubit.fetchChoppedFileStatus({});
      expect(revIds.length, 2);
    });

    test('Test fetchChoppedFileStatus status failed ', () async {
      var data = [
        {"revisionId": 26845231, "status": "Completed"},
        {"revisionId": 26845232, "status": "Completed"},
        {"revisionId": 26845232, "status": "Failed"},
      ];
      when(() => mockModelListUseCase.getChoppedStatus(any())).thenAnswer((invocation) => Future.value(Result(data, responseCode: 500)));
      when(() => mockModelListUseCase.processChoppedFile(any())).thenAnswer((invocation) => Future.value(Result(data, responseCode: 200)));
      List<RevisionId> revIds = await modelListCubit.fetchChoppedFileStatus({});
      expect(revIds.length, 0);
    });

    test('Test fetchChoppedFileStatusOnDrop ', () async {
      var data = [
        {"revisionId": 26845231, "status": "Completed"},
        {"revisionId": 26845232, "status": "Completed"},
      ];
      when(() => mockModelListUseCase.getChoppedStatus(any())).thenAnswer((invocation) => Future.value(Result(data, responseCode: 200)));
      List<RevisionId> revIds = await modelListCubit.fetchChoppedFileStatusOnDrop({});
      expect(revIds.length, 2);
    });

    blocTest<ModelListCubit, ModelListState>("pageFetch method test", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockModelListUseCase.getModelListFromServer(
            any(),
            any(),
          )).thenAnswer((invocation) => Future.value([mockModel]));
      await cubit.pageFetch(1, true, false, "", "project", 0, false, "asc", "model");
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("pageFetch method offline tests", build: () {
      return modelListCubit;
    }, act: (cubit) async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
      when(() => mockModelListUseCase.getModelListFromServer(
            any(),
            any(),
          )).thenAnswer((invocation) => Future.value([mockModel]));
      await cubit.pageFetch(1, true, false, "", "project", 0, false, "asc", "model", isTest: true);
    }, expect: () {
      return [isA<LoadingModelState>(), isA<AllModelSuccessState>()];
    });

    blocTest<ModelListCubit, ModelListState>("Fetch models list",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          when(() => mockModelListUseCase.getModelListFromServer(any(), any())).thenAnswer((_) => Future(() {
                return [];
              }));

          await cubit.pageFetch(0, false, false, "", "2134298\$\$4Dizau", 0, true, "aesc", "");
        },
        expect: () => [isA<ProjectLoadingState>(), isA<AllModelSuccessState>()]);
    blocTest<ModelListCubit, ModelListState>("Fetch Filtered list",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockModelListUseCase.getFilteredList(any(), any(), any())).thenAnswer((_) => Future(() {
                return [];
              }));
          await cubit.getFilteredList(0, false, "2134298\$\$4Dizau", "asiteBim_46312", 0);
        },
        expect: () => [isA<AllModelSuccessState>()]);

    blocTest<ModelListCubit, ModelListState>("Fetch favourite list",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockModelListUseCase.addModelAsFav(any(), any())).thenAnswer((_) => Future(() {
                return allItems;
              }));
          await cubit.favouriteModel(mockModel, 1);
        },
        expect: () => []);

    blocTest<ModelListCubit, ModelListState>("Fetch search list",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockModelListUseCase.getModelListFromServer(any(), any())).thenAnswer((_) => Future(() {
                return allItems;
              }));
          //int offset, bool isFavourite, bool isRefreshing, String searchValue,
          //String projectId, int isFavoriteValue,
          //bool isSorting, String sortOrder, String modelName
          await cubit.getSuggestedSearchModelList(0, false, false, "", "2134298\$\$4Dizau", 0, true, "aesc", "");
        },
        expect: () => []);

    blocTest<ModelListCubit, ModelListState>("insert DownloadModel File AuditTrail",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockModelListUseCase.setParallelViewAuditTrail(any(), any())).thenAnswer((_) => Future(() {
                return allItems;
              }));
          //String projectId, String remarks, String actionId, String modelId, String objectId,
          // String revisionId, {required bool isItemForUpdate}
          await cubit.insertDownloadModelFileAuditTrail(isItemForUpdate: true, "projectId", "remark", "Actionid", "ModelId", "objectId", "revisionId");
        },
        expect: () => [isA<ShowSnackBarState>()]);

    blocTest<ModelListCubit, ModelListState>("insert DownloadModel calibration File AuditTrail",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockModelListUseCase.setParallelViewAuditTrail(any(), any())).thenAnswer((_) => Future(() {
                return allItems;
              }));
          //String projectId, String remarks, String actionId, String modelId, String objectId,
          // String revisionId, {required bool isItemForUpdate}
          await cubit.insertDownloadModelCalibrateFileAuditTrail(isItemForUpdate: true, "projectId", "remark", "Actionid", "ModelId", "objectId", "revisionId");
        },
        expect: () => []);



    blocTest<ModelListCubit, ModelListState>("EmptyErrorState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(EmptyErrorState());
           },
        expect: () => [isA<EmptyErrorState>()]);


    blocTest<ModelListCubit, ModelListState>("ErrorState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(ErrorState(exception: AppException(message: "error")));
           },
        expect: () => [isA<ErrorState>()]);

    blocTest<ModelListCubit, ModelListState>("FavProjectSuccessState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(FavProjectSuccessState(items: allItems));
           },
        expect: () => [isA<FavProjectSuccessState>()]);


    blocTest<ModelListCubit, ModelListState>("DownloadModelState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(DownloadModelState(items: allItems,isItemForUpdate: true,totalSize: 100,downloadStart: true,progressValue: 15,totalModelSize: 1500));
           },
        expect: () => [isA<DownloadModelState>()]);


    blocTest<ModelListCubit, ModelListState>("ItemCheckedState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(ItemCheckedState(items: allItems,));
           },
        expect: () => [isA<ItemCheckedState>()]);

    blocTest<ModelListCubit, ModelListState>("LoadedState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(LoadedState());
           },
        expect: () => [isA<LoadedState>()]);

    blocTest<ModelListCubit, ModelListState>("ShowDetailsState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(ShowDetailsState(true,allItems,"200","200",true));
           },
        expect: () => [isA<ShowDetailsState>()]);

    blocTest<ModelListCubit, ModelListState>("RefreshingState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(RefreshingState());
           },
        expect: () => [isA<RefreshingState>()]);

    blocTest<ModelListCubit, ModelListState>("RefreshingState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(PaginationListInitial());
           },
        expect: () => [isA<PaginationListInitial>()]);


    blocTest<ModelListCubit, ModelListState>("ShowSnackBarInQueueState method test",
        build: () {
          return modelListCubit = ModelListCubit(modelListUseCase: mockModelListUseCase, projectListUseCase: mockProjectListUseCase);
        },
        act: (cubit) async {
              cubit.emit(ShowSnackBarInQueueState(items: allItems));
           },
        expect: () => [isA<ShowSnackBarInQueueState>()]);

  });
}
