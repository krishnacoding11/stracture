import 'package:field/data/model/sync/site/site_sync_location_vo.dart';
import 'package:field/database/dao.dart';

import '../../../../utils/field_enums.dart';


class SiteSyncStatusLocationDao extends Dao<SiteSyncLocationVo> {
  static const tableName = 'SyncLocationTbl';
  static const projectIdField = "ProjectId";
  static const locationIdField = "LocationId";
  static const parentLocationIdField = "ParentLocationId";
  static const docIdField = "DocId";
  static const revisionIdField = "RevisionId";
  static const pdfSyncStatusField = "PdfSyncStatus";
  static const xfdfSyncStatusField = "XfdfSyncStatus";
  static const formListSyncStatusField = "FormListSyncStatus";
  static const newSyncTimeStampField = "NewSyncTimeStamp";
  static const syncStatusField = "SyncStatus";
  static const syncProgressField = "SyncProgress";

  String get fields => "$projectIdField INTEGER NOT NULL,"
      "$locationIdField INTEGER NOT NULL,"
      "$parentLocationIdField INTEGER NOT NULL,"
      "$docIdField INTEGER NOT NULL DEFAULT 0,"
      "$revisionIdField INTEGER NOT NULL DEFAULT 0,"
      "$pdfSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$xfdfSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$formListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$newSyncTimeStampField TEXT,"
      "$syncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$syncProgressField INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$locationIdField)";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SiteSyncLocationVo> fromList(List<Map<String, dynamic>> query) {
    return List<SiteSyncLocationVo>.from(query.map((element) => fromMap(element)))
        .toList();
  }

  @override
  SiteSyncLocationVo fromMap(Map<String, dynamic> query) {
    SiteSyncLocationVo syncLocationVo = SiteSyncLocationVo();
    syncLocationVo.projectId = query[projectIdField].toString();
    syncLocationVo.locationId = query[locationIdField].toString();
    syncLocationVo.parentLocationId = query[parentLocationIdField].toString();
    syncLocationVo.docId = query[docIdField].toString();
    syncLocationVo.revisionId = query[revisionIdField].toString();
    syncLocationVo.ePdfSyncStatus =
        ESyncStatus.fromNumber(query[pdfSyncStatusField]);
    syncLocationVo.eXfdfSyncStatus =
        ESyncStatus.fromNumber(query[xfdfSyncStatusField]);
    syncLocationVo.eFormListSyncStatus =
        ESyncStatus.fromNumber(query[formListSyncStatusField]);
    syncLocationVo.newSyncTimeStamp = query[newSyncTimeStampField];
    syncLocationVo.eSyncStatus = ESyncStatus.fromNumber(query[syncStatusField]);
    syncLocationVo.syncProgress = query[syncProgressField];

    return syncLocationVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(
      List<SiteSyncLocationVo> objects) async {
    List<Map<String, dynamic>> syncLocationList = [];
    for (var element in objects) {
      syncLocationList.add(await toMap(element));
    }
    return syncLocationList;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteSyncLocationVo object) {
    return Future.value({
      projectIdField: object.projectId,
      locationIdField: object.locationId,
      parentLocationIdField: object.parentLocationId,
      docIdField: object.docId,
      revisionIdField: object.revisionId,
      pdfSyncStatusField: (object.ePdfSyncStatus??ESyncStatus.failed).value,
      xfdfSyncStatusField: (object.eXfdfSyncStatus??ESyncStatus.failed).value,
      formListSyncStatusField: (object.eFormListSyncStatus??ESyncStatus.failed).value,
      newSyncTimeStampField: object.newSyncTimeStamp??"",
      syncStatusField: (object.eSyncStatus??ESyncStatus.failed).value,
      syncProgressField:object.syncProgress
    });
  }
}
