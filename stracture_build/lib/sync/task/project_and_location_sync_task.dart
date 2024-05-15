import 'dart:async';
import 'dart:convert';

import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/local/site/site_local_repository.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/extensions.dart';

import '../../data/model/sync_status.dart';
import '../../injection_container.dart';
import '../../utils/field_enums.dart';

class ProjectAndLocationSyncTask extends BaseSyncTask {
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();
  List<Project> _projectList = [];
  List<SiteLocation> _siteLocationList = [];
  SiteSyncRequestTask siteSyncRequestTask;

  ProjectAndLocationSyncTask(this.siteSyncRequestTask, SyncCallback syncCallback) : super(siteSyncRequestTask, syncCallback);

  Future<SyncStatus> syncProjectAndLocationData(num? taskNumber) async {
    return await _getProjectAndLocationListFromServer(taskNumber);
  }

  Future<SyncStatus> _getProjectAndLocationListFromServer(num? taskNumber) async {
    final completer = Completer<SyncStatus>();
    try {
      AppConfig appConfig = di.getIt<AppConfig>();
      if (appConfig.getSyncManagerProperty(false) == null) {
        await _projectListUseCase.getDeviceConfigurationFromServer();
      }

      String serverTime = "";
      Map<String, dynamic> map1 = {};
      Result resultOfServerTime = (await _projectListUseCase.getServerTime(map1));
      if (resultOfServerTime is SUCCESS) {
        serverTime = resultOfServerTime.data;
      }

      Map<String, dynamic> map = getRequestMapDataForProjectAndLocationList(taskNumber);
      Result result = (await _projectListUseCase.getProjectAndLocationList(map));
      if (result is SUCCESS) {
        if (result.data != null) {
          String response = result.data.toString();
          _projectList = _getProjectListFromJson(response, serverTime);
          _siteLocationList = _getLocationListFromJson(response, serverTime);
          ProjectDao projectDaoObj = ProjectDao();
          await projectDaoObj.insert(_projectList);

          LocationDao loactionDaoObj = LocationDao();
          await loactionDaoObj.insert(_siteLocationList);
          List<SiteLocation> sites = [];
          sites.addAll(_siteLocationList);
          if (siteSyncRequestTask.isReSync && siteSyncRequestTask.eSyncType == ESyncType.siteLocation) {
            for (SyncRequestLocationVo locationVo in siteSyncRequestTask.syncRequestLocationList!) {
              bool isExists = _siteLocationList.any((element) => element.pfLocationTreeDetail?.locationId.toString() == locationVo.locationId);
              //for (SiteLocation location in _siteLocationList) {
              if (!isExists) {
                Result resLocations = await getIt<SiteLocalRepository>().getOfflineMarkedLocationByFolderId({"projectId": siteSyncRequestTask.projectId, "folderId": locationVo.folderId});
                List<SiteLocation> locations = resLocations.data;
                if (locations.isNotEmpty) {
                  SiteLocation loc = locations.first;
                  loc.newSyncTimeStamp = serverTime;
                  //loc.lastSyncTimeStamp = serverTime;
                  loc.canRemoveOffline = true;
                  loc.isMarkOffline = true;
                  loc.syncStatus = ESyncStatus.success;
                  sites.add(loc);
                  //}
                }
              }
            }
          }
          await passDataToSyncCallback(ESyncTaskType.projectAndLocationSyncTask, ESyncStatus.success, {"projectList": _projectList, "siteLocationList": sites});
          completer.complete(SyncSuccessProjectLocationState(_projectList, sites));
        } else {
          ///This is only for 204 status when project data is not coming in offlineFolderList api while Resync.
          if (siteSyncRequestTask.isReSync) {
            List<SiteLocation> sites = [];
            if (siteSyncRequestTask.eSyncType == ESyncType.siteLocation) {
              Result resLocations = await getIt<SiteLocalRepository>().getOfflineMarkedLocationByFolderId({"projectId": siteSyncRequestTask.projectId});
              sites = resLocations.data;
              // resLocations.data.forEach((SiteLocation element) {
              //   if(element.canRemoveOffline == true){
              //     sites.add(element);
              //   }
              // });
            }
            Project project = Project(projectID: map['offlineProjectId']);
            project.newSyncTimeStamp = siteSyncRequestTask.lastSyncTime;
            await passDataToSyncCallback(ESyncTaskType.projectAndLocationSyncTask, ESyncStatus.failed, {
              "projectList": [project],
              "siteLocationList": sites
            });
            completer.complete(SyncStatus.error("ProjectAndLocationSyncCubit", result.failureMessage.toString()));
            // completer.complete(SyncSuccessProjectLocationState([project], []));
          }
        }
      } else {
        completer.complete(SyncStatus.error("ProjectAndLocationSyncCubit", result.failureMessage.toString()));
      }
      Log.d("Project list size ${_projectList.length}");
      Log.d("Site Location list size ${_siteLocationList.length}");
    } catch (e) {
      Log.d("ProjectAndLocationList exception ${e}");
      completer.complete(SyncStatus.error("ProjectAndLocationSyncCubit", e.toString()));
    }
    return completer.future;
  }

