import 'package:field/data/dao/location_dao.dart';
import 'package:field/data_source/forms/site_form_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

import '../../data/dao/form_dao.dart';
import '../../data/dao/form_message_dao.dart';
import '../../data/dao/status_style_dao.dart';
import '../../data/dao/sync/site/site_sync_status_location_dao.dart';
import '../../data/model/pinsdata_vo.dart';
import '../../data/model/site_location.dart';
import '../../networking/network_response.dart';

class SiteLocationLocalDatasource extends SiteFormLocalDataSource {
  Future<List<Map<String, dynamic>>> getSyncStatusDataByLocationId(Map<String, dynamic> request) async {
    // "folderId" -> "0"
    String projectId = request['projectId']?.toString().plainValue() ?? "";
    String parentFolderId = request['folderId']?.toString().plainValue() ?? "0";

    String query = "SELECT locTbl.ProjectId,locTbl.LocationId, IFNULL(syncLocTbl.SyncProgress,100) AS SyncProgress,IFNULL(syncLocTbl.SyncStatus,locTbl.SyncStatus) AS SyncStatus,locTbl.CanRemoveOffline,locTbl.IsMarkOffline,locTbl.LastSyncTimeStamp FROM ${LocationDao.tableName} locTbl\n"
        "LEFT JOIN ${SiteSyncStatusLocationDao.tableName} syncLocTbl ON syncLocTbl.ProjectId=locTbl.ProjectId AND syncLocTbl.LocationId=locTbl.LocationId\n"
        "WHERE locTbl.ProjectId=$projectId AND locTbl.${(parentFolderId == "0") ? LocationDao.parentLocationIdField : LocationDao.parentFolderIdField}=$parentFolderId";
    List<Map<String, dynamic>> syncStatusMap = [];
    try {
      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
      syncStatusMap = db.executeSelectFromTable(LocationDao.tableName, query);
    } on Exception {}
    return syncStatusMap;
  }

  Future<SiteLocation?> getLocationTreeByAnnotationId(Map<String, dynamic> request) async {
    String? projectId = request["projectId"];
    String? annotationId = request["annotationId"];

    String query = "WITH CTE_ParentLocationList AS (";
    query = "$query SELECT *,1 AS Level FROM LocationDetailTbl";
    query = "$query WHERE ProjectId=$projectId AND AnnotationId='$annotationId'";
    query = "$query UNION";
    query = "$query SELECT locTbl.*,locCte.Level+1 AS Level FROM LocationDetailTbl locTbl";
    query = "$query INNER JOIN CTE_ParentLocationList locCte ON locCte.ProjectId=locTbl.ProjectId AND locCte.ParentLocationId=locTbl.LocationId)";
    query = "$query SELECT * FROM CTE_ParentLocationList ORDER BY Level ASC";

    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);

    try {
      var qurResult = db.executeSelectFromTable(LocationDao.tableName, query);
      SiteLocation? siteLocation;
      for(var res in qurResult) {
        SiteLocation tmpLoc = LocationDao().fromMap(res);
        if(siteLocation != null) {
          tmpLoc.childTree.add(siteLocation);
        }
        siteLocation = tmpLoc;
      }
      return siteLocation;
    } on Exception catch (e) {
      Log.d("Exception :: $e");
    }
    return null;
  }

  Future<List<ObservationData>?> getObservationListByPlan(Map<String, dynamic> request) async {
    String? projectId = request["projectId"].toString().plainValue();
    String? revisionId = request["revisionId"]?.toString().plainValue();
    String? strObservationIds = request["observationIds"]?.toString().plainValue();

    String query = "SELECT frmTbl.*,locTbl.*,frmTbl.PageNumber AS page_number,frmMsgTbl.ResponseRequestBy AS responseRequestBy,statStyTbl.BackgroundColor AS bgColor,statStyTbl.FontColor AS fontColor FROM ${FormDao.tableName} frmTbl";
    query = "$query INNER JOIN ${LocationDao.tableName} locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId";
    query = "$query INNER JOIN ${FormMessageDao.tableName} frmMsgTbl ON frmMsgTbl.ProjectId = frmTbl.ProjectId AND frmMsgTbl.FormId = frmTbl.FormId AND frmMsgTbl.MsgId = frmTbl.MessageId";
    query = "$query LEFT JOIN ${StatusStyleListDao.tableName} statStyTbl ON statStyTbl.ProjectId=frmTbl.ProjectId AND statStyTbl.StatusId=frmTbl.StatusId";
    query = "$query WHERE locTbl.ProjectId=$projectId";
    if (!revisionId.isNullOrEmpty()) {
      query = "$query AND locTbl.RevisionId=$revisionId";
      String filterJsonData = request["jsonData"] ?? "";
      String filterSqlDataQuery = await siteFormFilterQuery('frmTbl', filterJsonData);
      query = "$query\nAND $filterSqlDataQuery";
    } else {
      query = "$query AND frmMsgTbl.ObservationId IN ($strObservationIds)";
    }
    //fetch offlinecreated forms only to inject data in site listing while auto-sync is running
    if(request.containsKey("onlyOfflineCreatedDataReq") && request["onlyOfflineCreatedDataReq"] == true) {
      query = "$query\nAND frmTbl.IsOfflineCreated=1";
    }
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    List<ObservationData>? observationList = [];
    try {
      var qurResult = db.executeSelectFromTable(FormDao.tableName, query);
      for (Map<String, dynamic> map in qurResult) {
        observationList.add(ObservationData.fromJsonDB(map));
      }
      observationList = observationList.where((element) => !element.coordinates.isNullOrEmpty()).toList();
    } on Exception catch (e) {
      FAIL("failureMessage -----> $e", 602);
    }
    return observationList;
  }
}
