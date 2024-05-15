import 'dart:convert';
import 'dart:io';

import 'package:field/data_source/forms/view_form_local_data_source.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/pdftron/document_viewer.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mime/mime.dart';

import '../data/local/site/site_local_repository.dart';
import '../data_source/forms/create_form_local_data_source.dart';
import '../logger/logger.dart';
import 'app_path_helper.dart';
import 'file_utils.dart';

class HTMLInterceptor {
  ViewFormLocalDataSource? _viewFormLocalDataSource;
  CreateFormLocalDataSource? _createFormLocalDataSource;

  Map<String, dynamic> data;
  String formId = "";
  BuildContext context;
  Function callbackJSPEvent;
  InAppWebViewController? controller;

  HTMLInterceptor(this.context, this.callbackJSPEvent, this.data);

  Future<void> init() async {
    if (!isNetWorkConnected()) {
      _viewFormLocalDataSource ??= ViewFormLocalDataSource();
      _createFormLocalDataSource ??= CreateFormLocalDataSource();
      await _viewFormLocalDataSource?.init();
      await _createFormLocalDataSource?.init();
    }
    formId = data['formId'] ?? "";
  }

  Future<void> handleJSPCommand(InAppWebViewController controller, String url, String prefix) async {
    this.controller = controller;
    var parts = url.split(prefix);
    Log.d("Handle JSP:$url");

    if (parts.length < 2) {
      return;
    }
    // if()
    var command = parts[1].trim();
    var decodeSucceeded = false;
    Map<String, dynamic> decodedJSON = {};
    try {
      command = Uri.decodeFull(command);
      if (command.startsWith('{')) {
        try {
          decodedJSON = json.decode(command) as Map<String, dynamic>;
        } on FormatException catch (_) {
          try {
            decodedJSON = json.decode(command.replaceAll('/\"', '\\"')) as Map<String, dynamic>;
          } on FormatException catch (_) {
            decodedJSON = json.decode(command.replaceAll('\\', '\\\\')) as Map<String, dynamic>;
          }
        }
        decodeSucceeded = true;
      }
    } on FormatException catch (e) {
      Log.e('HTMLInterceptor::decodedJSON The provided string is not valid JSON $e');
    }
    if (decodeSucceeded) {
      if (decodedJSON.containsKey('lan')) {
        String languageId = await StorePreference.getUserCurrentLanguage() ?? "en_gb";
        languageId = languageId.toString().toLowerCase();
        String path = "assets/platformlocalization/app_${languageId}.json";
        String jsCode;
        try {
          jsCode = await rootBundle.loadString(path);
        } catch(_) {
          jsCode = await rootBundle.loadString("assets/platformlocalization/app_en_gb.json");
        }
        controller.evaluateJavascript(source: 'langResponseCallBack($jsCode)');

      } else if (decodedJSON.containsValue("backClicked") || decodedJSON.containsValue("offLineReplyFormClose")) {
        callbackJSPEvent(command, url);
      } else if (decodedJSON.containsKey('data')) {
        decodedJSON = decodedJSON['data'] as Map<String, dynamic>;
        if (decodedJSON.containsKey('action_id')) {
          int actionId = decodedJSON['action_id'];
          switch (actionId) {
            case AConstants.PROJECT_PRIVILEGES:
              getProjectPrivilege(decodedJSON);
              break;
            case AConstants.VIEW_FORM_MSG_DETAILS_ACTION:
              viewFormMessageHtmlResponse(decodedJSON);
              break;
            case AConstants.MESSAGE_THREADS:
              messageThreadResponse(decodedJSON);
              break;
            case AConstants.ATTACHMENT_ASSOCIATION_COLUMN_HEADER:
              attachmentAndAssociationColumnHeadersListJson(decodedJSON);
              break;
            case AConstants.REQUEST_FIELD_ENABLED_PROJECT:
              getFieldEnabledProjects(decodedJSON);
              break;
            case AConstants.REQUEST_LOCATION:
              getLocations(decodedJSON);
              break;
            case AConstants.REQUEST_LOCATION_TREE:
              getLocationsTree(decodedJSON);
              break;
            case AConstants.REQUEST_GET_ASSOCIATE_LOCATION_TREE_BY_SEARCH:
              getAssociatedLocationTreeBySearch(decodedJSON);
              break;
            case AConstants.REQUEST_GET_RESULT_ASSOCIATE_LOCATION_TREE_BY_SEARCH:
              getSelectedAssociatedLocationTreeBySearch(decodedJSON);
              break;
            case AConstants.DISTRIBUTION:
              getDistributionList(decodedJSON);
              break;
            case AConstants.ADODDLE_FORM_PERMISSIONS:
              getFormPermissionResponseToHTML(decodedJSON);
              break;
            case AConstants.DISPLAY_FORM_CHANGE_STATUS:
              displayFormChangeStatusToHTML(decodedJSON);
              break;
            case AConstants.REQUEST_SAVE_STATUS_CHANGE:
              saveFormChangeStatusToHTML(decodedJSON);
              break;
            case AConstants.ATTACHMENT_ASSOCIATION:
              getAttachmentAssociationListToHTML(decodedJSON);
              break;
            case AConstants.REPLY_ACTION_ID:
            case AConstants.INITIATE_EDIT_FORM_MSG_COMMITED:
              if (decodedJSON["isCallFor"].toString().toLowerCase() == "editdraft") {
                editDraftToHTML(decodedJSON);
              } else {
                replyRespondHTML(decodedJSON);
              }
              break;
            case AConstants.REQUEST_DISCARD_DRAFT:
              discardDraftHTML(decodedJSON);
              break;
            case AConstants.REQUEST_COPY_DEFECT:
              getFieldCopyFormHtml5Json(decodedJSON);
              break;
            case AConstants.REQUEST_EDIT_ORI:
              editOri(decodedJSON);
              break;
            case AConstants.EDIT_AND_DISTRIBUTE:
              editDistributeHTMLForm(decodedJSON);
              break;
            case AConstants.REQUEST_SAVE_ACKNOWLEDGEMENT:
              saveAcknowledgement(decodedJSON);
              break;
            case AConstants.REQUEST_SAVE_ACTION:
              saveAction(decodedJSON);
              break;
            case AConstants.REQUEST_SAVE_DISTRIBUTION:
              saveDistribution(decodedJSON);
              break;
            case AConstants.REQUEST_RELEASE_RESPONSE:
              getReleaseResponse(decodedJSON);
              break;
            case AConstants.REQUEST_GET_OBSERVATION_LIST_BY_PLAN:
              getObservationDetail(decodedJSON);
              break;
            default:
              break;
          }
        }
      }
    } else {
      if (command.contains('uploadAttachment')) {
        // if (components.length > 1) {
        callbackJSPEvent(command, url);
        // }
      } else if (command.contains('viewCreateAttachment')) {
        List<String> data = url.split("js-frame:viewCreateAttachment:");
        String jsonString = Uri.decodeFull(data[1]);
        var dictAttachment = json.decode(jsonString);
        if (dictAttachment['OfflineAttachFilePath'] != null) {
          String fileName = dictAttachment['FileName'].toString();
          String path = dictAttachment['OfflineAttachFilePath'].toString();
          viewFileInViewer(fileName, path);
        } else if (dictAttachment['canOpen'] as bool) {
          String fileName = dictAttachment['FileName'].toString();
          String projectID = dictAttachment['thumbnailURL'].toString();
          projectID = projectID.split('projectId=').last;
          projectID = projectID.split('&').first;
          String path = await AppPathHelper().getTemporaryAttachmentPath(fileName: fileName, projectId: projectID);
          viewFileInViewer(fileName, path);
        }
      } else if (command == 'offLineHtmlFormCancel' || command == "offLineFormCancelClicked") {
        Utility.showConfirmationDialog(
            context: context,
            title: context.toLocale!.lbl_confirm,
            msg: context.toLocale!.lbl_confirmation_form_cancel_msg,
            onPressOkButton: (context) {
              Navigator.of(context).pop();
              callbackJSPEvent(command, url);
            });
      } else if (command.contains('offlineCustomAttributeSetData')) {
        List<String> data = url.split("js-frame:offlineCustomAttributeSetData:");
        String jsonString = Uri.decodeFull(data[1]);
        Map<String, dynamic> attributeMap = json.decode(jsonString);
        String attributeSetId = attributeMap['attributeSetId'] ?? "";
        String? dbResponse = _createFormLocalDataSource?.getCustomAttributeSetDataByAttributeSetId(this.data['projectId'] ?? "", attributeSetId);
        controller.evaluateJavascript(source: 'offlineModeCallback(${(dbResponse)})');
      } else if (['cancel', 'backClicked'].contains(command)) {
        await callbackJSPEvent(command, url);
      } else if (command == 'attachmentBackClicked') {
        controller.reload();
      } else if (command == 'offLineHtmlFormSubmit') {
        handleOffLineHtmlFormSubmit(false);
      } else if (command == 'offLineHtmlFormSubmitDraft') {
        handleOffLineHtmlFormSubmit(true);
      } else if (['action-complete', 'offLineHtmlFormAttachment'].contains(command)) {
        callbackJSPEvent(command, url);
      } else if (command.contains('FormSubmitClicked') || command.contains('actionUpdate') || command.contains('navigateToPlanView') || command.contains('discardDraft')) {
        callbackJSPEvent(command, url);
      } else if (command.contains('downloadZip')) {
        callbackJSPEvent(command, url);
      } else if (command.contains('offlineAttachmentAssociationClick:')) {
        List<String> data = url.split("js-frame:offlineAttachmentAssociationClick:");
        String jsonString = Uri.decodeFull(data[1]);
        var dictAttachment = json.decode(jsonString);
        if (dictAttachment != "") {
          viewFileInViewer(dictAttachment.split("/").last, dictAttachment);
        }
      } else if (command.contains("offlineAppAssociationClick")) {
        callbackJSPEvent(command, url);
      }
    }
    // Utils.flushBarErrorMessage(url, context);
  }

