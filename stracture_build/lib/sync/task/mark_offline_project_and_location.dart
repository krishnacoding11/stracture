import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/user_reference_attachment_dao.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/data_source/sync_size/sync_size_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_utils.dart';
import 'package:field/utils/store_preference.dart';

import '../../data/dao/form_dao.dart';
import '../../data/dao/form_message_attachAndAssoc_dao.dart';
import '../../data/dao/location_dao.dart';
import '../../data/dao/project_dao.dart';
import '../../data/dao/user_reference_formtype_template_dao.dart';
import '../../data/dao/user_reference_location_plan_dao.dart';
import 'offline_project_mark.dart';

class MarkOfflineLocationProject {
  Future<bool> deleteProjectLocationDetails({
    required String projectID,
    required String locationID,
  }) async {
    await deleteSyncSize(projectId: projectID, locationId: locationID);
    final isDeleteLocationAttachment = await _deleteLocationAttachment(projectID, locationID);
    if (isDeleteLocationAttachment) {
      final isDeleteLocationFormTypeAttachment = await _deleteLocationFormTypeAttachment(projectID, locationID);
      if(isDeleteLocationFormTypeAttachment){
      final isDeleteLocationAttachmentFromTbl = await _deleteLocationAttachmentFromTbl(projectID, locationID);
      if (isDeleteLocationAttachmentFromTbl) {
        final isDeleteLocationFormMessageList = await _deleteLocationFormMessageList(projectID, locationID);
        if (isDeleteLocationFormMessageList) {
          final isDeleteLocationFormMsgActionList = await _deleteLocationFormMsgActionList(projectID, locationID);
          if (isDeleteLocationFormMsgActionList) {
            final isDeleteLocationFormList = await _deleteLocationFormList(projectID, locationID);
            if (isDeleteLocationFormList) {
              final isDeleteLocationPlanFile = await _deleteLocationPlanFile(projectID, locationID);
              if (isDeleteLocationPlanFile) {
                final isDeleteLocationTableData = await _deleteLocationTableData(projectID, locationID);
                await _removeProjectData(projectID: projectID);
                return isDeleteLocationTableData;
                }
              }
            }
          }
        }
      }
    }
    return false;
  }

  Future<bool> _deleteLocationAttachment(String projectID,
      String locationID,) async {
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String getLocationFormListQuery = _getLocationListInFormListTbl();
    String query = "$getLocationListQuery,\n"
        "$getLocationFormListQuery\n"
        "SELECT frmAtchTbl.* FROM FormMsgAttachAndAssocListTbl frmAtchTbl\n"
        "INNER JOIN LocationFormList frmCte ON frmCte.ProjectId=frmAtchTbl.ProjectId AND frmCte.FormId=frmAtchTbl.FormId AND ${FormMessageAttachAndAssocDao.attachRevIdField} IS NOT NULL AND ${FormMessageAttachAndAssocDao.attachRevIdField} != ''";

    try {
      final path = await AppPathHelper().getUserDataDBFilePath();
      final databaseManager = DatabaseManager(path);
      var resultFormData =
      databaseManager.executeSelectFromTable("LocationDetailTbl", query);
      if (resultFormData.isNotEmpty) {
        for (var attachmentItem in resultFormData) {
          //verify is multiple User available in FormRevisionListTbl
          bool isLastUserInRevisionTbl = await _isLastUserInRevisionTbl(
            revisionId: attachmentItem['AttachRevId'],
            projectID: projectID,
          );
          if (isLastUserInRevisionTbl) {
            String realPath = await AppPathHelper().getAttachmentFilePath(
                projectId: projectID,
                revisionId: attachmentItem['AttachRevId'],
                fileExtention: attachmentItem['AttachFileName']
                    .toString()
                    .getFileExtension()
                    ?.replaceAll(".", "") ??
                    "");
            await deleteFileAtPath(realPath);
          }
        }
      }
      return true;
    } catch (e, stacktrace) {
      Log.d("DeleteLocationAttachment exception $e $stacktrace}");
      return false;
    }
  }

