import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';

enum NetworkRequestType { GET, POST, PUT, PATCH, DELETE }

enum NetworkExecutionType { MAIN, SYNC }

class NetworkRequest {
  const NetworkRequest({
    required this.type,
    required this.path,
    required this.data,
    this.queryParams,
    this.headers,
    this.callType = CallType.Normal,
    this.networkExecutionType,
    this.taskNumber,
  });

  final NetworkRequestType type;
  final String path;
  final NetworkRequestBody data;
  final Map<String, dynamic>? queryParams;
  final Map<String, String>? headers;
  final CallType callType;
  final NetworkExecutionType? networkExecutionType;
  final num? taskNumber;
}
