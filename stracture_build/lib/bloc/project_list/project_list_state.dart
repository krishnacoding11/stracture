part of 'project_list_cubit.dart';

abstract class ProjectListState extends FlowState {}

class PaginationListInitial extends ProjectListState {
  @override
  List<Object?> get props => [];
}

class AllProjectLoadingState extends ProjectListState {
  @override
  List<Object?> get props => [];
}

class FavProjectLoadingState extends ProjectListState {
  @override
  List<Object?> get props => [DateTime.now().toString()];
}

class RefreshingState extends ProjectListState {
  final bool isFavourite;

  RefreshingState(this.isFavourite);

  @override
  List<Object?> get props => [];
}

class LoadedState extends ProjectListState {
  final bool isLoading;

  LoadedState(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class ProjectEmptyState extends ProjectListState {
  ProjectEmptyState();

  @override
  List<Object?> get props => [];
}

//added for extra data (QRcode)
class FillState extends ProjectListState {
  final List<Project> items;
  final Map<String, dynamic> requestData;

  FillState({required this.items, required this.requestData});

  @override
  List<Object?> get props => [];
}

class ProjectDetailSuccessState extends ProjectListState {
  final List<dynamic> items;

  ProjectDetailSuccessState({required this.items});

  @override
  List<Object?> get props => [items,DateTime.now().toString()];
}

class AllProjectSuccessState extends ProjectListState {
  final List<Popupdata> items;

  AllProjectSuccessState({required this.items});

  @override
  List<Object?> get props => [items, DateTime.now().toString()];
}

class FavProjectSuccessState extends ProjectListState {
  final List<Popupdata> items;

  FavProjectSuccessState({required this.items});

  @override
  List<Object?> get props => [items, DateTime.now().toString()];
}

class RecentProjectSuccessState extends ProjectListState {
  final List<String> recentList;

  RecentProjectSuccessState({required this.recentList});

  @override
  List<Object?> get props => [recentList];
}

class ProjectErrorState extends ProjectListState {
  final AppException exception;

  ProjectErrorState({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class FavouriteState extends ProjectListState {
  final Popupdata? project;

  FavouriteState({this.project});

  @override
  List<Object?> get props => [project];
}

class OnChangeSorting extends ProjectListState {
  final bool? isAscending;

  OnChangeSorting({this.isAscending});

  @override
  List<Object?> get props => [isAscending];
}

class OnChangeFavSorting extends ProjectListState {
  final bool? isFavAscending;

  OnChangeFavSorting({this.isFavAscending});

  @override
  List<Object?> get props => [isFavAscending];
}

class SearchModeState extends ProjectListState {
  final SearchMode? searchMode;

  SearchModeState(this.searchMode);

  @override
  List<Object?> get props => [searchMode];
}

class ProjectSyncProgressState extends ProjectListState {
  final int progress;
  final String projectId;
  final ESyncStatus syncStatus;
  ProjectSyncProgressState(this.progress, this.projectId, this.syncStatus);
  @override
  List<Object?> get props => [progress,projectId,syncStatus];
}
/*class ProjectLocationSyncProgressState extends ProjectListState {
  final String projectId;
  final ESyncStatus syncStatus;
  ProjectLocationSyncProgressState( this.projectId, this.syncStatus);
  @override
  List<Object?> get props => [projectId,syncStatus];
}*/
///////

class AllProjectNotFoundState extends ProjectListState{
  AllProjectNotFoundState();
  @override
  List<Object?> get props => [];
}

class AllProjectNotAllocatedState extends ProjectListState{
  AllProjectNotAllocatedState();
  @override
  List<Object?> get props => [];
}

class FavProjectNotFoundState extends ProjectListState{
  FavProjectNotFoundState();
  @override
  List<Object?> get props => [];
}

class FavProjectNotAllocatedState extends ProjectListState{
  FavProjectNotAllocatedState();
  @override
  List<Object?> get props => [];
}

class EnableSorting extends ProjectListState{
  EnableSorting();
  @override
  List<Object?> get props => [];
}

class DisableSorting extends ProjectListState{
  DisableSorting();
  @override
  List<Object?> get props => [];
}