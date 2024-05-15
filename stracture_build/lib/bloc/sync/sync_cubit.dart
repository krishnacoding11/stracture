import 'dart:convert';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/sync/sync_state.dart';
import 'package:field/data_source/forms/form_local_data_source.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/sync/sync_manager.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/global.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../data/local/project_list/project_list_local_repository.dart';
import '../../data/local/site/site_local_repository.dart';
import '../../data/model/project_vo.dart';
import '../../data/model/site_location.dart';
import '../../data/model/sync/sync_request_task.dart';
import '../../data/model/sync/sync_status_data_vo.dart';
import '../../injection_container.dart';
import '../../logger/logger.dart';
import '../../sync/task/offline_project_mark.dart';
import '../../utils/store_preference.dart';

class SyncCubit extends BaseCubit {
  SyncCubit() : super(SyncInitial()) {
    formLocalDataSource = FormLocalDataSource();
  }

  Map<int,Map<String, dynamic>> syncRequestList = {};
  bool _isSyncPending = false;

  bool get isSyncPending => _isSyncPending;
  late FormLocalDataSource formLocalDataSource;
  FormLocalDataSource get formLocalDataSourceInst => formLocalDataSource;


  set isSyncPending(bool value) {
    _isSyncPending = value;
  }

  void syncProjectData(Map<String, dynamic> argsMap, {BuildContext? context}) async {
    isOnlineButtonSyncClicked = false;
    _isSyncPending = true;
    if (argsMap.containsKey('syncRequest')) {
      var request = jsonDecode(argsMap['syncRequest']);
      syncRequestList[request['syncRequestId']] = argsMap;
      emitState(SyncStartState());
      Utility.showBannerNotification(context??NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_syncing, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_syncing_msg, Icons.sync, AColors.greenColor);
      emitState(SyncProgressState(0,request['projectId'].toString().plainValue(),ESyncStatus.inProgress,time: DateTime.now().millisecondsSinceEpoch.toString()));
      di.getIt<SyncManager>().execute(argsMap, (eSyncType, eSyncStatus, data) {
        Log.d("SyncCubit >> callback: $data");
        var syncResult = jsonDecode(data);
        Log.d("syncResult:$data");
        var isSyncFail = false;
        if (syncResult is Map) {
          List<SiteSyncStatusDataVo> locationSitesSyncDataVo=[];
          if (syncResult['syncProjectData'] != null) {
            SiteSyncStatusDataVo? siteSyncStatusDataVo = SiteSyncStatusDataVo.fromJson(syncResult['syncProjectData']);
            int progress = (siteSyncStatusDataVo.syncProgress ?? 0.0).toInt();
            emitState(SyncProgressState(progress, siteSyncStatusDataVo.projectId ?? "", siteSyncStatusDataVo.eSyncStatus, time: DateTime.now().millisecondsSinceEpoch.toString()));
            isSyncFail = siteSyncStatusDataVo.eSyncStatus == ESyncStatus.failed ? true : false;
          }
          if (syncResult['syncLocationData'] != null && (syncResult['syncLocationData'] as List).isNotEmpty) {
            for (int i = 0; i < (syncResult['syncLocationData'] as List).length; i++) {
              Map<String, dynamic> jsonLocationData = syncResult['syncLocationData'][i];
              locationSitesSyncDataVo.add(SiteSyncStatusDataVo.fromJson(jsonLocationData));
              if (!isSyncFail) {
                isSyncFail = jsonLocationData["SyncStatus"] == ESyncStatus.failed.value ? true : false;
              }
            }
            emitState(SyncLocationProgressState(locationSitesSyncDataVo));
          }
          Log.d("SyncCubit >> $eSyncStatus");
          if (eSyncStatus == ESyncStatus.success) {
            syncRequestList.remove(syncResult['syncRequest']['syncRequestId']);
          }
          if (syncRequestList.isEmpty) {
            stopSyncing();
            deleteAttachmentZipFile();
            emitState(SyncCompleteState());
            isSyncFail ? Utility.showBannerNotification(context??NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_fail, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_fail_msg, Icons.sync_problem, Colors.red) : Utility.showBannerNotification(context??NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_successfull, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_successfull_msg, Icons.offline_pin, AColors.greenColor);
          }
        }
      });
    }
  }

  void stopSyncing() {
     _isSyncPending = false;
    di.getIt<SyncManager>().stopIsolate();
    _isSyncDataPending();
  }


  Future<void> deleteAttachmentZipFile() async {
    final offlineProjectMark = OfflineProjectMark();
    await offlineProjectMark.deleteAttachmentZipFiles();
  }

  Future<void> _isSyncDataPending() async {
    isSyncPending = await isSyncDataPending();
  }