  void offlineModeCallback(InAppWebViewController controller, dynamic params) {
    if (params.isNotEmpty) {
      controller.evaluateJavascript(source: 'offlineModeCallback($params)');
    }
  }

  void offlineModeCallToHtml(InAppWebViewController controller, dynamic params, Map<String, dynamic> requestParams) {
    Map<String, dynamic> toMap = {'responseData': params, 'actionId': requestParams['action_id']};
    if (requestParams.containsKey('type')) {
      toMap['type'] = requestParams['type'];
    }
    if (requestParams.containsKey('requestedEntityType')) {
      toMap['requestedEntityType'] = requestParams['requestedEntityType'];
    }
    if (requestParams.containsKey('listingType')) {
      toMap['listingType'] = requestParams['listingType'];
    }

    if (toMap.isNotEmpty) {
      offlineModeCallback(controller, jsonEncode(toMap));
    }
  }

  Future<void> attachmentAndAssociationColumnHeadersListJson(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> request = {};
    request['ListingType'] = decodedJSON['listingType'];
    request['isForSiteTask'] = decodedJSON['isForSiteTask'] ?? true;
    String? columnHeadersListData = await _viewFormLocalDataSource?.getOfflineFormMessageAttachmentAndAssociationColumnHeadersListJson(request);
    if (columnHeadersListData.isNullOrEmpty()) {
      columnHeadersListData = "{}";
    }
    offlineModeCallToHtml(controller!, columnHeadersListData, decodedJSON);
  }

