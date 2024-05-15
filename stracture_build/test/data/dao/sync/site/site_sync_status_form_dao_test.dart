import 'package:field/data/dao/sync/site/site_sync_status_form_dao.dart';
import 'package:field/data/model/sync/site/site_sync_form_vo.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.init(test: true);
  SiteSyncStatusFormDao siteSyncStatusFormDao = SiteSyncStatusFormDao();

  test('Sync Form createTableQuery test', () {
    String fields = "${SiteSyncStatusFormDao.projectIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormDao.locationIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormDao.formIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormDao.formTypeIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormDao.formMsgListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusFormDao.formXSNHtmlViewSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusFormDao.syncStatusField} INTEGER NOT NULL DEFAULT 0";

    String primaryKeys = ",PRIMARY KEY(${SiteSyncStatusFormDao.projectIdField},${SiteSyncStatusFormDao.locationIdField},${SiteSyncStatusFormDao.formIdField})";

    String strCreateTableQuery = "CREATE TABLE IF NOT EXISTS ${siteSyncStatusFormDao.getTableName}($fields$primaryKeys)";
    expect(strCreateTableQuery, siteSyncStatusFormDao.createTableQuery);
  });


  test('Sync Form fromList() test', () async {
    List<Map<String, dynamic>> query = [
      {'FormId': "1", 'ProjectId': '2', 'FormTypeId': "3", 'LocationId': '4', 'SyncStatus' : ESyncStatus.success.value, 'FormMsgListSyncStatus' : ESyncStatus.success.value, 'FormXSNHtmlViewSyncStatus' : ESyncStatus.success.value},
      {'FormId': "5", 'ProjectId': '6', 'FormTypeId': "7", 'LocationId': '8', 'SyncStatus' : ESyncStatus.success.value, 'FormMsgListSyncStatus' : ESyncStatus.failed.value, 'FormXSNHtmlViewSyncStatus' : ESyncStatus.failed.value},
    ];
    List<SiteSyncFormVo> list = SiteSyncStatusFormDao().fromList(query);
    expect(list.length, 2);
  });

  test('Sync Form fromMap() test', () async {
    Map<String, dynamic> query = {'FormId': "1", 'ProjectId': '2', 'FormTypeId': "3", 'LocationId': '4', 'SyncStatus' : ESyncStatus.success.value, 'FormMsgListSyncStatus' : ESyncStatus.success.value, 'FormXSNHtmlViewSyncStatus' : ESyncStatus.success.value};
    SiteSyncFormVo data = SiteSyncStatusFormDao().fromMap(query);
    expect(data.formId, '1');
    expect(data.projectId, '2');
    expect(data.formTypeId, '3');
    expect(data.locationId, '4');
    expect(data.eSyncStatus, ESyncStatus.success);
    expect(data.eFormMsgListSyncStatus, ESyncStatus.success);
    expect(data.eFormXSNHtmlViewSyncStatus, ESyncStatus.success);
  });


  test('Sync Form toListMap() Returns Empty List test', () async {
    List<SiteSyncFormVo> dataList = [];
    List<Map<String, dynamic>> list = await SiteSyncStatusFormDao().toListMap(dataList);
    expect(list.length, 0);
  });

  test('Sync Form toListMap() test', () async {
    List<SiteSyncFormVo> dataList = [];
    SiteSyncFormVo siteSyncFormVo = SiteSyncFormVo();
    siteSyncFormVo.formId = '1';
    siteSyncFormVo.projectId = '2';
    siteSyncFormVo.formTypeId = '3';
    siteSyncFormVo.locationId = '4';
    siteSyncFormVo.eSyncStatus = ESyncStatus.success;
    siteSyncFormVo.eFormXSNHtmlViewSyncStatus = ESyncStatus.success;
    siteSyncFormVo.eFormMsgListSyncStatus = ESyncStatus.success;
    dataList.add(siteSyncFormVo);

    List<Map<String, dynamic>> list = await SiteSyncStatusFormDao().toListMap(dataList);
    expect(list.length, 1);
    expect(list[0]['FormId'], '1');
    expect(list[0]['ProjectId'], '2');
    expect(list[0]['FormTypeId'], '3');
    expect(list[0]['LocationId'], '4');
    expect(list[0]['FormMsgListSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['FormXSNHtmlViewSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['SyncStatus'], ESyncStatus.success.value);

  });

}
