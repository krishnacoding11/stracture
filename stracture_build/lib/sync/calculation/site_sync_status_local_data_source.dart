import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_form_attachment_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_form_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_form_type_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_location_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_project_dao.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/model/sync/site/site_sync_form_vo.dart';
import 'package:field/data/model/sync/site/site_sync_project_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/data/model/sync/sync_status_data_vo.dart';
import 'package:field/data_source/base/base_local_data_source.dart';
import 'package:field/logger/logger.dart';
import 'package:field/sync/task/location_plan_sync_task.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

import '../../data/dao/location_dao.dart';
import '../../data/dao/project_dao.dart';
import '../../data/model/sync/site/site_sync_form_attachment_vo.dart';
import '../../data/model/sync/site/site_sync_form_type_vo.dart';
import '../../data/model/sync/site/site_sync_location_vo.dart';
import '../../database/dao.dart';

class SiteSyncStatusLocalDataSource extends BaseLocalDataSource {
  List<Dao> siteSyncDaoList = [SiteSyncStatusProjectDao(), SiteSyncStatusLocationDao(), SiteSyncStatusFormTypeDao(), SiteSyncStatusFormDao(), SiteSyncStatusFormAttachmentDao()];

  Future<void> insertProjectSyncData(List<Project> projectList, ESyncType eSyncType, ESyncStatus eSyncStatus) async {
    List<SiteSyncProjectVo> syncProjectList = [];
    for (var element in projectList) {
      SiteSyncProjectVo syncProjectVo = SiteSyncProjectVo();
      syncProjectVo.projectId = element.projectID.plainValue();
      syncProjectVo.newSyncTimeStamp = element.newSyncTimeStamp;
      if (eSyncStatus == ESyncStatus.failed) {
        syncProjectVo.eFormTypeListSyncStatus = ESyncStatus.failed;
        syncProjectVo.eFormListSyncStatus = ESyncStatus.failed;
        syncProjectVo.eManageTypeSyncStatus = ESyncStatus.failed;
        syncProjectVo.eFilterSyncStatus = ESyncStatus.failed;
        syncProjectVo.eStatusStyleSyncStatus = ESyncStatus.failed;
      } else {
        syncProjectVo.eFormTypeListSyncStatus = ESyncStatus.inProgress;
        syncProjectVo.eFormListSyncStatus = eSyncType == ESyncType.project ? ESyncStatus.inProgress : ESyncStatus.success;
        syncProjectVo.eManageTypeSyncStatus = ESyncStatus.inProgress;
        syncProjectVo.eFilterSyncStatus = ESyncStatus.inProgress;
        syncProjectVo.eStatusStyleSyncStatus = ESyncStatus.inProgress;
      }
      syncProjectVo.eSyncStatus = syncProjectVo.eFormListSyncStatus;
      syncProjectList.add(syncProjectVo);
    }
    List<Map<String, dynamic>> rowList = await SiteSyncStatusProjectDao().toListMap(syncProjectList);

    await databaseManager.executeDatabaseBulkOperations(SiteSyncStatusProjectDao.tableName, rowList, isNeedToUpdate: false);
  }

  Future<void> insertLocationSyncData(List<SiteLocation> locationList, ESyncType eSyncType, ESyncStatus eSyncStatus) async {
    List<SiteSyncLocationVo> syncLocationList = [];
    for (var element in locationList) {
      SiteSyncLocationVo syncLocationVo = SiteSyncLocationVo()
        ..projectId = element.projectId.plainValue()
        ..locationId = element.pfLocationTreeDetail?.locationId.toString()
        ..parentLocationId = element.pfLocationTreeDetail?.parentLocationId.toString()
        ..docId = element.pfLocationTreeDetail?.docId.plainValue()
        ..revisionId = element.pfLocationTreeDetail?.revisionId.plainValue()
        ..eFormListSyncStatus = !(element.isMarkOffline ?? true) ? ESyncStatus.success : ESyncStatus.inProgress
        ..eSyncStatus = eSyncStatus == ESyncStatus.failed ? ESyncStatus.failed : ESyncStatus.inProgress
        ..newSyncTimeStamp = element.newSyncTimeStamp;

      if (LocationPlanSyncTask.isLocationHasPlan(element)) {
        syncLocationVo.ePdfSyncStatus = eSyncStatus == ESyncStatus.failed ? ESyncStatus.failed : ESyncStatus.inProgress;
        syncLocationVo.eXfdfSyncStatus = eSyncStatus == ESyncStatus.failed ? ESyncStatus.failed : ESyncStatus.inProgress;
      } else {
        syncLocationVo.ePdfSyncStatus = ESyncStatus.success;
        syncLocationVo.eXfdfSyncStatus = ESyncStatus.success;
      }
      syncLocationList.add(syncLocationVo);
    }
    List<Map<String, dynamic>> rowList = await SiteSyncStatusLocationDao().toListMap(syncLocationList);
    await databaseManager.executeDatabaseBulkOperations(SiteSyncStatusLocationDao.tableName, rowList);
  }

  Future<void> insertFormSyncData(List<SiteForm> formList) async {
    List<SiteSyncFormVo> syncFormList = [];
    for (var element in formList) {
      SiteSyncFormVo syncFormVo = SiteSyncFormVo()
        ..projectId = element.projectId.plainValue()
        ..locationId = element.locationId.toString()
        ..formId = element.formId.plainValue()
        ..formTypeId = element.formTypeId.plainValue()
        ..eFormMsgListSyncStatus = ESyncStatus.inProgress
        ..eFormXSNHtmlViewSyncStatus = ESyncStatus.success
        ..eSyncStatus = ESyncStatus.inProgress;

      /// Comment this lines of code as we are not supporting XSN forms.
      /* if (element.templateType.isXSN) {
        syncFormVo.eFormXSNHtmlViewSyncStatus = ESyncStatus.inProgress;
      }*/
      syncFormList.add(syncFormVo);
    }
    Log.d("insertFormSyncData", "insertFormSyncData Start");
    List<Map<String, dynamic>> rowList = await SiteSyncStatusFormDao().toListMap(syncFormList);
    await databaseManager.executeDatabaseBulkOperations(SiteSyncStatusFormDao.tableName, rowList);
    Log.d("insertFormSyncData", "insertFormSyncData End");
  }

  Future<void> insertFormTypeData(List<AppType> appTypeList) async {
    List<SiteSyncFormTypeVo> syncAppTypeList = [];
    for (var element in appTypeList) {
      SiteSyncFormTypeVo syncFormVo = SiteSyncFormTypeVo()
        ..projectId = element.projectID.plainValue()
        ..formTypeId = element.formTypeID.plainValue()
        ..eTemplateDownloadSyncStatus = ESyncStatus.inProgress
        ..eDistributionListSyncStatus = ESyncStatus.inProgress
        ..eCustomAttributeListSyncStatus = ESyncStatus.inProgress
        ..eStatusListSyncStatus = ESyncStatus.inProgress
        ..eControllerUserListSyncStatus = ESyncStatus.inProgress
        ..eFixFieldListSyncStatus = ESyncStatus.inProgress;
      if (element.templateType.isXSN) {
        syncFormVo.eCustomAttributeListSyncStatus = ESyncStatus.success;
        syncFormVo.eStatusListSyncStatus = ESyncStatus.success;
        syncFormVo.eControllerUserListSyncStatus = ESyncStatus.success;
        syncFormVo.eFixFieldListSyncStatus = ESyncStatus.success;
        syncFormVo.eDistributionListSyncStatus = ESyncStatus.success;
      }
      syncAppTypeList.add(syncFormVo);
    }
    Log.d("insertFormTypeData", "insertFormTypeData Start");
    List<Map<String, dynamic>> rowList = await SiteSyncStatusFormTypeDao().toListMap(syncAppTypeList);
    await databaseManager.executeDatabaseBulkOperations(SiteSyncStatusFormTypeDao.tableName, rowList, isNeedToUpdate: false);
    Log.d("insertFormTypeData", "insertFormTypeData End");
  }

