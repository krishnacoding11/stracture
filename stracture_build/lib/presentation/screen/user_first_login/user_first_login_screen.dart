import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/presentation/screen/user_first_login/privacy_policy.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/qrcode_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/login_background.dart';
import '../../../widgets/progressbar.dart';
import '../../base/state_renderer/state_render_impl.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';
import '../../managers/routes_manager.dart';
import 'edit_avatar/edit_avatar.dart';
import 'edit_notification/edit_notification.dart';

class UserFirstLogin extends StatefulWidget {
  final dynamic arguments;

  const UserFirstLogin(this.arguments, {Key? key}) : super(key: key);

  @override
  State<UserFirstLogin> createState() => _UserFirstLoginState();
}

class _UserFirstLoginState extends State<UserFirstLogin> {
  late UserFirstLoginSetupCubit _firstLoginSetupCubit;

  @override
  void initState() {
    _firstLoginSetupCubit = BlocProvider.of<UserFirstLoginSetupCubit>(context);
    getUserData();
    Future.delayed(const Duration(milliseconds: 100), () {
      _firstLoginSetupCubit.getUserName();
      _firstLoginSetupCubit.setupNotification();
    });
    super.initState();
  }

  getUserData() async {
    await _firstLoginSetupCubit.getUserDataFromLocal();
  }

  bool _isDisableContinueBtn() {
    return (_firstLoginSetupCubit
        .currentSetupScreen !=
        UserFirstLoginSetup
            .editProfileImage &&
        _firstLoginSetupCubit
            .isPrivacyAccept) ||
        (_firstLoginSetupCubit.currentSetupScreen ==
            UserFirstLoginSetup
                .editProfileImage &&
            _firstLoginSetupCubit
                .currentUserAvatar !=
                null);
  }

  @override
  Widget build(BuildContext context) {
    final welcomeHeader = Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: BlocBuilder<UserFirstLoginSetupCubit, FlowState>(
          builder: (context, state) {
            return NormalTextWidget(
              context.toLocale!.welcome_to_asite_field(_firstLoginSetupCubit.username ?? ""),
              fontSize: 28,
              fontWeight: AFontWight.medium,
            );
          },
        ));

    final divider = BlocBuilder<UserFirstLoginSetupCubit, FlowState>(builder: (context, state) {
      return Container(
        margin: Utility.isTablet
            ? MediaQuery
            .of(context)
            .orientation == Orientation.landscape &&
            _firstLoginSetupCubit.currentSetupScreen == UserFirstLoginSetup.editProfileImage
            ? const EdgeInsets.only(left: 24, right: 24, bottom: 24)
            : const EdgeInsets.all(24)
            : const EdgeInsets.all(16.0),
        height: 1.5,
        color: AColors.btnDisableClr,
      );
    });

    Widget getBasicUserSetup() {
      switch (_firstLoginSetupCubit.currentSetupScreen) {
        case UserFirstLoginSetup.privacyPolicy:
          return const PrivacyPolicy();
        case UserFirstLoginSetup.editNotification:
          return const EditNotificationSetting();
        case UserFirstLoginSetup.editProfileImage:
          return const EditAvatar(
            from: AConstants.userFirstLogin,
          );
      }
    }

