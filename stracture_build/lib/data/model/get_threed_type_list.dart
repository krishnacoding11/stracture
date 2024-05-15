// To parse this JSON data, do
//
//     final getThreedAppType = getThreedAppTypeFromJson(jsonString);

import 'dart:convert';

GetThreedAppType getThreedAppTypeFromJson(String str) => GetThreedAppType.fromJson(json.decode(str));

String getThreeDAppTypeToJson(GetThreedAppType data) => json.encode(data.toJson());

class GetThreedAppType {
  int totalDocs;
  int recordBatchSize;
  int listingType;
  int currentPageNo;
  int recordStartFrom;
  List<ColumnHeader> columnHeader;
  List<Datum> data;
  String viewType;
  String sortField;
  String sortFieldType;
  String sortOrder;
  bool editable;
  bool isIncludeSubFolder;
  int totalListData;

  GetThreedAppType({
    required this.totalDocs,
    required this.recordBatchSize,
    required this.listingType,
    required this.currentPageNo,
    required this.recordStartFrom,
    required this.columnHeader,
    required this.data,
    required this.viewType,
    required this.sortField,
    required this.sortFieldType,
    required this.sortOrder,
    required this.editable,
    required this.isIncludeSubFolder,
    required this.totalListData,
  });

  factory GetThreedAppType.fromJson(Map<String, dynamic> json) => GetThreedAppType(
    totalDocs: json["totalDocs"],
    recordBatchSize: json["recordBatchSize"],
    listingType: json["listingType"],
    currentPageNo: json["currentPageNo"],
    recordStartFrom: json["recordStartFrom"],
    columnHeader: List<ColumnHeader>.from(json["columnHeader"].map((x) => ColumnHeader.fromJson(x))),
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    viewType: json["viewType"],
    sortField: json["sortField"],
    sortFieldType: json["sortFieldType"],
    sortOrder: json["sortOrder"],
    editable: json["editable"],
    isIncludeSubFolder: json["isIncludeSubFolder"],
    totalListData: json["totalListData"],
  );

  Map<String, dynamic> toJson() => {
    "totalDocs": totalDocs,
    "recordBatchSize": recordBatchSize,
    "listingType": listingType,
    "currentPageNo": currentPageNo,
    "recordStartFrom": recordStartFrom,
    "columnHeader": List<dynamic>.from(columnHeader.map((x) => x.toJson())),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "viewType": viewType,
    "sortField": sortField,
    "sortFieldType": sortFieldType,
    "sortOrder": sortOrder,
    "editable": editable,
    "isIncludeSubFolder": isIncludeSubFolder,
    "totalListData": totalListData,
  };
}

class ColumnHeader {
  String id;
  String fieldName;
  String solrIndexfieldName;
  String colDisplayName;
  String colType;
  int userIndex;
  String imgName;
  String tooltipSrc;
  String dataType;
  String function;
  String funParams;
  String wrapData;
  int widthOfColumn;
  bool isSortSupported;
  bool isCustomAttributeColumn;
  bool isActive;

  ColumnHeader({
    required this.id,
    required this.fieldName,
    required this.solrIndexfieldName,
    required this.colDisplayName,
    required this.colType,
    required this.userIndex,
    required this.imgName,
    required this.tooltipSrc,
    required this.dataType,
    required this.function,
    required this.funParams,
    required this.wrapData,
    required this.widthOfColumn,
    required this.isSortSupported,
    required this.isCustomAttributeColumn,
    required this.isActive,
  });

  factory ColumnHeader.fromJson(Map<String, dynamic> json) => ColumnHeader(
    id: json["id"],
    fieldName: json["fieldName"],
    solrIndexfieldName: json["solrIndexfieldName"],
    colDisplayName: json["colDisplayName"],
    colType: json["colType"],
    userIndex: json["userIndex"],
    imgName: json["imgName"],
    tooltipSrc: json["tooltipSrc"],
    dataType: json["dataType"],
    function: json["function"],
    funParams: json["funParams"],
    wrapData: json["wrapData"],
    widthOfColumn: json["widthOfColumn"],
    isSortSupported: json["isSortSupported"],
    isCustomAttributeColumn: json["isCustomAttributeColumn"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fieldName": fieldName,
    "solrIndexfieldName": solrIndexfieldName,
    "colDisplayName": colDisplayName,
    "colType": colType,
    "userIndex": userIndex,
    "imgName": imgName,
    "tooltipSrc": tooltipSrc,
    "dataType": dataType,
    "function": function,
    "funParams": funParams,
    "wrapData": wrapData,
    "widthOfColumn": widthOfColumn,
    "isSortSupported": isSortSupported,
    "isCustomAttributeColumn": isCustomAttributeColumn,
    "isActive": isActive,
  };
}

class Datum {
  String formTypeId;
  String formTypeName;
  String code;
  String appBuilderCode;
  String projectId;
  String msgId;
  String formId;
  int dataCenterId;
  int createFormsLimit;
  int createdMsgCount;
  int draftCount;
  int draftMsgId;
  int appTypeId;
  int isFromWhere;
  String projectName;
  String instanceGroupId;
  int templateType;
  bool isRecent;
  String formTypeGroupName;
  bool isMarkDefault;
  bool generateUri;

  Datum({
    required this.formTypeId,
    required this.formTypeName,
    required this.code,
    required this.appBuilderCode,
    required this.projectId,
    required this.msgId,
    required this.formId,
    required this.dataCenterId,
    required this.createFormsLimit,
    required this.createdMsgCount,
    required this.draftCount,
    required this.draftMsgId,
    required this.appTypeId,
    required this.isFromWhere,
    required this.projectName,
    required this.instanceGroupId,
    required this.templateType,
    required this.isRecent,
    required this.formTypeGroupName,
    required this.isMarkDefault,
    required this.generateUri,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    formTypeId: json["formTypeID"],
    formTypeName: json["formTypeName"],
    code: json["code"],
    appBuilderCode: json["appBuilderCode"],
    projectId: json["projectID"],
    msgId: json["msgId"],
    formId: json["formId"],
    dataCenterId: json["dataCenterId"],
    createFormsLimit: json["createFormsLimit"],
    createdMsgCount: json["createdMsgCount"],
    draftCount: json["draft_count"],
    draftMsgId: json["draftMsgId"],
    appTypeId: json["appTypeId"],
    isFromWhere: json["isFromWhere"],
    projectName: json["projectName"],
    instanceGroupId: json["instanceGroupId"],
    templateType: json["templateType"],
    isRecent: json["isRecent"],
    formTypeGroupName: json["formTypeGroupName"],
    isMarkDefault: json["isMarkDefault"],
    generateUri: json["generateURI"],
  );

  Map<String, dynamic> toJson() => {
    "formTypeID": formTypeId,
    "formTypeName": formTypeName,
    "code": code,
    "appBuilderCode": appBuilderCode,
    "projectID": projectId,
    "msgId": msgId,
    "formId": formId,
    "dataCenterId": dataCenterId,
    "createFormsLimit": createFormsLimit,
    "createdMsgCount": createdMsgCount,
    "draft_count": draftCount,
    "draftMsgId": draftMsgId,
    "appTypeId": appTypeId,
    "isFromWhere": isFromWhere,
    "projectName": projectName,
    "instanceGroupId": instanceGroupId,
    "templateType": templateType,
    "isRecent": isRecent,
    "formTypeGroupName": formTypeGroupName,
    "isMarkDefault": isMarkDefault,
    "generateURI": generateUri,
  };
}