import 'package:field/bloc/audio/audio_cubit.dart';
import 'package:field/widgets/camera/a_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioCubit extends Mock implements AudioCubit {}

void main() {

  testWidgets('Audio record cover', (WidgetTester tester) async {
    // Create a mock AudioCubit instance
    final audioCubit = AudioCubit();

    // Provide the mock AudioCubit to the AudioRecorder widget using BlocProvider.value
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AudioCubit>.value(
          value: audioCubit,
          child: AudioRecorder(),
        ),
      ),
    );

    // Now, you can mock the behavior of the audioCubit
    // when(audioCubit.recordState).thenReturn(RecordState.stop);

    // Perform your test assertions here
    expect(find.text('Audio record'), findsOneWidget);
  });
}
