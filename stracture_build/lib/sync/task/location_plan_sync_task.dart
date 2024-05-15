import 'package:field/data/dao/user_reference_location_plan_dao.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

import '../../data/model/project_vo.dart';
import '../../data/model/site_location.dart';
import '../../domain/use_cases/site/site_use_case.dart';
import '../../logger/logger.dart';
import '../../utils/site_utils.dart';

class LocationPlanSyncTask extends BaseSyncTask {
  final SiteUseCase _siteUseCase = offline_di.getIt<SiteUseCase>();

  LocationPlanSyncTask(super.syncRequestTask, super.syncCallback);

  /// Download Pdf and XFDF Files for all Site location
  void downloadPlanFile(List<Project> projectList, List<SiteLocation> siteLocationList)  {
    var uniqueRevisionIds = <String>{};
    for (var project in projectList) {
      for (var siteLocation in siteLocationList) {
        if (isLocationHasPlan(siteLocation) && !uniqueRevisionIds.contains(siteLocation.pfLocationTreeDetail?.revisionId)) {
          Map<String, dynamic> request = {"projectId": project.projectID, "folderId": siteLocation.folderId, "revisionId": siteLocation.pfLocationTreeDetail?.revisionId, "networkExecutionType": NetworkExecutionType.SYNC};

          addTask((task) async => await _downloadPdfPlan(request, task),taskPriority: TaskPriority.regular, taskTag: "${ESyncTaskType.locationPlanSyncTask.value} PDF - ${siteLocation.pfLocationTreeDetail?.revisionId}");

          addTask((task) async => await _downloadXfdfPlan(request, task),taskPriority: TaskPriority.regular, taskTag: "${ESyncTaskType.locationPlanSyncTask.value} XFDF - ${siteLocation.pfLocationTreeDetail?.revisionId}");

          uniqueRevisionIds.add(siteLocation.pfLocationTreeDetail!.revisionId!);
        }
      }
    }
    Log.d("LocationPlanSync Total Plan Downloading ${uniqueRevisionIds.length.toString()}");
  }

  /// Download Pdf Plan for Site Location.
  Future<void> _downloadPdfPlan(Map<String, dynamic> request, Task? task) async {
    UserReferenceLocationPlanDao userReferenceLocationPlanDao = UserReferenceLocationPlanDao();
    final taskStartTime = DateTime.now();
    try {
      Log.d("LocationPlanSync PDF Call ${request['revisionId']}");
      final downloadResponse =
          await _siteUseCase.downloadPdf(request, checkFileExist: true);
      if (downloadResponse.isSuccess && downloadResponse.result != null) {
        await userReferenceLocationPlanDao.insertLocationPlanDetailsInUserReference(projectId: request['projectId'].toString().plainValue(), revisionId: request['revisionId'].toString().plainValue());
      }
      
      Log.d(
          "LocationPlanSync PDF Call Done ${request['revisionId']}  ${downloadResponse.isSuccess}");
      _passDownloadResponseToCallback(downloadResponse);
      taskLogger(
        task: task,
        requestParam: request,
        responseType: downloadResponse.isSuccess
            ? TaskSyncResponseType.success
            : TaskSyncResponseType.failure,
        message: downloadResponse.isSuccess
            ? TaskSyncResponseType.success.name
            : downloadResponse.errorMsg.toString().plainValue(),
        taskStarTime: taskStartTime,
      );
    } catch (e) {
      Log.d("LocationPlanSync Download Plan Failed $e");
      taskLogger(
        task: task,
        requestParam: request,
        responseType: TaskSyncResponseType.exception,
        message: e.toString(),
        taskStarTime: taskStartTime,
      );
    }
  }

  /// Download XFDF File for Site Location.
  Future<void> _downloadXfdfPlan(Map<String, dynamic> request, Task? task) async {
    UserReferenceLocationPlanDao userReferenceLocationPlanDao = UserReferenceLocationPlanDao();
    final taskStartTime = DateTime.now();
    try {
      Log.d("LocationPlanSync XFDF Call ${request['revisionId']}");
      final downloadResponse =
          await _siteUseCase.downloadXfdf(request, checkFileExist: true);
      if (downloadResponse.isSuccess && downloadResponse.result != null) {
        await userReferenceLocationPlanDao.insertLocationPlanDetailsInUserReference(projectId: request['projectId'].toString().plainValue(), revisionId: request['revisionId'].toString().plainValue());
      }
      Log.d(
          "LocationPlanSync XFDF Call Done ${request['revisionId']}  ${downloadResponse.isSuccess}");
      _passDownloadResponseToCallback(downloadResponse);
      taskLogger(
        task: task,
        requestParam: request,
        responseType: downloadResponse.isSuccess
            ? TaskSyncResponseType.success
            : TaskSyncResponseType.failure,
        message: downloadResponse.isSuccess
            ? TaskSyncResponseType.success.name
            : downloadResponse.errorMsg.toString(),
        taskStarTime: taskStartTime,
      );
    } catch (e) {
      Log.d("LocationPlanSync Download Xfdf Plan Failed $e");
      taskLogger(
        task: task,
        requestParam: request,
        responseType: TaskSyncResponseType.exception,
        message: e.toString(),
        taskStarTime: taskStartTime,
      );
    }
  }

  static bool isLocationHasPlan(SiteLocation siteLocation) {
    return (siteLocation.isMarkOffline ?? false) && siteLocation.isActive == 1 && SiteUtility.isLocationHasPlan(siteLocation) && ((siteLocation.pfLocationTreeDetail?.isFileUploaded ?? false) || (siteLocation.pfLocationTreeDetail?.isCalibrated ?? false));
  }

  Future<void> _passDownloadResponseToCallback(DownloadResponse downloadResponse) async {
    try {
      Map<String, dynamic>? requestData = downloadResponse.requestParam;
      if (requestData != null && requestData.isNotEmpty) {
        String? projectId = requestData["projectId"];
        String? revisionId = requestData["revisionId"];
        bool isXFDF = (downloadResponse.outputFilePath ?? "").toLowerCase().contains("xfdf");
        ESyncStatus eSyncStatus = downloadResponse.isSuccess ? ESyncStatus.success : ESyncStatus.failed;
        await passDataToSyncCallback(ESyncTaskType.locationPlanSyncTask, eSyncStatus, {"projectId": projectId, "revisionId": revisionId, "isXfdf": isXFDF});
      }
    } catch (e) {}
  }
}
