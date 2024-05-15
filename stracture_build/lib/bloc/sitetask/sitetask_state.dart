import 'package:field/bloc/sitetask/sitetask_cubit.dart';

import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';

class FormItemViewState extends FlowState {
  final String formId;
  final String headerIconColor;
  final String frmAppBuilderId;
  final String frmTitle;
  final String frmViewUrl;
  final Map<String, dynamic> webviewData;

  FormItemViewState(this.formId, this.headerIconColor,this.frmAppBuilderId, this.frmTitle, this.frmViewUrl,this.webviewData);

  @override
  List<Object?> get props => [formId, headerIconColor, frmAppBuilderId, frmTitle, frmViewUrl,webviewData, DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class RefreshPaginationItemState extends FlowState {
  RefreshPaginationItemState();

  @override
  List<Object?> get props => [DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}
class RefreshWebViewGlobalKeyState extends FlowState {
  RefreshWebViewGlobalKeyState();

  @override
  List<Object?> get props => [DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class SortChangeState extends FlowState {
  SortChangeState();

  @override
  List<Object?> get props => [DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}
class TaskListCountUpdateState extends FlowState {
  TaskListCountUpdateState();

  @override
  List<Object?> get props => [DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class StackDrawerState extends FlowState {

  StackDrawerState(this.currentSelected);

  StackDrawerOptions currentSelected;

  @override
  List<Object?> get props => [currentSelected];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class SearchModeState extends FlowState {
  final SearchMode? searchMode;

  SearchModeState(this.searchMode);

  @override
  List<Object?> get props => [searchMode];
}

class FilterState extends FlowState {

  FilterState();

  @override
  List<Object?> get props => [];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class DatePickerState extends FlowState {

  DatePickerState();

  @override
  List<Object?> get props => [];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class ScrollState extends FlowState {
  double? position;
  bool isScrollRequired;
  ScrollState({this.position,this.isScrollRequired = false});
  @override
  List<Object?> get props => [position,isScrollRequired,DateTime.now().toString()];
  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class SearchBarVisibleState extends FlowState {

  final bool isExpand;

  SearchBarVisibleState(this.isExpand);

  @override
  List<Object?> get props => [isExpand, DateTime.now().toString()];
}

class ApplyFilterState extends FlowState{
  bool isFilterApply;

  ApplyFilterState(this.isFilterApply);

  @override
  List<Object?> get props => [isFilterApply];
}

class CreateTaskState extends FlowState {
  CreateTaskState();

  @override
  List<Object?> get props => [DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class DefaultFormCodeFilterState extends FlowState {
  final String formCode;
  final bool isFormCodeFilterApply;

  DefaultFormCodeFilterState({this.formCode = "", this.isFormCodeFilterApply = false});

  @override
  List<Object?> get props => [formCode, isFormCodeFilterApply, DateTime.now().toString()];
}