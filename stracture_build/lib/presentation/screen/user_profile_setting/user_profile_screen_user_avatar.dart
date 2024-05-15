import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../networking/network_info.dart';
import '../../managers/routes_manager.dart';

class UserProfileScreenUserAvtar extends StatefulWidget {
  const UserProfileScreenUserAvtar({Key? key}) : super(key: key);

  @override
  State<UserProfileScreenUserAvtar> createState() => _UserProfileScreenUserAvtarState();
}

class _UserProfileScreenUserAvtarState extends State<UserProfileScreenUserAvtar> {
  late UserProfileSettingCubit _userProfileSettingCubit;

  @override
  Widget build(BuildContext context) {
    return _getUserProfileImage(context);
  }

  @override
  void initState() {
    _userProfileSettingCubit = BlocProvider.of<UserProfileSettingCubit>(context);
    super.initState();
    getUserSessionData();
  }

  void getUserSessionData() async {
    await _userProfileSettingCubit.getUserImageFromServer();
  }

  Widget _getUserProfileImage(BuildContext context) {
    var placeHolder = Image.asset("assets/images/ic_profile_avatar.png").image;

    return BlocBuilder<UserProfileSettingCubit, FlowState>(
        buildWhen: (prev, current) => current is ImageUpdateState,
        builder: (context, state) {
          return (state is ImageUpdateState && state.internalState == InternalState.success)
              ? isNetWorkConnected()
                  ? Container(
                      padding: const EdgeInsets.all(25),
                      child: Stack(alignment: Alignment.bottomRight, children: [
                        CachedNetworkImage(
                          imageUrl: _userProfileSettingCubit.strUserImage!,
                          httpHeaders: _userProfileSettingCubit.headersMap,
                          useOldImageOnUrlChange: false,
                          height: 100.0,
                          width: 100.0,
                          imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                            shape: BoxShape.circle,
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          )),
                          placeholder: (context, url) => Image(image: placeHolder, fit: BoxFit.cover),
                          errorWidget: (context, url, error) => Image(
                            image: placeHolder,
                            fit: BoxFit.cover,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.userUpdateAvatarView).then((value) async {
                              if (value != null) {
                                await _userProfileSettingCubit.getUserImageFromServer();
                                FireBaseEventAnalytics.setEvent(
                                    FireBaseEventType.editProfile,
                                    FireBaseFromScreen.settings,
                                    bIncludeProjectName: true);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AColors.lightGreyColor)),
                            child: CircleAvatar(
                                radius: 16,
                                backgroundColor: AColors.white,
                                child: Icon(
                                  semanticLabel: "Edit profile avatar",
                                  Icons.edit,
                                  color: AColors.grColorDark,
                                )),
                          ),
                        ),
                      ]),
                    )
                  : Container(
                      padding: const EdgeInsets.all(25),
                      child: Container(width: 100, height: 100, decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          shape: BoxShape.circle, image: DecorationImage(image: FileImage(_userProfileSettingCubit.file!),fit: BoxFit.cover))),
                    )
              : const ACircularProgress();
        });
  }
}
