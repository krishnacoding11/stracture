part of 'bim_project_model_cubit.dart';

abstract class BimProjectModelListState extends Equatable {}

class PaginationListInitial extends BimProjectModelListState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends BimProjectModelListState {
  @override
  List<Object?> get props => [];
}

class LoadedState extends BimProjectModelListState {
  LoadedState();

  @override
  List<Object?> get props => [];
}

class FillState extends BimProjectModelListState {
  final List<BimProjectModel> items;
  final Map<String, dynamic> requestData;
  FillState({required this.items, required this.requestData});
  @override
  List<Object?> get props => [];
}

class ErrorState extends BimProjectModelListState {
  final AppException exception;
  ErrorState({required this.exception});

  @override
  List<Object?> get props => [exception];
}
