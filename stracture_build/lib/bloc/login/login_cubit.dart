import 'dart:async';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/login/login_state.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/domain/use_cases/login/login_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/store_preference.dart';

import '../../injection_container.dart';
import '../dashboard/home_page_cubit.dart';

class LoginSuccessState extends FlowState{
  dynamic? response;

  LoginSuccessState(this.response);

  @override
  List<dynamic> get props => [response];
}

class LoginCubit extends BaseCubit  {
  final LoginUseCase _loginUseCase;

  LoginObject mLoginObject = LoginObject("", "");
  Result? result;

  LoginCubit({LoginUseCase? loginUseCase})
      : _loginUseCase = loginUseCase ?? di.getIt<LoginUseCase>(),
        super(FlowState());

  bool isFromSSO = false;

  bool isForgotPassword = false;

  set ssoLogin(bool isSSOLogin) {
    isFromSSO = isSSOLogin;
  }

  bool get isSSOLogin => isFromSSO;

  set forgotPassword(bool isForgot) {
    isForgotPassword = isForgot;
  }


  String? message;

  String? get getMessage => message;
  set setMessage(String msg) {
    message = msg;
  }

  bool get isForgot => isForgotPassword;

  doLogin(String email, String password) async {
    if (email.isEmpty) {
      emitState(ErrorState(StateRendererType.isValid, "Please enter email",time: DateTime.now().millisecondsSinceEpoch.toString()));
    } else if (!email.contains("@") || !email.contains(".")) {
      emitState(
          ErrorState(StateRendererType.isValid, "Please enter valid email address",time: DateTime.now().millisecondsSinceEpoch.toString()));
    } else if (password.isEmpty) {
      emitState(ErrorState(StateRendererType.isValid, "Please enter password",time: DateTime.now().millisecondsSinceEpoch.toString()));
    } else {
      emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
      try {
        Map<String, dynamic> map = <String, dynamic>{};
        map["emailId"] = email;
        map["password"] = password;
        map["applicationTypeId"] = "3";
        map["isFromField"] = "true";
        final result = await _loginUseCase.doLogin(map);
        if (result is SUCCESS) {
          emitState(SuccessState(result));
          updateSelectedProjectDetail();
          emitState(LoginSuccessState(result));
        } else {
          emitState(ErrorState(StateRendererType.isValid,
              result?.failureMessage ?? "Something went wrong",time: DateTime.now().millisecondsSinceEpoch.toString()));
        }
      } on Exception catch (e) {
        emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
      }
    }
  }

  doLogout() async {
    await _loginUseCase.doLogout();
  }

