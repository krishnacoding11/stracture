import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/sync/calculation/site_sync_status_local_data_source.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

import '../../data/model/project_vo.dart';
import '../../data/model/site_location.dart';
import '../../data/model/sync/sync_status_data_vo.dart';

class SiteSyncStatusManager {
  static SiteSyncStatusManager? _instance;

  SiteSyncStatusManager._();

  static Future<SiteSyncStatusManager> getInstance() async {
    if (_instance == null) {
      _instance = SiteSyncStatusManager._();
      await _instance!.init();
    }
    return _instance!;
  }

  final SiteSyncStatusLocalDataSource _siteSyncStatusLocalDataSource = SiteSyncStatusLocalDataSource();

  Future<void> init() async {
    await _siteSyncStatusLocalDataSource.init();
    _siteSyncStatusLocalDataSource.removeTables(_siteSyncStatusLocalDataSource.siteSyncDaoList);
    _siteSyncStatusLocalDataSource.createTables(_siteSyncStatusLocalDataSource.siteSyncDaoList);
  }

  Map syncStatusResultMap(SiteSyncRequestTask siteSyncRequestTask) {
    return _siteSyncStatusLocalDataSource.syncStatusResultMap(siteSyncRequestTask);
  }

  Map syncStatusResultMapDefault(SiteSyncRequestTask siteSyncRequestTask, List<Project> projectList, List<SiteLocation> siteFormList) {
    Map mapSyncData = <String, dynamic>{};
    mapSyncData['syncRequest'] = siteSyncRequestTask;
    List<SiteSyncStatusDataVo> syncStatusLocationList = [];
    for (var location in siteFormList) {
      if (location.isMarkOffline!) {
        SiteSyncStatusDataVo siteSyncStatusDataVo = SiteSyncStatusDataVo();
        siteSyncStatusDataVo.projectId = location.projectId;
        siteSyncStatusDataVo.locationId = location.pfLocationTreeDetail!.locationId.toString();
        siteSyncStatusDataVo.eSyncStatus = ESyncStatus.inProgress;
        siteSyncStatusDataVo.syncProgress = 0;
        syncStatusLocationList.add(siteSyncStatusDataVo);
      }
    }
    mapSyncData["syncLocationData"] = syncStatusLocationList;
    if (siteSyncRequestTask.eSyncType == ESyncType.project) {
      if (projectList.isNotEmpty) {
        SiteSyncStatusDataVo syncStatusProjectVo = SiteSyncStatusDataVo();
        syncStatusProjectVo.projectId = projectList[0].projectID?.plainValue() ?? "";
        syncStatusProjectVo.eSyncStatus = ESyncStatus.inProgress;
        syncStatusProjectVo.syncProgress = 0;
        mapSyncData["syncProjectData"] = syncStatusProjectVo;
      }
    }
    return mapSyncData;
  }

  Future<void> syncCallback(ESyncTaskType eSyncTaskType, ESyncStatus eSyncStatus, SiteSyncRequestTask siteSyncRequestTask, dynamic data) async {
    await _siteSyncStatusLocalDataSource.syncCallback(eSyncTaskType, eSyncStatus, siteSyncRequestTask, data);
  }

  Future<void> removeSyncRequestData(SiteSyncRequestTask siteSyncRequestTask) async {
    await _siteSyncStatusLocalDataSource.removeSyncRequestData(siteSyncRequestTask);
  }
}
