import 'dart:convert';

import 'package:field/data/repository/dashboard/homepage_repository.dart';
import 'package:field/utils/extensions.dart';

import '../../../logger/logger.dart';
import '../../../networking/network_response.dart';
import '../../../networking/request_body.dart';
import '../../../utils/app_path_helper.dart';
import '../../../utils/file_utils.dart';
import '../../model/home_page_model.dart';

class HomePageLocalRepository extends HomePageRepository {
  @override
  Future<Result?> getShortcutConfigList(Map<String, dynamic> request) async {
    try {
      String projectId = request["projectId"]?.toString().plainValue() ?? "";
      String filePath = await AppPathHelper().getHomePageShortcutConfigFile(projectId: projectId);
      if (filePath.isNotEmpty) {
        String fileContent = readFromFile(filePath);
        if (fileContent.isNotEmpty) {
          return SUCCESS(HomePageModel.fromJson(jsonDecode(fileContent)), null, 200, requestData: NetworkRequestBody.json(request));
        }
      }
    } catch (e) {
      Log.d("HomePageLocalRepository::getHomePageShortcutConfig Error exception $e");
    }
    return FAIL("", 204);
  }

  @override
  Future<Result?> getPendingShortcutConfigList(Map<String, dynamic> request) {
    // TODO: implement getNotSelectedConfig
    throw UnimplementedError();
  }

  @override
  Future<Result?>? updateShortcutConfigList(Map<String, dynamic> request) {
    // TODO: implement updateHomePageConfig
    throw UnimplementedError();
  }
}
