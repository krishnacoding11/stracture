import 'package:field/bloc/web_view/web_view_cubit.dart';
import 'package:field/bloc/web_view/web_view_state.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  group('WebViewCubit', () {
    test('initial state should have the correct StateRendererType', () {
      // Arrange
      final cubit = WebViewCubit();

      // Act
      final initialState = cubit.state;

      // Assert
      expect(initialState.getStateRendererType(), StateRendererType.DEFAULT);
    });
  });

  test('showLinearProgressIndicator should emit LinearProgressIndicatorState', () {
    // Arrange
    final cubit = WebViewCubit();
    final isShow = true;
    final progress = 0.75;

    // Act
    cubit.showLinearProgressIndicator(isShow, progress);

    // Assert
    expect(
      cubit.state,
      isA<LinearProgressIndicatorState>()
          .having((state) => state.progress, 'progress', progress)
          .having((state) => state.isShowing, 'isShow', isShow),
    );
  });

  test('showLinearProgressIndicator should emit LinearProgressIndicatorState with isShow = false', () {
    // Arrange
    final cubit = WebViewCubit();
    final isShow = false;
    final progress = 0.0;

    // Act
    cubit.showLinearProgressIndicator(isShow, progress);

    // Assert
    expect(
      cubit.state,
      isA<LinearProgressIndicatorState>()
          .having((state) => state.progress, 'progress', progress)
          .having((state) => state.isShowing, 'isShow', isShow),
    );
  });
}
