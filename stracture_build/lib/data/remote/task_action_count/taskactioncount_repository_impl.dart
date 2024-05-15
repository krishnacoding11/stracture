import 'package:field/data/model/taskactioncount_vo.dart';
import 'package:field/data/repository/task_action_count/taskactioncount_repository.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:sprintf/sprintf.dart';

class TaskActionCountRemoteRepository extends TaskActionCountRepository{
  TaskActionCountRemoteRepository();

  @override
  Future<Result?>? getTaskActionCount(Map<String, dynamic> request,[dioInstance]) async {

    String strAppTypeId = request["appType"].toString();
    String strEntityTypeId = request["entityTypeId"].toString();
    String strProjectIds = request["projectIds"].toString();
    String strActiveStatusCode = "-1"; //Here -1 is for active and 23 is for inactive

    if(strAppTypeId.isNotEmpty){
      request.removeWhere((key, value) => key == "appType");
    }

    if(strEntityTypeId.isNotEmpty){
      request.removeWhere((key, value) => key == "entityTypeId");
    }

    if(strProjectIds.isNotEmpty){
      request.removeWhere((key, value) => key == "projectIds");
    }

    String endPointUrl = sprintf(AConstants.getTaskActionCountUrl, [strEntityTypeId,strAppTypeId,strProjectIds,strActiveStatusCode]);

    var result = await NetworkService(
        dioClient: dioInstance,
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_JSON,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.GET,
            path: endPointUrl,
            data: const NetworkRequestBody.empty()))
        .execute(TaskActionCountVo.fromJson);
    Log.d("TaskActionCountVo is successfully received.");
    return result;
  }
}