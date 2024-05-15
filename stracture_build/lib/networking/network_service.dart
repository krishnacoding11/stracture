import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:field/logger/logger.dart';
import 'package:field/logger/network_logger.dart';
import 'package:field/networking/isolate_function.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/prepare_network_request.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/foundation.dart';

enum CallType { Normal, Download, MultiPart }

enum HeaderType { APPLICATION_FORM_URL_ENCODE, TEXT_JAVASCRIPT, APPLICATION_JSON, MULTIPART_REQUEST }

class NetworkService {
  Dio? _dio;
  final HeaderType headerType;
  String baseUrl;
  NetworkRequest mNetworkRequest;
  Map<String, String> _headers;
  ResponseType responseType;
  bool isRequiredRetry;
  int retries;
  List<Duration> retryDelays;
  Set<int> retryExtraStatuses;
  bool? isCsrfRequired;
  int? dcId;
  Duration? connectTimeout;
  Duration? receiveTimeout;
  bool isAkamaiDownload;

  static Map<String, String> csrfTokenKey = {'CSRF_SECURITY_TOKEN': ''};

  NetworkService(
      {required this.baseUrl,
      required this.mNetworkRequest,
      this.headerType = HeaderType.APPLICATION_FORM_URL_ENCODE,
      dioClient,
      httpHeaders,
      this.responseType = ResponseType.json,
      this.isRequiredRetry = false,
      this.retries = 3,
      this.dcId,
      this.isAkamaiDownload  = true,
      this.connectTimeout = const Duration(milliseconds: 50000),
      this.receiveTimeout = const Duration(milliseconds: 50000), /// `null` meanings no timeout limit Default 5 Seconds.
      this.retryDelays = const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
      this.retryExtraStatuses = const {},
      this.isCsrfRequired})
      : _dio = dioClient,
        _headers = {
          ...{
            'applicationId': '3',
          },
          ...(httpHeaders ?? {})
        };

  Future<Dio> _getCsrfDioClient() async {
    Map<String, String> headers = {};
    headers[HttpHeaders.contentTypeHeader] = "application/x-www-form-urlencoded";
    await _addSessionToHeader(headers);
    baseUrl = await UrlHelper.getBaseURL(baseUrl, dcId, bAkamaiDownload: isAkamaiDownload);
    final dio = Dio()
      ..options.baseUrl = baseUrl
      ..options.method = mNetworkRequest.type.name
      ..options.headers = headers
      ..options.connectTimeout = connectTimeout
      ..options.receiveTimeout = receiveTimeout
      ..interceptors.add(NetworkLogger(request: false, requestHeader: false, requestBody: false, responseHeader: false, cURLRequest: true, responseBody: false, networkExecutionType: mNetworkRequest.networkExecutionType, taskNumber: mNetworkRequest.taskNumber));
    if (isRequiredRetry) {
      retryExtraStatuses = {
        ...{600, 602}
      };
      dio.interceptors.add(RetryInterceptor(dio: dio, logPrint: (message) => {Log.d("Retry $message")}, retries: retries, retryableExtraStatuses: retryExtraStatuses, retryDelays: retryDelays));
    }
    return dio;
  }

  Future<Dio> _getDefaultDioClient() async {
    await _addRequestTypeInHeaders();
    await _addSessionToHeader(_headers);
    baseUrl = await UrlHelper.getBaseURL(baseUrl, dcId, bAkamaiDownload: isAkamaiDownload);
    // Added to fetch BASE URL based on user cloud and environment
    final dio = Dio()
      ..options.baseUrl = baseUrl
      ..options.method = mNetworkRequest.type.name
      ..options.headers = _headers
      ..options.connectTimeout = connectTimeout
      ..options.receiveTimeout = receiveTimeout
      ..options.responseType = responseType
      ..interceptors.add(NetworkLogger(request: false, requestHeader: false, requestBody: false, responseHeader: false, cURLRequest: /*mNetworkRequest.callType == CallType.MultiPart ? false :*/ true, responseBody: responseType == ResponseType.bytes ? false : false));

    if (isRequiredRetry) {
      retryExtraStatuses = {
        ...{600, 602}
      };
      dio.interceptors.add(RetryInterceptor(dio: dio, logPrint: (message) => {Log.d("Retry $message")}, retries: retries, retryableExtraStatuses: retryExtraStatuses, retryDelays: retryDelays));
    }
    try {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    } on Exception catch (e) {
      Log.d("Network AppException $e");
    }
    return dio;
  }

