import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

class CameraState extends FlowState {
  final bool isAnimEnd;

  CameraState({required this.isAnimEnd});

  @override
  List<Object?> get props => [isAnimEnd];
}