import 'package:field/domain/repository/task_form_listing_repository/model_list_repository_impl.dart';

import '../../../data/model/task_form_listing_reponse.dart';

class TaskFormListingUseCase {
  final TaskFormListingRepositoryImpl _taskFormListingRepositoryImpl = TaskFormListingRepositoryImpl();

  Future<TaskFormListingResponse> getTaskFormListingList(Map<String, dynamic> request) async {
    return await _taskFormListingRepositoryImpl.getTaskFormListingList(request);
  }
}
