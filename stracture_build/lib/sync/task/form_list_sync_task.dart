import 'dart:async';
import 'dart:convert';

import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/model/sync_status.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/sync/task/mark_offline_project_and_location.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/field_enums.dart';

class FormListSyncTask extends BaseSyncTask {
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();
  List<SiteForm> finalformList = [];
  bool _formListIsSuccess = false;
  final completer = Completer<SyncStatus>();

  FormListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<SyncStatus> syncFormListData(List<Project> projectList, List<SiteLocation> siteLocationList, num? taskNumber) async {
    for (var project in projectList) {
      if (syncRequestTask.eSyncType == ESyncType.project) {
        await _getFormListFromServer(project.projectID!, "", "", project.lastSyncTimeStamp ?? "", taskNumber);
      } else {
        for (var siteLocation in siteLocationList) {
          if ((siteLocation.canRemoveOffline ?? false) && (siteLocation.isActive ?? 0) == 1) {
            await _getFormListFromServer(project.projectID!, siteLocation.folderId ?? "", siteLocation.pfLocationTreeDetail?.locationId.toString() ?? "", siteLocation.lastSyncTimeStamp ?? "", taskNumber);
          }
        }
      }
    }
    completer.complete(SyncSuccessFormListState(finalformList));
    return completer.future;
  }

  Future<void> _removeDiscardedForms(String projectId, String folderId, String locationId, num? taskNumber) async {
    MarkOfflineLocationProject frmDataSource = MarkOfflineLocationProject();
    List<String> formIdList = await frmDataSource.getLocationIncludeSubFormIdList(projectId, locationId);
    if (formIdList.isNotEmpty) {
      Map<String, dynamic> map = {
        "projectId":projectId,
        "offlineFormIds":formIdList.join(','),
        "networkExecutionType":NetworkExecutionType.SYNC,
        "taskNumber":taskNumber,
      };
      Result result = await _projectListUseCase.getDiscardedFormIds(map);
      if (result is SUCCESS) {
        try {
          String jsonDataString = result.data.toString();
          final json = jsonDecode(jsonDataString);
          List<String> removeFromIdList = json.toList().cast<String>();
          await frmDataSource.removeFormsFromDatabase(projectId, removeFromIdList);
        } catch (e) {
          Log.d("FormListSyncTask _removeDiscardedForms parse error=$e");
        }
      } else {
        Log.d("FormListSyncTask _removeDiscardedForms HTTP-ERROR=$result");
      }
    }
  }

  Future<void> _getFormListFromServer(String strProjectId, String folderId, String locationId, String lastSyncTime, num? taskNumber) async {
    try {
      await _removeDiscardedForms(strProjectId,folderId,locationId,taskNumber);
      List<SiteForm> formList = [];
      AppConfig appConfig = di.getIt<AppConfig>();
      int lStartFrom = 0, lEndFrom = 0, lBatchSize = (appConfig.syncPropertyDetails?.fieldFormListCount ?? 25), lPageNumber = 0;
      bool bFetchData = false;
      do {
        ++lPageNumber;
        if (bFetchData) {
          lStartFrom = lStartFrom + lBatchSize;
        }
        lEndFrom = lEndFrom + lBatchSize;
        bFetchData = false;
        Result result = await _executeFormListCall(strProjectId, folderId, locationId, lPageNumber, lStartFrom, lBatchSize, taskNumber, lastSyncTime: lastSyncTime);
        if (result is SUCCESS) {
          String jsonDataString = result.data.toString();
          final json = jsonDecode(jsonDataString);
          int lTotalDocs = int.tryParse(json["totalDocs"].toString()) ?? 0;
          List<SiteForm> tmpformList = json['data'] != null ? SiteForm.offlineformListFromSyncJson(json['data']) : [];
          FormDao formDaoObj = FormDao();
          await formDaoObj.insert(tmpformList);
          formList.addAll(tmpformList);
          finalformList.addAll(tmpformList);
          await passDataToSyncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.inProgress, {"projectId": strProjectId, "locationId": locationId, "formList": tmpformList});
          if (lBatchSize == tmpformList.length && lTotalDocs > lBatchSize * lPageNumber) {
            bFetchData = true;
          } else {
            Log.d("FormListSyncTask total form received :${formList.length}");
            _formListIsSuccess = true;
            await passDataToSyncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.success, {"projectId": strProjectId, "locationId": locationId});
          }
        } else {
          await passDataToSyncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.failed, {"projectId": strProjectId, "locationId": locationId});
        }
      } while (bFetchData);
    } catch (e) {
      Log.d("FormListSyncTask exception $e");
      await passDataToSyncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.failed, {"projectId": strProjectId, "locationId": locationId});
    }
  }

  Future<Result> _executeFormListCall(String strProjectId, String folderId, String locationId, int lcurrentPageNo, int lrecordStartFrom, int lrecordBatchSize, num? taskNumber, {String lastSyncTime = ""}) async {
    Map<String, dynamic> map = _getRequestMapDataForFormList(strProjectId, folderId, locationId, lcurrentPageNo, lrecordStartFrom, lrecordBatchSize, taskNumber, lastSyncTime: lastSyncTime);
    Result result = (await _projectListUseCase.getFormList(map));
    return result;
  }

  Map<String, dynamic> _getRequestMapDataForFormList(String strProjectId, String folderId, String locationId, int lcurrentPageNo, int lrecordStartFrom, int lrecordBatchSize, num? taskNumber, {String lastSyncTime = ""}) {
    Map<String, dynamic> map = {};
    map["projectId"] = strProjectId;
    map["currentPageNo"] = lcurrentPageNo;
    map["recordStartFrom"] = lrecordStartFrom;
    map["recordBatchSize"] = lrecordBatchSize;
    map["isWorkspace"] = 0;
    map["appType"] = 2;
    map["action_id"] = 100;
    map["listingType"] = 31;
    map["recordMsg"] = "no-records-available-location";
    map["sortOrder"] = "asc";
    map["sortField"] = "updated";
    map["sortFieldType"] = "timestamp";
    map["isRequiredTemplateData"] = "true";
    map["isFromSyncCall"] = "true";
    map["networkExecutionType"] = NetworkExecutionType.SYNC;
    map["taskNumber"] = taskNumber;
    map["isExcludeClosesOutForms"] = "true";
    map["isExcludeXSNForms"] = "true";

    if (folderId != "") {
      map["folderId"] = folderId;
    }

    if (locationId != "") {
      map["locationId"] = locationId;
    }

    if (lastSyncTime != "") {
      lastSyncTime = lastSyncTime.replaceAll(" ", "T");
      map["lastmodified"] = "${lastSyncTime}Z";
      map["isFromAndroidApp"] = "true";
    }

    return map;
  }
}
