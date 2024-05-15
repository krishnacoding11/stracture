import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/site/create_form_cubit.dart';
import 'package:field/bloc/site/inline_attachment_success_state.dart';
import 'package:field/bloc/site/offline_attachment_success_state.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/enums.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/presentation/screen/bottom_navigation/tab_navigator.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/file_utils.dart';
import 'package:field/utils/html_interceptor.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/qrcode_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/a_file_picker.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/web_view_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import '../../../bloc/site/xsn_inline_attachment_success_state.dart';
import '../../../data/model/pinsdata_vo.dart';
import '../../../networking/network_info.dart';
import '../../../utils/site_utils.dart';
import '../../../widgets/app_permission_handler.dart';
import '../../managers/font_manager.dart';

class AsiteWebView extends StatefulWidget {
  final String title;
  final String url;
  final Map<String, dynamic> data;
  final Widget? appbarHeaderWidget;
  final bool isAppbarRequired;
  final String snaggingGuid;

  const AsiteWebView({
    Key? key,
    required this.url,
    this.title = "",
    required this.data,
    this.appbarHeaderWidget,
    this.isAppbarRequired = true,this.snaggingGuid = "",
  }) : super(key: key);

  @override
  State<AsiteWebView> createState() => AsiteWebViewState();
}

typedef CallBackJSPEvent = Function(String command, String url);

