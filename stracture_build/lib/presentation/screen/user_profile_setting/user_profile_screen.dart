import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/user_first_login/edit_formsetting/edit_formsetting.dart';
import 'package:field/presentation/screen/user_first_login/edit_notification/edit_notification.dart';
import 'package:field/presentation/screen/user_first_login/privacy_policy.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_screen_user_avatar.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_about.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_changepwd_screen.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_detail_screen.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_language_screen.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_offline_date_range.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_offline_screen.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_timezone_screen.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/online_model_viewer/online_model_viewer_cubit.dart';
import '../../../bloc/userprofilesetting/user_profile_setting_state.dart';
import '../../../injection_container.dart';
import '../../../networking/network_info.dart';
import '../../../utils/store_preference.dart';
import '../../base/state_renderer/state_render_impl.dart';
import 'cbim_settings_screen.dart';

class UserProfileSettingScreen extends StatefulWidget {
  const UserProfileSettingScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingScreen> createState() =>
      _UserProfileSettingScreenState();
}

class _UserProfileSettingScreenState extends State<UserProfileSettingScreen> {
  late UserProfileSettingCubit _userProfileSettingCubit;

  @override
  void initState() {
    _initUserProfileSettingCubit();
    super.initState();
  }

  void _initUserProfileSettingCubit() {
    _userProfileSettingCubit =
        BlocProvider.of<UserProfileSettingCubit>(context);
    getIt<CBIMSettingsCubit>().initCBIMSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (!Utility.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.toLocale!.lbl_setting),
        titleTextStyle: const TextStyle(
            color: AColors.black,
            fontFamily: "Sofia",
            fontWeight: AFontWight.medium,
            fontSize: 20),
        // toolbarHeight: 25,
        backgroundColor: AColors.white,
        elevation: 1,
        //automaticallyImplyLeading: true,
        leading: InkWell(
          onTap: () async {
            bool reload = await PreferenceUtils.getBool("reloadOffline");
            if(reload){
              if (isNetWorkConnected()) {
                await StorePreference.checkAndSetSelectedProjectIdHash();
              }
              NavigationUtils.reloadApp();
              getIt<TaskActionCountCubit>().getTaskActionCount();
            }
            else{
              _userProfileSettingCubit.selectedScreen !=
                      UserProfileSetting.userprofilesettingdetailscreen
                  ? _userProfileSettingCubit.onCancelBtnClickOfChangePassword()
                  : Navigator.pop(context);
            }
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black54,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: AColors.btnDisableClr,
        //padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
        child: FractionallySizedBox(
          heightFactor: 1,
          widthFactor: Utility.isTablet ? 0.8 : 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const UserProfileScreenUserAvtar(),
              Expanded(
                child: BlocBuilder<UserProfileSettingCubit, FlowState>(
                    builder: (context, state) {
                  return getBasicUserSetup(context, state);
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBaseView(
      BuildContext context, String strWidgetLabel, Widget currentWidget) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 50.0),
      decoration: BoxDecoration(
          color: AColors.white, borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: AColors.white),
              child: currentWidget,
            ),
          ),
          ADividerWidget(thickness: 1),
          Container(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                _userProfileSettingCubit.onCancelBtnClickOfChangePassword();
              },
              child: NormalTextWidget(
                context.toLocale!.lbl_back,
                color: AColors.themeBlueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getBasicUserSetup(BuildContext context, FlowState state){
    switch (_userProfileSettingCubit.selectedScreen) {
      case UserProfileSetting.userlanguagelistscreen:
        {
          return const UserProfileSettingLanguageScreen();
        }
      case UserProfileSetting.usertimezonelistscreen:
        {
          return const UserProfileSettingTimeZoneScreen();
        }
      case UserProfileSetting.userchangepasswordscreen:
        {
          return const UserProfileSettingChangePwdScreen();
        }
      case UserProfileSetting.usereditnotificationscreen:
        {
          return _getBaseView(context, context.toLocale!.lbl_privacy,
              const EditNotificationSetting());
        }
      case UserProfileSetting.userprivacypolicyscreen:
        {
          return _getBaseView(
              context, context.toLocale!.lbl_privacy, const PrivacyPolicy());
        }
      case UserProfileSetting.useraboutscreen:
        {
          return _getBaseView(context, context.toLocale!.lbl_about,
              const UserProfileSettingAbout());
        }
      case UserProfileSetting.userFormSettingscreen:
        {
          return _getBaseView(
              context, context.toLocale!.lbl_privacy, EditFormSetting());
        }
      case UserProfileSetting.cBimSettingScreen:
        {
          return _getBaseView(
              context, context.toLocale!.lbl_models_settings, CBimSettingsScreen());
        }
      case UserProfileSetting.userOfflineSettingScreen:
        {
          return UserProfileSettingOfflineScreen(userProfileSettingCubit: _userProfileSettingCubit,);
        }
      case UserProfileSetting.userOfflineSettingDateRangeScreen:
        {
          return UserProfileSettingDateRangeScreen(userProfileSettingCubit: _userProfileSettingCubit,);
        }
      case UserProfileSetting.userprofilesettingdetailscreen:
      default:
        {
          if(state is UserProfileSettingState && state.internalState == InternalState.success && state.isLanguageChange){
            Future.delayed(Duration.zero, () => appRelaunchDialog(context));
          }
          return const UserProfileSettingDetailScreen();
        }
    }
  }

  appRelaunchDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            actions: [
              InkWell(
                onTap: (){
                  _userProfileSettingCubit.getUserWithSubscription();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NormalTextWidget(context.toLocale!.lbl_ok),
                ),
              )
            ],
            content: NormalTextWidget(context.toLocale!.lbl_relogin_restart_app_on_language_change),
          );
        });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
