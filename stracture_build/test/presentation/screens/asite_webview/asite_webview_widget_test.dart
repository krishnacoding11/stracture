import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/site/create_form_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/webview/asite_webview.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../utils/load_url.dart';


class MockCreateFormCubit extends MockCubit<FlowState> implements CreateFormCubit {}
class MockFieldNavigatorCubit extends MockCubit<FlowState> implements FieldNavigatorCubit {}
class MockProjectListCubit extends MockCubit<FlowState> implements ProjectListCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockCreateFormCubit mockCreateFormCubit = MockCreateFormCubit();
  MockFieldNavigatorCubit mockFieldNavigatorCubit = MockFieldNavigatorCubit();
  MockProjectListCubit mockProjectListCubit = MockProjectListCubit();

  configureLoginCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<CreateFormCubit>();
    di.getIt.registerLazySingleton<CreateFormCubit>(() => mockCreateFormCubit);
    di.getIt.unregister<FieldNavigatorCubit>();
    di.getIt.registerLazySingleton<FieldNavigatorCubit>(() => mockFieldNavigatorCubit);
    di.getIt.unregister<ProjectListCubit>();
    di.getIt.registerLazySingleton<ProjectListCubit>(() => mockProjectListCubit);

    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  Widget getTestWidget() {
    return new MultiBlocProvider(
      providers: [
        BlocProvider<CreateFormCubit>(
          create: (BuildContext context) => di.getIt<CreateFormCubit>(),
        ),
        BlocProvider<FieldNavigatorCubit>(
          create: (BuildContext context) => di.getIt<FieldNavigatorCubit>(),
        ),
        BlocProvider<ProjectListCubit>(
          create: (BuildContext context) => di.getIt<ProjectListCubit>(),
        ),
        /*BlocProvider<SiteTaskCubit>(
          create: (BuildContext context) => di.getIt<SiteTaskCubit>(),
        ),
        BlocProvider<PlanCubit>(
          create: (BuildContext context) => di.getIt<PlanCubit>(),
        ),*/
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: AsiteWebView(
              key: ValueKey("Test123"),
              url: "https://systemqa.asite.com/view",
              title: "View Form or File",
              isAppbarRequired: false,
              data: {
                "projectId": "12345",
                "locationId" : "2344443",
                "commId": "132234",
                "appTypeId": 1
              }),
      ),
    );
  }


  group('Drawer Test', () {
    configureLoginCubitDependencies();
    setUp(() {
      when(() => mockCreateFormCubit.state).thenReturn(FlowState());
      when(() => mockProjectListCubit.state).thenReturn(FlowState());
      when(() => mockFieldNavigatorCubit.state).thenReturn(FlowState());
    });

    testWidgets('Initialize Asite Webview Widget', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      expect(asiteWebViewWidget, findsOneWidget);
    });

    testWidgets('Test Asite Webview Widget Properties', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      expect(asiteWebViewEl.url, "https://systemqa.asite.com/view");
      expect(asiteWebViewEl.title, "View Form or File");
      expect(asiteWebViewEl.isAppbarRequired, false);
    });

    testWidgets('Test attachment option is not available', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final cameraEl = find.byIcon(Icons.camera_alt);
      expect(cameraEl, findsNothing);
      final selectPictureEl = find.byIcon(Icons.photo_library);
      expect(selectPictureEl, findsNothing);
      final selectFileEl = find.byIcon(Icons.file_copy);
      expect(selectFileEl, findsNothing);
    });

    testWidgets('Test Bottom Attachment Widget', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.showBottomSheetDialog();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.file_copy), findsOneWidget);
    });

    testWidgets('Test Attachment Tap Handler', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.showBottomSheetDialog();
      await tester.pump(const Duration(milliseconds: 100));
      final cameraItem = find.byKey(const Key("camera_item")).last;
      expect(tester.widget<InkWell>(cameraItem).onTap, isNotNull);
      final selectPictureItem = find.byKey(const Key("select_picture_item")).last;
      expect(tester.widget<InkWell>(selectPictureItem).onTap, isNotNull);
      final selectFileItem = find.byKey(const Key("select_file_item")).last;
      expect(tester.widget<InkWell>(selectFileItem).onTap, isNotNull);
    });

    testWidgets('Test Camera Tap Handler', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.showBottomSheetDialog();
      await tester.pump(const Duration(milliseconds: 100));
      final cameraItem = find.byKey(const Key("camera_item")).last;
      await tester.tap(cameraItem, warnIfMissed: false);
      expect(tester.widget<InkWell>(cameraItem).onTap, isNotNull);
      /*await tester.pump();*/
    });

    testWidgets('Test Camera Tap Handler', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.showBottomSheetDialog();
      await tester.pump(const Duration(milliseconds: 100));
      final selectPictureItem = find.byKey(const Key("select_picture_item")).last;
      await tester.tap(selectPictureItem, warnIfMissed: false);
      expect(tester.widget<InkWell>(selectPictureItem).onTap, isNotNull);
    });

    testWidgets('Test Camera Tap Handler', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.showBottomSheetDialog();
      await tester.pump(const Duration(milliseconds: 100));
      final selectFileItem = find.byKey(const Key("select_file_item")).last;
      await tester.tap(selectFileItem, warnIfMissed: false);
      expect(tester.widget<InkWell>(selectFileItem).onTap, isNotNull);
    });

    testWidgets('Test Form Back Press Handler', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.isFromScreen = FromScreen.planView;
      state.callbackJSPEvent("backClicked", "js-frame::backClicked");
      await tester.pump(const Duration(milliseconds: 100));
      expect(state.isBackPress, true);
    });

    testWidgets('Test Offline Html Form Attachment Event', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.showBottomSheetDialog();
      state.callbackJSPEvent("offLineHtmlFormAttachment", "");
      await tester.pump();
      expect(state.dictAttachment, isEmpty);
      final cameraItem = find.byKey(const Key("camera_item")).last;
      expect(cameraItem, findsOneWidget);
    });

    testWidgets('Test Upload Inline Attachment Event', (WidgetTester tester) async {
      Widget testAsiteWebViewWidget = getTestWidget();
      await tester.pumpWidget(testAsiteWebViewWidget);
      await tester.pump(const Duration(milliseconds: 10));
      final asiteWebViewWidget = find.byType(AsiteWebView);
      final asiteWebViewEl = tester.widget<AsiteWebView>(asiteWebViewWidget);
      AsiteWebViewState state = tester.state<AsiteWebViewState>(find.byWidget(asiteWebViewEl));
      state.showBottomSheetDialog();
      state.callbackJSPEvent('uploadAttachment:{"dcMapSuffix":{"1":"","2":"b"}}', "js-frame:uploadAttachment:%7B%22dcMapSuffix%22:%7B%221%22:%22%22%7D%7D");
      await tester.pump();
      expect(state.dictAttachment, isNotEmpty);
    });
  });

}