class AsiteWebViewState extends State<AsiteWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? _appWebViewController;
  int attachmentCount = 0;
  String? message;
  String? commId;
  String projectId = "";
  String locationId = "";
  bool isAPICallInProgress = false;
  FromScreen isFromScreen = FromScreen.unknown;
  var arrAttachment = [];
  var dictAttachment = {};
  var dictSubmit = <String, dynamic>{};
  HTMLInterceptor? htmlInterceptor;
  var backwardForwardList = [];
  final CreateFormCubit _createFormCubit = di.getIt<CreateFormCubit>();
  final FieldNavigatorCubit _fieldNavigatorCubit = di.getIt<FieldNavigatorCubit>();
  final ProjectListCubit _cubit = di.getIt<ProjectListCubit>();
  late AProgressDialog? aProgressDialog;
  List<String> listInlineAttachmentActions = ["1203", "1730"];

  late SiteTaskCubit siteTaskCubit;
  late PlanCubit _planCubit;
  String appTypeId = '2';

  @override
  void initState() {
    super.initState();
    initHTMLInterceptor();
    projectId = widget.data['projectId'] ?? "";
    locationId = widget.data['locationId'].toString();
    commId = widget.data['commId'];
    isFromScreen = widget.data['isFrom'] ?? FromScreen.unknown;
    if (isFromScreen == FromScreen.siteTakListing && Utility.isTablet) {
      siteTaskCubit = BlocProvider.of<SiteTaskCubit>(context);
      _planCubit = BlocProvider.of<PlanCubit>(context);
    }
    if (widget.data.containsKey('appTypeId')) {
      appTypeId = widget.data['appTypeId'].toString();
    }

    Future.delayed(Duration.zero, () async {
      aProgressDialog = AProgressDialog(context, isAnimationRequired: true, isWillPopScope: true);
    });
  }

  fetchAttachments(dynamic capturedFile, String imagesFrom, {dynamic inValidFiles}) {
    if (capturedFile != null) {
      Navigator.pushNamed(NavigationUtils.mainNavigationKey.currentContext!, Routes.imageAnnotation, arguments: {"capturedFile": capturedFile, "imagesFrom": imagesFrom, "inValidFiles":inValidFiles, "mimeType" : dictAttachment["fileType"] }).then((value) {
        Log.d("Final path value ==> ${value.runtimeType}");
        (imagesFrom == "Camera") ? _uploadCreateFormAttachments(value) : _uploadCreateFormAttachments(value);
      });
    }
  }

  _uploadCreateFormAttachments(dynamic capturedFile) {
    if (capturedFile is List<XFile> || capturedFile is List<PlatformFile> || capturedFile is List<dynamic>) {
      var temp = capturedFile as List;
      attachmentCount = temp.length;
      for (int i = 0; i < temp.length; i++) {
        String filePath = (capturedFile is List<String>) ? temp[i] : temp[i].path ?? "";
        if (isInlineAttachment()) {
          _createFormCubit.uploadInlineAttachment(projectId, filePath, dictAttachment, appTypeId);
        } else {
          _createFormCubit.uploadAttachment(projectId, filePath, dictAttachment['ATTACHTEMP_FOLDERID'] ?? "", appTypeId);
        }
      }
    }
  }

  callbackJSPEvent(String command, String url,{FireBaseFromScreen screenName = FireBaseFromScreen.homePage}) async {

    if (command.contains('uploadAttachment')) {
      try {
        List<String> data = url.split("uploadAttachment:");
        String jsonString = Uri.decodeFull(data[1]);
        try {
          dictAttachment = json.decode(jsonString);
        } on FormatException catch (e) {
          print(e);
          dictAttachment = json.decode(jsonString.replaceAllMapped(RegExp(r'/("x|"y|":)'), (match) => '\\${match.group(1)}'));
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      showBottomSheetDialog();
    } else if (command.contains('OfflineFormSubmitClicked')) {
      try {
        dictSubmit = Utility.parseEventActionUrl(url, "OfflineFormSubmitClicked");
        commId = dictSubmit["formId"] ?? commId;
        if (isFromScreen == FromScreen.siteTakListing && dictSubmit["isCopySiteTask"] && Utility.isTablet) {
          _planCubit.refreshPins();
          siteTaskCubit.emitState(RefreshSiteTaskListItemState(null));
        }
      } catch (e) {
        //
      }
      await actionComplete(url);
    } else if (command == 'action-complete') {
      await actionComplete(url);
    } else if (command.contains('actionUpdate')) {
      dictSubmit = Utility.parseEventActionUrl(url, "actionUpdate");
      // It should go back to previous page only when there is no actionId, if actionId is present than it should check for Respond and StatusChange option.
      if(!dictSubmit.containsKey('actionId') ||
          (dictSubmit.containsKey('actionId') &&
              (dictSubmit['actionId'].toString() == FormAction.respond.value ||
                  dictSubmit['actionId'].toString() == FormAction.forStatusChange.value))) {
        dictSubmit['projectId'] = projectId;
        dictSubmit['formId'] = commId;
        await actionComplete(url);
      }
    } else if (['cancel', 'backClicked', 'offLineHtmlFormCancel'].contains(command)) {
      for (String path in arrAttachment) {
        await deleteFileAtPath(path);
      }
      if (isFromScreen == FromScreen.task || isFromScreen == FromScreen.quality) {
        navigateBackWithResult();
      } else if (command == 'backClicked' && isFromScreen == FromScreen.planView) {
        dictSubmit['projectId'] = projectId;
        dictSubmit['formId'] = widget.data['formId'];
        dictSubmit['backClicked'] = true;
        navigateBackWithResult();
      } else if (command.contains('offLineHtmlFormCancel')) {
        Uri? controllerUri = await _appWebViewController?.getUrl();
        bool isCopySiteTask = widget.data['isCopySiteTask'] ?? false;
        if (controllerUri.toString() != widget.url && (!isCopySiteTask || (isCopySiteTask && isFromScreen == FromScreen.siteTakListing && Utility.isTablet))) {
          _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url)));
        } else {
          navigateBackWithResult();
        }
      } else if (command.contains('cancel') && isFromScreen == FromScreen.siteTakListing && Utility.isTablet) {
        Uri? controllerUri = await _appWebViewController?.getUrl();
        if (controllerUri.toString() != widget.url) {
          _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url)));
        } else {
          navigateBackWithResult();
        }
      } else {
        if (NavigationUtils.mainCanPop()) {
          NavigationUtils.mainPop();
        }
      }
    } else if (command.contains('FormSubmitClicked')) {
      try {
        dictSubmit = Utility.parseEventActionUrl(url, "FormSubmitClicked");
        commId = dictSubmit["formId"] ?? commId;
        FireBaseEventAnalytics.setEvent(FireBaseEventType.saveForm, screenName,bIncludeProjectName: true);
      } catch (e) {
        //
      }
    } else if (command.contains('navigateToPlanView')) {
      try {
        dictSubmit = Utility.parseEventActionUrl(url, 'navigateToPlanView');
        ObservationData frmData = ObservationData.fromJson(dictSubmit);
        dictSubmit['locationId'] = frmData.locationDetailVO?.locationId;
        projectId = frmData.projectId ?? "";
        Project? temp = await StorePreference.getSelectedProjectData();
        String pid = temp?.projectID ?? "";
        if (frmData.projectId.plainValue() == pid.plainValue()) {
          if (!frmData.locationDetailVO!.locationId!.toString().isNullEmptyZeroOrFalse()) {
            aProgressDialog?.show();
            isAPICallInProgress = true;
            _fieldNavigatorCubit.getLocationDetails(frmData.locationDetailVO!.locationId!.toString(), frmData.projectId!);
          } else {
            navigateBackWithResult();
          }
        } else {
          aProgressDialog?.show();
          isAPICallInProgress = true;
          Popupdata data = Popupdata(id: frmData.projectId);
          await _cubit.getProjectDetail(data, false);
        }
      } catch (e) {
        //
      }
    } else if (command.contains('discardDraft')) {
      if (isFromScreen == FromScreen.task) {
        dictSubmit = Utility.parseEventActionUrl(url, command);
        //dictSubmit argument will pop after action-complete
        if (dictSubmit.length == 1) {
          dictSubmit['formDiscardDraft'] = true;
        }
        //no need to pop here, automatic return from action-complete
      }
    } else if (command == 'offLineHtmlFormAttachment') {
      dictAttachment = {};
      showBottomSheetDialog();
    } else if (command.contains('downloadZip')) {
      try {
        aProgressDialog?.show();
        Map<String, dynamic> data = jsonDecode(Uri.decodeComponent(url.split("downloadZip:")[1]));

        DownloadResponse result = await DownloadFile().downloadFileWithSameExtension(data, onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            double progress = (receivedBytes / totalBytes) * 100;
            Log.d("Download progress File : ${data['fileName']}: ${progress.toStringAsFixed(2)}%");
          }
        });

        aProgressDialog?.dismiss();
        if (result.isSuccess) {
          Utility.showAlertWithOk(context, context.toLocale!.file_downloaded_successfully);
        } else {
          Utility.showAlertWithOk(context, context.toLocale!.failed_file_download);
        }
      } catch (e) {
        aProgressDialog?.dismiss();
        Utility.showAlertWithOk(context, context.toLocale!.failed_file_download);
      }
    } else if (command.contains("backClicked") || command.contains("offLineReplyFormClose")) {
      Uri? controllerUri = await _appWebViewController?.getUrl();
      if (controllerUri.toString() != widget.url) {
        _appWebViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url)));
      } else {
        navigateBackWithResult();
      }
    } else if (command.contains('offlineAppAssociationClick')) {
      List<String> data = url.split("js-frame:offlineAppAssociationClick:");
      String jsonString = Uri.decodeFull(data[1]);
      var result = json.decode(jsonString);
      if (result != '') {
        final path = await FileFormUtility.getOfflineViewFormPath(result);
        if (path.isNotEmpty && (result['isAvailableOffline'] ?? false)) {
          await FileFormUtility.showFileFormViewDialog(context, frmViewUrl: path, data: result, callback: (value) async {
            if (value is Map && value.isNotEmpty) {
              if (NavigationUtils.mainCanPop()) {
                NavigationUtils.mainPopWithResult(value);
              } else {
                _appWebViewController?.reload();
              }
            }
          });
        } else {
          Utility.showAlertWithOk(context, context.toLocale!.lbl_not_synced_offline);
        }
      }
    }
  }

  Future<void> actionComplete(String url) async {
    if (isFromScreen == FromScreen.qrCode || isFromScreen == FromScreen.dashboard || isFromScreen == FromScreen.task) {
      Project? temp = await StorePreference.getSelectedProjectData();
      String pid = temp?.projectID ?? "";
      if (projectId.plainValue() == pid.plainValue()) {
        if (!dictSubmit['locationId'].toString().isNullEmptyZeroOrFalse()) {
          isAPICallInProgress = true;
          aProgressDialog?.show();
          _fieldNavigatorCubit.getLocationDetails(dictSubmit['locationId'].toString(), projectId);
        } else {
          navigateBackWithResult();
        }
      } else {
        isAPICallInProgress = true;
        Popupdata data = Popupdata(id: projectId);
        await _cubit.getProjectDetail(data, false);
      }
    } else if (isFromScreen == FromScreen.siteTakListing) {
      if (Utility.isTablet) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          // Do something
          if (url == "discard-draft") {
            dictSubmit['projectId'] = projectId;
            dictSubmit['formId'] = commId;
            dictSubmit['isFromDiscardDraft'] = true;
            _planCubit.refreshPins();
            _planCubit.refreshSiteTaskList();
          }
          SiteForm? siteForm = await siteTaskCubit.getUpdatedSiteTaskItem(projectId, commId.plainValue());
          if (siteForm != null) {
            _planCubit.refreshPinAfterFormStatusChanged(siteForm);
          }
        });
      } else {
        dictSubmit['projectId'] = projectId;
        dictSubmit['formId'] = commId;
        if (url == "discard-draft") {
          dictSubmit['isFromDiscardDraft'] = true;
        }
        navigateBackWithResult();
      }
    } else if (isFromScreen == FromScreen.planView) {
      //
      // Future.delayed(const Duration(milliseconds: 500)).then((value) async => await _planCubit.getUpdatedSiteTaskItem(projectId, commId?.plainValue()));
      dictSubmit['projectId'] = projectId;
      dictSubmit['formId'] = commId;
      if (url == "discard-draft") {
        dictSubmit['isFromDiscardDraft'] = true;
      }
      navigateBackWithResult();
    } else if (isFromScreen == FromScreen.quality) {
      dictSubmit['isActionCompleted'] = true;
      navigateBackWithResult();
    } else {
      //for other screen, default action is just close webview
      navigateBackWithResult();
    }
  }

  /// Used to handle crash as it is app webview platform issue for android.
  void navigateBackWithResult() {
    setState(() {
      isBackPress = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (NavigationUtils.mainCanPop()) {
        aProgressDialog?.dismiss();
        NavigationUtils.mainPopWithResult(dictSubmit);
      }
    });
  }

  void evaluateJSForAttachment(String callback, String filePath) async {
    await _appWebViewController?.evaluateJavascript(source: callback, contentWorld: ContentWorld.PAGE);
    arrAttachment.add(filePath);
    attachmentCount = attachmentCount - 1;
    if (attachmentCount <= 0) {
      aProgressDialog?.dismiss();
    }
  }

  bool isInlineAttachment() {
    return dictAttachment.containsKey("action") && listInlineAttachmentActions.contains(dictAttachment["action"]);
  }

  bool isBackPress = false;
  bool isTapped = false;

  @override
  void didChangeDependencies() {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _fieldNavigatorCubit),
        BlocProvider(create: (_) => _createFormCubit),
      ],
          child: MultiBlocListener(
              listeners: [
                BlocListener<CreateFormCubit, FlowState>(listener: (context, state) async {
                  if (state is LoadingState) {
                    aProgressDialog?.show();
                  }
                  if (state is SuccessState) {
                    String command = state.response.data;
                    command = command.replaceAll("\"", "");
                    String callback;
                    bool isForReply = dictAttachment.containsKey('isForReply') && dictAttachment['isForReply'];
                    if (isForReply && isNetWorkConnected()) {
                      callback = 'document.getElementById("reply-frame").contentWindow.FieldAppAttachmentUploadCallback("$command")';
                    } else {
                      callback = 'FieldAppAttachmentUploadCallback("$command")';
                    }
                    evaluateJSForAttachment(callback, state.time.toString());
                  } else if (state is InlineAttachmentSuccessState) {
                    String command = state.response;
                    String callback;
                    bool isForReply = dictAttachment.containsKey('isForReply') && dictAttachment['isForReply'];
                    if (isForReply && isNetWorkConnected()) {
                      callback = 'document.getElementById("reply-frame").contentWindow.FieldAppInlineAttachmentUploadCallback($command)';
                    } else {
                      callback = 'FieldAppInlineAttachmentUploadCallback($command)';
                    }
                    evaluateJSForAttachment(callback, state.time.toString());
                  }else if (state is SendDataToWebViewState) {

                  } else if (state is XSNInlineAttachmentSuccessState) {
                    var response = state.response;
                    if (response != null) {
                      if (response is String) {
                        String suffix = "</pre>";
                        String prefix = "<pre id='file_content'>";

                        final startIndex = response.indexOf(prefix);
                        final endIndex = response.indexOf(suffix, startIndex);
                        var resultFileName = response.substring(startIndex + prefix.length, endIndex).trim();

                        if (!resultFileName.isNullOrEmpty()) {
                          String callback = 'FieldAppInlineAttachmentUploadCallback("$resultFileName")';
                          evaluateJSForAttachment(callback, state.time.toString());
                        } else {
                          var resultFileName = state.time?.split('/').last;
                          String callback = 'FieldAppInlineAttachmentUploadCallback("$resultFileName")';
                          evaluateJSForAttachment(callback, state.time.toString());
                        }
                      } else {
                        var resultFileName = state.time?.split('/').last;
                        String callback = 'FieldAppInlineAttachmentUploadCallback("$resultFileName")';
                        evaluateJSForAttachment(callback, state.time.toString());
                      }
                    } else {
                      Utility.showAlertWithOk(context, context.toLocale!.error_unable_complete_request);
                    }
                  } else if (state is OfflineAttachmentSuccessState) {
                    String callback = 'offlineAttachmentUploadCallback("${state.response}")';
                    evaluateJSForAttachment(callback, state.time.toString());
                  } else if (state is ErrorState) {
                    attachmentCount = attachmentCount - 1;
                    if (attachmentCount <= 0) {
                      aProgressDialog?.dismiss();
                    }
                    if (state.stateRendererType == StateRendererType.isValid) {
                      deleteFileAtPath(state.time.toString());
                    }
                    Utility.showAlertWithOk(context, state.message);
                  }
                }),
                BlocListener<ProjectListCubit, FlowState>(listener: (context, state) async {
                  if (state is ProjectDetailSuccessState) {
                    if (!dictSubmit['locationId'].toString().isNullEmptyZeroOrFalse()) {
                      _fieldNavigatorCubit.getLocationDetails(dictSubmit['locationId'].toString(), projectId);
                    } else {
                      navigateBackWithResult();
                    }
                  } else if (state is ProjectErrorState) {
                    isAPICallInProgress = false;
                    aProgressDialog?.dismiss();
                    Utility.showAlertWithOk(context, state.exception.message);
                  } else {
                    isAPICallInProgress = false;
                  }
                }),
                BlocListener<FieldNavigatorCubit, FlowState>(listener: (context, state) async {
                  if (state is SuccessState) {
                    var dict = state.response['arguments'];
                    dict['createdFormDetails'] = dictSubmit;
                    dict['isFrom'] = isFromScreen;
                    dict['appTypeId'] = appTypeId;
                    var isPlanAvailable = SiteUtility.isLocationHasPlan(dict['selectedLocation']);
                    if (!isPlanAvailable && dict['appTypeId'] != '2') {
                      context.showSnack(context.toLocale!.form_created);
                      navigateBackWithResult();
                      return;
                    }
                    if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.sites) {
                      getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.sites);
                      getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.sites);
                    }
                    await Future.delayed(const Duration(milliseconds: 100));
                    isAPICallInProgress = false;
                    aProgressDialog?.dismiss();
                    NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.sitePlanView, argument: dict);
                    navigateBackWithResult();
                  } else if (state is ErrorState) {
                    isAPICallInProgress = false;
                    aProgressDialog?.dismiss();
                    try {
                      dynamic jsonResponse = jsonDecode(state.message);
                      String errorMsg = jsonResponse['msg'];
                      errorMsg = errorMsg.isNullOrEmpty() ? QrCodeUtility.getQrError(jsonResponse['key']) : errorMsg;
                      Utility.showAlertWithOk(context, errorMsg);
                    } catch (e) {
                      //
                    }
                  } else {
                    isAPICallInProgress = false;
                  }
                })
              ],
              child: WillPopScope(
                onWillPop: () async {
                  navigateBackWithResult();
                  if (dictSubmit.isNotEmpty) {
                    return false;
                  }
                  return true;
                },
                child: Scaffold(
                    appBar: (widget.isAppbarRequired)
                        ? AppBar(
                            centerTitle: true,
                            title: widget.appbarHeaderWidget ??
                                Text(
                                  widget.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                            titleTextStyle: const TextStyle(color: AColors.black, fontFamily: "Sofia", fontWeight: AFontWight.medium, fontSize: 20),
                            // toolbarHeight: 25,
                            backgroundColor: AColors.white,
                            elevation: 1,
                            //automaticallyImplyLeading: true,
                            leading: InkWell(
                              onTap: () {
                                if (!isTapped) {
                                  isTapped = true;
                                  navigateBackWithResult();
                                  getIt<online_model_viewer.OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "PinManager.disablePinOperator()");
                                }
                              },
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : null,
                    body: SafeArea(
                        child: (!isBackPress)
                            ? WebViewWidget(
                                key: webViewKey,
                                url: widget.url,
                                shouldOverrideUrlLoading: (webViewController, navigationAction) async {
                                  var request = navigationAction.request;
                                  var url = request.url;
                                  var urlPath = request.url?.path;
                                  bool absolute = url!.hasAbsolutePath;
                                  if ((urlPath.toString().contains('viewForm.jsp') || urlPath.toString().contains('fileView.jsp')) && url.toString() != widget.url) {
                                    if (!backwardForwardList.contains(url)) {
                                      backwardForwardList.add(url);
                                    }
                                  }
                                  if (absolute == false) {
                                    var prefix = 'js-frame:';
                                    //var restPattern = r'[a-zA-Z0-9]';
                                    var myRegExp = RegExp(RegExp.escape(prefix));
                                    var startsWith = url.toString().startsWith(myRegExp);
                                    if (startsWith) {
                                      var parts = url.toString().split(':');
                                      if (parts.length >= 2) {
                                        var command = parts[1].trim();
                                        if (command == 'backClicked' || command == 'cancel') {
                                          if (backwardForwardList.isNotEmpty) {
                                            backwardForwardList.removeLast();
                                            await webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url)));
                                          } else {
                                            htmlInterceptor?.handleJSPCommand(webViewController, url.toString(), prefix);
                                          }
                                        } else {
                                          htmlInterceptor?.handleJSPCommand(webViewController, url.toString(), prefix);
                                        }
                                      }
                                    }
                                    return NavigationActionPolicy.CANCEL;
                                  }
                                  // always allow all the other requests
                                  return NavigationActionPolicy.ALLOW;
                                },
                                onWebViewCreated: (webViewController) {
                                  _appWebViewController = webViewController;
                                  _createFormCubit.emit(SendDataToWebViewState());
                                },
                                setCookies: (url, cookieManager) {},
                              )
                            : Container())),
              ))
    );
  }

  void showBottomSheetDialog() {
    final ctx = NavigationUtils.mainNavigationKey.currentContext ?? context;
    showModalBottomSheet(
        context: ctx,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (_) {
          return SizedBox(
            height: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: InkWell(
                    key: const Key("camera_item"),
                    splashColor: AColors.themeBlueColor, // splash color
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      var permissionHandlerPermissionService = PermissionHandlerPermissionService();
                      permissionHandlerPermissionService.checkAndRequestCameraPermission((bool isGranted) {
                        if (isGranted) {
                          Navigator.pushNamed(ctx, Routes.aCamera, arguments: {"allowMultiple": "true", "onlyImage": "false"}).then((dynamic capturedImage) {
                            Log.d("Images/Videos => $capturedImage");
                            AFilePicker().validateSelectedFileFromCamera(capturedImage, dictAttachment["fileType"] ?? "", (selectImage) {
                              if (selectImage?["validFiles"] != null) {
                                Log.d("Valid Images/Videos => ${selectImage["validFiles"].toString()}");
                                fetchAttachments(selectImage["validFiles"], AConstants.camera, inValidFiles: selectImage["inValidFiles"]);
                              } else if (selectImage?["inValidFiles"] != null) {
                                Utility.showAlertWithOk(context, selectImage["inValidFiles"][0]);
                              }
                            });
                          });
                        } else {
                          permissionHandlerPermissionService.showPermissionMessageDialog(context);
                        }
                      });
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                          size: 35,
                          color: AColors.aPrimaryColor,
                        ),
                        // icon
                        const SizedBox(
                          height: 8,
                        ),
                        NormalTextWidget(context.toLocale!.take_a_picture),
                        // text
                      ],
                    ),
                  ),
                ),
                // Expanded(
                //   child: InkWell(
                //     splashColor: AColors.themeBlueColor, // splash color
                //     onTap: () {
                //       Navigator.of(context, rootNavigator: true).pop();
                //       Navigator.pushNamed(context, Routes.audioRecord)
                //           .then((dynamic capturedAudio) {
                //         Log.d("Audio path ==> $capturedAudio");
                //       });
                //     }, // button pressed
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: const <Widget>[
                //         Icon(Icons.audiotrack, size: 35), // icon
                //         SizedBox(
                //           height: 8,
                //         ),
                //         Text("Audio"), // text
                //       ],
                //     ),
                //   ),
                // ),
                Expanded(
                  child: InkWell(
                    splashColor: AColors.themeBlueColor, // splash color
                    key: const Key("select_picture_item"),
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      aProgressDialog?.show();
                      await AFilePicker().getMultipleImages((error, stackTrace) {
                        aProgressDialog?.dismiss();
                        if (error is PlatformException) {
                          PermissionHandlerPermissionService().showPermissionMessageDialog(context);
                        }
                      }, FileType.image, (selectImage) {
                          aProgressDialog?.dismiss();
                          if (selectImage?["validFiles"] != null) {
                            Log.d("File => ${selectImage["validFiles"].toString()}");
                            fetchAttachments(selectImage["validFiles"], AConstants.gallery, inValidFiles: selectImage["inValidFiles"]);
                          } else if (selectImage?["inValidFiles"] != null) {
                            Utility.showAlertWithOk(context, selectImage["inValidFiles"][0]);
                          }
                      }, dictAttachment["fileType"] ?? "");
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo_library,
                          size: 35,
                          color: AColors.aPrimaryColor,
                        ),
                        //
                        const SizedBox(
                          height: 8,
                        ),
                        NormalTextWidget(context.toLocale!.select_a_photo),
                        // text
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    splashColor: AColors.themeBlueColor, // splash color
                    key: const Key("select_file_item"),
                    onTap: () async {
                      Navigator.of(ctx).pop();

                      aProgressDialog?.show();
                      await AFilePicker().getMultipleImages((error, stackTrace) {
                        aProgressDialog?.dismiss();
                        if (error is PlatformException) {
                          PermissionHandlerPermissionService().showPermissionMessageDialog(context);
                        }
                      }, FileType.any, (selectImage) {
                          aProgressDialog?.dismiss();
                          if (selectImage["validFiles"] != null) {
                            Log.d("File => ${selectImage["validFiles"].toString()}");
                            fetchAttachments(selectImage["validFiles"], AConstants.gallery, inValidFiles: selectImage["inValidFiles"]);
                          } else if (selectImage["inValidFiles"] != null) {
                            Utility.showAlertWithOk(context, selectImage["inValidFiles"][0]);
                          }
                      }, dictAttachment["fileType"] ?? "");
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.file_copy,
                          size: 35,
                          color: AColors.aPrimaryColor,
                        ),
                        //
                        const SizedBox(
                          height: 8,
                        ),
                        NormalTextWidget(context.toLocale!.select_a_file),
                        // text
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    isTapped = false;
    super.dispose();
    AFilePicker().clearTemporaryFolder();
  }

  Future<void> initHTMLInterceptor() async {
    htmlInterceptor = HTMLInterceptor(context, callbackJSPEvent, widget.data);
    await htmlInterceptor?.init();
  }
}
