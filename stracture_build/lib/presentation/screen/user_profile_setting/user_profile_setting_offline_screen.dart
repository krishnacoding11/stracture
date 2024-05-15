import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_offline_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/toggle_switch.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/utils.dart';

class UserProfileSettingOfflineScreen extends StatefulWidget {
  final UserProfileSettingCubit userProfileSettingCubit;

  const UserProfileSettingOfflineScreen(
      {Key? key, required this.userProfileSettingCubit})
      : super(key: key);

  @override
  State<UserProfileSettingOfflineScreen> createState() =>
      _UserProfileSettingsOfflineScreenState();
}

class _UserProfileSettingsOfflineScreenState
    extends State<UserProfileSettingOfflineScreen> {
  final UserProfileSettingOfflineCubit _userProfileSettingOfflineCubit =
      getIt<UserProfileSettingOfflineCubit>();

  @override
  void initState() {
    super.initState();
    _userProfileSettingOfflineCubit.getDataFromPreference();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => _userProfileSettingOfflineCubit,
        child: BlocBuilder<UserProfileSettingOfflineCubit, FlowState>(
          builder: (context, state) => (state is LoadingState)
              ? const ACircularProgress()
              : Container(
                  margin: const EdgeInsets.only(bottom: 50.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                      color: AColors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NormalTextWidget(
                                context.toLocale!.lbl_offline_settings,
                                fontSize: 18,
                                fontWeight: AFontWight.semiBold,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              NormalTextWidget(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: AColors.textColor,
                                context.toLocale!.lbl_general_settings,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              generalSettingsListItem(context),
                             /* const SizedBox(
                                height: 20,
                              ),
                              NormalTextWidget(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: AColors.textColor,
                                context.toLocale!.lbl_sync_settings,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              syncSettingsListItem(context),
                              const SizedBox(height: 16),*/
                            ],
                          ),
                        ),
                        Spacer(flex: 1),
                        Container(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            key: const Key(
                                "Offline_Data_Back_Button_User_Profile_Settings"),
                            onPressed: () async {
                              widget.userProfileSettingCubit
                                  .onCancelBtnClickOfChangePassword();
                            },
                            child: NormalTextWidget(
                              context.toLocale!.lbl_back,
                              color: AColors.themeBlueColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }

  Widget generalSettingsListItem(BuildContext context) {
    return ListView.separated(
      reverse: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NormalTextWidget(
                context.toLocale!.lbl_work_offline,
                fontWeight: AFontWight.regular,
                fontSize: 16.0,
                color: AColors.iconGreyColor,
                textAlign: TextAlign.left,
              ),
              AToggleSwitch(
                width: 48.0,
                height: 28.0,
                toggleSize: 24.0,
                value: _userProfileSettingOfflineCubit.workOffline,
                borderRadius: 40.0,
                padding: 1.8,
                activeToggleColor: AColors.white,
                inactiveToggleColor: AColors.white,
                activeIcon: Icon(
                  Icons.check,
                  color: AColors.themeBlueColor,
                  size: 30,
                ),
                inactiveIcon: Icon(
                  Icons.close,
                  color: AColors.hintColor,
                  size: 30,
                ),
                toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                activeColor: AColors.themeBlueColor,
                inactiveColor: AColors.hintColor,
                onToggle: (val) async {
                  await _userProfileSettingOfflineCubit.toggleWorkOffline(val);
                  Utility.closeBanner();
                },
              ),
            ],
          );
        }
        /*else if (index == 1) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NormalTextWidget(
                context.toLocale!.lbl_image_compression,
                fontWeight: AFontWight.regular,
                fontSize: 16.0,
                color: AColors.iconGreyColor,
                textAlign: TextAlign.left,
              ),
              AToggleSwitch(
                disabled: _userProfileSettingOfflineCubit.workOffline,
                width: 48.0,
                height: 28.0,
                toggleSize: 24.0,
                value: _userProfileSettingOfflineCubit.imageCompression,
                borderRadius: 40.0,
                padding: 1.8,
                activeToggleColor: AColors.white,
                inactiveToggleColor: AColors.white,
                activeIcon: Icon(
                  Icons.check,
                  color: AColors.themeBlueColor,
                  size: 30,
                ),
                inactiveIcon: Icon(
                  Icons.close,
                  color: AColors.hintColor,
                  size: 30,
                ),
                toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                activeColor: AColors.themeBlueColor,
                inactiveColor: AColors.hintColor,
                onToggle: (val) async {
                  await _userProfileSettingOfflineCubit
                      .toggleImageCompression(val);
                },
              )
            ],
          );
        }
        else if (index == 2) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NormalTextWidget(
                context.toLocale!.lbl_number_of_recent_site_task,
                fontWeight: AFontWight.regular,
                fontSize: 16.0,
                color: AColors.iconGreyColor,
                textAlign: TextAlign.left,
              ),
              SizedBox(
                width: 80.0,
                height: 35,
                child: TextFormField(
                  enabled: !_userProfileSettingOfflineCubit.workOffline,
                  initialValue: "5",
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1,
                          color: AColors.lightGreyColor), //<-- SEE HERE
                    ),
                  ),
                ),
              ),
            ],
          );
        }*/
        return Container();
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
    );
  }

  Widget syncSettingsListItem(BuildContext context) {
    return ListView.separated(
      reverse: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        /*String title = "";
        if (_userProfileSettingOfflineCubit.selectedDateRange == SyncDateRange.lastWeek) {
          title = context.toLocale!.lbl_last_week;
        } else if (_userProfileSettingOfflineCubit.selectedDateRange == SyncDateRange.last2Weeks) {
          title = context.toLocale!.lbl_last_2_weeks;
        } else if (_userProfileSettingOfflineCubit.selectedDateRange == SyncDateRange.lastMonth) {
          title = context.toLocale!.lbl_last_month;
        } else if (_userProfileSettingOfflineCubit.selectedDateRange == SyncDateRange.last2Months) {
          title = context.toLocale!.lbl_last_2_month;
        } else if (_userProfileSettingOfflineCubit.selectedDateRange == SyncDateRange.last6Months) {
          title = context.toLocale!.lbl_last_6_month;
        }*/
        switch(index){
          /*case 0:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_sync_on_mobile_data,
                  fontWeight: AFontWight.regular,
                  fontSize: 16.0,
                  color: AColors.iconGreyColor,
                  textAlign: TextAlign.left,
                ),
                AToggleSwitch(
                  disabled: _userProfileSettingOfflineCubit.workOffline,
                  width: 48.0,
                  height: 28.0,
                  toggleSize: 24.0,
                  value: _userProfileSettingOfflineCubit.syncOnMobileData,
                  borderRadius: 40.0,
                  padding: 1.8,
                  activeToggleColor: AColors.white,
                  inactiveToggleColor: AColors.white,
                  activeIcon: Icon(
                    Icons.check,
                    color: AColors.themeBlueColor,
                    size: 30,
                  ),
                  inactiveIcon: Icon(
                    Icons.close,
                    color: AColors.hintColor,
                    size: 30,
                  ),
                  toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                  activeColor: AColors.themeBlueColor,
                  inactiveColor: AColors.hintColor,
                  onToggle: (val) async {
                    await _userProfileSettingOfflineCubit
                        .toggleSyncOnMobileData(val);
                  },
                )
              ],
            );*/
          /*case 1:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_include_attachments,
                  fontWeight: AFontWight.regular,
                  fontSize: 16.0,
                  color: AColors.iconGreyColor,
                  textAlign: TextAlign.left,
                ),
                AToggleSwitch(
                  disabled: _userProfileSettingOfflineCubit.workOffline,
                  width: 48.0,
                  height: 28.0,
                  toggleSize: 24.0,
                  value: _userProfileSettingOfflineCubit.includeAttachments,
                  borderRadius: 40.0,
                  padding: 1.8,
                  activeToggleColor: AColors.white,
                  inactiveToggleColor: AColors.white,
                  activeIcon: Icon(
                    Icons.check,
                    color: AColors.themeBlueColor,
                    size: 30,
                  ),
                  inactiveIcon: Icon(
                    Icons.close,
                    color: AColors.hintColor,
                    size: 30,
                  ),
                  toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                  activeColor: AColors.themeBlueColor,
                  inactiveColor: AColors.hintColor,
                  onToggle: (val) async {
                    await _userProfileSettingOfflineCubit
                        .toggleIncludeAttachments(val);
                  },
                )
              ],
            );*/
          /*case 2:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_include_associations,
                  fontWeight: AFontWight.regular,
                  fontSize: 16.0,
                  color: AColors.iconGreyColor,
                  textAlign: TextAlign.left,
                ),
                AToggleSwitch(
                  disabled: _userProfileSettingOfflineCubit.workOffline,
                  width: 48.0,
                  height: 28.0,
                  toggleSize: 24.0,
                  value: _userProfileSettingOfflineCubit.includeAssociations,
                  borderRadius: 40.0,
                  padding: 1.8,
                  activeToggleColor: AColors.white,
                  inactiveToggleColor: AColors.white,
                  activeIcon: Icon(
                    Icons.check,
                    color: AColors.themeBlueColor,
                    size: 30,
                  ),
                  inactiveIcon: Icon(
                    Icons.close,
                    color: AColors.hintColor,
                    size: 30,
                  ),
                  toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                  activeColor: AColors.themeBlueColor,
                  inactiveColor: AColors.hintColor,
                  onToggle: (val) async {
                    await _userProfileSettingOfflineCubit
                        .toggleIncludeAssociations(val);
                  },
                )
              ],
            );
          case 3:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_include_sub_location_data,
                  fontWeight: AFontWight.regular,
                  fontSize: 16.0,
                  color: AColors.iconGreyColor,
                  textAlign: TextAlign.left,
                ),
                AToggleSwitch(
                  disabled: _userProfileSettingOfflineCubit.workOffline,
                  width: 48.0,
                  height: 28.0,
                  toggleSize: 24.0,
                  value: _userProfileSettingOfflineCubit.includeSubLocationData,
                  borderRadius: 40.0,
                  padding: 1.8,
                  activeToggleColor: AColors.white,
                  inactiveToggleColor: AColors.white,
                  activeIcon: Icon(
                    Icons.check,
                    color: AColors.themeBlueColor,
                    size: 30,
                  ),
                  inactiveIcon: Icon(
                    Icons.close,
                    color: AColors.hintColor,
                    size: 30,
                  ),
                  toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                  activeColor: AColors.themeBlueColor,
                  inactiveColor: AColors.hintColor,
                  onToggle: (val) async {
                    await _userProfileSettingOfflineCubit
                        .toggleIncludeSubLocationData(val);
                  },
                )
              ],
            );
          case 4:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_include_closed_out_tasks,
                  fontWeight: AFontWight.regular,
                  fontSize: 16.0,
                  color: AColors.iconGreyColor,
                  textAlign: TextAlign.left,
                ),
                AToggleSwitch(
                  disabled: _userProfileSettingOfflineCubit.workOffline,
                  width: 48.0,
                  height: 28.0,
                  toggleSize: 24.0,
                  value: _userProfileSettingOfflineCubit.includeClosedOutTasks,
                  borderRadius: 40.0,
                  padding: 1.8,
                  activeToggleColor: AColors.white,
                  inactiveToggleColor: AColors.white,
                  activeIcon: Icon(
                    Icons.check,
                    color: AColors.themeBlueColor,
                    size: 30,
                  ),
                  inactiveIcon: Icon(
                    Icons.close,
                    color: AColors.hintColor,
                    size: 30,
                  ),
                  toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                  activeColor: AColors.themeBlueColor,
                  inactiveColor: AColors.hintColor,
                  onToggle: (val) async {
                    await _userProfileSettingOfflineCubit
                        .toggleIncludeClosedOutTasks(val);
                  },
                )
              ],
            );
          case 5:
            return Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: NormalTextWidget(
                    context.toLocale!.lbl_include_date_range_specific_data,
                    fontWeight: AFontWight.regular,
                    fontSize: 16.0,
                    color: AColors.iconGreyColor,
                    textAlign: TextAlign.left,
                  ),
                ),
                GestureDetector(
                    onTap: _userProfileSettingOfflineCubit.workOffline? null: widget
                        .userProfileSettingCubit.onSelectDateRangeButtonClick,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: NormalTextWidget(
                        title,
                        fontWeight: AFontWight.regular,
                        fontSize: 16.0,
                        color: AColors.textColor,
                        textAlign: TextAlign.left,
                      ),
                    )),
              ],
            );*/
        }

        return Container();
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox();
        // Divider();
      },
    );
  }
}
