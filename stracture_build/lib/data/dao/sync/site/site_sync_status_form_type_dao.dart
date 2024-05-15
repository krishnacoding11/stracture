import 'package:field/data/model/sync/site/site_sync_form_type_vo.dart';
import 'package:field/database/dao.dart';

import '../../../../utils/field_enums.dart';

class SiteSyncStatusFormTypeDao extends Dao<SiteSyncFormTypeVo> {
  static const tableName = 'SyncFormTypeTbl';
  static const projectIdField = "ProjectId";
  static const formTypeIdField = "FormTypeId";
  static const templateDownloadSyncStatusField = "TemplateDownloadSyncStatus";
  static const distributionListSyncStatusField = "DistributionListSyncStatus";
  static const statusListSyncStatusField = "StatusListSyncStatus";
  static const customAttributeListSyncStatusField = "CustomAttributeListSyncStatus";
  static const controllerUserListSyncStatusField = "ControllerUserListSyncStatusSyncStatus";
  static const fixFieldListSyncStatusField = "FixFieldListSyncStatus";

  String get fields => "$projectIdField INTEGER NOT NULL,"
      "$formTypeIdField INTEGER NOT NULL,"
      "$templateDownloadSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$distributionListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$statusListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$customAttributeListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$controllerUserListSyncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$fixFieldListSyncStatusField INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$formTypeIdField)";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SiteSyncFormTypeVo> fromList(List<Map<String, dynamic>> query) {
    return List<SiteSyncFormTypeVo>.from(query.map((element) => fromMap(element)))
        .toList();
  }

  @override
  SiteSyncFormTypeVo fromMap(Map<String, dynamic> query) {
    SiteSyncFormTypeVo syncFormTypeVo = SiteSyncFormTypeVo();
    syncFormTypeVo.projectId =  query[projectIdField].toString();
    syncFormTypeVo.formTypeId =  query[formTypeIdField].toString();
    syncFormTypeVo.eTemplateDownloadSyncStatus = ESyncStatus.fromNumber(query[templateDownloadSyncStatusField]);
    syncFormTypeVo.eDistributionListSyncStatus = ESyncStatus.fromNumber(query[distributionListSyncStatusField]);
    syncFormTypeVo.eStatusListSyncStatus = ESyncStatus.fromNumber(query[statusListSyncStatusField]);
    syncFormTypeVo.eCustomAttributeListSyncStatus = ESyncStatus.fromNumber(query[customAttributeListSyncStatusField]);
    syncFormTypeVo.eControllerUserListSyncStatus = ESyncStatus.fromNumber(query[controllerUserListSyncStatusField]);
    syncFormTypeVo.eFixFieldListSyncStatus = ESyncStatus.fromNumber(query[fixFieldListSyncStatusField]);
    return syncFormTypeVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<SiteSyncFormTypeVo> objects) async {
    List<Map<String, dynamic>> syncFormTypeList = [];
    for (var element in objects) {
      syncFormTypeList.add(await toMap(element));
    }
    return syncFormTypeList;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteSyncFormTypeVo object) {
    return Future.value({
      projectIdField: object.projectId,
      formTypeIdField: object.formTypeId,
      templateDownloadSyncStatusField: object.eTemplateDownloadSyncStatus?.value ?? ESyncStatus.failed.value,
      distributionListSyncStatusField: object.eDistributionListSyncStatus?.value ?? ESyncStatus.failed.value,
      statusListSyncStatusField: object.eStatusListSyncStatus?.value ?? ESyncStatus.failed.value,
      customAttributeListSyncStatusField: object.eCustomAttributeListSyncStatus?.value ?? ESyncStatus.failed.value,
      controllerUserListSyncStatusField: object.eControllerUserListSyncStatus?.value ?? ESyncStatus.failed.value,
      fixFieldListSyncStatusField: object.eFixFieldListSyncStatus?.value ?? ESyncStatus.failed.value
    });
  }

}