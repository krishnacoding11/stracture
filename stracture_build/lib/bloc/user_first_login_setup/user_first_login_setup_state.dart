import 'package:camera/camera.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import 'user_first_login_setup_cubit.dart';

class UserFirstLoginState extends FlowState {
  final UserFirstLoginSetup userFirstLoginState;

  UserFirstLoginState(this.userFirstLoginState);

  @override
  List<Object> get props => [userFirstLoginState];
}

class AcceptPrivacyState extends FlowState {
  final bool isPrivacyAccept;

  AcceptPrivacyState(this.isPrivacyAccept);

  @override
  List<Object> get props => [isPrivacyAccept];
}

class EnablePushNotification extends FlowState {
  final bool isPushNotificationEnable;
  final String time;

  EnablePushNotification(this.isPushNotificationEnable,this.time);

  @override
  List<Object> get props => [isPushNotificationEnable, time];
}

class ChangeIncludeCloseOutForm extends FlowState {
  final bool isCloseOutForm;

  ChangeIncludeCloseOutForm(this.isCloseOutForm);

  @override
  List<Object> get props => [isCloseOutForm, DateTime.now().millisecondsSinceEpoch.toString()];
}

class GetUserName extends FlowState {
  final String? userName;

  GetUserName({this.userName});

  @override
  List<Object> get props => [userName!];
}

class UpdateUserProfileOrientation extends FlowState {
  final bool? isOrientationChange;
  final bool? isUndoPerform;
  final double? orientation;

  UpdateUserProfileOrientation({this.isOrientationChange, this.isUndoPerform, this.orientation});

  @override
  List<Object> get props => [isOrientationChange!, orientation!];
}

class UpdateImageFromLocal extends FlowState {
  final XFile? currentUserAvatar;

  UpdateImageFromLocal({this.currentUserAvatar});

  @override
  List<Object> get props => [currentUserAvatar!];
}


class UpdateNetworkImage extends FlowState {
  final String? networkUserAvatar;

  UpdateNetworkImage({this.networkUserAvatar});

  @override
  List<Object> get props => [networkUserAvatar!];
}
