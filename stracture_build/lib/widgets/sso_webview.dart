import 'package:dio/dio.dart';
import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/data/model/login_exception.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import '../bloc/login/login_cubit.dart';
import '../bloc/login/login_state.dart';
import '../data/model/user_vo.dart';
import '../logger/logger.dart';

class SSOWebView extends StatefulWidget {
  final String url;
  final String emailId;
  const SSOWebView({Key? key, required this.url, required this.emailId}) : super(key: key);

  @override
  State<SSOWebView> createState() => _SSOWebViewState();

  static String getWebViewUrl(DatacenterVo item) {
    String? ssoIdentityProvider = item.ssoIdentityProvider;
    String webUrl = "";
    if (ssoIdentityProvider!.isNotEmpty) {
      String? trgtUrl = item.ssoTargetURL;
      if (ssoIdentityProvider.contains("?")) {
        webUrl = "$ssoIdentityProvider&loginToRp=${trgtUrl!}";
      } else {
        webUrl = "$ssoIdentityProvider?loginToRp=${trgtUrl!}";
      }
    }
    if (webUrl == "") {
      webUrl = AConstants.ssoAsiteAdfsUrl;
    }
    Log.d(webUrl);
    return webUrl;
  }

  static dynamic onSSOLoginResponse(var response, String email) {
    if ((response[0] as User).apiResponseFailure != null) {
      if ((response[0] as User).apiResponseFailure is AsiteApiExceptionThrown) {
        if (response[0].apiResponseFailure is AsiteApiExceptionThrown) {
          var exception = response[0].apiResponseFailure as AsiteApiExceptionThrown;
          return exception.errormessage;
        }
      } else {
        User data = response[0];
        Headers? resHeader = response[1];
        if (data.apiResponseFailure['isSecondaryAuthEnabled'] != null &&
            data.apiResponseFailure['isSecondaryAuthEnabled']
                .toString()
                .toLowerCase() ==
                'true') {
          data.apiResponseFailure['email'] = email;
          // user.apiResponseFailure['password'] = _passwordController.text;
          data.apiResponseFailure['userName'] = data.apiResponseFailure['userName'];
          String? jsessionid = resHeader?.getJSessionId().toString() ?? "";
          data.apiResponseFailure['JSESSIONID'] = jsessionid;
          StorePreference.setStringData('2FA', DateTime.now().toString());
          return data.apiResponseFailure;
        }
      }
    }
    return null;
  }
}

class _SSOWebViewState extends State<SSOWebView> {
  InAppWebViewController? webView;
  final LoginCubit _loginCubit = di.getIt<LoginCubit>();
  bool isBlock = false;
  bool isProceedForLogin = false;
  late AProgressDialog? aProgressDialog;
  String? message;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    aProgressDialog = AProgressDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    var webViewObject = InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(widget.url),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
        },
        shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
          var uri = Uri.parse(shouldOverrideUrlLoadingRequest.request.url.toString());
          if (isBlock == true) {
            Log.d("block shouldOverrideUrlLoading -- ${uri.toString()}");
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) async {
          _runJavaScript(controller, url!,"onUpdateVisitedHistory");
        },
        onLoadStop: (InAppWebViewController controller, Uri? url) async {
          _runJavaScript(controller, url!,"onLoadStop");
        },
        onLoadError: (controller, url, code, message) async {
          Log.d("sso_webView code:$code Error:$message");
          if(isBlock == false && isProceedForLogin == false) {
            showErrorDialog(message);
          }
        },
        onProgressChanged: (controller, progress) {
          if(isLoading == true && progress == 100){
            setState(() {
              isLoading = false;
            });
          }
        },
        initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
              disableDefaultErrorPage: false,
              loadWithOverviewMode: true
          ),
          crossPlatform: InAppWebViewOptions(javaScriptEnabled: true, mediaPlaybackRequiresUserGesture: false, useShouldOverrideUrlLoading: true, clearCache: true),
        ),
        androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
          return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
        });
    return BlocListener<LoginCubit, FlowState>(
        listener: (context, state) {
          aProgressDialog?.dismiss();
          if (state is SSOSuccessState) {
            dynamic data = state.response.data;
            Headers? resHeader = state.response.responseHeader;
            Navigator.of(context).pop([data,resHeader]);
          } else if (state is ErrorState) {
            Navigator.of(context).pop(state.message);
            // } else if(state is LoadingState){
            //   aProgressDialog?.show();
          }
        },
        child: SafeArea(
          child: Stack(
              children: [
                webViewObject,
                Visibility(
                    visible: isLoading,
                    child: const ACircularProgress()
                )
              ]
          ),
        )
    );
  }

  _runJavaScript(InAppWebViewController controller, Uri url,String callbackFrom) async {
    dynamic html;
    try {
      String jsScript = "javascript:HTMLViewer.showHTML(document.getElementsByTagName('html')[0].innerHTML)";
      await controller.evaluateJavascript(source: jsScript);

      html = await controller.evaluateJavascript(source: "window.document.getElementsByTagName('html')[0].outerHTML;");
    }
    on Exception catch (e) {
      //exception msg using logger
    }
    if (html != null && html.toString().isNotEmpty && isProceedForLogin == false) {
      _parseHtmlAndProceedForLogin(html,callbackFrom);
    }
  }

  _parseHtmlAndProceedForLogin(dynamic html,String callbackFrom){
    try {
      Document document = parse(html);
      if(document.getElementsByTagName("input").isNotEmpty) {
        String? samlTag = document
            .getElementsByTagName("input")
            .elementAt(0)
            .attributes['name'];
        if (samlTag != null && samlTag.isNotEmpty && samlTag == "SAMLResponse") {
          setState(() {
            isBlock = true;
            isProceedForLogin = true;
          });
          Log.d("Proceed for App-login from webView-$callbackFrom");
          String? samlResponse = document.getElementsByTagName("input")[0].attributes['value'];
          _loginCubit.doSSOLogin(widget.emailId,samlResponse!);
        }
      }
    }
    on Exception catch (e) {
      //exception msg using logger
    }
  }

  showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const NormalTextWidget('Message'),
        content: NormalTextWidget(message),
        actions: [
          AElevatedButtonWidget(
          btnLabel: "Ok",
          btnLabelClr:Colors.white,
          btnBackgroundClr: AColors.themeBlueColor,
          onPressed: () {
                Navigator.of(context).pop();
                },
          ),
        ],
      ),
    );
    Navigator.of(context).pop();
  }
}
