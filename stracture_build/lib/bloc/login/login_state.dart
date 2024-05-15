import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

// class LoginState extends FlowState {}

class LoginPasswordToggle extends FlowState {
  final bool isObscureText;

  LoginPasswordToggle(this.isObscureText);

  @override
  List<Object?> get props => [isObscureText];
}

class SSOSuccessState<T> extends FlowState {
  final T response;
  SSOSuccessState(this.response);
}

class TwoFactorResendButtonEnable extends FlowState{
  final bool isResendEnable;

  TwoFactorResendButtonEnable(this.isResendEnable);

  @override
  List<Object?> get props => [isResendEnable];
}

class TwoFactorTimer extends FlowState{
  final int seconds;

  TwoFactorTimer(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

class UpdateTextVisibility extends FlowState{
  final bool hiddenEnable;

  UpdateTextVisibility(this.hiddenEnable);

  @override
  List<Object?> get props => [hiddenEnable];
}

class UpdateDataCenterVisibility  extends FlowState{
  final bool dataCenterdisabled;
  UpdateDataCenterVisibility(this.dataCenterdisabled);
  @override
  List<Object?> get props => [dataCenterdisabled];
}

/*class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final Result result;

  LoginSuccessState(this.result);

  List<Object> get props => [result];
}

class LoginErrorState extends LoginState {
  final String errorMsg;

  LoginErrorState(this.errorMsg);

  List<Object> get props => [errorMsg];
}

class LoginValidationState extends LoginState {
  final String errorMsg;

  LoginValidationState(this.errorMsg);

  List<Object> get props => [errorMsg];
}

class LoginSAMLState extends LoginState {
  final String samlResponse;
  final String actionUrl;

  LoginSAMLState(this.samlResponse, this.actionUrl);

  List<Object> get props => [samlResponse, actionUrl];
}*/
