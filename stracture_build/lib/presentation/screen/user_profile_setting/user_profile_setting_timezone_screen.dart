import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileSettingTimeZoneScreen extends StatefulWidget {
  const UserProfileSettingTimeZoneScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingTimeZoneScreen> createState() => _UserProfileSettingTimeZoneScreenState();
}

class _UserProfileSettingTimeZoneScreenState extends State<UserProfileSettingTimeZoneScreen> {
  late UserProfileSettingCubit _userProfileSettingCubit;
  late AProgressDialog? aProgressDialog;

  @override
  void initState() {
    _userProfileSettingCubit = BlocProvider.of<UserProfileSettingCubit>(context);
    super.initState();
    aProgressDialog = AProgressDialog(context, isAnimationRequired: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileSettingCubit,FlowState>(
      listenWhen: (previous,current)  => current is TimeZoneUpdateState,
      listener: (context, state) {
        aProgressDialog?.dismiss();
        if (state is TimeZoneUpdateState && state.internalState == InternalState.loading) {
          aProgressDialog?.show();
        } else if (state is TimeZoneUpdateState && state.internalState == InternalState.success) {
          context.showSnack(context.toLocale!.change_timezone_success_message);
        }else if (state is TimeZoneUpdateState && state.internalState == InternalState.failure) {
          context.showSnack(context.toLocale!.change_timezone_failure_message);
        }
      },
      child: BlocBuilder<UserProfileSettingCubit,FlowState>(
          buildWhen: (prev, current) => current is TimeZoneUpdateState,
          builder:(context,state){
            return Container(
              key: const Key("Edit_Timezone_List_User_Profile_Settings"),
              margin: const EdgeInsets.only(bottom: 50.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(color: AColors.white,borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NormalTextWidget(
                    context.toLocale!.lbl_edit_timezone,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 20.0,),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),side: BorderSide(color: AColors.lightGreyColor,width: 1.0)),
                      elevation: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        color: AColors.white,
                        child: ListView.builder(
                            reverse: false,
                            shrinkWrap: true,
                            itemCount: _userProfileSettingCubit.userProfileSetting.jsonTimZones!.length,
                            itemBuilder: (context, index) {
                              return _getTimeZoneMenuWidget(
                                  context,
                                  _userProfileSettingCubit.userProfileSetting.jsonTimZones![index],
                                  _userProfileSettingCubit.userProfileSetting.jsonTimZones![index].id==_userProfileSettingCubit.userProfileSetting.timeZone!
                              );
                            }),
                      ),
                    ),
                  ),
                  ADividerWidget(thickness: 1),
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const Key("Edit_Timezone_Back_Button_User_Profile_Settings"),
                      onPressed: () async {
                        _userProfileSettingCubit.onBackButtonClick();
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
      ),
    );
  }

  Widget _getTimeZoneMenuWidget(BuildContext context, JsonTimZones timeZoneItem, bool isSelected) {
    return Material(
      //borderRadius: BorderRadius.circular(8.0),
      //color: Colors.transparent,
      child: ListTile(
        selectedTileColor: isSelected?AColors.listItemSelected:null,
        selected: isSelected,
        tileColor: AColors.white,
        onTap: () => selectTimeZoneItem(context, timeZoneItem.id!),
        dense: true,
        title: NormalTextWidget(
          timeZoneItem.timeZone!,
          fontWeight: FontWeight.w400,
          fontSize: 17.0,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }

  void selectTimeZoneItem(BuildContext context, String timeZoneId) async {
    if (_userProfileSettingCubit.userProfileSetting.timeZone != timeZoneId) {
      //aProgressDialog?.show();
      _userProfileSettingCubit.onTimeZoneSelectionChange(timeZoneId);
    }
  }
}