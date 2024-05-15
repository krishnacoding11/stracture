import 'dart:convert';

import 'package:field/utils/sharedpreference.dart';

import '../../../injection_container.dart' as di;
import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/app_config.dart';
import '../../../utils/constants.dart';
import '../../model/sync/sync_property_detail_vo.dart';
import '../../repository/generic_repository.dart';

class GenericRemoteRepository extends GenericRepository<Map, Result> {
  GenericRemoteRepository();

  @override
  Future<Result?> getHashValue(Map<String, dynamic> request,[dioInstance]) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
      dioClient: dioInstance,
        baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_FORM_URL_ENCODE, isRequiredRetry: true, mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.getHashUrl, data: NetworkRequestBody.json(request))).execute((response) {
      return jsonDecode(response);
    });
    return result;
  }

  @override
  Future<Result> getDeviceConfiguration([dioInstance]) async {
    var result = await NetworkService(dioClient: dioInstance,
        baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_JSON, retries: 0, mNetworkRequest: const NetworkRequest(type: NetworkRequestType.POST, path: AConstants.getDeviceConfigurationUrl, data: NetworkRequestBody.empty())).execute((response) {
      return response.toString();
    });
    if (result is SUCCESS) {
      di.getIt<AppConfig>().syncPropertyDetails = SyncManagerPropertyDetails.fromJson(result.data.toString());
      PreferenceUtils.setString(AConstants.keyAppConfig, result.data.toString());
    }
    return result;
  }
}
