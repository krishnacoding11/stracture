import 'dart:convert';

import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/repository/site/site_repository.dart';
import 'package:field/data_source/site_location/site_location_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/extensions.dart';

import '../../../data_source/sync_size/sync_size_data_source.dart';
import '../../../logger/logger.dart';
import '../../../networking/network_request.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';
import '../../dao/location_dao.dart';
import '../../model/project_vo.dart';
import '../../model/search_location_list_vo.dart';
import '../../model/sync_size_vo.dart';
import '../../repository/site/location_tree_repository.dart';

class SiteLocalRepository  extends SiteRepository with LocationTreeRepository {
  LocationDao locationDaoObj = LocationDao();
  final SiteLocationLocalDatasource _siteLocationLocalDatasource = getIt<SiteLocationLocalDatasource>();

  @override
  Future<DownloadResponse> downloadPdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
        bool checkFileExist = true}) async {
    return DownloadPdfFile().fetchPdfFile(request,
        onReceiveProgress: onReceiveProgress, checkFileExist: checkFileExist);
  }

  @override
  Future<DownloadResponse> downloadXfdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
        bool checkFileExist = false}) async {
    return DownloadXfdfFile().fetchXFDFFile(request,
        onReceiveProgress: onReceiveProgress, checkFileExist: checkFileExist);
  }

  @override
  Future<Result> getLocationTree(Map<String, dynamic> request) async {
    String? projectId = request["projectId"];
    String? folderId = request["folderId"];

    String query = "SELECT * FROM ${LocationDao.tableName}";
    query = "$query WHERE ${LocationDao.isActiveField}=1";
    if(!projectId.isNullOrEmpty()){
      query = "$query AND ${LocationDao.projectIdField}=${projectId.plainValue()}";
      if(!folderId.isNullOrEmpty()){
        if(folderId == '0'){
          query = "$query AND ${LocationDao.parentLocationIdField}=${folderId.plainValue()}";
        }else {
          query = "$query AND ${LocationDao.parentFolderIdField}=${folderId.plainValue()}";
        }
      }
    }
    query = "$query ORDER BY ${LocationDao.locationTitleField} COLLATE NOCASE ASC";
    final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
    Result result;
    try {
      var qurResult = db.executeSelectFromTable(LocationDao.tableName, query);
      result = SUCCESS(locationDaoObj.fromList(qurResult),null, 200, requestData: NetworkRequestBody.json(request));

    } on Exception catch (e) {
      result = FAIL("failureMessage -----> $e", 602);
    }
    return result;
  }
  Future<Result> getOfflineMarkedLocationByFolderId(Map<String, dynamic> request) async {
    String? projectId = request["projectId"];
    String? folderId = request["folderId"];

    String query = "SELECT * FROM ${LocationDao.tableName}";
    query = "$query WHERE ${LocationDao.isActiveField}=1";
    if(!projectId.isNullOrEmpty()){
      query = "$query AND ${LocationDao.projectIdField}=${projectId.plainValue()}";
      if(!folderId.isNullOrEmpty()){
        if(folderId == '0'){
          query = "$query AND ${LocationDao.folderIdField}=${folderId.plainValue()}";
        }else {
          query = "$query AND ${LocationDao.folderIdField}=${folderId.plainValue()}";
        }
      }
    }
    query = "$query AND ${LocationDao.canRemoveOfflineField}=1";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    Result result;
    try {
      var qurResult = db.executeSelectFromTable(LocationDao.tableName, query);
      result = SUCCESS(locationDaoObj.fromList(qurResult),null, 200, requestData: NetworkRequestBody.json(request));

    } on Exception catch (e) {
      result = FAIL("failureMessage -----> $e", 602);
    }
    return result;
  }

  @override
  Future<SiteLocation?> getLocationTreeByAnnotationId(Map<String, dynamic> request) async {
    return _siteLocationLocalDatasource.getLocationTreeByAnnotationId(request);
  }

  @override
  Future<List<SiteLocation>?> getLocationDetailsByLocationIds(
      Map<String, dynamic> request) async {
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.locationDetailsByLocationIds,
            data: NetworkRequestBody.json(request)))
        .execute(SiteLocation.jsonListToLocationList);
    List<SiteLocation>? locationList = [];
    if (result is SUCCESS) {
      locationList = result.data;
    }
    return locationList;
  }

  @override
  Future<List<ObservationData>?> getObservationListByPlan(Map<String, dynamic> request) async {
    return siteLocationLocalDatasource.getObservationListByPlan(request);
  }

  dynamic getVOFromResponse(dynamic response) {
    try {
      dynamic json = jsonDecode(response);
      var projectList =
      List<Project>.from(json.map((x) => Project.fromJson(x)));
      List<Project> outputList =
      projectList.where((o) => o.iProjectId == 0).toList();
      return outputList;
    } catch (error) {
      return null;
    }
    // return response;
  }


  @override
  Future<Result> getSearchList(Map<String, dynamic> request) async {

    String? projectId = request["selectedProjectIds"].toString();
    String? searchStr = request["searchValue"].toString();
    /*
      SELECT LocationTitle,COUNT(LocationTitle) AS LocationCount FROM LocationDetailTbl
      WHERE IsActive=1 AND ProjectId=2089700 AND LocationTitle LIKE '%21%'
      GROUP BY LocationTitle
      ORDER BY LocationTitle COLLATE NOCASE ASC
    */
    String query = "SELECT * FROM ${LocationDao.tableName}";
    query = "$query WHERE ${LocationDao.isActiveField}=1";
    if (!projectId.isNullOrEmpty()) {
      query =
      "$query AND ${LocationDao.projectIdField}=${projectId.plainValue()}";
      if (!searchStr.isNullOrEmpty()) {
        query =
        "$query AND ${LocationDao.locationTitleField} LIKE '%${searchStr.replaceFirst("_", "%")}%'";
      }
    }
    query =
    "$query ORDER BY ${LocationDao.locationTitleField} COLLATE NOCASE ASC";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    Result result;
    try {
      //{"totalDocs":2,"recordBatchSize":0,"data":[{"id":"90935832$$eShMfG#2089700$$zApjT9","value":"KrupalField19.8UK\\test _ pranav","dataCenterId":0,"isSelected":false,"imgId":1,"isActive":true},{"id":"109706563$$GLanZK#2089700$$zApjT9","value":"KrupalField19.8UK\\Test_Pranav","dataCenterId":0,"isSelected":false,"imgId":1,"isActive":true}],"isSortRequired":true,"isReviewEnableProjectSelected":false,"isAmessageProjectSelected":false,"generateURI":true}
      var qurResult = db.executeSelectFromTable(LocationDao.tableName, query);
      Map<String,dynamic> resMap = {};
      resMap["data"] = qurResult;
      resMap["totalDocs"] = qurResult.length;
      resMap["recordBatchSize"] = 0;
      resMap["isSortRequired"] = true;
      resMap["isReviewEnableProjectSelected"] = true;
      resMap["generateURI"] = true;
      resMap["isAmessageProjectSelected"] = false;

      result = SUCCESS(SearchLocationListVo.fromDBJson(json.encode(resMap)), null, 200,
          requestData: NetworkRequestBody.json(request));
    } on Exception catch (e) {
      result = FAIL("failureMessage -----> $e", 602);
    }
    return result;
  }

  @override
  Future<Result?> getSuggestedSearchList(Map<String, dynamic> request) async {
    String? projectId = request["selectedProjectIds"].toString();
    String? searchStr = request["searchValue"].toString();
    /*
      SELECT LocationTitle,COUNT(LocationTitle) AS LocationCount FROM LocationDetailTbl
      WHERE IsActive=1 AND ProjectId=2089700 AND LocationTitle LIKE '%21%'
      GROUP BY LocationTitle
      ORDER BY LocationTitle COLLATE NOCASE ASC
    */
    String query =
        "SELECT ${LocationDao.locationTitleField}, COUNT(${LocationDao.locationTitleField}) AS LocationCount FROM ${LocationDao.tableName}";
    query = "$query WHERE ${LocationDao.isActiveField}=1";
    if (!projectId.isNullOrEmpty()) {
      query =
          "$query AND ${LocationDao.projectIdField}=${projectId.plainValue()}";
      if (!searchStr.isNullOrEmpty()) {
        query =
            "$query AND ${LocationDao.locationTitleField} LIKE '%$searchStr%'";
      }
    }
    query =
        "$query GROUP BY ${LocationDao.locationTitleField} ORDER BY ${LocationDao.locationTitleField} COLLATE NOCASE ASC";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    Result result;
    try {
      var qurResult = db.executeSelectFromTable(LocationDao.tableName, query);
      Map<String, dynamic> locatonMap = {};
      for (Map subMap in qurResult) {
        locatonMap[subMap[LocationDao.locationTitleField]] =
            subMap["LocationCount"];
      }
      result = SUCCESS(json.encode(locatonMap), null, 200,
          requestData: NetworkRequestBody.json(request));
    } on Exception catch (e) {
      result = FAIL("failureMessage -----> $e", 602);
    }
    return result;
  }

  Future<bool> isProjectLocationMarkedOffline(String? projectId) async {
    String query = "SELECT COUNT(*) FROM ${LocationDao.tableName} WHERE ProjectId = ${projectId.plainValue()} AND ParentLocationId = 0";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(LocationDao.tableName, query);
      if (qurResult.isNotEmpty) {
        return (qurResult[0][0] == 0);
      }
      return false;
    } on Exception catch (e) {
      Log.d(e.toString());
      return false;
    }
  }
  Future<bool> canRemoveOfflineLocation(String? projectId, List<String> locationIds) async {
    String query = "SELECT ${LocationDao.canRemoveOfflineField} FROM ${LocationDao.tableName} WHERE ${LocationDao.projectIdField} = ${projectId.plainValue()} AND ${LocationDao.locationIdField} IN (${locationIds.join(',')}) AND ${LocationDao.canRemoveOfflineField} = 1";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var queryResult = db.executeSelectFromTable(LocationDao.tableName, query);
      return queryResult.isNotEmpty;
    } on Exception catch (e) {
      Log.d(e.toString());
      return false;
    }
  }

  Future<List<SyncSizeVo>> deleteItemFromSyncTable(Map<String,dynamic> request) async {
    SyncSizeDataSource syncSizeDataSource = SyncSizeDataSource();
    await syncSizeDataSource.init();
    return await syncSizeDataSource.deleteProjectSync(request);
  }
}
