import 'package:field/bloc/quality/quality_plan_listing_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import '../../data/model/quality_plan_list_vo.dart';
import '../../data/model/quality_search_vo.dart';

class QualityPlanSearchSuggestion extends FlowState {
  final List<PopupToData> searchSuggestion;
  final String time = DateTime.now().millisecondsSinceEpoch.toString();

  QualityPlanSearchSuggestion(this.searchSuggestion);

  @override
  List<Object> get props => [searchSuggestion, time];
}

class QualityPlanSearchSuggestionList extends FlowState {
  final List<Data>? searchList;
  final String time = DateTime.now().microsecondsSinceEpoch.toString();

  QualityPlanSearchSuggestionList({this.searchList});

  @override
  List<Object> get props => [searchList!,time];
}


class QualityPlanSearchModeState extends FlowState {
  final QualityPlanSearchMode searchSuggestion;

  QualityPlanSearchModeState(this.searchSuggestion);

  @override
  List<QualityPlanSearchMode> get props => [searchSuggestion];
}

class CurrentSearchListState extends FlowState {
  final List<Data>? searchList;
  final String time = DateTime.now().microsecondsSinceEpoch.toString();

  CurrentSearchListState({this.searchList});

  @override
  List<Object> get props => [searchList!,time];
}

class QualitySearchBarVisibleState extends FlowState {

  final bool isExpand;

  QualitySearchBarVisibleState(this.isExpand);

  @override
  List<Object?> get props => [isExpand, DateTime.now().toString()];
}

class UpdateNoMatchesFound extends FlowState {
  final bool noMatch;

  UpdateNoMatchesFound(this.noMatch);

  @override
  List<bool> get props => [noMatch];
}