  do2FALogin(
      String email, String password, String secureKey, String jSessionID) async {
    if (secureKey.isEmpty) {
      emitState(ErrorState(StateRendererType.isValid, "Please enter verification code",time: DateTime.now().millisecondsSinceEpoch.toString()));
    }

    var loginType = await StorePreference.getIntData(AConstants.keyLoginType, 1);

    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    try {
      Map<String, dynamic> map = <String, dynamic>{};
      map["emailId"] = email;
      map["password"] = password;
      map["applicationTypeId"] = "3";
      map["isFromField"] = "true";
      map["loginType"] = loginType;
      map["secureKey"] = secureKey;
      map["JSESSIONID"] = jSessionID;
      map["verificationType"] = "2";

      final result = await _loginUseCase.login2FA(map);
      if (result is SUCCESS) {
        dynamic user = result.data;
        if ((user as User).apiResponseFailure == null &&
            (user).usersessionprofile != null) {
          emitState(SuccessState(result));
          updateSelectedProjectDetail();
        } else {
            if ((user).apiResponseFailure != null){
              emitState(ErrorState(StateRendererType.isValid,user.apiResponseFailure['errorMessage'] ?? "Something went wrong"));
            }
            else{
              emitState(ErrorState(StateRendererType.isValid,"Something went wrong"));
            }
          }
      } else {
        emitState(ErrorState(StateRendererType.isValid,result?.failureMessage ?? "Something went wrong"));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT,e.toString()));
    }
  }

  doSSOLogin(String email,String samlResponse) async {
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    try {
      Map<String, dynamic> map = <String, dynamic>{};
      map["emailId"] = email;
      map["SAMLResponse"] = samlResponse;
      map["applicationTypeId"] = "3";

      final result = await _loginUseCase.doLogin(map);
      if (result is SUCCESS) {
        emitState(SSOSuccessState(result));
        updateSelectedProjectDetail();
      } else {
        emitState(ErrorState(StateRendererType.isValid,result?.failureMessage ?? "Something went wrong.",time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT,e.toString()));
    }
  }

  getUserSSODetails(String email) async {
    final bool emailValid =
    RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
    if (email.isEmpty) {
      emitState(ErrorState(StateRendererType.isValid,"Please enter email",time: DateTime.now().millisecondsSinceEpoch.toString()));
    } else if (!email.contains("@") || !email.contains(".") || !emailValid) {
      emitState(ErrorState(StateRendererType.isValid,"Please enter valid email address",time: DateTime.now().millisecondsSinceEpoch.toString()));
    } else {
      emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
      try {
        // Removed login type and cloud type as fetching data from adoddle otherwise it will last selected cloud's base URL(SB/UAE/KSA/MTA)
        //Code comment for logintype to persist last login type from user listing
        //await PreferenceUtils.remove(AConstants.keyLoginType);
        await StorePreference.removeData(AConstants.keyCloudTypeData);

        Map<String, dynamic> map = <String, dynamic>{};
        map["emailId"] = email;
        final result = await _loginUseCase.getUserSSODetails(map);
        if (result is SUCCESS) {
          emitState(SuccessState(result));
        } else {
          emitState(ErrorState(StateRendererType.isValid,result?.failureMessage ?? "Something went wrong",time: DateTime.now().millisecondsSinceEpoch.toString()));
        }
      } on Exception catch (e) {
        emitState(ErrorState(StateRendererType.DEFAULT,e.toString()));
      }
    }
  }

  Future<Result?> doSetPasswordRequest(String email) async {
    emitState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
    Map<String, dynamic> map = {};
    map["applicationId"] = "3";
    map["companyId"] = "300106";
    map["emailId"] = email;
    result = await _loginUseCase.doSetPasswordReqest(map);
    if(result is SUCCESS){
      emitState(SuccessState(result));
      return result;
    }else {
      emitState(ErrorState(StateRendererType.POPUP_ERROR_STATE, "Something went wrong please try again"));
    }
  }

  Future<Result?> doResetPassword(String password, String confirmPassword, String locale, String userId) async {
    emitState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
    Map<String, dynamic> map = {};
    map["password"] = password;
    map["confirmPassword"] = confirmPassword;
    map["locale"] = locale;
    map["userId"] = userId;
    result = await _loginUseCase.doRestSetPassword(map);
    if(result is SUCCESS){
      emitState(SuccessState(result));
      return result;
    }else {
      emitState(ErrorState(StateRendererType.POPUP_ERROR_STATE, "Something went wrong please try again"));
    }
  }
  //Fetch user from database if exist
  setPassword(String password) {
    mLoginObject.password = password;
  }

  setUserName(String userName) {
    mLoginObject.email = userName;
  }

  Future<List<User>> getExistingUsers() async {
    return await _loginUseCase.getExistingUsers();
  }

  registerDeviceToServer() async {
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    await _loginUseCase.registerDeviceToServer();
    emitState(InitialState(stateRendererType: StateRendererType.DEFAULT));
  }

  clearAllAccountPreference() async {
    await _loginUseCase.clearAllAccountPreference();
  }

  updateSelectedProjectDetail() async {
    Project? project = await StorePreference.getSelectedProjectData();
    if(project != null){
      Popupdata data = Popupdata(id: project.projectID ?? "");
      await di.getIt<ProjectListCubit>().getProjectDetail(data, false);
      //i.getIt<HomePageCubit>().getWeatherDetails();
        getIt<SyncCubit>().autoSyncOfflineToOnline();
    }
  }

  updateResendButtonVisibility() async {
    StorePreference.getResendNowBool("resendEnabled").then((value) {
      emitState(TwoFactorResendButtonEnable(value));
    });
  }

  updateVisibility([bool value = false])  {
      emitState(UpdateTextVisibility(value));
  }

  updateDataCenterVisibility([bool value = false])  {
    emitState(UpdateDataCenterVisibility(value));
  }

  emitContentState(int seconds){
    emitState(TwoFactorTimer(seconds));
  }

}

class LoginObject{
  String email;
  String password;
  LoginObject(this.email,this.password);
}
