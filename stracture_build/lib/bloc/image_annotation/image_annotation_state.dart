import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

class AddAttachmentState extends FlowState {
  String? time;

  AddAttachmentState({this.time});

  @override
  List<Object?> get props => [time];
}