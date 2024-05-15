import 'package:field/data/dao/sync/site/site_sync_status_project_dao.dart';
import 'package:field/data/model/sync/site/site_sync_project_vo.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.init(test: true);
  SiteSyncStatusProjectDao siteSyncStatusProjectDao = SiteSyncStatusProjectDao();

  test('Sync Project createTableQuery test', () {
    String fields = "${SiteSyncStatusProjectDao.projectIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusProjectDao.statusStyleSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusProjectDao.manageTypeSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusProjectDao.formTypeListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusProjectDao.formListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusProjectDao.filterSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusProjectDao.syncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusProjectDao.newSyncTimeStampField} TEXT,"
      "${SiteSyncStatusProjectDao.syncProgressField} INTEGER NOT NULL DEFAULT 0";



    String primaryKeys = ",PRIMARY KEY(${SiteSyncStatusProjectDao.projectIdField})";
    String strCreateTableQuery = "CREATE TABLE IF NOT EXISTS ${siteSyncStatusProjectDao.getTableName}($fields$primaryKeys)";
    expect(strCreateTableQuery, siteSyncStatusProjectDao.createTableQuery);
  });


  test('Sync Project fromList() test', () async {
    List<Map<String, dynamic>> query = [
      {'ProjectId': "1", 'StatusStyleSyncStatus' : ESyncStatus.success.value, 'ManageTypeSyncStatus' : ESyncStatus.success.value, 'FormTypeListSyncStatus' : ESyncStatus.success.value, 'FilterSyncStatus' : ESyncStatus.success.value, 'FormListSyncStatus' : ESyncStatus.success.value, 'SyncStatus' : ESyncStatus.success.value, 'SyncProgress' : 10, 'NewSyncTimeStamp' : '1234567'},
      {'ProjectId': "2", 'StatusStyleSyncStatus' : ESyncStatus.success.value, 'ManageTypeSyncStatus' : ESyncStatus.success.value, 'FormTypeListSyncStatus' : ESyncStatus.success.value, 'FilterSyncStatus' : ESyncStatus.success.value, 'FormListSyncStatus' : ESyncStatus.success.value, 'SyncStatus' : ESyncStatus.success.value, 'SyncProgress' : 10, 'NewSyncTimeStamp' : '1234567'}
    ];
    List<SiteSyncProjectVo> list = SiteSyncStatusProjectDao().fromList(query);
    expect(list.length, 2);
  });

  test('Sync Project fromMap() test', () async {
    Map<String, dynamic> query = {'ProjectId': "1", 'StatusStyleSyncStatus' : ESyncStatus.success.value, 'ManageTypeSyncStatus' : ESyncStatus.success.value, 'FormTypeListSyncStatus' : ESyncStatus.success.value, 'FilterSyncStatus' : ESyncStatus.success.value, 'FormListSyncStatus' : ESyncStatus.success.value, 'SyncStatus' : ESyncStatus.success.value, 'SyncProgress' : 10, 'NewSyncTimeStamp' : '1234567'};
    SiteSyncProjectVo data = SiteSyncStatusProjectDao().fromMap(query);
    expect(data.projectId, '1');
    expect(data.syncProgress, 10);
    expect(data.eSyncStatus, ESyncStatus.success);
    expect(data.eFormListSyncStatus, ESyncStatus.success);
    expect(data.eFilterSyncStatus, ESyncStatus.success);
    expect(data.eFormTypeListSyncStatus, ESyncStatus.success);
    expect(data.eFormListSyncStatus, ESyncStatus.success);
    expect(data.eManageTypeSyncStatus, ESyncStatus.success);
    expect(data.eStatusStyleSyncStatus, ESyncStatus.success);
  });

  test('Sync Project toListMap() Returns Empty List test', () async {
    List<SiteSyncProjectVo> dataList = [];
    List<Map<String, dynamic>> list = await SiteSyncStatusProjectDao().toListMap(dataList);
    expect(list.length, 0);
  });

  test('Sync Project toListMap() test', () async {
    List<SiteSyncProjectVo> dataList = [];
    SiteSyncProjectVo siteSyncProjectVo = SiteSyncProjectVo();
    siteSyncProjectVo.projectId = '1';
    siteSyncProjectVo.syncProgress = 20;
    siteSyncProjectVo.eStatusStyleSyncStatus = ESyncStatus.success;
    siteSyncProjectVo.eManageTypeSyncStatus = ESyncStatus.success;
    siteSyncProjectVo.eFilterSyncStatus = ESyncStatus.success;
    siteSyncProjectVo.eFormTypeListSyncStatus = ESyncStatus.success;
    siteSyncProjectVo.eFormListSyncStatus = ESyncStatus.success;
    siteSyncProjectVo.eSyncStatus = ESyncStatus.success;
    dataList.add(siteSyncProjectVo);

    List<Map<String, dynamic>> list = await SiteSyncStatusProjectDao().toListMap(dataList);
    expect(list.length, 1);
    expect(list[0]['ProjectId'], '1');
    expect(list[0]['SyncProgress'], 20);
    expect(list[0]['StatusStyleSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['ManageTypeSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['FormListSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['SyncStatus'], ESyncStatus.success.value);
    expect(list[0]['FilterSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['FormTypeListSyncStatus'], ESyncStatus.success.value);
  });

}
