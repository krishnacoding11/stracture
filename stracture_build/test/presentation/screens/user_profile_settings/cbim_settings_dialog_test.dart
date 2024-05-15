import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_state.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/screen/user_profile_setting/cbim_settings_dialog.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
    Utility.isTablet = true;
  }

  Widget _testableWidget() {
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
            body: CBimSettingsDialog(),
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
    when(() => mockOnlineModelViewerCubit.state).thenReturn(PaginationListInitial());
    testWidgets('Cbim settings widget test 1 ', (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget());
      expect(find.byType(OrientationBuilder), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      final paddingFinder1 = find.byKey(Key("cBimSettingDialog_padding_1"));
      expect(paddingFinder1, findsOneWidget);
      final padding = tester.widget<Padding>(paddingFinder1);
      expect(padding.padding, const EdgeInsets.fromLTRB(16, 8, 16, 16));
      final columnFinder = find.byKey(Key("cBimSettingDialog_Column_1"));
      expect(columnFinder, findsOneWidget);
      final column = tester.widget<Column>(columnFinder);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      expect(column.mainAxisSize,MainAxisSize.min );
      expect(column.mainAxisAlignment, MainAxisAlignment.start);
      final rowFinder = find.byKey(Key("cBimSettingDialog_row_1"));
      expect(rowFinder, findsOneWidget);
      final expandedFinder = find.byKey(Key("cBimSettingDialog_expanded_1"));
      expect(expandedFinder, findsOneWidget);
      final iconButtonFinder = find.byKey(Key("cBimSettingDialog_iconButton"));
      expect(iconButtonFinder, findsOneWidget);
      expect(find.text('Navigation Speed'), findsOneWidget);
    });
    testWidgets('Cbim settings widget test 2 ', (WidgetTester tester) async {
        await tester.pumpWidget(_testableWidget());
      final listContainer = find.byKey(Key("cBimSettingDialog_cBIMSettingListItem"));
      final container = tester.widget<Container>(listContainer);
      expect(container.padding,  const EdgeInsets.only(top: 16, left: 16, bottom: 16));
      expect(listContainer, findsOneWidget);
    });

    testWidgets('Slider updates value and invokes cubit', (WidgetTester tester) async {
      await tester.pumpWidget(_testableWidget());

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
