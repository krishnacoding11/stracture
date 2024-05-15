import 'dart:collection';

import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/web_view/web_view_cubit.dart';
import 'package:field/bloc/web_view/web_view_state.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../logger/logger.dart';
import '../presentation/base/state_renderer/state_render_impl.dart';
import '../utils/constants.dart';
import '../utils/in_app_webview_options.dart';

typedef OnPageStarted = Function(String url);
typedef OnPageFinished = Function(String url);
typedef OnPageError = Function(int code, String message);
typedef OnProgressChanged = Function(int progress);
typedef OnWebViewCreated = Function(InAppWebViewController webViewController);
typedef SetCookies = Function(String url, CookieManager cookieManager);
typedef GetInAppWebViewController = Function(InAppWebViewController inAppWebViewController);
typedef ShouldOverrideUrlLoading = Function(InAppWebViewController webViewController, NavigationAction navigationAction);

class WebViewWidget extends StatefulWidget {
  const WebViewWidget({
    Key? key,
    required this.url,
    this.isShowProgressBar = true,
    this.onWebViewCreated,
    this.onPageStarted,
    this.onPageFinished,
    this.onPageError,
    this.onProgressChanged,
    this.shouldOverrideUrlLoading,
    this.setCookies,
  }) : super(key: key);
  final String url;
  final bool isShowProgressBar;
  final OnWebViewCreated? onWebViewCreated;
  final OnPageStarted? onPageStarted;
  final OnPageFinished? onPageFinished;
  final OnPageError? onPageError;
  final OnProgressChanged? onProgressChanged;
  final ShouldOverrideUrlLoading? shouldOverrideUrlLoading;
  final SetCookies? setCookies;

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  final GlobalKey webViewKey = GlobalKey();
  String? aSessionId;
  String? jSessionId;
  String domain = AConstants.adoddleUrl;

  CookieManager cookieManager = CookieManager.instance();
  InAppWebViewController? _appWebViewController;
  WebViewCubit? _webViewCubit;
  HashSet loadedUrlList = HashSet<String>();
  bool isOnline = true;
  // File? pageHtmlFile;
  @override
  void initState() {
    isOnline = getNetworkStatus();
    getSessionData();
    super.initState();
    if (widget.isShowProgressBar) {
      _webViewCubit = getIt<WebViewCubit>();
    }
  }

  bool getNetworkStatus() {
    return isNetWorkConnected();
  }

