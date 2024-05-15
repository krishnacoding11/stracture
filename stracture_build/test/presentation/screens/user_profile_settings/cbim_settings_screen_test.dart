import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_state.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/screen/user_profile_setting/cbim_settings_screen.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';

class MockCBIMSettingsCubit extends MockCubit<CBIMSettingsState> implements CBIMSettingsCubit {}

class MockOnlineModelViewerCubit extends MockCubit<OnlineModelViewerState> implements OnlineModelViewerCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockCBIMSettingsCubit modeCBIMSettingsCubit = MockCBIMSettingsCubit();
  MockOnlineModelViewerCubit mockOnlineModelViewerCubit = MockOnlineModelViewerCubit();
  configureLoginCubitDependencies() {
    init(test: true);
    getIt.unregister<CBIMSettingsCubit>();
    getIt.registerLazySingleton<CBIMSettingsCubit>(() => modeCBIMSettingsCubit);
  }

  Widget _testbleWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CBIMSettingsCubit>(
          create: (BuildContext context) => modeCBIMSettingsCubit,
        ),
        BlocProvider<OnlineModelViewerCubit>(
          create: (BuildContext context) => mockOnlineModelViewerCubit,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocBuilder<CBIMSettingsCubit, CBIMSettingsState>(builder: (con, state) {
          return Scaffold(
            body: CBimSettingsScreen(),
          );
        }),
      ),
    );
  }

  group("cbim setting widget", () {
    configureLoginCubitDependencies();
    when(() => modeCBIMSettingsCubit.selectedSliderValue).thenReturn(6);
    when(() => modeCBIMSettingsCubit.min).thenReturn(1);
    when(() => modeCBIMSettingsCubit.max).thenReturn(10);
    when(() => modeCBIMSettingsCubit.state).thenReturn(PageInitialState());
    testWidgets('Cbim settings widget test 1 ', (WidgetTester tester) async {
      await tester.pumpWidget(_testbleWidget());
      final paddingFinder1 = find.byKey(Key("cBimSettingsScreen_padding_1"));
      expect(paddingFinder1, findsOneWidget);
      final padding = tester.widget<Padding>(paddingFinder1);
      expect(padding.padding, const EdgeInsets.all(16));
      final columnFinder = find.byType(Column);
      final column = tester.widget<Column>(columnFinder);
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      expect(find.text('Models Settings'), findsOneWidget);

    });
    testWidgets('Cbim settings widget test 2 ', (WidgetTester tester) async {
      await tester.pumpWidget(_testbleWidget());
      final listContainer = find.byKey(Key("cBimSettingsScreen_cBIMSettingListItem"));
      final container = tester.widget<Container>(listContainer);

      expect(container.padding, const EdgeInsets.only(top: 4, left: 16));
      expect(listContainer, findsOneWidget);

    });

    testWidgets('Cbim settings widget test 2 ', (WidgetTester tester) async {

      await tester.pumpWidget(_testbleWidget());
      Utility.isTablet=false;
      Utility.isPhone=true;
      final listContainer = find.byKey(Key("cBimSettingsScreen_cBIMSettingListItem"));
      final container = tester.widget<Container>(listContainer);
      expect(container.padding, const EdgeInsets.only(top: 4, left: 16));
      expect(listContainer, findsOneWidget);

    });

    testWidgets('Slider updates value and invokes cubit', (WidgetTester tester) async {
      await tester.pumpWidget(_testbleWidget());

      expect(
        tester.widget<Slider>(find.byType(Slider)).value,
        modeCBIMSettingsCubit.selectedSliderValue,
      );

      await tester.drag(find.byType(Slider), const Offset(600.0, 0.0));

      expect(modeCBIMSettingsCubit.selectedSliderValue, 6);
      verify(() => modeCBIMSettingsCubit.onSliderChange(any())).called(1);
      verifyNever(() => mockOnlineModelViewerCubit.setNavigationSpeed(newValue: any(named: 'newValue'))).called(0);
    });
  });
}
