import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

class FormSettingsChangeEventCubit extends BaseCubit {
  FormSettingsChangeEventCubit() : super(FormSettingsChangeEventState());

  refreshSiteTasks() {
    emitState(FormSettingsChangeEventState());
  }
}

class FormSettingsChangeEventState extends FlowState {}
