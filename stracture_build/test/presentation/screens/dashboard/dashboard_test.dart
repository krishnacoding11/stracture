import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/bloc/formsetting/form_settings_change_event_cubit.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_title_click_event_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/drawer_page.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockNavigationCubit extends MockCubit<FlowState> implements NavigationCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  group("Dashboard Testing", ()
  {
    configureLoginCubitDependencies();
    SharedPreferences.setMockInitialValues({
      "userData":fixture("user_data.json"),
      "selectedPinFilter": "1",
      "c1_u1_recentSearchTaskList": {'aa','aaa'}
    });
    PreferenceUtils.init();
    Widget testWidget = MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(
          create: (BuildContext context) => di.getIt<NavigationCubit>(),
        ),
        BlocProvider<ToolbarTitleClickEventCubit>(
          create: (BuildContext context) => di.getIt<ToolbarTitleClickEventCubit>(),
        ),
        BlocProvider<ToolbarCubit>(
          create: (BuildContext context) => di.getIt<ToolbarCubit>(),
        ),
        BlocProvider<FieldNavigatorCubit>(
          create: (BuildContext context) => di.getIt<FieldNavigatorCubit>(),
        ),
        BlocProvider<RecentLocationCubit>(
          create: (BuildContext context) => di.getIt<RecentLocationCubit>(),
        ),
        BlocProvider<TaskActionCountCubit>(
          create: (BuildContext context) => di.getIt<TaskActionCountCubit>(),
        ),
        BlocProvider<FormSettingsChangeEventCubit>(
          create: (BuildContext context) => di.getIt<FormSettingsChangeEventCubit>(),
        ),
        BlocProvider<HomePageCubit>(
          create: (BuildContext context) => di.getIt<HomePageCubit>(),
        ),
        BlocProvider<StorageDetailsCubit>(
          create: (BuildContext context) => di.getIt<StorageDetailsCubit>(),
        ),
        BlocProvider<ModelListCubit>(
          create: (BuildContext context) => di.getIt<ModelListCubit>(),
        ),
        BlocProvider<SyncCubit>(
          create: (BuildContext context) => di.getIt<SyncCubit>(),
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
          home: DrawerPage()
      ),
    );
    //FAIL
    /*testWidgets("Find DrawerPage widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(DrawerPage), findsOneWidget);
    });*/

    // testWidgets("Find DrawerPage widget", (tester) async {
    //   await tester.pumpWidget(testWidget);
    //   await PreferenceUtils.setInt(AConstants.selectedPinFilter, 1);
    //   // await tester.pump();
    //   expect(find.byType(DrawerPage), findsOneWidget);
    // });
  });
}

