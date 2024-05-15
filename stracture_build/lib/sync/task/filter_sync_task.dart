
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_utils.dart';

import '../../domain/use_cases/Filter/filter_usecase.dart';
import '../../networking/network_request.dart';
import '../../offline_injection_container.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/field_enums.dart';
import 'base_sync_task.dart';

class FilterSyncTask extends BaseSyncTask {

  FilterSyncTask(super.syncRequestTask, super.syncCallback);

  void getAttributeList({required String projectId, required String appTypeId})  {
    addTask((task) async {
      ESyncStatus eSyncStatus = ESyncStatus.failed;
      Map<String, dynamic> map = {
        "projectIds": projectId.plainValue(),
        "appType": appTypeId,
        "networkExecutionType" : NetworkExecutionType.SYNC,
      };
      final result = await getIt<FilterUseCase>().getFilterDataForDefectSync(map);
      if (result is SUCCESS) {
        String filePath = await AppPathHelper().getProjectFilterAttributeFile(projectId: projectId);
        await writeDataToFile(filePath, result.data);
        eSyncStatus = ESyncStatus.success;
      }
      await passDataToSyncCallback(ESyncTaskType.filterSyncTask, eSyncStatus, {"projectId": projectId});
    }, taskPriority: TaskPriority.high, taskTag: ESyncTaskType.filterSyncTask.value);
  }
}