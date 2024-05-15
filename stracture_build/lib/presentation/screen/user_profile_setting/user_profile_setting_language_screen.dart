import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/data/model/language_vo.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';

class UserProfileSettingLanguageScreen extends StatefulWidget {
  const UserProfileSettingLanguageScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingLanguageScreen> createState() => _UserProfileSettingLanguageScreenState();
}

class _UserProfileSettingLanguageScreenState extends State<UserProfileSettingLanguageScreen> {
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
    return _getEditLanguageList(context);
  }

  Widget _getEditLanguageList(BuildContext context) {
    return BlocListener<UserProfileSettingCubit, FlowState>(
        listenWhen: (previous, current) => current is LanguageUpdateState,
        listener: (context, state) {
          aProgressDialog?.dismiss();
          if (state is LanguageUpdateState && state.internalState == InternalState.loading) {
            aProgressDialog?.show();
          } else if (state is LanguageUpdateState && state.internalState == InternalState.success) {
            context.showSnack(context.toLocale!.change_language_success_message);
          } else if (state is LanguageUpdateState && state.internalState == InternalState.failure) {
            context.showSnack(context.toLocale!.change_language_failure_message);
          }
        },
        child: BlocBuilder<UserProfileSettingCubit, FlowState>(
            buildWhen: (prev, current) => current is LanguageUpdateState,
            builder: (context, state) {
              return Container(
                key: const Key("Edit_Language_List_User_Profile_Settings"),
                margin: const EdgeInsets.only(bottom: 50.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration( color: AColors.white,borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NormalTextWidget(
                      context.toLocale!.lbl_edit_language,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                      textAlign: TextAlign.left,
                    ),
                      const SizedBox(height: 20,),
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
                                itemCount: _userProfileSettingCubit.languageData!.jsonLocales!.length,
                                itemBuilder: (context, index) {
                                  return _getLanguageMenuWidget(context,
                                      _userProfileSettingCubit.languageData!.jsonLocales![index],
                                      (_userProfileSettingCubit.languageData!.jsonLocales![index].languageId == _userProfileSettingCubit.userProfileSetting.languageId));
                                }),
                          ),
                        ),
                      ),
                    ADividerWidget(thickness: 1),
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        key: const Key("Edit_Language_Back_Button_User_Profile_Settings"),
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
        )
    );
  }

  Widget _getLanguageMenuWidget(BuildContext context, JsonLocales languageItem, bool isSelected) {
    return Material(
      child: ListTile(
        selected: isSelected,
        selectedTileColor: isSelected?AColors.listItemSelected:null,
        tileColor: AColors.white,
        onTap: () {
          selectLanguageItem(context, languageItem.languageId!);
          FireBaseEventAnalytics.setEvent(
              FireBaseEventType.languageChange,
              FireBaseFromScreen.settingLanguage,
              bIncludeProjectName: true);
        },
        dense: true,
        title: NormalTextWidget(
          "${languageItem.displayLanguage!} (${languageItem.displayCountry!})",
          fontWeight: FontWeight.w400,
          fontSize: 17.0,
          color: AColors.black,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  void selectLanguageItem(BuildContext context, String languageId) async {
    if (_userProfileSettingCubit.userProfileSetting.languageId != languageId) {
      //aProgressDialog?.show();
      _userProfileSettingCubit.onLanguageSelectionChange(languageId);
    }
  }
}