  Future<void> autoSyncOnlineToOffline () async {
      Project? projectObj = await StorePreference.getSelectedProjectData();
      List<Project> prj = await getIt<ProjectListLocalRepository>().getProjectList(0, 50, {"projectIds": projectObj?.projectID.plainValue()});
      bool includeAttachments = await StorePreference.isIncludeAttachmentsSyncEnabled();

      if (prj.isNotEmpty) {
        if (prj.first.canRemoveOffline == true) {
          int? reSyncDownloadSize = await getUpdatedDownloadedProjectSize(projectObj!.projectID);
          if (reSyncDownloadSize != null) {
            SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
              ..syncRequestId = DateTime
                  .now()
                  .millisecondsSinceEpoch
              ..projectId = projectObj.projectID?.plainValue()
              ..projectName = projectObj.projectName?.plainValue()
              ..isMarkOffline = true
              ..isMediaSyncEnable = includeAttachments
              ..lastSyncTime = prj.length > 0 ? prj.first.lastSyncTimeStamp : ""
              ..eSyncType = ESyncType.project
             ..projectSizeInByte = reSyncDownloadSize.toString()
              ..isReSync = true;

            syncProjectData({"buildFlavor": AConstants.buildFlavor!, "tab": AConstants.siteTab, "syncRequest": jsonEncode(syncRequestTask)});
         }
        } else {
          ///Location sync request
          List<SyncRequestLocationVo> syncLocationList = [];
          Result result = await getIt<SiteLocalRepository>().getLocationTree({"projectId": projectObj?.projectID.plainValue()});
          // _locationTreeCubit.clearAllData();
          List<String> locationList = [];
          for (SiteLocation element in result.data) {
            if(element.canRemoveOffline??false){
              locationList.add(element.pfLocationTreeDetail!.locationId!.toString());
            }
          }
          int? reSyncDownloadSize = await getUpdatedDownloadedLocationSize(projectObj!.projectID!, locationList);
          if (reSyncDownloadSize != null) {
            for (SiteLocation element in result.data) {
              // Map<String, dynamic>? syncStatusData = await getIt<SiteLocationLocalDatasource>().getSyncStatusDataByLocationId(element);
              // if (syncStatusData!.isNotEmpty) {
              //   element.lastSyncTimeStamp = syncStatusData?["LastSyncTimeStamp"].toString();
              //   element.syncStatus = ESyncStatus.fromNumber(syncStatusData?['SyncStatus'] ?? 0);
              //   element.canRemoveOffline = syncStatusData?['CanRemoveOffline'] == 1 ? true : false;
              //   element.isMarkOffline = syncStatusData?['IsMarkOffline'] == 1 ? true : false;
              // }

              if (element.isMarkOffline ?? false) {
                SyncRequestLocationVo syncRequestLocationVo = SyncRequestLocationVo()
                  ..folderId = element.folderId?.plainValue()
                  ..folderTitle = element.folderTitle?.plainValue()
                  ..locationId = element.pfLocationTreeDetail?.locationId.toString()
                  ..lastSyncTime = element.lastSyncTimeStamp
                  ..isPlanOnly = true;
                syncLocationList.add(syncRequestLocationVo);
              }
            }

            SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
              ..syncRequestId = DateTime
                  .now()
                  .millisecondsSinceEpoch
              ..projectId = projectObj.projectID?.plainValue()
              ..projectName = projectObj.projectName?.plainValue()
              ..isMarkOffline = true
              ..isMediaSyncEnable = includeAttachments
              ..syncRequestLocationList = syncLocationList
              ..eSyncType = ESyncType.siteLocation
              ..projectSizeInByte = reSyncDownloadSize.toString()
              ..isReSync = true;

            syncProjectData({"buildFlavor": AConstants.buildFlavor!, "tab": AConstants.siteTab, "syncRequest": jsonEncode(syncRequestTask)});
          }
        }
      }
  }

  Future<void> autoSyncOfflineToOnline () async {
    // createNotification("Auto Sync","In progress");
    // FormLocalDataSource frmDb = FormLocalDataSource();
    // await frmDb.init();
    await formLocalDataSourceInst.init();
    var isPushToServer = await formLocalDataSourceInst.isPushToServerData();
    if(isPushToServer) {
      emitState(SyncStartState());
      Utility.showBannerNotification(NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_syncing, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_syncing_msg, Icons.sync, AColors.greenColor);
      final argsMap = {"buildFlavor": AConstants.buildFlavor!, "tab": AConstants.autoSyncTab};
      await di.getIt<SyncManager>().execute(argsMap, (eSyncType, eSyncStatus, data) async {
        if (eSyncType == ESyncType.pushToServer) {
          if (eSyncStatus == ESyncStatus.success) {
            // createNotification("Auto Sync", "Finished");
            stopSyncing();
            var isAnyPendingDataToSync = await formLocalDataSourceInst.isPushToServerData();
            if(isAnyPendingDataToSync) {
              Utility.showBannerNotification(NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_fail, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_fail_msg, Icons.sync_problem, Colors.red);
            } else {
              Utility.showBannerNotification(NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_successfull, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_successfull_msg, Icons.offline_pin, AColors.greenColor);
            }
            emitState(SyncCompleteState(isNeedToRefreshData: true));
            //COMMENT FOR DEMO PURPOSE ONLY FOR TODAY(9-06-23)
            // autoSyncOnlineToOffline();
          }else{
            stopSyncing();
            emitState(SyncCompleteState(isNeedToRefreshData: true));
            Utility.showBannerNotification(NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_fail, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_system_sync_fail_msg, Icons.sync_problem, Colors.red);
          }
        }
      });
    }
  }

  Future<void> showSyncLatestDataOption()async {
    emitState(SyncStartState());
    emitState(SyncCompleteState());
  }

  Future<int?> getUpdatedDownloadedProjectSize(String? projectID) async {
    // downloadSizeCubit = getIt<DownloadSizeCubit>();
    int? projectDownSizeVo = await downloadSizeCubit!.getProjectOfflineSyncDataSize(projectID!, ["-1"]);
    if(projectDownSizeVo != null){
      return projectDownSizeVo;
    }
    return null;
  }

  Future<int?> getUpdatedDownloadedLocationSize(String projectId,List<String> locationList) async {
    int? isLocationDownloadSizeAvailable = await downloadSizeCubit!.getProjectOfflineSyncDataSize(projectId, locationList);
    if(isLocationDownloadSizeAvailable != null){
      return isLocationDownloadSizeAvailable;
    }
    return null;

  }
  Future<bool> isSyncDataPending() async {
    FormLocalDataSource frmDb = FormLocalDataSource();
    await frmDb.init();
    var isPushToServer = await frmDb.isPushToServerData();
    return isPushToServer;
  }
}
