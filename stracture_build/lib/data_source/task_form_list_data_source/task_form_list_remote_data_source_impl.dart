import 'package:field/utils/constants.dart';
import '../../data/model/task_form_listing_reponse.dart';
import '../../networking/network_request.dart';
import '../../networking/network_service.dart';
import '../../networking/request_body.dart';
import 'task_form_list_data_source.dart';

class TaskFormListRemoteDataSourceImpl extends TaskFormListDataSource {
  @override
  Future<TaskFormListingResponse> getTaskFormListingList(Map<String, dynamic> request) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_FORM_URL_ENCODE, mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.getTaskFormListing, data: NetworkRequestBody.json(request))).execute((response) {
      return response;
    });
    return taskFormListingReponseFromJson(result.data);
  }
}
