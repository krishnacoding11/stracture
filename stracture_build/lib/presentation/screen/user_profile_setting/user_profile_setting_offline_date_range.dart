import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_offline_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileSettingDateRangeScreen extends StatefulWidget {
  final UserProfileSettingCubit userProfileSettingCubit;

  const UserProfileSettingDateRangeScreen(
      {Key? key, required this.userProfileSettingCubit})
      : super(key: key);

  @override
  State<UserProfileSettingDateRangeScreen> createState() =>
      _UserProfileSettingsDateRangeScreenState();
}

class _UserProfileSettingsDateRangeScreenState
    extends State<UserProfileSettingDateRangeScreen> {
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NormalTextWidget(
                            context.toLocale!.lbl_select_date_range,
                            fontSize: 18,
                            fontWeight: AFontWight.semiBold,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          dateRangeListItem(context),
                          Container(
                            alignment: Alignment.centerRight,
                            height: 40,
                            child: TextButton(
                              key: const Key(
                                  "Offline_Data_Back_Button_User_Profile_Settings"),
                              onPressed: () async {
                                widget.userProfileSettingCubit
                                    .onOfflineDataButtonClick();
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
                ),
        ));
  }

  Widget dateRangeListItem(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      decoration: BoxDecoration(
          color: AColors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: AColors.lightGreyColor)),
      child: ListView.builder(
        reverse: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          Color color = AColors.aPrimaryColor.withOpacity(0);
          if (index == _userProfileSettingOfflineCubit.selectedDateRange.index) {
            color = AColors.aPrimaryColor;
          }
          Color textColor = AColors.aPrimaryColor;
          if (index == _userProfileSettingOfflineCubit.selectedDateRange.index) {
            textColor = AColors.white;
          }
          String title = "";
          if (index == SyncDateRange.lastWeek.index) {
            title = context.toLocale!.lbl_last_week;
          } else if (index == SyncDateRange.last2Weeks.index) {
            title = context.toLocale!.lbl_last_2_weeks;
          } else if (index == SyncDateRange.lastMonth.index) {
            title = context.toLocale!.lbl_last_month;
          } else if (index == SyncDateRange.last2Months.index) {
            title = context.toLocale!.lbl_last_2_month;
          } else if (index == SyncDateRange.last6Months.index) {
            title = context.toLocale!.lbl_last_6_month;
          }

          return GestureDetector(
            onTap: (){
              _userProfileSettingOfflineCubit.setSelectedDateRange(index);
            },
            child: Container(
              color: color,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              height: 40,
              alignment: Alignment.centerLeft,
              child: NormalTextWidget(
                title,
                fontWeight: AFontWight.regular,
                fontSize: 16.0,
                color: textColor,
                textAlign: TextAlign.left,
              ),
            ),
          );
        },
      ),
    );
  }
}
