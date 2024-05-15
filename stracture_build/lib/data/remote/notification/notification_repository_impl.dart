
import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';

class NotificationRemoteRepository {

  // Future<Result> getNotificationList(Map<String, dynamic> request) async {
  //   var result = await NetworkService(
  //     baseUrl: AConstants.adoddleUrl,
  //     mNetworkRequest: NetworkRequest(
  //       type: NetworkRequestType.POST,
  //       path: AConstants.getDashboardNotifications,
  //       data: NetworkRequestBody.json(request),
  //     ),
  //   ).execute(parseNotificationList);
  //   return result;
  // }
  //
  // parseNotificationList(dynamic json) {
  //   List<NotificationVo> listNotifications = [];
  //   if(json is List){
  //       for(var element in json){
  //         if(element is Map){
  //           listNotifications.add(NotificationVo.fromJson(element.values.first[0]));
  //         }
  //       }
  //   }
  //   Log.d(json);
  //   return listNotifications;
  // }

  Future<Result> sendTaskDetailRequest(Map<String, dynamic> request,[dioInstance]) async {
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getTaskFileFormData,
        data: NetworkRequestBody.json(request),
      ), isCsrfRequired: true
    ).execute((response){
      return response;
    });
    return result;
  }
}