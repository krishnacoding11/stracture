import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/user_first_login/edit_avatar/edit_avatar.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../analytics/event_analytics.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/normaltext.dart';
import '../../../widgets/progressbar.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';

class UserAvatarSettingScreen extends StatefulWidget {
  const UserAvatarSettingScreen({Key? key}) : super(key: key);

  @override
  State<UserAvatarSettingScreen> createState() => _UserAvatarSettingScreenState();
}

class _UserAvatarSettingScreenState extends State<UserAvatarSettingScreen> {
  UserFirstLoginSetupCubit? _userProfileSettingCubit;

  @override
  void initState() {
    _userProfileSettingCubit = BlocProvider.of<UserFirstLoginSetupCubit>(context);
    _userProfileSettingCubit!.getuserprofilesettingfromserver();
    _userProfileSettingCubit!.getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AColors.btnDisableClr,
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.toLocale!.lbl_setting),
        titleTextStyle: const TextStyle(color: AColors.black, fontFamily: "Sofia", fontWeight: AFontWight.medium, fontSize: 20),
        // toolbarHeight: 25,
        backgroundColor: AColors.white,
        elevation: 1,
        //automaticallyImplyLeading: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black54,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(color: AColors.white, borderRadius: BorderRadius.circular(6.0)),
              child: Column(children: [
                Container(
                  decoration: const BoxDecoration(color: AColors.white),
                  child: const EditAvatar(
                    from: "userSetting",
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          _userProfileSettingCubit!.currentUserAvatar = null;
                        },
                        child: NormalTextWidget(
                          context.toLocale!.lbl_back,
                          color: AColors.themeBlueColor,
                          fontWeight: AFontWight.medium,
                        ),
                      ),
                    ),
                    BlocBuilder<UserFirstLoginSetupCubit, FlowState>(builder: (context, state) {
                      return (state is LoadingState)
                          ? const ACircularProgress()
                          : AElevatedButtonWidget(
                              btnLabel: context.toLocale!.lbl_btn_save,
                              fontWeight: AFontWight.medium,
                              onPressed: () async {
                                if (_userProfileSettingCubit!.currentUserAvatar != null) {
                                  await _userProfileSettingCubit!.updateUserProfileSettingOnServer();
                                  FireBaseEventAnalytics.setEvent(
                                      FireBaseEventType.saveAvatar,
                                      FireBaseFromScreen.settings,
                                      bIncludeProjectName: true);
                                }
                              },
                            );
                    })
                  ],
                ),
              ]))
        ],
      ),
    );
  }
}
