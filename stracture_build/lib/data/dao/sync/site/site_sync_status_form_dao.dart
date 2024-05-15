import 'package:field/data/model/sync/site/site_sync_form_vo.dart';
import 'package:field/database/dao.dart';

import '../../../../utils/field_enums.dart';

class SiteSyncStatusFormDao extends Dao<SiteSyncFormVo> {
  static const tableName = 'SyncFormTbl';
  static const projectIdField = "ProjectId";
  static const locationIdField = "LocationId";
  static const formIdField = "FormId";
  static const formTypeIdField = "FormTypeId";
  static const formMsgListSyncStatusField = "FormMsgListSyncStatus";
  static const formXSNHtmlViewSyncStatusField = "FormXSNHtmlViewSyncStatus";
  static const syncStatusField = "SyncStatus";

  String get fields => "$projectIdField INTEGER NOT NULL,"
      "$locationIdField INTEGER NOT NULL,"
      "$formIdField INTEGER NOT NULL,"
      "$formTypeIdField INTEGER NOT NULL,"
      "$formMsgListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$formXSNHtmlViewSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$syncStatusField INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys =>
      ",PRIMARY KEY($projectIdField,$locationIdField,$formIdField)";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SiteSyncFormVo> fromList(List<Map<String, dynamic>> query) {
    return List<SiteSyncFormVo>.from(query.map((element) => fromMap(element)))
        .toList();
  }

  @override
  SiteSyncFormVo fromMap(Map<String, dynamic> query) {
    SiteSyncFormVo syncFormVo = SiteSyncFormVo();
    syncFormVo.projectId = query[projectIdField].toString();
    syncFormVo.locationId = query[locationIdField].toString();
    syncFormVo.formId = query[formIdField].toString();
    syncFormVo.formTypeId = query[formTypeIdField].toString();
    syncFormVo.eFormMsgListSyncStatus = ESyncStatus.fromNumber(query[formMsgListSyncStatusField]);
    syncFormVo.eFormXSNHtmlViewSyncStatus = ESyncStatus.fromNumber(query[formXSNHtmlViewSyncStatusField]);
    syncFormVo.eSyncStatus = ESyncStatus.fromNumber(query[syncStatusField]);
    return syncFormVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<SiteSyncFormVo> objects) async {
    List<Map<String, dynamic>> syncFormList = [];
    for (var element in objects) {
      syncFormList.add(await toMap(element));
    }
    return syncFormList;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteSyncFormVo object) {
    return Future.value({
      projectIdField: object.projectId,
      locationIdField: object.locationId,
      formIdField: object.formId,
      formTypeIdField: object.formTypeId,
      formMsgListSyncStatusField: object.eFormMsgListSyncStatus?.value ?? ESyncStatus.failed,
      formXSNHtmlViewSyncStatusField: object.eFormXSNHtmlViewSyncStatus?.value ?? ESyncStatus.failed,
      syncStatusField: object.eSyncStatus?.value ?? ESyncStatus.failed.value
    });
  }
}
