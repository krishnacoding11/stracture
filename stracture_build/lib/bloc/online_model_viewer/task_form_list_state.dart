part of 'task_form_list_cubit.dart';

abstract class TaskFormListingState extends Equatable {}

class PaginationListInitial extends TaskFormListingState {
  @override
  List<Object?> get props => [];
}

class TaskFormListingLoadingState extends TaskFormListingState {
  TaskFormListingLoadingState();

  @override
  List<Object?> get props => [];
}

class TaskFormListingLoadedState extends TaskFormListingState {
  TaskFormListingLoadedState();

  @override
  List<Object?> get props => [];
}

class UpdatedSortedListState extends TaskFormListingState {
  final List<ElementVoList> datumList;
  UpdatedSortedListState(this.datumList);

  @override
  List<Object?> get props => [datumList];
}

class ResetSortedListState extends TaskFormListingState {
  final List<ElementVoList> datumList;
  ResetSortedListState(this.datumList);

  @override
  List<Object?> get props => [datumList];
}

class FullScreenFormViewState extends TaskFormListingState {
  final bool isFullScreen;
  final String formId;
  final String headerIconColor;
  final String frmAppBuilderId;
  final String frmTitle;
  final String frmViewUrl;
  final Map<String, dynamic> webviewData;

  FullScreenFormViewState(this.isFullScreen, this.formId, this.headerIconColor, this.frmAppBuilderId, this.frmTitle, this.frmViewUrl, this.webviewData);

  @override
  List<Object?> get props => [isFullScreen];
}

class FullLoadScreenFormViewState extends TaskFormListingState {
  final bool isFullScreen;
  final String formId;
  final String headerIconColor;
  final String frmAppBuilderId;
  final String frmTitle;
  final String frmViewUrl;
  final Map<String, dynamic> webviewData;

  FullLoadScreenFormViewState(this.isFullScreen, this.formId, this.headerIconColor, this.frmAppBuilderId, this.frmTitle, this.frmViewUrl, this.webviewData);

  @override
  List<Object?> get props => [isFullScreen];
}

class StackDrawerState extends TaskFormListingState {
  StackDrawerState(this.currentSelected);

  StackDrawerOptions currentSelected;

  @override
  List<Object?> get props => [currentSelected];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}
