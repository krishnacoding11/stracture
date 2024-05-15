import 'dart:async';
import 'dart:convert';

import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';
import 'package:field/utils/utils.dart';

import '../../data/dao/form_dao.dart';
import '../../data/model/sync/sync_request_task.dart';

class FormAttachmentDownloadBatchSyncTask extends BaseSyncTask {
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();

  FormAttachmentDownloadBatchSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> syncFormAttachmentDataInBatch() async {
    await _getFormAttachmentDataInBatchFromServer();
  }

  Future<void> _getFormAttachmentDataInBatchFromServer() async {
    try {
      List<FormMessageAttachAndAssocVO> attachmentDownloadListFromDB = await getListOfAllAttachmentFromDB();
      if (attachmentDownloadListFromDB.isNotEmpty) {
        if (!(syncRequestTask.projectId ?? "").isHashValue()) {
          Map<String, dynamic> paramDataNode = {};
          paramDataNode["fieldValueJson"] = jsonEncode([{"projectId":syncRequestTask.projectId.plainValue()}]);
          Result result = await _projectListUseCase.getHashedValueFromServer(paramDataNode);
          if (result is SUCCESS) {
            final respJson = jsonDecode(result.data);
            syncRequestTask.projectId = (respJson[0]["projectId"]).toString();
          }
        }
        if (syncRequestTask.projectId.isHashValue()) {
          await passDataToSyncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.inProgress, {"attachmentList": attachmentDownloadListFromDB});
          await processAttachmentDownloadList(attachmentDownloadListFromDB);
        } else {
          await passDataToSyncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.failed, {"attachmentList": attachmentDownloadListFromDB});
        }
      }
    } catch (e, stacktrace) {
      Log.d("_getFormAttachmentDataInBatchFromServer exception $e");
      Log.d("_getFormAttachmentDataInBatchFromServer exception $stacktrace");
    }
  }

  Future<Map<String, dynamic>> _getRequestMapData(List<FormMessageAttachAndAssocVO> listFormMessageAttachAndAssocVO) async {
    String strProjectId = syncRequestTask.projectId.toString();
    String strRevisionIds = "";
    for (var formMessageAttachAndAssocVO in listFormMessageAttachAndAssocVO) {
      if (strRevisionIds != "") {
        strRevisionIds = "$strRevisionIds,";
      }
      strRevisionIds = strRevisionIds + formMessageAttachAndAssocVO.attachRevId.plainValue();
    }
    Map<String, dynamic> pParamDataNode = {};
    if (strProjectId.isNotEmpty && strRevisionIds.isNotEmpty) {
      Map<String, dynamic> pAttachParamDataNode = {};
      pAttachParamDataNode["projectId"] = strProjectId;
      pAttachParamDataNode["revisionIds"] = strRevisionIds;
      pParamDataNode["EnableCompression"] = "true";
      pParamDataNode["attachmentDetails"] = jsonEncode(pAttachParamDataNode);
    }
    return pParamDataNode;
  }

  Future<List<FormMessageAttachAndAssocVO>> getListOfAllAttachmentFromDB() async {
    List<FormMessageAttachAndAssocVO> tmpListOfFormMessageAttachment = [];
    FormMessageAttachAndAssocDao formMessageAttachAndAssocDao = FormMessageAttachAndAssocDao();
    String query = "";
    if (syncRequestTask is SiteSyncRequestTask) {
      SiteSyncRequestTask siteSyncRequestTask = syncRequestTask as SiteSyncRequestTask;
      if (siteSyncRequestTask.eSyncType == ESyncType.project) {
        query = "SELECT attachTbl.* FROM ${FormMessageAttachAndAssocDao.tableName} attachTbl\n"
            "INNER JOIN ${FormDao.tableName} frmTbl ON frmTbl.${FormDao.projectIdField}=attachTbl.${FormMessageAttachAndAssocDao.projectIdField} AND frmTbl.${FormDao.formIdField}=attachTbl.${FormMessageAttachAndAssocDao.formIdField} AND frmTbl.${FormDao.isCloseOutField}=0\n"
            "WHERE attachTbl.${FormMessageAttachAndAssocDao.attachmentTypeField} IN (${EAttachmentAndAssociationType.files.value}, ${EAttachmentAndAssociationType.attachments.value}) AND attachTbl.${FormMessageAttachAndAssocDao.projectIdField}=${siteSyncRequestTask.projectId?.plainValue()}\n"
            "ORDER BY CAST(IIF(${FormMessageAttachAndAssocDao.attachSizeField}='','0',${FormMessageAttachAndAssocDao.attachSizeField}) AS INT) DESC";
      } else if (siteSyncRequestTask.eSyncType == ESyncType.siteLocation) {
        String projectId = siteSyncRequestTask.projectId?.plainValue() ?? "";
        String locationIds = siteSyncRequestTask.syncRequestLocationList?.map((e) => e.locationId).toList().join(',') ?? "";
        query = "WITH ChildLocation AS (\n"
            "SELECT * FROM ${LocationDao.tableName}\n"
            "WHERE ${LocationDao.projectIdField}=$projectId AND ${LocationDao.locationIdField} IN ($locationIds)\n"
            "UNION\n"
            "SELECT locTbl.* FROM ${LocationDao.tableName} locTbl\n"
            "INNER JOIN ChildLocation cteLoc ON cteLoc.${LocationDao.projectIdField}=locTbl.${LocationDao.projectIdField} AND cteLoc.${LocationDao.locationIdField}=locTbl.${LocationDao.parentLocationIdField}\n"
            ")\n"
            "SELECT attachTbl.* FROM ${FormMessageAttachAndAssocDao.tableName} attachTbl\n"
            "INNER JOIN ${FormDao.tableName} frmTbl ON frmTbl.${FormDao.projectIdField}=attachTbl.${FormMessageAttachAndAssocDao.projectIdField} AND frmTbl.${FormDao.formIdField}=attachTbl.${FormMessageAttachAndAssocDao.formIdField} AND frmTbl.${FormDao.isCloseOutField}=0\n"
            "INNER JOIN ChildLocation locCte ON locCte.${LocationDao.projectIdField}=frmTbl.${FormDao.projectIdField} AND locCte.${LocationDao.locationIdField}=frmTbl.${FormDao.locationIdField}\n"
            "WHERE attachTbl.${FormMessageAttachAndAssocDao.attachmentTypeField} IN (${EAttachmentAndAssociationType.files.value}, ${EAttachmentAndAssociationType.attachments.value})\n"
            "ORDER BY CAST(IIF(${FormMessageAttachAndAssocDao.attachSizeField}='','0',${FormMessageAttachAndAssocDao.attachSizeField}) AS INT) DESC";
      }
    }
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(formMessageAttachAndAssocDao.getTableName, query);
      List<FormMessageAttachAndAssocVO> listFormMessageAttachAndAssocVO = FormMessageAttachAndAssocDao().fromList(qurResult);
      tmpListOfFormMessageAttachment = await formMessageAttachAndAssocDao.getValidDownloadAttachmentList(listFormMessageAttachAndAssocVO);
    } on Exception catch (e) {
      Log.d(e.toString());
    }
    return tmpListOfFormMessageAttachment;
  }

  Future<void> _sendNetworkRequest(List<FormMessageAttachAndAssocVO> tmpList, bool bAkamaiDownload, Task? task) async {
    Map<String, dynamic> map = await _getRequestMapData(tmpList);
    if (map.isNotEmpty) {
      String strProjectId = syncRequestTask.projectId.plainValue();
      String strTimeInMilliSecond = DateTime.now().microsecondsSinceEpoch.toString();
      final taskStartTime = DateTime.now();
      String strFileExtension = ".zip";
      Log.d("FormAttachmentDownloadBatchSyncTask _parseFormAttachmentBatchData \"$strProjectId\" finished success");
      String attachmentDirPath = await AppPathHelper().getAttachmentDirectory(projectId: strProjectId);
      String attachmentPath = "$attachmentDirPath/${AConstants.tempAttachmentZip}$strTimeInMilliSecond$strFileExtension";
      map["attachmentPath"] = attachmentPath;
      map["projectId"] = strProjectId;
      map["networkExecutionType"] = NetworkExecutionType.SYNC;
      map["taskName"] = task?.taskNumber;
      Result result = await _projectListUseCase.downloadFormAttachmentInBatch(map, bAkamaiDownload: bAkamaiDownload);
      taskLogger(
        task: task,
        requestParam: map,
        responseType: result is SUCCESS ? TaskSyncResponseType.success : TaskSyncResponseType.failure,
        message: result is SUCCESS ? TaskSyncResponseType.success.name : result.failureMessage.toString(),
        taskStarTime: taskStartTime,
      );
      if (result is SUCCESS) {
        await _extractAndDeleteZipFile(attachmentPath, attachmentDirPath);
        List<String> successRevisionIdList = [];
        List<String> failRevisionIdList = [];
        await Future.forEach(tmpList, (FormMessageAttachAndAssocVO element) async {
          String attachmentFilePath = await AppPathHelper().getAttachmentFilePath(projectId: strProjectId.plainValue(), revisionId: element.attachRevId.toString(), fileExtention: Utility.getFileExtension(element.attachFileName.toString()));
          if (isFileExist(attachmentFilePath)) {
            successRevisionIdList.add(element.attachRevId.plainValue().toString());
          } else {
            failRevisionIdList.add(element.attachRevId.plainValue().toString());
          }
        });
        if (successRevisionIdList.isNotEmpty) {
          await passDataToSyncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.success, {"projectId": strProjectId.toString().plainValue(), "revisionIds": successRevisionIdList.join(",")});
        }
        if (failRevisionIdList.isNotEmpty) {
          await passDataToSyncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.failed, {"projectId": strProjectId.toString().plainValue(), "revisionIds": failRevisionIdList.join(",")});
        }
      } else {
        Map? attachmentParam = jsonDecode(map["attachmentDetails"]);
        if (attachmentParam != null && attachmentParam.isNotEmpty) {
          await passDataToSyncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.failed, {"projectId": attachmentParam["projectId"].toString().plainValue(), "revisionIds": attachmentParam['revisionIds']});
        }
      }
    }
  }

  Future<void> _extractAndDeleteZipFile(String attachmentPath, String attachmentDirPath) async {
    try {
      if (await ZipUtility().extractZipFile(strZipFilePath: attachmentPath, strExtractDirectory: attachmentDirPath)) {
        deleteFileAtPath(attachmentPath);
      }
    } catch (e) {
      Log.d("_parseFormAttachmentBatchData exception $e");
    }
  }

  Future<void> processAttachmentDownloadList(List<FormMessageAttachAndAssocVO> attachmentDownloadListFromDB) async {
    AppConfig appConfig = di.getIt<AppConfig>();
    int iMaxAkamaiDownloadLimit = appConfig.syncPropertyDetails!.akamaiDownloadLimit;
    List<FormMessageAttachAndAssocVO> attachmentDownloadList = [];
    int iMaxFileCount = appConfig.syncPropertyDetails!.fieldBatchDownloadFileLimit;
    int iMaxAttachmentDownloadSize = appConfig.syncPropertyDetails!.fieldBatchDownloadSize;

    int lRequestSize = 0;
    int iFileCounter = 0;

    void addAttachmentDownloadTask(List<FormMessageAttachAndAssocVO> attachments, bool bAkamaiDownload) {
      List<FormMessageAttachAndAssocVO> tempList = [...attachments];
      addTask((task) async => await _sendNetworkRequest(tempList, bAkamaiDownload, task), taskPriority: TaskPriority.low, taskTag: ESyncTaskType.formAttachmentDownloadBatchSyncTask.value);
    }

    for (FormMessageAttachAndAssocVO attachmentVo in attachmentDownloadListFromDB) {
      bool bAkamaiDownload = true;
      if (attachmentVo.attachSize! >= iMaxAttachmentDownloadSize) {
        if (iMaxAkamaiDownloadLimit <= attachmentVo.attachSize!) {
          bAkamaiDownload = false;
        }
        addAttachmentDownloadTask([attachmentVo], bAkamaiDownload);
      } else {
        if (((lRequestSize + attachmentVo.attachSize!) > iMaxAttachmentDownloadSize) || (iFileCounter >= iMaxFileCount && iMaxFileCount != -1)) {
          bool bAkamaiDownload = true;
          if (iMaxAkamaiDownloadLimit <= lRequestSize) {
            bAkamaiDownload = false;
          }
          addAttachmentDownloadTask(attachmentDownloadList, bAkamaiDownload);
          attachmentDownloadList.clear();
          attachmentDownloadList.add(attachmentVo);
          iFileCounter = 0;
          lRequestSize = attachmentVo.attachSize!;
        } else {
          lRequestSize = lRequestSize + attachmentVo.attachSize!;
          attachmentDownloadList.add(attachmentVo);
        }
        iFileCounter++;
      }
    }

    if (attachmentDownloadList.isNotEmpty) {
      bool bAkamaiDownload = true;
      if (iMaxAkamaiDownloadLimit <= lRequestSize) {
        bAkamaiDownload = false;
      }
      addAttachmentDownloadTask(attachmentDownloadList, bAkamaiDownload);
      attachmentDownloadList.clear();
    }

    attachmentDownloadListFromDB.clear();
  }
}
