import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';

import '../../presentation/base/state_renderer/state_render_impl.dart';

class UserProfileSettingState extends FlowState {
  final UserProfileSetting userProfileSettingState;
  final InternalState internalState;
  final String message;
  final bool isLanguageChange;

  UserProfileSettingState(this.userProfileSettingState, this.internalState,
      {this.message = "", this.isLanguageChange=false});

  @override
  List<Object> get props => [userProfileSettingState, internalState, message, isLanguageChange];
}

class ImageUpdateState extends FlowState {
  final InternalState internalState;
  final String message;
  final String time;

  ImageUpdateState(this.internalState, {this.message = "", this.time = ""});

  @override
  List<Object> get props => [internalState, message, time];
}

class TimeZoneUpdateState extends FlowState {
  final InternalState internalState;
  final String message;

  TimeZoneUpdateState(this.internalState, {this.message = ""});

  @override
  List<Object> get props => [internalState, message];
}

class LanguageUpdateState extends FlowState {
  final InternalState internalState;
  final String message;

  LanguageUpdateState(this.internalState, {this.message = ""});

  @override
  List<Object> get props => [internalState, message];
}


class ToggleWorkOfflineState extends FlowState {
  bool? value;
  String? time;

  ToggleWorkOfflineState(this.value, {this.time});

  @override
  List<Object?> get props => [value,time];
}

class ChangePasswordState extends FlowState {
  final String? time;
  final InternalState internalState;
  final String? message;

  ChangePasswordState(this.internalState, {this.message, this.time});

  @override
  List<Object?> get props => [internalState, message, time];
}

class ShowEyeIconState extends FlowState {
  final bool isEyeVisible;

  ShowEyeIconState({this.isEyeVisible = false});

  @override
  List<Object> get props => [isEyeVisible];
}

class PasswordVisiblityToggle extends FlowState {
  final bool isObscureText;

  PasswordVisiblityToggle(this.isObscureText);

  @override
  List<Object?> get props => [isObscureText];
}

class EditUserContact extends FlowState {
  final bool contactButtonEnabled;
  final InternalState internalState;
  final String message;

  EditUserContact(this.internalState,
      {this.contactButtonEnabled = false, this.message = ""});

  @override
  List<Object> get props => [internalState, contactButtonEnabled, message];
}

class ChangeAppLanguageSuccess extends FlowState {
  ChangeAppLanguageSuccess();

  @override
  List<Object> get props => [];
}

class LogFileUploadedSuccess extends FlowState {
  LogFileUploadedSuccess();

  @override
  List<Object> get props => [];
}

class LogFileUploadedFailure extends FlowState {
  LogFileUploadedFailure();

  @override
  List<Object> get props => [];
}