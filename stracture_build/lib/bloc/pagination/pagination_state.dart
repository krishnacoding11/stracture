part of 'pagination_bloc.dart';

abstract class PaginationState<T> extends FlowState {}

class PaginationInitial<T> extends PaginationState<T> {
  @override
  List<Object?> get props => [];
}

class PaginationError<T> extends PaginationState<T> {
  final Exception exception;
  PaginationError({required this.exception});
  
  @override
  List<Object?> get props => [exception];
}

class PaginationLoaded<T> extends PaginationState<T> {
  PaginationLoaded({
    required this.items,
    required this.hasReachedEnd,
  });

  final bool hasReachedEnd;
  final List<T> items;

  PaginationLoaded<T> copyWith({
    List<T>? items,
    bool? hasReachedEnd,
  }) {
    return PaginationLoaded<T>(
      items: items ?? this.items,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
  
  @override
  List<Object?> get props => [items, hasReachedEnd];
}