  Map<String, dynamic> getRequestMapDataForProjectAndLocationList(num? taskNumber) {
    String? folderIds = siteSyncRequestTask.syncRequestLocationList?.map((e) => e.folderId).toList().join(',');
    folderIds = (folderIds?.isEmpty ?? true) ? "-1" : folderIds;
    String? folderIdAndLastSyncTime;
    if (siteSyncRequestTask.eSyncType == ESyncType.project) {
      if (!siteSyncRequestTask.lastSyncTime.isNullOrEmpty()) {
        folderIdAndLastSyncTime = "0,${siteSyncRequestTask.lastSyncTime}"; // Add 0 with comma if project is syncing
      }
    } else if (siteSyncRequestTask.eSyncType == ESyncType.siteLocation) {
      List<String> tmpSuncRequestLocationList = [];
      for (int i = 0; i < siteSyncRequestTask.syncRequestLocationList!.length; i++) {
        var syncReqLoca = siteSyncRequestTask.syncRequestLocationList![i];
        if (!syncReqLoca.lastSyncTime.isNullOrEmpty()) {
          tmpSuncRequestLocationList.add(syncReqLoca.folderId.plainValue() + "," + syncReqLoca.lastSyncTime);
        }
      }
      if (tmpSuncRequestLocationList.isNotEmpty) {
        folderIdAndLastSyncTime = tmpSuncRequestLocationList.join('#');
      }
      /*folderIdAndLastSyncTime = siteSyncRequestTask.syncRequestLocationList?.map((e) {
        if(!e.lastSyncTime.isNullOrEmpty()){
          e.folderId.plainValue()+","+e.lastSyncTime;
        }
      }).toList().join('#');*/
    }
    Map<String, dynamic> map = {};
    map["offlineProjectId"] = siteSyncRequestTask.projectId;
    map["offlineFolderIds"] = folderIds;
    map["isDeactiveLocationRequired"] = "true";
    if (!folderIdAndLastSyncTime.isNullOrEmpty()) {
      map["lastSyncDate"] = folderIdAndLastSyncTime;
    }
    map["applicationId"] = 3;
    map["folderTypeId"] = 1;
    map["includeSubFolders"] = "true";
    map["networkExecutionType"] = NetworkExecutionType.SYNC;
    map["taskNumber"] = taskNumber;
    return map;
  }

  List<Project> _getProjectListFromJson(dynamic response, String serverTime) {
    List<Project> itemList = [];
    if (response.toString().isNotEmpty) {
      String jsonDataString = response.toString();
      final json = jsonDecode(jsonDataString);
      final workSpaceListObj = json['ResponseData'][0]['workspaceList'];
      if (workSpaceListObj != null) {
        itemList = List<Project>.from(workSpaceListObj.map((x) => Project.fromJson(x)
          ..isMarkOffline = siteSyncRequestTask.eSyncType == ESyncType.project
          ..canRemoveOffline = siteSyncRequestTask.eSyncType == ESyncType.project
          ..lastSyncTimeStamp = (siteSyncRequestTask.eSyncType == ESyncType.project) ? siteSyncRequestTask.lastSyncTime : ""
          ..newSyncTimeStamp = (siteSyncRequestTask.eSyncType == ESyncType.project) ? serverTime : ""
          ..projectSizeInByte = siteSyncRequestTask.projectSizeInByte
          ..syncStatus = ESyncStatus.failed)).toList();
      }
    }
    return itemList;
  }

  List<SiteLocation> _getLocationListFromJson(dynamic response, String serverTime) {
    List<SiteLocation> locationList = [];
    if (response.toString().isNotEmpty) {
      String jsonDataString = response.toString();
      final json = jsonDecode(jsonDataString);
      Map<String, String> folderIdList = {};
      siteSyncRequestTask.syncRequestLocationList?.forEach((e) {
        folderIdList[e.folderId?.plainValue() ?? ""] = e.lastSyncTime ?? "";
      });
      final finalFolderListObj = json['ResponseData'][1];
      if (finalFolderListObj['parentFolderList'] != null) {
        var tmpList = SiteLocation.jsonListToLocationList(finalFolderListObj['parentFolderList']);
        for (var element in tmpList) {
          element.isMarkOffline = folderIdList.isEmpty;
          element.canRemoveOffline = false;
          element.syncStatus = ESyncStatus.failed;
          locationList.add(element);
        }
      }
      if (finalFolderListObj['childFolderList'] != null) {
        var tmpList = SiteLocation.jsonListToLocationList(finalFolderListObj['childFolderList']);
        for (var element in tmpList) {
          element.canRemoveOffline = false;
          if (folderIdList.containsKey(element.folderId?.plainValue() ?? "")) {
            element.lastSyncTimeStamp = folderIdList[element.folderId?.plainValue() ?? ""];
            element.newSyncTimeStamp = serverTime;
            element.canRemoveOffline = true;
          }
          element.isMarkOffline = true;
          element.syncStatus = ESyncStatus.failed;
          locationList.add(element);
        }
      }
    }
    return locationList;
  }
}