  Future<void> insertFormMessageAttachAndAssocData(List<FormMessageAttachAndAssocVO> formMessageAttachAndAssocList, ESyncStatus eSyncStatus) async {
    List<SiteSyncFormAttachmentVo> syncFormAttachmentList = [];
    for (var element in formMessageAttachAndAssocList) {
      if (!element.attachType.isNullOrEmpty() && EAttachmentAndAssociationType.fromNumber(int.parse(element.attachType!)) == EAttachmentAndAssociationType.attachments) {
        SiteSyncFormAttachmentVo syncFormVo = SiteSyncFormAttachmentVo()
          ..projectId = element.projectId.plainValue()
          ..formId = element.formId.plainValue()
          ..locationId = ""
          ..revisionId = element.attachRevId.plainValue()
          ..eSyncStatus = eSyncStatus;
        syncFormAttachmentList.add(syncFormVo);
      }
    }
    Log.d("insertFormMessageAttachAndAssocData", "FormMessageAttachAndAssocData Start");
    List<Map<String, dynamic>> rowList = await SiteSyncStatusFormAttachmentDao().toListMap(syncFormAttachmentList);
    await databaseManager.executeDatabaseBulkOperations(SiteSyncStatusFormAttachmentDao.tableName, rowList);
    Log.d("insertFormMessageAttachAndAssocData", "insertFormMessageAttachAndAssocData End");
  }

