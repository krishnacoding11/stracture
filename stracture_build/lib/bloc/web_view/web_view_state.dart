import '../../presentation/base/state_renderer/state_render_impl.dart';

class LinearProgressIndicatorState extends FlowState {
  final double progress;
  final bool isShowing;

  LinearProgressIndicatorState(this.progress, this.isShowing);

  @override
  List<Object?> get props => [progress, isShowing, DateTime.now().toString()];
}