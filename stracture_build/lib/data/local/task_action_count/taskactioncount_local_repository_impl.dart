import 'package:field/data/repository/task_action_count/taskactioncount_repository.dart';
import 'package:field/networking/network_response.dart';

class TaskActionCountLocalRepository extends TaskActionCountRepository{
  TaskActionCountLocalRepository();

  @override
  Future<Result?>? getTaskActionCount(Map<String, dynamic> request) async {
    return FAIL("", -1);
  }
}