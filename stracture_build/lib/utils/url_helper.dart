import 'package:field/analytics/event_analytics.dart';
import 'package:field/data/dao/url_dao.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/notification_detail_vo.dart';
import 'package:field/data/model/site_form_action.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/enums.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_config.dart';

class UrlHelper {
  static Future<String> getAdoddleURL(int? dcId) async {
    return await UrlHelper.getBaseURL(AConstants.adoddleUrl,dcId);
  }

  static Future<String> getDownloadURL(int? dcId,{bool bAkamaiDownload=true}) async {
    return await UrlHelper.getBaseURL(AConstants.downloadUrl,dcId,bAkamaiDownload: bAkamaiDownload);
  }

  static Future<String> getBaseURL(String baseUrl,int? dcId,{bool bAkamaiDownload=true}) async {
    var userCloud = int.parse(await StorePreference.getUserCloud() ?? "1");
    dcId ??= await StorePreference.getDcId();
    var urlConfig = URLConfig(userCloud, AConstants.buildEnvironment, dcId);
    if (baseUrl.contains("//dms")) {
      baseUrl = await urlConfig.getCollabUrl();
    } else if (baseUrl.contains("//task")) {
      baseUrl = await urlConfig.getTaskUrl();
    } else if (baseUrl.contains("//oauth")) {
      baseUrl = urlConfig.getOAuthUrl();
    } else if (baseUrl.contains("//sync")) {
      baseUrl = await urlConfig.getDownloadUrl();
      if (!bAkamaiDownload) {
        baseUrl = _getAkamaiDownloadUrl(baseUrl, dcId, bAkamaiDownload);
      }
    } else {
      baseUrl = await urlConfig.getAdoddleUrl();
    }
    AConstants.streamingServerUrl = await urlConfig.getStreamingServerUrl();
    return baseUrl;
  }

  static String _getAkamaiDownloadUrl(String baseUrl,int dcId,bool bAkamaiDownload) {
      if (dcId == 1) {
        baseUrl = baseUrl.replaceAll("ak.", ".");
      } else {
        baseUrl = baseUrl.replaceAll("://", "://origin-");
      }
    return baseUrl;
  }

  static Future<String> getUrl(UrlType type, int dcId) async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    final UrlDao dao = UrlDao();
    final urlList = db.executeSelectFromTable(dao.tableName,
        "SELECT * FROM ${dao.tableName} WHERE ${dao.fieldType}='${type.text}';");

