import 'package:asite_plugins/asite_plugins.dart';
import 'package:field/data/local/login/login_local_repository.dart';
import 'package:field/data/model/language_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/data/remote/login/login_repository_impl.dart';
import 'package:field/data/repository/login_repository.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/db_config.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';

import '../../../data/model/forgotpassword_vo.dart';
import '../../../utils/store_preference.dart';
import '../project_list/project_list_use_case.dart';

class LoginUseCase extends LogInRepository<Map, Result> {
  final LogInRemoteRepository _loginRemoteRepository =
  di.getIt<LogInRemoteRepository>();
  final LogInLocalRepository _loginLocalRepository =
  di.getIt<LogInLocalRepository>();
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();

  @override
  Future<Result?>? doLogin(Map<String, dynamic> request) async {
    final result = await _loginRemoteRepository.doLogin(request);
    if (result is SUCCESS) {
      final user = result.data;
      if (user is User && user.usersessionprofile != null) {
        Log.d("User Value ${result.data}");
        user.usersessionprofile?.currentJSessionID =
            result.responseHeader.getJSessionId()!;

        await StorePreference.setUserData(user);
        await DBConfig().init();
        await Utility.setDataToFirebaseInstance(user.usersessionprofile!);
        _loginLocalRepository.insertLogin(user);

        getLanguageList();
        Result dcResult  = await _loginRemoteRepository.getDcWiseUrls();
        if (dcResult is SUCCESS) {
          await _loginLocalRepository.insertDcWiseUrl(dcResult.data.toString());
        }
        await checkIfProjectSelected();
      }
    }
    return result;
  }

  Future<void> getLanguageList() async {
    final languageListResult =
    await _loginRemoteRepository.getLanguageList();
    if (languageListResult is SUCCESS) {
      final language = languageListResult.data;
      if ((language as Language).locales != null) {
        Log.d("Language Data ${languageListResult.data}");
        await StorePreference.setLanguageData(
            AConstants.keyLanguageData, language);
      }
    }
  }

  @override
  Future<Result?>? getUserSSODetails(Map<String, dynamic> request) async {
    final result = await _loginRemoteRepository.getUserSSODetails(request);
    return result;
  }

  @override
  Future<Result?>? login2FA(Map<String, dynamic> request) async {
    // final result = await _loginRemoteRepository.doLogin(request);
    // if (result is SUCCESS) {
    //   final user = result.data;
    //   Log.d("User Value ${result.data}");

    //   Utility.setUserData(user);
    //   _loginLocalRepository.insertLogin(user!);
    // }
    return doLogin(request);
  }

  Future<List<User>> getExistingUsers() async {
    return await _loginLocalRepository.getExistingUser();
  }

  Future<Result?>? getDcWiseUrls() async {
    return await _loginRemoteRepository.getDcWiseUrls();
  }

  clearAllAccountPreference() async {
    await _loginLocalRepository.clearAllAccountPreference();
  }

  doLogout() async {
    await _loginRemoteRepository.doLogout();
  }

  Future<Result?>? doSetPasswordReqest(Map<String, dynamic> request) async {
    final result = await _loginRemoteRepository.doSetPasswordRequest(request);
    if (result is SUCCESS) {
      ForgotPasswordVo forgotPasswordVo = result.data;
      Log.d("reset call response ${forgotPasswordVo.status}");
    }
    return result;
  }

  Future<Result?>? doRestSetPassword(Map<String, dynamic> request) async {
    final result = await _loginRemoteRepository.doResetPassword(request);
    if (result is SUCCESS) {
      ForgotPasswordVo forgotPasswordVo = result.data;
      Log.d("reset call response ${forgotPasswordVo.status}");
      // final reset = result.data;
      // Log.d("reset call response ${result.data}");
    }
    return result;
  }

  Future<Result?> getProjectHash(Map<String, dynamic> request) async {
    final result = await _loginRemoteRepository.getProjectHash(request);
    return result;
  }

  Future<bool?> checkIfProjectSelected() async {
    var project = await StorePreference.getSelectedProjectData();
    if (project != null) {
      List<String> previousSelectedProjectId = project.projectID!.split("\$");
      Map<String, dynamic> map = <String, dynamic>{};
      map["fieldValueJson"] = [
        {"projectId": "${previousSelectedProjectId[0]}"}
      ].toString();
      final result = await getProjectHash(map);
      try {
        if (result is SUCCESS) {
          List<dynamic> hashValue = result.data as List<dynamic>;
          if (hashValue[0]["projectId"] != null) {
            final updatedProjectId = hashValue[0]["projectId"];
            project.projectID = updatedProjectId;
            await StorePreference.setSelectedProjectData(project);
            //await _projectListUseCase.getProjectList(0, 2, updatedProjectId);
            return true;
          } else {
            Log.d("Project hash value fail");
            return false;
          }
        }else{
          return false;
        }
      } catch (exception) {
        Log.d(exception.toString());
        return false;
      }
    } else {
      Log.d("Hash value API fail");
      return false;
    }
  }

  Future<Result?> registerDeviceToServer() async {
    Log.d("registerDeviceToServer start");
    Map<String, dynamic> requestMap = {};
    requestMap["autoSync"] = "true";
    requestMap["deviceId"] = await AsitePlugins().getUniqueDeviceId() ?? "";
    requestMap["deviceType"] = (Utility.isIos) ? "2" : "1";//Utility.getDeviceType();
    requestMap["applicationType"] = "3";
    requestMap["instantNotification"] = "true";
    bool isPushNotificationEnable = await StorePreference.getPushNotificationEnable();
    requestMap["pushNotificaion"] = isPushNotificationEnable.toString();
    requestMap["token"] = await StorePreference.getDeviceToken();
    requestMap["userId"] = await StorePreference.getUserId();
    Log.d("registerDeviceToServer:$requestMap");
    final result = await _loginRemoteRepository.sendTokenRequest(requestMap);
    Log.d("getDeviceTokenResult:$result");
    return result;
  }
}
