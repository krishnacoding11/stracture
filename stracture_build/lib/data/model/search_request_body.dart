// To parse this JSON data, do
//
//     final searchModelRequestBody = searchModelRequestBodyFromJson(jsonString);

import 'dart:convert';

SearchModelRequestBody searchModelRequestBodyFromJson(String str) => SearchModelRequestBody.fromJson(json.decode(str));

String searchModelRequestBodyToJson(SearchModelRequestBody data) => json.encode(data.toJson());

class SearchModelRequestBody {
  SearchModelRequestBody({
    this.id,
    this.userId,
    this.filterName,
    this.listingTypeId,
    this.subListingTypeId,
    this.isUnsavedFilter,
    this.isFavorite,
    this.filterQueryVOs,
    this.userAccesibleDcIds,
  });

  int? id;
  int? userId;
  String? filterName;
  int? listingTypeId;
  int? subListingTypeId;
  bool? isUnsavedFilter;
  String? isFavorite;
  List<FilterQueryVo>? filterQueryVOs;
  List<int>? userAccesibleDcIds;

  factory SearchModelRequestBody.fromJson(Map<String, dynamic> json) => SearchModelRequestBody(
    id: json["id"],
    userId: json["userId"],
    filterName: json["filterName"],
    listingTypeId: json["listingTypeId"],
    subListingTypeId: json["subListingTypeId"],
    isUnsavedFilter: json["isUnsavedFilter"],
    isFavorite: json["isFavorite"],
    filterQueryVOs: List<FilterQueryVo>.from(json["filterQueryVOs"].map((x) => FilterQueryVo.fromJson(x))),
    userAccesibleDcIds: List<int>.from(json["userAccesibleDCIds"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "filterName": filterName,
    "listingTypeId": listingTypeId,
    "subListingTypeId": subListingTypeId,
    "isUnsavedFilter": isUnsavedFilter,
    "isFavorite": isFavorite,
    "filterQueryVOs": List<dynamic>.from(filterQueryVOs!.map((x) => x.toJson())),
    "userAccesibleDCIds": List<dynamic>.from(userAccesibleDcIds!.map((x) => x)),
  };
}

class FilterQueryVo {
  FilterQueryVo({
    this.fieldName,
    this.indexField,
    this.v,
    this.dataType,
    this.solrCollections,
    this.returnIndexFields,
    this.popupTo,
    this.labelName,
  });

  String? fieldName;
  String? indexField;
  String? v;
  String? dataType;
  String? solrCollections;
  String? returnIndexFields;
  PopupTo? popupTo;
  String? labelName;

  factory FilterQueryVo.fromJson(Map<String, dynamic> json) => FilterQueryVo(
    fieldName: json["fieldName"],
    indexField: json["indexField"],
    v: json["v"],
    dataType: json["dataType"],
    solrCollections: json["solrCollections"],
    returnIndexFields: json["returnIndexFields"],
    popupTo: PopupTo.fromJson(json["popupTo"]),
    labelName: json["labelName"],
  );

  Map<String, dynamic> toJson() => {
    "fieldName": fieldName,
    "indexField": indexField,
    "v": v,
    "dataType": dataType,
    "solrCollections": solrCollections,
    "returnIndexFields": returnIndexFields,
    "popupTo": popupTo!.toJson(),
    "labelName": labelName,
  };
}

class PopupTo {
  PopupTo({
    this.data,
  });

  List<Datum>? data;

  factory PopupTo.fromJson(Map<String, dynamic> json) => PopupTo(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.id,
    this.value,
  });

  String? id;
  String? value;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "value": value,
  };
}
