import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as sideCubit;

import 'package:field/exception/app_exception.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late SideToolBarCubit sideToolBarCubit;

  setUp(() {
    sideToolBarCubit = SideToolBarCubit();
  });

  tearDown(() {
    sideToolBarCubit.close();
  });

  group('SideToolBarCubit', () {
    test('showPictureInPictureMode toggles isPictureInPictureMode', () {
      expect(sideToolBarCubit.isPictureInPictureMode, false);
      sideToolBarCubit.showPictureInPictureMode();
      expect(sideToolBarCubit.isPictureInPictureMode, true);
      sideToolBarCubit.showPictureInPictureMode();
      expect(sideToolBarCubit.isPictureInPictureMode, false);
    });

    blocTest<SideToolBarCubit, FlowState>(
      'emits PictureInPictureState when showPictureInPictureMode is called',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.showPictureInPictureMode(),
      expect: () => [isA<PictureInPictureState>()],
    );

    blocTest<SideToolBarCubit, FlowState>(
      'emits isCuttingPlaneMenuVisible',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.isCuttingPlaneMenuVisible(true),
      expect: () => [isA<CuttingPlaneMenuVisibility>()],
    );

    blocTest<SideToolBarCubit, FlowState>(
      'emits isSideToolBarEnable',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.isSideToolBarEnable(),
      expect: () => [isA<SideToolBarEnableState>()],
    );

    blocTest<SideToolBarCubit, FlowState>(
      'emits isMarkerMenuVisible',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.isMarkerMenuVisible(true),
      expect: () => [isA<MarkerMenuVisibility>()],
    );

    blocTest<SideToolBarCubit, FlowState>(
      'emits RulerMenuVisibility state when isRulerMenuVisible is called',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.isRulerMenuVisible(true),
      expect: () => [isA<RulerMenuVisibility>()],
    );

    blocTest<SideToolBarCubit, FlowState>(
      'emits StepsIconState when showStepsIcon is called',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.showStepsIcon(),
      expect: () => [isA<StepsIconState>()],
    );

    blocTest<SideToolBarCubit, FlowState>(
      'isThereCurrentDialogShowing returns correct value',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.isThereCurrentDialogShowing(MockBuildContext()),
      expect: () => [],
    );

    blocTest<SideToolBarCubit, FlowState>('AppErrorState state test',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.emit(AppErrorState(exception:AppException(message: "test Message"))),
      expect: () => [isA<AppErrorState>()],
    );

    blocTest<SideToolBarCubit, FlowState>('ColorPickerState state test',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.emit(ColorPickerState(true)),
      expect: () => [isA<ColorPickerState>()],
    );

    blocTest<SideToolBarCubit, FlowState>('LoadingState state test',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.emit(sideCubit.LoadingState()),
      expect: () => [isA<sideCubit.LoadingState>()],
    );

    blocTest<SideToolBarCubit, FlowState>('PaginationListInitial state test',
      build: () => sideToolBarCubit,
      act: (cubit) => cubit.emit(sideCubit.PaginationListInitial()),
      expect: () => [isA<sideCubit.PaginationListInitial>()],
    );
  });
}
