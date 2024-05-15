import 'dart:convert';

import 'package:field/data/model/home_page_model.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_utils.dart';
import 'package:sprintf/sprintf.dart';

import '../../../networking/network_request.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/app_path_helper.dart';
import '../../../utils/constants.dart';
import '../../repository/dashboard/homepage_repository.dart';

class HomePageRemoteRepository extends HomePageRepository {
  HomePageRemoteRepository();

  @override
  Future<Result?> getShortcutConfigList(Map<String, dynamic> request,[dioInstance]) async {
    bool isCsrfTokenRequired = !(request["projectId"].toString().isHashValue());
    Result result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
     isCsrfRequired: isCsrfTokenRequired,
      dioClient: dioInstance,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.manageDeviceHomePage,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(HomePageModel.fromJson);
    if (result is SUCCESS) {
      String projectId = request["projectId"]?.toString().plainValue() ?? "";
      HomePageModel homePageModel = result.data;
      writeHomePageShortcutConfigData(projectId, jsonEncode(homePageModel.toJson()));
    }
    return result;
  }

  @override
  Future<Result?>? updateShortcutConfigList(Map<String, dynamic> request,[dioInstance]) async {
    Result result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      dioClient: dioInstance,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.manageDeviceHomePage,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(HomePageModel.fromJson);

    if (result is SUCCESS) {
      String projectId = request["projectId"]?.toString().plainValue() ?? "";
      HomePageModel homePageModel = result.data;
      writeHomePageShortcutConfigData(projectId, jsonEncode(homePageModel.toJson()));
    }
    return result;
  }

  @override
  Future<Result?> getPendingShortcutConfigList(Map<String, dynamic> request, [dioInstance]) async {
    String projectId = request["projectId"].toString();
    String endPointUrl = sprintf(AConstants.homePageDataForConfiguration, [projectId, 2, "true"]);
    Result result = await NetworkService(baseUrl: AConstants.adoddleUrl,dioClient: dioInstance, headerType: HeaderType.APPLICATION_JSON, mNetworkRequest: NetworkRequest(type: NetworkRequestType.GET, path: endPointUrl, data: NetworkRequestBody.empty())).execute(HomePageModel.fromJson);
    return result;
  }

  Future<void> writeHomePageShortcutConfigData(String projectId, String data) async {
    String filePath = await AppPathHelper().getHomePageShortcutConfigFile(projectId: projectId);
    if (filePath.isNotEmpty) {
      writeDataToFile(filePath, data);
    }
  }
}
