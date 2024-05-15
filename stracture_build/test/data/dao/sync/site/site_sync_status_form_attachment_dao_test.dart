import 'package:field/data/dao/sync/site/site_sync_status_form_attachment_dao.dart';
import 'package:field/data/model/sync/site/site_sync_form_attachment_vo.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.init(test: true);
  SiteSyncStatusFormAttachmentDao siteSyncStatusFormAttachmentDao = SiteSyncStatusFormAttachmentDao();

  test('Sync Form Attachment createTableQuery test', () {
    String fields = "${SiteSyncStatusFormAttachmentDao.projectIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormAttachmentDao.locationIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormAttachmentDao.formIdField} INTEGER NOT NULL,"
      "${SiteSyncStatusFormAttachmentDao.revisionIdField} INTEGER,"
      "${SiteSyncStatusFormAttachmentDao.syncStatusField} INTEGER NOT NULL DEFAULT 0";

    String primaryKeys = ",PRIMARY KEY(${SiteSyncStatusFormAttachmentDao.projectIdField},${SiteSyncStatusFormAttachmentDao.locationIdField},${SiteSyncStatusFormAttachmentDao.formIdField},${SiteSyncStatusFormAttachmentDao.revisionIdField})";

    String strCreateTableQuery = "CREATE TABLE IF NOT EXISTS ${siteSyncStatusFormAttachmentDao.getTableName}($fields$primaryKeys)";

    expect(strCreateTableQuery, siteSyncStatusFormAttachmentDao.createTableQuery);
  });



  test('Sync Form Attachment fromList() test', () async {
    List<Map<String, dynamic>> query = [
      {'FormId': "1", 'ProjectId': '2', 'RevisionId': "3", 'LocationId': '4', 'SyncStatus' : ESyncStatus.success.value},
      {'FormId': "5", 'ProjectId': '6', 'RevisionId': "7", 'LocationId': '8', 'SyncStatus' : ESyncStatus.success.value},
    ];
    List<SiteSyncFormAttachmentVo> list = SiteSyncStatusFormAttachmentDao().fromList(query);
    expect(list.length, 2);
  });

  test('Sync Form Attachment toListMap() test', () async {
    List<SiteSyncFormAttachmentVo> dataList = [];
    SiteSyncFormAttachmentVo siteSyncFormAttachmentVo = SiteSyncFormAttachmentVo();
    siteSyncFormAttachmentVo.formId = '1';
    siteSyncFormAttachmentVo.projectId = '2';
    siteSyncFormAttachmentVo.revisionId = '3';
    siteSyncFormAttachmentVo.locationId = '4';
    siteSyncFormAttachmentVo.eSyncStatus = ESyncStatus.success;
    dataList.add(siteSyncFormAttachmentVo);

    List<Map<String, dynamic>> list = await SiteSyncStatusFormAttachmentDao().toListMap(dataList);
    expect(list.length, 1);
    expect(list[0]['FormId'], '1');
    expect(list[0]['ProjectId'], '2');
    expect(list[0]['RevisionId'], '3');
    expect(list[0]['LocationId'], '4');
  });

  test('Sync Form Attachment toListMap() Returns Empty List test', () async {
    List<SiteSyncFormAttachmentVo> dataList = [];
    List<Map<String, dynamic>> list = await SiteSyncStatusFormAttachmentDao().toListMap(dataList);
    expect(list.length, 0);
  });

}
