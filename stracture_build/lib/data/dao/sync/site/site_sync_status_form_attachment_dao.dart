import 'package:field/data/model/sync/site/site_sync_form_attachment_vo.dart';
import 'package:field/database/dao.dart';

import '../../../../utils/field_enums.dart';

class SiteSyncStatusFormAttachmentDao extends Dao<SiteSyncFormAttachmentVo> {
  static const tableName = 'SyncFormAttachmentTbl';
  static const projectIdField = "ProjectId";
  static const locationIdField = "LocationId";
  static const formIdField = "FormId";
  static const revisionIdField = "RevisionId";
  static const syncStatusField = "SyncStatus";

  String get fields => "$projectIdField INTEGER NOT NULL,"
      "$locationIdField INTEGER NOT NULL,"
      "$formIdField INTEGER NOT NULL,"
      "$revisionIdField INTEGER,"
      "$syncStatusField INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys =>
      ",PRIMARY KEY($projectIdField,$locationIdField,$formIdField,$revisionIdField)";

  @override
  String get getTableName => tableName;

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  List<SiteSyncFormAttachmentVo> fromList(List<Map<String, dynamic>> query) {
    return List<SiteSyncFormAttachmentVo>.from(
        query.map((element) => fromMap(element))).toList();
  }

  @override
  SiteSyncFormAttachmentVo fromMap(Map<String, dynamic> query) {
    SiteSyncFormAttachmentVo syncFormAttachmentVo = SiteSyncFormAttachmentVo();
    syncFormAttachmentVo.projectId = query[projectIdField].toString();
    syncFormAttachmentVo.locationId = query[locationIdField].toString();
    syncFormAttachmentVo.formId = query[formIdField].toString();
    syncFormAttachmentVo.revisionId = query[revisionIdField].toString();
    syncFormAttachmentVo.eSyncStatus =
        ESyncStatus.fromNumber(query[syncStatusField]);
    return syncFormAttachmentVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(
      List<SiteSyncFormAttachmentVo> objects) async {
    List<Map<String, dynamic>> syncFormAttachmentList = [];
    for (var element in objects) {
      syncFormAttachmentList.add(await toMap(element));
    }
    return syncFormAttachmentList;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteSyncFormAttachmentVo object) {
    return Future.value({
      projectIdField: object.projectId,
      locationIdField: object.locationId,
      formIdField: object.formId,
      revisionIdField: object.revisionId,
      syncStatusField: object.eSyncStatus?.value ?? ESyncStatus.failed.value
    });
  }
}
