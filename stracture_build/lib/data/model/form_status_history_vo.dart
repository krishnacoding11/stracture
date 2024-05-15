import 'dart:convert';

import 'package:field/data/model/user_vo.dart';

import '../../utils/utils.dart';

class FormStatusHistoryVO {

  String? strAppTypeId;
  String? strProjectId;
  String? strFormTypeId;
  String? strFormId;
  String? strMessageId;
  String? strActionUserId;
  String? strActionUserName;
  String? strActionUserOrgName;
  String? strActionProxyUserId;
  String? strActionProxyUserName;
  String? strActionProxyUserOrgName;
  String? strActionUserTypeId;
  String? strActionId;
  String? strActionDate;
  String? strDescription;
  String? strRemarks;
  String? strCreateDateInMS;
  String? strJsonData;
  String? strLocationId;
  String? strObservationId;

  FormStatusHistoryVO({this.strAppTypeId, this.strProjectId, this.strFormTypeId, this.strFormId, this.strMessageId, this.strActionUserId, this.strActionUserName, this.strActionUserOrgName, this.strActionProxyUserId, this.strActionProxyUserName, this.strActionProxyUserOrgName, this.strActionUserTypeId, this.strActionId, this.strActionDate, this.strDescription, this.strRemarks, this.strCreateDateInMS, this.strJsonData, this.strLocationId, this.strObservationId});

  FormStatusHistoryVO.fromJson(dynamic json){
    strAppTypeId = json["appTypeId"];
    strProjectId = json["projectId"];
    strFormTypeId = json["formTypeId"];
    strFormId = json["selectedFormId"];
    strMessageId = json["messageId"];
    strActionUserId = json["actionUserId"];
    strActionUserName = json["actionUserName"];
    strActionUserOrgName = json["actionUserOrgName"];
    strActionProxyUserId = json["actionProxyUserId"];
    strActionProxyUserName = json["actionProxyUserName"];
    strActionProxyUserOrgName = json["actionProxyUserOrgName"];
    strActionUserTypeId = json["actionUserTypeId"];
    strActionId = json["actionId"];
    strActionDate = json["actionDate"];
    strDescription = json["description"];
    strRemarks = json["remarks"];
    strCreateDateInMS = json["createDateInMS"];
    strJsonData = json["jsonData"];
    strLocationId = json["locationId"];
    strObservationId = json["observationId"];
  }

  FormStatusHistoryVO.fromJsonOffline(dynamic json, User currentUser){
    String currentTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    strAppTypeId = json["appTypeId"]?.toString();
    strProjectId = json["projectId"]?.toString();
    strFormTypeId = json["formTypeId"]?.toString();
    strFormId = json["selectedFormId"]?.toString();
    strMessageId = json["messageId"]?.toString() ?? "";
    strActionUserId = currentUser.usersessionprofile?.userID ?? "";
    strActionUserName = currentUser.usersessionprofile?.tpdUserName ?? "";
    strActionUserOrgName = currentUser.usersessionprofile?.tpdOrgName ?? "";
    strActionProxyUserId = currentUser.usersessionprofile?.proxyUserID ?? "";
    strActionProxyUserName = currentUser.usersessionprofile?.proxyUserName ?? "";
    strActionProxyUserOrgName = currentUser.usersessionprofile?.proxyOrgName ?? "";
    strActionUserTypeId = currentUser.usersessionprofile?.userTypeId ?? "";
    strActionId = "26";
    strActionDate = Utility.getDateTimeFromTimeStamp(currentTimeStamp);
    strDescription = "Status Changed to ${json["statusName"]}";
    strRemarks = json["newStatusReason"] ?? "";
    strCreateDateInMS = currentTimeStamp;
    strJsonData = jsonEncode(json);
    strLocationId = json["locationId"];
    strObservationId = json["observationId"];
  }

}