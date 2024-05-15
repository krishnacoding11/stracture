import 'dart:convert';
import 'dart:io';

import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';

class ColumnHeaderListSyncTask extends BaseSyncTask{
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();
  bool _columnHeaderListIsSuccess = false;

  ColumnHeaderListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> syncColumnHeaderListData(Task? task) async {
    return await _getColumnHeaderListFromServer(task);
  }

  Future<void> _getColumnHeaderListFromServer(Task? task) async {
    print(task);
    final taskStartTime = DateTime.now();
    try {
      List<String> strListingTypes = ["", "139", "148"];
      for (var listingType in strListingTypes) {
        Map<String, dynamic> map =
            _getRequestMapDataForColumnHeaderList(listingType: listingType);
        map["taskNumber"]  = task?.taskNumber;
        Result result = (await _projectListUseCase.getColumnHeaderList(map));
        if (result is SUCCESS) {
          final columnHeaderJson = result.data;
          for (final listingTypeKey in columnHeaderJson.keys) {
            String strlistingTypeValue =
                jsonEncode(columnHeaderJson[listingTypeKey]);
            String strlistingTypeKey = listingTypeKey.toString();
            if (strlistingTypeKey.isNotEmpty &&
                strlistingTypeValue.isNotEmpty) {
              String listingTypeFilePath = await AppPathHelper()
                  .getColumnHeaderFilePath(listingType: strlistingTypeKey);
              await writeIntoFile(
                  File(listingTypeFilePath), strlistingTypeValue);
            }
          }
          taskLogger(
            task: task,
            requestParam: map,
            responseType: TaskSyncResponseType.success,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          taskLogger(
            task: task,
            requestParam: map,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage ?? "",
            taskStarTime: taskStartTime,
          );
        }
      }
      _columnHeaderListIsSuccess = true;
    } catch (e) {
      taskLogger(
        task: task,
        responseType: TaskSyncResponseType.exception,
        message: "ColumnHeaderListSyncCubit exception $e",
        taskStarTime: taskStartTime,
      );
      Log.d("ColumnHeaderListSyncCubit exception $e");
    }
  }

  Map<String, dynamic> _getRequestMapDataForColumnHeaderList(
      {String listingType = ""}) {
    Map<String, dynamic> map = {};
    map["listingType"] = listingType;
    map["networkExecutionType"] = NetworkExecutionType.SYNC;
    return map;
  }

  bool isColumnHeaderListCallSuccess() {
    return _columnHeaderListIsSuccess;
  }
}
