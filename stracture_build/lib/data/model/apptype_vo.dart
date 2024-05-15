import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:field/utils/extensions.dart';

class AppType extends Equatable {
  String? formTypeID;
  String? formTypeName;
  String? code;
  String? appBuilderCode;
  String? projectID;
  String? msgId;
  String? formId;
  int? dataCenterId;
  int? createFormsLimit;
  int? createdMsgCount;
  int? draftCount;
  int? draftMsgId;
  int? appTypeId;
  int? isFromWhere;
  String? projectName;
  String? instanceGroupId;
  int? templateType;
  bool? isRecent;
  String? formTypeGroupName;
  String? formTypeGroupID;
  String? formTypeDetailJson;
  bool? generateURI;
  bool? isMarkDefault;
  bool? allowLocationAssociation;
  bool? canCreateForms;
  bool? isUseController;

  AppType({
    this.formTypeID,
    this.formTypeName,
    this.code,
    this.appBuilderCode,
    this.projectID,
    this.msgId,
    this.formId,
    this.dataCenterId,
    this.createFormsLimit,
    this.createdMsgCount,
    this.draftCount,
    this.draftMsgId,
    this.appTypeId,
    this.isFromWhere,
    this.projectName,
    this.instanceGroupId,
    this.templateType,
    this.isRecent,
    this.formTypeGroupName,
    this.generateURI,
    this.isMarkDefault
  });

  static List<AppType> fromJsonListSync(dynamic json) {
    return List<AppType>.from(json.map((element) => AppType.fromJsonSync(element))).toList();
  }

  AppType.fromJsonSync(Map<String, dynamic> json) {
    projectID = json['formTypesDetail']?["formTypeVO"]?["projectId"]??json['workspaceid']?.toString();
    formTypeID = json['formTypeID'];
    formTypeGroupID = json['formtypeGroupid']?.toString();
    formTypeGroupName = json['formTypeGroupName'];
    code = json['formGroupCode'];
    formTypeName = json['formTypeName'];
    appBuilderCode = json['appBuilderID'];//
    instanceGroupId = json['instanceGroupId']?.toString();
    templateType = json['templatetype']??json['template_type_id']??json['templateType'];
    formTypeDetailJson = jsonEncode(json);
    allowLocationAssociation = json['allow_associate_location'];
    canCreateForms = json['canCreateForm'];
    isUseController = json['formTypesDetail']?["formTypeVO"]?["use_controller"];
    appTypeId = int.tryParse(json['appId'].toString().plainValue());
    //This is adding while syncing apptypes online to offline
    isMarkDefault = false;
  }

  AppType.fromJson(Map<String, dynamic> json) {
    formTypeID = json['formTypeID'];
    formTypeName = json['formTypeName'];
    code = json['code'];
    appBuilderCode = json['appBuilderCode'];
    projectID = json['projectID'];
    msgId = json['msgId'];
    formId = json['formId'];
    dataCenterId = json['dataCenterId'];
    createFormsLimit = json['createFormsLimit'];
    createdMsgCount = json['createdMsgCount'];
    canCreateForms = json['canCreateForm'];
    draftCount = json['draft_count'];
    draftMsgId = json['draftMsgId'];
    appTypeId = json['appTypeId'];
    isFromWhere = json['isFromWhere'];
    projectName = json['projectName'];
    instanceGroupId = json['instanceGroupId'];
    templateType = json['templateType'];
    isRecent = json['isRecent']?? false;
    formTypeGroupName = json['formTypeGroupName'];
    generateURI = json['generateURI'];
    isMarkDefault = json['isMarkDefault'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['formTypeID'] = formTypeID;
    data['formTypeName'] = formTypeName;
    data['code'] = code;
    data['appBuilderCode'] = appBuilderCode;
    data['appBuilderID'] = appBuilderCode;
    data['projectID'] = projectID;
    data['msgId'] = msgId;
    data['formId'] = formId;
    data['dataCenterId'] = dataCenterId;
    data['createFormsLimit'] = createFormsLimit;
    data['createdMsgCount'] = createdMsgCount;
    data['draft_count'] = draftCount;
    data['draftMsgId'] = draftMsgId;
    data['appTypeId'] = appTypeId;
    data['isFromWhere'] = isFromWhere;
    data['projectName'] = projectName;
    data['instanceGroupId'] = instanceGroupId;
    data['templateType'] = templateType;
    data['isRecent'] = isRecent;
    data['formTypeGroupName'] = formTypeGroupName;
    data['generateURI'] = generateURI;
    data['isMarkDefault'] = isMarkDefault;
    data['canCreateForm'] = canCreateForms;
    data['formTypesDetail'] = json.decode(formTypeDetailJson ?? "")["formTypesDetail"];
    return data;
  }

  @override
  List<Object?> get props => [];

  bool isAutoPublishToFolder() {
    bool bIsTrue = false;
    try {
      if (!formTypeDetailJson.isNullOrEmpty()) {
        var formTypeDetail = jsonDecode(formTypeDetailJson!);
        bIsTrue = formTypeDetail["formTypesDetail"]["formTypeVO"]["auto_publish_to_folder"]??false;
      }
    } catch (_) {}
    return bIsTrue;
  }
}
