import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart' as pdf_tron;
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:field/bloc/toolbar/model_tree_title_click_event_cubit.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/online_model_viewer_arguments.dart';
import 'package:field/data/model/online_model_viewer_request_model.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/online_model_viewer/online_model_viewer_screen.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';

class MockModelListCubit extends MockCubit<ModelListState> implements ModelListCubit {}

class MockOnlineModelViewerCubit extends MockCubit<online_model_viewer.OnlineModelViewerState> implements online_model_viewer.OnlineModelViewerCubit {}

class MockSideToolBarCubit extends MockCubit<FlowState> implements side_tool_bar.SideToolBarCubit {}

class MockModelListState extends MockCubit<ModelListState> implements ModelListState {}

class MockPdfTronCubit extends MockCubit<pdf_tron.PdfTronState> implements pdf_tron.PdfTronCubit {}

class MockModelTreeCubit extends MockCubit<ModelTreeState> implements ModelTreeCubit {}
class MockInAppWebViewController extends Mock implements InAppWebViewController {}
class MockModelTreeTitleClickEventCubit extends MockCubit<FlowState> implements ModelTreeTitleClickEventCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockInAppWebViewController mockWebviewController = MockInAppWebViewController();
  MockModelListCubit mockModelListCubit = MockModelListCubit();
  MockOnlineModelViewerCubit mockOnlineModelViewerCubit = MockOnlineModelViewerCubit();
  MockSideToolBarCubit mockSideToolBarCubit = MockSideToolBarCubit();
  MockPdfTronCubit mockPdfTronCubit = MockPdfTronCubit();
  MockModelTreeCubit mockModelTreeCubit = MockModelTreeCubit();
  MockModelTreeTitleClickEventCubit mockModelTreeTitleClickEventCubit = MockModelTreeTitleClickEventCubit();
  late OnlineModelViewerArguments onlineModelViewerArguments;
  Map<String, dynamic> offlineParams = {};

  configureLoginCubitDependencies() {
    init(test: true);
    getIt.unregister<ModelListCubit>();
    getIt.unregister<side_tool_bar.SideToolBarCubit>();
    getIt.unregister<pdf_tron.PdfTronCubit>();
    getIt.unregister<ModelTreeTitleClickEventCubit>();
    getIt.unregister<online_model_viewer.OnlineModelViewerCubit>();
    getIt.registerLazySingleton<ModelListCubit>(() => mockModelListCubit);
    getIt.registerLazySingleton<side_tool_bar.SideToolBarCubit>(() => mockSideToolBarCubit);
    getIt.registerLazySingleton<MockModelTreeCubit>(() => mockModelTreeCubit);
    getIt.registerLazySingleton<ModelTreeTitleClickEventCubit>(() => mockModelTreeTitleClickEventCubit);
    getIt.registerLazySingleton<online_model_viewer.OnlineModelViewerCubit>(() => mockOnlineModelViewerCubit);
    getIt.registerLazySingleton<pdf_tron.PdfTronCubit>(() => mockPdfTronCubit);
  }

  setUp(() async {
    when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
    when(() => mockModelTreeTitleClickEventCubit.state).thenReturn(ToolbarTitleClickEventState());
    when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
    when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
    when(() => mockOnlineModelViewerCubit.offlineFilePath).thenReturn([]);
    when(() => mockOnlineModelViewerCubit.bimModelListData).thenReturn([]);
    when(() => mockOnlineModelViewerCubit.calibrationList).thenReturn([]);
    when(() => mockOnlineModelViewerCubit.isDialogShowing).thenReturn(false);
    when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
    when(() => mockSideToolBarCubit.isRulerFirstSubMenuActive).thenReturn(true);
    when(() => mockSideToolBarCubit.isRulerThirdSubMenuActive).thenReturn(true);
    when(() => mockSideToolBarCubit.isRulerSecondSubMenuActive).thenReturn(true);
    when(() => mockSideToolBarCubit.isRulerMenuActive).thenReturn(true);
    when(() => mockSideToolBarCubit.isCuttingPlaneMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isCuttingPlaneSecondSubMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isCuttingPlaneThirdSubMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isCuttingPlaneFourthSubMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isCuttingPlaneFifthSubMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
    when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.totalNumbersOfModelsLoad).thenReturn('1');
    when(() => mockOnlineModelViewerCubit.totalNumbersOfModels).thenReturn('1');
    when(() => mockOnlineModelViewerCubit.selectedPdfFileName).thenReturn('');
    when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('');
    when(() => mockOnlineModelViewerCubit.key).thenReturn(GlobalKey<ScaffoldState>());
    when(() => mockModelListCubit.lastModelRequest).thenReturn(OnlineViewerModelRequestModel(modelId: "41568\$\$mWexLq", bimModelList: [], modelName: '0109 D', isSelectedModel: false));
    onlineModelViewerArguments = OnlineModelViewerArguments(projectId: "2134298\$\$4Dizau", isShowSideToolBar: false, onlineViewerModelRequestModel: mockModelListCubit.lastModelRequest!, offlineParams: {}, model: Model());
  });

  group('Online Model Viewer Screen', () {
    configureLoginCubitDependencies();

    Widget makeTestableWidget() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ModelListCubit>(
            create: (BuildContext context) => mockModelListCubit,
          ),
          BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
            create: (BuildContext context) => mockOnlineModelViewerCubit,
          ),
          BlocProvider<side_tool_bar.SideToolBarCubit>(
            create: (BuildContext context) => mockSideToolBarCubit,
          ),
          BlocProvider<pdf_tron.PdfTronCubit>(
            create: (BuildContext context) => mockPdfTronCubit,
          ),
          BlocProvider<ModelTreeCubit>(
            create: (BuildContext context) => mockModelTreeCubit,
          ),
          BlocProvider<ModelTreeTitleClickEventCubit>(
            create: (BuildContext context) => mockModelTreeTitleClickEventCubit,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: OnlineModelViewerScreen(
            onlineModelViewerArguments: onlineModelViewerArguments,
          ),
        ),
      );
    }

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.LoadingState());
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_ignore_pointer_animation')), findsOneWidget);
      expect(find.byKey(Key('key_animation_sized_box')), findsOneWidget);
      expect(find.byKey(Key('key_in_app_view')), findsOneWidget);
      expect(find.byKey(Key('key_empty_sized_box')), findsNothing);
    });

