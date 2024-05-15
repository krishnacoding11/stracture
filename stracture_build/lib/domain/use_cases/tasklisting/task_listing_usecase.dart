import 'package:field/data/local/task_listing/tasklisting_local_repository_impl.dart';
import 'package:field/data/remote/task_listing/tasklisting_repository_impl.dart';
import 'package:field/data/repository/task_listing/tasklisting_repository.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';

import '../../../networking/network_response.dart';

class TaskListingUseCase extends BaseUseCase {
  TaskListingRepository? _taskListingRepository;

  Future<Result> getTaskListing(Map<String,dynamic> request) async {
    await getInstance();
    return await _taskListingRepository!.getTaskListing(request);
  }

  Future<Result> getTaskStatusList(Map<String,dynamic> request) async {
    await getInstance();
    return await _taskListingRepository!.getTaskStatusList(request);
  }

  Future<Result> getTaskDetail(Map<String,dynamic> request) async {
    await getInstance();
    return await _taskListingRepository!.getTaskDetail(request);
  }

  @override
  Future<TaskListingRepository?> getInstance() async {
    if(isNetWorkConnected()){
      _taskListingRepository = di.getIt<TaskListingRemoteRepository>();
    }
    else{
      _taskListingRepository = di.getIt<TaskListingLocalRepository>();
    }
    return _taskListingRepository;
  }
}