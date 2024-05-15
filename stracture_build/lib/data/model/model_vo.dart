import 'dart:convert';

import 'package:equatable/equatable.dart';

ModelList modelListFromJson(String str) => ModelList.fromJson(json.decode(str));

String modelListToJson(ModelList data) => json.encode(data.toJson());

class ModelList {
  ModelList({
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

  factory ModelList.fromJson(Map<String, dynamic> json) => ModelList(
        totalDocs: json["totalDocs"],
        recordBatchSize: json["recordBatchSize"],
        listingType: json["listingType"],
        currentPageNo: json["currentPageNo"],
        recordStartFrom: json["recordStartFrom"],
        columnHeader: List<ColumnHeader>.from(json["columnHeader"].map((x) => ColumnHeader.fromJson(x))),
        data: json["data"] != null ? List<Model>.from(json["data"].map((x) => Model.fromJson(x))) : [],
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
    this.isFavoriteModel,
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
  int? isFavoriteModel;

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
        isFavoriteModel: json["isFavoriteModel"],
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
        "isFavoriteModel": isFavoriteModel,
      };
}

enum ImgName { empty, fav_png }

final imgNameValues = EnumValues({"": ImgName.empty, "fav.png": ImgName.fav_png});

class Work {
  Work();

  factory Work.fromJson(Map<String, dynamic> json) => Work();

  Map<String, dynamic> toJson() => {};
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

List<Model> modelVoNewFromJson(String str) => List<Model>.from(json.decode(str).map((x) => Model.fromJson(x)));

String modelVoNewToJson(List<Model> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Model extends Equatable {
  Model({
    this.modelId,
    this.bimModelId,
    this.projectId,
    this.projectName,
    this.bimModelName,
    this.modelDescription,
    this.userModelName,
    this.workPackageId,
    this.modelCreatorUserId,
    this.modelStatus,
    this.modelCreationDate,
    this.lastUpdateDate,
    this.mergeLevel,
    this.isFavoriteModel,
    this.dc,
    this.modelViewId,
    this.revisionId,
    this.folderId,
    this.revisionNumber,
    this.worksetId,
    this.docId,
    this.publisher,
    this.lastUpdatedUserId,
    this.lastUpdatedBy,
    this.lastAccessUserId,
    this.lastAccessBy,
    this.lastAccessModelDate,
    this.modelTypeId,
    this.worksetdetails,
    this.workingFolders,
    this.generateUri,
    this.setAsOffline,
    this.isDropOpen,
    this.isDownload,
    this.fileSize,
    this.downloadProgress = "0",
    this.modelSupportedOffline,
  });

  String? modelId;
  String? bimModelId;
  String? projectId;
  String? projectName;
  String? fileSize;
  String? downloadProgress;
  String? bimModelName;
  String? modelDescription;
  String? userModelName;
  int? workPackageId;
  String? modelCreatorUserId;
  bool? modelStatus;
  String? modelCreationDate;
  String? lastUpdateDate;
  int? mergeLevel;
  int? isFavoriteModel;
  String? dc;
  int? modelViewId;
  String? revisionId;
  String? folderId;
  int? revisionNumber;
  String? worksetId;
  String? docId;
  String? publisher;
  String? lastUpdatedUserId;
  String? lastUpdatedBy;
  String? lastAccessUserId;
  String? lastAccessBy;
  String? lastAccessModelDate;
  int? modelTypeId;
  Work? worksetdetails;
  Work? workingFolders;
  bool? generateUri;
  bool? setAsOffline;
  bool? isDropOpen;
  bool? isDownload;
  bool? modelSupportedOffline;

  factory Model.fromJson(Map<String, dynamic> json) => Model(
        modelId: json["modelId"] ?? json["bimModelId"],
        bimModelId: json["bimModelId"],
        projectId: json["projectId"],
        projectName: json["projectName"],
        fileSize: json["fileSize"],
        bimModelName: json["bimModelName"],
        modelDescription: json["modelDescription"],
        userModelName: json["userModelName"],
        workPackageId: json["workPackageId"],
        modelCreatorUserId: json["modelCreatorUserId"],
        modelStatus: json["modelStatus"],
        modelCreationDate: json["modelCreationDate"],
        lastUpdateDate: json["lastUpdateDate"],
        mergeLevel: json["mergeLevel"],
        isFavoriteModel: json["isFavoriteModel"],
        dc: json["dc"],
        modelViewId: json["modelViewId"],
        revisionId: json["revisionId"],
        folderId: json["folderId"],
        revisionNumber: json["revisionNumber"],
        worksetId: json["worksetId"],
        docId: json["docId"],
        publisher: json["publisher"],
        lastUpdatedUserId: json["lastUpdatedUserId"],
        lastUpdatedBy: json["lastUpdatedBy"],
        lastAccessUserId: json["lastAccessUserId"],
        lastAccessBy: json["lastAccessBy"],
        lastAccessModelDate: json["lastAccessModelDate"],
        modelTypeId: json["modelTypeId"],
        generateUri: json["generateURI"],
        setAsOffline: json["setAsOffline"],
        isDropOpen: json["isDropOpen"] ?? false,
        isDownload: json["isDownload"] ?? false,
        modelSupportedOffline: json["modelSupportedOffline"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "modelId": modelId,
        "bimModelId": bimModelId,
        "projectId": projectId,
        "projectName": projectName,
        "bimModelName": bimModelName,
        "modelDescription": modelDescription,
        "userModelName": userModelName,
        "workPackageId": workPackageId,
        "modelCreatorUserId": modelCreatorUserId,
        "modelStatus": modelStatus,
        "modelCreationDate": modelCreationDate,
        "lastUpdateDate": lastUpdateDate,
        "mergeLevel": mergeLevel,
        "isFavoriteModel": isFavoriteModel,
        "dc": dc,
        "modelViewId": modelViewId,
        "revisionId": revisionId,
        "folderId": folderId,
        "revisionNumber": revisionNumber,
        "worksetId": worksetId,
        "docId": docId,
        "publisher": publisher,
        "lastUpdatedUserId": lastUpdatedUserId,
        "lastUpdatedBy": lastUpdatedBy,
        "lastAccessUserId": lastAccessUserId,
        "lastAccessBy": lastAccessBy,
        "lastAccessModelDate": lastAccessModelDate,
        "modelTypeId": modelTypeId,
        "worksetdetails": worksetdetails?.toJson(),
        "workingFolders": workingFolders?.toJson(),
        "generateURI": generateUri,
        "setAsOffline": setAsOffline,
        "isDropOpen": isDropOpen,
        "isDownload": isDownload,
        "fileSize": fileSize,
        "modelSupportedOffline": modelSupportedOffline,
      };

  @override
  List<Object?> get props => [
        modelId,
        bimModelId,
        projectId,
        projectName,
        bimModelName,
        modelDescription,
        userModelName,
        workPackageId,
        modelCreatorUserId,
        modelStatus,
        modelCreationDate,
        lastUpdateDate,
        mergeLevel,
        isFavoriteModel,
        dc,
        modelViewId,
        revisionId,
        folderId,
        revisionNumber,
        worksetId,
        docId,
        publisher,
        lastUpdatedUserId,
        lastUpdatedBy,
        lastAccessUserId,
        lastAccessBy,
        lastAccessModelDate,
        modelTypeId,
        worksetdetails,
        workingFolders,
        generateUri,
        setAsOffline,
        isDropOpen,
        isDownload,
        fileSize,
        downloadProgress,
        modelSupportedOffline,
      ];
}
