import 'package:dio/dio.dart';
import 'package:field/data/repository/filter_repository.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';

class FilterRemoteRepository extends FilterRepository<Map,Result> {
  FilterRemoteRepository();

  @override Future<Result?>? getFilterDataForDefect(Map<String, dynamic> request) async {
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.getDefectFilter,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        ),
        responseType: ResponseType.plain,
        //isCsrfRequired: true
    ).execute((response){
      return response;
    });
    return result;
  }

  @override
  Future<Result?>? getFilterSearchData(Map<String, dynamic> request) async {
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.adoddleFilter,
          data: NetworkRequestBody.json(request),
        ),
        responseType: ResponseType.plain,
        //isCsrfRequired: true
    ).execute((response){
      return response;
    });
    return result;
  }
}