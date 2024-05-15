import 'package:field/domain/use_cases/dashboard/homepage_usecase.dart';
import 'package:field/utils/field_enums.dart';

import '../../offline_injection_container.dart';
import 'base_sync_task.dart';

class ManageHomePageConfigurationTask extends BaseSyncTask {
  ManageHomePageConfigurationTask(super.syncRequestTask, super.syncCallback);

  void manageHomePageConfiguration({required String projectId}) {
    addTask((task) async {
      Map<String, dynamic> request = {"projectId": projectId};
      await getIt<HomePageUseCase>().getShortcutConfigList(request);
    }, taskTag: ESyncTaskType.manageHomePageConfigurationTask.value);
  }
}
