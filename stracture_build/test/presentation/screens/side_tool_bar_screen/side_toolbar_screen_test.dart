import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart' as pdf_tron;
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/side_toolbar/side_toolbar_screen.dart';
import 'package:field/utils/constants.dart';
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

class MockInAppWebViewController extends Mock implements InAppWebViewController {}

class MockPdfTronCubit extends MockCubit<pdf_tron.PdfTronState> implements pdf_tron.PdfTronCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockOnlineModelViewerCubit mockOnlineModelViewerCubit = MockOnlineModelViewerCubit();
  MockSideToolBarCubit mockSideToolBarCubit = MockSideToolBarCubit();
  MockModelListCubit mockModelListCubit = MockModelListCubit();
  MockPdfTronCubit mockPdfTronCubit = MockPdfTronCubit();
   MockInAppWebViewController mockWebviewController = MockInAppWebViewController();

  configureLoginCubitDependencies() {
    init(test: true);
    getIt.unregister<ModelListCubit>();
    getIt.unregister<online_model_viewer.OnlineModelViewerCubit>();
    getIt.unregister<side_tool_bar.SideToolBarCubit>();
    getIt.unregister<pdf_tron.PdfTronCubit>();
    getIt.registerLazySingleton<online_model_viewer.OnlineModelViewerCubit>(() => mockOnlineModelViewerCubit);
    getIt.registerLazySingleton<side_tool_bar.SideToolBarCubit>(() => mockSideToolBarCubit);
    getIt.registerLazySingleton<pdf_tron.PdfTronCubit>(() => mockPdfTronCubit);
    getIt.registerLazySingleton<ModelListCubit>(() => mockModelListCubit);
  }

  setUp(() async {
    mockWebviewController = MockInAppWebViewController();
    when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
    when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
    when(() => mockSideToolBarCubit.isRulerMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isRulerSecondSubMenuActive).thenReturn(true);
    when(() => mockSideToolBarCubit.isCuttingPlaneMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isMarkerMenuActive).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
    when(() => mockOnlineModelViewerCubit.offlineFilePath).thenReturn([]);
    when(() => mockOnlineModelViewerCubit.bimModelListData).thenReturn([]);
    when(() => mockOnlineModelViewerCubit.isDialogShowing).thenReturn(false);
    when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
    when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
    when(() => mockModelListCubit.isShowPdf).thenReturn(true);
    when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
    when(() => mockOnlineModelViewerCubit.totalNumbersOfModelsLoad).thenReturn('1');
    when(() => mockOnlineModelViewerCubit.totalNumbersOfModels).thenReturn('1');
    when(() => mockOnlineModelViewerCubit.selectedPdfFileName).thenReturn('');
    when(() => mockOnlineModelViewerCubit.key).thenReturn(GlobalKey<ScaffoldState>());
    when(() => mockModelListCubit.isFavorite).thenReturn(false);
    when(() => mockModelListCubit.isShowDetails).thenReturn(false);
    when(() => mockModelListCubit.progress).thenReturn(0);
    when(() => mockModelListCubit.allItems).thenReturn([]);
    when(() => mockModelListCubit.totalProgress).thenReturn(-1);

    when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
    when(() => mockModelListCubit.allItems).thenReturn([]);
    when(() => mockModelListCubit.getProjectName(any(), any())).thenAnswer((invocation) => Future.value("projectName"));
    when(() => mockSideToolBarCubit.isRulerMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isCuttingPlaneMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isMarkerMenuActive).thenReturn(false);
  });

  Widget getTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
          create: (BuildContext context) => mockOnlineModelViewerCubit,
        ),
        BlocProvider<side_tool_bar.SideToolBarCubit>(
          create: (BuildContext context) => mockSideToolBarCubit,
        ),
        BlocProvider<ModelListCubit>(
          create: (BuildContext context) => mockModelListCubit,
        ),
        BlocProvider<pdf_tron.PdfTronCubit>(
          create: (BuildContext context) => mockPdfTronCubit,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: SideToolbarScreen(
          isWhite: false,
          isModelSelected: true,
          isOnlineModelViewerScreen:true,
          onlineModelViewerCubit: mockModelListCubit,
          orientation: Orientation.landscape,
          isPdfViewISFull: true,
          modelId: "",
          modelName: AConstants.modelName,
        ),
      ),
    );
  }

  group('Side Tool Bar Test', () {
    configureLoginCubitDependencies();
    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byType(OrientationBuilder), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(OrientationBuilder), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byKey(Key(AConstants.key_side_tool_bar_icons_column)), findsOneWidget);
      expect(find.byKey(Key(AConstants.key_home)), findsOneWidget);
      expect(find.byKey(Key(AConstants.key_pdf)), findsOneWidget);
      expect(find.byKey(Key(AConstants.key_color_palette)), findsOneWidget);
      expect(find.byKey(Key(AConstants.key_model)), findsOneWidget);
      expect(find.byKey(Key(AConstants.key_reset)), findsOneWidget);
    });

    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      when(() => mockPdfTronCubit.lastSavedYPoint).thenReturn(0);
      when(() => mockPdfTronCubit.lastSavedXPoint).thenReturn(0);
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_icon_home')), findsOneWidget);
      await tester.tap(find.byKey(Key('key_icon_home')));
      await tester.pumpAndSettle();
      expect(mockOnlineModelViewerCubit.isDialogShowing, false);
      expect(mockPdfTronCubit.lastSavedYPoint, 0);
      expect(mockPdfTronCubit.lastSavedXPoint, 0);
    });

    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_single_child_scroll_view')), findsOneWidget);
      expect(find.byKey(Key('key_container_widget')), findsOneWidget);
    });

    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_single_child_scroll_view')), findsOneWidget);
      expect(find.byKey(Key('key_container_widget')), findsOneWidget);
      await tester.tap(find.byKey(Key('key_cutting_plane_widget')));
      await tester.pumpAndSettle();
      expect(mockSideToolBarCubit.isPopUpShowing, false);
    });

    testWidgets('openRulerMenu method test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isRulerFirstSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isRulerThirdSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isRulerSecondSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      widget.sideToolBarCubit.isRulerFirstSubMenuActive = true;
      widget.sideToolBarCubit.isRulerThirdSubMenuActive = true;
      widget.sideToolBarCubit.isRulerSecondSubMenuActive = true;
      widget.openRulerMenu(widget.context, Orientation.portrait, Offset(100, 200));
    });

    testWidgets('openCuttingPlaneMenu method test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneFirstSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneSecondSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneThirdSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneFourthSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneFifthSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      widget.sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
      widget.openCuttingPlaneMenu(widget.context, Orientation.portrait, Offset(100, 200));
    });

    testWidgets('openMarkerMenu method test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      widget.openMarkerMenu(widget.context, Orientation.portrait, Offset(100, 200));
    });

    testWidgets('key_icon_ruler_outline key test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      when(() => mockSideToolBarCubit.isRulerFirstSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isRulerThirdSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isRulerSecondSubMenuActive).thenReturn(true);
      Utility.isIos=true;
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      var finder = find.byKey(Key("key_icon_ruler_outline"));
      expect(finder, findsOneWidget);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      widget.widget.isPdfViewISFull=false;
      widget.sideToolBarCubit.isWhite=false;
      widget.sideToolBarCubit.isSideToolBarEnabled=false;
      widget.widget.isOnlineModelViewerScreen=true;
      widget.sideToolBarCubit.isRulerFirstSubMenuActive = true;
      widget.sideToolBarCubit.isRulerThirdSubMenuActive = true;
      widget.sideToolBarCubit.isRulerSecondSubMenuActive = true;
      Utility.isIos=true;
      await tester.tap(finder);
      await tester.pumpAndSettle();
    });

    testWidgets('key_icon_home key test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      when(() => mockSideToolBarCubit.isRulerFirstSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isRulerThirdSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isRulerSecondSubMenuActive).thenReturn(true);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.webviewController).thenReturn(mockWebviewController);
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      Utility.isIos=true;
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      var finder = find.byKey(Key("key_icon_home"));
      expect(finder, findsOneWidget);
      widget.widget.isPdfViewISFull=false;
      widget.widget.onlineModelViewerCubit=mockOnlineModelViewerCubit;
      widget.widget.onlineModelViewerCubit.webviewController=mockWebviewController;
      widget.sideToolBarCubit.isWhite=false;
      widget.sideToolBarCubit.isSideToolBarEnabled=false;
      widget.widget.isOnlineModelViewerScreen=true;
      widget.sideToolBarCubit.isRulerFirstSubMenuActive = true;
      widget.sideToolBarCubit.isRulerThirdSubMenuActive = true;
      widget.sideToolBarCubit.isRulerSecondSubMenuActive = true;
      await tester.tap(finder);
      await tester.pumpAndSettle();
    });

    testWidgets('key_cutting_plane_widget key test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneFirstSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneSecondSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneThirdSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneFourthSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isCuttingPlaneFifthSubMenuActive).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.webviewController).thenReturn(mockWebviewController);
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      Utility.isIos=true;
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      var finder = find.byKey(Key("key_cutting_plane_widget"));
      expect(finder, findsOneWidget);
      widget.widget.isPdfViewISFull=false;
      widget.widget.onlineModelViewerCubit=mockOnlineModelViewerCubit;
      widget.widget.onlineModelViewerCubit.webviewController=mockWebviewController;
      widget.sideToolBarCubit.isWhite=false;
      widget.sideToolBarCubit.isSideToolBarEnabled=false;
      widget.widget.isOnlineModelViewerScreen=true;
      widget.sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
      await tester.tap(finder);
      await tester.pumpAndSettle();
    });


    testWidgets('key_split_horizontally_widget key test', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.getCalibrationList(any(), any(), any())).thenAnswer((invocation) => Future.value([]));
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.isCalibListPressed).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedProject).thenReturn(Project(projectID: "222",projectName: "testName"));
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn([]);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.webviewController).thenReturn(mockWebviewController);
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      Utility.isIos=true;
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      var finder = find.byKey(Key("key_split_horizontally_widget"));
      expect(finder, findsOneWidget);
      widget.widget.isPdfViewISFull=false;
      widget.widget.onlineModelViewerCubit=mockOnlineModelViewerCubit;
      widget.widget.onlineModelViewerCubit.webviewController=mockWebviewController;
      widget.sideToolBarCubit.isWhite=false;
      widget.sideToolBarCubit.isSideToolBarEnabled=false;
      widget.widget.isOnlineModelViewerScreen=true;
      widget.sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
      await tester.tap(finder);
      await tester.pumpAndSettle();
    });

    testWidgets('key_model_widget key test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(true, items: [], isShowCloseButton: false));
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.getCalibrationList(any(), any(), any())).thenAnswer((invocation) => Future.value([]));
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockOnlineModelViewerCubit.isCalibListPressed).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.selectedProject).thenReturn(Project(projectID: "222",projectName: "testName"));
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn([]);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.webviewController).thenReturn(mockWebviewController);
      when(() => mockWebviewController.evaluateJavascript(source: any(named: "source"))).thenAnswer((invocation) => Future.value());
      Utility.isIos=true;
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      var finder = find.byKey(Key("key_model_widget"));
      expect(finder, findsOneWidget);
      widget.widget.isPdfViewISFull=false;
      widget.widget.onlineModelViewerCubit=mockOnlineModelViewerCubit;
      widget.widget.onlineModelViewerCubit.webviewController=mockWebviewController;
      widget.sideToolBarCubit.isWhite=false;
      widget.sideToolBarCubit.isSideToolBarEnabled=false;
      widget.widget.isOnlineModelViewerScreen=true;
      widget.sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = true;
      widget.sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
      widget.sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
      await tester.tap(finder);
      await tester.pumpAndSettle();
    });

    testWidgets('showRulerMenu method test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      widget.showRulerMenu(widget.context, Orientation.portrait);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
              create: (BuildContext context) => mockOnlineModelViewerCubit,
            ),
            BlocProvider<side_tool_bar.SideToolBarCubit>(
              create: (BuildContext context) => mockSideToolBarCubit,
            ),
            BlocProvider<ModelListCubit>(
              create: (BuildContext context) => mockModelListCubit,
            ),
            BlocProvider<pdf_tron.PdfTronCubit>(
              create: (BuildContext context) => mockPdfTronCubit,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(
              body: Builder(builder: (con) {
                return ElevatedButton(
                    onPressed: () {
                      widget.showCuttingPlaneMenu(con, Orientation.portrait);
                    },
                    child: Text("Test Button"));
              }),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();
    });

    testWidgets('showCuttingPlaneMenu method test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      widget.showCuttingPlaneMenu(widget.context, Orientation.portrait);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
              create: (BuildContext context) => mockOnlineModelViewerCubit,
            ),
            BlocProvider<side_tool_bar.SideToolBarCubit>(
              create: (BuildContext context) => mockSideToolBarCubit,
            ),
            BlocProvider<ModelListCubit>(
              create: (BuildContext context) => mockModelListCubit,
            ),
            BlocProvider<pdf_tron.PdfTronCubit>(
              create: (BuildContext context) => mockPdfTronCubit,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(
              body: Builder(builder: (con) {
                return ElevatedButton(
                    onPressed: () {
                      widget.showCuttingPlaneMenu(con, Orientation.portrait);
                    },
                    child: Text("Test Button"));
              }),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Test Button'));
      await tester.pumpAndSettle();
    });

    testWidgets('showMarkerMenu method test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
      when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(true);
      when(() => mockSideToolBarCubit.isPopUpShowing).thenReturn(false);
      when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
      when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
      when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
      await tester.pumpWidget(getTestWidget());
      var widget = tester.state<SideToolbarScreenState>(find.byType(SideToolbarScreen));
      RenderObject? box = widget.markerKey.currentContext?.findRenderObject();
      widget.showMarkerMenu(widget.context, Orientation.portrait);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
              create: (BuildContext context) => mockOnlineModelViewerCubit,
            ),
            BlocProvider<side_tool_bar.SideToolBarCubit>(
              create: (BuildContext context) => mockSideToolBarCubit,
            ),
            BlocProvider<ModelListCubit>(
              create: (BuildContext context) => mockModelListCubit,
            ),
            BlocProvider<pdf_tron.PdfTronCubit>(
              create: (BuildContext context) => mockPdfTronCubit,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(
              body: Builder(builder: (con) {
                return ElevatedButton(
                    onPressed: () {
                      widget.showMarkerMenu(con, Orientation.portrait);
                    },
                    child: Text("Test Button"));
              }),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Button'));
     await tester.pumpAndSettle();
    });
  });
}
