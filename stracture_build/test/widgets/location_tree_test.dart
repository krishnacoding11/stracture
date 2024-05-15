import 'dart:convert';

import 'package:field/bloc/site/location_tree_cubit.dart';
import 'package:field/bloc/site/location_tree_state.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/remote/site/site_remote_repository.dart';
import 'package:field/data/repository/site/location_tree_repository.dart';
import 'package:field/domain/use_cases/site/site_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/widgets/alisttile_location.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/location_tree.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';
import '../presentation/screens/common/ignore_overflow.dart';

GetIt getIt = GetIt.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late LocationTreeCubit locationTreeCubit;
  final mockSiteUseCase = MockSiteUseCase();
  late Widget locationTreeWidget;
  Project project = Project.fromJson(jsonDecode(fixture("project.json")));
  Map<String, dynamic> arguments = {};
  arguments['isFrom'] = LocationTreeViewFrom.projectList;
  arguments['projectDetail'] = project;
  arguments['listBreadCrumb'] = [project];

  configureLocationTreeCubitDependencies() {
    di.getIt.unregister<LocationTreeCubit>();
    di.getIt.unregister<SiteUseCase>();
    di.getIt.unregister<SiteRemoteRepository>();
    di.getIt.registerFactory<LocationTreeCubit>(() => locationTreeCubit);
    di.getIt.registerLazySingleton<SiteUseCase>(() => mockSiteUseCase);
    di.getIt.registerLazySingleton<SiteRemoteRepository>(() => SiteRemoteRepository());
    AppConfigTestData().setupAppConfigTestData();
  }

  Widget makeTestableWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationTreeCubit>(
          create: (BuildContext context) => locationTreeCubit,
        ),
        BlocProvider<SyncCubit>(
          create: (BuildContext context) => di.getIt<SyncCubit>(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: LocationTreeWidget(arguments),
      ),
    );
  }

  setUpAll(() {
    di.init(test: true);
  });

  setUp(() {
    configureLocationTreeCubitDependencies();
    locationTreeWidget = makeTestableWidget();
    locationTreeCubit = LocationTreeCubit();
  });
  assumeLocationsAvailableInOffline() {
    for (int i = 0; i < 5; i++) {
      SiteLocation location = locationTreeCubit.listSiteLocation[i];
      location.isMarkOffline = true;
      location.syncStatus = ESyncStatus.success;
      location.canRemoveOffline = true;
    }
  }

  group("Location Tree widget", () {
    testWidgets('Testing if theme available', (WidgetTester tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Theme), findsWidgets);
      expect(find.widgetWithText(NormalTextWidget, project.projectName!), findsOneWidget);
    });
    testWidgets('Testing if theme EdgeInsets', (WidgetTester tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(EdgeInsets), findsNothing);
    });

    testWidgets('Test case find Location List widget', (WidgetTester tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(Key("LocationList")), findsOneWidget);
    });
    testWidgets('Test case find Close Icon', (WidgetTester tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.close_sharp), findsOneWidget);
    });

    testWidgets('Test case Click UnMark Location Icon', (WidgetTester tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));

      assumeLocationsAvailableInOffline();

      Finder _unMarkBtnClicked = find.byIcon(Icons.folder_delete_outlined);
      expect(_unMarkBtnClicked, findsOneWidget);

      await tester.tap(_unMarkBtnClicked);
      await tester.pump();

      expect(find.text("Offline Locations"), findsOneWidget);

      Finder _deleteBtnClicked = find.byIcon(Icons.delete_outline_sharp, skipOffstage: false);
      expect(_deleteBtnClicked, findsAtLeastNWidgets(3));

      await tester.tap(_deleteBtnClicked.first);
      await tester.pump();

      expect(find.text("Remove Offline Records"), findsOneWidget);

      await tester.tap(_deleteBtnClicked.first);
      await tester.pump();
    });

    testWidgets('Test case for click on mark the location enable button', (widgetTester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await widgetTester.pumpWidget(locationTreeWidget);
      await widgetTester.pump(const Duration(seconds: 1));
      Finder _finder = find.byIcon(Icons.cloud_download_outlined);
      expect(_finder, findsOneWidget);
      await widgetTester.tap(_finder);
      await widgetTester.pump();
    });

    testWidgets('Test case for click on Select All Text', (widgetTester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await widgetTester.pumpWidget(locationTreeWidget);
      await widgetTester.pump(const Duration(seconds: 1));

      await widgetTester.tap(find.byIcon(Icons.cloud_download_outlined));
      await widgetTester.pump();

      Finder _finder = find.text("Select All");
      expect(_finder, findsOneWidget);

      await widgetTester.tap(_finder);
      await widgetTester.pump();
    });
    testWidgets('Location Item Count', (WidgetTester tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(AListTile, skipOffstage: false), findsAtLeastNWidgets(5));
      expect(locationTreeCubit.listSiteLocation.length, 69);
    });

    testWidgets('Click on Location Item', (WidgetTester tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));
      Finder _finder = find.byType(AListTile, skipOffstage: false);
      expect(_finder, findsAtLeastNWidgets(5));

      await tester.tap(_finder.first);
      await tester.pumpAndSettle(const Duration(microseconds: 100));
    });

    testWidgets('Select Location : Mark Location for Offline', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.cloud_download_outlined));
      await tester.pumpAndSettle(const Duration(microseconds: 100));

      Finder _finder = find.byType(AListTile, skipOffstage: false);
      await tester.tap(_finder.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(microseconds: 100));
    });

    testWidgets('Selected Location : find Save Button & Click ', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.cloud_download_outlined));
      await tester.pumpAndSettle(const Duration(microseconds: 100));

      Finder _finder = find.byType(AListTile, skipOffstage: false);
      await tester.tap(_finder.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(microseconds: 100));

      SiteLocation location = locationTreeCubit.listSiteLocation[0];
      location.isCheckForMarkOffline = true;
      locationTreeCubit.emitState(CheckboxClickState(true));

      Finder _saveBtnFinder = find.text("Save");
      expect(_saveBtnFinder, findsOneWidget);
      await tester.tap(_saveBtnFinder);
      await tester.pumpAndSettle();

      // FlutterError.onError = ignoreOverflowErrors;
      // Finder _finderDownloadSize = find.byKey(Key("DownloadSize Dialog"));
      // expect(_finderDownloadSize, findsOneWidget);
    });

    testWidgets("View Site Plan from Listing", (tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));
      Finder _finder = find.byType(AListTile, skipOffstage: false);
      expect(_finder, findsAtLeastNWidgets(5));

      await tester.tap(_finder.first);
      await tester.pumpAndSettle(const Duration(microseconds: 100));

      Finder _selectBtnFinder = find.byType(AElevatedButtonWidget);
      expect((_selectBtnFinder.evaluate().first.widget as AElevatedButtonWidget).btnLabel, "Select");

      await tester.tap(_selectBtnFinder);
      await tester.pump();
    });

    testWidgets("Select button is enabled for Project Level", (tester) async {
      await tester.pumpWidget(locationTreeWidget);
      await tester.pump(const Duration(seconds: 1));
      Finder _selectBtnFinder = find.byType(AElevatedButtonWidget);
      expect((_selectBtnFinder.evaluate().first.widget as AElevatedButtonWidget).btnLabel, "Select");
      expect((_selectBtnFinder.evaluate().first.widget as AElevatedButtonWidget).onPressed, isNotNull);
    });
  });
}

class MockSiteUseCase extends Mock implements SiteUseCase {
  @override
  Future<Result> getLocationTree(Map<String, dynamic> request) {
    return Future(() => SUCCESS(SiteLocation.jsonToList(fixture("site_location_list.json")), null, 200, requestData: NetworkRequestBody.json(request)));
  }

  @override
  Future<bool> canRemoveOfflineLocation(String? projectId, List<String> locationIds) async {
    return Future.value(true);
  }

  Future<bool> isProjectLocationMarkedOffline(String? projectId) async {
    return Future.value(false);
  }
}
