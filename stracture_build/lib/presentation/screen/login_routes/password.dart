 import 'package:dio/dio.dart';
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/bloc/login/login_state.dart';
import 'package:field/bloc/password/password_cubit.dart';
import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/data/model/login_exception.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/onboarding_login_screen.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/backtologin_textbutton.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/headlinetext.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:field/widgets/textformfieldwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../injection_container.dart';
import '../../../utils/store_preference.dart';

class PasswordWidget extends StatefulWidget {
  final Function callback;
  final Function? handleBackPress;
  final dynamic paramData;
  final String? screenName;
  final Function? handleNavigation;

  const PasswordWidget(this.callback, {Key? key, this.paramData, this.screenName, this.handleBackPress, this.handleNavigation})
      : super(key: key);

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  final TextEditingController _passwordController = TextEditingController();
  final LoginCubit _loginCubit = getIt<LoginCubit>();
  final PasswordCubit _passwordCubit = getIt<PasswordCubit>();
  bool _isIncorrectLogin = false;
  bool _buttonEnabled = false;
  String? message;
  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: 'form');
  DataCenters? ssoData;
  AppConfig appConfig = getIt<AppConfig>();

  _validate() {
   setState(() {
      if (_passwordController.text.isNotEmpty) {
        _buttonEnabled = true;
      } else {
        _buttonEnabled = false;
      }
    });
  }

  _bind() {
    ssoData = widget.paramData as DataCenters;
    _passwordController.addListener(() {
      _validate();
      _loginCubit.setPassword(_passwordController.text);
    });
  }

  @override
  void initState() {
    _bind();
    _loginCubit.emitState(InitialState(stateRendererType: StateRendererType.DEFAULT));
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
              color: AColors.white,
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
    Log.d("=== ${widget.screenName}");
    final txtSignIn = (widget.screenName != null && widget.screenName!.isNotEmpty)
        ? HeadlineTextWidget(
            "Welcome \n ${widget.screenName}",
            style: TextStyle(
              color: AColors.textColor,
              fontFamily: AFonts.fontFamily,
              fontWeight: AFontWight.medium,
              decoration: TextDecoration.none,
            ),
          )
        : HeadlineTextWidget(
            context.toLocale!.lbl_sign_in,
            style: TextStyle(
              color: AColors.textColor,
              fontFamily: AFonts.fontFamily,
              fontWeight: AFontWight.medium,
              decoration: TextDecoration.none,
            ),
          );

    final lblPassword = Align(
      alignment: Alignment.centerLeft,
      child: NormalTextWidget(
        context.toLocale!.lbl_password,
        fontWeight: AFontWight.medium,
        fontSize: 15,
      ),
    );

    final containerPassword = _containerTextFields(
      lblPassword,
      BlocBuilder<PasswordCubit, FlowState>(
          bloc: _passwordCubit,
          builder: (context, state) {
            bool obscureText = false;
            if(state is LoginPasswordToggle){
              Log.d("PasswordCubit >> ${state.isObscureText}");
             obscureText = state.isObscureText;
            }
            return ATextFormFieldWidget(
                key: const Key('Password'),
                isPassword: true,
                autofocus:appConfig.isOnBoarding!?true:false,
                obscureText: obscureText,
                controller: _passwordController,
                hintText: context.toLocale!.login_et_user_password,
                onShowPasswordClick: () {
                  _passwordCubit.togglePasswordVisibility();
                });
          }),
    );

    final textForgotPswd = GestureDetector(
      onTap: () {
        widget.callback(LoginWidgetState.forgot);
        FireBaseEventAnalytics.setEvent(FireBaseEventType.forgotPassword, FireBaseFromScreen.login);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: NormalTextWidget(
            context.toLocale!.login_btn_forgot_password,
            color: AColors.textColor1,
            fontWeight: AFontWight.medium,
            fontSize: 15,
          ),
        ),
      ),
    );

    final textIncorrectLogin = AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: _isIncorrectLogin ? 1 : 0,
      onEnd: () {
        if (!_isIncorrectLogin) {
         setState(() {
            _isIncorrectLogin = false;
         });
        }
      },
      child: Visibility(
        visible: _isIncorrectLogin,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
          child: SizedBox(
            child: Align(
              alignment: Alignment.centerLeft,
              child: NormalTextWidget(
                message ?? context.toLocale!.err_message_incorrect_login,
                maxLines: 8,
                color: Colors.red,
                fontWeight: AFontWight.regular,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );

    final containerLogin = BlocBuilder<LoginCubit, FlowState>(builder: (context, state) {
      return ((state is LoadingState || state is LoginSuccessState) && !_isIncorrectLogin)
          ? const ACircularProgress()
          : FractionallySizedBox(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AElevatedButtonWidget(
                    key: const Key('LoginButton'),
                    btnLabel: context.toLocale!.login_btn_sign_in,
                    btnLabelClr: _buttonEnabled ? Colors.white : Colors.grey,
                    fontWeight: AFontWight.medium,
                    fontSize: 15,
                    btnBackgroundClr:
                        _buttonEnabled ? AColors.themeBlueColor : AColors.btnDisableClr,
                    onPressed: _buttonEnabled
                        ? () async {
                            if (isNetWorkConnected()) {
                              context.closeKeyboard();
                              FireBaseEventAnalytics.setEvent(FireBaseEventType.signIn, FireBaseFromScreen.login);
                             setState(() {
                                _isIncorrectLogin = false;
                             });
                              _loginCubit.doLogin(ssoData?.email ?? "", _passwordController.text);
                            } else {
                             _loginCubit.emitState(ErrorState(StateRendererType.isValid,context.toLocale!.login_nt_supported_offline_mode,time: DateTime.now().millisecondsSinceEpoch.toString() ));
                            }
                          }
                        : null),
              ),
            );
    });

    return BlocListener<LoginCubit, FlowState>(
      listener: (context, state) {
        if (state is SuccessState) {
          _manageLoginResult(state.response);
          FireBaseEventAnalytics.setEvent(FireBaseEventType.login, FireBaseFromScreen.login);
        } else if (state is ErrorState) {
          if (state.stateRendererType == StateRendererType.DEFAULT) {
            context.showSnack(state.message);
          } else {
           setState(() {
              message = state.message;
              _isIncorrectLogin = true;
           });
          }
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            txtSignIn,
            const SizedBox(height: 30),
            containerPassword,
            textForgotPswd,
            const SizedBox(height: 10),
            textIncorrectLogin,
            containerLogin,
            const SizedBox(height: 15),
            ATextbuttonWidget(
                label: context.toLocale!.lbl_back_sign_in,
                buttonIcon: Icons.arrow_back,
                fontSize: 15,
                fontWeight: AFontWight.medium,
                onPressed: () {
                  _loginCubit.emitState(InitialState(stateRendererType: StateRendererType.DEFAULT));
                  // widget.callback(LoginWidgetState.login);
                  widget.handleBackPress!();
                }),
          ],
        ),
      ),
    );
  }

  _manageLoginResult(Result result) async {
    dynamic data = result.data;
    Headers? resHeader = result.responseHeader;
    if (data is User && data.apiResponseFailure != null) {
     setState(() {
        _isIncorrectLogin = false;
     });
      if (data.apiResponseFailure is AsiteApiExceptionThrown) {
        if (data.apiResponseFailure is AsiteApiExceptionThrown) {
          var exception = data.apiResponseFailure as AsiteApiExceptionThrown;
          if (exception.errorcode != null && exception.errorcode == '216') {
            message = context.toLocale!.err_message_incorrect_password;
          } else if(exception.errorcode != null && exception.errorcode == '221'){
            message = context.toLocale!.error_message_221;
          } else {
            message = exception.errormessage;
          }
         setState(() {
            _isIncorrectLogin = true;
         });
        }
      } else {
        if (data.apiResponseFailure['isSecondaryAuthEnabled'] != null &&
            data.apiResponseFailure['isSecondaryAuthEnabled'].toString().toLowerCase() == 'true') {
          data.apiResponseFailure['email'] = ssoData?.email;
          data.apiResponseFailure['password'] = _passwordController.text;
          String? jsessionid = resHeader!.getJSessionId().toString();
          data.apiResponseFailure['JSESSIONID'] = jsessionid;
          StorePreference.setStringData('2FA', DateTime.now().toString());
          widget.callback(LoginWidgetState.twoFactorLogin, data: data.apiResponseFailure);
        }
      }
    } else {
     setState(() {
        _isIncorrectLogin = false;
     });

      User user = data;
      appConfig.isOnBoarding = false;
      context.closeKeyboard();
      // navigate to main screen
      widget.handleNavigation!(user);
    }
  }
}
