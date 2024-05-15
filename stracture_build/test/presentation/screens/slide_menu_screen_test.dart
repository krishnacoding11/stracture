import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/sidebar/sidebar_cubit.dart';
import 'package:field/bloc/sidebar/sidebar_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/sidebar_menu_screen.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart' as mocktail;
import 'package:provider/provider.dart';

import '../../bloc/mock_method_channel.dart';

class MockSidebarCubit extends MockCubit<FlowState> implements SidebarCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  Widget getTestWidget(GlobalKey scaffoldKey, MockSidebarCubit dummyCubit) {
    return MediaQuery(
      data: const MediaQueryData(),
      child: MultiProvider(
        providers: [
          BlocProvider<SidebarCubit>(
            create: (context) => dummyCubit,
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Scaffold(
              key: scaffoldKey,
              drawer: const SidebarMenuWidget(),
            ),
          );
        },
      ),
    );
  }

  group('Drawer Test', () {
    configureLoginCubitDependencies();

    testWidgets('Drawer open/close test', (WidgetTester tester) async {
      MockSidebarCubit dummyCubit = MockSidebarCubit();
      mocktail.when(() => dummyCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      Widget testDrawerWidget = getTestWidget(scaffoldKey, dummyCubit);
      await tester.pumpWidget(testDrawerWidget);

      scaffoldKey.currentState?.openDrawer();
      await tester.pump();
      expect(scaffoldKey.currentState?.isDrawerOpen, equals(true));
      scaffoldKey.currentState?.closeDrawer();
      await tester.pump();
      expect(scaffoldKey.currentState?.isDrawerOpen, equals(false));
    });

    testWidgets('Drawer Init State test', (WidgetTester tester) async {
      MockSidebarCubit dummyCubit = MockSidebarCubit();
      mocktail.when(() => dummyCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      Widget testDrawerWidget = getTestWidget(scaffoldKey, dummyCubit);
      await tester.pumpWidget(testDrawerWidget);
      scaffoldKey.currentState?.openDrawer();
      await tester.pump();
      expect(scaffoldKey.currentState?.isDrawerOpen, equals(true));
      //Check Init state
      Finder checkProgress = find.byType(ACircularProgress);
      expect(checkProgress, findsOneWidget);
      Finder checkErrorTxt = find.byKey(const Key('ErrorTextViewKey'));
      expect(checkErrorTxt, findsNothing);
    });

    testWidgets('Drawer Loading State test', (WidgetTester tester) async {
      MockSidebarCubit dummyCubit = MockSidebarCubit();
      mocktail.when(() => dummyCubit.state).thenReturn(LoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      Widget testDrawerWidget = getTestWidget(scaffoldKey, dummyCubit);
      await tester.pumpWidget(testDrawerWidget);

      scaffoldKey.currentState?.openDrawer();
      await tester.pump();
      expect(scaffoldKey.currentState?.isDrawerOpen, equals(true));
      //Check Loading state
      await tester.pump();
      Finder checkProgress = find.byType(ACircularProgress);
      expect(checkProgress, findsOneWidget);
      Finder checkErrorTxt = find.byKey(const Key('ErrorTextViewKey'));
      expect(checkErrorTxt, findsNothing);
    });

    testWidgets('Drawer Error State test', (WidgetTester tester) async {
      MockSidebarCubit dummyCubit = MockSidebarCubit();
      mocktail.when(() => dummyCubit.state).thenReturn(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, "Login issue, try with re-login"));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      Widget testDrawerWidget = getTestWidget(scaffoldKey, dummyCubit);
      await tester.pumpWidget(testDrawerWidget);

      scaffoldKey.currentState?.openDrawer();
      await tester.pump();
      expect(scaffoldKey.currentState?.isDrawerOpen, equals(true));
      //Check error state
      await tester.pump();
      Finder checkErrorTxt = find.byKey(const Key('ErrorTextViewKey'));
      expect(checkErrorTxt, findsOneWidget);
      Finder checkProgress = find.byType(ACircularProgress);
      expect(checkProgress, findsNothing);
    });

    //FAIL
    /*testWidgets('Drawer UserMenuList/Success State test', (WidgetTester tester) async {
      MockSidebarCubit dummyCubit = MockSidebarCubit();
      String userFirstname = "Vijay";
      String userImgUrl = "";
      Map<String, String> headersMap = {
        'Cookie': 'ASessionID=asessionid;JSessionID=jsessionid'
      };
      mocktail.when(() => dummyCubit.state).thenReturn(UserProfileSidebarState(userFirstname, userImgUrl, headersMap));
      final scaffoldKey = GlobalKey<ScaffoldState>();
      Widget testDrawerWidget = getTestWidget(scaffoldKey, dummyCubit);
      await tester.pumpWidget(testDrawerWidget);

      scaffoldKey.currentState?.openDrawer();
      await tester.pump();
      expect(scaffoldKey.currentState?.isDrawerOpen, equals(true));
      //Check UserMenuList/Success state
      await tester.pump();
      Finder headerWidget = find.byKey(const Key('SidebarHeaderWidgetKey'));
      expect(headerWidget, findsOneWidget);
      Finder menulistWidget = find.byKey(const Key('MenuListKey'));
      expect(menulistWidget, findsOneWidget);
      Finder footerWidget = find.byKey(const Key('SidebarFooterWidgetKey'));
      expect(footerWidget, findsOneWidget);
    });*/
  });
}