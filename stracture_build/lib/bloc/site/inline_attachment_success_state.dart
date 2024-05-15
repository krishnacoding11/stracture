import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';

// success state
class InlineAttachmentSuccessState<T> extends FlowState {
  T response;
  StateRendererType? stateRendererType;
  String? time;

  InlineAttachmentSuccessState(this.response,
      {this.stateRendererType, this.time});

  @override
  List<Object?> get props => [response, time];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}
