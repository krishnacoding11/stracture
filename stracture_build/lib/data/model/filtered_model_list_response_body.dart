// To parse this JSON data, do
//
//     final filteredListResponseBody = filteredListResponseBodyFromJson(jsonString);

import 'dart:convert';

import 'model_vo.dart';

FilteredListResponseBody filteredListResponseBodyFromJson(String str) => FilteredListResponseBody.fromJson(json.decode(str));

String filteredListResponseBodyToJson(FilteredListResponseBody data) => json.encode(data.toJson());

class FilteredListResponseBody {
  FilteredListResponseBody({
    required this.filterResponse,
    required this.filterData,
  });

  FilterResponse filterResponse;
  FilterData filterData;

  factory FilteredListResponseBody.fromJson(Map<String, dynamic> json) => FilteredListResponseBody(
    filterResponse: FilterResponse.fromJson(json["filterResponse"]),
    filterData: FilterData.fromJson(json["filterData"]),
  );

  Map<String, dynamic> toJson() => {
    "filterResponse": filterResponse.toJson(),
    "filterData": filterData.toJson(),
  };
}

class FilterData {
  FilterData({
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

  int totalDocs;
  int recordBatchSize;
  int listingType;
  int currentPageNo;
  int recordStartFrom;
  List<ColumnHeader> columnHeader;
  List<Model> data;
  String viewType;
  String sortField;
  String sortFieldType;
  String sortOrder;
  bool editable;
  bool isIncludeSubFolder;
  int totalListData;

  factory FilterData.fromJson(Map<String, dynamic> json) => FilterData(
    totalDocs: json["totalDocs"],
    recordBatchSize: json["recordBatchSize"],
    listingType: json["listingType"],
    currentPageNo: json["currentPageNo"],
    recordStartFrom: json["recordStartFrom"],
    columnHeader: List<ColumnHeader>.from(json["columnHeader"].map((x) => ColumnHeader.fromJson(x))),
    data: json["data"]!=null?List<Model>.from(json["data"].map((x) => Model.fromJson(x))):[],
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

  String id;
  String fieldName;
  String solrIndexfieldName;
  String colDisplayName;
  String colType;
  int userIndex;
  ImgName imgName;
  String tooltipSrc;
  String dataType;
  String function;
  String funParams;
  String wrapData;
  int widthOfColumn;
  bool isSortSupported;
  bool isCustomAttributeColumn;
  bool isActive;

  factory ColumnHeader.fromJson(Map<String, dynamic> json) => ColumnHeader(
    id: json["id"],
    fieldName: json["fieldName"],
    solrIndexfieldName: json["solrIndexfieldName"],
    colDisplayName: json["colDisplayName"],
    colType: json["colType"],
    userIndex: json["userIndex"],
    imgName: imgNameValues.map[json["imgName"]]!,
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
    "imgName": imgNameValues.reverse[imgName],
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

enum ImgName { empty, favPng }

final imgNameValues = EnumValues({
  "": ImgName.empty,
  "fav.png": ImgName.favPng
});

class FilterResponse {
  FilterResponse();

  factory FilterResponse.fromJson(Map<String, dynamic> json) => FilterResponse(
  );

  Map<String, dynamic> toJson() => {
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
