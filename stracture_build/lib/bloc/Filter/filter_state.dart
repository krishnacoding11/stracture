import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';

class FilterListState extends FlowState {
  final List filterData;
  final FilterScreen type;

  FilterListState(this.filterData, this.type);

  @override
  List<Object?> get props => [filterData, type];
}

class UpdateFilterData extends FlowState {
  final Map filledFilterData;
  final int index;
  final String time;

  UpdateFilterData(this.filledFilterData,this.index,this.time);

  @override
  List<Object?> get props => [filledFilterData,index,time];
}

class UpdateToggleState extends FlowState {
  final bool isOverDueEnabled;
  final bool isCompletedEnabled;

  UpdateToggleState(this.isOverDueEnabled, this.isCompletedEnabled);

  @override
  List<Object?> get props => [isOverDueEnabled, isCompletedEnabled];
}

class ShowDropDownState extends FlowState {
  final String message;
  final int index;
  final String titleFilter;

  ShowDropDownState(this.index, this.titleFilter,  {String? message}) : message = message ?? '';

  //@override
  //String getMessage() => message;

  @override
  List<Object?> get props => [index, message, titleFilter];
}

class DismissDropDownState extends FlowState {
  final String time;

  DismissDropDownState(this.time);

  @override
  List<Object?> get props => [time];
}

class SelectDropDownState extends FlowState {
  final dynamic value;
  final int index;

  SelectDropDownState(this.index, {this.value});

  @override
  List<Object?> get props => [index, value];
}

class ShowDatePickerState extends FlowState {
  final String date;
  final String labelText;
  final int index;

  ShowDatePickerState(this.index, {String? date, String? labelText})
      : labelText = labelText ?? '',
        date = date ?? '';

  @override
  List<Object?> get props => [index, labelText, date];
}

class ClearDropDownState extends FlowState {
  final int index;

  ClearDropDownState(this.index);

  @override
  List<Object?> get props => [index];
}

class FilterAttributeValueState extends FlowState {
  final dynamic data;

  FilterAttributeValueState(this.data);

  @override
  List<Object?> get props => [DateTime.now().toString(), data];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class FilterAttributeValueErrorState extends FlowState {
  final dynamic data;

  FilterAttributeValueErrorState(this.data);

  @override
  List<Object?> get props => [DateTime.now().toString(), data];
}

class UpdateHomeShortcutNameState extends FlowState {
  final String shortcutName;

  UpdateHomeShortcutNameState(this.shortcutName);

  @override
  List<Object?> get props => [shortcutName];
}
