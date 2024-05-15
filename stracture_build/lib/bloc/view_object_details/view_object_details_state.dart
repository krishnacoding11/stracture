part of 'view_object_details_cubit.dart';

abstract class ViewObjectDetailsState extends Equatable {}

class PaginationListInitial extends ViewObjectDetailsState {
  @override
  List<Object?> get props => [];
}

class ViewFullScreenObjectDetails extends ViewObjectDetailsState {
  final bool isShow;
  ViewFullScreenObjectDetails(this.isShow);
  @override
  List<Object?> get props => [isShow];
}

class ExpandedDropdownState extends ViewObjectDetailsState {
  final bool isExpanded;
  ExpandedDropdownState(this.isExpanded);
  @override
  List<Object?> get props => [isExpanded];
}

class NormalHandleState extends ViewObjectDetailsState {
  NormalHandleState();
  @override
  List<Object?> get props => [];
}