  Future<void> getProjectPrivilege(Map<String, dynamic> decodedJSON) async {
    String? response = await _viewFormLocalDataSource?.getOfflineHTML5ProjectPrivilegeListJson({"projectId": decodedJSON["projectId"].toString()});
    offlineModeCallToHtml(controller!, response, decodedJSON);
  }

  Future<void> viewFormMessageHtmlResponse(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'];
    request['msgId'] = decodedJSON['msgId'];
    request['formId'] = formId;
    String? strFormData = await _viewFormLocalDataSource?.getOfflineFormMessageViewHtml(request);
    offlineModeCallToHtml(controller!, strFormData, decodedJSON);
  }

  Future<void> messageThreadResponse(Map<String, dynamic> decodedJSON) async {
    String projectId = decodedJSON['projectId'].toString();
    String? strMsgThreadData = await _viewFormLocalDataSource?.getOfflineFormMessageListJson(projectId: projectId, formId: formId);
    offlineModeCallToHtml(controller!, strMsgThreadData, decodedJSON);
  }

  Future<void> getFormPermissionResponseToHTML(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'];
    request['msgId'] = decodedJSON['msgId'];
    request['formId'] = formId;
    String? formMsgPermissionData = await _viewFormLocalDataSource?.getOfflineFormMessagePrivilegeListJson(request);
    offlineModeCallToHtml(controller!, formMsgPermissionData, decodedJSON);
  }

