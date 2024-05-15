import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/enums.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/search_task.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_end_drawer.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../bloc/mock_method_channel.dart';
import '../../common/ignore_overflow.dart';
import '../site_plan_viewer_screen_test.dart';

GetIt getIt = GetIt.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  late Widget siteEndDrawerWidget;
  MockPlanCubit mockPlanCubit = MockPlanCubit();
  MockSiteTaskCubit mockSiteTaskCubit = MockSiteTaskCubit();
  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<PlanCubit>();
    di.getIt.registerFactory<PlanCubit>(() => mockPlanCubit);
    di.getIt.unregister<SiteTaskCubit>();
    di.getIt.registerFactory<SiteTaskCubit>(() => mockSiteTaskCubit);
  }

  setUp(() {
    SiteLocation siteLocation = SiteLocation();
    siteEndDrawerWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PlanCubit>(
              create: (context) => mockPlanCubit,
            ),
            BlocProvider<SiteTaskCubit>(
              create: (context) => mockSiteTaskCubit,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SiteEndDrawerWidget(
                key: ValueKey("state"),
                obj: siteLocation,
                onClose: () {},
                isFromFormCreate: true,
                selectedFormId: '123',
                selectedFormCode: 'SITE389',
                animationStatus: AnimationStatus.forward,
              ),
            ),
          ),
        ));
  });

  group("Site End Drawer Widget Cases", () {
    configureCubitDependencies();
    setUp(() {
      SiteTaskCubit.sortValue = ListSortField.title;
      when(() => mockSiteTaskCubit.state).thenReturn(StackDrawerState(StackDrawerOptions.drawerBody));
      when(() => mockPlanCubit.state).thenReturn(FlowState());
      when(() => mockSiteTaskCubit.getTaskListCount()).thenReturn(0);
      when(() => mockSiteTaskCubit.getTotalCount()).thenReturn(0);
      when(() => mockSiteTaskCubit.totalCount).thenReturn(0);
      when(() => mockSiteTaskCubit.filterApplied).thenReturn(false);
      when(() => mockSiteTaskCubit.applyStaticFilter).thenReturn(false);
      when(() => mockSiteTaskCubit.pageFetch(any())).thenAnswer((_) => Future.value(List.empty()));
      when(() => mockSiteTaskCubit.isClosed).thenAnswer((_) => false);

    });
    testWidgets('Text Widget Testing', (tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(siteEndDrawerWidget, Duration(milliseconds: 500));

      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });

    // testWidgets('FloatingActionButton Widget Testing', (tester) async {
    //   FlutterError.onError = ignoreOverflowErrors;
    //   await tester.pumpWidget(siteEndDrawerWidget);
    //
    //   final pdftronDocumentViewFinder = find.byType(FloatingActionButton);
    //   expect(pdftronDocumentViewFinder, findsOneWidget);
    // });

    testWidgets('AnimatedOpacity Widget Testing', (tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(siteEndDrawerWidget);

      final pdftronDocumentViewFinder = find.byType(AnimatedOpacity);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });

    // testWidgets('Positioned Widget Testing', (tester) async {
    //   FlutterError.onError = ignoreOverflowErrors;
    //   await tester.pumpWidget(siteEndDrawerWidget);
    //
    //   final pdftronDocumentViewFinder = find.byType(Positioned);
    //   expect(pdftronDocumentViewFinder, findsWidgets);
    // });

    testWidgets('Test TaskList count', (tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      when(() => mockSiteTaskCubit.getTotalCount()).thenReturn(100);
      when(() => mockSiteTaskCubit.getTaskListCount()).thenReturn(25);
      await tester.pumpWidget(siteEndDrawerWidget);
      Finder count = find.byKey(const Key('key_pagination_count'));
      expect(tester.widget<NormalTextWidget>(count).text, "25 out of 100");
      expect(mockSiteTaskCubit.getTotalCount(), 100);
      expect(mockSiteTaskCubit.getTaskListCount(), 25);
    });

    // testWidgets('Testing Search By Summary Widget', (tester) async {
    //   FlutterError.onError = ignoreOverflowErrors;
    //   when(() => mockSiteTaskCubit.pageFetch(any())).thenAnswer((_) => Future.value(List.empty()));
    //   when(() => mockSiteTaskCubit.getTaskListCount()).thenReturn(0);
    //   when(() => mockSiteTaskCubit.getTotalCount()).thenReturn(0);
    //   when(() => mockSiteTaskCubit.state).thenReturn(StackDrawerState(StackDrawerOptions.drawerBody));
    //   when(() => mockPlanCubit.state).thenReturn(FlowState());
    //   when(() => mockSiteTaskCubit.getRecentSearchedSiteList()).thenAnswer((_) async => Future.value(List.empty()));
    //   await tester.pumpWidget(siteEndDrawerWidget);
    //   final searchTaskWidget = find.byType(SearchTask);
    //   expect(searchTaskWidget, findsWidgets);
    // });

    // testWidgets('Test Expand and Collapse Drawer Button Widget', (tester) async {
    //   FlutterError.onError = ignoreOverflowErrors;
    //   when(() => mockSiteTaskCubit.getTotalCount()).thenReturn(100);
    //   when(() => mockSiteTaskCubit.getTaskListCount()).thenReturn(25);
    //   await tester.pumpWidget(siteEndDrawerWidget);
    //
    //   final collapseExpandBtnInk = find.byKey(const Key("collapse_expand_button_Ink"));
    //   expect(collapseExpandBtnInk, findsOneWidget);
    //   expect(tester.widget<InkWell>(collapseExpandBtnInk).onTap, isNotNull);
    //   final collapseScreenIcon = find.byIcon(Icons.fullscreen_exit);
    //   expect(collapseScreenIcon, findsOneWidget);
    //   final fullscreenIcon = find.byIcon(Icons.fullscreen);
    //   expect(fullscreenIcon, findsNothing);
    // });

    // testWidgets('Test Expand and Collapse Drawer Button Widget with animation reverse', (tester) async {
    //   SiteLocation siteLocation = SiteLocation();
    //   siteEndDrawerWidget = MediaQuery(
    //       data: const MediaQueryData(),
    //       child: MultiBlocProvider(
    //         providers: [
    //           BlocProvider<PlanCubit>(
    //             create: (context) => mockPlanCubit,
    //           ),
    //         ],
    //         child: MaterialApp(
    //           localizationsDelegates: const [
    //             GlobalMaterialLocalizations.delegate,
    //             GlobalWidgetsLocalizations.delegate,
    //             GlobalCupertinoLocalizations.delegate,
    //             AppLocalizations.delegate
    //           ],
    //           supportedLocales: const [Locale('en')],
    //           home: Scaffold(
    //             resizeToAvoidBottomInset: false,
    //             body: SiteEndDrawerWidget(
    //               key: ValueKey("state"),
    //               obj: siteLocation,
    //               onClose: () {},
    //               isFromFormCreate: true,
    //               selectedFormId: '123',
    //               selectedFormCode: 'SITE389',
    //               animationStatus: AnimationStatus.reverse,
    //             ),
    //           ),
    //         ),
    //       ));
    //
    //   FlutterError.onError = ignoreOverflowErrors;
    //   when(() => mockSiteTaskCubit.getTotalCount()).thenReturn(100);
    //   when(() => mockSiteTaskCubit.getTaskListCount()).thenReturn(25);
    //   await tester.pumpWidget(siteEndDrawerWidget);
    //
    //   final collapseExpandBtnInk = find.byKey(const Key("collapse_expand_button_Ink"));
    //   expect(collapseExpandBtnInk, findsOneWidget);
    //   expect(tester.widget<InkWell>(collapseExpandBtnInk).onTap, isNotNull);
    //   final collapseScreenIcon = find.byIcon(Icons.fullscreen_exit);
    //   expect(collapseScreenIcon, findsNothing);
    //   final fullscreenIcon = find.byIcon(Icons.fullscreen);
    //   expect(fullscreenIcon, findsOneWidget);
    // });

    // testWidgets('Test Close Drawer Panel Button Widget', (tester) async {
    //   FlutterError.onError = ignoreOverflowErrors;
    //   when(() => mockSiteTaskCubit.getTotalCount()).thenReturn(100);
    //   when(() => mockSiteTaskCubit.getTaskListCount()).thenReturn(25);
    //   await tester.pumpWidget(siteEndDrawerWidget);
    //
    //   final drawerBtnInk = find.byKey(const Key("drawerClosBtn"));
    //   expect(drawerBtnInk, findsOneWidget);
    //   expect(tester.widget<FloatingActionButton>(drawerBtnInk).onPressed, isNotNull);
    //   final collapseScreenIcon = find.byIcon(Icons.fullscreen_exit);
    //   expect(collapseScreenIcon, findsOneWidget);
    // });

  });
}

class MockSiteTaskCubit extends MockCubit<FlowState> implements SiteTaskCubit {}