    if (urlList.isNotEmpty) {
      if (urlList.length == 1) {
        return urlList.first[dao.fieldUrl];
      } else {
        for (var element in urlList) {
          if (element[dao.fieldDcId] == dcId.toString()) {
            return element[dao.fieldUrl];
          }
        }
      }
    }
    return "";
  }

  static Future<String> getCreateFormURL(Map<String, dynamic> object, {required FireBaseFromScreen screenName}) async {
    String baseURL = await UrlHelper.getAdoddleURL(null);
    String url =
        "$baseURL/adoddle/apps?action_id=903&screen=new&application_Id=3&applicationId=3&isAndroid=true&isFromApps=true&isNewUI=true&numberOfRecentDefect=5&isMultipleAttachment=true&v=${DateTime.now().millisecondsSinceEpoch}";

    Iterable<String> keys = object.keys;
    for (var element in keys) {
      url = "$url&$element=${object[element]}";
      /*if(element=="locationId"){
        url = "$url&isFromMapView=true&isCalibrated=true";
      }*/
    }
    url = keys.contains("projectId") ? "$url&projectids=${object["projectId"].toString().plainValue()}" : "$url + projectids=";
    FireBaseEventAnalytics.setEvent(FireBaseEventType.createSiteForm, screenName,bIncludeProjectName: true);
    return url;
  }

  static Future<String> getCreateFormURLForCBim(Map<String, dynamic> object) async {
    String baseURL = await UrlHelper.getAdoddleURL(null);
    String url =
        "$baseURL/adoddle/apps?action_id=903";

    Iterable<String> keys = object.keys;
    for (var element in keys) {
      url = "$url&$element=${object[element]}";
    }
    url = "$url";
    return url;
  }

  static Future<String> getViewFileURL(Map<String,dynamic> object,{FireBaseFromScreen screenName = FireBaseFromScreen.twoDPlan}) async {
    String baseURL = await UrlHelper.getAdoddleURL(null);
    String url = "$baseURL${AConstants.viewFileURL}";
    url = "$url?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&ios=true&hasOnlineViewerSupport=true&documentTypeId=0&viewerId=0&isFromFileViewForDomain=true&isMarkOffline=false&documentId=null";
    Iterable<String> keys = object.keys ;
    for (var element in keys) {
      url = "$url&$element=${object[element]}";
    }
    if(keys.contains("projectId"))
    {
      url = "$url&projectids=${object["projectId"].toString().plainValue()}";
    }
    return url;
  }

  static Future<String> getViewFormURL(Map<String,dynamic> object,{FireBaseFromScreen screenName = FireBaseFromScreen.twoDPlan}) async {
    String baseURL = await UrlHelper.getAdoddleURL(null);
    String url = "$baseURL${AConstants.viewFormURL}";
    url = "$url?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&isMultipleAttachment=true&callFor=viewForm";
    Iterable<String> keys = object.keys ;
    for (var element in keys) {
      url = "$url&$element=${object[element]}";
    }
    if(keys.contains("projectId"))
    {
      url = "$url&projectids=${object["projectId"].toString().plainValue()}";
    }
    FireBaseEventAnalytics.setEvent(FireBaseEventType.fView, screenName,bIncludeProjectName: true);
    return url;
  }

  static Future<String> getORIFormURLByAction(SiteForm frmData,[SiteFormAction? frmAction]) async {
    String url = "";
    /* Uncomment below 2 lines when need to open respond/other action when clicking on task item. Currently it will only view file.*/
    // String? actionId = TaskUtils.getMyTaskId(TaskUtils.getMyTaskAction(frmData.actions));
    // SiteFormAction? frmAction = actionId.isNullOrEmpty() ? null : SiteFormAction(actionId: actionId);
    String baseURL = await UrlHelper.getAdoddleURL(null);
    if(frmAction != null) {
      url = "$baseURL${AConstants.viewFormURL}";
      url = "$url?applicationId=3&application_Id=3&isNewUI=true";
      Map<String, dynamic> param = {};
      final formActionEnum = FormAction.fromString(frmAction.actionId.toString());
      switch(formActionEnum) {
        case FormAction.assignStatus:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["docType"] = frmData.docType;
          param["actionToComplete"] = frmAction.actionId;
          param["isFromAndroid"] = "true";
          param["toOpen"] = "ASSIGN_STATUS";
        }
        break;
        case FormAction.respond:{
          param["hformTypeId"] = frmData.formTypeId;
          param["isFromAndroid"] = "true";
          param["isAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["height"] = "400";
          param["toOpen"] = "Respond";
          param["actionId"] = frmAction.actionId;
        }
        break;
        case FormAction.releaseResponse:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["callFor"] = "comments";
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        case FormAction.attachDocs:{
          param["isDraft"] = frmData.isDraft;
          param["dcId"] = "1";
          param["statusId"] = frmData.statusid;
          param["parentmsgId"] = frmData.parentMsgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["msgCode"] = frmData.msgCode;
          param["originatorId"] = frmData.observationId;
          param["msgId"] = frmData.msgId;
          param["toOpen"] = "FromForms";
          param["numberOfRecentDefect"] = "5";
          param["appTypeId"] = frmData.appTypeId;
        }
        break;
        case FormAction.distribute:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["toOpen"] = "distributeApp";
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        case FormAction.forInformation:{
          param["msgId"] = frmData.msgId;
          param["isFromApps"] = "true";
          param["msgCode"] = frmData.msgCode;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["originatorId"] = frmData.originatorId;
          param["parentmsgId"] = frmData.parentMsgId;
          param["actions"] = frmAction.actionName;
          param["statusId"] = frmData.statusid;
          param["dcId"] = frmData.dcId;
          param["isDraft"] = frmData.isDraft;
          param["folderId"] = frmData.pfLocFolderId;
          param["callFor"] = "viewForm";
          param["isAndroid"] = "true";
        }
        break;
        case FormAction.reviewDraft:{
          param["msgId"] = frmData.msgId;
          param["actionId"] = frmAction.actionId;
          param["hformTypeId"] = frmData.formTypeId;
          param["isFromDirectAccessURL"] = "true";
          param["toOpen"] = "Review Draft";
          //param["toOpen"] = "FromForms";
        }
        break;
        case FormAction.forAction:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["templateType"] = frmData.templateType;
          param["actionToComplete"] = frmAction.actionId;
          param["isFromAndroid"] = "true";
        }
        break;
        case FormAction.forAcknowledgement:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["templateType"] = frmData.templateType;
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        default:
          break;
      }
      param["projectId"] = frmData.projectId;
      param["formID"] = frmData.formId;
      param["commId"] = frmData.commId;
      param["formTypeId"] = frmData.formTypeId;
      param["formId"] = frmData.formId;
      param["projectIds"] = frmData.projectId?.plainValue();
      param["checkHashing"] = "false";
      Iterable<String> keys = param.keys;
      for (var element in keys) {
        url = "$url&$element=${param[element]}";
      }
      if(keys.contains("projectId"))
      {
        url = "$url&projectids=${param["projectId"].toString().plainValue()}";
      }
    }
    else{
      Map<String, dynamic> param = {
        "projectId": frmData.projectId,
        "projectids": frmData.projectId?.plainValue(),
        "isDraft": frmData.isDraft,
        "checkHashing": false,
        "formID": frmData.formId,
        "formTypeId": frmData.formTypeId,
        "dcId": "1",
        "statusId": frmData.statusid,
        "parentmsgId": frmData.parentMsgId,
        "msgTypeCode": frmData.msgTypeCode,
        "msgCode": frmData.msgCode,
        "originatorId": frmData.observationId,
        "msgId": frmData.msgId,
        "toOpen": "FromForms",
        "commId": frmData.commId,
        "numberOfRecentDefect": "5",
        "appTypeId": frmData.appTypeId,
      };
      url = await getViewFormURL(param);
    }
    return url;
  }
  static Future<String> getORIFormURLByActionForNotification(NotificationDetailVo frmData,[NotificationActions? frmAction]) async {
    String url = "";
    String baseURL = await UrlHelper.getAdoddleURL(null);
    if(frmAction != null) {
      url = "$baseURL${AConstants.viewFormURL}";
      url = "$url?applicationId=3&application_Id=3&isNewUI=true";
      Map<String, dynamic> param = {};
      final formActionEnum = FormAction.fromString(frmAction.actionId.toString());
      switch(formActionEnum) {
        case FormAction.assignStatus:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["docType"] = frmData.docType;
          param["actionToComplete"] = frmAction.actionId;
          param["isFromAndroid"] = "true";
          param["toOpen"] = "ASSIGN_STATUS";
        }
        break;
        case FormAction.respond:{
          param["hformTypeId"] = frmData.formTypeId;
          param["isFromAndroid"] = "true";
          param["isAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["height"] = "400";
          param["toOpen"] = "Respond";
          param["actionId"] = frmAction.actionId;
        }
        break;
        case FormAction.releaseResponse:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["callFor"] = "comments";
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        case FormAction.attachDocs:{
          param["isDraft"] = frmData.isDraft;
          param["dcId"] = "1";
          param["statusId"] = frmData.statusid;
          param["parentmsgId"] = frmData.parentMsgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["msgCode"] = frmData.msgCode;
          param["originatorId"] = frmData.observationId;
          param["msgId"] = frmData.msgId;
          param["toOpen"] = "FromForms";
          param["numberOfRecentDefect"] = "5";
          param["appTypeId"] = frmData.appTypeId;
        }
        break;
        case FormAction.distribute:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["toOpen"] = "distributeApp";
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        case FormAction.forInformation:{
          param["msgId"] = frmData.msgId;
          param["isFromApps"] = "true";
          param["msgCode"] = frmData.msgCode;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["originatorId"] = frmData.originatorId;
          param["parentmsgId"] = frmData.parentMsgId;
          param["actions"] = frmAction.actionName;
          param["statusId"] = frmData.statusid;
          param["dcId"] = frmData.dcId;
          param["isDraft"] = frmData.isDraft;
          param["folderId"] = frmData.pfLocFolderId;
          param["callFor"] = "viewForm";
          param["isAndroid"] = "true";
          param["toOpen"] = "Information";
        }
        break;
        case FormAction.reviewDraft:{
          param["msgId"] = frmData.msgId;
          param["actionId"] = frmAction.actionId;
          param["hformTypeId"] = frmData.formTypeId;
          param["isFromDirectAccessURL"] = "true";
          param["toOpen"] = "Review Draft";
          //param["toOpen"] = "FromForms";
        }
        break;
        case FormAction.forAction:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["templateType"] = frmData.templateType;
          param["actionToComplete"] = frmAction.actionId;
          param["isFromAndroid"] = "true";
          param["toOpen"] = "FOR_ACTION";
        }
        break;
        case FormAction.forAcknowledgement:{
          param["folderId"] = frmData.pfLocFolderId;
          param["dcId"] = frmData.dcId;
          param["isFromAndroid"] = "true";
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["isDraft"] = frmData.isDraft;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["templateType"] = frmData.templateType;
          param["actionToComplete"] = frmAction.actionId;
          param["toOpen"] = "FOR_ACKNOWLEDGEMENT";
        }
        break;
        default:
          break;
      }
      param["projectId"] = frmData.projectId;
      param["formID"] = frmData.formId;
      param["commId"] = frmData.commId;
      param["formTypeId"] = frmData.formTypeId;
      param["formId"] = frmData.formId;
      param["projectIds"] = frmData.projectId?.plainValue();
      param["checkHashing"] = "false";
      Iterable<String> keys = param.keys;
      for (var element in keys) {
        url = "$url&$element=${param[element]}";
      }
      if(keys.contains("projectId"))
      {
        url = "$url&projectids=${param["projectId"].toString().plainValue()}";
      }
    }
    else{
      Map<String, dynamic> param = {
        "projectId": frmData.projectId,
        "projectids": frmData.projectId?.plainValue(),
        "isDraft": frmData.isDraft,
        "checkHashing": false,
        "formID": frmData.formId,
        "formTypeId": frmData.formTypeId,
        "dcId": "1",
        "statusId": frmData.statusid,
        "parentmsgId": frmData.parentMsgId,
        "msgTypeCode": frmData.msgTypeCode,
        "msgCode": frmData.msgCode,
        "originatorId": frmData.observationId,
        "msgId": frmData.msgId,
        "toOpen": "FromForms",
        "commId": frmData.commId,
        "numberOfRecentDefect": "5",
        "appTypeId": frmData.appTypeId,
      };
      url = await getViewFormURL(param);
    }
    return url;
  }
  static Future<String> getFileURLByActionForNotification(NotificationDetailVo frmData,[NotificationActions? frmAction]) async {
    String url = "";
    String baseURL = await UrlHelper.getAdoddleURL(null);
    if(frmAction != null) {
      url = "$baseURL${AConstants.viewFormURL}";
      url = "$url?applicationId=3&application_Id=3&isNewUI=true";
      Map<String, dynamic> param = {};
      switch(frmAction.actionId) {
        case 8:{

        }
        break;
        case 9:{
          param["toOpen"] = "createCommet";
        }
        break;
        case 10:{
           param["toOpen"] = "coordination";
        }
        break;
        case 11:{
          param["toOpen"] = "incorporation";
        }
        break;
        case 12:{
          param["toOpen"] = "distribution";
        }
        break;
        case 13:{
          //actionURL = "/adoddle/viewer/fileView.jsp?projectId=" + currentFilesFolderListVO.getProjectId() + "&revisionId=" + currentFilesFolderListVO.getRevisionId() + "&documentId=" + currentFilesFolderListVO.getDocumentId() + "&folderId=" + currentFilesFolderListVO.getFolderId() + "&hasOnlineViewerSupport=true&toOpen=FromFile&dcId=" + currentFilesFolderListVO.getDcId() + "&documentTypeId=" + currentFilesFolderListVO.getDocumentTypeId() + "&viewerId=" + currentFilesFolderListVO.getViewerId() + "&applicationId=" + IAdoddleConstants.TABLET_APPLICATION_ID + "&application_Id=" + IAdoddleConstants.TABLET_APPLICATION_ID + "&ios=true&toOpen=false&hasOnlineViewerSupport=true&isFromFileViewForDomain=true" + "&isAndroid=true" + "&isNewUI=true";
          // param["documentId"] = frmData.documentId;
          param["toOpen"] = "FromFile";
          param["ios"] = "true";
          param["isFromFileViewForDomain"] = "true";
        }
        break;
        case 14:{
          param["toOpen"] = "ASSIGN_STATUS";
        }
        break;
        case 35:{

        }
        break;
        default:
          break;
      }
      param["projectId"] = frmData.projectId;
      // param["revisionId"] = frmData.revisionId;
      param["dcId"] = frmData.dcId;
      // param["fileName"] = frmData.fileName;
      // param["fileSize"] = frmData.fileSize;
      param["folderId"] = frmData.pfLocFolderId;
      // param["uploadFilename"] = frmData.uploadFilename;
      // param["issueNum"] = frmData.issueNum;
      // param["documentId"] = frmData.documentId;
      // param["documentTypeId"] = frmData.documentTypeId;
      // param["isLink"] = frmData.isLink;
      // param["checkOutStatus"] = frmData.checkOutStatus;
      // param["hasOnlineViewerSupport"] = "true";
      // param["toOpen"] = "distribution";
      // param["viewerId"] = "0";
      // param["isFromAndroid"] = "true";
      // param["docStatusId"] = frmData.docStatusId;
      param["actionToComplete"] = frmAction.actionId;
      // param["isActive"] = frmAction.isActive;
      // param["isNewUI"] = frmAction.isNewUI;
      Iterable<String> keys = param.keys;
      for (var element in keys) {
        url = "$url&$element=${param[element]}";
      }
      if(keys.contains("projectId"))
      {
        url = "$url&projectids=${param["projectId"].toString().plainValue()}";
      }
    }
    else{
      // Map<String, dynamic> param = {
      //   "projectId": frmData.projectId,
      //   "projectids": frmData.projectId?.plainValue(),
      //   "isDraft": frmData.isDraft,
      //   "checkHashing": false,
      //   "formID": frmData.formId,
      //   "formTypeId": frmData.formTypeId,
      //   "dcId": "1",
      //   "statusId": frmData.statusid,
      //   "parentmsgId": frmData.parentMsgId,
      //   "msgTypeCode": frmData.msgTypeCode,
      //   "msgCode": frmData.msgCode,
      //   "originatorId": frmData.observationId,
      //   "msgId": frmData.msgId,
      //   "toOpen": "FromForms",
      //   "commId": frmData.commId,
      //   "numberOfRecentDefect": "5",
      //   "appTypeId": frmData.appTypeId,
      // };
      // url = await getViewFormURL(param);
    }
    return url;
  }
  static Future<String> getActionNameFromActionsForNotification(NotificationDetailVo frmData,[NotificationActions? frmAction]) async {
    String url = "";
    String baseURL = await UrlHelper.getAdoddleURL(null);
    if(frmAction != null) {
      url = "$baseURL${AConstants.viewFormURL}";
      url = "$url?applicationId=3&application_Id=3&isNewUI=true";
      Map<String, dynamic> param = {};
      switch(frmAction.actionId) {
        case 2:{
          param["actionName"] = "ASSIGN_STATUS";
          param["folderId"] = frmData.folderId;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["docType"] = frmData.docType;
          param["commId"] = frmData.commId;
          param["actionToComplete"] = frmAction.actionId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["msgId"] = frmData.msgId;
        }
        break;
        case 3:{
          param["actionName"] = "Respond";
          param["hformTypeId"] = frmData.formTypeId;
          param["height"] = "400";
          param["toOpen"] = "Respond";
          param["actionId"] = frmAction.actionId;
        }
        break;
        case 4:{
          param["folderId"] = frmData.folderId;
          param["callFor"] = "comments";
          param["commId"] = frmData.commId;
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        case 6:{
          param["actionName"] = "distributeApp";
          param["folderId"] = frmData.folderId;
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["toOpen"] = frmData.statusid;
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        case 7:{
          param["msgId"] = frmData.msgId;
          param["isFromApps"] = "true";
          param["msgCode"] = frmData.msgCode;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["commId"] = frmData.commId;
          param["folderId"] = frmData.folderId;
          param["callFor"] = "viewForm";
        }
        break;
        case 34:{
          param["commId"] = frmData.commId;
          param["msgId"] = frmData.msgId;
          param["actionId"] = frmAction.actionId;
          param["toOpen"] = "Review Draft";
          param["toOpen"] = "FromForms";
          param["isFromDirectAccessURL"] = "true";
          param["actionName"] = "Review%20Draft";
        }
        break;
        case 36:{
          param["actionName"] = "FOR_ACTION";
          param["folderId"] = frmData.folderId;
          param["commId"] = frmData.commId;
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["templateType"] = frmData.templateType;
          param["actionToComplete"] = frmAction.actionId;
        }
        break;
        case 37:{
          param["folderId"] = frmData.folderId;
          param["commId"] = frmData.commId;
          param["msgId"] = frmData.msgId;
          param["msgTypeCode"] = frmData.msgTypeCode;
          param["originatorId"] = frmData.originatorId;
          param["parentMsgId"] = frmData.parentMsgId;
          param["statusid"] = frmData.statusid;
          param["templateType"] = frmData.templateType;
          param["actionToComplete"] = frmAction.actionId;
          param["actionName"] = "FOR_ACKNOWLEDGEMENT";
        }
        break;
        default:
          break;
      }
      param["projectId"] = frmData.projectId;
      param["dcId"] = frmData.dcId;
      param["formTypeId"] = frmData.formTypeId;
      param["formID"] = frmData.formId;
      param["isDraft"] = frmData.isDraft;
      param["formId"] = frmData.formId;
      param["isFromAndroid"] = "true";
      param["isNewUI"] = "true";
      param["projectIds"] = frmData.projectId?.plainValue();
      // param["checkHashing"] = "false";

      Iterable<String> keys = param.keys;
      for (var element in keys) {
        url = "$url&$element=${param[element]}";
      }
      if(keys.contains("projectId"))
      {
        url = "$url&projectids=${param["projectId"].toString().plainValue()}";
      }
    }
    else{
      // Map<String, dynamic> param = {
      //   "projectId": frmData.projectId,
      //   "projectids": frmData.projectId?.plainValue(),
      //   "isDraft": frmData.isDraft,
      //   "checkHashing": false,
      //   "formID": frmData.formId,
      //   "formTypeId": frmData.formTypeId,
      //   "dcId": "1",
      //   "statusId": frmData.statusid,
      //   "parentmsgId": frmData.parentMsgId,
      //   "msgTypeCode": frmData.msgTypeCode,
      //   "msgCode": frmData.msgCode,
      //   "originatorId": frmData.observationId,
      //   "msgId": frmData.msgId,
      //   "toOpen": "FromForms",
      //   "commId": frmData.commId,
      //   "numberOfRecentDefect": "5",
      //   "appTypeId": frmData.appTypeId,
      // };
      // url = await getViewFormURL(param);
    }
    return url;
  }

}