  Future<void> displayFormChangeStatusToHTML(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'];
    request['msgId'] = decodedJSON['msgId'];
    request['formId'] = formId;

    String? offlineFormStatusHistoryData = await _viewFormLocalDataSource?.getOfflineFormStatusHistoryListJson(request);
    // var resMap = {"responseData": offlineFormStatusHistoryData, "actionId": decodedJSON['action_id']};
    // offlineModeCallback(controller!, jsonEncode(resMap) ?? "");
    offlineModeCallToHtml(controller!, offlineFormStatusHistoryData, decodedJSON);
  }

  //getAttachmentAssociationListToHTML
  Future<void> getAttachmentAssociationListToHTML(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'];
    request['msgId'] = decodedJSON['msgId'];
    request['requestedEntityType'] = decodedJSON['requestedEntityType'];
    if (decodedJSON['requestedEntityType'].toLowerCase() == "all") {
      request['commId'] = formId;
    } else {
      request['formId'] = formId;
    }
    String? offlineFormStatusHistoryData = await _viewFormLocalDataSource?.getOfflineAttachmentAndAssociationListJson(request);
    offlineModeCallToHtml(controller!, offlineFormStatusHistoryData, decodedJSON);
  }

  void navigateToDocumentViewerScreen(String fileName, String filePath) {
    NavigationUtils.mainPush(context, MaterialPageRoute(builder: (context) => DocumentViewer(title: fileName, filePath: filePath)));
  }

  void getFieldEnabledProjects(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'];
    String? response = _createFormLocalDataSource?.getOfflineProjectListJson(request);
    offlineModeCallToHtml(controller!, response, decodedJSON);
  }

  void getLocations(Map<String, dynamic> decodedJSON) {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'];
    request['folderId'] = "0";
    String? response = _createFormLocalDataSource?.getOfflineLocationListJson(request);
    offlineModeCallToHtml(controller!, response, decodedJSON);
  }

  void getLocationsTree(Map<String, dynamic> decodedJSON) {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'];
    request['folderId'] = decodedJSON['folderId'].toString();
    String? response = _createFormLocalDataSource?.getOfflineLocationListJson(request);
    offlineModeCallToHtml(controller!, response, decodedJSON);
  }

  void getAssociatedLocationTreeBySearch(Map<String, dynamic> decodedJSON) {
    String? response = _createFormLocalDataSource?.getFieldAssociateSearchLocationList(decodedJSON);
    offlineModeCallToHtml(controller!, response, decodedJSON);
  }

  void getSelectedAssociatedLocationTreeBySearch(Map<String, dynamic> decodedJSON) {
    String? response = _createFormLocalDataSource?.getFieldAssociateSearchLocationSelectTreeList(decodedJSON);
    offlineModeCallToHtml(controller!, response, decodedJSON);
  }

  Future<void> getDistributionList(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> request = {};
    request['projectId'] = decodedJSON['projectId'] ?? data['projectId'];
    request['formTypeId'] = decodedJSON['rmft'] ?? data['formTypeId'].toString();
    String? response = await _createFormLocalDataSource?.getDistributionList(request);
    offlineModeCallToHtml(controller!, response, decodedJSON);
  }

  void viewFileInViewer(String fileName, String path) {
    String ext = Utility.getFileExtension(fileName);
    if (Utility.isPDFTronSupported(ext)) {
      navigateToDocumentViewerScreen(fileName, path);
    } else {
      final mimeType = lookupMimeType(path)?.split("/").first.toLowerCase();
      try {
        var platform = const MethodChannel('flutter.native/opendocumentviewer');
        if (mimeType == 'audio') {
          platform.invokeMethod('openAudio', {"filePath": path});
        } else if (mimeType == 'video') {
          platform.invokeMethod('openVideo', {"filePath": path});
        } else {
          platform.invokeMethod('openDocument', {"filePath": path});
        }
      } on PlatformException catch (e) {
        Log.e("HTMLInterceptor::openDocument video PlatformException $e");
      } catch (e) {
        Log.e("HTMLInterceptor::openDocument video Exception $e");
      }
    }
  }

