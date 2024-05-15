import 'package:field/data/local/task_action_count/taskactioncount_local_repository_impl.dart';
import 'package:field/data/remote/task_action_count/taskactioncount_repository_impl.dart';
import 'package:field/data/repository/task_action_count/taskactioncount_repository.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';

import '../../../networking/network_response.dart';

class TaskActionCountUseCase extends BaseUseCase {
  TaskActionCountRepository? _taskActionCountRepository;

  Future<Result?> getTaskActionCount(Map<String,dynamic> request) async {
    await getInstance();
    return await _taskActionCountRepository!.getTaskActionCount(request);
  }

  @override
  Future getInstance() async{
    if(!isNetWorkConnected()){
      _taskActionCountRepository = di.getIt<TaskActionCountLocalRepository>();
    }
    else{
      _taskActionCountRepository = di.getIt<TaskActionCountRemoteRepository>();
    }
  }
}