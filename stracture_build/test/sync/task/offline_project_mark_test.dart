import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/user_reference_attachment_dao.dart';
import 'package:field/data/dao/user_reference_formtype_template_dao.dart';
import 'package:field/data/dao/user_reference_location_plan_dao.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/sync/task/offline_project_mark.dart';
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

  late OfflineProjectMark offlineProjectMark;

  final String projectId = "2130192";
  final String userId = "808581";
  final String userCloudId = "1";

  configureDependencies() {
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});

    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);
  }

  setUp(() async {
    configureDependencies();
    offlineProjectMark = OfflineProjectMark();
  });

  group("test shouldDeleteAttachment", () {
    test("test shouldDeleteAttachment pass UniqueUser 1 with valid select query expected true", () async {
      String selectQuery = "SELECT count(DISTINCT ${UserReferenceAttachmentDao.userId}) as UniqueUser FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} = $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceAttachmentDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceAttachmentDao.revisionIdField} FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} != $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId)";

      ResultSet resultSet = ResultSet(
          ["UniqueUser"],
          null,
          [
            [1]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQuery)).thenReturn(resultSet);

      bool result = await offlineProjectMark.shouldDeleteAttachment(projectId: projectId);
      expect(true, result);

      verify(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test shouldDeleteAttachment pass invalid result expected false", () async {
      ResultSet resultSet = ResultSet(
          [""],
          null,
          [
            [1]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, any())).thenReturn(resultSet);

      bool shouldDeleteAttachment = await offlineProjectMark.shouldDeleteAttachment(projectId: projectId);
      expect(false, shouldDeleteAttachment);
    });
  });

  group("test shouldDeletePlanBy", () {
    test("test shouldDeletePlanBy pass UniqueUser 1 with valid select query expected true", () async {
      String selectQuery = "SELECT count(DISTINCT ${UserReferenceLocationPlanDao.userId}) as UniqueUser FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} = $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceLocationPlanDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceLocationPlanDao.revisionIdField} FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} != $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId)";

      ResultSet resultSet = ResultSet(
          ["UniqueUser"],
          null,
          [
            [1]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery)).thenReturn(resultSet);

      bool shouldDeletePlanBy = await offlineProjectMark.shouldDeletePlanBy(projectId: projectId);
      expect(true, shouldDeletePlanBy);

      verify(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test shouldDeletePlanBy pass invalid result expected false", () async {
      ResultSet resultSet = ResultSet(
          [""],
          null,
          [
            [1]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, any())).thenReturn(resultSet);

      bool shouldDeletePlanBy = await offlineProjectMark.shouldDeletePlanBy(projectId: projectId);
      expect(false, shouldDeletePlanBy);
    });
  });

  group("test shouldDeleteFormType", () {
    test("test shouldDeleteFormType pass UniqueUser 1 with valid select query expected true", () async {
      String selectQuery = "SELECT count(DISTINCT ${UserReferenceFormTypeTemplateDao.userId}) as UniqueUser FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} = $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} NOT IN "
          "(SELECT ${UserReferenceFormTypeTemplateDao.formTypeIdField} FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} != $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId)";

      ResultSet resultSet = ResultSet(
          ["UniqueUser"],
          null,
          [
            [1]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery)).thenReturn(resultSet);

      bool shouldDeleteFormType = await offlineProjectMark.shouldDeleteFormType(projectId: projectId);
      expect(true, shouldDeleteFormType);

      verify(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test shouldDeleteFormType pass invalid result expected false", () async {
      ResultSet resultSet = ResultSet(
          [""],
          null,
          [
            [1]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, any())).thenReturn(resultSet);

      bool shouldDeleteFormType = await offlineProjectMark.shouldDeleteFormType(projectId: projectId);
      expect(false, shouldDeleteFormType);
    });
  });

  group("test deleteProjectAttachment", () {
    test("test deleteProjectAttachment pass RevisionId with valid select query expected true", () async {
      //UserReferenceAttachmentTbl
      String selectQueryReference = "SELECT * FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} = $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceAttachmentDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceAttachmentDao.revisionIdField} FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} != $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId)";

      ResultSet resultSetReference = ResultSet(
          ["RevisionId"],
          null,
          [
            ["123456"]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQueryReference)).thenReturn(resultSetReference);

      //FormMsgAttachAndAssocListTbl
      String selectQueryForm = "SELECT ${FormMessageAttachAndAssocDao.attachFileNameField} FROM ${FormMessageAttachAndAssocDao.tableName} WHERE ${FormMessageAttachAndAssocDao.projectIdField} = $projectId AND "
          "${FormMessageAttachAndAssocDao.attachRevIdField} = 123456";

      ResultSet resultSetForm = ResultSet(
          ["AttachFileName"],
          null,
          [
            ["my_profile.jpg"]
          ]);

      when(() => mockDb.selectFromTable(FormMessageAttachAndAssocDao.tableName, selectQueryForm)).thenReturn(resultSetForm);

      bool deleteProjectAttachment = await offlineProjectMark.deleteProjectAttachment(projectId);
      expect(true, deleteProjectAttachment);

      verify(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQueryReference)).called(greaterThanOrEqualTo(1));
      verify(() => mockDb.selectFromTable(FormMessageAttachAndAssocDao.tableName, selectQueryForm)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteProjectAttachment pass invalid result expected false", () async {
      ResultSet resultSetReference = ResultSet(
          [""],
          null,
          [
            [""]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, any())).thenReturn(resultSetReference);

      bool deleteProjectAttachment = await offlineProjectMark.deleteProjectAttachment(projectId);
      expect(false, deleteProjectAttachment);
    });
  });

  group("test deleteProjectPlanBy", () {
    test("test deleteProjectPlanBy pass RevisionId with valid select query expected true", () async {
      String selectQuery = "SELECT * FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} = $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceLocationPlanDao.revisionIdField} !='0' AND "
          "${UserReferenceLocationPlanDao.revisionIdField} IS NOT NULL AND "
          "${UserReferenceLocationPlanDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceLocationPlanDao.revisionIdField} FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} != $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId)";

      ResultSet resultSet = ResultSet(
          ["RevisionId"],
          null,
          [
            ["123456"]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery)).thenReturn(resultSet);

      bool deleteProjectPlanBy = await offlineProjectMark.deleteProjectPlanBy(projectId);
      expect(true, deleteProjectPlanBy);

      verify(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteProjectPlanBy pass invalid result expected false", () async {
      ResultSet resultSet = ResultSet(
          [""],
          null,
          [
            [""]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, any())).thenReturn(resultSet);

      bool deleteProjectPlanBy = await offlineProjectMark.deleteProjectPlanBy(projectId);
      expect(false, deleteProjectPlanBy);
    });
  });

  group("test deleteProjectFormType", () {
    //FAIL
    /*test("test deleteProjectFormType pass FormTypeId with valid select query expected true", () async {
      String selectQuery = "SELECT * FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} = $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} !='0' AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} IS NOT NULL AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} NOT IN "
          "(SELECT ${UserReferenceFormTypeTemplateDao.formTypeIdField} FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} != $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId)";

      ResultSet resultSet = ResultSet(
          ["FormTypeId"],
          null,
          [
            ["123456"]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery)).thenReturn(resultSet);

      bool deleteProjectFormType = await offlineProjectMark.deleteProjectFormType(projectId);
      expect(true, deleteProjectFormType);

      verify(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });*/

    test("test deleteProjectFormType pass exception expected false", () async {
      when(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, any())).thenThrow(Exception());

      bool deleteProjectFormType = await offlineProjectMark.deleteProjectFormType(projectId);
      expect(false, deleteProjectFormType);
    });
  });

  group("test deleteUserFormType", () {
    test("test deleteUserFormType pass FormTypeId with valid select query expected true", () async {
      String selectQuery = "SELECT ${FormTypeDao.formTypeIdField} FROM ${FormTypeDao.tableName} WHERE ${FormTypeDao.projectIdField} = $projectId";

      ResultSet resultSet = ResultSet(
          ["FormTypeId"],
          null,
          [
            ["123456"]
          ]);

      when(() => mockDb.selectFromTable(FormTypeDao.tableName, selectQuery)).thenReturn(resultSet);

      bool deleteUserFormType = await offlineProjectMark.deleteUserFormType(projectId: projectId);
      expect(true, deleteUserFormType);

      verify(() => mockDb.selectFromTable(FormTypeDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteUserFormType pass exception expected false", () async {
      when(() => mockDb.selectFromTable(FormTypeDao.tableName, any())).thenThrow(Exception());

      bool deleteUserFormType = await offlineProjectMark.deleteUserFormType(projectId: projectId);
      expect(false, deleteUserFormType);
    });
  });

  group("test deleteUserDataForPlanBy", () {
    test("test deleteUserDataForPlanBy with valid delete query expected true", () async {
      String selectQuery = "DELETE FROM ${UserReferenceLocationPlanDao.tableName} WHERE ${UserReferenceLocationPlanDao.userId} = $userId AND ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId";

      ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

      when(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery)).thenReturn(resultSet);

      bool deleteUserDataForPlanBy = await offlineProjectMark.deleteUserDataForPlanBy(projectId: projectId);
      expect(true, deleteUserDataForPlanBy);

      verify(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteUserDataForPlanBy pass exception expected false", () async {
      when(() => mockDb.selectFromTable(UserReferenceLocationPlanDao.tableName, any())).thenThrow(Exception());

      bool deleteUserDataForPlanBy = await offlineProjectMark.deleteUserDataForPlanBy(projectId: projectId);
      expect(false, deleteUserDataForPlanBy);
    });
  });

  group("test deleteUserDataForAttachment", () {
    test("test deleteUserDataForAttachment with valid delete query expected true", () async {
      String selectQuery = "DELETE FROM ${UserReferenceAttachmentDao.tableName} WHERE UserId = $userId AND ProjectId = $projectId AND UserCloudId = $userCloudId";

      ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQuery)).thenReturn(resultSet);

      bool deleteUserDataForAttachment = await offlineProjectMark.deleteUserDataForAttachment(projectId: projectId);
      expect(true, deleteUserDataForAttachment);

      verify(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteUserDataForAttachment pass exception expected false", () async {
      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, any())).thenThrow(Exception());

      bool deleteUserDataForAttachment = await offlineProjectMark.deleteUserDataForAttachment(projectId: projectId);
      expect(false, deleteUserDataForAttachment);
    });
  });

  group("test deleteUserDataForFormType", () {
    test("test deleteUserDataForFormType with valid delete query expected true", () async {
      String selectQuery = "DELETE FROM ${UserReferenceFormTypeTemplateDao.tableName} WHERE ${UserReferenceFormTypeTemplateDao.userId} = $userId AND ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId";

      ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

      when(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery)).thenReturn(resultSet);

      bool deleteUserDataForFormType = await offlineProjectMark.deleteUserDataForFormType(projectId: projectId);
      expect(true, deleteUserDataForFormType);

      verify(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteUserDataForFormType pass exception expected false", () async {
      when(() => mockDb.selectFromTable(UserReferenceFormTypeTemplateDao.tableName, any())).thenThrow(Exception());

      bool deleteUserDataForFormType = await offlineProjectMark.deleteUserDataForFormType(projectId: projectId);
      expect(false, deleteUserDataForFormType);
    });
  });

  group("test deleteDataFromTable", () {
    test("test deleteDataFromTable pass single table expected true", () async {
      String selectQuery = "DELETE FROM ${FormMessageActionDao.tableName} WHERE ProjectId = $projectId";
      ResultSet resultSet = ResultSet(List.empty(), null, List.empty());

      when(() => mockDb.selectFromTable(FormMessageActionDao.tableName, any())).thenReturn(resultSet);

      bool deleteDataFromTable = await offlineProjectMark.deleteDataFromTable(projectId: projectId, tableName: FormMessageActionDao.tableName);
      expect(true, deleteDataFromTable);

      verify(() => mockDb.selectFromTable(FormMessageActionDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });

    test("test deleteDataFromTable pass exception expected false", () async {
      when(() => mockDb.selectFromTable(FormMessageActionDao.tableName, any())).thenThrow(Exception());

      bool deleteDataFromTable = await offlineProjectMark.deleteDataFromTable(projectId: projectId, tableName: FormMessageActionDao.tableName);
      expect(false, deleteDataFromTable);
    });
  });

  group("test deleteProjectDetails", () {
    test("test deleteProjectDetails verify shouldDeleteAttachment call expected yes", () async {
      String selectQuery = "SELECT count(DISTINCT ${UserReferenceAttachmentDao.userId}) as UniqueUser FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} = $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceAttachmentDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceAttachmentDao.revisionIdField} FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} != $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId)";

      ResultSet resultSet = ResultSet(
          ["UniqueUser"],
          null,
          [
            [1]
          ]);

      when(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQuery)).thenReturn(resultSet);

      await offlineProjectMark.deleteProjectDetails(projectId: projectId);
      verify(() => mockDb.selectFromTable(UserReferenceAttachmentDao.tableName, selectQuery)).called(greaterThanOrEqualTo(1));
    });
  });
}
