import 'package:equatable/equatable.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';

mixin BaseFlowState {
  StateRendererType getStateRendererType();

  String getMessage();
}

class FlowState extends Equatable with BaseFlowState {
  @override
  String getMessage() {
    return "";
  }

  @override
  StateRendererType getStateRendererType() {
    return StateRendererType.EMPTY_SCREEN_STATE;
  }

  @override
  List<Object?> get props => [DateTime.now().microsecondsSinceEpoch.toString()];
}

class InitialState extends FlowState {
  StateRendererType stateRendererType;
  String message;

  InitialState({required this.stateRendererType, String? message}) : message = message ?? 'Loading';

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;
}

// Loading State (POPUP, FULL SCREEN)

class LoadingState extends FlowState {
  StateRendererType stateRendererType;
  String message;

  LoadingState({required this.stateRendererType, String? message}) : message = message ?? 'Loading';

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;
}

// error state (POPUP, FULL LOADING)
class ErrorState extends FlowState {
  StateRendererType stateRendererType;
  String message;
  String? time;
  int? code;
  dynamic? data;

  ErrorState(this.stateRendererType, this.message, {this.time, this.code, this.data});

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;

  @override
  List<Object?> get props => [message, time, code, data];
}

// CONTENT STATE

class ContentState extends FlowState {
  String? time;

  ContentState({this.time});

  @override
  String getMessage() => "";

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;

  @override
  List<Object?> get props => [time];
}

// EMPTY STATE

class EmptyState extends FlowState {
  String message;

  EmptyState(this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => StateRendererType.EMPTY_SCREEN_STATE;
}

// success state
class SuccessState<T> extends FlowState {
  T response;
  StateRendererType? stateRendererType;
  String? time;

  SuccessState(this.response, {this.stateRendererType, this.time});

  @override
  List<Object?> get props => [response, time];

  @override
  StateRendererType getStateRendererType() => StateRendererType.POPUP_SUCCESS;
}

class SendDataToWebViewState<T> extends FlowState {

  SendDataToWebViewState();

  @override
  List<Object?> get props => [];
}

///no project selected state
/// This state is used when user haven't selected any project so that it shows appropriate message.
class NoProjectSelectedState extends FlowState {
  NoProjectSelectedState();
}
