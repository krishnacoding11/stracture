import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/file_association_model.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/online_model_vewer_use_case.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/fixture_reader.dart';
import '../mock_method_channel.dart';

class MockOnlineModelViewerUseCase extends Mock implements OnlineModelViewerUseCase {}

class MockInternetCubit extends Mock implements InternetCubit {}

class MockWebViewController extends Mock implements InAppWebViewController {}

class MockOnlineModelViewerCubit extends MockCubit<OnlineModelViewerState> implements OnlineModelViewerCubit {}

class DBServiceMock extends Mock implements DBService {}

class MockModel extends Mock implements Model {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  final mockInternetCubit = MockInternetCubit();
  MockOnlineModelViewerCubit mockOnlineModelViewerCubit = MockOnlineModelViewerCubit();

  di.init(test: true);
  late OnlineModelViewerCubit onlineModelViewerCubit;
  MockOnlineModelViewerUseCase mockOnlineModelViewerUseCase = MockOnlineModelViewerUseCase();
  MockWebViewController mockWebViewController = MockWebViewController();
  List<IfcObjects> bimModelList = [];
  AppConfig appConfig = di.getIt<AppConfig>();
  late List<CalibrationDetails> calibList;
  setUpAll(() async {
    onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});
    appConfig.currentSelectedProject = jsonDecode(fixture("project.json"));
    when(() => mockOnlineModelViewerCubit.bimModelListData).thenReturn(['abc']);
    when(() => mockOnlineModelViewerCubit.offlineFilePath).thenReturn(['abc']);

    when(() => mockOnlineModelViewerCubit.webviewController).thenReturn(mockWebViewController);

