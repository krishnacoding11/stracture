import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/accept_termofuse_vo.dart';
import 'package:field/data/model/get_user_with_subscription_vo.dart';
import 'package:field/data/model/simple_file_upload.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/networking/logger_network_service.dart' as LoggerService;
import 'package:sprintf/sprintf.dart';

import '../../../logger/logger.dart';
import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';
import '../../model/update_user_avatar_vo.dart';
import '../../repository/userprofilesetting/userprofilesetting_repository.dart';

class UserProfileSettingRemoteRepository extends UserProfileSettingRepository {
  UserProfileSettingRemoteRepository();

  @override
  Future<Result> getUserProfileSetting(Map<String, dynamic> request) async {
    String loginTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String endPointUrl =
        sprintf(AConstants.userprofileSettingUrl, [loginTimeStamp]);

    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            headerType: HeaderType.TEXT_JAVASCRIPT,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.GET,
                path: endPointUrl,
                data: const NetworkRequestBody.empty()))
        .execute(UserProfileSettingVo.fromJson);
    Log.d("Userprofilesetting is successfully received.");
    return result;
  }

  @override
  Future<Result> updateLanguage(Map<String, dynamic> request) async {
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.dashboardUrl,
                data: NetworkRequestBody.json(request)))
        .execute(notRequired);
    Log.d("Updating language call successfully sent.");
    return result;
  }

  @override
  Future<Result> updateUserProfileSetting(UserProfileSettingVo userProfileSetting,{String? imagePath}) async {
    FormData formData = FormData();
    bool isImagePresent = false;

    Map<String, dynamic> userProfilemap = {};
    userProfilemap["lastName"] = userProfileSetting.lastName.toString();
    userProfilemap["curPassword"] = userProfileSetting.curPassword.toString();
    userProfilemap["jobTitle"] = userProfileSetting.jobTitle.toString();
    userProfilemap["phoneId"] = userProfileSetting.phoneId;
    userProfilemap["languageId"] = userProfileSetting.languageId;
    userProfilemap["marketingPref"] = false;
    userProfilemap["newPassword"] = userProfileSetting.newPassword.toString();
    userProfilemap["timeZone"] = userProfileSetting.timeZone.toString();
    userProfilemap["screenName"] = userProfileSetting.screenName.toString();
    userProfilemap["phoneNo"] = userProfileSetting.phoneNo.toString();
    userProfilemap["firstName"] = userProfileSetting.firstName.toString();
    userProfilemap["emailAddress"] = userProfileSetting.emailAddress.toString();
    userProfilemap["secondaryEmailAddress"] = userProfileSetting.secondaryEmailAddress.toString();
    userProfilemap["confirmPassword"] = userProfileSetting.confirmPassword.toString();
    userProfilemap["middleName"] = userProfileSetting.middleName.toString();

    Map<String, dynamic> request = {};
    request["action_id"] = 206;
    request["extra"] = jsonEncode(userProfilemap);
    request["applicationId"] = "3";

    if(imagePath!=null){
      request["file"] = await MultipartFile.fromFile(imagePath);
      formData = FormData.fromMap(request);
      isImagePresent = true;
    }

    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
      mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: (isImagePresent)
              ? "${AConstants.dashboardUrl}?action_id=206"
              : AConstants.dashboardUrl,
          data: (isImagePresent)
              ? NetworkRequestBody.formData(formData)
              : NetworkRequestBody.json(request),
          callType: (isImagePresent) ? CallType.MultiPart : CallType.Normal),
    ).execute(isImagePresent ? UpdateUserAvatarVo.fromJson : notRequired);
    Log.d("Updating user setting profile call successfully sent.");
    return result;
  }

  @override
  Future<Result> acceptTermOfUse(Map<String, dynamic> request) async {
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.dashboardUrl,
                data: NetworkRequestBody.json(request)))
        .execute(AcceptTermofuseVo.fromJson);
    Log.d("update privacy policy status ${result.data}");
    return result;
  }

  @override
  Future<Result> getUserWithSubscription(Map<String, dynamic> request) async {
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.getUserWithSubscription,
            data: NetworkRequestBody.json(request)))
        .execute(GetUserWithSubscriptionVo.fromJson);
    Log.d("Get User With Subscription ${result.data}");
    return result;
  }

  dynamic notRequired(dynamic result) {
    return result;
  }

  @override
  Future<List<int>>? downloadUserImage(String? imageUrl, Map<String, dynamic>? header ) async {
    final rs = await Dio().get<List<int>>(
      imageUrl!,
      options: Options(headers: header,responseType: ResponseType.bytes), // Set the response type to `bytes`.
    );
   return rs.data!;
  }

  @override
  Future<Result?> doLogin(Map<String, dynamic> request) async {
    //Instantiate a service and keep it in your DI container:
    var result = await LoggerService.LoggerNetworkService(
        baseUrl: "https://dms.asite.com",
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.loginUrl,
            data: NetworkRequestBody.json(request)))
        .execute(User.parseXML);

    Log.d("Logged in successfully");
    return result;
  }

  @override
  Future<Result?> doLogout() async {
    var result = await LoggerService.LoggerNetworkService(
        baseUrl: AConstants.LIVE_COLLAB_URL,
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

  @override
  Future<Result> uploadSyncFile(Map<String, dynamic> request, [dioInstance]) async {
    FormData formData = FormData();
    formData = FormData.fromMap(request);

    var result = await LoggerService.LoggerNetworkService(
      baseUrl: AConstants.LIVE_ADODDLE_URL,
      headerType: HeaderType.MULTIPART_REQUEST,
      receiveTimeout: null,
      mNetworkRequest: NetworkRequest(
        callType: CallType.MultiPart,
        type: NetworkRequestType.POST,
        path: AConstants.simpleFileUpload,
        data: NetworkRequestBody.formData(formData),
      ),
    ).execute(simpleUploadListFromJson);
    return result;
  }

  List<SimpleFileUpload>? simpleUploadListFromJson(dynamic value) {
    dynamic response = jsonDecode(value);
    var simpleUploadList = List<SimpleFileUpload>.from(response.map((x) => SimpleFileUpload.fromJson(x)));
    return simpleUploadList;
  }
}