  void updateLocationPdfStatus({required String projectId, required String revisionId, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusLocationDao.tableName} SET ${SiteSyncStatusLocationDao.pdfSyncStatusField}=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ${SiteSyncStatusLocationDao.projectIdField}=${projectId.plainValue()}";
    strUpdateQuery = "$strUpdateQuery AND ${SiteSyncStatusLocationDao.revisionIdField}=${revisionId.plainValue()}";
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateLocationXFDFStatus({required String projectId, required String revisionId, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusLocationDao.tableName} SET ${SiteSyncStatusLocationDao.xfdfSyncStatusField}=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ${SiteSyncStatusLocationDao.projectIdField}=${projectId.plainValue()}";
    strUpdateQuery = "$strUpdateQuery AND ${SiteSyncStatusLocationDao.revisionIdField}=${revisionId.plainValue()}";
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateLocationFormListStatus({required String projectId, String locationId = "0", required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusLocationDao.tableName} SET ${SiteSyncStatusLocationDao.formListSyncStatusField}=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ${SiteSyncStatusLocationDao.projectIdField}=${projectId.plainValue()}";
    if (locationId != "0") {
      strUpdateQuery = "WITH CTE_ChildLocation AS (\n"
          "SELECT ProjectId,LocationId,ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName}\n"
          "WHERE ProjectId=${projectId.plainValue()} AND LocationId=${locationId.plainValue()}\n"
          "UNION\n"
          "SELECT locTbl.ProjectId,locTbl.LocationId,locTbl.ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName} locTbl\n"
          "INNER JOIN CTE_ChildLocation cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.LocationId=locTbl.ParentLocationId\n"
          ")\n"
          "UPDATE ${SiteSyncStatusLocationDao.tableName} SET FormListSyncStatus=${eSyncStatus.value}\n"
          "FROM (SELECT * FROM CTE_ChildLocation) AS newData\n"
          "WHERE ${SiteSyncStatusLocationDao.tableName}.ProjectId=newData.ProjectId AND ${SiteSyncStatusLocationDao.tableName}.LocationId=newData.LocationId";
    }
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateProjectFormListStatus({required String projectId, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusProjectDao.tableName} SET ${SiteSyncStatusProjectDao.formListSyncStatusField}=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ${SiteSyncStatusProjectDao.projectIdField}=${projectId.plainValue()}";
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateProjectFormTypeListSyncStatus({required String projectId, required ESyncStatus eSyncStatus}) {
    updateProjectFieldSyncStatus(projectId: projectId, fieldName: SiteSyncStatusProjectDao.formTypeListSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateProjectFieldSyncStatus({required String projectId, required String fieldName, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusProjectDao.tableName} SET $fieldName=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ${SiteSyncStatusProjectDao.projectIdField}=${projectId.plainValue()}";
    if (eSyncStatus == ESyncStatus.inProgress) {
      strUpdateQuery = "$strUpdateQuery\nAND $fieldName=${ESyncStatus.failed.value}";
    }
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateFormTypeTemplateDownloadSyncStatus({required String projectId, required String formTypeId, required ESyncStatus eSyncStatus}) {
    updateFormTypeFieldSyncStatus(projectId: projectId, formTypeId: formTypeId, fieldName: SiteSyncStatusFormTypeDao.templateDownloadSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateFormTypeCustomAttributeListSyncStatus({required String projectId, required String formTypeId, required ESyncStatus eSyncStatus}) {
    updateFormTypeFieldSyncStatus(projectId: projectId, formTypeId: formTypeId, fieldName: SiteSyncStatusFormTypeDao.customAttributeListSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateFormTypeDistributionListSyncStatus({required String projectId, required String formTypeId, required ESyncStatus eSyncStatus}) {
    updateFormTypeFieldSyncStatus(projectId: projectId, formTypeId: formTypeId, fieldName: SiteSyncStatusFormTypeDao.distributionListSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateFormTypeStatusListSyncStatus({required String projectId, required String formTypeId, required ESyncStatus eSyncStatus}) {
    updateFormTypeFieldSyncStatus(projectId: projectId, formTypeId: formTypeId, fieldName: SiteSyncStatusFormTypeDao.statusListSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateFormTypeControllerUserListSyncStatus({required String projectId, required String formTypeId, required ESyncStatus eSyncStatus}) {
    updateFormTypeFieldSyncStatus(projectId: projectId, formTypeId: formTypeId, fieldName: SiteSyncStatusFormTypeDao.controllerUserListSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateFormTypeFixFieldListSyncStatus({required String projectId, required String formTypeId, required ESyncStatus eSyncStatus}) {
    updateFormTypeFieldSyncStatus(projectId: projectId, formTypeId: formTypeId, fieldName: SiteSyncStatusFormTypeDao.fixFieldListSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateFormTypeFieldSyncStatus({required String projectId, required String formTypeId, required String fieldName, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusFormTypeDao.tableName} SET $fieldName=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ProjectId=${projectId.plainValue()} AND FormTypeId=${formTypeId.plainValue()}";
    if (eSyncStatus == ESyncStatus.inProgress) {
      strUpdateQuery = "$strUpdateQuery\nAND $fieldName=${ESyncStatus.failed.value}";
    }
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateBatchFormMsgListSyncData({required String projectId, required String formIds, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusFormDao.tableName} SET ${SiteSyncStatusFormDao.formMsgListSyncStatusField}=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ProjectId=${projectId.plainValue()}";
    strUpdateQuery = "$strUpdateQuery AND ${SiteSyncStatusFormDao.formIdField} IN ($formIds)";
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateFormXSNHtmlViewSyncData({required String projectId, required String locationId, required String formId, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusFormDao.tableName} SET ${SiteSyncStatusFormDao.formMsgListSyncStatusField}=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ${SiteSyncStatusFormDao.projectIdField}=${projectId.plainValue()}";
    strUpdateQuery = "$strUpdateQuery AND ${SiteSyncStatusFormDao.locationIdField}=${locationId.plainValue()}";
    strUpdateQuery = "$strUpdateQuery AND ${SiteSyncStatusFormDao.formIdField}=${formId.plainValue()}";
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateFormAttachmentBatchSyncData({required String projectId, required String revisionIds, required ESyncStatus eSyncStatus}) {
    String strUpdateQuery = "UPDATE ${SiteSyncStatusFormAttachmentDao.tableName} SET ${SiteSyncStatusFormAttachmentDao.syncStatusField}=${eSyncStatus.value}";
    strUpdateQuery = "$strUpdateQuery WHERE ${SiteSyncStatusFormAttachmentDao.projectIdField}=${projectId.plainValue()}";
    strUpdateQuery = "$strUpdateQuery AND ${SiteSyncStatusFormAttachmentDao.revisionIdField} IN ($revisionIds)";
    databaseManager.executeTableRequest(strUpdateQuery);
  }

  void updateProjectStatusStyleSyncStatus({required String projectId, required ESyncStatus eSyncStatus}) {
    updateProjectFieldSyncStatus(projectId: projectId, fieldName: SiteSyncStatusProjectDao.statusStyleSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateProjectManageTypeSyncStatus({required String projectId, required ESyncStatus eSyncStatus}) {
    updateProjectFieldSyncStatus(projectId: projectId, fieldName: SiteSyncStatusProjectDao.manageTypeSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void updateProjectFilterSyncStatus({required String projectId, required ESyncStatus eSyncStatus}) {
    updateProjectFieldSyncStatus(projectId: projectId, fieldName: SiteSyncStatusProjectDao.filterSyncStatusField, eSyncStatus: eSyncStatus);
  }

  void calculateSyncStatus(String projectId, {String locationId = "0"}) {
    try {
      const projectWeight = "10", formTypeWeight = "25", locationPlanWeight = "20", formWeight = "45", totalWeight = "100";

      String strInSyncStatus = ESyncStatus.inProgress.value.toString();
      String strNotSyncStatus = ESyncStatus.failed.value.toString();
      String strFullSyncStatus = ESyncStatus.success.value.toString();

      String baseQuery = "";
      if (locationId == "0" || locationId.isNullOrEmpty()) {
        baseQuery = "SELECT ${projectId.plainValue()},0,0\n"
            "UNION\n";
      }
      String strSyncFormUpdateQuery = "WITH CTE_ChildLocation(ProjectId,LocationId,ParentLocationId) AS (\n"
          "$baseQuery"
          "SELECT ProjectId,LocationId,ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName}\n"
          "WHERE ProjectId=${projectId.plainValue()} AND ${(locationId == "0" || locationId.isNullOrEmpty()) ? 'ParentLocationId=0' : 'LocationId IN (${locationId.plainValue()})'}\n"
          "UNION\n"
          "SELECT sl.ProjectId,sl.LocationId,sl.ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName} sl\n"
          "INNER JOIN CTE_ChildLocation cl ON sl.ProjectId=cl.ProjectId AND sl.ParentLocationId=cl.LocationId\n"
          "),\n"
          "CTE_ProjectSyncStatus(ProjectId,SyncStatus) AS (\n"
          "SELECT ProjectId,CASE WHEN (FilterSyncStatus=$strInSyncStatus OR StatusStyleSyncStatus=$strInSyncStatus OR ManageTypeSyncStatus=$strInSyncStatus OR FormTypeListSyncStatus=$strInSyncStatus) THEN $strInSyncStatus\n"
          "WHEN (FilterSyncStatus=$strNotSyncStatus OR StatusStyleSyncStatus=$strNotSyncStatus OR ManageTypeSyncStatus=$strNotSyncStatus OR FormTypeListSyncStatus=$strNotSyncStatus) THEN $strNotSyncStatus\n"
          "ELSE $strFullSyncStatus END AS SyncStatus FROM ${SiteSyncStatusProjectDao.tableName}\n"
          "WHERE ProjectId IN (SELECT ProjectId FROM CTE_ChildLocation)\n"
          "),\n"
          "CTE_FormTypeSyncStatus(ProjectId,FormTypeId,SyncStatus) AS (\n"
          "SELECT ProjectId,FormTypeId,CASE WHEN (TemplateDownloadSyncStatus=$strInSyncStatus OR DistributionListSyncStatus=$strInSyncStatus OR StatusListSyncStatus=$strInSyncStatus OR CustomAttributeListSyncStatus=$strInSyncStatus OR ControllerUserListSyncStatusSyncStatus=$strInSyncStatus OR FixFieldListSyncStatus=$strInSyncStatus) THEN $strInSyncStatus\n"
          "WHEN (TemplateDownloadSyncStatus=$strNotSyncStatus OR DistributionListSyncStatus=$strNotSyncStatus OR StatusListSyncStatus=$strNotSyncStatus OR CustomAttributeListSyncStatus=$strNotSyncStatus OR ControllerUserListSyncStatusSyncStatus=$strNotSyncStatus OR FixFieldListSyncStatus=$strNotSyncStatus) THEN $strNotSyncStatus ELSE $strFullSyncStatus END FROM ${SiteSyncStatusFormTypeDao.tableName}\n"
          "WHERE ProjectId IN (SELECT DISTINCT ProjectId FROM CTE_ChildLocation)\n"
          "),\n"
          "CTE_FormAttachmentSyncStatus(ProjectId,LocationId,FormId,CompletedCount,InProgressCount,FailedCount) AS (\n"
          "SELECT frmAttachTbl.ProjectId,frmTbl.LocationId,frmAttachTbl.FormId,SUM(IIF(frmAttachTbl.SyncStatus=$strFullSyncStatus,1,0)) AS CompletedCount,\n"
          "SUM(IIF(frmAttachTbl.SyncStatus=$strInSyncStatus,1,0)) AS InProgressCount,\n"
          "SUM(IIF(frmAttachTbl.SyncStatus=$strNotSyncStatus,1,0)) AS FailedCount FROM ${SiteSyncStatusFormAttachmentDao.tableName} frmAttachTbl\n"
          "INNER JOIN ${SiteSyncStatusFormDao.tableName} frmTbl ON frmTbl.ProjectId=frmAttachTbl.ProjectId AND frmTbl.FormId=frmAttachTbl.FormId\n"
          "INNER JOIN CTE_ChildLocation cteChldLoc ON cteChldLoc.ProjectId=frmTbl.ProjectId AND cteChldLoc.LocationId=frmTbl.LocationId\n"
          "GROUP BY frmAttachTbl.ProjectId,frmAttachTbl.LocationId,frmAttachTbl.FormId\n"
          "),\n"
          "CTE_FormSyncStatus AS (\n"
          "SELECT frmTbl.ProjectId,frmTbl.LocationId,frmTbl.FormId,CASE\n"
          "WHEN (frmTbl.FormMsgListSyncStatus=$strInSyncStatus OR frmTbl.FormXSNHtmlViewSyncStatus=$strInSyncStatus OR ctePrj.SyncStatus=$strInSyncStatus OR IFNULL(cteFrmTp.SyncStatus,$strNotSyncStatus)=$strInSyncStatus OR IFNULL(cteFrmAttach.InProgressCount,0)>0) THEN $strInSyncStatus\n"
          "WHEN (frmTbl.FormMsgListSyncStatus=$strNotSyncStatus OR frmTbl.FormXSNHtmlViewSyncStatus=$strNotSyncStatus OR ctePrj.SyncStatus=$strNotSyncStatus OR IFNULL(cteFrmTp.SyncStatus,$strNotSyncStatus)=$strNotSyncStatus OR IFNULL(cteFrmAttach.FailedCount,0)>0) THEN $strNotSyncStatus\n"
          "ELSE $strFullSyncStatus END AS SyncStatus FROM ${SiteSyncStatusFormDao.tableName} frmTbl\n"
          "INNER JOIN CTE_ChildLocation cteChldLoc ON cteChldLoc.ProjectId=frmTbl.ProjectId AND cteChldLoc.LocationId=frmTbl.LocationId\n"
          "INNER JOIN CTE_ProjectSyncStatus ctePrj ON ctePrj.ProjectId=frmTbl.ProjectId\n"
          "LEFT JOIN CTE_FormTypeSyncStatus cteFrmTp ON cteFrmTp.ProjectId=frmTbl.ProjectId AND cteFrmTp.FormTypeId=frmTbl.FormTypeId\n"
          "LEFT JOIN CTE_FormAttachmentSyncStatus cteFrmAttach ON cteFrmAttach.ProjectId=frmTbl.ProjectId AND cteFrmAttach.LocationId=frmTbl.LocationId AND cteFrmAttach.FormId=frmTbl.FormId\n"
          ")\n"
          "UPDATE ${SiteSyncStatusFormDao.tableName} SET SyncStatus=IFNULL(newFormData.SyncStatus,${SiteSyncStatusFormDao.tableName}.SyncStatus)\n"
          "FROM (SELECT * FROM CTE_FormSyncStatus) AS newFormData\n"
          "WHERE newFormData.ProjectId=${SiteSyncStatusFormDao.tableName}.ProjectId AND newFormData.LocationId=${SiteSyncStatusFormDao.tableName}.LocationId AND newFormData.FormId=${SiteSyncStatusFormDao.tableName}.FormId";
      databaseManager.executeTableRequest(strSyncFormUpdateQuery);

      String strSyncLocCalcQuery = "WITH CTE_ChildLocation(ProjectId,LocationId,ParentLocationId) AS (\n"
          "SELECT ProjectId,LocationId,ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName}\n"
          "WHERE ProjectId=${projectId.plainValue()} AND ${(locationId == "0" || locationId.isNullOrEmpty()) ? 'ParentLocationId=0' : 'LocationId IN (${locationId.plainValue()})'}\n"
          "UNION\n"
          "SELECT f.ProjectId,f.LocationId,f.ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName} f\n"
          "INNER JOIN CTE_ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=c.ProjectId\n"
          "),\n"
          "CTE_LocationFormSyncStatusCount(ProjectId,LocationId,CompletedCount,InProgressCount,FailedCount) AS (\n"
          "SELECT fs.ProjectId,fs.LocationId,SUM(IIF(fs.SyncStatus=$strFullSyncStatus,1,0)),SUM(IIF(fs.SyncStatus=$strInSyncStatus,1,0)),SUM(IIF(fs.SyncStatus=$strNotSyncStatus,1,0)) FROM ${SiteSyncStatusFormDao.tableName} fs\n"
          "INNER JOIN CTE_ChildLocation cl ON fs.LocationId=cl.LocationId AND fs.ProjectId=cl.ProjectId\n"
          "GROUP BY fs.ProjectId,fs.LocationId\n"
          "),\n"
          "CTE_LocationWithSubLocation(ProjectId,TopLocationId,LocationId,ParentLocationId) AS (\n"
          "SELECT ProjectId,LocationId,LocationId,ParentLocationId FROM CTE_ChildLocation\n"
          "UNION\n"
          "SELECT c.ProjectId,c.TopLocationId,f.LocationId,f.ParentLocationId FROM CTE_ChildLocation f\n"
          "INNER JOIN CTE_LocationWithSubLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=c.ProjectId\n"
          "),\n"
          "CTE_AllLocationFormSyncStatusCount(ProjectId,LocationId,CompletedCount,InProgressCount,FailedCount,TotalCount) AS (\n"
          "SELECT mainTbl.ProjectId,mainTbl.TopLocationId,SUM(IFNULL(jnTbl1.CompletedCount,0)),SUM(IFNULL(jnTbl1.InProgressCount,0)),SUM(IFNULL(jnTbl1.FailedCount,0)),SUM(IFNULL(jnTbl1.CompletedCount,0))+SUM(IFNULL(jnTbl1.InProgressCount,0))+SUM(IFNULL(jnTbl1.FailedCount,0)) FROM CTE_LocationWithSubLocation mainTbl\n"
          "LEFT JOIN CTE_LocationFormSyncStatusCount jnTbl1 ON jnTbl1.LocationId=mainTbl.LocationId AND jnTbl1.ProjectId=mainTbl.ProjectId\n"
          "GROUP BY mainTbl.ProjectId,mainTbl.TopLocationId\n"
          "),\n"
          "CTE_FormTypeSyncStatus(ProjectId,FormTypeId,SyncStatus) AS (\n"
          "SELECT ProjectId,FormTypeId,CASE WHEN (TemplateDownloadSyncStatus=$strInSyncStatus OR DistributionListSyncStatus=$strInSyncStatus OR StatusListSyncStatus=$strInSyncStatus OR CustomAttributeListSyncStatus=$strInSyncStatus) THEN $strInSyncStatus\n"
          "WHEN (TemplateDownloadSyncStatus=$strNotSyncStatus OR DistributionListSyncStatus=$strNotSyncStatus OR StatusListSyncStatus=$strNotSyncStatus OR CustomAttributeListSyncStatus=$strNotSyncStatus) THEN $strNotSyncStatus ELSE $strFullSyncStatus END FROM ${SiteSyncStatusFormTypeDao.tableName}\n"
          "WHERE ProjectId IN (SELECT DISTINCT ProjectId FROM CTE_ChildLocation)\n"
          "),\n"
          "CTE_ProjectFormTypeSyncStatusCount(ProjectId,CompletedCount,InProgressCount,FailedCount) AS (\n"
          "SELECT ProjectId,SUM(IIF(SyncStatus=$strFullSyncStatus,1,0)),SUM(IIF(SyncStatus=$strInSyncStatus,1,0)),SUM(IIF(SyncStatus=$strNotSyncStatus,1,0)) FROM CTE_FormTypeSyncStatus\n"
          "GROUP BY ProjectId\n"
          "),\n"
          "CTE_ProjectSyncStatus(ProjectId,FormTypeListSyncStatus,SyncStatus,TotalProjectSyncCount,CompletedProjectSyncCount,TotalFormTypeCount,CompletedFormTypeCount) AS (\n"
          "SELECT prjTbl.ProjectId,prjTbl.FormTypeListSyncStatus,CASE WHEN (prjTbl.FilterSyncStatus=$strInSyncStatus OR prjTbl.StatusStyleSyncStatus=$strInSyncStatus OR prjTbl.ManageTypeSyncStatus=$strInSyncStatus OR prjTbl.FormTypeListSyncStatus=$strInSyncStatus OR IFNULL(ctePrjTbl.InProgressCount,0)>0) THEN $strInSyncStatus\n"
          "WHEN (prjTbl.FilterSyncStatus=$strNotSyncStatus OR prjTbl.StatusStyleSyncStatus=$strNotSyncStatus OR prjTbl.ManageTypeSyncStatus=$strNotSyncStatus OR prjTbl.FormTypeListSyncStatus=$strNotSyncStatus OR IFNULL(ctePrjTbl.FailedCount,0)>0) THEN $strNotSyncStatus ELSE $strFullSyncStatus END AS SyncStatus,4 AS TotalProjectSyncCount,\n"
          "IIF(prjTbl.FilterSyncStatus<>$strInSyncStatus,1,0) + IIF(prjTbl.StatusStyleSyncStatus<>$strInSyncStatus,1,0) + IIF(prjTbl.ManageTypeSyncStatus<>$strInSyncStatus,1,0) + IIF(prjTbl.FormTypeListSyncStatus<>$strInSyncStatus,1,0) AS CompletedProjectSyncCount,\n"
          "IFNULL(ctePrjTbl.CompletedCount,0) + IFNULL(ctePrjTbl.InProgressCount,0) + IFNULL(ctePrjTbl.FailedCount,0) AS TotalFormTypeCount,\n"
          "IFNULL(ctePrjTbl.CompletedCount,0) + IFNULL(ctePrjTbl.FailedCount,0) AS CompletedFormTypeCount FROM ${SiteSyncStatusProjectDao.tableName} prjTbl\n"
          "LEFT JOIN CTE_ProjectFormTypeSyncStatusCount ctePrjTbl ON ctePrjTbl.ProjectId=prjTbl.ProjectId\n"
          "WHERE prjTbl.ProjectId IN (SELECT ProjectId FROM CTE_ChildLocation)\n"
          "),\n"
          "CTE_SyncLocationData AS (\n"
          "SELECT frmTbl.ProjectId,frmTbl.LocationId,CASE WHEN (frmTbl.PdfSyncStatus=$strInSyncStatus OR frmTbl.XfdfSyncStatus=$strInSyncStatus OR frmTbl.FormListSyncStatus=$strInSyncStatus OR pss.SyncStatus=$strInSyncStatus OR IFNULL(inCount.InProgressCount,0)>0) THEN $strInSyncStatus\n"
          "WHEN (frmTbl.PdfSyncStatus=$strNotSyncStatus OR frmTbl.XfdfSyncStatus=$strNotSyncStatus OR frmTbl.FormListSyncStatus=$strNotSyncStatus OR pss.SyncStatus=$strNotSyncStatus OR IFNULL(inCount.FailedCount,0)>0) THEN $strNotSyncStatus ELSE $strFullSyncStatus END AS SyncStatus,\n"
          "(pss.CompletedProjectSyncCount*100/pss.TotalProjectSyncCount) AS ProjectSyncProgress,"
          "CASE WHEN pss.TotalFormTypeCount>0 THEN (pss.CompletedFormTypeCount*100/pss.TotalFormTypeCount) WHEN pss.FormTypeListSyncStatus=$strInSyncStatus THEN 0 ELSE 100 END AS ProjectFormTypeSyncProgress,"
          "(IIF(frmTbl.PdfSyncStatus=$strInSyncStatus,0,1)+IIF(frmTbl.XfdfSyncStatus=$strInSyncStatus,0,1))*100/2 AS PlanSyncProgress,\n"
          "IIF(frmTbl.FormListSyncStatus=$strInSyncStatus,0,IFNULL((IFNULL(inCount.TotalCount,0)-IFNULL(inCount.InProgressCount,0))*100/IFNULL(inCount.TotalCount,0),100)) AS LocationSyncProgress FROM ${SiteSyncStatusLocationDao.tableName} frmTbl\n"
          "INNER JOIN CTE_ProjectSyncStatus pss ON pss.ProjectId=frmTbl.ProjectId\n"
          "INNER JOIN CTE_ChildLocation ch ON ch.LocationId=frmTbl.LocationId AND ch.ProjectId=frmTbl.ProjectId\n"
          "LEFT JOIN CTE_AllLocationFormSyncStatusCount inCount ON inCount.LocationId=frmTbl.LocationId AND inCount.ProjectId=frmTbl.ProjectId\n"
          ")\n"
          "UPDATE ${SiteSyncStatusLocationDao.tableName} SET SyncStatus=IFNULL(newLocData.SyncStatus,${SiteSyncStatusLocationDao.tableName}.SyncStatus),\n"
          "SyncProgress=IFNULL(ROUND((newLocData.ProjectSyncProgress*$projectWeight+newLocData.ProjectFormTypeSyncProgress*$formTypeWeight+newLocData.LocationSyncProgress*$formWeight+newLocData.PlanSyncProgress*$locationPlanWeight)/$totalWeight,2),${SiteSyncStatusLocationDao.tableName}.SyncProgress)\n"
          "FROM (SELECT * FROM CTE_SyncLocationData) AS newLocData\n"
          "WHERE newLocData.ProjectId=${SiteSyncStatusLocationDao.tableName}.ProjectId AND newLocData.LocationId=${SiteSyncStatusLocationDao.tableName}.LocationId\n"
          "AND ${SiteSyncStatusLocationDao.tableName}.LocationId IN (SELECT LocationId FROM CTE_ChildLocation)";
      databaseManager.executeTableRequest(strSyncLocCalcQuery);

      // Update Main Location Table Sync Status
      String strQuery = "WITH CTE_ChildLocation AS (\n"
          "SELECT * FROM ${SiteSyncStatusLocationDao.tableName}\n"
          "WHERE ProjectId=$projectId AND ParentLocationId=0\n"
          "UNION\n"
          "SELECT f.* FROM ${SiteSyncStatusLocationDao.tableName} f\n"
          "INNER JOIN CTE_ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=c.ProjectId\n"
          ")\n"
          "UPDATE ${LocationDao.tableName} SET SyncStatus=(IIF(newLocTbl.SyncStatus=$strInSyncStatus,$strNotSyncStatus,newLocTbl.SyncStatus))\n"
          //if (bIsMediaFileDownload) {
          ",LastSyncTimeStamp=(IIF(newLocTbl.SyncStatus=$strFullSyncStatus AND ${LocationDao.tableName}.CanRemoveOffline=1,newLocTbl.NewSyncTimeStamp,${LocationDao.tableName}.LastSyncTimeStamp))\n"
          //}
          "FROM (SELECT * FROM CTE_ChildLocation) AS newLocTbl\n"
          "WHERE ${LocationDao.tableName}.ProjectId=newLocTbl.ProjectId AND ${LocationDao.tableName}.LocationId=newLocTbl.LocationId";
      databaseManager.executeTableRequest(strQuery);

      strQuery = "WITH CTE_ChildLocation(ProjectId,LocationId,ParentLocationId) AS (\n"
          "$baseQuery"
          "SELECT ProjectId,LocationId,ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName}\n"
          "WHERE ProjectId=${projectId.plainValue()} AND ${(locationId == "0" || locationId.isNullOrEmpty()) ? 'ParentLocationId=0' : 'LocationId IN (${locationId.plainValue()})'}\n"
          "UNION\n"
          "SELECT f.ProjectId,f.LocationId,f.ParentLocationId FROM ${SiteSyncStatusLocationDao.tableName} f\n"
          "INNER JOIN CTE_ChildLocation c ON f.ParentLocationId=c.LocationId AND f.LocationId<>c.LocationId AND f.ProjectId=c.ProjectId\n"
          "),\n"
          "CTE_FormSyncStatus(ProjectId,LocationId,FormId,SyncStatus) AS (\n"
          "SELECT fs.ProjectId,fs.LocationId,fs.FormId,fs.SyncStatus FROM ${SiteSyncStatusFormDao.tableName} fs\n"
          "INNER JOIN CTE_ChildLocation cl ON fs.LocationId=cl.LocationId AND fs.ProjectId=cl.ProjectId\n"
          "WHERE fs.SyncStatus<>$strInSyncStatus\n"
          ")\n"
          "UPDATE ${FormDao.tableName} SET SyncStatus=IFNULL(newFormData.SyncStatus,${FormDao.tableName}.SyncStatus)\n"
          "FROM (SELECT * FROM CTE_FormSyncStatus) AS newFormData\n"
          "WHERE ${FormDao.tableName}.ProjectId=newFormData.ProjectId AND ${FormDao.tableName}.LocationId=newFormData.LocationId AND ${FormDao.tableName}.FormId=newFormData.FormId";
      databaseManager.executeTableRequest(strQuery);

      if (baseQuery.isNotEmpty) {
        //project level sync
        strQuery = "WITH CTE_FormTypeSyncStatus(ProjectId,FormTypeId,SyncStatus) AS (\n"
            "SELECT ProjectId,FormTypeId,CASE WHEN (TemplateDownloadSyncStatus=$strInSyncStatus OR DistributionListSyncStatus=$strInSyncStatus OR StatusListSyncStatus=$strInSyncStatus OR CustomAttributeListSyncStatus=$strInSyncStatus) THEN $strInSyncStatus\n"
            "WHEN (TemplateDownloadSyncStatus=$strNotSyncStatus OR DistributionListSyncStatus=$strNotSyncStatus OR StatusListSyncStatus=$strNotSyncStatus OR CustomAttributeListSyncStatus=$strNotSyncStatus) THEN $strNotSyncStatus ELSE $strFullSyncStatus END FROM ${SiteSyncStatusFormTypeDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()}\n"
            "),\n"
            "CTE_ProjectFormTypeSyncStatusCount(ProjectId,SuccessCount,InProgressCount,FailedCount) AS (\n"
            "SELECT ProjectId,SUM(IIF(SyncStatus=$strFullSyncStatus,1,0)),SUM(IIF(SyncStatus=$strInSyncStatus,1,0)),SUM(IIF(SyncStatus=$strNotSyncStatus,1,0)) FROM CTE_FormTypeSyncStatus\n"
            "WHERE ProjectId=${projectId.plainValue()}\n"
            "GROUP BY ProjectId\n"
            "),\n"
            "CTE_ProjectFormSyncStatusCount(ProjectId,SuccessCount,InProgressCount,FailedCount) AS (\n"
            "SELECT ProjectId,SUM(IIF(SyncStatus=$strFullSyncStatus,1,0)),SUM(IIF(SyncStatus=$strInSyncStatus,1,0)),SUM(IIF(SyncStatus=$strNotSyncStatus,1,0)) FROM ${SiteSyncStatusFormDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND LocationId=0\n"
            "),\n"
            "CTE_ProjectLocationSyncStatusCount(ProjectId,SuccessCount,InProgressCount,FailedCount,LocationSyncProgress) AS (\n"
            "SELECT ProjectId,SUM(IIF(SyncStatus=$strFullSyncStatus,1,0)),SUM(IIF(SyncStatus=$strInSyncStatus,1,0)),SUM(IIF(SyncStatus=$strNotSyncStatus,1,0)),ROUND(AVG(IFNULL(SyncProgress,100)),2) FROM ${SiteSyncStatusLocationDao.tableName}\n"
            "WHERE ProjectId=${projectId.plainValue()} AND ParentLocationId=0\n"
            "),\n"
            "CTE_ProjectSyncStatus(ProjectId,FormTypeListSyncStatus,FormListSyncStatus,SyncStatus,TotalProjectSyncCount,CompletedProjectSyncCount,TotalFormTypeCount,CompletedFormTypeCount,TotalProjectFormCount,CompletedProjectFormCount,LocationSyncProgress) AS (\n"
            "SELECT prjTbl.ProjectId,prjTbl.FormTypeListSyncStatus,prjTbl.FormListSyncStatus,CASE WHEN (prjTbl.FilterSyncStatus=$strInSyncStatus OR prjTbl.StatusStyleSyncStatus=$strInSyncStatus OR prjTbl.ManageTypeSyncStatus=$strInSyncStatus OR prjTbl.FormTypeListSyncStatus=$strInSyncStatus OR IFNULL(ctePrjTbl.InProgressCount,0)>0 OR IFNULL(cteFrmTbl.InProgressCount,0)>0 OR IFNULL(cteLocTbl.InProgressCount,0)>0) THEN $strInSyncStatus\n"
            "WHEN (prjTbl.FilterSyncStatus=$strNotSyncStatus OR prjTbl.StatusStyleSyncStatus=$strNotSyncStatus OR prjTbl.ManageTypeSyncStatus=$strNotSyncStatus OR prjTbl.FormTypeListSyncStatus=$strNotSyncStatus OR IFNULL(ctePrjTbl.FailedCount,0)>0 OR IFNULL(cteFrmTbl.FailedCount,0)>0 OR IFNULL(cteLocTbl.FailedCount,0)>0) THEN $strNotSyncStatus ELSE $strFullSyncStatus END AS SyncStatus,4 AS TotalProjectSyncCount,\n"
            "IIF(prjTbl.FilterSyncStatus<>$strInSyncStatus,1,0) + IIF(prjTbl.StatusStyleSyncStatus<>$strInSyncStatus,1,0) + IIF(prjTbl.ManageTypeSyncStatus<>$strInSyncStatus,1,0) + IIF(prjTbl.FormTypeListSyncStatus<>$strInSyncStatus,1,0) AS CompletedProjectSyncCount,\n"
            "IFNULL(ctePrjTbl.SuccessCount,0) + IFNULL(ctePrjTbl.InProgressCount,0) + IFNULL(ctePrjTbl.FailedCount,0) AS TotalFormTypeCount,\n"
            "IFNULL(ctePrjTbl.SuccessCount,0) + IFNULL(ctePrjTbl.FailedCount,0) AS CompletedFormTypeCount,\n"
            "IFNULL(cteFrmTbl.SuccessCount,0) + IFNULL(cteFrmTbl.InProgressCount,0) + IFNULL(cteFrmTbl.FailedCount,0) AS TotalProjectFormCount,\n"
            "IFNULL(cteFrmTbl.SuccessCount,0) + IFNULL(cteFrmTbl.FailedCount,0) AS CompletedProjectFormCount,"
            "IFNULL(cteLocTbl.LocationSyncProgress,100) AS LocationSyncProgress FROM ${SiteSyncStatusProjectDao.tableName} prjTbl\n"
            "LEFT JOIN CTE_ProjectFormTypeSyncStatusCount ctePrjTbl ON ctePrjTbl.ProjectId=prjTbl.ProjectId\n"
            "LEFT JOIN CTE_ProjectFormSyncStatusCount cteFrmTbl ON cteFrmTbl.ProjectId=prjTbl.ProjectId\n"
            "LEFT JOIN CTE_ProjectLocationSyncStatusCount cteLocTbl ON cteLocTbl.ProjectId=prjTbl.ProjectId\n"
            "WHERE prjTbl.ProjectId=${projectId.plainValue()}\n"
            ")\n"
            "UPDATE ${SiteSyncStatusProjectDao.tableName} SET SyncStatus=IFNULL(newPrjTbl.SyncStatus,${SiteSyncStatusProjectDao.tableName}.SyncStatus),\n"
            "SyncProgress=IFNULL(ROUND(newPrjTbl.SyncProgress,2),${SiteSyncStatusProjectDao.tableName}.SyncProgress)\n"
            "FROM (SELECT ProjectId, SyncStatus,(\n"
            "(CompletedProjectSyncCount*100/TotalProjectSyncCount)*$projectWeight +\n"
            "CASE WHEN TotalFormTypeCount>0 THEN (CompletedFormTypeCount*100/TotalFormTypeCount) WHEN FormTypeListSyncStatus=$strInSyncStatus THEN 0 ELSE 100 END * $formTypeWeight +\n"
            "CASE WHEN TotalProjectFormCount>0 THEN (CompletedProjectFormCount*100/TotalProjectFormCount) WHEN FormListSyncStatus=$strInSyncStatus THEN 0 ELSE 100 END * $formWeight +\n"
            "LocationSyncProgress * $locationPlanWeight)/$totalWeight AS SyncProgress \n"
            "FROM CTE_ProjectSyncStatus\n"
            ") AS newPrjTbl\n"
            "WHERE ${SiteSyncStatusProjectDao.tableName}.ProjectId=newPrjTbl.ProjectId";
        databaseManager.executeTableRequest(strQuery);

        strQuery = "UPDATE ${ProjectDao.tableName} SET SyncStatus=(IIF(newData.SyncStatus=$strInSyncStatus,$strNotSyncStatus,newData.SyncStatus)),\n"
            //if (bIsMediaFileDownload) {
            "LastSyncTimeStamp=IIF((newData.SyncStatus=$strFullSyncStatus AND ${ProjectDao.tableName}.CanRemoveOffline=1),newData.NewSyncTimeStamp,${ProjectDao.tableName}.LastSyncTimeStamp)\n"
            //}
            "FROM (SELECT * FROM ${SiteSyncStatusProjectDao.tableName}) AS newData\n"
            "WHERE ${ProjectDao.tableName}.ProjectId=newData.ProjectId AND ${ProjectDao.tableName}.ProjectId=${projectId.plainValue()}";
        databaseManager.executeTableRequest(strQuery);
      }
    } catch (e) {
      Log.d("SiteSyncStatusManager::", "calculateSyncStatus default::exception");
    }
  }

  Map syncStatusResultMap(SiteSyncRequestTask siteSyncRequestTask) {
    String projectId = siteSyncRequestTask.projectId.plainValue() ?? "0";
    String? locationIds = siteSyncRequestTask.syncRequestLocationList?.map((e) => e.locationId.plainValue()).toList().join(', ');
    calculateSyncStatus(projectId, locationId: locationIds ?? "0");

    Map mapSyncData = <String, dynamic>{};

    mapSyncData['syncRequest'] = siteSyncRequestTask;

    String strChildLocationQuery = "WITH ChildLocation(ProjectId,ParentLocationId,LocationId) AS (\n"
        "SELECT ProjectId,ParentLocationId,LocationId FROM ${SiteSyncStatusLocationDao.tableName} \n"
        "WHERE ProjectId=$projectId AND ${(locationIds.isNullOrEmpty() || locationIds == "0") ? "ParentLocationId=0" : "LocationId IN ($locationIds)"}\n"
        "UNION\n"
        "SELECT f.ProjectId,f.ParentLocationId,f.LocationId FROM ${SiteSyncStatusLocationDao.tableName} f\n"
        "INNER JOIN ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=C.ProjectId\n"
        ")";

    /* //Form Sync Status
    String strFormQuery = "$strChildLocationQuery SELECT ProjectId,LocationId,FormId,SyncStatus FROM ";
    strFormQuery = "$strFormQuery  ${SiteSyncStatusFormDao.tableName}  WHERE ProjectId=${projectId.plainValue()}  AND LocationId IN (SELECT DISTINCT LocationId FROM ChildLocation)";
    var resultFormData = databaseManager.executeSelectFromTable(SiteSyncStatusFormDao.tableName, strFormQuery);
    if (resultFormData.isNotEmpty) {
      List<SiteSyncStatusDataVo> syncStatusFormList = SiteSyncStatusDataVo().toList(resultFormData);
      mapSyncData["syncFormData"] = syncStatusFormList;
    }*/

    //Location Sync Status.
    String strLocationQuery = "$strChildLocationQuery \n"
        "SELECT f.ProjectId,f.LocationId,f.SyncStatus,f.SyncProgress From ${SiteSyncStatusLocationDao.tableName} f\n"
        "INNER JOIN ChildLocation c ON f.LocationId=c.LocationId AND f.ProjectId=C.ProjectId";

    var resultLocationData = databaseManager.executeSelectFromTable(SiteSyncStatusLocationDao.tableName, strLocationQuery);
    if (resultLocationData.isNotEmpty) {
      List<SiteSyncStatusDataVo> syncStatusLocationList = SiteSyncStatusDataVo().toList(resultLocationData);
      mapSyncData["syncLocationData"] = syncStatusLocationList;
    }

    //Project Level Progress
    if (siteSyncRequestTask.eSyncType == ESyncType.project) {
      String strProjectProgressQuery = "SELECT ProjectId,SyncStatus,SyncProgress FROM ${SiteSyncStatusProjectDao.tableName}\n"
          "WHERE ProjectId=$projectId";
      var resultProjectData = databaseManager.executeSelectFromTable(SiteSyncStatusProjectDao.tableName, strProjectProgressQuery);
      if (resultProjectData.isNotEmpty) {
        SiteSyncStatusDataVo syncStatusProjectVo = SiteSyncStatusDataVo.fromJson(resultProjectData[0]);
        mapSyncData["syncProjectData"] = syncStatusProjectVo;
      }
    }

    return mapSyncData;
  }

  Future<void> syncCallback(ESyncTaskType eSyncTaskType, ESyncStatus eSyncStatus, SiteSyncRequestTask siteSyncRequestTask, dynamic data) async {
    try {
      switch (eSyncTaskType) {
        case ESyncTaskType.projectAndLocationSyncTask:
          if (data is Map && data.isNotEmpty) {
            await insertProjectSyncData(data["projectList"], siteSyncRequestTask.eSyncType!, eSyncStatus);
            await insertLocationSyncData(data["siteLocationList"], siteSyncRequestTask.eSyncType!, eSyncStatus);
          }
          break;
        case ESyncTaskType.filterSyncTask:
          String projectId = data["projectId"];
          updateProjectFilterSyncStatus(projectId: projectId, eSyncStatus: eSyncStatus);
          break;
        case ESyncTaskType.locationPlanSyncTask:
          if (data is Map && data.isNotEmpty) {
            if (data["isXfdf"]) {
              updateLocationXFDFStatus(projectId: data["projectId"], revisionId: data["revisionId"], eSyncStatus: eSyncStatus);
            } else {
              updateLocationPdfStatus(projectId: data["projectId"], revisionId: data["revisionId"], eSyncStatus: eSyncStatus);
            }
          }
          break;
        case ESyncTaskType.formListSyncTask:
          if (data is Map && data.isNotEmpty) {
            String projectId = data["projectId"];
            String locationId = !data["locationId"].toString().isNullOrEmpty() ? data["locationId"] : "0";
            if (eSyncStatus == ESyncStatus.inProgress) {
              if (data.containsKey('formList')) {
                await insertFormSyncData(data["formList"]);
              }
            } else if (eSyncStatus == ESyncStatus.success) {
              if (siteSyncRequestTask.eSyncType == ESyncType.project) {
                updateProjectFormListStatus(projectId: projectId, eSyncStatus: ESyncStatus.success);
                updateLocationFormListStatus(projectId: projectId, locationId: locationId, eSyncStatus: ESyncStatus.success);
              } else {
                updateLocationFormListStatus(projectId: projectId, locationId: locationId, eSyncStatus: ESyncStatus.success);
              }
            } else {
              if (siteSyncRequestTask.eSyncType == ESyncType.project) {
                updateProjectFormListStatus(projectId: projectId, eSyncStatus: ESyncStatus.failed);
                updateLocationFormListStatus(projectId: projectId, locationId: locationId, eSyncStatus: ESyncStatus.failed);
              } else {
                updateLocationFormListStatus(projectId: projectId, locationId: locationId, eSyncStatus: ESyncStatus.failed);
              }
            }
          }
          break;
        case ESyncTaskType.formMessageBatchListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateBatchFormMsgListSyncData(projectId: data["projectId"], formIds: data["formIds"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.formTypeListSyncTask:
          if (data is Map && data.isNotEmpty) {
            if (data.containsKey("appTypeList")) {
              await insertFormTypeData(data["appTypeList"]);
            } else {
              updateProjectFormTypeListSyncStatus(projectId: data["projectId"], eSyncStatus: eSyncStatus);
            }
          }
          break;
        case ESyncTaskType.formTypeTemplateDownloadSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateFormTypeTemplateDownloadSyncStatus(projectId: data["projectId"], formTypeId: data["formTypeId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.formTypeDistributionListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateFormTypeDistributionListSyncStatus(projectId: data["projectId"], formTypeId: data["formTypeId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.formTypeControllerUserListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateFormTypeControllerUserListSyncStatus(projectId: data["projectId"], formTypeId: data["formTypeId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.formTypeFixFieldListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateFormTypeFixFieldListSyncStatus(projectId: data["projectId"], formTypeId: data["formTypeId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.formTypeStatusListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateFormTypeStatusListSyncStatus(projectId: data["projectId"], formTypeId: data["formTypeId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.formTypeCustomAttributeListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateFormTypeCustomAttributeListSyncStatus(projectId: data["projectId"], formTypeId: data["formTypeId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.formAttachmentDownloadBatchSyncTask:
          if (data is Map && data.isNotEmpty) {
            if (data.containsKey("attachmentList")) {
              await insertFormMessageAttachAndAssocData(data["attachmentList"], eSyncStatus);
            } else {
              updateFormAttachmentBatchSyncData(projectId: data["projectId"], revisionIds: data["revisionIds"], eSyncStatus: eSyncStatus);
            }
          }
          break;
        case ESyncTaskType.statusStyleListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateProjectStatusStyleSyncStatus(projectId: data["projectId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.manageTypeListSyncTask:
          if (data is Map && data.isNotEmpty) {
            updateProjectManageTypeSyncStatus(projectId: data["projectId"], eSyncStatus: eSyncStatus);
          }
          break;
        case ESyncTaskType.columnHeaderListSyncTask:
          break;
        case ESyncTaskType.formTypeAttributeSetDetailSyncTask:
          break;
        case ESyncTaskType.createOrRespondFormSyncTask:
          break;
        case ESyncTaskType.distributionFormActionSyncTask:
          break;
        case ESyncTaskType.otherActionSyncTask:
          break;
        case ESyncTaskType.formStatusChangeTask:
          break;
        case ESyncTaskType.manageHomePageConfigurationTask:
          break;
      }
      Log.d("[SITE_SYNC_STATUS] ${eSyncStatus.value.toString()} ${eSyncTaskType.value.toString()}=$data");
    } catch (e) {
      Log.e("SiteSyncStatusLocalDataSource::syncCallback $e");
    }
  }

  Future<void> removeSyncRequestData(SiteSyncRequestTask siteSyncRequestTask) async {
    try {
      if (siteSyncRequestTask.eSyncType == ESyncType.siteLocation) {
        String strProjectId = siteSyncRequestTask.projectId.plainValue();
        String locationIds = siteSyncRequestTask.syncRequestLocationList?.map((e) => e.locationId).toList().join(',') ?? "";

        String strChildLocationQuery = "WITH ChildLocation(ProjectId,ParentLocationId,LocationId) AS (\n"
            "SELECT ProjectId,ParentLocationId,LocationId FROM ${SiteSyncStatusLocationDao.tableName} \n"
            "WHERE ProjectId=$strProjectId AND ${(locationIds.isNullOrEmpty() || locationIds == "0") ? "ParentLocationId=0" : "LocationId IN ($locationIds)"}\n"
            "UNION\n"
            "SELECT f.ProjectId,f.ParentLocationId,f.LocationId FROM ${SiteSyncStatusLocationDao.tableName} f\n"
            "INNER JOIN ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=C.ProjectId\n"
            ")";

        String strFormAttachRequestQuery = strChildLocationQuery +
            " DELETE FROM ${SiteSyncStatusFormAttachmentDao.tableName} WHERE FormId IN (\n"
                "SELECT FormId FROM ${SiteSyncStatusFormDao.tableName} frmTbl\n"
                "INNER JOIN ChildLocation cteLoc ON frmTbl.ProjectId=cteLoc.ProjectId AND frmTbl.LocationId=cteLoc.LocationId\n"
                ")";
        databaseManager.executeTableRequest(strFormAttachRequestQuery);

        String strFormQuery = strChildLocationQuery + " DELETE FROM ${SiteSyncStatusFormDao.tableName}";
        strFormQuery = strFormQuery + " WHERE ProjectId=" + strProjectId + " AND LocationId IN (SELECT LocationId FROM ChildLocation)";
        databaseManager.executeTableRequest(strFormQuery);

        String strQuery = strChildLocationQuery + " DELETE FROM ${SiteSyncStatusLocationDao.tableName}";
        strQuery = strQuery + " WHERE ProjectId=" + strProjectId + " AND LocationId IN (SELECT LocationId FROM ChildLocation)";
        databaseManager.executeTableRequest(strQuery);
      } else if (siteSyncRequestTask.eSyncType == ESyncType.project) {
        removeTables(siteSyncDaoList);
        createTables(siteSyncDaoList);
      }
    } catch (e) {
      Log.e("SiteSyncStatusLocalDataSource::removeSyncRequestData $e");
    }
  }
}
