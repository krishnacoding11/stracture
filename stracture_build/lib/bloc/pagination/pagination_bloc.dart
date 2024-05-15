import 'dart:async';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

part 'pagination_state.dart';

class PaginationCubit<T> extends BaseCubit {
  PaginationCubit(this.preloadedItems, this.callback) : super(PaginationInitial<T>());

  final List<T> preloadedItems;

  final Future<List<T>> Function(int) callback;

  void fetchPaginatedList() {
    if (state is PaginationInitial) {
      _fetchAndEmitPaginatedList(previousList: preloadedItems);
    } else if (state is PaginationLoaded<T>) {
      final loadedState = state as PaginationLoaded;
      if (loadedState.hasReachedEnd) return;
      _fetchAndEmitPaginatedList(previousList: loadedState.items as List<T>);
    }
  }

  Future<void> refreshPaginatedList() async {
    await _fetchAndEmitPaginatedList(previousList: preloadedItems);
  }

  Future<void> _fetchAndEmitPaginatedList({
    List<T> previousList = const [],
  }) async {
    try {
      final newList = await callback(
        _getAbsoluteOffset(previousList.length),
      );
      emitState(PaginationLoaded(
        items: List<T>.from(previousList + newList),
        hasReachedEnd: newList.isEmpty,
      ));
    } on Exception catch (e) {
      emitState(PaginationError(exception: e));
    }
  }

  int _getAbsoluteOffset(int offset) => offset - preloadedItems.length;
}
