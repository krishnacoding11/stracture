
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/widgets/sso_webview.dart';
import 'package:field/widgets/textformfieldwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/login/login_state.dart';
import '../../../networking/network_response.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/headlinetext.dart';
import '../../../widgets/normaltext.dart';
import '../../../widgets/progressbar.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';
import '../onboarding_login_screen.dart';

class LoginWidget extends StatefulWidget {
  final Function callback;
  final Function? handleNavigation;

  const LoginWidget(this.callback, {Key? key,this.handleNavigation,}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _userNameController = TextEditingController();
  final LoginCubit _loginCubit = di.getIt<LoginCubit>();
  bool _buttonEnabled = false;
  final GlobalKey<FormState> _formKey = GlobalKey(debugLabel: 'form');

  _validate() {
    setState(() {
      // &&_passwordController.text.isNotEmpty
      if (_userNameController.text.isNotEmpty) {
        _buttonEnabled = true;
      } else {
        _buttonEnabled = false;
      }
    });
  }

  _bind() {
    _userNameController.addListener(() {
      _validate();
      _loginCubit.setUserName(_userNameController.text);
    });
  }

  @override
  void initState() {
    _bind();
    if(_loginCubit.mLoginObject.email.isNotEmpty)
       _userNameController.text = _loginCubit.mLoginObject.email;
    super.initState();
    FireBaseEventAnalytics.setCurrentScreen(FireBaseFromScreen.login.value);
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

  getUserSSODetails(BuildContext context, {bool isSSOLogin = false}) async {
    context.closeKeyboard();
    _loginCubit.updateVisibility(false);
    if (_userNameController.text.isNotEmpty) {
      StorePreference.setIntData(AConstants.keyLoginType,
          isSSOLogin ? AConstants.keySsoLogin : AConstants.keyCloudLogin);
      _loginCubit.ssoLogin = isSSOLogin;
      int loginType = await StorePreference.getIntData(AConstants.keyLoginType, 1);
      Log.d("User session data ==>${loginType}");
    }
    _loginCubit.getUserSSODetails(_userNameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final txtSignIn = HeadlineTextWidget(
      context.toLocale!.lbl_sign_in,
      style: TextStyle(
        color: AColors.textColor,
        fontFamily: AFonts.fontFamily,
        fontWeight: AFontWight.medium,
        decoration: TextDecoration.none,
      ),
    );

    final lblEmail = Align(
      alignment: Alignment.centerLeft,
      child: NormalTextWidget(
        context.toLocale!.lbl_email_address,
        fontWeight: AFontWight.medium,
        fontSize: 15,
      ),
    );

    final containerEmail = _containerTextFields(
      lblEmail,
      ATextFormFieldWidget(
          key: const Key('Email'),
          keyboardType: TextInputType.emailAddress,
          isPassword: false,
          obscureText: false,
          controller: _userNameController,
          hintText: context.toLocale!.login_et_user_email),
    );

    Widget textIncorrectLogin() {
      return BlocBuilder<LoginCubit, FlowState>(
          key: const Key('Error message'),
          buildWhen: (prev,current) => current is UpdateTextVisibility,
          builder: (context, state) {
            if (state is UpdateTextVisibility && state.hiddenEnable) {
              return AnimatedOpacity(duration: const Duration(seconds: 1),
                opacity: state.hiddenEnable ? 1 : 0,
                onEnd: () async {
                   if(!state.hiddenEnable) {
                     _loginCubit.updateVisibility(false);
                   }
                },
                child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                      child: SizedBox(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: NormalTextWidget(
                            _loginCubit.getMessage ?? context.toLocale!.err_message_incorrect_login,
                            maxLines: 2,
                            color: Colors.red,
                            fontWeight: AFontWight.medium,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
              );
                } else {
              return Container();
            }
          });
    }

    final containerLogin =
        BlocBuilder<LoginCubit, FlowState>(builder: (context, state) {
      return (state is LoadingState)
          ? const ACircularProgress()
          : FractionallySizedBox(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AElevatedButtonWidget(
                    key: const Key('LoginButton'),
                      btnLabel: context.toLocale!.lbl_btn_continue,
                    btnLabelClr: _buttonEnabled ? Colors.white : Colors.grey,
                    fontWeight: AFontWight.medium,
                    fontSize: 15,
                    btnBackgroundClr: _buttonEnabled
                        ? AColors.themeBlueColor
                        : AColors.btnDisableClr,
                    onPressed: _buttonEnabled
                        ? () async {
                            if (isNetWorkConnected()) {
                              getUserSSODetails(context);
                            } else {
                              context.showSnack('No network available');
                            }
                          }
                        : null),
              ),
            );
    });

    final txtBtnSSO = GestureDetector(
      onTap: () {
        // this.widget.callback(LoginWidgetState.sso_login);
        getUserSSODetails(context, isSSOLogin: true);
        FireBaseEventAnalytics.setEvent(FireBaseEventType.sso, FireBaseFromScreen.login);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 10),
        child: Align(
          alignment: Alignment.center,
          child: NormalTextWidget(
            context.toLocale!.lbl_useSSO,
            fontWeight: AFontWight.medium,
            color: AColors.themeBlueColor,
            fontSize: 15,
          ),
        ),
      ),
    );

    return BlocListener<LoginCubit, FlowState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          if (state is SuccessState) {
            _manageLoginResult(state.response);
          } else if (state is ErrorState) {
            if (state.stateRendererType == StateRendererType.DEFAULT) {
              context.showSnack(state.message);
            } else {
              _loginCubit.setMessage = state.message;
              _loginCubit.updateVisibility(true);
            }
          }
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
    padding: EdgeInsets.only(
    bottom:60,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              txtSignIn,
              const SizedBox(height: 40) ,
              containerEmail,
              const SizedBox(height: 10),
              textIncorrectLogin(),
              const SizedBox(height: 5),
              containerLogin,
              const SizedBox(height: 15),
              txtBtnSSO,
            ],
          ),
        ),
      ),
    );
  }

  _manageLoginResult(Result result) {
    dynamic data = result.data;

    _loginCubit.updateVisibility(false);

    DataCenters dataCenters = DataCenters(data as List<DatacenterVo>);

    dataCenters.email = _userNameController.text;
    dataCenters.isFromSSO = _loginCubit.isSSOLogin;

    List<DatacenterVo>? availableCloudList;

    if (dataCenters.isFromSSO == true) {
      // Filter data based on available clouds & SSO login
      availableCloudList = dataCenters.clouds
          ?.where((i) => i.isUserAvailable == "true" && i.ssoEnabled == "true")
          .toList();

      dataCenters.clouds = availableCloudList;
    } else {
      // Filters data based on available clouds & Normal login
      availableCloudList =
          dataCenters.clouds?.where((i) => i.isUserAvailable == "true").toList();
      dataCenters.clouds = availableCloudList;
    }

    if (dataCenters.clouds!.isNotEmpty) {
      if (dataCenters.isFromSSO == true) {
        if (dataCenters.clouds!.length == 1 &&
            dataCenters.clouds![0].ssoEnabled == "true") {
          StorePreference.setStringData(AConstants.keyCloudTypeData,
              dataCenters.clouds![0].cloudId.toString());
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => SSOWebView(
                          url: SSOWebView.getWebViewUrl(dataCenters.clouds![0]),
                          emailId: dataCenters.email ?? "",
                        )))
                .then((value) {
              if (value is String) {
                context.showSnack(value);
              } else {
                if (value != null && (value as List).isNotEmpty) {
                  dynamic successResult =
                      SSOWebView.onSSOLoginResponse(value, dataCenters.email!);
                  if (successResult is String) {
                    context.showSnack(successResult); //error message
                  } else if (successResult is Map) {
                    widget.callback(LoginWidgetState.twoFactorLogin,
                        data: successResult);
                  } else {
                    // navigate to dashboard screen
                    Log.d("user in login screen");
                    /*Navigator.pushNamedAndRemoveUntil(
                        context, Routes.dashboard, (route) => false);*/
                    widget.handleNavigation!(value[0]);
                  }
                }
              }
            });
        } else if (dataCenters.clouds!.length > 1) {
          widget.callback(LoginWidgetState.dataCenter, data: dataCenters);
        } else {
          context.showSnack(context.toLocale!.err_message_sso_not_enable);
        }
      } else {
        if (dataCenters.clouds!.length > 1) {
          widget.callback(LoginWidgetState.dataCenter, data: dataCenters);
        } else {
          StorePreference.setStringData(AConstants.keyCloudTypeData,
              dataCenters.clouds![0].cloudId.toString());
          widget.callback(LoginWidgetState.passwordLogin, data: dataCenters);
        }
      }
    } else {
      if (dataCenters.isFromSSO == true) {
        _loginCubit.setMessage = context.toLocale!.err_message_sso_not_enable;
        _loginCubit.updateVisibility(true);
      } else {
        _loginCubit.setMessage = context.toLocale!.err_message_user_doesnt_exist;
        _loginCubit.updateVisibility(true);
      }
    }
  }
}
