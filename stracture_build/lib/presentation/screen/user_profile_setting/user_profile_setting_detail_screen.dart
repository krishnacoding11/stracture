import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_contact_widget.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_label_item.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_label_item_with_icon.dart';
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_label_item_with_toggle.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';

class UserProfileSettingDetailScreen extends StatefulWidget {
  const UserProfileSettingDetailScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingDetailScreen> createState() =>
      _UserProfileSettingDetailScreenState();
}

class _UserProfileSettingDetailScreenState
    extends State<UserProfileSettingDetailScreen> {
  late UserProfileSettingCubit _userProfileSettingCubit;
  AProgressDialog? aProgressDialog;

  @override
  void initState() {
    _userProfileSettingCubit =
        BlocProvider.of<UserProfileSettingCubit>(context);
    _userProfileSettingCubit.getDataFromPreference();
    _userProfileSettingCubit.isSyncFileIsEmpty();
    super.initState();
    initUserProfileSettingData();
    aProgressDialog = AProgressDialog(context, isAnimationRequired: true);
  }

  void initUserProfileSettingData() async {
    if (!_userProfileSettingCubit.isCancelTap) {
      await _userProfileSettingCubit.getUserProfileSettingFromServer();
    }
    _userProfileSettingCubit.isCancelTap = false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: BlocListener<UserProfileSettingCubit, FlowState>(
        listener: (context, state) {
          if (state is UserProfileSettingState &&
              state.internalState == InternalState.loading) {
            aProgressDialog?.show();
          } else if (state is UserProfileSettingState &&
              state.internalState == InternalState.success) {
            aProgressDialog?.dismiss();
          } else if (state is UserProfileSettingState &&
              state.internalState == InternalState.failure) {
            if(isNetWorkConnected()){
              context.showSnack(state.message);
            }
            aProgressDialog?.dismiss();
          } else if(state is LoadingState &&  state.stateRendererType == StateRendererType.FULL_SCREEN_LOADING_STATE)  {
            aProgressDialog?.show();
          } else if(state is ErrorState) {
            aProgressDialog?.dismiss();
          } else if (state is LogFileUploadedSuccess){
            context.showSnack(context.toLocale!.file_uploaded_successfully);
            aProgressDialog?.dismiss();
          } else if (state is LogFileUploadedFailure) {
            context.showSnack(context.toLocale!.something_went_wrong);
            aProgressDialog?.dismiss();
          }
        },
        child: BlocBuilder<UserProfileSettingCubit, FlowState>(
          buildWhen: (prev, current) => current is UserProfileSettingState || current is ToggleWorkOfflineState,
          builder: (context, state) {
            return /*(state is UserProfileSettingState &&
                    state.internalState == InternalState.success)
                ? */Padding(
                    padding: const EdgeInsets.all(5),
                    child: Wrap(
                      runSpacing: 20,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: AColors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              UserProfileSettingLabelItem(
                                  context: context,
                                  strLabel: context.toLocale!.lbl_first_name,
                                  strValue: (_userProfileSettingCubit
                                      .userProfileSetting.firstName ?? "")
                                      .toString(),
                                  bIsBorderRequired: true,
                                  bIsInfoIconRequired: true),
                              UserProfileSettingLabelItem(
                                context: context,
                                strLabel: context.toLocale!.lbl_last_name,
                                strValue: (_userProfileSettingCubit
                                    .userProfileSetting.lastName ?? "")
                                    .toString(),
                                bIsBorderRequired: true,
                                bIsInfoIconRequired: true,
                              ),
                              UserProfileSettingLabelItem(
                                context: context,
                                strLabel: context.toLocale!.lbl_email,
                                strValue: (_userProfileSettingCubit
                                    .userProfileSetting.emailAddress ?? "")
                                    .toString(),
                                bIsBorderRequired: true,
                                bIsInfoIconRequired: true,
                              ),
                              const UserProfileSettingContact(),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: AColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: UserProfileSettingLabelItem(
                            context: context,
                            strLabel: context.toLocale!.lbl_job_title,
                            strValue: (_userProfileSettingCubit
                                .userProfileSetting.jobTitle ?? "")
                                .toString(),
                            bIsInfoIconRequired: true,
                          ),
                        ), Container(
                          decoration: const BoxDecoration(
                              color: AColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              UserProfileSettingLabelItem(
                                  context: context,
                                  strLabel: context.toLocale!.lbl_time_Zone,
                                  strValue: (_userProfileSettingCubit
                                      .currentTimeZone ?? "")
                                      .toString(),
                                  bIsBorderRequired: true,
                                  onTap: () => isNetWorkConnected()?onTimeZoneLabelClick(context):{}),
                              UserProfileSettingLabelItem(
                                  context: context,
                                  strLabel: context.toLocale!.lbl_language,
                                  strValue: _userProfileSettingCubit
                                      .getProperLanguageName(
                                          _userProfileSettingCubit
                                              .userProfileSetting,
                                          _userProfileSettingCubit
                                              .languageData),
                                  onTap: () => isNetWorkConnected()?onLanguageLabelClick(context):{}),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: AColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: UserProfileSettingLabelItemWithIcon(
                                    context: context,
                                    strLabel:
                                        context.toLocale!.lbl_change_password,
                                    onTap: () =>
                                    isNetWorkConnected()?onChangePasswordClick(context):{}),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: AColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Column(
                                  children: [
                                    UserProfileSettingLabelItemWithIcon(
                                        context: context,
                                        strLabel:
                                        context.toLocale!.lbl_form_settings,
                                        bIsBorderRequired: true,
                                        onTap: () =>
                                        isNetWorkConnected()?onFormSettingsButtonClick(
                                                context):{}),
                                    UserProfileSettingLabelItemWithIcon(
                                        context: context,
                                        strLabel:
                                            context.toLocale!.lbl_notifications,
                                        bIsBorderRequired: true,
                                        onTap: () =>
                                        isNetWorkConnected()?onEditNotificationButtonClick(
                                                context):{}),
                                   /* UserProfileSettingLabelItemWithIcon(
                                        context: context,
                                        strLabel:
                                        context.toLocale!.lbl_offline_data,
                                        bIsBorderRequired: true,
                                        onTap: () =>
                                            onOfflineDataButtonClick(
                                                context)),*/
                                    UserProfileSettingLabelItemWithIcon(
                                        context: context,
                                        strLabel: context.toLocale!.lbl_privacy,
                                        bIsBorderRequired: true,
                                        onTap: () => onPrivacyPolicyButtonClick(
                                            context)),
                                    UserProfileSettingLabelItemWithToggle(
                                      context: context,
                                      strLabel: context.toLocale!.lbl_write_log,
                                      toggleValue: _userProfileSettingCubit.isWriteLogs,
                                      onToggle: (val) async {
                                        await _userProfileSettingCubit.toggleIncludeLogs(val);
                                        FireBaseEventAnalytics.setEvent(
                                            FireBaseEventType.writeLog,
                                            FireBaseFromScreen.settings,
                                            bIncludeProjectName: true);

                                      },
                                      childWidget: (isNetWorkConnected() && !_userProfileSettingCubit.isSyncLogFileEmpty) ? SizedBox(
                                        height: 30,
                                        child: ElevatedButton(
                                            onPressed: _userProfileSettingCubit.isWriteLogs
                                                ? () async {
                                                    await _userProfileSettingCubit.onUploadLogPress();
                                                    _userProfileSettingCubit.toggleIncludeLogs(false);
                                                    FireBaseEventAnalytics.setEvent(
                                                        FireBaseEventType.uploadLogs,
                                                        FireBaseFromScreen.settings,
                                                        bIncludeProjectName: true);
                                                  }
                                                : null,
                                            child: Text(context.toLocale!.lbl_upload_logs)),
                                      ) : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: AColors.white,
                              borderRadius:
                              BorderRadius.all(Radius.circular(5.0))),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: UserProfileSettingLabelItemWithIcon(
                                    context: context,
                                    strLabel:
                                    context.toLocale!.lbl_models_settings,
                                    onTap: () => oncBimSettingClick(context)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: AColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: UserProfileSettingLabelItemWithIcon(
                                    context: context,
                                    strLabel: context.toLocale!.lbl_about,
                                    onTap: () => onAboutButtonClick(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                //: Container();
          },
        ),
      ),
    );
  }

  void onTimeZoneLabelClick(BuildContext context) async {
    _userProfileSettingCubit.timezonelableclick();
  }

  void onLanguageLabelClick(BuildContext context) async {
    _userProfileSettingCubit.languagelableclick();
  }

  void onChangePasswordClick(BuildContext context) {
    _userProfileSettingCubit.onChangePasswordClick();
  }
  void oncBimSettingClick(BuildContext context) {
    _userProfileSettingCubit.onCBimSettingClick();
  }

  void onPrivacyPolicyButtonClick(BuildContext context) {
    _userProfileSettingCubit.onPrivacyPolicyButtonClick();
  }

  void onEditNotificationButtonClick(BuildContext context) {
    _userProfileSettingCubit.onEditNotificationButtonClick();
  }

  void onOfflineDataButtonClick(BuildContext context) {
    _userProfileSettingCubit.onOfflineDataButtonClick();
  }

  void onFormSettingsButtonClick(BuildContext context) {
    _userProfileSettingCubit.onFormSettingsButtonClick();
  }

  void onAboutButtonClick(BuildContext context) {
    _userProfileSettingCubit.onAboutBtnClick();
  }
}
