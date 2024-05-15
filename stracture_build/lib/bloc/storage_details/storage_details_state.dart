part of 'storage_details_cubit.dart';

abstract class StorageDetailsState extends FlowState {}

class PaginationListInitial extends StorageDetailsState {
  @override
  List<Object?> get props => [];
}

class ShowHideDetailsState extends StorageDetailsState {
  final bool isShow;

  ShowHideDetailsState(this.isShow);

  @override
  List<Object?> get props => [isShow];
}

class ModelSelectedState extends StorageDetailsState {
  Model? selectedModel;
  ModelSelectedState(this.selectedModel,);

  @override
  List<Object?> get props => [selectedModel];
}

class RefreshState extends StorageDetailsState {
  @override
  List<Object?> get props => [];
}

class SizeUpdateState extends StorageDetailsState {
  @override
  List<Object?> get props => [];
}

class ProjectUnmarkState extends StorageDetailsState {
  @override
  List<Object?> get props => [];
}
