import 'package:dio/dio.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/prepare_network_request.dart';
import 'package:flutter/foundation.dart';

import '../logger/logger.dart';
import 'network_request.dart';

Future<Result<Model>> executeRequest<Model>(
  PreparedNetworkRequest request,
) async {
  try {
    dynamic body = request.request.data.whenOrNull(
      json: (data) => data,
      text: (data) => data,
      formData: (data) => data
    );
    var response;
    switch(request.request.callType){
      case CallType.MultiPart:
        response = await request.dio.post(
          request.request.path,
          data: body,
          options: Options(
            method: request.request.type.name,
            headers: request.request.headers,
          ),
          onReceiveProgress: request.onReceiveProgress,
        );
        break;
      case CallType.Download:
        response = await request.dio.download(
          request.request.path,
          request.filePath,
          data: body,
          options: Options(
            method: request.request.type.name,
            headers: request.request.headers ?? request.headers,
          ),
          onReceiveProgress: request.onReceiveProgress,
        );
        break;
      default:
        response = await request.dio.request(
          request.request.path,
          data: body,
          options: Options(
            method: request.request.type.name,
            headers: request.headers,
          ),
          onSendProgress: request.onSendProgress,
          onReceiveProgress: request.onReceiveProgress,
        );
        break;
    }

    dynamic data;
    if (request.request.callType == CallType.MultiPart || request.request.callType == CallType.Download || request.request.networkExecutionType == NetworkExecutionType.SYNC) {
      data = await request.parser(response.data);
    } else {
      data = await compute(request.parser ,response.data);
    }
    return SUCCESS(data, response.headers, response.statusCode, requestData: request.request.data);
  } on DioException catch (error) {
    if (error.response != null) {
      Log.d("DIO Error => StatusCode=${error.response?.statusCode} Data=${error.response?.data}");
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      Log.d("DIO Error => RequestOptions ${error.requestOptions} Msg ${error.message}");
    }
    return FAIL(error.response.toString(), error.response?.statusCode);
  } catch (error) {
    Log.d("Error => ${error.toString()}");
    return FAIL("", -1);
  }
}
