import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/pinsdata_vo.dart';

import '../../data/model/apptype_vo.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../presentation/screen/site_routes/site_plan_viewer_screen.dart';

enum PlanStatus { loadingPlan, loadedPlan }

class PlanLoadingState extends FlowState {
  final PlanStatus planStatus;

  PlanLoadingState(this.planStatus);

  @override
  List<Object?> get props => [planStatus];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class ProgressDialogState extends FlowState {
  final bool isShowDialog;

  ProgressDialogState(this.isShowDialog);

  @override
  List<Object?> get props => [isShowDialog, DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class LastLocationChangeState extends FlowState {
  LastLocationChangeState();

  @override
  List<Object?> get props => [DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class RefreshSiteTaskListState extends LastLocationChangeState {
  RefreshSiteTaskListState();
}

class RefreshSiteTaskListItemState extends FlowState {
  final SiteForm? siteForm;
  RefreshSiteTaskListItemState(this.siteForm);
}

class LongPressCreateTaskState extends FlowState {
  final bool isShowingPin;
  final double x, y;

  LongPressCreateTaskState(this.x, this.y, {required this.isShowingPin});

  @override
  List<Object?> get props => [DateTime.now().toString(), x, y, isShowingPin];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class CreateTaskNavigationState extends FlowState {
  final String url;
  final Map<String, dynamic> data;
  final AppType appType;

  CreateTaskNavigationState(this.url, this.data, this.appType);

  @override
  List<Object?> get props => [DateTime.now().toString(), url, data];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class PinsLoadedState extends FlowState {
  final Pins? type;

  PinsLoadedState({this.type});

  @override
  List<Object?> get props => [DateTime.now().toString()];
}

class ShowObservationDialogState extends FlowState {
  final ObservationData observationData;
  final double x, y;
  final double pinWidth,pinHeight;
  final bool isShowDialog;
  ShowObservationDialogState(this.observationData,this.x,this.y, this.pinWidth, this.pinHeight, this.isShowDialog);

  @override
  List<Object?> get props => [observationData, DateTime.now().toString()];
}
class RefreshObservationDialogState extends FlowState{
  final ObservationData observationData;
  RefreshObservationDialogState(this.observationData);

  @override
  List<Object?> get props => [observationData,DateTime.now().toString()];
}

class HistoryLocationBtnState extends FlowState {
  final bool isHistoryLocationBtnVisible;

  HistoryLocationBtnState(this.isHistoryLocationBtnVisible);

  @override
  List<Object?> get props => [isHistoryLocationBtnVisible,DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class CloseKeyBoardState extends FlowState {

  CloseKeyBoardState();

  @override
  List<Object?> get props => [DateTime.now().toString()];

}

class SelectedFormDataState extends FlowState{
  final ObservationData observationData;
  SelectedFormDataState(this.observationData);

  @override
  List<Object?> get props => [observationData,DateTime.now().toString()];
}

class AppliedStaticFilter extends FlowState {
  final bool appliedStaticFilter;

  AppliedStaticFilter(this.appliedStaticFilter);

  @override
  List<Object?> get props => [appliedStaticFilter,DateTime.now().toString()];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}