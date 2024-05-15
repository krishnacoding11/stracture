
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/recent_location_widget.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class MockRecentLocationCubit extends MockCubit<FlowState> implements RecentLocationCubit {}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockRecentLocationCubit dummyCubit = MockRecentLocationCubit();

  configureLoginCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<RecentLocationCubit>();
    di.getIt.registerLazySingleton<RecentLocationCubit>(() => dummyCubit);
    AppConfigTestData().setupAppConfigTestData();
  }

  Widget getTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecentLocationCubit>(
          create: (BuildContext context) => di.getIt<RecentLocationCubit>(),
        ),
        BlocProvider<FieldNavigatorCubit>(
          create: (BuildContext context) => di.getIt<FieldNavigatorCubit>(),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: Scaffold(
          body: RecentLocationWidget(),
        ),
      ),
    );
  }

  group('Recent Location Test', ()
  {
    configureLoginCubitDependencies();

    testWidgets('Test Init State', (WidgetTester tester) async {
      when(() =>
      di
          .getIt<RecentLocationCubit>()
          .state).thenReturn(InitialState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
      Widget testDrawerWidget = getTestWidget();
      await tester.pumpWidget(testDrawerWidget);
      Finder titleWidget = find.byKey(Key("key_recent_location_widget_title"));
      expect(titleWidget, findsOneWidget);
    });

    Future<void> errorPopUp(WidgetTester tester) async {
      NavigatorState navigator = tester.state(find.byType(Navigator));
      await RecentLocationWidgetState().showAlertDialog(navigator.context,"No Data" ,ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE,"No Data")) ;
      await tester.pump();
    }

    testWidgets('Test Error PopUp ', (WidgetTester tester) async {
      when(() => di.getIt<RecentLocationCubit>().state).thenReturn(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE,"No Data",code: 401));
      Widget testDrawerWidget = getTestWidget();
      await tester.pumpWidget(testDrawerWidget);
      await errorPopUp(tester);
      await tester.pump();
      Finder findItem = find.byType(AlertDialog);
      expect(findItem, findsOneWidget);
    });

    // Future<void> successState(WidgetTester tester, lastLocation) async {
    //   NavigatorState navigator = tester.state(find.byType(Navigator));
    //   RecentLocationWidgetState().isOnline = true;
    //   RecentLocationWidgetState().onRecentLocationClicked(lastLocation) ;
    //   await tester.pump();
    // }
    //
    // testWidgets('Test Success State ', (WidgetTester tester) async {
    //   String strData = "{\"folder_title\":\"1234\",\"permission_value\":1023,\"isActive\":1,\"folderPath\":\"!!PIN_ANY_APP_TYPE_20_9\\\\1234\",\"folderId\":\"112342369\$\$uVlTQW\",\"folderPublishPrivateRevPref\":0,\"clonedFolderId\":0,\"isPublic\":false,\"projectId\":\"2116416\$\$5Gjy6f\",\"hasSubFolder\":false,\"isFavourite\":false,\"fetchRuleId\":0,\"includePublicSubFolder\":false,\"parentFolderId\":0,\"childfolderTreeVOList\":[],\"pfLocationTreeDetail\":{\"locationId\":44053,\"siteId\":6307,\"isSite\":true,\"parentLocationId\":0,\"docId\":\"0\$\$SreGEv\",\"revisionId\":\"0\$\$XKEuyf\",\"isFileUploaded\":false,\"pageNumber\":0,\"isCalibrated\":false,\"generateURI\":true},\"isPFLocationTree\":true,\"isWatching\":false,\"permissionValue\":0,\"ownerName\":\"Dhaval Vekaria (5226)\",\"isPlanSelected\":false,\"isMandatoryAttribute\":false,\"isShared\":false,\"publisherId\":\"514806\$\$3d3gPh\",\"imgModifiedDate\":\"2022-07-05 05:45:05.6\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000\",\"orgName\":\"Asite Solutions\",\"isSharedByOther\":false,\"permissionTypeId\":0,\"generateURI\":true}";
    //   SiteLocation lastLocation = SiteLocation.fromJson(json.decode(strData));
    //   when(() => di.getIt<RecentLocationCubit>().state).thenReturn(SuccessState([lastLocation,null]));
    //   Widget testDrawerWidget = getTestWidget();
    //   await tester.pumpWidget(testDrawerWidget);
    //   await successState(tester, lastLocation);
    //   await tester.pump();
    //   Finder findItem = find.byType(NavigationUtils);
    //   expect(findItem, findsOneWidget);
    // });
  });
}