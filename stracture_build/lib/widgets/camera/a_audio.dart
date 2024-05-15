import 'dart:async';

import 'package:field/bloc/audio/audio_cubit.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  AudioCubit? audioCubit;

  @override
  void initState() {
    audioCubit = BlocProvider.of<AudioCubit>(context);
    audioCubit?.init();
    super.initState();
  }

  Future<void> _start() async {
    try {
      audioCubit?.start();
    } catch (e) {
      if (kDebugMode) {
        Log.d(e);
      }
    }
  }

  Future<void> _stop() async {
    final path = audioCubit?.stop();
    Log.d("Stop path is ==> $path");
    Navigator.of(context).pop(path);
  }

  Future<void> _pause() async {
    await audioCubit?.pause();
  }

  Future<void> _resume() async {
    await audioCubit?.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const NormalTextWidget(
          'Audio record',
          color: AColors.white,
          fontSize: 18,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildRecordStopControl(),
              const SizedBox(width: 20),
              _buildPauseResumeControl(),
              const SizedBox(width: 20),
              _buildText(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    audioCubit?.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    return BlocBuilder<AudioCubit, FlowState>(builder: (context, state) {
      if (audioCubit!.recordState != RecordState.stop) {
        icon = const Icon(Icons.stop, color: Colors.red, size: 30);
        color = Colors.red.withOpacity(0.1);
      } else {
        final theme = Theme.of(context);
        icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
        color = theme.primaryColor.withOpacity(0.1);
      }

      return ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            child: SizedBox(width: 56, height: 56, child: icon),
            onTap: () {
              (audioCubit!.recordState != RecordState.stop) ? _stop() : _start();
            },
          ),
        ),
      );
    });
  }

  Widget _buildPauseResumeControl() {
    return BlocBuilder<AudioCubit, FlowState>(builder: (context, state) {
      if (audioCubit!.recordState == RecordState.stop) {
        return const SizedBox.shrink();
      }

      late Icon icon;
      late Color color;

      if (audioCubit!.recordState == RecordState.record) {
        icon = const Icon(Icons.pause, color: Colors.red, size: 30);
        color = Colors.red.withOpacity(0.1);
      } else {
        final theme = Theme.of(context);
        icon = const Icon(Icons.play_arrow, color: Colors.red, size: 30);
        color = theme.primaryColor.withOpacity(0.1);
      }
      return ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            child: SizedBox(width: 56, height: 56, child: icon),
            onTap: () {
              (audioCubit!.recordState == RecordState.pause) ? _resume() : _pause();
            },
          ),
        ),
      );
    });
  }

  Widget _buildText() {
    return BlocBuilder<AudioCubit, FlowState>(builder: (context, state) {
      if (audioCubit!.recordDuration >= audioCubit!.maxDuration) {
        _stop();
      }
      if (audioCubit!.recordState != RecordState.stop) {
        return _buildTimer();
      }
      return const NormalTextWidget("Waiting to record");
    });
  }

  Widget _buildTimer() {
    final String minutes =
        audioCubit!.formatNumber(audioCubit!.recordDuration ~/ 60);
    final String seconds = audioCubit!.formatNumber(audioCubit!.recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }
}
