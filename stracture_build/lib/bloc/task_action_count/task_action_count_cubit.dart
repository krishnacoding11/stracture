import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_state.dart';
import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/taskactioncount_vo.dart';
import 'package:field/domain/use_cases/task_action_count/task_action_count_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/store_preference.dart';

enum TaskActionType { newTask, dueToday, dueThisWeek, overDue }

class TaskActionCountCubit extends BaseCubit {
  final TaskActionCountUseCase _taskActionCountUseCase = di.getIt<TaskActionCountUseCase>();
  late TaskActionCountVo _taskActionCountVo = TaskActionCountVo();

  TaskActionCountCubit() : super(TaskActionCountState(InternalState.loading, taskActionCount: TaskActionCountVo()));

  Future<void> getTaskActionCount() async {
    Project? project = await StorePreference.getSelectedProjectData();
    if (!await checkIfProjectSelected()) {
      emitState(TaskActionCountState(
        InternalState.failure,
        message: "Error in getting task action count data.",
        taskActionCount: TaskActionCountVo(),
      ));
      return;
    }
    Result? result;
    Map<String, dynamic> request = {};
    request["isOnline"] = isNetWorkConnected();
    request["appType"] = "2";
    request["entityTypeId"] = "1";
    request["projectIds"] = project?.projectID;
    result = await _taskActionCountUseCase.getTaskActionCount(request);
    if (result is SUCCESS) {
      _taskActionCountVo = result.data;
      emitState(TaskActionCountState(InternalState.success, taskActionCount: _taskActionCountVo));
    } else {
      emitState(TaskActionCountState(
        InternalState.failure,
        message: "Error in getting task action count data.",
        taskActionCount: TaskActionCountVo(),
      ));
    }
  }
}