  Future<void> _addRequestTypeInHeaders() async {
    switch (headerType) {
      case HeaderType.APPLICATION_FORM_URL_ENCODE:
        _headers[HttpHeaders.contentTypeHeader] = "application/x-www-form-urlencoded";
        break;
      case HeaderType.TEXT_JAVASCRIPT:
        _headers[HttpHeaders.contentTypeHeader] = "text/javascript;charset=UTF-8";
        break;
      case HeaderType.APPLICATION_JSON:
        _headers[HttpHeaders.contentTypeHeader] = "application/json";
        break;
      case HeaderType.MULTIPART_REQUEST:
        _headers[HttpHeaders.contentTypeHeader] = "multipart/form-data;";
        break;
    }
  }

  Future<void> _addSessionToHeader(Map<String, String> headers) async {
    var aSessionId = await StorePreference.getUserAsessionId();
    var jSessionId = await StorePreference.getUserJsessionId();
    if ((aSessionId?.length)! > 0 && (jSessionId?.length)! > 0) {
      headers[AConstants.cookie] = 'ASessionID=$aSessionId;JSESSIONID=$jSessionId';
    }
  }

  Future<Result<Model>> execute<Model>(
    // NetworkRequest request,
    Model Function(dynamic) parser, {
    String? filePath,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _dio ??= await _getDefaultDioClient();

    bool bNeedCsrfRequest = false;
    Result<Model> result;
    do {
      bNeedCsrfRequest = false;
      if ((isCsrfRequired ?? false) && csrfTokenKey['CSRF_SECURITY_TOKEN'] == "") {
        final resultCsrf = await getCsrfToken(onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
        if (resultCsrf != null) {
          return resultCsrf;
        }
      }
      final req = PreparedNetworkRequest<Model>(mNetworkRequest, parser, _dio!, {..._headers, ...(mNetworkRequest.headers ?? {}), ...(isCsrfRequired ?? false ? csrfTokenKey : {})}, filePath: filePath, onSendProgress, onReceiveProgress);
      result = await executeRequest<Model>(req);

      if (result is! SUCCESS) {
        if (result.responseCode == 801 && isCsrfRequired == true) {
          bNeedCsrfRequest = true;
          csrfTokenKey['CSRF_SECURITY_TOKEN'] = "";
        } else {
          Utility.showReLoginDialog(FAIL(Utility.getErrorMessage(result.responseCode, message: result.failureMessage), result.responseCode));

          return FAIL(Utility.getErrorMessage(result.responseCode, message: result.failureMessage), result.responseCode);
        }
      }
    } while (bNeedCsrfRequest == true);
    return result;
  }

  Future<dynamic> getCsrfToken<Model>({ProgressCallback? onSendProgress, ProgressCallback? onReceiveProgress}) async {
    final csrfReq = PreparedNetworkRequest<Model>(
        const NetworkRequest(type: NetworkRequestType.POST, path: AConstants.csrfTokenUrl, data: NetworkRequestBody.json({})),
        (r) => r,
        await _getCsrfDioClient(),
         //_dio ??= await _getCsrfDioClient(),
        {
          ...{'applicationId': '3'}
        },
        onSendProgress,
        onReceiveProgress);
    final resultCsrf = await executeRequest<Map>(csrfReq);
    if (resultCsrf is SUCCESS) {
      csrfTokenKey = Map<String, String>.from(resultCsrf.data!);
    } else {
      return FAIL(Utility.getErrorMessage(resultCsrf.responseCode, message: resultCsrf.failureMessage), resultCsrf.responseCode);
    }
    return null;
  }
}
