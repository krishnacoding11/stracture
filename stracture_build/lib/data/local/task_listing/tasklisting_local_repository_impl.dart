import 'package:field/data/model/taskstatussist_vo.dart';
import 'package:field/data/repository/task_listing/tasklisting_repository.dart';
import 'package:field/networking/network_response.dart';

class TaskListingLocalRepository extends TaskListingRepository{
  TaskListingLocalRepository();

  @override
  Future<Result> getTaskListing(Map<String, dynamic> request) async {
    return FAIL("", -1);
  }

  @override
  Future<Result> getTaskStatusList(Map<String, dynamic> request) async {
    return FAIL("", -1);
  }

  dynamic getTaskStatusObjList(dynamic result) {
    List<TaskStatusListVo> lstTaskStatusVO=[];
    for(dynamic obj in result){
      lstTaskStatusVO.add(TaskStatusListVo.fromJson(obj));
    }
    return lstTaskStatusVO;
  }

  @override
  Future<Result> getTaskDetail(Map<String, dynamic> request) async {
    return FAIL("", -1);
  }
}