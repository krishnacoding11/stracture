import 'package:field/data_source/task_form_list_data_source/task_form_list_data_source.dart';
import 'package:field/data_source/task_form_list_data_source/task_form_list_local_data_source_impl.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import '../../../data/model/task_form_listing_reponse.dart';
import '../../../data_source/task_form_list_data_source/task_form_list_remote_data_source_impl.dart';

class TaskFormListingRepositoryImpl {
  TaskFormListDataSource? _taskFormListDataSource;

  Future<TaskFormListDataSource?> getInstance() async {
    if (isNetWorkConnected()) {
      _taskFormListDataSource = getIt<TaskFormListRemoteDataSourceImpl>();
      return _taskFormListDataSource;
    } else {
      _taskFormListDataSource = getIt<TaskFormListLocalDataSourceImpl>();
      return _taskFormListDataSource;
    }
  }

  Future<TaskFormListingResponse> getTaskFormListingList(Map<String, dynamic> request) async {
    await getInstance();
    return await _taskFormListDataSource!.getTaskFormListingList(request);
  }
}
