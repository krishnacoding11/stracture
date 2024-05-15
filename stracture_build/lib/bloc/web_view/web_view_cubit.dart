import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/web_view/web_view_state.dart';

import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';

class WebViewCubit extends BaseCubit {
  WebViewCubit()
      : super(InitialState(stateRendererType: StateRendererType.DEFAULT));


  showLinearProgressIndicator(bool isShow, double progress) {
    emitState(LinearProgressIndicatorState(progress, isShow));
  }
}
