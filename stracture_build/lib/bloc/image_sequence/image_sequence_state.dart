import '../../presentation/base/state_renderer/state_render_impl.dart';

class UpdateImageState extends FlowState {
  int index;
  UpdateImageState(this.index);

  @override
  List<Object?> get props => [index];
}