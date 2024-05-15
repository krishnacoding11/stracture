import 'package:field/data/dao/sync/site/site_sync_status_form_type_dao.dart';
import 'package:field/data/model/sync/site/site_sync_form_type_vo.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.init(test: true);
  SiteSyncStatusFormTypeDao siteSyncStatusFormTypeDao = SiteSyncStatusFormTypeDao();

  test('Sync Form Type createTableQuery test', () {
    String fields = "${SiteSyncStatusFormTypeDao.projectIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormTypeDao.formTypeIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormTypeDao.templateDownloadSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusFormTypeDao.distributionListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusFormTypeDao.statusListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusFormTypeDao.customAttributeListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusFormTypeDao.controllerUserListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
    "${SiteSyncStatusFormTypeDao.fixFieldListSyncStatusField} INTEGER NOT NULL DEFAULT 0";

    String primaryKeys = ",PRIMARY KEY(${SiteSyncStatusFormTypeDao.projectIdField},${SiteSyncStatusFormTypeDao.formTypeIdField})";
    String strCreateTableQuery = "CREATE TABLE IF NOT EXISTS ${siteSyncStatusFormTypeDao.getTableName}($fields$primaryKeys)";
    expect(strCreateTableQuery, siteSyncStatusFormTypeDao.createTableQuery);
  });


  test('Sync Form Type fromList() test', () async {
    List<Map<String, dynamic>> query = [
      {'ProjectId': "1", 'FormTypeId': '2', 'TemplateDownloadSyncStatus' : ESyncStatus.success.value, 'DistributionListSyncStatus' : ESyncStatus.success.value, 'StatusListSyncStatus' : ESyncStatus.success.value, 'CustomAttributeListSyncStatus' : ESyncStatus.success.value, 'ControllerUserListSyncStatusSyncStatus' : ESyncStatus.success.value, 'FixFieldListSyncStatus' : ESyncStatus.success.value},
      {'ProjectId': "3", 'FormTypeId': '4', 'TemplateDownloadSyncStatus' : ESyncStatus.failed.value, 'DistributionListSyncStatus' : ESyncStatus.failed.value, 'StatusListSyncStatus' : ESyncStatus.failed.value, 'CustomAttributeListSyncStatus' : ESyncStatus.failed.value, 'ControllerUserListSyncStatusSyncStatus' : ESyncStatus.failed.value, 'FixFieldListSyncStatus' : ESyncStatus.failed.value},
    ];
    List<SiteSyncFormTypeVo> list = SiteSyncStatusFormTypeDao().fromList(query);
    expect(list.length, 2);
  });

  test('Sync Form Type fromMap() test', () async {
    Map<String, dynamic> query = {'ProjectId': "1", 'FormTypeId': '2', 'TemplateDownloadSyncStatus' : ESyncStatus.success.value, 'DistributionListSyncStatus' : ESyncStatus.success.value, 'StatusListSyncStatus' : ESyncStatus.success.value, 'CustomAttributeListSyncStatus' : ESyncStatus.success.value, 'ControllerUserListSyncStatusSyncStatus' : ESyncStatus.success.value, 'FixFieldListSyncStatus' : ESyncStatus.success.value};
    SiteSyncFormTypeVo data = SiteSyncStatusFormTypeDao().fromMap(query);
    expect(data.projectId, '1');
    expect(data.formTypeId, '2');
    expect(data.eControllerUserListSyncStatus, ESyncStatus.success);
    expect(data.eCustomAttributeListSyncStatus, ESyncStatus.success);
    expect(data.eDistributionListSyncStatus, ESyncStatus.success);
    expect(data.eFixFieldListSyncStatus, ESyncStatus.success);
    expect(data.eStatusListSyncStatus, ESyncStatus.success);
    expect(data.eTemplateDownloadSyncStatus, ESyncStatus.success);
  });

  test('Sync Form Type toListMap() Returns Empty List test', () async {
    List<SiteSyncFormTypeVo> dataList = [];
    List<Map<String, dynamic>> list = await SiteSyncStatusFormTypeDao().toListMap(dataList);
    expect(list.length, 0);
  });

  test('Sync Form Type toListMap() test', () async {
    List<SiteSyncFormTypeVo> dataList = [];
    SiteSyncFormTypeVo siteSyncFormTypeVo = SiteSyncFormTypeVo();
    siteSyncFormTypeVo.projectId = '1';
    siteSyncFormTypeVo.formTypeId = '2';
    siteSyncFormTypeVo.eTemplateDownloadSyncStatus = ESyncStatus.success;
    siteSyncFormTypeVo.eStatusListSyncStatus = ESyncStatus.success;
    siteSyncFormTypeVo.eFixFieldListSyncStatus = ESyncStatus.success;
    siteSyncFormTypeVo.eDistributionListSyncStatus = ESyncStatus.success;
    siteSyncFormTypeVo.eCustomAttributeListSyncStatus = ESyncStatus.success;
    siteSyncFormTypeVo.eControllerUserListSyncStatus = ESyncStatus.success;
    dataList.add(siteSyncFormTypeVo);

    List<Map<String, dynamic>> list = await SiteSyncStatusFormTypeDao().toListMap(dataList);
    expect(list.length, 1);
    expect(list[0]['ProjectId'], '1');
    expect(list[0]['FormTypeId'], '2');
    expect(list[0]['TemplateDownloadSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['StatusListSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['FixFieldListSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['DistributionListSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['CustomAttributeListSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['ControllerUserListSyncStatusSyncStatus'], ESyncStatus.success.value);
  });

}
