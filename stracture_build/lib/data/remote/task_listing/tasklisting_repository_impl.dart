import 'package:dio/dio.dart';
import 'package:field/data/model/tasklisting_vo.dart';
import 'package:field/data/model/taskstatussist_vo.dart';
import 'package:field/data/repository/task_listing/tasklisting_repository.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';
import 'package:sprintf/sprintf.dart';


class TaskListingRemoteRepository extends TaskListingRepository{
  TaskListingRemoteRepository();

  @override
  Future<Result> getTaskListing(Map<String, dynamic> request) async {
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.getSearchTaskUrl,
            data: NetworkRequestBody.json(request)))
        .execute(TaskListingVO.fromJson);
    Log.d("Search Task call executed successfully.");
    return result;
  }

  @override
  Future<Result> getTaskStatusList(Map<String, dynamic> request) async {
    String loginTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    String endPointUrl = sprintf(AConstants.getTaskStatusListUrl, [loginTimeStamp]);

    var result = await NetworkService(
        baseUrl: AConstants.taskUrl,
        headerType: HeaderType.APPLICATION_JSON,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.GET,
            path: endPointUrl,
            data: const NetworkRequestBody.empty()))
        .execute(getTaskStatusObjList);
    Log.d("Task Statuc list is successfully received.");
    return result;
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
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.adoddleSiteListing,
        data: NetworkRequestBody.json(request),
      ),
      responseType: ResponseType.plain,
    ).execute((response){
      return response;
    });
    Log.d("getTaskDetail executed successfully.");
    return result;
  }
}