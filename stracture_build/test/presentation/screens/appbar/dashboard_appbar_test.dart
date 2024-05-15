import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/sync/sync_state.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/appbar/dashboard_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockSyncCubit mockSyncCubit = MockSyncCubit();
  MockToolbarCubit mockToolbarCubit = MockToolbarCubit();
  late Widget makeTestableWidget;
  MockNavigationCubit mockNavigationCubit = MockNavigationCubit();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() async {
    makeTestableWidget = MultiBlocProvider(
        providers: [
          BlocProvider<SyncCubit>(
            create: (context) => mockSyncCubit,
          ),
          BlocProvider<ToolbarCubit>(
            create: (context) => mockToolbarCubit,
          ),
          BlocProvider<OnlineModelViewerCubit>(
            create: (context) => di.getIt<OnlineModelViewerCubit>(),
          ),
          BlocProvider<NavigationCubit>(
            create: (context) => di.getIt<NavigationCubit>(),
          ),
        ],
        child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: DashboardAppBar(scaffoldKey: _scaffoldKey,),
            )));
  });

  group("Dashboard Appbar widget", () {
    configureCubitDependencies();

    testWidgets('Find tooltip', (tester) async {
      when(() => mockSyncCubit.state).thenReturn(SyncInitial());
      when(() => mockToolbarCubit.state).thenReturn(ToolbarNavigationItemSelectedState(NavigationMenuItemType.home,navigationItems[NavigationMenuItemType.home]?.title));
      await tester.pumpWidget(makeTestableWidget);
      var tooltipWidget = find.byKey(const Key("offline_tooltip"));
      await tester.pump(const Duration(seconds: 1));
      expect(tooltipWidget, findsOneWidget);
    });

    testWidgets('sync icon / tooltip dialog not available for quality and task screen', (WidgetTester tester) async {
      var navigationMenuItemType = NavigationMenuItemType.quality;
      var navigationTitle = navigationItems[navigationMenuItemType]?.title;
      when(() => mockSyncCubit.state).thenReturn(SyncInitial());
      when(() => mockToolbarCubit.state).thenReturn(ToolbarNavigationItemSelectedState(navigationMenuItemType,navigationTitle));
      await tester.pumpWidget(makeTestableWidget);
      var tooltipWidget = find.byKey(const Key("offline_tooltip"));
      await tester.pump(const Duration(seconds: 1));
      expect(tooltipWidget, findsNothing);
      navigationMenuItemType = NavigationMenuItemType.tasks;
      navigationTitle = navigationItems[navigationMenuItemType]?.title;
      await tester.pumpWidget(makeTestableWidget);
      await tester.pump(const Duration(seconds: 1));
      tooltipWidget = find.byKey(const Key("offline_tooltip"));
      expect(tooltipWidget, findsNothing);
    });

    testWidgets('Close more option when navigation drawer opens', (WidgetTester tester) async {
      var navigationMenuItemType = NavigationMenuItemType.quality;
      var navigationTitle = navigationItems[navigationMenuItemType]?.title;
      when(() => mockToolbarCubit.state).thenReturn(ToolbarNavigationItemSelectedState(navigationMenuItemType,navigationTitle));
      await tester.pumpWidget(makeTestableWidget);
      var menuIcon = find.byIcon(Icons.menu);
      await tester.pump();
      expect(menuIcon, findsWidgets);
      await tester.tap(menuIcon);
      await tester.pump();
      when(() => mockNavigationCubit.moreBottomBarView).thenReturn(false);
      Finder moreOptionMenuContainer = find.byKey(Key('key_more_option_menu_container'));
      expect(moreOptionMenuContainer, findsNothing);
    });
  });
}
class MockSyncCubit extends MockCubit<FlowState> implements SyncCubit {}

class MockToolbarCubit extends MockCubit<FlowState> implements ToolbarCubit {}

class MockNavigationCubit extends MockCubit<FlowState> implements NavigationCubit {}

