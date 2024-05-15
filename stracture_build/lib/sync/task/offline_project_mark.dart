import 'dart:io';
import 'package:path/path.dart' as fp;
import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/user_reference_attachment_dao.dart';
import 'package:field/data/dao/user_reference_formtype_template_dao.dart';
import 'package:field/data/dao/user_reference_location_plan_dao.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';

import '../../data/dao/form_dao.dart';
import '../../data/dao/form_message_action_dao.dart';
import '../../data/dao/formtype_dao.dart';
import '../../data/dao/location_dao.dart';
import '../../data/dao/manage_type_dao.dart';
import '../../data/dao/project_dao.dart';
import '../../data/dao/status_style_dao.dart';
import '../../data/model/sync_size_vo.dart';
import '../../data_source/sync_size/sync_size_data_source.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/file_utils.dart';
import '../../utils/store_preference.dart';

class OfflineProjectMark {
  Future<void> deleteProjectDetails({required String projectId}) async {
    if (await shouldDeleteAttachment(projectId: projectId)) {
      await deleteProjectAttachment(projectId);
      await _deleteSyncSize(projectId: projectId, locationId: "-1");
    }
    if (await shouldDeletePlanBy(projectId: projectId)) {
      await deleteProjectPlanBy(projectId);
    }
    if (await shouldDeleteFormType(projectId: projectId)) {
      await deleteProjectFormType(projectId);
    }
    await deleteUserFormType(projectId: projectId);

    await deleteUserDataForAttachment(projectId: projectId);
    await deleteUserDataForPlanBy(projectId: projectId);
    await deleteUserDataForFormType(projectId: projectId);

    List<String> tableNameList = [FormMessageActionDao.tableName, FormMessageAttachAndAssocDao.tableName, FormMessageDao.tableName, FormDao.tableName, LocationDao.tableName, FormTypeDao.tableName, ManageTypeDao.tableName, StatusStyleListDao.tableName, ProjectDao.tableName];

    for (var tableName in tableNameList) {
      await deleteDataFromTable(projectId: projectId, tableName: tableName);
    }

    String filePath = await AppPathHelper().getProjectFilterAttributeFile(projectId: projectId);
    if (filePath.isNotEmpty && isFileExist(filePath)) {
      await deleteFileAtPath(filePath);
    }
  }

