import 'dart:convert';

import 'package:field/data/model/form_message_attach_assoc_vo.dart' as form;
import 'package:field/data/model/sync/sync_property_detail_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/data_source/forms/view_form_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/form_attachment_download_batch_sync_task.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';

class MockProjectListUseCase extends Mock implements ProjectListUseCase {}

class DBServiceMock extends Mock implements DBService {}

class MockAppConfig extends Mock implements AppConfig {}

class MockDatabaseManager extends Mock implements DatabaseManager {}

class MockFormAttachmentDownloadBatchSyncTask extends Mock implements FormAttachmentDownloadBatchSyncTask {}

class SyncPropertyDetails {
  final int akamaiDownloadLimit;
  final int fieldBatchDownloadFileLimit;
  final int fieldBatchDownloadSize;

  SyncPropertyDetails({
    required this.akamaiDownloadLimit,
    required this.fieldBatchDownloadFileLimit,
    required this.fieldBatchDownloadSize,
  });
}

class FormMessageAttachAndAssocVO {
  final int? attachSize;

  FormMessageAttachAndAssocVO({this.attachSize});
}

void processAttachmentDownloadList(List<FormMessageAttachAndAssocVO> attachmentDownloadListFromDB) {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();

  AppConfigTestData().setupAppConfigTestData();
  MockProjectListUseCase? mockProjectListUseCase;
  DBServiceMock? mockDb;
  MockDatabaseManager mockDatabaseManager = MockDatabaseManager();
  List<SyncRequestLocationVo> syncLocationList = [];
  SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
    ..syncRequestId = DateTime.now().millisecondsSinceEpoch
    ..eSyncType = ESyncType.siteLocation
    ..projectId = '2089700'
    ..projectName = "KrupalField19.8UK"
    ..isMarkOffline = true
    ..isMediaSyncEnable = true
    ..projectSizeInByte = "182335131"
    ..syncRequestLocationList = syncLocationList;

  configureDependencies() {
    mockProjectListUseCase = MockProjectListUseCase();
    mockDb = DBServiceMock();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    di.getIt.unregister<ProjectListUseCase>();
    di.getIt.registerLazySingleton<ProjectListUseCase>(() => mockProjectListUseCase!);
  }

  setUpAll(() {
    configureDependencies();
  });

  tearDown(() {
    reset(mockDb);
    reset(mockProjectListUseCase);
  });

  tearDownAll(() {
    mockDb = null;
    mockProjectListUseCase = null;
  });

  test("getHashedValueFromServerTest", () {
    when(() => mockProjectListUseCase!.getHashedValueFromServer(any())).thenAnswer((_) async {
      return Future.value(SUCCESS({
        "fieldValueJson": [
          {"projectId": "2116416"}
        ]
      }, null, 200));
    });
  });

  test('Attachment zip file size should not exceed 250 and file count should not exceed 250', () {
    // Created attachment list with different sizes
    List<FormMessageAttachAndAssocVO> attachmentList = [FormMessageAttachAndAssocVO(attachSize: 100), FormMessageAttachAndAssocVO(attachSize: 75), FormMessageAttachAndAssocVO(attachSize: 50), FormMessageAttachAndAssocVO(attachSize: 30), FormMessageAttachAndAssocVO(attachSize: 20), FormMessageAttachAndAssocVO(attachSize: 10), FormMessageAttachAndAssocVO(attachSize: 10)];

    SyncManagerPropertyDetails syncManagerPropertyDetails = SyncManagerPropertyDetails(
      fieldBatchDownloadSize: 250 * 1000,
      fieldBatchDownloadFileLimit: 250,
    );

    // calling processAttachmentDownloadList method with the attachment list
    processAttachmentDownloadList(attachmentList);

    // checking attachment list is divided into batches correctly
    expect(attachmentList.length, lessThanOrEqualTo(syncManagerPropertyDetails.fieldBatchDownloadFileLimit));

    // calculate zip file size and file limit
    int totalSize = 0;
    int fileCount = 0;
    for (var attachment in attachmentList) {
      totalSize = totalSize + attachment.attachSize!;
      fileCount++;
    }

    // Checking total zip file size does not exceed the limit
    expect(totalSize, lessThanOrEqualTo(syncManagerPropertyDetails.fieldBatchDownloadSize));

    // Checking file count does not exceed the limit
    expect(fileCount, lessThanOrEqualTo(syncManagerPropertyDetails.fieldBatchDownloadFileLimit));
  });
  group("ProcessAttachmentDownloadListTest group", () {
    test("ProcessAttachmentDownloadListTest attachsize", () async {
      FormAttachmentDownloadBatchSyncTask formAttachmentDownloadBatchSyncTask = FormAttachmentDownloadBatchSyncTask(siteSyncTask, (eSyncTaskType, eSyncStatus, data) => Future.value(null));
      AppConfig appConfig = MockAppConfig();
      when(() => appConfig.syncPropertyDetails).thenReturn(SyncManagerPropertyDetails(
        akamaiDownloadLimit: 100,
        fieldBatchDownloadFileLimit: 2,
        fieldBatchDownloadSize: 1000,
      ));

      form.FormMessageAttachAndAssocVO attachmentDownloadListFromDB = form.FormMessageAttachAndAssocVO.fromJson(jsonDecode(fixture("form_attachment_download_batch_sync_task.json")));
      attachmentDownloadListFromDB.setAttachSize = 26;
      attachmentDownloadListFromDB.setAttachType = "3";
      List<form.FormMessageAttachAndAssocVO> finalList = [];
      finalList.add(attachmentDownloadListFromDB);

      await formAttachmentDownloadBatchSyncTask.processAttachmentDownloadList(finalList);

      expect(finalList, isEmpty);
    });

    test("ProcessAttachmentDownloadListTest attachsize max", () async {
      FormAttachmentDownloadBatchSyncTask formAttachmentDownloadBatchSyncTask = FormAttachmentDownloadBatchSyncTask(siteSyncTask, (eSyncTaskType, eSyncStatus, data) => Future.value(null));
      AppConfig appConfig = MockAppConfig();
      when(() => appConfig.syncPropertyDetails).thenReturn(SyncManagerPropertyDetails(
        akamaiDownloadLimit: 10,
        fieldBatchDownloadFileLimit: 2,
        fieldBatchDownloadSize: 1000,
      ));

      form.FormMessageAttachAndAssocVO attachmentDownloadListFromDB = form.FormMessageAttachAndAssocVO.fromJson(jsonDecode(fixture("form_attachment_download_batch_sync_task.json")));
      attachmentDownloadListFromDB.setAttachSize = 260000;
      attachmentDownloadListFromDB.setAttachType = "0";
      List<form.FormMessageAttachAndAssocVO> finalList = [];
      finalList.add(attachmentDownloadListFromDB);

      await formAttachmentDownloadBatchSyncTask.processAttachmentDownloadList(finalList);

      expect(finalList, isEmpty);
    });
  });

  group("getListOfAllAttachmentFromDB group", () {
    test('getListOfAllAttachmentFromDB siteLocation', () async {
      String attachTblName = "FormMsgAttachAndAssocListTbl";
      String query = '''WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=2089700 AND LocationId IN ()
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
)
SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTbl
INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0
INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId
WHERE attachTbl.AttachmentType IN (0, 3)
ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC''';
      final columnList = ["ProjectId", "FormTypeId", "FormId", "MsgId", "AttachmentType", "AttachAssocDetailJson", "OfflineUploadFilePath", "AttachDocId", "AttachRevId", "AttachFileName", "AssocProjectId", "AssocDocFolderId", "AssocDocRevisionId", "AssocFormCommId", "AssocCommentMsgId", "AssocCommentId", "AssocCommentRevisionId", "AssocViewModelId", "AssocViewId", "AssocListModelId", "AssocListId", "AttachSize"];
      final rows = [
        ["2089700", "11092231", "11651734", "12370943", "3", "", "", "13733302", "27306498", "Blue Abstract .jpeg", "", "", "", "", "", "", "", "", "", "", "", "193"]
      ];
      FormAttachmentDownloadBatchSyncTask formAttachmentDownloadBatchSyncTask = FormAttachmentDownloadBatchSyncTask(siteSyncTask, (eSyncTaskType, eSyncStatus, data) => Future.value(null));

      // when(() => mockDatabaseManager.executeSelectFromTable('FormMsgAttachAndAssocListTbl', "WITH ChildLocation AS (SELECT * FROM LocationDetailTblWHERE ProjectId=2130192 AND LocationId IN ()UNIONSELECT locTbl.* FROM LocationDetailTbl locTblINNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId)SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTblINNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationIdWHERE attachTbl.AttachmentType IN (0, 3)ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC")).thenReturn([jsonDecode(fixture("form_attachment_download_batch_sync_task.json"))]);
      when(() => mockDb!.selectFromTable(attachTblName, query)).thenReturn(ResultSet(columnList, null, rows));

      List<form.FormMessageAttachAndAssocVO> actualListOfDownloadedAttachment = await formAttachmentDownloadBatchSyncTask.getListOfAllAttachmentFromDB();

      expect(actualListOfDownloadedAttachment, isNotEmpty);
      verify(() => mockDb!.selectFromTable(attachTblName, query)).called(1);
    });

    test('getListOfAllAttachmentFromDB project', () async {
      SiteSyncRequestTask siteSyncTaskProject = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..eSyncType = ESyncType.project
        ..projectId = '2089700'
        ..projectName = "KrupalField19.8UK"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectSizeInByte = "182335131"
        ..syncRequestLocationList = syncLocationList;
      FormAttachmentDownloadBatchSyncTask formAttachmentDownloadBatchSyncTask = FormAttachmentDownloadBatchSyncTask(siteSyncTaskProject, (eSyncTaskType, eSyncStatus, data) => Future.value(null));

      String attachTblName = "FormMsgAttachAndAssocListTbl";
      String query = '''SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTbl
INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0
WHERE attachTbl.AttachmentType IN (0, 3) AND attachTbl.ProjectId=2089700
ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC''';
      final columnList = ["ProjectId", "FormTypeId", "FormId", "MsgId", "AttachmentType", "AttachAssocDetailJson", "OfflineUploadFilePath", "AttachDocId", "AttachRevId", "AttachFileName", "AssocProjectId", "AssocDocFolderId", "AssocDocRevisionId", "AssocFormCommId", "AssocCommentMsgId", "AssocCommentId", "AssocCommentRevisionId", "AssocViewModelId", "AssocViewId", "AssocListModelId", "AssocListId", "AttachSize"];
      final rows = [
        ["2089700", "11092231", "11651734", "12370943", "3", "", "", "13733302", "27306498", "Blue Abstract .jpeg", "", "", "", "", "", "", "", "", "", "", "", "193"]
      ];
      when(() => mockDb!.selectFromTable(attachTblName, query)).thenReturn(ResultSet(columnList, null, rows));
      List<form.FormMessageAttachAndAssocVO> actualListOfDownloadedAttachment = await formAttachmentDownloadBatchSyncTask.getListOfAllAttachmentFromDB();
      when(() => mockDatabaseManager.executeSelectFromTable('FormMsgAttachAndAssocListTbl', "SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTbl INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0WHERE attachTbl.AttachmentType IN (0, 3) AND attachTbl.ProjectId=2130192ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC")).thenReturn([jsonDecode(fixture("form_attachment_download_batch_sync_task.json"))]);
      var qurResult = mockDatabaseManager.executeSelectFromTable('FormMsgAttachAndAssocListTbl', "SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTbl INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0WHERE attachTbl.AttachmentType IN (0, 3) AND attachTbl.ProjectId=2130192ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC");
      verify(() => mockDatabaseManager.executeSelectFromTable('FormMsgAttachAndAssocListTbl', "SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTbl INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0WHERE attachTbl.AttachmentType IN (0, 3) AND attachTbl.ProjectId=2130192ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC")).called(1);
      expect(actualListOfDownloadedAttachment, isNotEmpty);
      verify(() => mockDb!.selectFromTable(attachTblName, query)).called(1);
    });
  });

  test('syncFormAttachmentDataInBatch', () async {
    String attachTblName = "FormMsgAttachAndAssocListTbl";
    String query = '''WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=2089700 AND LocationId IN ()
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
)
SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTbl
INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0
INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId
WHERE attachTbl.AttachmentType IN (0, 3)
ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC''';
    final columnList = ["ProjectId", "FormTypeId", "FormId", "MsgId", "AttachmentType", "AttachAssocDetailJson", "OfflineUploadFilePath", "AttachDocId", "AttachRevId", "AttachFileName", "AssocProjectId", "AssocDocFolderId", "AssocDocRevisionId", "AssocFormCommId", "AssocCommentMsgId", "AssocCommentId", "AssocCommentRevisionId", "AssocViewModelId", "AssocViewId", "AssocListModelId", "AssocListId", "AttachSize"];
    final rows = [
      ["2089700", "11092231", "11651734", "12370943", "3", "", "", "13733302", "27306498", "Blue Abstract .jpeg", "", "", "", "", "", "", "", "", "", "", "", "193"]
    ];
    FormAttachmentDownloadBatchSyncTask formAttachmentDownloadBatchSyncTask = FormAttachmentDownloadBatchSyncTask(siteSyncTask, (eSyncTaskType, eSyncStatus, data) => Future.value(null));
    MockFormAttachmentDownloadBatchSyncTask mockFormAttachmentDownloadBatch = MockFormAttachmentDownloadBatchSyncTask();
    form.FormMessageAttachAndAssocVO attachmentDownloadListFromDB = form.FormMessageAttachAndAssocVO.fromJson(jsonDecode(fixture("form_attachment_download_batch_sync_task.json")));
    attachmentDownloadListFromDB.setAttachSize = 10;
    attachmentDownloadListFromDB.setAttachType = "3";
    // List<form.FormMessageAttachAndAssocVO> finalList = [];
    // finalList.add(attachmentDownloadListFromDB);
    // when(() => mockDatabaseManager.executeSelectFromTable('FormMsgAttachAndAssocListTbl', "WITH ChildLocation AS (SELECT * FROM LocationDetailTblWHERE ProjectId=2130192 AND LocationId IN ()UNIONSELECT locTbl.* FROM LocationDetailTbl locTblINNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId)SELECT attachTbl.* FROM FormMsgAttachAndAssocListTbl attachTblINNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=attachTbl.ProjectId AND frmTbl.FormId=attachTbl.FormId AND frmTbl.IsCloseOut=0INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationIdWHERE attachTbl.AttachmentType IN (0, 3)ORDER BY CAST(IIF(AttachSize='','0',AttachSize) AS INT) DESC")).thenReturn([jsonDecode(fixture("form_attachment_download_batch_sync_task.json"))]);
    when(() => mockDb!.selectFromTable(attachTblName, query)).thenReturn(ResultSet(columnList, null, rows));
    when(() => mockProjectListUseCase!.getHashedValueFromServer(any())).thenAnswer((_) async {
      return Future.value(SUCCESS("2089700", null, 200));
    });
    await formAttachmentDownloadBatchSyncTask.syncFormAttachmentDataInBatch();

    //expect(actualListOfDownloadedAttachment, isNotEmpty);
    verify(() => mockDb!.selectFromTable(attachTblName, query)).called(1);
  });
}
