import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/dao/sync/sync_size_dao.dart';
import 'package:field/data/dao/user_reference_attachment_dao.dart';
import 'package:field/data/dao/user_reference_formtype_template_dao.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/sync/task/mark_offline_project_and_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setAsitePluginsMethodChannel();
  di.init(test: true);

  DBServiceMock mockDb = DBServiceMock();

  late MarkOfflineLocationProject markOfflineLocationProject;

  final String projectID = "2130192";
  final String locationID = "177287";
  final String userCloudID = "1";
  final String revisionID = "123456";

  configureDependencies() {
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});

    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);
  }

  setUp(() async {
    configureDependencies();
    markOfflineLocationProject = MarkOfflineLocationProject();
  });

  String testDeleteLocationAttachment() {
    String selectQuery = """WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=$projectID AND LocationId=$locationID 
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
),
LocationFormList AS (
SELECT frmTbl.ProjectId,frmTbl.LocationId,frmTbl.FormId FROM FormListTbl frmTbl
INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId
)
SELECT frmAtchTbl.* FROM FormMsgAttachAndAssocListTbl frmAtchTbl
INNER JOIN LocationFormList frmCte ON frmCte.ProjectId=frmAtchTbl.ProjectId AND frmCte.FormId=frmAtchTbl.FormId AND ${FormMessageAttachAndAssocDao.attachRevIdField} IS NOT NULL AND ${FormMessageAttachAndAssocDao.attachRevIdField} != ''""";

    ResultSet resultSet = ResultSet(
        ["AttachRevId", "AttachFileName"],
        null,
        [
          [revisionID, "my_profile.jpg"]
        ]);

    when(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).thenReturn(resultSet);
    return selectQuery;
  }

  group("test deleteLocationAttachment", () {
    test("test deleteLocationAttachment pass AttachRevId and AttachFileName with valid select query expected true", () async {
      String selectQuery = testDeleteLocationAttachment();
      String fetchQuery = "SELECT * FROM ${UserReferenceAttachmentDao.tableName} WHERE ProjectId=$projectID AND RevisionId=$revisionID AND UserCloudId=$userCloudID";

      ResultSet fetchQueryResultSet = ResultSet(List.empty(), null, List.empty());

      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, fetchQuery)).thenReturn(fetchQueryResultSet);

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(true, result);

      verify(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
      verify(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, fetchQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteLocationAttachment pass exception expected false", () async {
      when(() => mockDb.selectFromTable(LocationDao.tableName, any())).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);
    });
  });

  String testDeleteLocationFormTypeAttachment() {
    String selectQuery = """WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=$projectID AND LocationId=$locationID 
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
)
SELECT DISTINCT frmTbl.FormTypeId FROM FormListTbl frmTbl
INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId""";

    ResultSet resultSet = ResultSet(
        ["FormTypeId"],
        null,
        [
          ["123456"]
        ]);

    when(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).thenReturn(resultSet);

    return selectQuery;
  }

  group("test deleteLocationFormTypeAttachment", () {
    test("test deleteLocationFormTypeAttachment pass FormTypeId with valid select query expected false", () async {
      testDeleteLocationAttachment();
      String selectQuery = testDeleteLocationFormTypeAttachment();

      String fetchQuery = "SELECT * FROM ${UserReferenceFormTypeTemplateDao.tableName} WHERE ${UserReferenceFormTypeTemplateDao.projectIdField}=$projectID AND ${UserReferenceFormTypeTemplateDao.formTypeIdField}=123456 AND ${UserReferenceFormTypeTemplateDao.userCloudIdField}=$userCloudID";

      ResultSet fetchQueryResultSet = ResultSet(List.empty(), null, List.empty());
      when(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, fetchQuery)).thenReturn(fetchQueryResultSet);

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);

      verify(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
      verify(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, fetchQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteLocationFormTypeAttachment pass exception expected false", () async {
      testDeleteLocationAttachment();
      String selectQuery = testDeleteLocationFormTypeAttachment();

      when(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);
    });
  });

  String testDeleteLocationAttachmentFromTbl() {
    String deleteQuery = """WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=$projectID AND LocationId=$locationID 
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
),
LocationFormList AS (
SELECT frmTbl.ProjectId,frmTbl.LocationId,frmTbl.FormId FROM FormListTbl frmTbl
INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId
)
DELETE  FROM FormMsgAttachAndAssocListTbl WHERE ProjectId= (SELECT ProjectId FROM LocationFormList) AND FormId= (SELECT FormId FROM LocationFormList)""";

    ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

    when(() => mockDb.executeQuery(deleteQuery)).thenReturn(resultSet);
    return deleteQuery;
  }

  group("test deleteLocationAttachmentFromTbl", () {
    test("test deleteLocationAttachmentFromTbl pass valid delete query expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      String deleteQuery = testDeleteLocationAttachmentFromTbl();

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);

      verify(() => mockDb.executeQuery(deleteQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteLocationAttachmentFromTbl pass exception expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      String deleteQuery = testDeleteLocationAttachmentFromTbl();

      when(() => mockDb.executeQuery(deleteQuery)).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);
    });
  });

  String testDeleteLocationFormMsgActionList() {
    String deleteQuery = """WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=$projectID AND LocationId=$locationID 
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
),
LocationFormList AS (
SELECT frmTbl.ProjectId,frmTbl.LocationId,frmTbl.FormId FROM FormListTbl frmTbl
INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId
)
DELETE FROM FormMsgActionListTbl WHERE ProjectId=$projectID AND FormId IN (SELECT FormId FROM LocationFormList)""";

    ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

    when(() => mockDb.executeQuery(deleteQuery)).thenReturn(resultSet);
    return deleteQuery;
  }

  group("test deleteLocationFormMsgActionList", () {
    test("test deleteLocationFormMsgActionList pass valid delete query expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      String deleteQuery = testDeleteLocationFormMsgActionList();

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);

      verify(() => mockDb.executeQuery(deleteQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteLocationFormMsgActionList pass exception expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      String deleteQuery = testDeleteLocationFormMsgActionList();

      when(() => mockDb.executeQuery(deleteQuery)).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);
    });
  });

  String testDeleteLocationFormList() {
    String deleteQuery = """WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=$projectID AND LocationId=$locationID 
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
),
LocationFormList AS (
SELECT frmTbl.ProjectId,frmTbl.LocationId,frmTbl.FormId FROM FormListTbl frmTbl
INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId
)
DELETE FROM FormListTbl WHERE ProjectId=$projectID AND LocationId IN (SELECT LocationId FROM LocationFormList)""";

    ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

    when(() => mockDb.executeQuery(deleteQuery)).thenReturn(resultSet);
    return deleteQuery;
  }

  group("test deleteLocationFormList", () {
    test("test deleteLocationFormList pass valid delete query expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      testDeleteLocationFormMsgActionList();
      String deleteQuery = testDeleteLocationFormList();

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);

      verify(() => mockDb.executeQuery(deleteQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteLocationFormList pass exception expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      testDeleteLocationFormMsgActionList();
      String deleteQuery = testDeleteLocationFormList();

      when(() => mockDb.executeQuery(deleteQuery)).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);
    });
  });

  String testDeleteLocationPlanFile() {
    String selectQuery = """WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=$projectID AND LocationId=$locationID 
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
)
SELECT * FROM ChildLocation
WHERE RevisionId<>0
GROUP BY RevisionId
""";

    ResultSet resultSet = ResultSet(
        ["RevisionId"],
        null,
        [
          [revisionID]
        ]);

    when(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).thenReturn(resultSet);
    return selectQuery;
  }

  group("test deleteLocationPlanFile", () {
    test("test deleteLocationPlanFile pass valid delete query expected true", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      testDeleteLocationFormMsgActionList();
      testDeleteLocationFormList();
      String selectQuery = testDeleteLocationPlanFile();

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(true, result);

      verify(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteLocationPlanFile pass exception expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      testDeleteLocationFormMsgActionList();
      testDeleteLocationFormList();
      String selectQuery = testDeleteLocationPlanFile();

      when(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);
    });
  });

  List<String> testDeleteLocationTableData() {
    String deleteSubQuery = """WITH ChildLocation AS (
SELECT * FROM LocationDetailTbl
WHERE ProjectId=$projectID AND LocationId=$locationID 
UNION
SELECT locTbl.* FROM LocationDetailTbl locTbl
INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId
)
DELETE FROM LocationDetailTbl WHERE ProjectId=$projectID AND LocationId IN (SELECT LocationId FROM ChildLocation)""";

    ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

    when(() => mockDb.executeQuery(deleteSubQuery)).thenReturn(resultSet);

    String deleteQuery = "DELETE FROM LocationDetailTbl WHERE ProjectId=$projectID AND LocationId=$locationID";
    when(() => mockDb.executeQuery(deleteQuery)).thenReturn(resultSet);

    return [deleteSubQuery, deleteQuery];
  }

  group("test deleteLocationTableData", () {
    test("test deleteLocationTableData pass valid delete query expected true", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      testDeleteLocationFormMsgActionList();
      testDeleteLocationFormList();
      testDeleteLocationPlanFile();
      List<String> queries = testDeleteLocationTableData();

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(true, result);

      verify(() => mockDb.executeQuery(queries.first)).called(greaterThanOrEqualTo(1));
      verify(() => mockDb.executeQuery(queries[1])).called(greaterThanOrEqualTo(1));
    });

    test("test deleteLocationTableData pass exception expected false", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      testDeleteLocationFormMsgActionList();
      testDeleteLocationFormList();
      testDeleteLocationPlanFile();
      List<String> queries = testDeleteLocationTableData();

      when(() => mockDb.executeQuery(queries[1])).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(false, result);
    });
  });

  String testRemoveProjectData() {
    String selectQuery = """SELECT COUNT(LocationId) FROM LocationDetailTbl\nWHERE ProjectId=$projectID AND CanRemoveOffline=1""";

    ResultSet resultSet = ResultSet(
        ["AttachRevId", "AttachFileName"],
        null,
        [
          [revisionID, "my_profile.jpg"]
        ]);

    when(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).thenReturn(resultSet);

    return selectQuery;
  }

  group("test removeProjectData", () {
    test("test removeProjectData pass valid select query expected true", () async {
      testDeleteLocationAttachment();
      testDeleteLocationFormTypeAttachment();
      testDeleteLocationAttachmentFromTbl();
      testDeleteLocationFormMsgActionList();
      testDeleteLocationFormList();
      testDeleteLocationPlanFile();
      testDeleteLocationTableData();
      testDeleteLocationTableData();
      String selectQuery = testRemoveProjectData();

      bool result = await markOfflineLocationProject.deleteProjectLocationDetails(projectID: projectID, locationID: locationID);
      expect(true, result);

      verify(() => mockDb.selectFromTable(LocationDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });
  });

  group("test deleteSyncSize", () {
    test("test deleteSyncSize pass empty list data expected false", () async {
      String deleteQuery = """DELETE FROM ${SyncSizeDao.tableName} WHERE ${SyncSizeDao.projectIdField}=$projectID AND ${SyncSizeDao.locationIdField}=$locationID""";

      ResultSet resultSet = ResultSet(List.empty(), null, List.empty());
      when(() => mockDb.selectFromTable(SyncSizeDao.tableName, deleteQuery)).thenReturn(resultSet);

      bool result = await markOfflineLocationProject.deleteSyncSize(projectId: projectID, locationId: locationID);
      expect(false, result);

      verify(() => mockDb.selectFromTable(SyncSizeDao.tableName, deleteQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteSyncSize pass exception expected false", () async {
      String deleteQuery = """DELETE FROM ${SyncSizeDao.tableName} WHERE ${SyncSizeDao.projectIdField}=$projectID AND ${SyncSizeDao.locationIdField}=$locationID""";

      when(() => mockDb.selectFromTable(SyncSizeDao.tableName, deleteQuery)).thenThrow(Exception());

      bool result = await markOfflineLocationProject.deleteSyncSize(projectId: projectID, locationId: locationID);
      expect(false, result);
    });
  });

  group("test getUpdatedProjectSyncSize", () {
    test("test getUpdatedProjectSyncSize pass projectID expected list of SyncSizeVo", () async {
      String selectQuery = """SELECT * FROM ${SyncSizeDao.tableName} WHERE ${SyncSizeDao.projectIdField}=$projectID  ORDER BY ${SyncSizeDao.projectIdField} COLLATE NOCASE ASC""";

      ResultSet resultSet = ResultSet(
          ["ProjectId", "LocationId", "PdfAndXfdfSize", "FormTemplateSize", "TotalSize", "CountOfLocations", "TotalFormXmlSize", "AttachmentsSize", "AssociationsSize", "CountOfForms"],
          null,
          [
            ["2130192", 177287, 1535000, 873112, 51446117, 14, 3005501, 43964602, 2941014, 509]
          ]);
      when(() => mockDb.selectFromTable(SyncSizeDao.tableName, selectQuery)).thenReturn(resultSet);

      List<SyncSizeVo> result = await markOfflineLocationProject.getUpdatedProjectSyncSize(projectId: projectID);
      expect(result, isA<List<SyncSizeVo>>());

      verify(() => mockDb.selectFromTable(SyncSizeDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });
  });

  group("test setUpdatedProjectSyncSize", () {
    test("test setUpdatedProjectSyncSize pass projectID and projectSize expected true", () async {
      String updateQuery = """UPDATE ${ProjectDao.tableName} SET ${ProjectDao.projectSizeInByte}=1535000 WHERE ${ProjectDao.projectIdField}=${projectID}""";

      ResultSet resultSet = ResultSet(
          ["ProjectId", "LocationId", "PdfAndXfdfSize", "FormTemplateSize", "TotalSize", "CountOfLocations", "TotalFormXmlSize", "AttachmentsSize", "AssociationsSize", "CountOfForms"],
          null,
          [
            ["2130192", 177287, 1535000, 873112, 51446117, 14, 3005501, 43964602, 2941014, 509]
          ]);
      when(() => mockDb.selectFromTable(ProjectDao.tableName, updateQuery)).thenReturn(resultSet);

      bool result = await markOfflineLocationProject.setUpdatedProjectSyncSize(projectId: projectID, updatedProjectSize: "1535000");
      expect(result, true);

      verify(() => mockDb.selectFromTable(ProjectDao.tableName, updateQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test setUpdatedProjectSyncSize pass exception expected false", () async {
      String updateQuery = """UPDATE ${ProjectDao.tableName} SET ${ProjectDao.projectSizeInByte}=1535000 WHERE ${ProjectDao.projectIdField}=${projectID}""";

      when(() => mockDb.selectFromTable(ProjectDao.tableName, updateQuery)).thenThrow(Exception());

      bool result = await markOfflineLocationProject.setUpdatedProjectSyncSize(projectId: projectID, updatedProjectSize: "1535000");
      expect(result, false);
    });
  });
}
