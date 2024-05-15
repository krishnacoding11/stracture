import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter/cupertino.dart';

import '../../presentation/base/state_renderer/state_renderer.dart';

class CustomSearchViewCubit<T> extends BaseCubit {
  CustomSearchViewCubit() : super(FlowState());

  Iterable<T>? suggestions;
  late bool suggestionsValid;
  late VoidCallback controllerListener;
  bool? isLoading, isQueued;
  Object? error;
  AnimationController? animationController;
  String? lastTextValue;
  List<FocusNode> focusNodes = [];
  int suggestionIndex = -1;

  getSuggestionsChange() {
    isLoading = true;
    error = null;
    emitState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
  }

  setSuggestions(error, suggestions) {
    this.error = error;
    isLoading = false;
    this.suggestions = suggestions;
    emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  setSuggestionListen(){
   isLoading = false;
   suggestions = null;
   suggestionsValid = true;
   emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }
}
