import 'package:custom_timer/custom_timer.dart';
import 'package:dio/dio.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/login/login_cubit.dart';
import '../../../bloc/login/login_state.dart';
import '../../../data/model/user_vo.dart';
import '../../../logger/logger.dart';
import '../../../networking/network_info.dart';
import '../../../networking/network_response.dart';
import '../../../widgets/backtologin_textbutton.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/headlinetext.dart';
import '../../../widgets/normaltext.dart';
import '../../../widgets/progressbar.dart';
import '../../../widgets/textformfieldwidget.dart';
import '../../base/state_renderer/state_renderer.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';

class TwoFactorAuthLoginWidget extends StatefulWidget {
  final Function callback;
  Function? handleBackPress;
  final dynamic paramData;
  Function? handleNavigation;

  TwoFactorAuthLoginWidget(this.callback,
      {Key? key,
      required this.paramData,
      this.handleBackPress,
      this.handleNavigation})
      : super(key: key);

  @override
  State<TwoFactorAuthLoginWidget> createState() =>
      _TwoFactorAuthLoginWidgetState();
}

class _TwoFactorAuthLoginWidgetState extends State<TwoFactorAuthLoginWidget> {
  TextEditingController codeController = TextEditingController();
  bool _btnEnabled = false;
  final LoginCubit _loginCubit = di.getIt<LoginCubit>();
  final CustomTimerController _controller = CustomTimerController();
  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: 'form');
  var date;
  var seconds;

  _manageLoginResult(Result result) async {
    dynamic user = result.data;
    Headers? resHeader = result.responseHeader;
    if ((user as User).apiResponseFailure == null &&
        (user).usersessionprofile != null) {
        Log.d("user in login screen");
        StorePreference.removeData('2FA');
        widget.handleNavigation!(user);
    } else {
      if ((user).apiResponseFailure != null) {
        if (user.apiResponseFailure['isSecondaryAuthEnabled']
                .toString()
                .toLowerCase() ==
            'true') {
          String? jsessionid = resHeader?.getJSessionId().toString() ?? "";
          widget.paramData['JSESSIONID'] = jsessionid;
          _controller.reset();
          _controller.start(disableNotifyListeners: false);

          await StorePreference.setResendNowBool("resendEnabled", false);
          setState(() {});
          PreferenceUtils.setString('2FA', DateTime.now().toString());
        } else {}
      }
    }
  }

  @override
  void initState() {
    StorePreference.getStringData('2FA').then((dateString) {
      if (dateString.isEmpty) {
        dateString = DateTime.now().toString();
        StorePreference.setStringData('2FA', dateString);
      }
      date = DateTime.parse(dateString);
      date = DateTime(date.year, date.month, date.day, date.hour,
          date.minute + 5, date.second);
      var now = DateTime.now();
      var diff = date.difference(now);
      seconds = diff.inSeconds;
      if (seconds < 0) {
        seconds = 0;
      }
      _loginCubit.emitContentState(seconds);
    });
    codeController.addListener(() {
      if (codeController.text.isNotEmpty) {
        setState(() {
          _btnEnabled = true;
        });
      } else {
        setState(() {
          _btnEnabled = false;
        });
      }
    });
    super.initState();
    _controller.start(disableNotifyListeners: false);
    FireBaseEventAnalytics.setCurrentScreen(FireBaseFromScreen.twoFA.value);
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

  @override
  Widget build(BuildContext context) {
    final txtName = HeadlineTextWidget(
      "Welcome \n${widget.paramData['userName']}",
    );

    // StorePreference.getStringData('2FA').then((dateString) {
    //   if(dateString.isEmpty){
    //     dateString = DateTime.now().toString();
    //     StorePreference.setStringData('2FA',dateString);
    //   }
    //   var date = DateTime.parse(dateString);
    //   date = DateTime(date.year, date.month, date.day, date.hour, date.minute + 5,
    //       date.second);
    //   var diff = date.difference(now);
    //   seconds = diff.inSeconds;
    //   if (seconds < 0) {
    //     seconds = 0;
    //   }
    // });

    final lblTwoFactorDesc = BlocBuilder<LoginCubit, FlowState>(
        buildWhen: (prev, current) => current is TwoFactorTimer,
        builder: (context, state) {
          if (state is TwoFactorTimer) {
            return Align(
              alignment: Alignment.centerLeft,
              child: CustomTimer(
                controller: _controller,
                begin: Duration(seconds: state.seconds),
                end: const Duration(),
                builder: (remaining) {
                  return NormalTextWidget(context.toLocale!.lbl_two_factor_desc
                      .replaceAll(
                          "5", "${remaining.minutes}:${remaining.seconds}"));
                },
                onChangeState: (state) async {
                  if (state == CustomTimerState.reset) {
                    await StorePreference.setResendNowBool(
                        "resendEnabled", false);
                    setState(() {});
                  } else if (state == CustomTimerState.finished) {
                    await StorePreference.setResendNowBool(
                        "resendEnabled", true);
                    setState(() {});
                  }
                },
              ),
            );
          } else {
            return Container();
          }
        });

    final lblVerification = Align(
      alignment: Alignment.centerLeft,
      child: NormalTextWidget(context.toLocale!.lbl_verification,
          fontWeight: AFontWight.light),
    );

    final containerVerificationCode = _containerTextFields(
      lblVerification,
      ATextFormFieldWidget(
          key: const Key('Verification code'),
          keyboardType: TextInputType.text,
          isPassword: false,
          obscureText: false,
          controller: codeController,
          hintText: context.toLocale!.hint_verification_code),
    );

    final lblErrorMessage = BlocBuilder<LoginCubit, FlowState>(
       key: const Key("Error message"),
        builder: (context, state) {
          if (state is SuccessState || state is LoadingState) {
            _loginCubit.message = "";
            return const SizedBox(height: 0);
          } else if (state is ErrorState || (_loginCubit.getMessage?.isNotEmpty ?? false)) {
            if(state is ErrorState){
              _loginCubit.message = state.message;
            }
            return Padding(
              padding: const EdgeInsets.only(left: 16.0,top: 0.0,bottom: 0.0,right: 16.0),
              child: NormalTextWidget(_loginCubit.getMessage!,
                  color: Colors.red, textAlign: TextAlign.start),
            );
          } else {
            return const SizedBox(height: 0);
          }
        });

    final containerContinue =
        BlocBuilder<LoginCubit, FlowState>(builder: (context, state) {
      return (state is LoadingState)
          ? const ACircularProgress()
          : FractionallySizedBox(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AElevatedButtonWidget(
                  key: const Key('Continue Button'),
                  btnLabel: context.toLocale!.login_btn_sign_in,
                  btnLabelClr:
                      _btnEnabled ? Colors.white : AColors.lightGreyColor,
                  btnBackgroundClr: _btnEnabled
                      ? AColors.themeBlueColor
                      : AColors.btnDisableClr,
                  onPressed: _btnEnabled
                      ? () async {
                          if (isNetWorkConnected()) {
                            do2FALogin(context);
                          } else {
                            _loginCubit.emitState(ErrorState(StateRendererType.isValid,context.toLocale!.login_nt_supported_offline_mode, time: DateTime.now().millisecondsSinceEpoch.toString()));
                          }
                        }
                      : null,
                ),
              ),
            );
    });

    Widget lblResend() {
      _loginCubit.updateResendButtonVisibility();
      return BlocBuilder<LoginCubit, FlowState>(
          key: const Key('Resend Button'),
        buildWhen: (prev,current) => current is TwoFactorResendButtonEnable,
          builder: (context, state) {
        if (state is TwoFactorResendButtonEnable && state.isResendEnable) {
          return GestureDetector(

            onTap: () {
              _loginCubit.doLogin(
                  widget.paramData['email'], widget.paramData['password']);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 10),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: NormalTextWidget(
                          context.toLocale!.lbl_resend,
                          fontWeight: AFontWight.light,
                        ),
                      ),
                      NormalTextWidget(
                        context.toLocale!.text_resend_now,
                        fontWeight: AFontWight.light,
                        color: AColors.themeBlueColor,
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: NormalTextWidget(
                          "Verification code has timed out.",
                          color: Colors.red,
                          textAlign: TextAlign.start)),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      });
    }

    return BlocListener<LoginCubit, FlowState>(
      listener: (context, state) {
        if (state is SuccessState) {
          StorePreference.removeData("resendEnabled");
          _manageLoginResult(state.response);
        } else if (state is ErrorState) {}
      },
      child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              txtName,
              const SizedBox(
                height: 30,
              ),
              lblTwoFactorDesc,
              const SizedBox(
                height: 30,
              ),
              containerVerificationCode,
              lblResend(),
              const SizedBox(height: 8),
              lblErrorMessage,
              const SizedBox(height: 8),
              containerContinue,
              ATextbuttonWidget(
                  label: context.toLocale!.lbl_back_sign_in,
                  buttonIcon: Icons.arrow_back,
                  onPressed: () {
                    StorePreference.removeData('2FA');
                    widget.handleBackPress!();
                    widget.handleBackPress!();
                  }),
            ],
          )),
    );
  }

  do2FALogin(BuildContext context) {
    context.closeKeyboard();
    _loginCubit.do2FALogin(
        widget.paramData['email'],
        widget.paramData['password'] ?? "",
        codeController.text,
        widget.paramData['JSESSIONID']);
  }
}
