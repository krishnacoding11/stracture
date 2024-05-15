import 'dart:async';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioCubit extends BaseCubit {
  final maxDuration = 31;

  AudioCubit() : super(FlowState());
  StreamSubscription<RecordState>? _recordSub;
  final _audioRecorder = Record();
  RecordState _recordState = RecordState.stop;

  int _recordDuration = 0;
  Timer? _timer;

  get recordState => _recordState;

  get recordDuration => _recordDuration;

  init() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _recordState = recordState;
    });
  }

  Future<void> start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );

        await _audioRecorder.start(path: '${(await getApplicationDocumentsDirectory()).path}/Audio_${DateTime.now().millisecondsSinceEpoch}.m4a').then((value) {
          _recordDuration = 0;
        });
        _startTimer();
      }
    } catch (e) {
      Log.d(e);
    }
  }

  dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    // _amplitudeSub?.cancel();
    _audioRecorder.dispose();
  }

  Future<String?> stop() async {
    _timer?.cancel();
    _recordDuration = 0;
    return await _audioRecorder.stop();
  }

  Future<void> resume() async {
    _startTimer();
    await _audioRecorder.resume();
    emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<void> pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
    emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  String formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }
    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_recordDuration >= maxDuration) {
        //_timer?.cancel();
      } else {
        _recordDuration++;
      }
      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }
}
