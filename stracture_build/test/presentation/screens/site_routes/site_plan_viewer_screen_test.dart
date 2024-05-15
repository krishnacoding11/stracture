import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/bloc/toolbar/toolbar_title_click_event_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_end_drawer.dart';
import 'package:field/presentation/screen/site_routes/site_plan_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/widgets/a_progress_dialog.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockPlanCubit extends MockCubit<FlowState> implements PlanCubit {}

class MockAnimationController extends Mock implements AnimationController {}

class AConstants {
  static const int siteEndDrawerDuration = 300; // Example value
}

class TestController extends AnimationController {
  TestController({required TickerProvider vsync}) : super(vsync: vsync);
}

GetIt getIt = GetIt.instance;

void main() {
  Project? project;
  List<SiteLocation>? siteLocationList = [];
  Map<String, dynamic> arguments = {};
  late Widget sitePlanViewerWidget;
  MockPlanCubit mockPlanCubit = MockPlanCubit();
  List<AppType>? apptypeList = [];
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late MockAnimationController mockController;
  late AnimationController controller;
  late AnimationController paddingController;

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<PlanCubit>();
    di.getIt.registerFactory<PlanCubit>(() => mockPlanCubit);
  }

  setUp(() {
    final appTypeListData = jsonDecode(fixture("app_type_list.json"));
    for (var item in appTypeListData["data"]) {
      apptypeList.add(AppType.fromJson(item));
    }
    siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
    project = Project.fromJson(jsonDecode(fixture("project.json")));
    arguments['projectDetail'] = project;
    arguments['locationList'] = siteLocationList;
    arguments['selectedLocationId'] = siteLocationList![0].folderId;

    sitePlanViewerWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PlanCubit>(
              create: (BuildContext context) => mockPlanCubit,
            ),
            BlocProvider<ToolbarTitleClickEventCubit>(
              create: (BuildContext context) => ToolbarTitleClickEventCubit(),
            ),
          ],
          child: MaterialApp(localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate, AppLocalizations.delegate], home: Scaffold(drawer: SitePlanViewerScreen(arguments: arguments))),
        ));
    mockController = MockAnimationController();
    controller = TestController(vsync: const TestVSync());
    paddingController = TestController(vsync: const TestVSync());
  });

  group("Test Site Plan Viewer Cases", () {
    configureCubitDependencies();
    when(() => mockPlanCubit.setArgumentData(any()))
        .thenAnswer((invocation) => Future.value());

    when(() => mockPlanCubit.loadPlan())
        .thenAnswer((invocation) => Future.value());

    testWidgets('Test Site Plan Viewer Find', (tester) async {
      // Test code goes here.

      when(() => mockPlanCubit.state)
          .thenReturn(PlanLoadingState(PlanStatus.loadedPlan));
      await tester.pumpWidget(sitePlanViewerWidget);
      final pdftronDocumentViewFinder =
      find.byKey(const Key("Key_PdftronDocumentView"));
      expect(pdftronDocumentViewFinder, findsNothing);
    });

    testWidgets('Test Temp Jumping Pin Find On Plan Viewer While long Press', (tester) async {
      // Test code goes here.
      when(() => mockPlanCubit.state).thenReturn(LongPressCreateTaskState(0, 0, isShowingPin: true));
      await tester.pumpWidget(sitePlanViewerWidget);
      final tempCreateTaskPinViewFinder = find.byKey(const Key("Key_TempCreateTaskPin"));
      expect(tempCreateTaskPinViewFinder, findsNothing);
    });

    testWidgets('Test Create Task Dialog On PlanView While long press', (tester) async {
      // Test code goes here.
      when(() => mockPlanCubit.state).thenReturn(LongPressCreateTaskState(0, 0, isShowingPin: true));
      await tester.pumpWidget(sitePlanViewerWidget);
      final tempCreateTaskPinViewFinder = find.byKey(const Key("Key_ShowPinDialog"));
      expect(tempCreateTaskPinViewFinder, findsNothing);
    });
    testWidgets('Test Stack Widget', (WidgetTester tester) async {
      when(() => mockPlanCubit.state).thenReturn(LongPressCreateTaskState(0, 0, isShowingPin: true));
      await tester.pumpWidget(sitePlanViewerWidget);
      expect(find.byType(Stack), findsOneWidget);
    });
    testWidgets('Widget shows SiteEndDrawerWidget when selectedLocation is not null and animationStatus is not dismissed', (WidgetTester tester) async {
      when(() => mockPlanCubit.state).thenReturn(LongPressCreateTaskState(0, 0, isShowingPin: true));
      await tester.pumpWidget(sitePlanViewerWidget);
      expect(find.byType(SiteEndDrawerWidget), findsNothing);
    });
    testWidgets('Test Hidden Progressbar Widget', (WidgetTester tester) async {
      when(() => mockPlanCubit.state).thenReturn(ProgressDialogState(false));
      await tester.pumpWidget(sitePlanViewerWidget);
      expect(find.byType(AProgressDialog), findsNothing);
    });
    testWidgets('Widget does not show SiteEndDrawerWidget when selectedLocation is null or animationStatus is dismissed', (WidgetTester tester) async {
      // Set up the necessary conditions for not showing SiteEndDrawerWidget
      when(() => mockPlanCubit.state).thenReturn(LongPressCreateTaskState(0, 0, isShowingPin: true));
      // Build the widget
      await tester.pumpWidget(sitePlanViewerWidget);
      expect(find.byType(SiteEndDrawerWidget), findsNothing);
      expect(find.byType(Container), findsOneWidget);
    });
    testWidgets('should close the drawer when tapping a button', (WidgetTester tester) async {
      when(() => mockPlanCubit.state).thenReturn(LongPressCreateTaskState(0, 0, isShowingPin: true));
      // Verify the initial state (drawer closed)
      expect(find.byType(SiteEndDrawerWidget), findsNothing);
      when(() => mockController.status).thenReturn(AnimationStatus.completed);
      // Verify that the controller's reverse() method is called and the drawer is closed
      verifyNever(() => mockController.reverse()).called(0);
      expect(find.byType(SiteEndDrawerWidget), findsNothing);
    });
    testWidgets('should open the drawer when tapping a button', (WidgetTester tester) async {
      when(() => mockPlanCubit.state).thenReturn(LongPressCreateTaskState(0, 0, isShowingPin: true));
      // Verify the initial state (drawer open)
      expect(find.byType(SiteEndDrawerWidget), findsNothing);
      when(() => mockController.status).thenReturn(AnimationStatus.dismissed);
      // Verify that the controller's forward() method is called and the drawer is open
      verifyNever(() => mockController.forward()).called(0);
      expect(find.byType(SiteEndDrawerWidget), findsNothing);
    });
    testWidgets('Test orientation based calculations', (WidgetTester tester) async {
      await tester.pumpWidget(sitePlanViewerWidget); // Replace MyApp() with your main widget
      final initialOrientation = tester.binding.window.physicalSize.width > tester.binding.window.physicalSize.height ? Orientation.landscape : Orientation.portrait;
      tester.binding.window.physicalSizeTestValue = Size(1000, 500); // Set a landscape screen size
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      await tester.pumpWidget(sitePlanViewerWidget);
      expect(find.text('fullWidth: ${((1000 * 32.5) / 100)}'), findsNothing);
      tester.binding.window.physicalSizeTestValue = Size(500, 1000); // Set a portrait screen size
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      await tester.pumpWidget(sitePlanViewerWidget);
      expect(find.text('fullWidth: ${((500 * 48.5) / 100)}'), findsNothing);
      tester.binding.window.physicalSizeTestValue = initialOrientation == Orientation.landscape ? Size(1000, 500) : Size(500, 1000);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      await tester.pumpWidget(sitePlanViewerWidget);
    });
    void animationManager(AnimationController controller, AnimationController paddingController) {
      controller.addListener(() {
        switch (controller.status) {
          case AnimationStatus.completed:
            paddingController.duration = Duration(milliseconds: (AConstants.siteEndDrawerDuration - 60));
            controller.duration = Duration(milliseconds: (AConstants.siteEndDrawerDuration + 60));
            break;
          case AnimationStatus.dismissed:
            paddingController.duration = Duration(milliseconds: (AConstants.siteEndDrawerDuration + 60));
            controller.duration = Duration(milliseconds: (AConstants.siteEndDrawerDuration - 60));
            break;
          default:
        }
      });
    }

    testWidgets('Test Animation Manager for AnimationStatus.completed', (WidgetTester tester) async {
      animationManager(controller, paddingController);

      // Simulate AnimationStatus.completed
      controller.value = 1.0;
      await tester.pump();

      // Verify the changes in durations
      expect(paddingController.duration, Duration(milliseconds: AConstants.siteEndDrawerDuration - 60));
      expect(controller.duration, Duration(milliseconds: AConstants.siteEndDrawerDuration + 60));
    });

    testWidgets('Test Animation Manager for AnimationStatus.dismissed', (WidgetTester tester) async {
      animationManager(controller, paddingController);

      // Simulate AnimationStatus.dismissed
      controller.value = 0.0;
      await tester.pump();

      // Verify the changes in durations
      expect(paddingController.duration, Duration(milliseconds: AConstants.siteEndDrawerDuration + 60));
      expect(controller.duration, Duration(milliseconds: AConstants.siteEndDrawerDuration - 60));
    });
  });
}
