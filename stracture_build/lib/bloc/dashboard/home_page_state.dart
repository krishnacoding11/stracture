import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import '../../data/model/home_page_model.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../task_action_count/task_action_count_cubit.dart';

class UserDefinedErrorState extends FlowState {
  final String message;
  final String? time;

  UserDefinedErrorState(this.message, {this.time});

  @override
  String getMessage() => message;
}

class HomePageItemState extends FlowState {
  final List<UserProjectConfigTabsDetails>? homePageItemList;
  final bool isEditable;

  HomePageItemState(this.homePageItemList, this.isEditable);

  @override
  List<Object?> get props => [homePageItemList, isEditable, DateTime.now().toString()];
}

class HomePageItemLoadingState extends FlowState {
  final StateRendererType stateRendererType;

  HomePageItemLoadingState({required this.stateRendererType});

  @override
  List<Object?> get props => [stateRendererType, DateTime.now().toString()];
}

class HomePageNoProjectSelectState extends FlowState {
  final bool isOnline;

  HomePageNoProjectSelectState(this.isOnline);

  @override
  List<Object?> get props => [isOnline, DateTime.now().toString()];
}

class HomePageEmptyState extends FlowState {

  HomePageEmptyState();

  @override
  List<Object?> get props => [DateTime.now().toString()];
}

class HomePageEditErrorState extends FlowState {
  final String? message;

  HomePageEditErrorState(this.message);

  @override
  List<Object?> get props => [message, DateTime.now().toString()];
}

class ShowFormCreationOptionsDialogState extends FlowState {
  ShowFormCreationOptionsDialogState();

  @override
  List<Object?> get props => [DateTime.now().toString()];
}

class ShowFormCreateDialogState extends FlowState {
  final String frmViewUrl;
  final Map<String, dynamic> data;
  final String? title;

  ShowFormCreateDialogState(this.frmViewUrl, this.data, this.title);

  @override
  List<Object?> get props => [frmViewUrl, data, title, DateTime.now().toString()];
}

class NoFormsMessageState extends FlowState {
  NoFormsMessageState();

  @override
  List<Object?> get props => [DateTime.now().toString()];
}

class NavigateTaskListingScreenState extends FlowState {
  final TaskActionType taskType;

  NavigateTaskListingScreenState(this.taskType);

  @override
  List<Object?> get props => [taskType, DateTime.now().toString()];
}

class NavigateSiteListingScreenState extends FlowState {
  final Map<String, dynamic> arguments;

  NavigateSiteListingScreenState(this.arguments);

  @override
  List<Object?> get props => [arguments, DateTime.now().toString()];
}

class PendingShortcutItemState extends FlowState {
  final List<UserProjectConfigTabsDetails>? pendingShortCutList;

  PendingShortcutItemState(this.pendingShortCutList);

  @override
  List<Object?> get props => [pendingShortCutList, DateTime.now().toString()];
}

class ItemToggleState extends FlowState {
  final List<UserProjectConfigTabsDetails>? pendingShortCutList;

  ItemToggleState(this.pendingShortCutList);

  @override
  List<Object?> get props => [pendingShortCutList, DateTime.now().toString()];
}

class AddMoreSearchState extends FlowState {
  final List<UserProjectConfigTabsDetails>? searchShortCutList;

  AddMoreSearchState(this.searchShortCutList);

  @override
  List<Object?> get props => [searchShortCutList, DateTime.now().toString()];
}

class AddMoreErrorState extends FlowState {
  final String message;

  AddMoreErrorState(this.message);

  @override
  List<Object?> get props => [message, DateTime.now().toString()];
}

class ReachedConfigureLimitState extends FlowState {
  ReachedConfigureLimitState();

  @override
  List<Object?> get props => [DateTime.now().toString()];
}

class AddPendingProgressState extends FlowState {
  final bool isShow;

  AddPendingProgressState(this.isShow);

  @override
  List<Object?> get props => [isShow, DateTime.now().toString()];
}

class UpdateShortcutListProgressState extends FlowState {
  final bool isShow;

  UpdateShortcutListProgressState(this.isShow);

  @override
  List<Object?> get props => [isShow, DateTime.now().toString()];
}