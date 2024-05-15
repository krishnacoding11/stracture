import 'package:field/bloc/deeplink/deeplink_cubit.dart';
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/data/remote/generic/generic_repository_impl.dart';
import 'package:field/domain/use_cases/user_profile_setting/user_profile_setting_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/login_routes/datacenter.dart';
import 'package:field/presentation/screen/login_routes/password.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/qrcode_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import '../../data/model/project_vo.dart';
import '../../data/model/user_vo.dart';
import '../../utils/store_preference.dart';
import '../../widgets/login_background.dart';
import '../../widgets/logo.dart';
import '../managers/routes_manager.dart';
import 'login_routes/bio_metric_login.dart';
import 'login_routes/check_mail.dart';
import 'login_routes/create_password.dart';
import 'login_routes/existing_users.dart';
import 'login_routes/forgot.dart';
import 'login_routes/login.dart';
import 'login_routes/twofactor_login.dart';

enum LoginWidgetState {
  login,
  forgot,
  checkMail,
  existingAccount,
  createPassword,
  resetPasswordSuccess,
  twoFactorLogin,
  bioMetricLogin,
  dataCenter,
  passwordLogin,
}

typedef CallbackFunction = Function(LoginWidgetState nextPage, {dynamic data});
typedef BackPressFunction = Function();
typedef NavigationFunction = Function(User result);

class MyStack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;

  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();
}

class OnBoardingLoginScreen extends StatefulWidget {
  const OnBoardingLoginScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingLoginScreen> createState() => _OnBoardingLoginScreenState();
}

class _OnBoardingLoginScreenState extends State<OnBoardingLoginScreen> {
  final widgetStack = MyStack<LoginWidgetState>();
  final dataStack = MyStack<dynamic>();
  final _loginCubit = di.getIt<LoginCubit>();
  final _deepLinkCubit = di.getIt<DeepLinkCubit>();
  late LoginWidgetState selectedWidget;
  dynamic paramData;
  dynamic userList;
  String? userName;

  setResendEnabled() async {
    await StorePreference.setResendNowBool("resendEnabled", false);
  }

  @override
  void initState() {
    setResendEnabled();
    selectedWidget = LoginWidgetState.login;
    if (widgetStack.isNotEmpty) {
      widgetStack._list.clear();
      dataStack._list.clear();
    }
    widgetStack.push(selectedWidget);
    _getLastLoginUsers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getLastLoginUsers() async {
    userList = await _loginCubit.getExistingUsers();
    bool isCreatePassword = _loginCubit.isForgotPassword;
    if (_deepLinkCubit.uri.isNotEmpty && isCreatePassword) {
      callback(LoginWidgetState.createPassword, data: _deepLinkCubit.uri);
    } else if (userList.length > 0) {
      callback(LoginWidgetState.existingAccount);
    } else {
      callback(LoginWidgetState.login);
    }
  }

  // Used for change widget state for login area
  void callback(LoginWidgetState nextPage, {dynamic data, String? screenName}) {
    setState(() {
      selectedWidget = nextPage;
      widgetStack.push(selectedWidget);
      paramData = data;
      dataStack.push(paramData);
      userName = screenName;
    });
  }

  // Used for handle back press inside login area
  _handleBackPress() {
    if (widgetStack.isNotEmpty) {
      if (selectedWidget == LoginWidgetState.passwordLogin) {
        _loginCubit.emitState(InitialState(stateRendererType: StateRendererType.DEFAULT));
      }
      widgetStack.pop();
      if (dataStack.isNotEmpty) {
        dataStack.pop();
      }
      setState(() {
        selectedWidget = widgetStack.peek;
        if (dataStack.isNotEmpty && dataStack.peek != null) {
          paramData = dataStack.peek;
        }
      });
    }
  }

  _handleNavigation(User user) async {
    await _loginCubit.registerDeviceToServer();
    Project? currSelectedProject = await StorePreference.getSelectedProjectData();
    StorePreference.setUserCurrentDateFormatForLanguage(user.usersessionprofile!.dateFormatforLanguage);
    StorePreference.setUserCurrentLanguage(user.usersessionprofile!.languageId);
    // Validate context available or not.
    if (user.usersessionprofile!.isAgreedToTermsAndCondition != null &&
        user.usersessionprofile!.isAgreedToTermsAndCondition == "true" && context.mounted) {
      di.getIt<UserProfileSettingUseCase>().storeImageOffline();
      await di.getIt<GenericRemoteRepository>().getDeviceConfiguration();
      QRCodeDataVo? qrObj = await QrCodeUtility.extractDataFromLink();
      if (currSelectedProject == null && qrObj?.projectId == null) {
        // Validate context available or not.
        if (context.mounted) {
           Navigator.pushReplacementNamed(context, Routes.dashboard);
           NavigationUtils.mainPushNamed(context, Routes.projectList,
              argument: AConstants.projectSelection);
        }
      } else {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
      }
    } else {
      //navigate to userFirstLogin setup
      Navigator.pushNamed(context, Routes.userFirstLoginSetup, arguments: selectedWidget)
          .then((value) {
        if (value == LoginWidgetState.passwordLogin) {
          _handleBackPress();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widgetStack._list.length <= 1 || selectedWidget == LoginWidgetState.existingAccount) {
          return true;
        } else {
          _handleBackPress();
          return false;
        }
      },
      child: Material(
          color: Colors.transparent,
          child: (Utility.isTablet && MediaQuery.of(context).orientation == Orientation.landscape)
              ? TabletContainer(
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: SingleChildScrollView(
                      reverse: false,
                      scrollDirection: Axis.vertical,
                      child: getLoginWidgetState(context, selectedWidget, callback,
                          _handleBackPress, paramData, userList, userName, _handleNavigation),
                    ),
                  ),
                )
              : PhoneContainer(
                  child: FractionallySizedBox(
                    widthFactor: 0.9,
                    child: SingleChildScrollView(
                      reverse: false,
                      scrollDirection: Axis.vertical,
                      child: getLoginWidgetState(context, selectedWidget, callback,
                          _handleBackPress, paramData, userList, userName, _handleNavigation),
                    ),
                  ),
                )),
    );
  }
}

class TabletContainer extends StatelessWidget {
  final Widget child;

