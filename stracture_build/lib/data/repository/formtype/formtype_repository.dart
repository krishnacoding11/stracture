

import 'dart:convert';

import 'package:field/data/model/apptype_vo.dart';
import 'package:field/utils/extensions.dart';

abstract class FormTypeRepository<REQUEST,RESPONSE> {

  /// API "/commonapi/pfprojectfieldservice/getLatestProjectDefectFormTypeId"
  Future<RESPONSE?>? getLatestProjectDefectFormTypeIdList(Map<String, dynamic> request);

  /// API "/dmsa/DownloadServlet"
  Future<RESPONSE?>? getFormTypeHTMLTemplateZipDownload(Map<String, dynamic> request);

  /// API "/adoddle/apps"
  Future<RESPONSE?>? getFormTypeXSNTemplateZipDownload(Map<String, dynamic> request);

  /// API "/adoddle/apps"
  Future<RESPONSE?>? getFormTypeStatusList(Map<String, dynamic> request);

  /// API "/adoddlenavigatorapi/form/getDistributionList"
  Future<RESPONSE?>? getFormTypeDistributionList(Map<String, dynamic> request);

  /// API "/adoddle/apps"
  Future<RESPONSE?>? getFormTypeFixFieldData(Map<String, dynamic> request);

  /// API "/adoddle/apps"
  Future<RESPONSE?>? getFormTypeCustomAttributeList(Map<String, dynamic> request);

  Future<RESPONSE?>? getFormTypeAttributeSetDetail(Map<String, dynamic> request);

  /// API "/commonapi/form/getFormTypeControllerUsers"
  Future<RESPONSE?>? getFormTypeControllerUserList(Map<String, dynamic> request);

  Future<void> getAppTypeList(String projectId, isFromMap,String appTypeId);

  List<AppType>? appTypeListFromJson(dynamic response) {
    var jsonMap = jsonDecode(response);
    var appTypes = jsonMap["data"];
    var projectList =  List<AppType>.from(appTypes.map((x) => AppType.fromJson(x)));

    return projectList;
  }

  Map<String, dynamic> getRequestMapDataAppTypeList(String projectID) {
    Map<String, dynamic> map = {};
    map["projectId"] = projectID;
    map["projectIds"] = projectID.plainValue();
    map["project_id"] = projectID;
    map["checkHashing"] = "false";
    map["recordBatchSize"] = "500";
    map["isFromWhere"] = "103";
    map["isFromMapView"] = "true";
    map["appType"] = "2";

    return map;
  }

}