/*    testWidgets('Test key_online_mobile_sizBox ', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.LoadingState());
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      Utility.isPhone=true;
      Utility.isTablet=false;
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_online_mobile_sizBox')), findsOneWidget);
    });*/

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_visibility_three_hybrid_button')), findsOneWidget);
      expect(find.byKey(Key('key_row_three_hybrid_button')), findsOneWidget);
      expect(find.byKey(Key('key_container_three_button')), findsOneWidget);
      expect(find.byKey(Key('key_row_hybrid_button')), findsOneWidget);
      expect(find.byKey(Key('key_transform_rotate')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.HIdePopUpState());
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_web_view_flex')), findsOneWidget);
      expect(find.byKey(Key('key_web_view_stack')), findsOneWidget);
      expect(find.byKey(Key('key_side_tool_bar_visibility')), findsOneWidget);
      expect(find.byKey(Key('key_side_tool_bar_widget')), findsOneWidget);
      expect(find.byKey(Key('key_web_view_expanded')), findsOneWidget);
      expect(find.byKey(Key('key_web_view_ignore_pointer')), findsOneWidget);
      expect(find.byKey(Key('key_in_app_web_view')), findsOneWidget);
      expect(find.byKey(Key('key_positioned_widget')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.LoadingModelsState());
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_load_message_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_load_message_positioned_widget')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_load_message_text_widget')), findsNothing);
      expect(find.byKey(Key('key_load_message_positioned_widget')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn([]);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      List<dynamic> calibrationList = [];
      calibrationList.add('');
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: calibrationList));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      //expect(find.byKey(Key('key_widget_stack')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn([]);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      when(() => mockOnlineModelViewerCubit.webviewController).thenReturn(mockWebviewController);
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());

      await tester.pumpWidget(
        makeTestableWidget(),
      );

      expect(find.byKey(Key('key_container_widget')), findsNothing);
      expect(find.byKey(Key('key_calibList_list_view_widget')), findsNothing);
      expect(find.byKey(Key('key_container_widget_calib_list')), findsNothing);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      List<CalibrationDetails> calibList = [];
      CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy", createdDate: "17-Jul-2023#10:52 WET", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2", depth: 3, fileName: "fileName", fileType: "fileType", isChecked: false, documentId: "documentId", docRef: "docRef", folderPath: "folderPath", calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId", calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
      calibList.add(calibrationDetails);
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn(calibList);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.webviewController.evaluateJavascript(source: any())).thenAnswer((invocation) => Future.value());
      List<dynamic> calibSuccessList = [];
      calibSuccessList.add('testValue');
      when(() => mockOnlineModelViewerCubit.webviewController).thenReturn(mockWebviewController);
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      await tester.pumpWidget(
        makeTestableWidget(),
      );

      //expect(find.byKey(Key('key_container_widget')), findsOneWidget);
    //expect(find.byKey(Key('key_calibList_list_view_widget')), findsOneWidget);
    //expect(find.byKey(Key('key_container_widget_calib_list')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(ShowBackGroundWebviewState());
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      if (Utility.isIos) {
        expect(find.byKey(Key('key_show_web_view_widget')), findsOneWidget);
        expect(find.byKey(Key('key_show_web_view_widget')), findsOneWidget);
        expect(find.byKey(Key('key_in_web_view_widget')), findsOneWidget);
      } else {
        expect(find.byKey(Key('key_show_web_view_widget')), findsNothing);
        expect(find.byKey(Key('key_show_web_view_widget')), findsNothing);
        expect(find.byKey(Key('key_in_web_view_widget')), findsNothing);
      }
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_show_web_view_widget')), findsNothing);
      expect(find.byKey(Key('key_show_web_view_widget_empty_container')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(LoadedAllModelState());
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      if (Utility.isIos) {
        expect(find.byKey(Key('key_menu_options_loaded_state')), findsOneWidget);
        expect(find.byKey(Key('key_opacity_options_loaded_state')), findsOneWidget);
      } else {
        expect(find.byKey(Key('key_menu_options_loaded_state')), findsNothing);
        expect(find.byKey(Key('key_opacity_options_loaded_state')), findsNothing);
      }
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_widget_expanded')), findsOneWidget);
      expect(find.byKey(Key('key_widget_visibility')), findsOneWidget);
    });

    testWidgets('Test Visibility when visible is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      expect(find.byKey(Key('key_side_tool_bar_widget')), findsOneWidget);
    });

    testWidgets('getLeftPosition Orientation.landscape method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(1200, 800));
      var dx = widget.getLeftPosition(Orientation.landscape);
      expect(dx, 1000);
    });

    testWidgets('getLeftPosition Orientation.landscape method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(130, 800));
      var dx = widget.getLeftPosition(Orientation.landscape);
      expect(dx, 160);
    });

    testWidgets('getLeftPosition Orientation.landscape method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(150, 800));
      var dx = widget.getLeftPosition(Orientation.landscape);
      expect(dx, -500);
    });

    testWidgets('getLeftPosition Orientation.portrait method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(735, 800));
      widget.getLeftPosition(Orientation.portrait);
    });

    testWidgets('getLeftPosition Orientation.portrait method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(130, 800));
      widget.getLeftPosition(Orientation.portrait);
    });

    testWidgets('getTopPosition Orientation.portrait method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(750, 800));
      widget.getTopPosition(Orientation.portrait);
    });

    testWidgets('getTopPosition Orientation.portrait method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(750, 1200));
      widget.getTopPosition(Orientation.portrait);
    });

    testWidgets('getTopPosition Orientation.landscape method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(750, 840));
      widget.getTopPosition(Orientation.landscape);
    });

    testWidgets('getTopPosition Orientation.landscape method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.tapXY).thenReturn(Offset(750, 200));
      widget.getTopPosition(Orientation.landscape);
    });

    testWidgets('onTapDown method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.height).thenReturn(12000);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);

      widget.onTapDown(widget.context, LongPressEndDetails(), Orientation.landscape, LoadedAllModelState());
    });

    testWidgets('onTapUp method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.height).thenReturn(12000);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);

      widget.onTapUp(widget.context, LongPressStartDetails(), Orientation.landscape, LoadedAllModelState());
    });

    testWidgets('onWillPop method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.height).thenReturn(12000);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);
      when(() => mockOnlineModelViewerCubit.selectedProject).thenReturn(Project(projectName: "test"));

      widget.onWillPop();
    });

    testWidgets('onMenuClose method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.height).thenReturn(12000);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);

      widget.onMenuClose();
    });

    testWidgets('getFormattedDate method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.height).thenReturn(12000);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);

      final unformattedDate = '15-Aug-2023';
      final expectedFormattedDate = '15/08/2023';

      final formattedDate = widget.getFormattedDate(unformattedDate);

      expect(formattedDate, expectedFormattedDate);
    });

    testWidgets('showLocationTreeDialog method test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('true');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.isShowPdfView).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.height).thenReturn(12000);
      when(() => mockOnlineModelViewerCubit.state).thenReturn(CalibrationListResponseSuccessState(items: []));
      await tester.pumpWidget(
        makeTestableWidget(),
      );
      final finder = find.byType(OnlineModelViewerScreen);
      final widget = tester.state<OnlineModelViewerStates>(finder);

      final formattedDate = widget.showLocationTreeDialog(widget.context);
    });
  });
}
