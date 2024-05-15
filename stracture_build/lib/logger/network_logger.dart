import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';

class NetworkLogger extends Interceptor {
  /// Print request [Options]
  late final bool request;

  /// Print Curl request
  late final bool cURLRequest;

  /// Print request header [Options.headers]
  late final bool requestHeader;

  /// Print request data [Options.data]
  late final bool requestBody;

  /// Print [Response.data]
  late final bool responseBody;

  /// Print [Response.headers]
  late final bool responseHeader;

  /// Print error message
  late final bool error;

  /// InitialTab count to logPrint json response
  static const int initialTab = 1;

  /// 1 tab length
  static const String tabStep = '    ';

  /// Print compact json response
  late final bool compact;

  /// Width size per logPrint
  late final int maxWidth;

  /// Print networkExecutionType
  late final NetworkExecutionType? networkExecutionType;

  late final num? taskNumber;
  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  void Function(Object object) logPrint;

  NetworkLogger({
    this.request = true,
    this.requestHeader = false,
    this.cURLRequest = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
    this.logPrint = _printLog,
    this.networkExecutionType,
    this.taskNumber,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['requestTime'] = DateTime.now().toString();
    options.headers['networkExecutionType'] = '${networkExecutionType ?? NetworkExecutionType.MAIN}';
    options.headers['taskNumber'] = '${taskNumber ?? ''}';

    if (cURLRequest) {
      _renderCurlRepresentation(options);
    }
    if (request) {
      _printRequestHeader(options);
    }

    if (requestHeader) {
      _printMapAsTable(options.queryParameters, header: 'Query Parameters');
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout;
      requestHeaders['receiveTimeout'] = options.receiveTimeout;
      _printMapAsTable(requestHeaders, header: 'Headers');
      _printMapAsTable(options.extra, header: 'Extras');
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) _printMapAsTable(options.data as Map?, header: 'Body');
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addEntries(data.fields)
            ..addEntries(data.files);
          _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}');
        } else {
          _printBlock(data.toString());
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      if (err.type == DioExceptionType.badResponse) {
        final uri = err.response?.requestOptions.uri;
        _printBoxed(header: 'DioException ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage}', text: uri.toString());
        if (err.response != null && err.response?.data != null) {
          logPrint('╔ ${err.type.toString()}');
          _printResponse(err.response!);
        }
        _printLine('╚');
        logPrint('');
      } else {
        _printBoxed(header: 'DioException ║ ${err.type}', text: err.message);
      }
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printResponseHeader(response);
    if (responseHeader) {
      final responseHeaders = <String, String>{};

      response.headers.forEach((k, list) => responseHeaders[k] = list.toString());

      _printMapAsTable(responseHeaders, header: 'Headers');
    }

    if (responseBody) {
      logPrint('╔ Body');
      logPrint('║');
      _printResponse(response);
      logPrint('║');
      _printLine('╚');
    }
    super.onResponse(response, handler);
  }

  void _printBoxed({String? header, String? text}) {
    logPrint('');
    logPrint("╔╣ $header");
    logPrint("║  $text");
    _printLine("╚");
  }

  void _printResponse(Response response) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map);
      } else if (response.data is List) {
        logPrint('║${_indent()}[');
        _printList(response.data as List);
        logPrint('║${_indent()}[');
      } else {
        _printBlock(response.data.toString());
      }
    }
  }

  void _printResponseHeader(Response response) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    int difference = 0;
    if (response.requestOptions.headers.containsKey('requestTime')) {
      final requestTime = DateTime.parse(response.requestOptions.headers['requestTime'].toString());
      difference = DateTime.now().difference(requestTime).inMilliseconds;
    }
    _printBoxed(header: 'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage} ║ Time: $difference Milliseconds', text: uri.toString());
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(header: 'Request ║ $method ', text: uri.toString());
  }

  void _printLine([String pre = '', String suf = '╝']) => logPrint('$pre${'═' * maxWidth}$suf');

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(pre);
      _printBlock(msg);
    } else {
      logPrint('$pre$msg');
    }
  }

  void _printBlock(String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      var m = msg.substring(i * maxWidth, math.min<int>(i * maxWidth + maxWidth, msg.length));
      if (m.isNotEmpty) {
        logPrint((i >= 0 ? '║ ' : '') + m);
      }
    }
  }

  String _indent([int tabCount = initialTab]) => tabStep * tabCount;

  void _printPrettyMap(
      Map data, {
        int tabs = initialTab,
        bool isListItem = false,
        bool isLast = false,
      }) {
    var _tabs = tabs;
    final isRoot = _tabs == initialTab;
    final initialIndent = _indent(_tabs);
    _tabs++;

    if (isRoot || isListItem) logPrint('║$initialIndent{');

    data.keys.toList().asMap().forEach((index, dynamic key) {
      final isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'(\r|\n)+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint('║${_indent(_tabs)} $key: $value${!isLast ? ',' : ''}');
        } else {
          logPrint('║${_indent(_tabs)} $key: {');
          _printPrettyMap(value, tabs: _tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint('║${_indent(_tabs)} $key: ${value.toString()}');
        } else {
          logPrint('║${_indent(_tabs)} $key: [');
          _printList(value, tabs: _tabs);
          logPrint('║${_indent(_tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(_tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            logPrint('║${_indent(_tabs)} ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
          }
        } else {
          logPrint('║${_indent(_tabs)} $key: $msg${!isLast ? ',' : ''}');
        }
      }
    });

    logPrint('║$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printList(List list, {int tabs = initialTab}) {
    list.asMap().forEach((i, dynamic e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (compact && _canFlattenMap(e)) {
          logPrint('║${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(e, tabs: tabs + 1, isListItem: true, isLast: isLast);
        }
      } else {
        logPrint('║${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  bool _canFlattenMap(Map map) {
    return map.values.where((dynamic val) => val is Map || val is List).isEmpty && map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    logPrint('╔ $header ');
    map.forEach((dynamic key, dynamic value) => _printKV(key.toString(), value));
    _printLine('╚');
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
    // add a breakpoint here so all errors can break
    try {
      _printLog(_cURLRepresentation(requestOptions));
    } catch (err) {
      _printLog('unable to create a CURL representation of the requestOptions');
    }
  }

  String _cURLRepresentation(RequestOptions options) {
    List<String> components = ['curl -i'];
    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method}');
    }

    options.headers.forEach((k, v) {
      components.add('-H "$k: $v"');
    });

    if (options.data != null) {
      if (options.data is Map) {
        options.data.forEach((dynamic key, dynamic value) => components.add('-d \'$key=$value\''));
      } else if (options.data is FormData) {
        // FormData can't be JSON-serialized, so keep only their fields attributes
        Map fields = Map.fromEntries(options.data.fields);
        fields.forEach((dynamic key, dynamic value) => components.add('-F \'$key=$value\''));
      } else {
        components.add('-d "${options.data.toString()}"');
      }
    }
    components.add('"${options.uri.toString()}"');
    return components.join(' \\\n\t');
  }

  static void _printLog(Object object) {
    Log.d(object);
  }
}
