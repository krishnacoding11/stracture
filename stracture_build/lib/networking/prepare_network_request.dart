import 'package:dio/dio.dart';
import 'package:field/networking/network_request.dart';


class PreparedNetworkRequest<Model> {
  final NetworkRequest request;
  final Model Function(dynamic) parser;
  final Dio dio;
  final String? filePath;
  final Map<String, dynamic> headers;
  final ProgressCallback? onSendProgress;
  final ProgressCallback? onReceiveProgress;

  const PreparedNetworkRequest(
      this.request,
      this.parser,
      this.dio,
      this.headers,
      this.onSendProgress,
      this.onReceiveProgress,
      {this.filePath}
      );
}