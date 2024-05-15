import 'package:bloc_test/bloc_test.dart';
import 'package:field/data/model/measurement_units.dart';
import 'package:field/domain/use_cases/online_model_vewer_use_case.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/side_toolbar/unit_calibration.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;

import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;

import '../../../bloc/mock_method_channel.dart';


class MockOnlineModelViewerCubit extends MockCubit<online_model_viewer.OnlineModelViewerState> implements online_model_viewer.OnlineModelViewerCubit {}

class MockSideToolBarCubit extends MockCubit<FlowState> implements side_tool_bar.SideToolBarCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  final onlineModelViewerCubit = MockOnlineModelViewerCubit();
  final sideToolBarCubit = MockSideToolBarCubit();
  List<MeasurementUnits> areaMeasurementUnit = [
    MeasurementUnits("sqmm", "mm2"),
    MeasurementUnits("sqcm", "cm2"),
    MeasurementUnits("sqm", "m2"),
    MeasurementUnits("sqinch", "in2"),
    MeasurementUnits("sqfeet", "ft2"),
    MeasurementUnits("acre", "Acres"),
    MeasurementUnits("hectare", "Hectare"),
  ];

  List<MeasurementUnits> distanceMeasurementUnit = [
    MeasurementUnits("mm", "MM"),
    MeasurementUnits("cm", "CM"),
    MeasurementUnits("m", "Meter"),
    MeasurementUnits("inch", "Inch"),
    MeasurementUnits("feet", "Feet"),
    MeasurementUnits("fractional_inch", "Fractional Inch"),
    MeasurementUnits("fractional_foot", "Fractional feet & Inch"),
  ];

  List<MeasurementUnits> precisionUnit = [
    MeasurementUnits("zero", "0"),
    MeasurementUnits("one", "0.1"),
    MeasurementUnits("two", "0.01"),
    MeasurementUnits("three", "0.001"),
    MeasurementUnits("four", "0.0001"),
    MeasurementUnits("five", "0.00001"),
  ];

  List<MeasurementUnits> angleMeasurementUnit = [
    MeasurementUnits("Degrees", "Degrees"),
    MeasurementUnits("DegreesMinutesSeconds", "Degrees, Minutes and Seconds"),
    MeasurementUnits("Radians", "Radians"),
  ];

  MeasurementUnits selectedAreaUnit = MeasurementUnits("sqmm", "mm2");
  MeasurementUnits selectedDistanceUnit = MeasurementUnits("mm", "MM");
  MeasurementUnits selectedPrecisionUnit = MeasurementUnits("zero", "0");
  MeasurementUnits selectedAngleUnit = MeasurementUnits("Degrees", "Degrees");

  setUp(() async {
    when(() => onlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
    when(() => sideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
    when(() => onlineModelViewerCubit.selectedModelId).thenReturn("");
    when(() => onlineModelViewerCubit.offlineFilePath).thenReturn([]);
    when(() => onlineModelViewerCubit.bimModelListData).thenReturn([]);
    when(() => onlineModelViewerCubit.isDialogShowing).thenReturn(false);
    when(() => sideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
    when(() => sideToolBarCubit.isWhite).thenReturn(false);
    when(() => sideToolBarCubit.angleMeasurementUnit).thenReturn(angleMeasurementUnit);
    when(() => sideToolBarCubit.areaMeasurementUnit).thenReturn(areaMeasurementUnit);
    when(() => sideToolBarCubit.distanceMeasurementUnit).thenReturn(distanceMeasurementUnit);
    when(() => sideToolBarCubit.precisionUnit).thenReturn(precisionUnit);

    when(() => sideToolBarCubit.selectedAreaUnit).thenReturn(selectedAreaUnit);
    when(() => sideToolBarCubit.selectedDistanceUnit).thenReturn(selectedDistanceUnit);
    when(() => sideToolBarCubit.selectedPrecisionUnit).thenReturn(selectedPrecisionUnit);
    when(() => sideToolBarCubit.selectedAngleUnit).thenReturn(selectedAngleUnit);
    when(() => sideToolBarCubit.selectedAngleUnit).thenReturn(selectedAngleUnit);

    when(() => onlineModelViewerCubit.isShowPdf).thenReturn(false);
    when(() => onlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
    when(() => onlineModelViewerCubit.totalNumbersOfModelsLoad).thenReturn('1');
    when(() => onlineModelViewerCubit.totalNumbersOfModels).thenReturn('1');
    when(() => onlineModelViewerCubit.selectedPdfFileName).thenReturn('');
    when(() => onlineModelViewerCubit.key).thenReturn(GlobalKey<ScaffoldState>());
  });

  configureCubitDependencies() {
    init(test: true);
    getIt.unregister<online_model_viewer.OnlineModelViewerCubit>();
    getIt.unregister<side_tool_bar.SideToolBarCubit>();
    getIt.registerFactory<online_model_viewer.OnlineModelViewerCubit>(() => onlineModelViewerCubit);
    getIt.registerLazySingleton<side_tool_bar.SideToolBarCubit>(() => sideToolBarCubit);
  }

  Widget getUnitCalibrationTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
          create: (BuildContext context) => onlineModelViewerCubit,
        ),
        BlocProvider<side_tool_bar.SideToolBarCubit>(
          create: (BuildContext context) => sideToolBarCubit,
        ),
      ],
      child: MaterialApp(
        navigatorKey: NavigationUtils.mainNavigationKey,
        home: Scaffold(
          body: UnitCalibration(top: 100, left: 200),
        ),
      ),
    );
  }

  group('Unit Calibration Test', () {
    configureCubitDependencies();
    testWidgets('should show Unit Calibration', (WidgetTester tester) async {
      await tester.pumpWidget(getUnitCalibrationTestWidget());
      expect(find.byKey(Key('key_unit_calibration_orientation')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_stack')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_positioned')), findsOneWidget);
    });

    testWidgets('should show Unit Calibration', (WidgetTester tester) async {
      await tester.pumpWidget(getUnitCalibrationTestWidget());
      expect(find.byKey(Key('key_unit_calibration_padding')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_dialog')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_container')), findsOneWidget);
    });

    testWidgets('should show Unit Calibration', (WidgetTester tester) async {
      await tester.pumpWidget(getUnitCalibrationTestWidget());
      expect(find.byKey(Key('key_unit_calibration_column')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_row')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_sized_box_empty')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_icon_button')), findsOneWidget);
      await tester.tap(find.byKey(Key('key_unit_calibration_icon_button')));
      await tester.pump();
    });

    testWidgets('should show Unit Calibration', (WidgetTester tester) async {
      await tester.pumpWidget(getUnitCalibrationTestWidget());
      expect(find.byKey(Key('key_unit_calibration_row_drop_down_distance')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_expanded_custom_drop_down_distance')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_expanded_angle')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_expanded_area')), findsOneWidget);
      expect(find.byKey(Key('key_unit_calibration_expanded_precision')), findsOneWidget);
      expect(find.byKey(Key('key_custom_drop_down')), findsNWidgets(4));
    });
    
    testWidgets('should show Unit Calibration', (WidgetTester tester) async {
      await tester.pumpWidget(getUnitCalibrationTestWidget());
      expect(find.byKey(Key('key_custom_drop_down')), findsNWidgets(4));
      expect(find.byKey(Key('key_custom_drop_down_text_field')), findsNWidgets(4));
      expect(find.byKey(Key('key_custom_drop_down_padding')), findsNWidgets(4));
      expect(find.byKey(Key('key_custom_drop_down_center')), findsNWidgets(4));
      expect(find.byKey(Key('key_custom_drop_down_drop_down_button_hide_underline')), findsNWidgets(4));
      expect(find.byKey(Key('key_drop_down_item')), findsNWidgets(0));
      expect(find.byKey(Key('key_icon_arrow_drop_down')), findsNWidgets(4));
    });

  });
}
