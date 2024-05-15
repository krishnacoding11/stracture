import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart';
import 'package:field/pdftron/pdftron_document_view.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class MockPdftronDocumentViewController extends Mock implements PdftronDocumentViewController {}

class MockInAppWebViewController extends Mock implements InAppWebViewController {}

class MockScrollController extends Mock implements ScrollController {}

class DBServiceMock extends Mock implements DBService {}

class MockDownloadPdfFile extends Mock implements DownloadPdfFile {}

void main() {
  late PdfTronCubit pdfTronCubit;
  DBServiceMock? mockDb;
  late MockPdftronDocumentViewController mockPdftronDocumentViewController;
  late MockInAppWebViewController mockWebviewController;
  late MockScrollController mockScrollController;
  late MockDownloadPdfFile mockDownloadPdfFile;
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setAsitePluginsMethodChannel();

  List<CalibrationDetails> calibList = [
    CalibrationDetails.fromJson({
      "modelId": "46288\$\$JYjB69",
      "revisionId": "26991926\$\$QWzoAp",
      "calibrationId": "859\$\$fKJbka",
      "sizeOf2dFile": 194,
      "createdByUserid": "2054614\$\$euhSdp",
      "calibratedBy": "kajal",
      "createdDate": "14-Jul-2023#17:43 WET",
      "modifiedDate": "14-Jul-2023#17:43 WET",
      "point3d1": "{\"x\":-13252.9026429976,\"y\":-12848.7658434939,\"z\":3800.000106018972}",
      "point3d2": "{\"x\":53582.0973576951,\"y\":-12848.7658434939,\"z\":3800}",
      "point2d1": "{\"x\":490.725,\"y\":851,\"z\":1}",
      "point2d2": "{\"x\":500.55,\"y\":2737.4,\"z\":1}",
      "depth": 1947.08592145,
      "fileName": "Hospital_00_Floor_1_Ver2_Ver1_Ver1.pdf",
      "fileType": "pdf",
      "documentId": "13490764\$\$gsEoUS",
      "docRef": "Hospital_00_Floor_1_Ver2_Ver1_Ver1",
      "folderPath": "CBIM_Data_Kajal\\cBIM Test Data A\\Hospital A",
      "calibrationImageId": 859,
      "pageWidth": 3370.0,
      "pageHeight": 2384.0,
      "pageRotation": 270.0,
      "folderId": "115421471\$\$mLTmOE",
      "calibrationName": "Ground floor 00",
      "generateURI": true,
      "isChecked": false,
      "isDownloaded": false,
      "projectId": ""
    }),
    CalibrationDetails.fromJson({
      "modelId": "46288\$\$JYjB69",
      "revisionId": "26991930\$\$RJHPB8",
      "calibrationId": "1025\$\$aQUU93",
      "sizeOf2dFile": 178,
      "createdByUserid": "2054614\$\$euhSdp",
      "calibratedBy": "kajal",
      "createdDate": "12-Aug-2023#10:34 WET",
      "modifiedDate": "12-Aug-2023#10:34 WET",
      "point3d1": "{\"x\":-13397.9026416122,\"y\":40715.2814181994,\"z\":45700}",
      "point3d2": "{\"x\":-12765.4026416122,\"y\":30513.599677946077,\"z\":45700}",
      "point2d1": "{\"x\":2040.4,\"y\":834.9249999999997,\"z\":1}",
      "point2d2": "{\"x\":1729.95,\"y\":839.7249999999999,\"z\":1}",
      "depth": 43950.0,
      "fileName": "Hospital_13th Floor_Ver1_Ver1_Ver1.pdf",
      "fileType": "pdf",
      "documentId": "13490768\$\$FjQMzx",
      "docRef": "Hospital_13th Floor_Ver1_Ver1_Ver1",
      "folderPath": "CBIM_Data_Kajal\\cBIM Test Data A\\Hospital A",
      "calibrationImageId": 1025,
      "pageWidth": 3370.0,
      "pageHeight": 2384.0,
      "pageRotation": 270.0,
      "folderId": "115421471\$\$mLTmOE",
      "calibrationName": "Login User A and open the Hospital A model from model tab and create calibration for the 13th floor. This is the 13 th floor 13",
      "generateURI": true,
      "isChecked": false,
      "isDownloaded": false,
      "projectId": ""
    }),
  ];

  configureLoginCubitDependencies() {
    mockDb = DBServiceMock();
    init(test: true);
    getIt.unregister<PdfTronCubit>();
    getIt.unregister<DBService>();
    getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    getIt.registerLazySingleton<PdfTronCubit>(() => pdfTronCubit);
    AConstants.loadProperty();
  }

  setUp(() {
    mockPdftronDocumentViewController = MockPdftronDocumentViewController();
    mockWebviewController = MockInAppWebViewController();
    mockScrollController = MockScrollController();
    mockDownloadPdfFile = MockDownloadPdfFile();

    pdfTronCubit = PdfTronCubit();
    pdfTronCubit.pdftronDocumentViewController = mockPdftronDocumentViewController;
    pdfTronCubit.webviewController = mockWebviewController;
  });

  tearDown(() {
    pdfTronCubit.close();
  });

  group('PdfTronCubit', () {
    configureLoginCubitDependencies();
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json")});

    blocTest<PdfTronCubit, PdfTronState>(
      'togglePdfTronFullViewVisibility method test',
      build: () => pdfTronCubit,
      act: (cubit) async {
        when(() => mockPdftronDocumentViewController.requestResetRenderingPdftron()).thenAnswer((invocation) => Future.value());
        await cubit.togglePdfTronFullViewVisibility(isTest: true);
      },
      expect: () => [isA<FullPdfTronVIew>(), isA<PDFDownloaded>()],
    );

    blocTest<PdfTronCubit, PdfTronState>(
      'resetPdfTronFullViewVisibility method test',
      build: () => pdfTronCubit,
      act: (cubit) async {
        when(() => mockPdftronDocumentViewController.requestResetRenderingPdftron()).thenAnswer((invocation) => Future.value());
        await cubit.resetPdfTronFullViewVisibility(isTest: true);
      },
      expect: () => [isA<FullPdfTronVIew>(), isA<PDFDownloaded>()],
    );

    blocTest<PdfTronCubit, PdfTronState>(
      'toggleScrollController method bloc test',
      build: () => pdfTronCubit,
      act: (cubit) async {
        when(() => mockScrollController.hasClients).thenReturn(false);
        await cubit.toggleScrollController(mockScrollController);
      },
      expect: () => [
        isA<FullPdfTronVIew>(),
      ],
    );

    blocTest<PdfTronCubit, PdfTronState>('emits PDFDownloading and PDFDownloaded states when downloadPdf is called',
        build: () => pdfTronCubit,
        act: (cubit) async {
          DownloadResponse downloadResponse = DownloadResponse(true, "test", null);
          Map<String, dynamic> map = {};

          /// Temp values
          map[RequestConstants.projectId] = "20202020";
          map[RequestConstants.folderId] = "21";
          map[RequestConstants.revisionId] = "20202020";
          when(() => mockDownloadPdfFile.downloadPdf(map)).thenAnswer((project) => Future.value(downloadResponse));

          await cubit.downloadPdf(map);
        },
        expect: () => [isA<PDFDownloading>()],
        tearDown: () => [isA<PDFDownloading>()]);

    blocTest<PdfTronCubit, PdfTronState>(
      'emits FilteredListState when onSearchTextChanged is called',
      build: () => pdfTronCubit,
      act: (cubit) {
        final searchString = 'sample'; // Replace with your search string
        cubit.onSearchTextChanged(searchString);
      },
      expect: () => [isA<PDFDownloading>(), isA<FilteredListState>()],
    );

    blocTest<PdfTronCubit, PdfTronState>(
      'emits FilteredListState when onSearchTextChanged is called empty',
      build: () => pdfTronCubit,
      act: (cubit) {
        final searchString = ''; // Replace with your search string
        cubit.onSearchTextChanged(searchString);
      },
      expect: () => [isA<PDFDownloading>(), isA<EmptyFilteredListState>()],
    );

    blocTest<PdfTronCubit, PdfTronState>(
      'Open document',
      build: () => pdfTronCubit,
      act: (cubit) {
        // Replace with your search string
        pdfTronCubit.pdftronDocumentViewController = mockPdftronDocumentViewController;
        when(() => mockPdftronDocumentViewController.openDocument(any())).thenAnswer((invocation) => Future.value());
        pdfTronCubit.pdfFile = File("testFile.pdf");
        cubit.openDocument();
      },
      expect: () => [],
    );

    blocTest<PdfTronCubit, PdfTronState>(
      'onCancelClick test',
      build: () => pdfTronCubit,
      act: (cubit) {
        cubit.onCancelClick();
      },
      expect: () => [isA<EmptyFilteredListState>(), isA<PDFDownloaded>()],
    );

    blocTest<PdfTronCubit, PdfTronState>(
      'errorStateEmit test',
      build: () => pdfTronCubit,
      act: (cubit) {
        cubit.errorStateEmit("test");
      },
      expect: () => [isA<ErrorState>()],
    );

    blocTest<PdfTronCubit, PdfTronState>(
      'MenuOptionLoadedState test',
      build: () => pdfTronCubit,
      act: (cubit) {
        cubit.emit(MenuOptionLoadedState(true, true, true, true, true, true, "true"));
      },
      expect: () => [isA<MenuOptionLoadedState>()],
    );
    blocTest<PdfTronCubit, PdfTronState>(
      'PaginationListInitial test',
      build: () => pdfTronCubit,
      act: (cubit) {
        cubit.emit(PaginationListInitial());
      },
      expect: () => [isA<PaginationListInitial>()],
    );

    test("updateMarker method test", () {
      when(() => mockWebviewController.addJavaScriptHandler(handlerName: any(named: "handlerName"), callback: any(named: "callback"))).thenReturn(null);
      pdfTronCubit.updateMarker();
    });

    test("updateCalibrationLocation method test", () {
      pdfTronCubit.pdfLoaded = true;
      pdfTronCubit.emit(PDFDownloaded());
      when(() => mockPdftronDocumentViewController.polygonAnnotation(
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((invocation) => Future.value());
      pdfTronCubit.updateCalibrationLocation();
    });

    test("newCalibrationData method test", () {
      pdfTronCubit.selectedCalibration = calibList.first;
      pdfTronCubit.pdfLoaded = true;
      pdfTronCubit.emit(PDFDownloaded());
      when(() => mockPdftronDocumentViewController.getZoom()).thenAnswer((invocation) => Future.value());
      when(() => mockPdftronDocumentViewController.requestResetRenderingPdftron()).thenAnswer((invocation) => Future.value());
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      pdfTronCubit.newCalibrationData();
    });

    test("onDocumentViewCreated method test", () {
      pdfTronCubit.selectedCalibration = calibList.first;
      pdfTronCubit.pdfLoaded = true;
      pdfTronCubit.pdfFile = File("testFile.pdf");
      pdfTronCubit.pdftronDocumentViewController = mockPdftronDocumentViewController;
      when(() => mockPdftronDocumentViewController.convertScreenPtToPagePt(any(), any())).thenAnswer((invocation) => Future.value());
      when(() => mockPdftronDocumentViewController.polygonAnnotation(any(), any(), any(), any())).thenAnswer((invocation) => Future.value());
      when(() => mockPdftronDocumentViewController.openDocument(any())).thenAnswer((invocation) => Future.value());
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      pdfTronCubit.onDocumentViewCreated(mockPdftronDocumentViewController);
    });
  });
}