  Future<bool> _deleteLocationFormTypeAttachment(
      String projectID,
      String locationID,
      ) async {
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String query = "$getLocationListQuery\n"
        "SELECT DISTINCT frmTbl.FormTypeId FROM FormListTbl frmTbl\n"
        "INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId";

    try {
      final path = await AppPathHelper().getUserDataDBFilePath();
      final databaseManager = DatabaseManager(path);
      var resultFormData =
      databaseManager.executeSelectFromTable(LocationDao.tableName, query);
      if (resultFormData.isNotEmpty) {
        for (var formTypeItem in resultFormData) {
          //verify is multiple User available in FormTypeId
          String formTypeId = formTypeItem[FormDao.formTypeIdField].toString();
          bool isLastUserInRevisionTbl = await _isLastUserInReferenceFormTypeTbl(
            formTypeId: formTypeId,
            projectID: projectID
          );
          if (isLastUserInRevisionTbl) {
            String appFormTypePath = await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectID, formTypeId: formTypeId);
             deleteDirectory(directoryPath: appFormTypePath);
          }
          String userFormTypePath = await AppPathHelper().getUserDataFormTypeDirectory(projectId: projectID, formTypeId: formTypeId);
           deleteDirectory(directoryPath: userFormTypePath);
        }
      }
      return true;
    } catch (e, stacktrace) {
      Log.d("DeleteLocationForm exception $e $stacktrace}");
      return false;
    }
  }

  Future<bool> _deleteLocationAttachmentFromTbl(String projectID,
      String locationID,) async {
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String getLocationFormListQuery = _getLocationListInFormListTbl();
    String query = "$getLocationListQuery,\n"
        "$getLocationFormListQuery\n"
        "DELETE  FROM FormMsgAttachAndAssocListTbl WHERE ProjectId= (SELECT ProjectId FROM LocationFormList) AND FormId= (SELECT FormId FROM LocationFormList)";

    return await _executeDeleteQueryFromTable(
        query, "FormMsgAttachAndAssocListTbl");
  }

  Future<bool> _deleteLocationFormMessageList(String projectID, String locationID) async {
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String getLocationFormListQuery = _getLocationListInFormListTbl();
    String query = "$getLocationListQuery,\n"
        "$getLocationFormListQuery\n"
        "DELETE FROM FormMessageListTbl WHERE ProjectId=$projectID AND LocationId IN (SELECT LocationId FROM LocationFormList)";

    return await _executeDeleteQueryFromTable(query, "FormMessageListTbl");
  }

  Future<bool> _deleteLocationFormMsgActionList(String projectID, String locationID) async {
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String getLocationFormListQuery = _getLocationListInFormListTbl();
    String query = "$getLocationListQuery,\n"
        "$getLocationFormListQuery\n"
        "DELETE FROM FormMsgActionListTbl WHERE ProjectId=$projectID AND FormId IN (SELECT FormId FROM LocationFormList)";

    return await _executeDeleteQueryFromTable(query, "FormMsgActionListTbl");
  }

  Future<bool> _deleteLocationFormList(String projectID, String locationID) async {
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String getLocationFormListQuery = _getLocationListInFormListTbl();
    String query = "$getLocationListQuery,\n"
        "$getLocationFormListQuery\n"
        "DELETE FROM FormListTbl WHERE ProjectId=$projectID AND LocationId IN (SELECT LocationId FROM LocationFormList)";
    return await _executeDeleteQueryFromTable(query, "FormListTbl");
  }

  Future<bool> _deleteLocationPlanFile(String projectID, String locationID) async {
    UserReferenceLocationPlanDao userReferenceLocationPlanDao = UserReferenceLocationPlanDao();
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String query = "$getLocationListQuery\n"
        "SELECT * FROM ChildLocation\n"
        "WHERE RevisionId<>0\n"
        "GROUP BY RevisionId\n";
    try {
      final path = await AppPathHelper().getUserDataDBFilePath();
      final databaseManager = DatabaseManager(path);

      var resultFormData =
      databaseManager.executeSelectFromTable("LocationDetailTbl", query);
      if (resultFormData.isNotEmpty) {
        for (var attachmentItem in resultFormData) {
          String pdfPath = await AppPathHelper().getPlanPDFFilePath(
              projectId: projectID, revisionId: attachmentItem['RevisionId']);

          String xfdfPath = await AppPathHelper().getPlanXFDFFilePath(
              projectId: projectID, revisionId: attachmentItem['RevisionId']);
          await userReferenceLocationPlanDao.deleteLocationPlanDetailsInUserReference(projectId: projectID, revisionId: attachmentItem['RevisionId']);
          if (await userReferenceLocationPlanDao.shouldDeleteLocationPlan(projectId: projectID, revisionId: attachmentItem['RevisionId'])) {
            //await deleteFileAtPath(pdfPath);
            await deleteFileAtPath(xfdfPath);
}
        }
      }
      return true;
    } catch (e, stacktrace) {
      Log.d("DeleteLocationPlanFile exception $e $stacktrace}");
      return false;
    }
  }

  Future<bool> _deleteLocationTableData(String projectID, String locationID) async {
    String getLocationListQuery =
    _getLocationListFromLocationDetailTbl(projectID, locationID);
    String query = "$getLocationListQuery\n"
        "DELETE FROM LocationDetailTbl WHERE ProjectId=$projectID AND LocationId IN (SELECT LocationId FROM ChildLocation)";
    await _executeDeleteQueryFromTable(query, "LocationDetailTbl");
    String queryParentLocationID = "DELETE FROM LocationDetailTbl WHERE ProjectId=$projectID AND LocationId=$locationID";
    return await _executeDeleteQueryFromTable(queryParentLocationID, "LocationDetailTbl");
  }

  String _getLocationListFromLocationDetailTbl(String projectID, String locationID) {
    return "WITH ChildLocation AS (\n"
        "SELECT * FROM LocationDetailTbl\n"
        "WHERE ProjectId=$projectID AND LocationId=$locationID \n"
        "UNION\n"
        "SELECT locTbl.* FROM LocationDetailTbl locTbl\n"
        "INNER JOIN ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId\n"
        ")";
  }

  String _getLocationListInFormListTbl() {
    return "LocationFormList AS (\n"
        "SELECT frmTbl.ProjectId,frmTbl.LocationId,frmTbl.FormId FROM FormListTbl frmTbl\n"
        "INNER JOIN ChildLocation locCte ON locCte.ProjectId=frmTbl.ProjectId AND locCte.LocationId=frmTbl.LocationId\n"
        ")";
  }

  Future<bool> _executeDeleteQueryFromTable(String query, String actionTblName) async {
    try {
      final path = await AppPathHelper().getUserDataDBFilePath();
      final databaseManager = DatabaseManager(path);
      databaseManager.executeTableRequest(query);
      return true;
    } catch (e, stacktrace) {
      Log.d("$actionTblName exception $e $stacktrace}");
      return false;
    }
  }

  Future<bool> _isLastUserInRevisionTbl({required String revisionId, required String projectID}) async {
    final path = await DatabaseManager.getUserDBPath();
    final databaseManager =
    DatabaseManager("$path/${AConstants.userReference}");
    const tableName = UserReferenceAttachmentDao.tableName;
    final userId = await StorePreference.getUserId();
    final userCloudId = await StorePreference.getUserCloud();
    //Delete attachment for current User
    final deleteQuery =
        "DELETE FROM $tableName WHERE ProjectId=$projectID AND RevisionId=$revisionId AND UserId=$userId AND UserCloudId=$userCloudId";
    await databaseManager.executeTableRequest(deleteQuery);
    //Validate is any other user using same attachment or not
    final fetchQuery =
        "SELECT * FROM $tableName WHERE ProjectId=$projectID AND RevisionId=$revisionId AND UserCloudId=$userCloudId";
    var resultFormData =
    databaseManager.executeSelectFromTable(tableName, fetchQuery);
    return resultFormData.isEmpty ? true : false;
  }

  Future<bool> _isLastUserInReferenceFormTypeTbl(
      {required String formTypeId, required String projectID}) async {
    final path = await DatabaseManager.getUserDBPath();
    final databaseManager =
    DatabaseManager("$path/${AConstants.userReference}");
    const tableName = UserReferenceFormTypeTemplateDao.tableName;
    final userId = await StorePreference.getUserId();
    final userCloudId = await StorePreference.getUserCloud();
    //Delete attachment for current User
    final deleteQuery =
        "DELETE FROM $tableName WHERE ${UserReferenceFormTypeTemplateDao.projectIdField}=$projectID AND ${UserReferenceFormTypeTemplateDao.formTypeIdField}=$formTypeId AND ${UserReferenceFormTypeTemplateDao.userId}=$userId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField}=$userCloudId";
    await databaseManager.executeTableRequest(deleteQuery);
    //Validate is any other user using same attachment or not
    final fetchQuery =
        "SELECT * FROM $tableName WHERE ${UserReferenceFormTypeTemplateDao.projectIdField}=$projectID AND ${UserReferenceFormTypeTemplateDao.formTypeIdField}=$formTypeId AND ${UserReferenceFormTypeTemplateDao.userCloudIdField}=$userCloudId";
    var resultFormData =
    databaseManager.executeSelectFromTable(tableName, fetchQuery);
    return resultFormData.isEmpty ? true : false;
  }

  Future<bool> _removeProjectData({required String projectID}) async {
    try {
      final getLocationCount = "SELECT COUNT(LocationId) FROM LocationDetailTbl\n"
          "WHERE ProjectId=$projectID AND CanRemoveOffline=1";
      final path = await AppPathHelper().getUserDataDBFilePath();
      final databaseManager = DatabaseManager(path);
      var resultFormData =
      databaseManager.executeSelectFromTable("LocationDetailTbl", getLocationCount);
      if (resultFormData.isNotEmpty) {
        final locationCount = resultFormData[0].values.first;
        if (locationCount == 0) {
          OfflineProjectMark().deleteProjectDetails(projectId: projectID);
        }
      }
    } catch (e, stacktrace) {
      Log.d("LocationDetailTbl exception $e $stacktrace");
      return false;
    }
    return false;
  }

  Future<bool> deleteSyncSize({required String projectId, required String locationId}) async {
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

  Future<List<SyncSizeVo>> getUpdatedProjectSyncSize({required String projectId}) async {
    SyncSizeDataSource syncSizeDataSource = SyncSizeDataSource();
    await syncSizeDataSource.init();
    List<SyncSizeVo> syncSizeVo = [];
    try {
      syncSizeVo = await syncSizeDataSource.getProjectSyncSize({"projectId": projectId});
    } catch (e, stacktrace) {
      Log.d("SyncSizeTable exception $e $stacktrace");
    }
    return syncSizeVo;
  }

  Future<bool> setUpdatedProjectSyncSize({required String projectId, required String updatedProjectSize}) async {
    String strUpdateQuery = "UPDATE ${ProjectDao.tableName} SET ${ProjectDao.projectSizeInByte}=$updatedProjectSize WHERE ${ProjectDao.projectIdField}=${projectId.plainValue()}";

    try {
      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
      var qurResult = db.executeSelectFromTable(ProjectDao.tableName, strUpdateQuery);
      if (qurResult.isNotEmpty) {
        return true;
      }
    } catch (e, stacktrace) {
      Log.d("LocationDetailTbl exception $e $stacktrace");
      return false;
    }
    return false;
  }

  Future<List<String>> getLocationIncludeSubFormIdList(String projectId, String locationId) async {
    List<String> formIdList = [];
    try {
      String query = "WITH ChildLocation AS (\n"
          "SELECT ProjectId,LocationId,ParentLocationId FROM ${LocationDao.tableName}\n"
          "WHERE ProjectId=${projectId.plainValue()} AND LocationId=${locationId.plainValue()}\n"
          "UNION\n"
          "SELECT locTbl.ProjectId,locTbl.LocationId,locTbl.ParentLocationId FROM ${LocationDao.tableName} locTbl\n"
          "INNER JOIN ChildLocation childLoc ON childLoc.ProjectId=locTbl.ProjectId AND childLoc.LocationId=locTbl.ParentLocationId\n"
          ")\n"
          "SELECT DISTINCT FormId FROM ${FormDao.tableName} frmTbl\n"
          "INNER JOIN ChildLocation childLoc ON childLoc.ProjectId=frmTbl.ProjectId AND childLoc.LocationId=frmTbl.LocationId \n"
          "AND frmTbl.IsOfflineCreated<>1";
      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
      var result = db.executeSelectFromTable(FormDao.tableName, query);
      formIdList = result.map((e) => e["FormId"].toString()).toList();
    } on Exception catch (e) {
      Log.d("SiteFormListingLocalDataSource::getFormIdList exception=$e");
    }
    return formIdList;
  }

  Future<void> _removeAttachments(String query) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    final resultFormData = db.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, query);
    if (resultFormData.isNotEmpty) {
      for (var attachmentItem in resultFormData) {
        String projectId = attachmentItem['ProjectId'].toString();
        String revisionId = attachmentItem['AttachRevId'].toString();
        bool isLastUserInRevisionTbl = await _isLastUserInRevisionTbl(revisionId: revisionId, projectID: projectId);
        if (isLastUserInRevisionTbl) {
          String fileExt = attachmentItem['AttachFileName'].toString().getExtension().replaceAll(".", "") ?? "";
          String realPath = await AppPathHelper().getAttachmentFilePath(projectId: projectId, revisionId: revisionId, fileExtention: fileExt);
          await deleteFileAtPath(realPath);
        }
      }
    }
  }

  Future<void> removeFormsFromDatabase(String projectId, List<String> formIdList) async {
    try {
      if (formIdList.isNotEmpty) {
        String formIds = formIdList.join(",");
        final path = await AppPathHelper().getUserDataDBFilePath();
        final db = DatabaseManager(path);
        String query = "SELECT ProjectId,AttachRevId,AttachFileName FROM ${FormMessageAttachAndAssocDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND FormId IN ($formIds) AND AttachRevId<>''";
        await _removeAttachments(query);
        /*query = "SELECT DISTINCT FormTypeId FROM ${FormDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND FormId IN ($formIds) AND FormTypeId NOT IN (\n"
            "SELECT DISTINCT FormTypeId FROM ${FormDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND FormId NOT IN ($formIds)\n"
            ")";
        final resultFormTypeData = db.executeSelectFromTable(FormDao.tableName, query);
        if (resultFormTypeData.isNotEmpty) {
          for (var frmTpItem in resultFormTypeData) {
            String formTypeId = frmTpItem['FormTypeId'].toString();
            bool isLastUserInRevisionTbl = await _isLastUserInReferenceFormTypeTbl(formTypeId: formTypeId, projectID: projectId);
            if (isLastUserInRevisionTbl) {
              String appFormTypePath = await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeId);
              deleteDirectory(directoryPath: appFormTypePath);
            }
            String userFormTypePath = await AppPathHelper().getUserDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeId);
            deleteDirectory(directoryPath: userFormTypePath);
          }
        }
        query = "DELETE FROM ${FormTypeDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND FormTypeId IN (SELECT DISTINCT FormTypeId FROM ${FormDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND FormId IN ($formIds) AND FormTypeId NOT IN (\n"
            "SELECT DISTINCT FormTypeId FROM ${FormDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND FormId NOT IN ($formIds)\n"
            "))";
        db.executeTableRequest(query);*/

        final tableList = [FormMessageActionDao.tableName, FormMessageAttachAndAssocDao.tableName, FormMessageDao.tableName, FormDao.tableName];
        for (var tableName in tableList) {
          query = "DELETE FROM $tableName\n"
              "WHERE ProjectId=${projectId.plainValue()} AND FormId IN ($formIds)";
          db.executeTableRequest(query);
        }
        db.executeTableRequest("VACUUM");
      }
    } on Exception catch (e) {
      Log.d("SiteFormListingLocalDataSource::removeFormsFromDatabase exception=$e");
    }
  }

  Future<void> removeFormMessagesFromDatabase(String projectId, String formId, List<String> msgIdList) async {
    try {
      if (projectId.isNotEmpty && formId.isNotEmpty && msgIdList.isNotEmpty) {
        msgIdList = msgIdList.map((e) => e.toString().plainValue()).toList().cast<String>();
        String msgIds = msgIdList.join(",");
        String subQuery = "SELECT MsgId FROM ${FormMessageDao.tableName}\n"
        "WHERE IsOfflineCreated=0 AND ProjectId=${projectId.plainValue()}\n"
        "AND FormId=${formId.plainValue()} AND MsgId NOT IN ($msgIds)";
        final path = await AppPathHelper().getUserDataDBFilePath();
        final db = DatabaseManager(path);
        String query = "SELECT ProjectId,AttachRevId,AttachFileName FROM ${FormMessageAttachAndAssocDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND FormId=$formId AND MsgId IN ($subQuery) AND AttachRevId<>''";
        await _removeAttachments(query);
        final tableList = [FormMessageActionDao.tableName, FormMessageAttachAndAssocDao.tableName, FormMessageDao.tableName];
        for (var tableName in tableList) {
          query = "DELETE FROM $tableName\n"
              "WHERE ProjectId=${projectId.plainValue()} AND FormId=$formId AND MsgId IN ($subQuery)";
          db.executeTableRequest(query);
        }
        db.executeTableRequest("VACUUM");
      }
    } on Exception catch (e) {
      Log.d("SiteFormListingLocalDataSource::removeFormMessagesFromDatabase exception=$e");
    }
  }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          