  Future<bool> deleteProjectAttachment(String projectId) async {
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "SELECT * FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} = $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceAttachmentDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceAttachmentDao.revisionIdField} FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} != $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId)";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(UserReferenceAttachmentDao.tableName, selectQuery);
      for (var attachmentItem in queryResult) {
        String revisionIdField = attachmentItem[UserReferenceAttachmentDao.revisionIdField];

        String selectQuery = "SELECT ${FormMessageAttachAndAssocDao.attachFileNameField} FROM ${FormMessageAttachAndAssocDao.tableName} WHERE ${FormMessageAttachAndAssocDao.projectIdField} = $projectId AND "
            "${FormMessageAttachAndAssocDao.attachRevIdField} = $revisionIdField";

        final path = await AppPathHelper().getUserDataDBFilePath();
        final db = DatabaseManager(path);
        var queryResult = db.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, selectQuery);

        if (queryResult.isNotEmpty) {
          String fileName = queryResult.first[FormMessageAttachAndAssocDao.attachFileNameField];
          String realPath = await AppPathHelper().getAttachmentFilePath(projectId: projectId, revisionId: revisionIdField, fileExtention: fileName.toString().getExtension().replaceAll(".", "") ?? "");

          await deleteFileAtPath(realPath);
        }
      }
      return true;
    } catch (e, stacktrace) {
      Log.d("DeleteAttachmentByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> deleteProjectPlanBy(String projectId) async {
    UserReferenceLocationPlanDao userReferenceLocationPlanDao = UserReferenceLocationPlanDao();
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "SELECT * FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} = $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceLocationPlanDao.revisionIdField} !='0' AND "
          "${UserReferenceLocationPlanDao.revisionIdField} IS NOT NULL AND "
          "${UserReferenceLocationPlanDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceLocationPlanDao.revisionIdField} FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} != $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId)";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery);

      for (var planItem in queryResult) {
        String pdfPath = await AppPathHelper().getPlanPDFFilePath(projectId: projectId, revisionId: planItem[UserReferenceLocationPlanDao.revisionIdField]);
        String xfdfPath = await AppPathHelper().getPlanXFDFFilePath(projectId: projectId, revisionId: planItem[UserReferenceLocationPlanDao.revisionIdField]);

        await deleteFileAtPath(pdfPath);
        await deleteFileAtPath(xfdfPath);
      }
      return true;
    } catch (e, stacktrace) {
      Log.d("DeletePlanByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> deleteProjectFormType(String projectId) async {
    UserReferenceFormTypeTemplateDao userReferenceFormTypeTemplateDao = UserReferenceFormTypeTemplateDao();
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "SELECT * FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} = $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} !='0' AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} IS NOT NULL AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} NOT IN "
          "(SELECT ${UserReferenceFormTypeTemplateDao.formTypeIdField} FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} != $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId)";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery);

      for (var formTypeItem in queryResult) {
        String appFormTypePath = await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeItem[UserReferenceFormTypeTemplateDao.formTypeIdField].toString());
         deleteDirectory(directoryPath: appFormTypePath);
      }
      return true;
    } catch (e, stacktrace) {
      Log.d("DeleteFormTypeByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> deleteUserFormType({required String projectId}) async {
    try {
      String selectQuery = "SELECT ${FormTypeDao.formTypeIdField} FROM ${FormTypeDao.tableName} WHERE ${FormTypeDao.projectIdField} = $projectId";

      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);

      var queryResult = db.executeSelectFromTable(FormTypeDao.tableName, selectQuery);

      for (var formTypeItem in queryResult) {
        String userFormTypePath = await AppPathHelper().getUserDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeItem[FormTypeDao.formTypeIdField].toString());
         deleteDirectory(directoryPath: userFormTypePath);
      }
      return true;
    } catch (e, stacktrace) {
      Log.d("DeleteUserFormTypeByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> deleteDataFromTable({required String projectId, required String tableName}) async {
    try {
      String selectQuery = "DELETE FROM $tableName WHERE ProjectId = $projectId";
      String reduceQuery = "VACUUM";

      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
      db.executeSelectFromTable(tableName, selectQuery);
      db.executeTableRequest(reduceQuery);
      return true;
    } catch (e, stacktrace) {
      Log.d("RemoveDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> shouldDeleteAttachment({required String projectId}) async {
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "SELECT count(DISTINCT ${UserReferenceAttachmentDao.userId}) as UniqueUser FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} = $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceAttachmentDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceAttachmentDao.revisionIdField} FROM ${UserReferenceAttachmentDao.tableName} "
          "WHERE ${UserReferenceAttachmentDao.projectIdField} = $projectId AND ${UserReferenceAttachmentDao.userId} != $userId AND ${UserReferenceAttachmentDao.userCloudIdField} = $userCloudId)";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(UserReferenceAttachmentDao.tableName, selectQuery);
      for (var element in queryResult) {
        return element["UniqueUser"] <= 1;
      }
    } catch (e, stacktrace) {
      Log.d("RemoveDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> shouldDeletePlanBy({required String projectId}) async {
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "SELECT count(DISTINCT ${UserReferenceLocationPlanDao.userId}) as UniqueUser FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} = $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceLocationPlanDao.revisionIdField} NOT IN "
          "(SELECT ${UserReferenceLocationPlanDao.revisionIdField} FROM ${UserReferenceLocationPlanDao.tableName} "
          "WHERE ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userId} != $userId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId)";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery);
      for (var element in queryResult) {
        return element["UniqueUser"] <= 1;
      }
    } catch (e, stacktrace) {
      Log.d("RemoveDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> shouldDeleteFormType({required String projectId}) async {
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "SELECT count(DISTINCT ${UserReferenceFormTypeTemplateDao.userId}) as UniqueUser FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} = $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId AND "
          "${UserReferenceFormTypeTemplateDao.formTypeIdField} NOT IN "
          "(SELECT ${UserReferenceFormTypeTemplateDao.formTypeIdField} FROM ${UserReferenceFormTypeTemplateDao.tableName} "
          "WHERE ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userId} != $userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId)";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery);
      for (var element in queryResult) {
        return element["UniqueUser"] <= 1;
      }
    } catch (e, stacktrace) {
      Log.d("RemoveDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> deleteUserDataForAttachment({required String projectId}) async {
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "DELETE FROM ${UserReferenceAttachmentDao.tableName} WHERE UserId = $userId AND ProjectId = $projectId AND UserCloudId = $userCloudId";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      db.executeSelectFromTable(UserReferenceAttachmentDao.tableName, selectQuery);
      return true;
    } catch (e, stacktrace) {
      Log.d("RemoveDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> deleteUserDataForPlanBy({required String projectId}) async {
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "DELETE FROM ${UserReferenceLocationPlanDao.tableName} WHERE ${UserReferenceLocationPlanDao.userId} = $userId AND ${UserReferenceLocationPlanDao.projectIdField} = $projectId AND ${UserReferenceLocationPlanDao.userCloudIdField} = $userCloudId";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      db.executeSelectFromTable(UserReferenceLocationPlanDao.tableName, selectQuery);
      return true;
    } catch (e, stacktrace) {
      Log.d("RemoveDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> deleteUserDataForFormType({required String projectId}) async {
    try {
      final userId = await StorePreference.getUserId();
      final userCloudId = await StorePreference.getUserCloud();

      String selectQuery = "DELETE FROM ${UserReferenceFormTypeTemplateDao.tableName} WHERE ${UserReferenceFormTypeTemplateDao.userId} = $userId AND ${UserReferenceFormTypeTemplateDao.projectIdField} = $projectId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField} = $userCloudId";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      db.executeSelectFromTable(UserReferenceFormTypeTemplateDao.tableName, selectQuery);
      return true;
    } catch (e, stacktrace) {
      Log.d("RemoveDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }

  Future<bool> _deleteSyncSize({required String projectId, required String locationId}) async {
    SyncSizeDataSource syncSizeDataSource = SyncSizeDataSource();
    await syncSizeDataSource.init();
    try {
      final map = {"projectId": projectId, "locationId": locationId};
      List<SyncSizeVo> syncSizeList = await syncSizeDataSource.deleteProjectSync(map);
      return syncSizeList.isNotEmpty;
    } catch (e, stacktrace) {
      Log.d("SyncSizeTable exception $e $stacktrace");
      return false;
    }
  }

  /// Added function to delete files + .zip file when app is closed and sync failed
  Future<void> deleteAttachmentZipFiles() async {
    try {
      String selectQuery = "SELECT DISTINCT ${UserReferenceAttachmentDao.projectIdField} FROM ${UserReferenceAttachmentDao.tableName} ";
      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(UserReferenceAttachmentDao.tableName, selectQuery);
      if (queryResult.isNotEmpty) {
        for (var element in queryResult) {
          String projectId = element[UserReferenceAttachmentDao.projectIdField];
          final dir = Directory(await AppPathHelper().getAttachmentDirectory(projectId: projectId));
          List<FileSystemEntity> attachmentZipFiles = await dir.list().toList();
          for (var attachmentItem in attachmentZipFiles) {
            String filename = fp.basename(attachmentItem.path);
            if (filename.startsWith(AConstants.tempAttachmentZip)) {
               await deleteFileAtPath(attachmentItem.path);
            }
          }
        }
      }
    } catch (e, stacktrace) {
      Log.d("delete Attachment Zip Files$e $stacktrace");
    }
  }
}
