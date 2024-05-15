
import '../../data/model/task_form_listing_reponse.dart';

abstract class TaskFormListDataSource {
  Future<TaskFormListingResponse> getTaskFormListingList(Map<String, dynamic> request);
}
