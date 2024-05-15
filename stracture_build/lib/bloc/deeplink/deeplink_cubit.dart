import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter/services.dart';

import '../../logger/logger.dart';
import '../../networking/network_request.dart';
import '../../networking/network_response.dart';
import '../../networking/network_service.dart';
import '../../networking/request_body.dart';
import '../../utils/constants.dart';

class DeepLinkCubit extends BaseCubit {
  String uri = "";

  //Event Channel creation
  static const eventStream = EventChannel('addodle.deeplinke/events');

  //Method channel creation
  static const platform = MethodChannel('addodle.deeplinkc/channel');

  DeepLinkCubit() : super(FlowState()) {
    //Checking application start by deep link
    startUri().then((value) {
      _onRedirected(value);
    });
    //Checking broadcast stream, if deep link was clicked in opened appication
    eventStream.receiveBroadcastStream().listen((d) => _onRedirected(d));
  }

  Future<void> _onRedirected(dynamic uri) async {
    dynamic urL = await uri;
    // Here can be any uri analysis, checking tokens etc, if itâ€™s necessary
    // Throw deep link URI into the BloC's stream
    Log.d("_onRedirected ${uri.toString()}");
    try {
      if (urL == null || urL.toString().isEmpty) {
        emitState(EmptyState("URI empty"));
      }
      else {
        emitState(SuccessState(urL.toString(),time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(EmptyState(e.toString()));
    }
  }

  Future<Object> startUri() async {
    try {
      return platform.invokeMethod('initialLink');
    } on PlatformException catch (e) {
      return "Failed to Invoke initialLink: '${e.message}'.";
    }
  }

  Future<Result> getRequestURLForDeeplink(String url,
      {Function? onSuccess, Function? onFail}) async {
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            headerType: HeaderType.APPLICATION_JSON,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.GET,
                path: url,
                data: const NetworkRequestBody.empty()))
        .execute((response) {
      return response;
    });
    if (result is SUCCESS) {
      Log.d("Result: $result");
      String subStr = "portlet-msg-error";
      if (result.data.contains(subStr)) {
        print("Result.data ${result.data}");
           onFail!(result.data);
      } else {
        if (onSuccess != null) {
          onSuccess();
        }
      }
    }
    return result;
  }
}
