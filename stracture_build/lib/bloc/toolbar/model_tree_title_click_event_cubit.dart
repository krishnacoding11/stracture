import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

class ModelTreeTitleClickEventCubit extends BaseCubit {
  ModelTreeTitleClickEventCubit() : super(ToolbarTitleClickEventState());

  openModelTreeDialog() {
    emitState(ToolbarTitleClickEventState());
  }
}

class ToolbarTitleClickEventState extends FlowState {}
