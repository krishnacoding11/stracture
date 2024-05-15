part of 'online_model_viewer_cubit.dart';

abstract class OnlineModelViewerState extends Equatable {}

class PaginationListInitial extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class ShowPopUpState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class HIdePopUpState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class CalibrationListLoadingState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class FileAssociationLoadingState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class CalibrationListResponseSuccessState extends OnlineModelViewerState {
  final List<dynamic> items;

  CalibrationListResponseSuccessState({required this.items});

  @override
  List<Object?> get props => [items];
}

class CalibrationListPresentState extends OnlineModelViewerState {
  CalibrationListPresentState();

  @override
  List<Object?> get props => [];
}

class LoadingModelsState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class LoadedModelState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class DeletedModelState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class WebGlContextLostState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class FailedModelState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class InsufficientStorageState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class GetFileAssociationListState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class TimeoutWarningState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class TimeOutState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class NormalWebState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class UnitCalibrationUpdateState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class JoyStickPositionState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class ShowBackGroundWebviewState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class WebsocketConnectionClosedState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class ModelLoadFailureState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class LoadedAllModelState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class LoadedSuccessfulAllModelState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class AddPinOnModelState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class LoadedSuccessfullyState extends OnlineModelViewerState {
  @override
  List<Object?> get props => [];
}

class GetJoystickCoordinatesState extends OnlineModelViewerState {
  final String bIsInside;
  final String longPress;

  GetJoystickCoordinatesState(this.bIsInside, this.longPress);

  @override
  List<Object?> get props => [bIsInside, longPress];
}


class LoadedState extends OnlineModelViewerState {
  LoadedState();

  @override
  List<Object?> get props => [];
}

class NormalState extends OnlineModelViewerState {
  NormalState();

  @override
  List<Object?> get props => [];
}

class MenuOptionLoadedState extends OnlineModelViewerState {
  final bool isEditMenuVisible;
  final bool isMarkupMenuVisible;
  final bool isRulerMenuVisible;
  final bool isCuttingPlaneMenuVisible;
  final bool isShowPdfView;
  final bool isShowPdfViewFullScreen;
  final bool isShowColorPopup;
  final String pdfFileName;
  MenuOptionLoadedState(this.isEditMenuVisible, this.isMarkupMenuVisible, this.isRulerMenuVisible, this.isCuttingPlaneMenuVisible, this.isShowPdfView, this.isShowPdfViewFullScreen, this.isShowColorPopup, this.pdfFileName);

  @override
  List<Object?> get props => [isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShowPdfView, isShowPdfViewFullScreen, isShowColorPopup, pdfFileName];
}

class ErrorState extends OnlineModelViewerState {
  final AppException exception;
  ErrorState({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class CreateTaskNavigationState extends OnlineModelViewerState {
  final String url;
  final Map<String, dynamic> data;
  final Datum appType;

  CreateTaskNavigationState(this.url, this.data, this.appType);

  @override
  List<Object?> get props => [DateTime.now().toString(), url, data];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}
