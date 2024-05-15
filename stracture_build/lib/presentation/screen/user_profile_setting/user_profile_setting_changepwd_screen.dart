import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:field/widgets/textformfieldwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';


class UserProfileSettingChangePwdScreen extends StatefulWidget {
  const UserProfileSettingChangePwdScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileSettingChangePwdScreen> createState() => _UserProfileSettingChangePwdScreenState();
}

class _UserProfileSettingChangePwdScreenState extends State<UserProfileSettingChangePwdScreen> {
  late UserProfileSettingCubit _userProfileSettingCubit;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  late AProgressDialog? aProgressDialog;

  @override
  void initState() {
    _userProfileSettingCubit = BlocProvider.of<UserProfileSettingCubit>(context);
    super.initState();
    aProgressDialog = AProgressDialog(context, isAnimationRequired: true);
    //_userProfileSettingCubit.saveButtonDisabled();
    _bindChangePasswordTxtBoxes();
  }

  @override
  Widget build(BuildContext context) {
    return _changePasswordWidget(context);
  }

  Widget _containerTextFields(Widget lblChild, Widget inputChild) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: lblChild,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.white, spreadRadius: 2),
              ],
            ),
            child: inputChild,
          ),
        ),
      ],
    );
  }

  Widget _changePasswordWidget(BuildContext context) {
    final changePasswordTitle = Align(
      alignment:AlignmentDirectional.centerStart,
      child: NormalTextWidget(
        context.toLocale!.lbl_change_password,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
        color: AColors.textColor,
      ),
    );

    final lblCurrentPassword = Align(
      alignment: AlignmentDirectional.centerStart,
      child: NormalTextWidget(
        fontWeight: FontWeight.w500,
        fontSize: 15.0,
        color: AColors.textColor,
        context.toLocale!.lbl_current_password,
      ),
    );

    final containerCurrentPassword = _containerTextFields(
      lblCurrentPassword,
      BlocBuilder<UserProfileSettingCubit, FlowState>(
        buildWhen: (previous,current)=>current is ShowEyeIconState || current is PasswordVisiblityToggle,
        builder: (context, state) {
          return ATextFormFieldWidget(
            key: const Key('CurrentPassword'),
            isPassword: true,
            border: OutlineInputBorder(borderSide: BorderSide(
              color: AColors.lightGreyColor
            )),
            focusBorder: OutlineInputBorder(borderSide: BorderSide(
                color: AColors.lightGreyColor
            )),
            obscureText: _userProfileSettingCubit.obscureCurrentPwdText,
            controller: _currentPasswordController,
            hintText: context.toLocale!.login_et_user_password,
            onShowPasswordClick: _userProfileSettingCubit.onCurrentPwdToggle,
          );
        },
      ),
    );

    final lblNewPassword = Align(
      alignment: AlignmentDirectional.centerStart,
      child: NormalTextWidget(
        fontWeight: FontWeight.w500,
        fontSize: 15.0,
        color: AColors.textColor,
        context.toLocale!.lbl_new_password,
      ),
    );

    final containerNewPassword = _containerTextFields(
      lblNewPassword,
      BlocBuilder<UserProfileSettingCubit, FlowState>(
          buildWhen: (previous,current)=>current is ShowEyeIconState || current is PasswordVisiblityToggle,
          builder: (context, state) {
            return ATextFormFieldWidget(
              key: const Key('NewPassword'),
              isPassword: true,
              obscureText: _userProfileSettingCubit.obscureNewPwdText,
              controller: _newPasswordController,
              border: OutlineInputBorder(borderSide: BorderSide(
                  color: AColors.lightGreyColor
              )),
              focusBorder: OutlineInputBorder(borderSide: BorderSide(
                  color: AColors.lightGreyColor
              )),
              hintText: context.toLocale!.login_et_new_password,
              onShowPasswordClick: _userProfileSettingCubit.onNewPwdToggle,
            );
          }
      ),
    );

    final lblConfirmPassword = Align(
      alignment: AlignmentDirectional.centerStart,
      child: NormalTextWidget(
        fontWeight: FontWeight.w500,
        fontSize: 15.0,
        color: AColors.textColor,
        context.toLocale!.lbl_confirm_password,
      ),
    );

    final containerConfirmPassword = _containerTextFields(
      lblConfirmPassword,
      BlocBuilder<UserProfileSettingCubit, FlowState>(
          buildWhen: (previous,current)=>current is ShowEyeIconState || current is PasswordVisiblityToggle,
          builder: (context, state) {
            return ATextFormFieldWidget(
              key: const Key('ConfirmPassword'),
              isPassword: true,
              obscureText: _userProfileSettingCubit.obscureConfirmNewPwdText,
              controller: _confirmNewPasswordController,
              hintText: context.toLocale!.login_et_new_password,
              border: OutlineInputBorder(borderSide: BorderSide(
                  color: AColors.lightGreyColor
              )),
              focusBorder: OutlineInputBorder(borderSide: BorderSide(
                  color: AColors.lightGreyColor
              )),
              onShowPasswordClick: _userProfileSettingCubit.onConfirmNewPwdToggle,
            );
          }
      ),
    );

    return BlocListener<UserProfileSettingCubit, FlowState>(
      //listenWhen: (previous, current) => current is ChangePasswordState,
        listener: (context, state) {
          aProgressDialog?.dismiss();
          if (state is ChangePasswordState && state.internalState == InternalState.loading) {
            aProgressDialog?.show();
          } else if (state is ChangePasswordState && state.internalState == InternalState.success) {
            if(state.message=="Password_changed_successfully"){
              context.showSnack(context.toLocale!.change_password_success_message);
            }
          } else if (state is ChangePasswordState && state.internalState == InternalState.failure) {
            context.showSnack(state.message??context.toLocale!.change_password_failure_message);
          }
        },
        child: BlocBuilder<UserProfileSettingCubit, FlowState>(
            //buildWhen: (prev, current) => current is ChangePasswordState,
            builder: (context, state) {
              return Container(
                margin: const EdgeInsets.only(bottom: 50.0),
                decoration: BoxDecoration(color:AColors.white,borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    changePasswordTitle,
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            containerCurrentPassword,
                            containerNewPassword,
                            containerConfirmPassword,
                            const SizedBox(height: 14.0,),
                            ADividerWidget(thickness: 1),
                            const SizedBox(height: 14.0,),
                            Row(
                              verticalDirection: VerticalDirection.up,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  key: const Key("Cancel_Button_Change_Pwd"),
                                  onPressed: () async {
                                    _currentPasswordController.clear();
                                    _newPasswordController.clear();
                                    _confirmNewPasswordController.clear();
                                    _userProfileSettingCubit.onCancelBtnClickOfChangePassword();
                                  },
                                  child: NormalTextWidget(
                                    context.toLocale!.lbl_btn_cancel,
                                    color: AColors.themeBlueColor,
                                  ),
                                ),
                                const SizedBox(width: 24.0,),
                                AElevatedButtonWidget(
                                  key: const Key("Save_Button_Change_Pwd"),
                                  btnLabel: context.toLocale!.lbl_btn_save,
                                  onPressed: () {
                                    _userProfileSettingCubit.saveButtonEnabled
                                        ? _onSaveBtnClickofChangePwd
                                        : null;
                                    FireBaseEventAnalytics.setEvent(
                                        FireBaseEventType.changePasswordSave, FireBaseFromScreen.settingChangePassword,
                                        bIncludeProjectName: true);
                                  },
                                  btnBackgroundClr: _userProfileSettingCubit.saveButtonEnabled ? AColors.themeBlueColor : AColors.btnDisableClr,
                                  btnBorderClr: _userProfileSettingCubit.saveButtonEnabled ? AColors.themeBlueColor : AColors.btnDisableClr,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            }
        )
    );
  }

  void _onSaveBtnClickofChangePwd() {
    _userProfileSettingCubit.onSaveBtnClickOfChangePassword();
  }

  _bindChangePasswordTxtBoxes() {
    _userProfileSettingCubit.saveButtonDisabled();
    _currentPasswordController.addListener(() {
      _validateChangePassword();
      if (_currentPasswordController.text != "") {
        _userProfileSettingCubit.userProfileSetting.curPassword = _currentPasswordController.text;
        _userProfileSettingCubit.showEyeIcon();
      }
    });
    _newPasswordController.addListener(() {
      _validateChangePassword();
      if (_newPasswordController.text != "") {
        _userProfileSettingCubit.userProfileSetting.newPassword = _newPasswordController.text;
        _userProfileSettingCubit.showEyeIcon();
      }
    });
    _confirmNewPasswordController.addListener(() {
      _validateChangePassword();
      if (_confirmNewPasswordController.text != "") {
        _userProfileSettingCubit.userProfileSetting.confirmPassword = _confirmNewPasswordController.text;
        _userProfileSettingCubit.showEyeIcon();
      }
    });
  }


_validateChangePassword() {
    if (_currentPasswordController.text != "" &&
        _newPasswordController.text != "" &&
        _confirmNewPasswordController.text == _newPasswordController.text &&
        _currentPasswordController.text != _newPasswordController.text) {
      _userProfileSettingCubit.onSaveButtonEnabled();
    }else{
      _userProfileSettingCubit.saveButtonDisabled();
    }
  }
}