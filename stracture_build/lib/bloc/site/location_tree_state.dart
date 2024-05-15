import 'package:field/bloc/navigation/navigation_state.dart';
import 'package:field/bloc/site/location_tree_cubit.dart';

import '../../data/model/location_suggestion_search_vo.dart';
import '../../data/model/search_location_list_vo.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';

class LocationTreeState extends BottomNavigationMenuListState {
  final String time = DateTime.now().millisecondsSinceEpoch.toString();

  LocationTreeState(super.menuList, super.selectedItemIndex, super.online);

  @override
  List<Object> get props => [super.menuList, super.selectedItemIndex, time];
}

class LocationSearchSate extends FlowState {
  final String time = DateTime.now().millisecondsSinceEpoch.toString();
  final List<SearchLocationData> searchList;

  LocationSearchSate({required this.searchList});

  @override
  List<Object> get props => [searchList, time];
}

class VisibleSelectBtn extends FlowState {
  final bool isVisibleSelectBtn;

  VisibleSelectBtn(this.isVisibleSelectBtn);

  @override
  List<Object> get props => [isVisibleSelectBtn];
}

class LocationSearchSuggestion extends FlowState {
  final List<SearchDropdownList> searchSuggestion;
  final String time = DateTime.now().millisecondsSinceEpoch.toString();

  LocationSearchSuggestion(this.searchSuggestion);

  @override
  List<Object> get props => [searchSuggestion, time];
}

class LocationSearchSuggestionMode extends FlowState {
  final LocationSearchMode searchSuggestion;

  LocationSearchSuggestionMode(this.searchSuggestion);

  @override
  List<LocationSearchMode> get props => [searchSuggestion];
}

class MarkOfflineEnableState extends FlowState {
  final bool isEnableOfflineSelection;

  MarkOfflineEnableState(this.isEnableOfflineSelection);

  @override
  List<Object?> get props => [isEnableOfflineSelection];
}

class CheckboxClickState extends FlowState {
  final bool isChecked;
  final String time = DateTime.now().millisecondsSinceEpoch.toString();

  CheckboxClickState(this.isChecked);

  @override
  List<Object?> get props => [isChecked, time];
}

class LocationUnMarkEnableState extends FlowState {
  final bool isEnableUnmarkSelection;

  LocationUnMarkEnableState(this.isEnableUnmarkSelection);

  @override
  List<Object?> get props => [isEnableUnmarkSelection];
}

class LocationUnMarkDeleteApprovalState extends FlowState {
  final int locationId;
  final bool deleteLocation;
  final bool isAnimate;

  LocationUnMarkDeleteApprovalState(this.locationId,this.isAnimate, {this.deleteLocation = false});

  @override
  List<Object?> get props => [locationId,isAnimate, deleteLocation];
}
class LocationUnMarkProgressDialogState extends FlowState {
  final bool show;
  final String time = DateTime.now().millisecondsSinceEpoch.toString();

  LocationUnMarkProgressDialogState(this.show);

  @override
  List<Object?> get props => [show, time];
}