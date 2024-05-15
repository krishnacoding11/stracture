import 'dart:async';

import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/data/model/forgotpassword_vo.dart';
import 'package:field/data/model/language_vo.dart';
import 'package:field/data/remote/generic/generic_repository_impl.dart';
import 'package:field/data/repository/login_repository.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';
import 'package:sprintf/sprintf.dart';

import '../../model/user_vo.dart';

class LogInRemoteRepository extends LogInRepository<Map, Result> {
  LogInRemoteRepository();

 final GenericRemoteRepository _genericRemoteRepository = getIt<GenericRemoteRepository>();

  @override
  Future<Result?> doLogin(Map<String, dynamic> request) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
            baseUrl: AConstants.collabUrl,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.loginUrl,
                data: NetworkRequestBody.json(request)))
        .execute(User.parseXML);

    Log.d("Logged in successfully");
    return result;
  }

  Future<Result> getLanguageList() async {
    String loginTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String endPointUrl = sprintf(AConstants.languageListUrl, [loginTimeStamp]);

    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            headerType: HeaderType.APPLICATION_JSON,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.GET,
                path: endPointUrl,
                data: const NetworkRequestBody.empty()))
        .execute(Language.fromJson);
    Log.d("Language list is successfully received.");
    return result;
  }

  Future<Result?> doSetPasswordRequest(Map<String, dynamic> request) {
    return setPassword(request);
  }

  Future<Result?> doResetPassword(Map<String, dynamic> request) {
    return resetPassword(request);
  }

  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<Result> logIn(request) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
            baseUrl: AConstants.collabUrl,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.loginUrl,
                data: NetworkRequestBody.json(request)))
        .execute(User.parseXML);

    Log.d("Logged in successfully");
    return result;
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  Future<Result?> doLogout() async {
    var result = await NetworkService(
        baseUrl: AConstants.collabUrl,
        headerType: HeaderType.APPLICATION_JSON,
        mNetworkRequest: const NetworkRequest(
            type: NetworkRequestType.GET,
            path: AConstants.logoutUrl,
            data: NetworkRequestBody.empty()))
        .execute((response){
      return response;
    });
    return result;
  }

  Future<Result?> setPassword(request) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.sendPasswordLink,
                headers: {'Content-Type': 'application/json'},
                data: NetworkRequestBody.json(request)))
        .execute(ForgotPasswordVo.fromJson);

    Log.d("set password successfully");
    return result;
  }

  Future<Result?> resetPassword(request) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.resetPasswordUrl,
                headers: {'Content-Type': 'application/json'},
                data: NetworkRequestBody.json(request)))
        .execute(ForgotPasswordVo.fromJson);

    Log.d("reset successfully");
    return result;
  }

  void dispose() => _controller.close();

  @override
  Future<Result?>? getUserSSODetails(Map<String, dynamic> request) async {
    String email = request['emailId'];
    String endPointUrl = sprintf(AConstants.checkSsoUrl, [email]);

    var result = await NetworkService(
            baseUrl: AConstants.oauthUrl,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.GET,
                path: endPointUrl,
                data: const NetworkRequestBody.empty(),))
        .execute(DataCenters.jsonToList);

    return result;
  }

  @override
  Future<Result?>? login2FA(Map<String, dynamic> request) {
    return doLogin(request);
  }

  Future<Result?> getProjectHash(Map<String, dynamic> request) async {
    //Instantiate a service and keep it in your DI container:
    var result = _genericRemoteRepository.getHashValue(request);
    return result;
  }

  Future<Result> getDcWiseUrls() async {
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_JSON,
        mNetworkRequest: const NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.getAllAppDcUrl,
            data: NetworkRequestBody.empty()))
        .execute((response){
          return response;
        });
    return result;
  }
  Future<Result> sendTokenRequest(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.saveUserDeviceDetails,
        headers: {'Content-Type': 'application/json'},
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response){
      return response;
    });
    return result;
  }
}
