import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

class ToolbarTitleClickEventCubit extends BaseCubit {
  ToolbarTitleClickEventCubit() : super(ToolbarTitleClickEventState());

  openLocationTreeDialog() {
    emitState(ToolbarTitleClickEventState());
  }
}

class ToolbarTitleClickEventState extends FlowState {}
