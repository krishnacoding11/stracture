part of 'model_list_cubit.dart';

abstract class ModelListState extends Equatable {}

class PaginationListInitial extends ModelListState {
  @override
  List<Object?> get props => [];
}

class LoadingModelState extends ModelListState {
  @override
  List<Object?> get props => [];
}

class RefreshingState extends ModelListState {
  @override
  List<Object?> get props => [];
}

class ShowProgressBar extends ModelListState {
  final bool isLoading;

  ShowProgressBar(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class ShowDetailsState extends ModelListState {
  final bool isShowDetails;
  final List<Model> items;
  final String modelsSize;
  final String calibFileSize;
  final bool isShowDetailsT;

  ShowDetailsState(this.isShowDetails, this.items, this.modelsSize, this.calibFileSize, this.isShowDetailsT);

  @override
  List<Object?> get props => [isShowDetails, items];
}

class LoadedState extends ModelListState {
  LoadedState();

  @override
  List<Object?> get props => [];
}

class ItemCheckedState extends ModelListState {
  final List<Model> items;

  ItemCheckedState({required this.items});

  @override
  List<Object?> get props => [];
}


class AllModelSuccessState extends ModelListState {
  final List<Model> items;
  final bool isModelSelected;
  final bool isShowCloseButton;
  bool downloadStart;
  Model? openItem;
  double progressValue;

  AllModelSuccessState(this.isModelSelected, {required this.items, required this.isShowCloseButton, this.openItem, this.progressValue = 0, this.downloadStart = false});

  @override
  List<Object?> get props => [isModelSelected, items, isShowCloseButton, openItem, progressValue];
}

class DownloadModelState extends ModelListState {
  final List<Model> items;
  bool downloadStart;
  double progressValue;
  double totalModelSize;
  double totalSize;
  bool isItemForUpdate;

  DownloadModelState({required this.items, this.progressValue = 1, required this.isItemForUpdate, this.totalSize = 1, this.totalModelSize = 0.0, this.downloadStart = false});

  @override
  List<Object?> get props => [
        items,
        progressValue,
    isItemForUpdate,
        downloadStart,
      ];
}

class DropdownOpenState extends ModelListState {
  final List<Model> items;
  final bool isOpen;
  final bool isUpdate;

  DropdownOpenState({
    required this.items,
    required this.isUpdate,
    required this.isOpen,
  });

  @override
  List<Object?> get props => [items, isOpen, isUpdate];
}

class FavProjectSuccessState extends ModelListState {
  final List<Model> items;

  FavProjectSuccessState({required this.items});

  @override
  List<Object?> get props => [items];
}

class ShowSnackBarState extends ModelListState {
  final List<Model> items;
  final bool isItemForUpdate;

  ShowSnackBarState({required this.items, required this.isItemForUpdate});

  @override
  List<Object?> get props => [items, isItemForUpdate];
}

class ShowSnackBarInQueueState extends ModelListState {
  final List<Model> items;

  ShowSnackBarInQueueState({required this.items});

  @override
  List<Object?> get props => [items];
}

class ErrorState extends ModelListState {
  final AppException exception;

  ErrorState({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class SearchModelState extends ModelListState {
  final SearchMode? searchMode;
  final List<Model> items;

  SearchModelState(this.searchMode, this.items);

  @override
  List<Object?> get props => [searchMode, items];
}

class EmptyErrorState extends ModelListState {
  EmptyErrorState();

  @override
  List<Object?> get props => [];
}

class ProjectLoadingState extends ModelListState {
  @override
  List<Object?> get props => [];
}

class OpenButtonLoadingState extends ModelListState {
  final List<Model> items;
  final bool isShow;

  OpenButtonLoadingState({required this.items, required this.isShow});

  @override
  List<Object?> get props => [items, isShow];
}