    Widget commonButtonRow() {
      return Container(
          margin: const EdgeInsets.only(bottom: 20, right: 20),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _firstLoginSetupCubit.currentSetupScreen == UserFirstLoginSetup.editProfileImage
                  ? Flexible(
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('SkipButton'),
                        onTap: () => navigateToNextScreen(context),
                        child: Container(
                          margin: const EdgeInsets.only(left: 28, right: 28, top: 10, bottom: 10),
                          child: NormalTextWidget(
                            context.toLocale!.text_skip,
                            fontSize: 15,
                            fontWeight: AFontWight.medium,
                            color: AColors.themeBlueColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
                  : _firstLoginSetupCubit.currentSetupScreen == UserFirstLoginSetup.privacyPolicy &&
                  Utility.isTablet
                  ? Flexible(
                child: Container(
                  key: const Key('CheckBoxClick'),
                  padding: const EdgeInsets.only(top: 4, bottom: 0, left: 24),
                  child: Row(children: [
                    Checkbox(
                      checkColor: AColors.white,
                      activeColor: AColors.themeBlueColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.5)),
                      value: _firstLoginSetupCubit.isPrivacyAccept,
                      onChanged: (bool? value) {
                        _firstLoginSetupCubit.onChangePrivacyAccept();
                      },
                    ),
                    Flexible(
                      child: InkWell(
                          onTap: () => _firstLoginSetupCubit.onChangePrivacyAccept(),
                          child: NormalTextWidget(
                            context.toLocale!.i_agree_to_term_condition,
                            fontWeight: AFontWight.regular,
                          )),
                    )
                  ]),
                ),
              )
                  : Container(),
              Row(
                children: [
                  _firstLoginSetupCubit.currentSetupScreen != UserFirstLoginSetup.privacyPolicy
                      ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                        key: const Key("BackButton"),
                        onTap: () {
                          _firstLoginSetupCubit.backToCurrent(
                              userFirstLoginCurrentScreen: _firstLoginSetupCubit
                                  .currentSetupScreen);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 28, right: 28, top: 10, bottom: 10),
                          child: NormalTextWidget(
                            context.toLocale!.lbl_back,
                            fontSize: 15,
                            fontWeight: AFontWight.medium,
                            color: AColors.themeBlueColor,
                          ),
                        )),
                  )
                      : Material(
                    color: Colors.transparent,
                    child: InkWell(
                        key: const Key("CancelButton"),
                        onTap: () {
                          AppConfig appConfig = getIt<AppConfig>();
                          appConfig.isOnBoarding = true;
                          if (widget.arguments == "fromSplash") {
                            Navigator.pushReplacementNamed(context, Routes.onboardingLogin);
                          } else {
                            _firstLoginSetupCubit.cancelTermOfUse();
                            AppConfig appConfig = getIt<AppConfig>();
                            appConfig.isOnBoarding = true;
                            Navigator.pop(context, widget.arguments);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(left: 28, right: 28, top: 10, bottom: 10),
                          child: NormalTextWidget(
                            context.toLocale!.lbl_btn_cancel,
                            fontSize: 15,
                            fontWeight: AFontWight.medium,
                            color: AColors.themeBlueColor,
                          ),
                        )),
                  ),
                  BlocBuilder<UserFirstLoginSetupCubit, FlowState>(builder: (context, state) {
                    return (state is LoadingState)
                        ? const ACircularProgress()
                        : AElevatedButtonWidget(
                      key: const Key('ContinueButton'),
                      btnLabel: context.toLocale!.lbl_btn_continue,
                            btnLabelClr: _isDisableContinueBtn()
                                ? Colors.white
                                : Colors.grey,
                            btnBackgroundClr: _isDisableContinueBtn()
                                ? AColors.themeBlueColor
                                : AColors.btnDisableClr,
                            fontWeight: AFontWight.medium,
                            onPressed: () {
                              _isDisableContinueBtn()
                                  ? _firstLoginSetupCubit.continueToNext(
                                      userFirstLoginCurrentScreen:
                                          _firstLoginSetupCubit
                                              .currentSetupScreen,
                                      context: context,
                                      onFinish: () => navigateToNextScreen(context))
                            : null;
                      },
                    );
                  }),
                ],
              ),
            ],
          ));
    }

    return LoginBackgroundWidget(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<UserFirstLoginSetupCubit, FlowState>(builder: (builder, state) {
              return Container(
                margin: Utility.isTablet ? EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .viewPadding
                    .top + 80, bottom: 80) : EdgeInsets.only(top: MediaQuery
                    .of(context)
                    .viewPadding
                    .top + 45, bottom: 80),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [Flexible(child: welcomeHeader)],
                    ),
                    Expanded(
                        child: FractionallySizedBox(
                          widthFactor: Utility.isTablet ? 0.8 : 0.95,
                          heightFactor: Utility.isTablet ? 0.85 : 0.87,
                          alignment: Alignment.center,
                          child: Container(
                              decoration: BoxDecoration(color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: getBasicUserSetup()),
                                  _firstLoginSetupCubit.currentSetupScreen ==
                                      UserFirstLoginSetup.privacyPolicy && !Utility.isTablet
                                      ? Container(
                                    key: const Key('CheckBoxClick'),
                                    padding: const EdgeInsets.only(top: 4, left: 14),
                                    child: Row(children: [
                                      Checkbox(
                                        checkColor: AColors.white,
                                        activeColor: AColors.themeBlueColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(3.5)),
                                        value: _firstLoginSetupCubit.isPrivacyAccept,
                                        onChanged: (bool? value) {
                                          _firstLoginSetupCubit.onChangePrivacyAccept();
                                        },
                                      ),
                                      InkWell(
                                          onTap: () =>
                                              _firstLoginSetupCubit.onChangePrivacyAccept(),
                                          child: NormalTextWidget(
                                            context.toLocale!.i_agree_to_term_condition,
                                            fontSize: 14,
                                            fontWeight: AFontWight.regular,
                                          ))
                                    ]),
                                  )
                                      : Container(),
                                  divider,
                                  commonButtonRow()
                                ],
                              )),
                        ))
                  ],
                ),
              );
            })));
  }

  void navigateToNextScreen(BuildContext cContext) async {
    await _firstLoginSetupCubit.setAcceptedTermLocal();
    QRCodeDataVo? qrObj = await QrCodeUtility.extractDataFromLink();
    if(qrObj != null && qrObj.projectId != null){
      Navigator.pushReplacementNamed(cContext, Routes.dashboard);
    }
    else {
      Navigator.pushNamedAndRemoveUntil(cContext,Routes.dashboard, (route) => false);
      Navigator.pushNamed(cContext,Routes.projectList,arguments: AConstants.userFirstLogin);
    }
  }
}