  Future<void> getSessionData() async {
    aSessionId = await StorePreference.getUserAsessionId() ?? "";
    jSessionId = await StorePreference.getUserJsessionId() ?? "";
    domain = await UrlHelper.getAdoddleURL(null);
    domain = domain.split("://").last;
// <<<<<<< Updated upstream
//     if(!isOnline){
//       await localhostServer.start();
//       if (Platform.isIOS) {
//         _appWebViewController?.setOptions(options: inAppWebViewGroupOptions(Uri.parse('file://${await AppPathHelper().getBasePath()}')));
//         /*String fileString = readFromFile(widget.url.replaceAll('&${AConstants.fieldAppParam}', '').replaceAll('file://', ''));
//         pageHtmlFile = File('${await AppPathHelper().getAssetHTML5FormZipPath()}/tempFile.html');
//
//         pageHtmlFile?.writeAsBytesSync(utf8.encode(fileString));
//         _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));
//         // _appWebViewController?.loadData(data: fileString,allowingReadAccessTo: Uri.parse('file://${await AppPathHelper().getAssetHTML5FormZipPath()}'));
//         _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse('file://${pageHtmlFile?.path}')), allowingReadAccessTo: Uri.parse('file://${await AppPathHelper().getBasePath()}'));
//         // _appWebViewController?.loadFile(assetFilePath: widget.url.replaceAll('&${AConstants.fieldAppParam}', ''));*/
//         _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url.replaceAll('&${AConstants.fieldAppParam}', ''))), allowingReadAccessTo: Uri.parse('file://${await AppPathHelper().getBasePath()}'));
//       } else {
//         _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url.replaceAll('&${AConstants.fieldAppParam}', ''))));
//       }
//     }
// =======
    // if(!isOnline){
    //   await localhostServer.start();
    //   _appWebViewController?.setOptions(options: inAppWebViewGroupOptions(Uri.parse('file://${await AppPathHelper().getBasePath()}')));
    //   String fileString = readFromFile(widget.url.replaceAll('&${AConstants.fieldAppParam}', '').replaceAll('file://', ''));
    //   pageHtmlFile = File('${await AppPathHelper().getAssetHTML5FormZipPath()}/tempFile.html');
    //
    //   pageHtmlFile?.writeAsBytesSync(utf8.encode(fileString));
    //   _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));
    //   // _appWebViewController?.loadData(data: fileString,allowingReadAccessTo: Uri.parse('file://${await AppPathHelper().getAssetHTML5FormZipPath()}'));
    //   _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse('file://${pageHtmlFile?.path}')),allowingReadAccessTo: Uri.parse('file://${await AppPathHelper().getBasePath()}'));
    //   // _appWebViewController?.loadFile(assetFilePath: widget.url.replaceAll('&${AConstants.fieldAppParam}', ''));
    // }
    setCookies(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          key: webViewKey,
          gestureRecognizers: Set()..add(Factory<DragGestureRecognizer>(() => VerticalDragGestureRecognizer())),
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
          initialOptions: inAppWebViewGroupOptions(Uri.parse('file://${AppPathHelper().basePath}')),
          onWebViewCreated: (InAppWebViewController webViewController) async {
            _appWebViewController = webViewController;
            setCookies(widget.url);
            if (widget.onWebViewCreated != null) {
              widget.onWebViewCreated!(_appWebViewController!);
            }
          },
          onConsoleMessage: (controller, consoleMessage) {
            Log.d('Console message is ----> ${consoleMessage.message}');
          },
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
          },
          onLoadStart: (InAppWebViewController controller, Uri? url) async {
            if (widget.onProgressChanged != null) {
              widget.onPageStarted!(url.toString());
            }
          },
          onLoadStop: (InAppWebViewController controller, Uri? url) async {
            if (widget.onPageFinished != null) {
              widget.onPageFinished!(url.toString());
            }
            if (_webViewCubit != null && !_webViewCubit!.isClosed) {
              _webViewCubit?.showLinearProgressIndicator(false, 1);
              await Future.delayed(Duration(seconds: 5));
              _appWebViewController!.evaluateJavascript(source: "const event2 = new CustomEvent('setBimObjectDataFromFlutter',{detail : '${getIt<OnlineModelViewerCubit>().snaggingGuId}'}); window.dispatchEvent(event2)");
            }
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {
            if (widget.onProgressChanged != null) {
              widget.onProgressChanged!(progress);
            }

            _webViewCubit?.showLinearProgressIndicator(true, progress / 100);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var request = navigationAction.request;
            var url = request.url;
            bool absolute = url!.hasAbsolutePath;

            if (absolute) {
              setCookies(url.toString());
            }

            if (widget.shouldOverrideUrlLoading != null) {
              widget.shouldOverrideUrlLoading!(controller, navigationAction);
            }
            // always allow all the other requests
            return NavigationActionPolicy.ALLOW;
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
          },
          onLoadError: (_, __, int code, String message) {
            if (widget.onPageError != null) {
              widget.onPageError!(code, message);
            }
            _webViewCubit?.showLinearProgressIndicator(false, 1);
          },
        ),
        if (_webViewCubit != null)
          BlocProvider(
            create: (context) => _webViewCubit!,
            child: BlocBuilder<WebViewCubit, FlowState>(
              buildWhen: (previous, current) => current is LinearProgressIndicatorState,
              builder: (context, state) {
                return state is LinearProgressIndicatorState && state.progress < 1.0 ? ACircularProgress() : Container();
              },
            ),
          )
      ],
    );
  }

  setCookies(String url) {
    if (isOnline) {
      loadedUrlList.add(url);
      if (!aSessionId.isNullOrEmpty()) {
        cookieManager.setCookie(
          url: Uri.parse(url),
          name: "ASessionID",
          value: aSessionId!,
          domain: domain,
        );
        cookieManager.setCookie(
          url: Uri.parse(url),
          name: "ASessionID",
          value: aSessionId!,
          domain: 'appbuilderqa.asite.com',
        );
        cookieManager.setCookie(
          url: Uri.parse(url),
          name: "ASessionID",
          value: aSessionId!,
          domain: '.asite.com',
        );
      } else {
        Log.i('Failed to set aSessionId.');
      }
      if (!jSessionId.isNullOrEmpty()) {
        cookieManager.setCookie(
          url: Uri.parse(url),
          name: "JSESSIONID",
          value: jSessionId!,
          domain: '.asite.com',
        );
      } else {
        Log.i('Failed to set jSessionId.');
      }

      cookieManager.setCookie(
        url: Uri.parse(url),
        name: "applicationId",
        value: '3',
        domain: domain,
      );

      if (widget.setCookies != null) {
        widget.setCookies!(url, cookieManager);
      }
    }
  }

  @override
  void dispose() {
    for (var element in loadedUrlList) {
      cookieManager.deleteCookies(url: Uri.parse(element));
    }
    //cookieManager.deleteAllCookies();

    // localhostServer.close();

    super.dispose();
  }
}
