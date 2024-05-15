import 'package:field/database/dao.dart';

import '../../../../utils/field_enums.dart';
import '../../../model/sync/site/site_sync_project_vo.dart';

class SiteSyncStatusProjectDao extends Dao<SiteSyncProjectVo> {
  static const tableName = 'SyncProjectTbl';
  static const projectIdField = "ProjectId";
  static const statusStyleSyncStatusField = "StatusStyleSyncStatus";
  static const manageTypeSyncStatusField = "ManageTypeSyncStatus";
  static const formTypeListSyncStatusField = "FormTypeListSyncStatus";
  static const filterSyncStatusField = "FilterSyncStatus";
  static const formListSyncStatusField = "FormListSyncStatus";
  static const syncStatusField = "SyncStatus";
  static const newSyncTimeStampField = "NewSyncTimeStamp";
  static const syncProgressField = "SyncProgress";

  String get fields => "$projectIdField INTEGER NOT NULL,"
      "$statusStyleSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$manageTypeSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$formTypeListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$formListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$filterSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$syncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$newSyncTimeStampField TEXT,"
      "$syncProgressField INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField)";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SiteSyncProjectVo> fromList(List<Map<String, dynamic>> query) {
    return List<SiteSyncProjectVo>.from(query.map((element) => fromMap(element)))
        .toList();
  }

  @override
  SiteSyncProjectVo fromMap(Map<String, dynamic> query) {
    SiteSyncProjectVo syncProjectVo = SiteSyncProjectVo();
    syncProjectVo.projectId = query[projectIdField].toString();
    syncProjectVo.eStatusStyleSyncStatus = ESyncStatus.fromNumber(query[statusStyleSyncStatusField]);
    syncProjectVo.eManageTypeSyncStatus = ESyncStatus.fromNumber(query[manageTypeSyncStatusField]);
    syncProjectVo.eFormTypeListSyncStatus = ESyncStatus.fromNumber(query[formTypeListSyncStatusField]);
    syncProjectVo.eFormListSyncStatus = ESyncStatus.fromNumber(query[formListSyncStatusField]);
    syncProjectVo.eFilterSyncStatus = ESyncStatus.fromNumber(query[filterSyncStatusField]);
    syncProjectVo.eSyncStatus = ESyncStatus.fromNumber(query[syncStatusField]);
    syncProjectVo.newSyncTimeStamp = query[newSyncTimeStampField];
    syncProjectVo.syncProgress = query[syncProgressField];
    return syncProjectVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(
      List<SiteSyncProjectVo> objects) async {
    List<Map<String, dynamic>> syncProjectList = [];
    for (var element in objects) {
      syncProjectList.add(await toMap(element));
    }
    return syncProjectList;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteSyncProjectVo object) {
    return Future.value({
      projectIdField: object.projectId,
      statusStyleSyncStatusField: (object.eStatusStyleSyncStatus?? ESyncStatus.failed).value,
      manageTypeSyncStatusField: (object.eManageTypeSyncStatus?? ESyncStatus.failed).value,
      formTypeListSyncStatusField: (object.eFormTypeListSyncStatus?? ESyncStatus.failed).value,
      formListSyncStatusField: (object.eFormListSyncStatus?? ESyncStatus.failed).value,
      filterSyncStatusField: (object.eFilterSyncStatus?? ESyncStatus.failed).value,
      syncStatusField: (object.eSyncStatus??ESyncStatus.failed).value,
      newSyncTimeStampField: object.newSyncTimeStamp??"",
      syncProgressField:object.syncProgress
    });
  }
}
