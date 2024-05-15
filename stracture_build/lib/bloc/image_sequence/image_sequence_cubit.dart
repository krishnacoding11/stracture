import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import 'image_sequence_state.dart';

class ImageSequenceCubit extends BaseCubit {
  int currentIndex = 0;
  List<String> imagePaths = [
    'assets/images/cloud_download_outlined.png',
    'assets/images/cloud_downloading_progress_a.png',
    'assets/images/cloud_downloading_progress_b.png',
    'assets/images/cloud_downloading_progress_c.png',
    'assets/images/cloud_downloading_progress_d.png',
  ];

  ImageSequenceCubit(): super(FlowState());

  Future<void> simulateProgress() async {

    for (int i = 0; i < imagePaths.length; i++) {
      currentIndex = i;
      emitState(UpdateImageState(currentIndex));
    }
  }
}
