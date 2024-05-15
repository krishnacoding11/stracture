part of 'side_tool_bar_cubit.dart';

abstract class SideToolBarState extends FlowState {}

class PaginationListInitial extends SideToolBarState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends SideToolBarState {
  @override
  List<Object?> get props => [];
}

class NoState extends SideToolBarState {
  @override
  List<Object?> get props => [];
}

class RulerMenuVisibility extends SideToolBarState {
  final bool isRulerMenuVisible;
  final bool isCameraIconVisible;
  RulerMenuVisibility(this.isRulerMenuVisible,this.isCameraIconVisible);
  @override
  List<Object?> get props => [isRulerMenuVisible,isCameraIconVisible];
}

class CuttingPlaneMenuVisibility extends SideToolBarState {
  final bool isCuttingPlaneMenuVisible;
  final bool isCameraIconVisible;
  CuttingPlaneMenuVisibility(this.isCuttingPlaneMenuVisible,this.isCameraIconVisible);
  @override
  List<Object?> get props => [isCuttingPlaneMenuVisible,isCameraIconVisible];
}

class StepsIconState extends SideToolBarState {
  final bool isSteps;
  StepsIconState(this.isSteps);
  @override
  List<Object?> get props => [isSteps];
}

class MarkerMenuVisibility extends SideToolBarState {
  final bool isMarkerMenuVisible;
  final bool isCameraIconVisible;
  MarkerMenuVisibility(this.isMarkerMenuVisible,this.isCameraIconVisible);
  @override
  List<Object?> get props => [isMarkerMenuVisible,isCameraIconVisible];
}

class ColorPickerState extends SideToolBarState {
  final bool isColorPicker;
  ColorPickerState(this.isColorPicker);

  @override
  List<Object?> get props => [isColorPicker];
}

class SideToolBarEnableState extends SideToolBarState {
  SideToolBarEnableState();

  @override
  List<Object?> get props => [];
}

class PictureInPictureState extends SideToolBarState {
  final bool isPictureInPictureMode;
  PictureInPictureState(this.isPictureInPictureMode);

  @override
  List<Object?> get props => [isPictureInPictureMode];
}



class AppErrorState extends SideToolBarState {
  final AppException exception;
  AppErrorState({required this.exception});

  @override
  List<Object?> get props => [exception];
}
