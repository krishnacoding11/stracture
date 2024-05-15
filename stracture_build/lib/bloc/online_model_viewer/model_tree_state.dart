part of 'model_tree_cubit.dart';

abstract class ModelTreeState extends Equatable {}

class PaginationListInitial extends ModelTreeState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends ModelTreeState {
  @override
  List<Object?> get props => [];
}

class LoadedState extends ModelTreeState {
  LoadedState();

  @override
  List<Object?> get props => [];
}

class UpdatedState extends ModelTreeState {
  UpdatedState();

  @override
  List<Object?> get props => [];
}

class AfterUpdatedState extends ModelTreeState {
  AfterUpdatedState();

  @override
  List<Object?> get props => [];
}

class NormalState extends ModelTreeState {
  NormalState();

  @override
  List<Object?> get props => [];
}
