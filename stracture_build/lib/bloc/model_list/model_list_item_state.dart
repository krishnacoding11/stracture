import 'package:equatable/equatable.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';

import 'model_list_item_cubit.dart';

abstract class ModelListItemState extends Equatable {}

class ExpandedState extends ModelListItemState {
  final bool isExpanded;

  ExpandedState(this.isExpanded);

  @override
  List<Object?> get props => [isExpanded];
}

class FloorExpandedState extends ModelListItemState {
  final bool isExpanded;

  FloorExpandedState(this.isExpanded);

  @override
  List<Object?> get props => [isExpanded];
}

class TabChangeState extends ModelListItemState {
  final bool isModelSelected;

  TabChangeState(this.isModelSelected);

  @override
  List<Object?> get props => [isModelSelected];
}

class CalibrateFileLoadingState extends ModelListItemState {
  final bool isLoading;

  CalibrateFileLoadingState(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class FloorFileLoadingState extends ModelListItemState {
  final bool isLoading;

  FloorFileLoadingState(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class SingleFloorDeletedState extends ModelListItemState {
  final bool isDeleted;

  SingleFloorDeletedState(this.isDeleted);

  @override
  List<Object?> get props => [isDeleted];
}

class FloorCheckedState extends ModelListItemState {
  final bool isChecked;
  final BimModel bimModel;

  FloorCheckedState(this.isChecked, this.bimModel);

  @override
  List<Object?> get props => [isChecked, bimModel];
}

class FileChoppingState extends ModelListItemState {
  @override
  List<Object?> get props => [];
}

class FileChoppedState extends ModelListItemState {
  @override
  List<Object?> get props => [];
}


class SendAdministratorState extends ModelListItemState {
  final dynamic responseData;

  SendAdministratorState({required this.responseData});

  @override
  List<Object?> get props => [responseData];
}

class ModelLoadingState extends ModelListItemState {
  final ModelStatus modelStatus;

  ModelLoadingState(this.modelStatus);

  @override
  List<Object?> get props => [modelStatus];
}

class UnableChoppedState extends ModelListItemState {
  @override
  List<Object?> get props => [];
}


class DownloadedProgressState extends ModelListItemState {
  final int progress;

  DownloadedProgressState(this.progress);

  @override
  List<Object?> get props => [];
}

class LoadingFavCheckState extends ModelListItemState {
  LoadingFavCheckState();
  @override
  List<Object?> get props => [];
}

class FavCheckedState extends ModelListItemState {
  FavCheckedState();
  @override
  List<Object?> get props => [];
}

class CalibrateFileCheckState extends ModelListItemState {
  final List<CalibrationDetails> calibratedList;

  CalibrateFileCheckState(this.calibratedList);

  @override
  List<Object?> get props => [calibratedList];
}