  const TabletContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Row(
            children: [
              const Expanded(
                flex: 1,
                child: LogoWidget(),
              ),
              Expanded(
                flex: 1,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneContainer extends StatelessWidget {
  final Widget child;

  const PhoneContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Utility.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    return LoginBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: FractionallySizedBox(
            // widthFactor: Utility.isTablet ? 0.7 : 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Expanded(flex: 1, child: LogoWidget()),
                Expanded(
                  flex: 3,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Method is used for switching login widget withing same screen.
Widget getLoginWidgetState(
  BuildContext context,
  LoginWidgetState selectedWidget,
  CallbackFunction callback,
  BackPressFunction handleBackPress,
  dynamic data,
  dynamic userList,
  String? userName,
  NavigationFunction handleNavigation,
) {
  switch (selectedWidget) {
    case LoginWidgetState.login:
      return LoginWidget(callback, handleNavigation: handleNavigation);
    case LoginWidgetState.forgot:
      return ForgotPasswordWidget(callback, handleBackPress: handleBackPress);
    case LoginWidgetState.existingAccount:
      return ExistingAccountWidget(
        callback,
        userList,
        handleBackPress: handleBackPress,
        handleNavigation: handleNavigation,
      );
    case LoginWidgetState.createPassword:
      return CreatePasswordWidget(callback, paramData: data, handleBackPress: handleBackPress);
    case LoginWidgetState.checkMail:
      return CheckMailWidget(callback);
    case LoginWidgetState.resetPasswordSuccess:
      return CheckMailWidget(
        callback,
        title: context.toLocale!.lbl_success_password,
        desc: context.toLocale!.lbl_success_password_desc,
        btnText: context.toLocale!.login_btn_sign_in,
      );
    case LoginWidgetState.twoFactorLogin:
      return TwoFactorAuthLoginWidget(
        callback,
        paramData: data,
        handleBackPress: handleBackPress,
        handleNavigation: handleNavigation,
      );
    case LoginWidgetState.dataCenter:
      return DataCenterWidget(
        callback,
        paramData: data,
        screenName: userName,
        handleBackPress: handleBackPress,
        handleNavigation: handleNavigation,
      );
    case LoginWidgetState.bioMetricLogin:
      return BioMetricWidget(
        callback,
        icon: "ic_faceid.png",
        title: context.toLocale!.lbl_face_id,
        desc: context.toLocale!.lbl_face_id_desc,
      );
    case LoginWidgetState.passwordLogin:
      return PasswordWidget(
        callback,
        paramData: data,
        screenName: userName,
        handleBackPress: handleBackPress,
        handleNavigation: handleNavigation,
      );
    default:
      return LoginWidget(callback, handleNavigation: handleNavigation);
  }
}
