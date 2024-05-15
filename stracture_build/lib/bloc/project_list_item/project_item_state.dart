part of 'project_item_cubit.dart';

@immutable
abstract class ProjectItemState extends FlowState {}

class ProjectItemInitial extends ProjectItemState {

  @override
  List<Object?> get props => [];
}

class ItemDeleteRequestState extends ProjectItemState {

  ItemDeleteRequestState({required this.projectId, required this.isProcessing});
  String projectId = "";
  bool isProcessing = false;

  @override
  List<Object?> get props => [projectId, isProcessing];
}

class ItemDeleteRequestCancelState extends ProjectItemState {

  ItemDeleteRequestCancelState({required this.projectId});
  String projectId = "";

  @override
  List<Object?> get props => [projectId];
}

class ItemDeleteRequestSuccessState extends ProjectItemState {

  ItemDeleteRequestSuccessState({required this.projectId});
  String projectId = "";

  @override
  List<Object?> get props => [projectId];
}