  Future<void> handleOffLineHtmlFormSubmit(bool isDraft) async {
    controller!.evaluateJavascript(source: "getHtmlJsonData();").then((value) async {
      if(value is String){
        var tempData = jsonDecode(value);
        if(tempData is Map){
          if(tempData['myFields'] != null){
            if(tempData['myFields']['create_hidden_list'] != null){
              if(tempData['myFields']['create_hidden_list']['assocLocationSelection'] is String){
                String jsonString = tempData['myFields']['create_hidden_list']['assocLocationSelection'];
                if(jsonString.isNotEmpty){
                  tempData = jsonDecode(jsonString);
                  if(tempData is Map){
                    if(tempData['locationId']!=null){
                      data['locationId'] = tempData['locationId'];
                    }
                  }
                }
              }
            }
          }
        }
      }
      Map<String, dynamic> requestParam = data;
      requestParam.remove('isFrom');
      requestParam.remove('commId');
      requestParam['offlineFormDataJson'] = value;
      requestParam['isDraft'] = isDraft;
      if (requestParam["isCopySiteTask"] ?? false) {
        requestParam.remove("formId");
        requestParam.remove("msgId");
        requestParam["locationId"] = "0";
      }
      Log.d(jsonEncode(requestParam));
      Map<String, dynamic>? response = await _createFormLocalDataSource?.saveFormOffline(requestParam);
      callbackJSPEvent("OfflineFormSubmitClicked", "js-frame:OfflineFormSubmitClicked:${jsonEncode(response)}");
    });
  }

  Future<void> saveFormChangeStatusToHTML(Map<String, dynamic> decodedJSON) async {
    decodedJSON['formId'] = formId;

    String? offlineFormStatusHistoryData = await _createFormLocalDataSource?.changeFieldFormHistoryStatus(decodedJSON);
    offlineModeCallToHtml(controller!, offlineFormStatusHistoryData, decodedJSON);
  }

  Future<void> editDraftToHTML(Map<String, dynamic> decodedJSON) async {
    decodedJSON['formId'] = formId;

    String? editDraftHtmlResponse = await _createFormLocalDataSource?.getCreateOrRespondHtmlJson(EHtmlRequestType.editDraft, decodedJSON);
    if (!editDraftHtmlResponse.isNullOrEmpty()) {
      String url = "${await AppPathHelper().getAssetHTML5FormZipPath()}/createFormHTML.html";
      File file = File(url);
      file.writeAsBytesSync(utf8.encode(editDraftHtmlResponse!));
      var path = "file://${file.path}";
      offlineModeCallToHtml(controller!, path, decodedJSON);
    }
  }

  Future<void> replyRespondHTML(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> requestParam = {};
    requestParam['projectId'] = decodedJSON['projectId'];
    requestParam['formId'] = formId;
    requestParam['formTypeId'] = data['formTypeId'];
    requestParam['templateType'] = data['templateType'];
    if (decodedJSON.containsKey("msgId")) {
      requestParam["msgId"] = decodedJSON["msgId"] ?? "";
    }
    if (decodedJSON.containsKey("parent_msg_id")) {
      requestParam["parent_msg_id"] = decodedJSON["parent_msg_id"] ?? "";
    }
    EHtmlRequestType eHtmlRequestType;
    String strIsCallFor = decodedJSON["isCallFor"].toString().toLowerCase().trim();
    switch (strIsCallFor) {
      case "replyall":
        eHtmlRequestType = EHtmlRequestType.replyAll;
        break;
      case "reply":
        eHtmlRequestType = EHtmlRequestType.reply;
        break;
      case "editori":
        if (decodedJSON.containsKey("msgId")) {
          requestParam["parent_msg_id"] = decodedJSON["msgId"] ?? "";
        }
        eHtmlRequestType = EHtmlRequestType.editOri;
        break;
      default:
        eHtmlRequestType = EHtmlRequestType.respond;
        break;
    }

    String? replyRespondHtmlResponse = await _createFormLocalDataSource?.getCreateOrRespondHtmlJson(eHtmlRequestType, requestParam);
    if (!replyRespondHtmlResponse.isNullOrEmpty()) {
      String url = "${await AppPathHelper().getAssetHTML5FormZipPath()}/RESPOND.html";
      File file = File(url);
      file.writeAsBytesSync(utf8.encode(replyRespondHtmlResponse!));
      var path = "file://${file.path}";
      offlineModeCallToHtml(controller!, path, decodedJSON);
    }
  }

