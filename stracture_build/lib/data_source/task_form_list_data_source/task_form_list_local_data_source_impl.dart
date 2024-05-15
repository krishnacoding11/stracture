import 'package:field/data/dao/floor_list_dao.dart';
import 'package:field/data/model/floor_details.dart';
import '../../data/model/task_form_listing_reponse.dart';
import 'task_form_list_data_source.dart';

class TaskFormListLocalDataSourceImpl extends TaskFormListDataSource {
  @override
  Future<TaskFormListingResponse> getTaskFormListingList(Map<String, dynamic> request) {
    // TODO: implement getTaskFormListingList
    throw UnimplementedError();
  }

  // @override
  // Future<TaskFormListingResponse> getTaskFormListingList(Map<String, dynamic> request) async {
  //   return Task;
  // }
}
