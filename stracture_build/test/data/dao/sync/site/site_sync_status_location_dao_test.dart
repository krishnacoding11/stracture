import 'package:field/data/dao/sync/site/site_sync_status_location_dao.dart';
import 'package:field/data/model/sync/site/site_sync_location_vo.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.init(test: true);
  SiteSyncStatusLocationDao siteSyncStatusLocationDao = SiteSyncStatusLocationDao();

  test('Sync Location createTableQuery test', () {
    String fields = "${SiteSyncStatusLocationDao.projectIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusLocationDao.locationIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusLocationDao.parentLocationIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusLocationDao.docIdField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusLocationDao.revisionIdField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusLocationDao.pdfSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusLocationDao.xfdfSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusLocationDao.formListSyncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusLocationDao.newSyncTimeStampField} TEXT,"
      "${SiteSyncStatusLocationDao.syncStatusField} INTEGER NOT NULL DEFAULT 0,"
      "${SiteSyncStatusLocationDao.syncProgressField} INTEGER NOT NULL DEFAULT 0";

    String primaryKeys = ",PRIMARY KEY(${SiteSyncStatusLocationDao.projectIdField},${SiteSyncStatusLocationDao.locationIdField})";
    String strCreateTableQuery = "CREATE TABLE IF NOT EXISTS ${siteSyncStatusLocationDao.getTableName}($fields$primaryKeys)";
    expect(strCreateTableQuery, siteSyncStatusLocationDao.createTableQuery);
  });


  test('Sync Location fromList() test', () async {
    List<Map<String, dynamic>> query = [
      {'ProjectId': "1", 'LocationId': '2', 'ParentLocationId': '3', 'DocId' : '4', 'RevisionId' : '5',  'PdfSyncStatus' : ESyncStatus.success.value, 'XfdfSyncStatus' : ESyncStatus.success.value, 'FormListSyncStatus' : ESyncStatus.success.value, 'SyncStatus' : ESyncStatus.success.value, 'SyncProgress' : 10.0, 'NewSyncTimeStamp' : '1234567'},
      {'ProjectId': "6", 'LocationId': '7', 'ParentLocationId': '8', 'DocId' : '9', 'RevisionId' : '10',  'PdfSyncStatus' : ESyncStatus.success.value, 'XfdfSyncStatus' : ESyncStatus.success.value, 'FormListSyncStatus' : ESyncStatus.success.value, 'SyncStatus' : ESyncStatus.success.value, 'SyncProgress' : 20.0, 'NewSyncTimeStamp' : '1234567'}
    ];

    List<SiteSyncLocationVo> list = SiteSyncStatusLocationDao().fromList(query);
    expect(list.length, 2);
  });

  test('Sync Location fromMap() test', () async {
    Map<String, dynamic> query = {'ProjectId': "1", 'LocationId': '2', 'ParentLocationId': '3', 'DocId' : '4', 'RevisionId' : '5',  'PdfSyncStatus' : ESyncStatus.success.value, 'XfdfSyncStatus' : ESyncStatus.success.value, 'FormListSyncStatus' : ESyncStatus.success.value, 'SyncStatus' : ESyncStatus.success.value, 'SyncProgress' : 10.0, 'NewSyncTimeStamp' : '1234567'};
    SiteSyncLocationVo data = SiteSyncStatusLocationDao().fromMap(query);
    expect(data.projectId, '1');
    expect(data.locationId, '2');
    expect(data.parentLocationId, '3');
    expect(data.docId, '4');
    expect(data.revisionId, '5');
    expect(data.syncProgress, 10.0);
    expect(data.ePdfSyncStatus, ESyncStatus.success);
    expect(data.eXfdfSyncStatus, ESyncStatus.success);
    expect(data.eFormListSyncStatus, ESyncStatus.success);
    expect(data.eSyncStatus, ESyncStatus.success);
  });

  test('Sync Location toListMap() Returns Empty List test', () async {
    List<SiteSyncLocationVo> dataList = [];
    List<Map<String, dynamic>> list = await SiteSyncStatusLocationDao().toListMap(dataList);
    expect(list.length, 0);
  });

  test('Sync Location toListMap() test', () async {
    List<SiteSyncLocationVo> dataList = [];
    SiteSyncLocationVo siteSyncLocationVo = SiteSyncLocationVo();
    siteSyncLocationVo.projectId = '1';
    siteSyncLocationVo.locationId = '2';
    siteSyncLocationVo.parentLocationId = '3';
    siteSyncLocationVo.docId = '4';
    siteSyncLocationVo.revisionId = '5';
    siteSyncLocationVo.syncProgress = 20.0;
    siteSyncLocationVo.ePdfSyncStatus = ESyncStatus.success;
    siteSyncLocationVo.eXfdfSyncStatus = ESyncStatus.success;
    siteSyncLocationVo.eFormListSyncStatus = ESyncStatus.success;
    siteSyncLocationVo.eSyncStatus = ESyncStatus.success;
    dataList.add(siteSyncLocationVo);

    List<Map<String, dynamic>> list = await SiteSyncStatusLocationDao().toListMap(dataList);
    expect(list.length, 1);
    expect(list[0]['ProjectId'], '1');
    expect(list[0]['LocationId'], '2');
    expect(list[0]['ParentLocationId'], '3');
    expect(list[0]['DocId'], '4');
    expect(list[0]['RevisionId'], '5');
    expect(list[0]['SyncProgress'], 20.0);

    expect(list[0]['PdfSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['XfdfSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['FormListSyncStatus'], ESyncStatus.success.value);
    expect(list[0]['SyncStatus'], ESyncStatus.success.value);
  });

}