    calibList = [
      CalibrationDetails(
        modelId: "model123",
        revisionId: "revision456",
        calibrationId: "calibration789",
        sizeOf2DFile: 1024 * 1024,
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
        sizeOf2DFile: 1024 * 1024,
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

  List<FileAssociation> sampleFileAssociations = [
    FileAssociation(
      revisionId: 'rev123',
      filename: 'file1.pdf',
      filepath: '/documents/file1.pdf',
      documentRevision: '1',
      publisherName: 'John Doe',
      publisherOrganization: 'Organization A',
      revisionCounter: 'A',
      projectId: 'project123',
      publishDate: '2023-08-01',
      documentTitle: 'Document 1',
      documentId: 'doc456',
      folderId: 'folder789',
      associatedDate: '2023-08-15',
      documentTypeId: 1,
      generateUri: true,
    ),
    FileAssociation(
      revisionId: 'rev456',
      filename: 'file2.docx',
      filepath: '/documents/file2.docx',
      documentRevision: '2',
      publisherName: 'Jane Smith',
      publisherOrganization: 'Organization B',
      revisionCounter: 'B',
      projectId: 'project456',
      publishDate: '2023-08-02',
      documentTitle: 'Document 2',
      documentId: 'doc789',
      folderId: 'folder012',
      associatedDate: '2023-08-16',
      documentTypeId: 2,
      generateUri: false,
    ),
    // Add more sample data entries as needed
  ];

  configurationDependencies() {
    di.getIt.unregister<InternetCubit>();
    di.getIt.unregister<OnlineModelViewerUseCase>();
    di.getIt.registerFactory<OnlineModelViewerUseCase>(() => mockOnlineModelViewerUseCase);
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    final popUpData = jsonDecode(fixture("bim_model.json"));
    for (var item in popUpData['BIMProjectModelVO']['ifcObject']['ifcObjects']) {
      bimModelList.add(IfcObjects.fromJson(item));
    }
  }

  group("Online model list cubit: ", ()
  {
    configurationDependencies();

    test("Initial state", () {
      expect(onlineModelViewerCubit.state, isA<PaginationListInitial>());
    });

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("toggle Cutting Plane Menu Visibility",
        build: () {
          onlineModelViewerCubit.isCuttingPlaneMenuVisible = !onlineModelViewerCubit.isCuttingPlaneMenuVisible;
          onlineModelViewerCubit.isMarkupMenuVisible = false;
          onlineModelViewerCubit.isEditMenuVisible = true;
          onlineModelViewerCubit.isRulerMenuVisible = false;
          onlineModelViewerCubit.isShowPdfView = false;
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.toggleCuttingPlaneMenuVisibility();
        },
        expect: () => [isA<MenuOptionLoadedState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("toggle All Menus Visibility",
        build: () {
          onlineModelViewerCubit.isEditMenuVisible = false;
          onlineModelViewerCubit.isMarkupMenuVisible = false;
          onlineModelViewerCubit.isRulerMenuVisible = false;
          onlineModelViewerCubit.isCuttingPlaneMenuVisible = false;
          onlineModelViewerCubit.isShowPdfView = false;

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.toggleAllMenusVisibility();
        },
        expect: () => [isA<MenuOptionLoadedState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("toggle Ruler Menu Visibility",
        build: () {
          onlineModelViewerCubit.isRulerMenuVisible = !onlineModelViewerCubit.isRulerMenuVisible;
          onlineModelViewerCubit.isMarkupMenuVisible = false;
          onlineModelViewerCubit.isCuttingPlaneMenuVisible = false;
          onlineModelViewerCubit.isEditMenuVisible = true;
          onlineModelViewerCubit.isShowPdfView = false;

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.toggleRulerMenuVisibility();
        },
        expect: () => [isA<MenuOptionLoadedState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("toggle Marker Menu Visibility",
        build: () {
          onlineModelViewerCubit.isEditMenuVisible = true;
          onlineModelViewerCubit.isMarkupMenuVisible = !onlineModelViewerCubit.isMarkupMenuVisible;
          onlineModelViewerCubit.isRulerMenuVisible = false;
          onlineModelViewerCubit.isCuttingPlaneMenuVisible = false;
          onlineModelViewerCubit.isShowPdfView = false;

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.toggleMarkerMenuVisibility();
        },
        expect: () => [isA<MenuOptionLoadedState>()]);
    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("toggle Edit Menu Visibility",
        build: () {
          onlineModelViewerCubit.isEditMenuVisible = !onlineModelViewerCubit.isEditMenuVisible;
          onlineModelViewerCubit.isMarkupMenuVisible = false;
          onlineModelViewerCubit.isRulerMenuVisible = false;
          onlineModelViewerCubit.isCuttingPlaneMenuVisible = false;
          onlineModelViewerCubit.isShowPdfView = false;

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.toggleEditMenuVisibility();
        },
        expect: () => [isA<MenuOptionLoadedState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("reset PdfTron Visibility",
        build: () {
          onlineModelViewerCubit.isShowPdfView = false;

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.resetPdfTronVisibility(false, "pdfName", false);
        },
        expect: () => [isA<MenuOptionLoadedState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("toggle PdfTron Visibility",
        build: () {
          onlineModelViewerCubit.isShowPdfView = false;

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.togglePdfTronVisibility(true, "pdfFileName", false, false);
        },
        expect: () => [isA<MenuOptionLoadedState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("calibList Present State",
        build: () {
          onlineModelViewerCubit.calibList = [];

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.calibListPresentState();
        },
        expect: () => [isA<CalibrationListPresentState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("get Model File Data",
        build: () {
          onlineModelViewerCubit.calibList = [];

          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.getModelFileData(bimModelList, "modelName");
        },
        expect: () => []);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("refresh UI",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.refreshUI(true);
        },
        expect: () => [isA<ShowPopUpState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("refresh UI",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

          await cubit.refreshUI(false);
        },
        expect: () => [isA<HIdePopUpState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("insufficient Storage",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          await cubit.insufficientStorage();
        },
        expect: () => [isA<InsufficientStorageState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("call ViewObject File Association Details",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          await cubit.callViewObjectFileAssociationDetails();
        },
        expect: () => [isA<ShowBackGroundWebviewState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("emit Normal Web State",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          await cubit.emitNormalWebState();
        },
        expect: () => [isA<NormalWebState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("emit Unit Calibration Update State",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          await cubit.emitUnitCalibrationUpdateState();
        },
        expect: () => [isA<UnitCalibrationUpdateState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test isModelTreeOpen",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          cubit.isModelTreeOpen = true;
        },
        expect: () => [isA<NormalState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test getCalibrationList method isPopup and isNetworkConnected false",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          cubit.offlineParams = {};
          cubit.offlineParams[RequestConstants.calibrateList] = calibList;
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
          cubit.getCalibrationList("222222", "33333", false);
        },
        expect: () => [isA<CalibrationListLoadingState>(), isA<CalibrationListResponseSuccessState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test getCalibrationList method isPopup and isNetworkConnected true",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          cubit.offlineParams = {};
          cubit.offlineParams[RequestConstants.calibrateList] = calibList;
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockOnlineModelViewerUseCase.getCalibrationList(any(), any())).thenAnswer((invocation) => Future.value(Result(jsonDecode(jsonEncode(calibList)))));
          var list = await cubit.getCalibrationList("222222", "33333", false);
        },
        expect: () => [isA<CalibrationListLoadingState>(), isA<CalibrationListResponseSuccessState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test getFileAssociation method ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() =>
              mockOnlineModelViewerUseCase.getFileAssociationList(
                any(),
              )).thenAnswer((invocation) => Future.value(SUCCESS(jsonDecode(jsonEncode(sampleFileAssociations)),Headers(), 200)));
           cubit.getFileAssociation("222222", "33333", "", "");
        },
        expect: () => [isA<FileAssociationLoadingState>(), isA<GetFileAssociationListState>()]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test loadModelOnline method ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          onlineModelViewerCubit.bimModelListData = ["1", "2"];
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          onlineModelViewerCubit.webviewController = mockWebViewController;
          when(() => mockWebViewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
          await cubit.loadModelOnline("222222", "33333", "",);
        },
        expect: () => [isA<LoadingState>(),]);

    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test loadModelOnline method isNetworkConnected false ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
          cubit.bimModelListData = ["1", "2"];
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
          onlineModelViewerCubit.webviewController = mockWebViewController;
          when(() => mockWebViewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
          when(() => mockWebViewController.addJavaScriptHandler(callback: any(named: "callback"),handlerName: any(named: "handlerName"))).thenReturn("");
          await cubit.loadModelOnline("222222", "33333", "",);
        },
        expect: () => [isA<LoadingState>(),]);





    test('returns correct request body for assign', () {
      final projectId = 'project123';
      final modelId = 'model456';
      final isAssign = true;
      final jsonDataForSaveColor = onlineModelViewerCubit.jsonDataForSaveColor = {'color': 'blue', 'value': 123};

      final result = onlineModelViewerCubit.getRequestBodyForSaveColor(
        projectId,
        modelId,
        isAssign,
      );

      expect(result, {
        'modelId': modelId,
        'projectId': projectId,
        'operation': 'assign',
        'jsonData': jsonDataForSaveColor.toString(),
      });
    });
    test('returns correct request map for Set Offline', () {
      final projectId = 'project123';
      final accessedValue = 'user1';
      final accessedType = 'Set Offline';
      final actionId = 'action456';
      final modelId = 'model789';
      final objectId = 'object012';

      final result = onlineModelViewerCubit.getRequestMapDataForAuditTrail(projectId, accessedValue, accessedType, actionId, modelId, objectId);

      expect(result, {
        'project_id': projectId,
        'model_id': modelId,
        'action_id': actionId,
      });
    });

    test("save color method", () async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockOnlineModelViewerUseCase.saveColor(any(), any())).thenAnswer((invocation) =>
          Future.value(Result([
            {"response:Success}"}
          ])));
      var result = await onlineModelViewerCubit.saveColor("222222", "33333", "0000", true);
      expect(result, isNot(Null));
    });

    test("setParallelViewAuditTrail method test", () async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockOnlineModelViewerUseCase.setParallelViewAuditTrail(any(), any())).thenAnswer((invocation) =>
          Future.value(Result([
            {"response:Success}"}
          ])));
      var result = onlineModelViewerCubit.setParallelViewAuditTrail("222222", "33333", "0000", "ddd", "0000", "ddd");
      expect(result, isA<Future<void>>());
    });

    test("test setNavigationSpeed method", () async {
      onlineModelViewerCubit.isModelLoaded = true;
      onlineModelViewerCubit.webviewController = mockWebViewController;
      when(() => mockWebViewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      onlineModelViewerCubit.setNavigationSpeed(newValue: 5.0);
    });

    test('test getColor method', () async {
      var data = [
        {
          "color": "#dd2828",
          "generateURI": true,
          "lastModifiedDate": "2023-08-29 06:55:43.96",
          "lastModifiedUserId": 2054614,
          "modelId": 46203,
          "operation": null,
          "uniqueId": "3\$QiCiRBTEaeIJhfzAK2tp",
          "uri": null,
        }
      ];
      onlineModelViewerCubit.webviewController = mockWebViewController;
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockOnlineModelViewerUseCase.getColor(any(), any())).thenAnswer((invocation) => Future.value(Result(data)));
      when(() => mockWebViewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());

      var result = await onlineModelViewerCubit.getColor("222222", "33333");

      expect(result, isNot(Null));
    });


    blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test PaginationListInitial State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(PaginationListInitial());
        },
        expect: () => [isA<PaginationListInitial>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test LoadingModelsState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(LoadingModelsState());
        },
        expect: () => [isA<LoadingModelsState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test LoadedModelState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(LoadedModelState());
        },
        expect: () => [isA<LoadedModelState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test DeletedModelState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(DeletedModelState());
        },
        expect: () => [isA<DeletedModelState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test WebGlContextLostState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(WebGlContextLostState());
        },
        expect: () => [isA<WebGlContextLostState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test FailedModelState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(FailedModelState());
        },
        expect: () => [isA<FailedModelState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test TimeoutWarningState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(TimeoutWarningState());
        },
        expect: () => [isA<TimeoutWarningState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test TimeOutState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(TimeOutState());
        },
        expect: () => [isA<TimeOutState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test JoyStickPositionState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(JoyStickPositionState());
        },
        expect: () => [isA<JoyStickPositionState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test WebsocketConnectionClosedState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(WebsocketConnectionClosedState());
        },
        expect: () => [isA<WebsocketConnectionClosedState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test ModelLoadFailureState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(ModelLoadFailureState());
        },
        expect: () => [isA<ModelLoadFailureState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test LoadedAllModelState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(LoadedAllModelState());
        },
        expect: () => [isA<LoadedAllModelState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test LoadedSuccessfulAllModelState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(LoadedSuccessfulAllModelState());
        },
        expect: () => [isA<LoadedSuccessfulAllModelState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test LoadedSuccessfullyState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(LoadedSuccessfullyState());
        },
        expect: () => [isA<LoadedSuccessfullyState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test GetJoystickCoordinatesState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(GetJoystickCoordinatesState("1","2"));
        },
        expect: () => [isA<GetJoystickCoordinatesState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test LoadedState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(LoadedState());
        },
        expect: () => [isA<LoadedState>(),]);

     blocTest<OnlineModelViewerCubit, OnlineModelViewerState>("Test ErrorState State ",
        build: () {
          return onlineModelViewerCubit = OnlineModelViewerCubit(onlineModelViewerUseCase: mockOnlineModelViewerUseCase);
        },
        act: (cubit) async {
         cubit.emit(ErrorState(exception: AppException(message: "")));
        },
        expect: () => [isA<ErrorState>(),]);

  });
}

Map<String, dynamic> getRequestMapDataForPopupPagination(page, limit, isFavourite, searchValue) {
  var startedFrom = (page == 0) ? 0 : (page * limit);
  Map<String, dynamic> map = {};
  map["recordBatchSize"] = "$limit";
  map["recordStartFrom"] = "$startedFrom";
  map["applicationId"] = 3;
  map["object_type"] = "PROJECT";
  map["object_attribute"] = "project_id";
  map["searchValue"] = searchValue;
  map["sortOrder"] = "desc";
  map["sortField"] = "name";
  if (isFavourite) {
    map["dataFor"] = 2;
  }
  return map;
}