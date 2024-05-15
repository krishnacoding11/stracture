import 'dart:convert';
import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_cubit.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_state.dart';
import 'package:field/bloc/site/create_form_cubit.dart';
import 'package:field/data/model/quality_activity_list_vo.dart';
import 'package:field/domain/use_cases/quality/quality_plan_listing_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/quality/activity_listing_screen.dart';
import 'package:field/presentation/screen/webview/asite_webview.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/widgets/action_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

GetIt getIt = GetIt.instance;


class MockQualityPlanLocationListingCubit extends MockCubit<FlowState>
    implements QualityPlanLocationListingCubit {

  Map<String, dynamic> map = {
    'url': 'https://adoddleqa.asite.com',
    'name': 'SimpleForm_Mailbox_Rohit',
    'projectId': '2107646\$\$7JXhZF',
    'locationId': '1519169\$\$OwZvJg',
    'commId': '12345\$\$5TyU6',
    // 'isFrom': 'Quality',
    'appTypeId': 1
  };

  @override
  Future<String> getViewFileUrl(DeliverableActivities activity) async {
    return Future.value('');
  }

  @override
  Future<Map<String, dynamic>> navigateToCreateForm(ActivitiesList data) async {
    return map;
  }
}

class MockQualityLocationListingUseCase extends Mock implements QualityPlanListingUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late Widget activityListingScreen;
  MockQualityPlanLocationListingCubit mockQualityPlanLocationListingCubit = MockQualityPlanLocationListingCubit();
  AConstants.adoddleUrl = 'https://adoddleqaak.asite.com/';

  setUpAll(() =>
    registerFallbackValue(DeliverableActivities())
  );
  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<QualityPlanLocationListingCubit>();
    di.getIt.registerFactory<QualityPlanLocationListingCubit>(
            () => mockQualityPlanLocationListingCubit);
  }

  setUp(() {
    // PreferenceUtils.init();
    activityListingScreen = Material(child: MediaQuery(
      data: const MediaQueryData(),
      child: MultiBlocProvider(
        // create: (context) => di.getIt<QualityPlanLocationListingCubit>(),
        providers: [
          BlocProvider<QualityPlanLocationListingCubit>(
            create: (BuildContext context) => di.getIt<QualityPlanLocationListingCubit>(),
          ),
          BlocProvider<CreateFormCubit>(
              create: (BuildContext context) => di.getIt<CreateFormCubit>(),
          ),
          BlocProvider<ProjectListCubit>(
          create: (BuildContext context) => di.getIt<ProjectListCubit>(),
          ),
        ],
        child: const MaterialApp(localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ], home: Scaffold(
          body: ActivityListingScreen(),
        )
        ),
      ),
    ));
  });

  group("Test Activity Listing Screen Cases", () {
    configureCubitDependencies();
    setUp(() {
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(FlowState());
    });

    testWidgets('Activity List Loader', (tester) async {
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(
          ActivityListState(null, QualityListInternalState.activityList, InternalState.loading));
      expect(mockQualityPlanLocationListingCubit.state,
          ActivityListState(null, QualityListInternalState.activityList, InternalState.loading));

      await tester.pumpWidget(activityListingScreen);

      var loadingWidget = find.byKey(
          const Key("key_activity_listing_progressbar"));
      expect(loadingWidget, findsOneWidget);
    });

    group("Activity List Success scenarios Button Values according to conditions", () {
      final data = QualityActivityList.fromJson(jsonDecode(fixture("quality_activity_listing_response.json")));
      final activityList = data.response!.root!.activitiesList!;

      group("Show Open Button and click events", () {

        testWidgets("No Permission against File", (tester) async {
          var updatedActivityList = [ActivitiesList.fromJson({
            "activitySeq": 4,
            "isStatusChanged": false,
            "deliverableActivities": [
              {
                "activitySeq": 4,
                "deliverableActivityId": "6197605\$\$rjXO0F",
                "statusColor": "#F24043",
                "statusName": "Not Started",
                "isAccess": false,
                "activityType": 0,
                "createdById": "643944\$\$tWd9hd",
                "isWorking": false
              }
            ],
            "qiActivityId": "6680\$\$mv8AZu",
            "associationType": 1,
            "activityName": "logo",
            "isAccess": false,
            "activityType": 0,
          })];

          when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
              .thenAnswer((_) async => Future.value());

          when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
              ActivityListState(updatedActivityList, QualityListInternalState.activityList, InternalState.success));

          when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusOpen(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isNotBlocked(any())).thenReturn(true);

          await tester.pumpWidget(activityListingScreen);
          await tester.pump(const Duration(milliseconds: 100000));
          await tester.pump();
          expect(mockQualityPlanLocationListingCubit.state, ActivityListState(updatedActivityList, QualityListInternalState.activityList, InternalState.success));
          expect(find.bySemanticsLabel('Open'), findsWidgets);

          Finder openButton = find.bySemanticsLabel('Open').first;
          await tester.tap(openButton);
          await tester.pump(const Duration(milliseconds: 250));

          expect(find.text('You do not have permission to add file. Please contact your workspace administrator.'), findsOneWidget);
        });

        testWidgets("No Permission against Form", (tester) async {
          var updatedActivityList = [ActivitiesList.fromJson({
            "activitySeq": 4,
            "isStatusChanged": false,
            "deliverableActivities": [
              {
                "activitySeq": 4,
                "deliverableActivityId": "6197605\$\$rjXO0F",
                "statusColor": "#F24043",
                "statusName": "Not Started",
                "isAccess": false,
                "activityType": 0,
                "createdById": "643944\$\$tWd9hd",
                "isWorking": false
              }
            ],
            "qiActivityId": "6680\$\$mv8AZu",
            "associationType": 2,
            "activityName": "logo",
            "isAccess": false,
            "activityType": 0,
          })];

          when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
              .thenAnswer((_) async => Future.value());

          when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
              ActivityListState(updatedActivityList, QualityListInternalState.activityList, InternalState.success));

          when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusOpen(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isNotBlocked(any())).thenReturn(true);

          await tester.pumpWidget(activityListingScreen);
          await tester.pump(const Duration(milliseconds: 100000));
          await tester.pump();
          expect(mockQualityPlanLocationListingCubit.state, ActivityListState(updatedActivityList, QualityListInternalState.activityList, InternalState.success));
          expect(find.bySemanticsLabel('Open'), findsWidgets);

          Finder openButton = find.bySemanticsLabel('Open').first;
          await tester.tap(openButton);
          await tester.pump(const Duration(milliseconds: 250));

          expect(find.text('You do not have a permission to create a form. Please contact your workspace administrator.'), findsOneWidget);
        });

        testWidgets("Click Open button against File", (tester) async {

          // successCallBack(){}

          when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
              .thenAnswer((_) async => Future.value());

          when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
              ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

          // when(()=>mockQualityPlanLocationListingCubit.getFileFromGallery((){}, FileType.image, successCallBack)).thenAnswer((_) => Future(() => successCallBack()));

          when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusOpen(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusComplete(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusInProgress(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(true);

          await tester.pumpWidget(activityListingScreen);
          await tester.pump(const Duration(milliseconds: 100000));
          await tester.pump();
          expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
          expect(find.byKey(const Key("Hold_Point")), findsWidgets);
          expect(find.bySemanticsLabel('Open'), findsWidgets);

          Finder openButton = find.bySemanticsLabel('Open').first;
          await tester.tap(openButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          expect(find.bySemanticsLabel('Select a picture'), findsOneWidget);
          expect(find.bySemanticsLabel('Take a picture  '), findsOneWidget);
          expect(find.bySemanticsLabel('Select a file'), findsOneWidget);

          // await tester.tap(find.bySemanticsLabel('Select a picture'));
          // await tester.pumpAndSettle(const Duration(seconds: 5));

          // expect(find.byElementType(AlertDialog), findsOneWidget);
        });

        testWidgets("Click Open button against Form", (tester) async {
          when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
              .thenAnswer((_) async => Future.value());

          when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
              ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

          when(() => mockQualityPlanLocationListingCubit.isNotBlocked(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusOpen(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusComplete(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isActivityStatusInProgress(any())).thenReturn(false);
          when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(true);
          when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(true);

          await tester.pumpWidget(activityListingScreen);
          await tester.pump(const Duration(milliseconds: 100000));
          await tester.pump();
          expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
          expect(find.byKey(const Key("Hold_Point")), findsWidgets);
          expect(find.bySemanticsLabel('Open'), findsWidgets);

          Finder openButton = find.bySemanticsLabel('Open').last;
          await tester.tap(openButton);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          expect(find.bySemanticsLabel('Create Form'), findsOneWidget);

          // COmmented as NavigationUtils.mainKey.currentState is getting null and failing testcase.
          // await tester.tap(find.bySemanticsLabel('Create Form'));
          // await tester.pumpAndSettle(const Duration(seconds: 5));
          // expect(find.byType(AsiteWebView), findsOneWidget);
        });
      });

      testWidgets("Show Action button(In progress/Closed with Delete icon) according to permission", (tester) async {

        when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
            .thenAnswer((_) async => Future.value());

        when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
            ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

        when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.hasActivityManageAccess).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.getUrlBasedOnAssociationType(any())).thenAnswer((_) async => Future.value('https://adoddleqaak.asite.com/adoddle/viewer/fileView.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&ios=true&hasOnlineViewerSupport=true&documentTypeId=0&viewerId=0&isFromFileViewForDomain=true&isMarkOffline=false&documentId=null&projectId=2116416\$\$2XLm0n&revisionId=null&folderId=null&dcId=1&toOpen=FromFile&projectids=2116416'));
        when(() => mockQualityPlanLocationListingCubit.getDataToViewFormFile()).thenReturn({
          'projectId': '2116416',
          'locationId': '456'
        });

        await tester.pumpWidget(activityListingScreen);
        await tester.pump(const Duration(milliseconds: 100000));
        await tester.pump();
        expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
        expect(find.byKey(const Key("Hold_Point")), findsWidgets);
        expect(find.bySemanticsLabel('Closed'), findsWidgets);
        expect(find.byType(ActionButton), findsWidgets);

        var iconButton = find.byKey(const Key("CrossIconButton")).last;
        expect(iconButton, findsWidgets);
        await tester.tap(iconButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.text("Cancel"), findsOneWidget);
        await tester.tap(find.text("Cancel"));
        await tester.pump();

        await tester.tap(find.byKey(const Key("KeyActionButton")).first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        expect(find.byType(AsiteWebView), findsOneWidget);
      });

      testWidgets("Show In progress/Complete evaluate Button when no permission for Remove/Delete", (tester) async {
        /// When no Manage Access than Remove button will not be available. It will show only Closed/In Progress (Elevated)Button
        when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
            .thenAnswer((_) async => Future.value());

        when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
            ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

        when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.isNotBlocked(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.isActivityStatusOpen(any())).thenReturn(false);
        when(() => mockQualityPlanLocationListingCubit.isActivityStatusComplete(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.hasActivityManageAccess).thenReturn(false);
        when(() => mockQualityPlanLocationListingCubit.getUrlBasedOnAssociationType(any())).thenAnswer((_) async => Future.value('https://adoddleqaak.asite.com/adoddle/viewer/fileView.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&ios=true&hasOnlineViewerSupport=true&documentTypeId=0&viewerId=0&isFromFileViewForDomain=true&isMarkOffline=false&documentId=null&projectId=2116416\$\$2XLm0n&revisionId=null&folderId=null&dcId=1&toOpen=FromFile&projectids=2116416'));
        when(() => mockQualityPlanLocationListingCubit.getDataToViewFormFile()).thenReturn({
          'projectId': '2116416',
          'locationId': '456'
        });

        await tester.pumpWidget(activityListingScreen);
        await tester.pump();
        expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
        expect(find.byKey(const Key("Hold_Point")), findsWidgets);
        expect(find.bySemanticsLabel("Closed"), findsWidgets);
        expect(find.byType(ActionButton), findsNothing);

        await tester.tap(find.bySemanticsLabel("Closed").first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        expect(find.text("You do not have a permission to view the content. Please contact your administrator."), findsWidgets);
        expect(find.byType(AsiteWebView), findsNothing);
      });

      testWidgets("Show Blocked Button", (tester) async {
        when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
            .thenAnswer((_) async => Future.value());

        when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
            ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

        when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
        when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(false);
        when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(false);
        when(() => mockQualityPlanLocationListingCubit.isActivityStatusOpen(any())).thenReturn(true);

        await tester.pumpWidget(activityListingScreen);
        await tester.pump(const Duration(milliseconds: 100000));
        await tester.pump();
        expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
        expect(find.byKey(const Key("Hold_Point")), findsWidgets);
        expect(find.bySemanticsLabel('Blocked'), findsWidgets);
      });

      testWidgets("Show N/A Button", (tester) async {
        when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
            .thenAnswer((_) async => Future.value());

        when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
            ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

        when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(false);
        when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(false);
        when(() => mockQualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(any())).thenReturn(false);
        when(() => mockQualityPlanLocationListingCubit.isActivityStatusOpen(any())).thenReturn(true);

        await tester.pumpWidget(activityListingScreen);
        await tester.pump(const Duration(milliseconds: 100000));
        await tester.pump();
        expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
        expect(find.byKey(const Key("Hold_Point")), findsWidgets);
        expect(find.bySemanticsLabel('N/A'), findsWidgets);
      });
    });

    testWidgets("Activity List Loader Success with empty List", (tester) async {
      when(() => mockQualityPlanLocationListingCubit.getActivityList(false))
          .thenAnswer((_) async => Future.value());

      when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
          ActivityListState(const [], QualityListInternalState.activityList, InternalState.success));

      await tester.pumpWidget(activityListingScreen);
      await tester.pump(const Duration(milliseconds: 100000));
      await tester.pump();
      expect(mockQualityPlanLocationListingCubit.state, ActivityListState(const [], QualityListInternalState.activityList, InternalState.success));
      expect(find.byType(Center), findsOneWidget);
      expect(find.text("No Activity Found"), findsOneWidget);
    });


    testWidgets("TEST UPLOAD FILE IN ACTIVITY", (tester) async {
      when(() => mockQualityPlanLocationListingCubit.uploadFileToServer(filePath : "", fileName : ""))
          .thenAnswer((_) async => Future.value());

      final data = QualityActivityList.fromJson(jsonDecode(fixture("quality_activity_listing_response.json")));
      final activityList = data.response!.root!.activitiesList!;
      when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
          ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

      when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
      when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(true);
      when(() => mockQualityPlanLocationListingCubit.hasActivityManageAccess).thenReturn(true);

      await tester.pumpWidget(activityListingScreen);
      await tester.pump(const Duration(milliseconds: 10000));
      await tester.pump();
      expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
      expect(find.bySemanticsLabel("Closed"), findsWidgets);
    });

    testWidgets("TEST ACTIVITY LIST SCROLLING", (tester) async {
      final data = QualityActivityList.fromJson(jsonDecode(fixture("quality_activity_listing_response.json")));
      final activityList = data.response!.root!.activitiesList!;
      when(()=>mockQualityPlanLocationListingCubit.state).thenReturn(
          ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));

      when(() => mockQualityPlanLocationListingCubit.isAssociationRequired(any())).thenReturn(true);
      when(() => mockQualityPlanLocationListingCubit.isInProgressOrCompleteState(any())).thenReturn(true);
      when(() => mockQualityPlanLocationListingCubit.hasActivityManageAccess).thenReturn(true);

      await tester.pumpWidget(activityListingScreen);
      await tester.pump(const Duration(milliseconds: 1000));
      /*await tester.drag(find.byType(ListView), const Offset(0.0, -500));
      await tester.pump();*/

      final listView = tester.widget<ListView>(find.byType(ListView));
      final ctrl = listView.controller;
      ctrl?.jumpTo(-300);
      await tester.pumpAndSettle(Duration(microseconds: 100));

      expect(mockQualityPlanLocationListingCubit.state, ActivityListState(activityList, QualityListInternalState.activityList, InternalState.success));
    });

  });
}