  void editDistributeHTMLForm(Map<String, dynamic> decodedJSON) async {
    Map<String, dynamic> requestParam = decodedJSON;
    requestParam['formId'] = formId;
    requestParam['formTypeId'] = data['formTypeId'];
    requestParam['templateType'] = data['templateType'];
    requestParam['projectId'] = requestParam['project_id'];
    EHtmlRequestType eHtmlRequestType = EHtmlRequestType.editAndDistribute;
    String? htmlResponse = await _createFormLocalDataSource?.getCreateOrRespondHtmlJson(eHtmlRequestType, requestParam);
    if (!htmlResponse.isNullOrEmpty()) {
      String url = "${await AppPathHelper().getAssetHTML5FormZipPath()}/editDistribute_$formId.html";
      File file = File(url);
      file.writeAsBytesSync(utf8.encode(htmlResponse!));
      var path = "file://${file.path}";
      offlineModeCallToHtml(controller!, path, decodedJSON);
    }
  }

  void getFieldCopyFormHtml5Json(Map<String, dynamic> decodedJSON) async {
    decodedJSON['projectId'] = decodedJSON['project_id'];
    String? str = await _createFormLocalDataSource?.getFieldCopyFormHtml5Json(decodedJSON);
    if (!str.isNullOrEmpty()) {
      String url = "${await AppPathHelper().getAssetHTML5FormZipPath()}/CopySiteTask.html";
      File file = File(url);
      file.writeAsBytesSync(utf8.encode(str!));
      var path = "file://${file.path}";
      data['offlineFormId'] = DateTime.now().millisecondsSinceEpoch;
      data['isCopySiteTask'] = true;
      offlineModeCallToHtml(controller!, path, decodedJSON);
    }
  }

  void discardDraftHTML(Map<String, dynamic> decodedJSON) async {
    decodedJSON["projectId"] = data["projectId"];
    decodedJSON["formId"] = data["formId"];
    decodedJSON["formTypeId"] = data["formTypeId"];
    decodedJSON["observationId"] = data["observationId"];
    decodedJSON["locationId"] = data["locationId"];
    String? discardDraftHtmlResponse = await _createFormLocalDataSource?.discardDraft(decodedJSON);
    offlineModeCallToHtml(controller!, discardDraftHtmlResponse, decodedJSON);
    callbackJSPEvent("action-complete", "discard-draft");
  }

  void editOri(Map<String, dynamic> decodedJSON) {
    offlineModeCallToHtml(controller!, "{}", decodedJSON);
  }

  Future<void> saveDistribution(Map<String, dynamic> decodedJSON) async {
    String strActionId = decodedJSON["action_id"]?.toString() ?? "";
    if (strActionId != "26") {
      decodedJSON["actionId"] = "6";
      await _createFormLocalDataSource?.completeOfflineFormActivityForActions(decodedJSON);
    }
    offlineModeCallToHtml(controller!, "[]", decodedJSON);
  }

  Future<void> saveAcknowledgement(Map<String, dynamic> decodedJSON) async {
    await _createFormLocalDataSource?.completeOfflineFormActivityForActions(decodedJSON);
    offlineModeCallToHtml(controller!, "[]", decodedJSON);
  }

  Future<void> saveAction(Map<String, dynamic> decodedJSON) async {
    await _createFormLocalDataSource?.completeOfflineFormActivityForActions(decodedJSON);
    offlineModeCallToHtml(controller!, "[]", decodedJSON);
  }

  Future<void> getReleaseResponse(Map<String, dynamic> decodedJSON) async {
    await _createFormLocalDataSource?.completeOfflineFormActivityForActions(decodedJSON);
    offlineModeCallToHtml(controller!, "[]", decodedJSON);
  }

  Future<void> getObservationDetail(Map<String, dynamic> decodedJSON) async {
    {
      Map<String, dynamic> request = {};
      request['projectId'] = decodedJSON['projectId'];
      request['observationIds'] = decodedJSON['observationIds'];
      SiteLocalRepository siteTaskRepository = getIt<SiteLocalRepository>();
      final result = await siteTaskRepository.getObservationListByPlan(request);
      if (result?.isNotEmpty ?? false) {
        offlineModeCallToHtml(controller!, jsonEncode(result), decodedJSON);
      }
    }
  }
}
