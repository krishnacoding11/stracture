import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/navigation/navigation_state.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_title_click_event_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/presentation/screen/bottom_navigation/bottom_navigation_page.dart';
import 'package:field/widgets/bottom_navigation_item/ABottomNavigationItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';

class MockNavigationCubit extends MockCubit<FlowState> implements NavigationCubit {}

class MockFlowState extends Fake implements FlowState {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  configureLoginCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<NavigationCubit>();
    di.getIt.registerLazySingleton<NavigationCubit>(() => MockNavigationCubit());
  }

  setUpAll(() {
    configureLoginCubitDependencies();
    registerFallbackValue(MockFlowState());
  });

  group("Bottom Navigation Page Testing", () {
    final navigatorKey = GlobalKey<NavigatorState>();

    Widget testWidget = MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(
          create: (BuildContext context) => di.getIt<NavigationCubit>(),
        ),
        BlocProvider<PlanCubit>(
          create: (BuildContext context) => di.getIt<PlanCubit>(),
        ),
        BlocProvider<ToolbarCubit>(
          create: (BuildContext context) => di.getIt<ToolbarCubit>(),
        ),
        BlocProvider<ToolbarTitleClickEventCubit>(
          create: (BuildContext context) => di.getIt<ToolbarTitleClickEventCubit>(),
        ),
        BlocProvider<RecentLocationCubit>(
          create: (BuildContext context) => di.getIt<RecentLocationCubit>(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
            body: Navigator(
              key: navigatorKey,
              onGenerateRoute: RouteGenerator.generateRoute,
            )

          // BottomNavigationPage(),
        ),
      ),
    );

    testWidgets("Find BottomNavigationPage widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(find.byType(BottomNavigationPage), findsNothing);
    });

    testWidgets("Initially can we pop", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(navigatorKey.currentState?.canPop(), equals(false));
    });

    testWidgets("widgets in Initial route", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(BottomNavigationPage), findsNothing);
    });

    testWidgets("Home navigation", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      navigatorKey.currentState?.pushNamed("Home");
      await tester.pump();
      expect(navigatorKey.currentState?.canPop(), equals(true));
    });

    testWidgets("widgets in Home navigation", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(BottomNavigationPage), findsNothing);
    });

    testWidgets("Site Location navigation from home", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      navigatorKey.currentState?.pushNamed("Site Location");
      await tester.pump();
      expect(navigatorKey.currentState?.canPop(), equals(true));
    });

    testWidgets("widgets in Site Location navigation from home", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(BottomNavigationPage), findsNothing);
    });

    testWidgets("Quality navigation from home", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      navigatorKey.currentState?.pushNamed("Quality");
      await tester.pump();
      expect(navigatorKey.currentState?.canPop(), equals(true));
    });

    testWidgets("widgets in Quality navigation from home", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expectLater(find.byType(BottomNavigationPage), findsNothing);
    });
  });

  group('Bottom navigation bar Testing', () {
    late MockNavigationCubit mockNavigationCubit;
    setUp(() {
      mockNavigationCubit = di.getIt<NavigationCubit>() as MockNavigationCubit;
    });

    /// Building Widget
    Widget testWidget() {
      return MediaQuery(
        data: const MediaQueryData(viewInsets: EdgeInsets.zero),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<NavigationCubit>(
              create: (BuildContext context) => di.getIt<NavigationCubit>(),
            ),
            BlocProvider<MockNavigationCubit>(
              create: (BuildContext context) => MockNavigationCubit(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(
              // body: BottomNavigationPage(),
              bottomNavigationBar: ABottomNavigationBar(
                key: Key('bottom_navigation_bar_test_key'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets("bottom navigation Home icon click", (tester) async {
      when(() => mockNavigationCubit.moreBottomBarView).thenReturn(false);
      when(() => mockNavigationCubit.menuList).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.menuListAll).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);
      when(() => mockNavigationCubit.menuListPrimary).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.more,
      ]);
      when(() => mockNavigationCubit.menuListSecondary).thenReturn([
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.currSelectedItem).thenReturn(NavigationMenuItemType.quality);

      when(() => mockNavigationCubit.state).thenReturn(BottomNavigationMenuListState(mockNavigationCubit.menuListPrimary, 2, ''));
      await tester.pumpWidget(testWidget());
      await tester.pump();
      Finder homeIcon = find.byKey(Key(NavigationMenuItemType.home.value));
      Finder homeText = find.text(NavigationMenuItemType.home.value);
      Finder moreOptionMenuContainer = find.byKey(Key('key_more_option_menu_container'));
      Finder bottomNavigationBarTestKey = find.byKey(Key('bottom_navigation_bar_test_key'));
      Finder bottomNavigationBarType = find.byType(BottomNavigationBar);
      await tester.pump();
      expect(homeIcon, findsOneWidget);
      expect(homeText, findsOneWidget);
      expect(bottomNavigationBarTestKey, findsOneWidget);
      expect(bottomNavigationBarType, findsOneWidget);
      expect(moreOptionMenuContainer, findsNothing);
      await tester.tap(homeIcon);
      await tester.pump();
    });

    testWidgets("bottom navigation Site icon click", (tester) async {
      when(() => mockNavigationCubit.moreBottomBarView).thenReturn(false);
      when(() => mockNavigationCubit.menuList).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.menuListAll).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);
      when(() => mockNavigationCubit.menuListPrimary).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.more,
      ]);
      when(() => mockNavigationCubit.menuListSecondary).thenReturn([
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.currSelectedItem).thenReturn(NavigationMenuItemType.home);

      when(() => mockNavigationCubit.state).thenReturn(BottomNavigationMenuListState(mockNavigationCubit.menuListPrimary, 0, ''));
      await tester.pumpWidget(testWidget());
      await tester.pump();
      Finder sitesIcon = find.byKey(Key(NavigationMenuItemType.sites.value));
      Finder bottomNavigationBarTestKey = find.byKey(Key('bottom_navigation_bar_test_key'));
      await tester.pump();
      expect(sitesIcon, findsOneWidget);
      expect(bottomNavigationBarTestKey, findsOneWidget);
      await tester.tap(sitesIcon);
      await tester.pump();
    });

    testWidgets("bottom navigation Quality icon click", (tester) async {
      when(() => mockNavigationCubit.moreBottomBarView).thenReturn(false);
      when(() => mockNavigationCubit.menuList).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.menuListAll).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);
      when(() => mockNavigationCubit.menuListPrimary).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.more,
      ]);
      when(() => mockNavigationCubit.menuListSecondary).thenReturn([
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.currSelectedItem).thenReturn(NavigationMenuItemType.home);

      when(() => mockNavigationCubit.state).thenReturn(BottomNavigationMenuListState(mockNavigationCubit.menuListPrimary, 0, ''));
      await tester.pumpWidget(testWidget());
      await tester.pump();
      Finder qualityIcon = find.byKey(Key(NavigationMenuItemType.quality.value));
      Finder bottomNavigationBarTestKey = find.byKey(Key('bottom_navigation_bar_test_key'));
      await tester.pump();
      expect(qualityIcon, findsOneWidget);
      expect(bottomNavigationBarTestKey, findsOneWidget);
      await tester.tap(qualityIcon);
      await tester.pump();
    });

    testWidgets("bottom navigation More icon click", (tester) async {
      when(() => mockNavigationCubit.moreBottomBarView).thenReturn(false);
      when(() => mockNavigationCubit.menuList).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.menuListAll).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);
      when(() => mockNavigationCubit.menuListPrimary).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.more,
      ]);
      when(() => mockNavigationCubit.menuListSecondary).thenReturn([
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.currSelectedItem).thenReturn(NavigationMenuItemType.home);

      when(() => mockNavigationCubit.state).thenReturn(BottomNavigationMenuListState(mockNavigationCubit.menuListPrimary, 0, ''));
      await tester.pumpWidget(testWidget());
      await tester.pump();
      Finder moreIcon = find.byKey(Key(NavigationMenuItemType.more.value));
      Finder moreOptionMenuContainer = find.byKey(Key('key_more_option_menu_container'));
      expect(moreIcon, findsOneWidget);
      expect(moreOptionMenuContainer, findsNothing);
      await tester.tap(moreIcon);
      when(() => mockNavigationCubit.state).thenReturn(BottomNavigationToggleState(true, mockNavigationCubit.menuListPrimary.length + 1));
      await tester.pumpWidget(testWidget());
      expect(moreIcon, findsOneWidget);
    });

    testWidgets("bottom navigation Close icon click", (tester) async {
      when(() => mockNavigationCubit.moreBottomBarView).thenReturn(true);
      when(() => mockNavigationCubit.menuList).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.menuListAll).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);
      when(() => mockNavigationCubit.menuListPrimary).thenReturn([
        NavigationMenuItemType.scan,
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.close,
      ]);
      when(() => mockNavigationCubit.menuListSecondary).thenReturn([
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.currSelectedItem).thenReturn(NavigationMenuItemType.home);

      when(() => mockNavigationCubit.state).thenReturn(BottomNavigationMenuListState(mockNavigationCubit.menuListPrimary, 4, ''));
      await tester.pumpWidget(testWidget());
      await tester.pump();
      Finder closeIcon = find.byKey(Key(NavigationMenuItemType.close.value));
      Finder moreOptionMenuContainer = find.byKey(Key('key_more_option_menu_container'));
      expect(closeIcon, findsOneWidget);
      expect(moreOptionMenuContainer, findsOneWidget);
      await tester.tap(closeIcon);
      await tester.pump();
    });

    testWidgets("bottom navigation Models icon click", (tester) async {
      when(() => mockNavigationCubit.moreBottomBarView).thenReturn(true);
      when(() => mockNavigationCubit.menuList).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.menuListAll).thenReturn([
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);
      when(() => mockNavigationCubit.menuListPrimary).thenReturn([
        NavigationMenuItemType.scan,
        NavigationMenuItemType.home,
        NavigationMenuItemType.sites,
        NavigationMenuItemType.quality,
        NavigationMenuItemType.close,
      ]);
      when(() => mockNavigationCubit.menuListSecondary).thenReturn([
        NavigationMenuItemType.models,
        NavigationMenuItemType.tasks,
      ]);

      when(() => mockNavigationCubit.currSelectedItem).thenReturn(NavigationMenuItemType.home);

      when(() => mockNavigationCubit.state).thenReturn(BottomNavigationMenuListState(mockNavigationCubit.menuListPrimary, 4, ''));
      await tester.pumpWidget(testWidget());
      await tester.pump();
      Finder modelsIcon = find.byKey(Key(NavigationMenuItemType.models.value));
      Finder moreOptionMenuContainer = find.byKey(Key('key_more_option_menu_container'));
      expect(modelsIcon, findsOneWidget);
      expect(moreOptionMenuContainer, findsOneWidget);
      await tester.tap(modelsIcon);
      await tester.pump();
    });
  });
}
