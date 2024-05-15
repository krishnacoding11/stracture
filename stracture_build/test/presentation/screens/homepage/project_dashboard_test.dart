import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/bloc/dashboard/home_page_state.dart';
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/homepage/project_dashboard.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockHomePageCubit extends MockCubit<FlowState> implements HomePageCubit {}

class MockCreateFormSelectionCubit extends MockCubit<FlowState> implements CreateFormSelectionCubit {}

class MockFieldNavigatorCubit extends MockCubit<FlowState> implements FieldNavigatorCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setConnectivity();
  di.init(test: true);

  MockHomePageCubit mockHomePageCubit = MockHomePageCubit();
  MockCreateFormSelectionCubit mockCreateFormSelectionCubit = MockCreateFormSelectionCubit();
  MockFieldNavigatorCubit mockFieldNavigatorCubit = MockFieldNavigatorCubit();

  Map responseOfQRFormCreate = {
    "qrCodeType": QRCodeType.qrFormType,
    "arguments": {"projectId": "2116416\$\$XqC46u", "appTypeId": 1, "formSelectRadiobutton": "1_2116416\$\$XqC46u_10400819\$\$F0mqVu_HIREN-CI", "locationId": "", "url": "https: //adoddleqaak.asite.com/adoddle/apps?action_id=903&screen=new&application_Id=3&applicationId=3&isAndroid=true&isFromApps=true&isNewUI=true&numberOfRecentDefect=5&isMultipleAttachment=true&v=1697633227690&projectId=2116416\$\$XqC46u&appTypeId=1&formSelectRadiobutton=1_2116416\$\$XqC46u_10400819\$\$F0mqVu_HIREN-CI&projectids=2116416", "name": "ConstructionInspectionChecklist"},
    "formData": jsonDecode(fixture("app_type_vo.json")).toString()
  };

  Map responseOfQRLocation = {
    "qrCodeType": QRCodeType.qrLocation,
  };

  Project project = Project.fromJson(jsonDecode(fixture("project.json")));

  configureLoginCubitDependencies() {
    di.getIt.unregister<HomePageCubit>();
    di.getIt.registerFactory<HomePageCubit>(() => mockHomePageCubit);

    di.getIt.unregister<CreateFormSelectionCubit>();
    di.getIt.registerFactory<CreateFormSelectionCubit>(() => mockCreateFormSelectionCubit);

    di.getIt.unregister<FieldNavigatorCubit>();
    di.getIt.registerFactory<FieldNavigatorCubit>(() => mockFieldNavigatorCubit);
  }

  Widget testWidget() {
    return MultiBlocProvider(
        providers: [
          BlocProvider<FieldNavigatorCubit>(create: (context) => di.getIt<FieldNavigatorCubit>()),
          BlocProvider<CreateFormSelectionCubit>(create: (context) => di.getIt<CreateFormSelectionCubit>()),
          BlocProvider<HomePageCubit>(create: (context) => di.getIt<HomePageCubit>()),
        ],
        child: const MaterialApp(localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ], supportedLocales: [
          Locale('en')
        ], home: Material(child: ProjectDashboard())));
  }

  group("Test project dashboard", () {
    configureLoginCubitDependencies();

    testWidgets("Find Project dashboard widget", (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));

      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      await tester.pumpWidget(testWidget());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets("Find Project dashboard HomePageCubit BlocListener widget", (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      final expectedStates = [HomePageItemLoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE)];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenAnswer((invocation) => HomePageItemLoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets("Find Project dashboard HomePageCubit showFromCreateOptionDialog widget", (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      final expectedStates = [ShowFormCreationOptionsDialogState()];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenAnswer((invocation) => ShowFormCreationOptionsDialogState());
      await tester.pumpWidget(testWidget());
      await tester.pump(Duration(seconds: 1));
    });

    testWidgets('Test HomepageCubit <NavigateTaskListingScreenState> navigation Listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      final expectedStates = [NavigateTaskListingScreenState(TaskActionType.newTask)];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenAnswer((invocation) => NavigateTaskListingScreenState(TaskActionType.newTask));
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets('Test HomepageCubit <NavigateSiteListingScreenState> navigation Listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      Map<String, dynamic> arg = {
        "projectDetail": project,
        "listBreadCrumb": [project]
      };
      final expectedStates = [NavigateSiteListingScreenState(arg)];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenAnswer((invocation) => NavigateSiteListingScreenState({}));
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets('Test HomepageCubit <NoFormsMessageState> Listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      final expectedStates = [NoFormsMessageState()];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenAnswer((invocation) => NoFormsMessageState());
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets('Test FieldNavigatorCubit <Success No permission message>  listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      await tester.pumpWidget(testWidget());
      await tester.pump();

      //Success permission error dialog
      when(() => mockFieldNavigatorCubit.getAppTypeList(any())).thenReturn([]);
      final expectedStatesLocationScan = [SuccessState("")];
      whenListen(mockFieldNavigatorCubit, Stream.fromIterable(expectedStatesLocationScan));

      when(() => mockFieldNavigatorCubit.state).thenReturn(SuccessState(""));
      await tester.pumpWidget(testWidget());
      await tester.pumpAndSettle();
    });

    testWidgets('Test FieldNavigatorCubit <Success QR Code Form>  listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      await tester.pumpWidget(testWidget());
      await tester.pump();

      //QRCode Scan for Form
      when(() => mockFieldNavigatorCubit.getAppTypeList(any())).thenReturn([]);
      final expectedStates = [SuccessState(responseOfQRFormCreate)];
      whenListen(mockFieldNavigatorCubit, Stream.fromIterable(expectedStates));

      final appTypeListData = jsonDecode(fixture("app_type_list.json"));
      List<AppType> appList = [];
      for (var item in appTypeListData["data"]) {
        appList.add(AppType.fromJson(item));
      }
      when(() => mockFieldNavigatorCubit.getAppTypeList(any())).thenReturn(appList);
      when(() => mockFieldNavigatorCubit.state).thenReturn(SuccessState(responseOfQRFormCreate));
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets('Test FieldNavigatorCubit <Success QR Code Location>  listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      await tester.pumpWidget(testWidget());
      await tester.pump();

      //QRCode Scan for Location
      when(() => mockFieldNavigatorCubit.getAppTypeList(any())).thenReturn([]);
      final expectedStatesLocationScan = [SuccessState(responseOfQRLocation)];
      whenListen(mockFieldNavigatorCubit, Stream.fromIterable(expectedStatesLocationScan));

      when(() => mockFieldNavigatorCubit.state).thenReturn(SuccessState(responseOfQRLocation));
      await tester.pumpWidget(testWidget());
      await tester.pumpAndSettle();
    });

    testWidgets('Test FieldNavigatorCubit <Loading> listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);
      await tester.pumpWidget(testWidget());
      await tester.pump(Duration(milliseconds: 100));

      final expectedStates = [LoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE)];
      whenListen(mockFieldNavigatorCubit, Stream.fromIterable(expectedStates));

      when(() => mockFieldNavigatorCubit.state).thenReturn(LoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets('Test FieldNavigatorCubit <Error> listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      await tester.pumpWidget(testWidget());
      await tester.pump();

      //FromScreen.dashboard
      final expectedStates = [ErrorState(StateRendererType.DEFAULT, "", data: FromScreen.dashboard)];
      whenListen(mockFieldNavigatorCubit, Stream.fromIterable(expectedStates));

      when(() => mockFieldNavigatorCubit.state).thenReturn(ErrorState(StateRendererType.DEFAULT, "", data: FromScreen.dashboard));
      await tester.pumpWidget(testWidget());
      await tester.pump();

      //Error status code 601
      final expectedStatesCode = [ErrorState(StateRendererType.DEFAULT, "", code: 601)];
      whenListen(mockFieldNavigatorCubit, Stream.fromIterable(expectedStatesCode));

      when(() => mockFieldNavigatorCubit.state).thenReturn(ErrorState(StateRendererType.DEFAULT, "", code: 601));
      await tester.pumpWidget(testWidget());
      await tester.pump();

      //QRCode Alert Dialog
      final expectedStatesQRAlertDialog = [ErrorState(StateRendererType.DEFAULT, "")];
      whenListen(mockFieldNavigatorCubit, Stream.fromIterable(expectedStatesQRAlertDialog));

      when(() => mockFieldNavigatorCubit.state).thenReturn(ErrorState(
        StateRendererType.DEFAULT,
        "",
      ));
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets('Test CreateFormSelectionCubit <Loading> listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      await tester.pumpWidget(testWidget());
      await tester.pump();

      final expectedStates = [LoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE)];
      whenListen(mockCreateFormSelectionCubit, Stream.fromIterable(expectedStates));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(LoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
      await tester.pumpWidget(testWidget());
      await tester.pump();
    });

    testWidgets('Test CreateFormSelectionCubit success listen', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockFieldNavigatorCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockCreateFormSelectionCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      await tester.pumpWidget(testWidget());
      await tester.pump();

      final expectedStates = [SuccessState(null)];
      whenListen(mockCreateFormSelectionCubit, Stream.fromIterable(expectedStates));

      when(() => mockCreateFormSelectionCubit.state).thenReturn(SuccessState(null));
      await tester.pumpWidget(testWidget());
      await tester.pump(Duration(milliseconds: 100));
    });
  });
}
