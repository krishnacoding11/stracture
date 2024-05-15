import 'dart:convert';

class QualityPlanListVo {
  QualityPlanListVo({
      this.totalDocs, 
      this.recordBatchSize, 
      this.listingType, 
      this.currentPageNo, 
      this.recordStartFrom, 
      this.columnHeader, 
      this.data, 
      this.sortField, 
      this.sortFieldType, 
      this.sortOrder, 
      this.editable, 
      this.isIncludeSubFolder, 
      this.totalListData,});

  QualityPlanListVo.fromJson(dynamic json) {
    totalDocs = json['totalDocs'];
    recordBatchSize = json['recordBatchSize'];
    listingType = json['listingType'];
    currentPageNo = json['currentPageNo'];
    recordStartFrom = json['recordStartFrom'];
    if (json['columnHeader'] != null) {
      columnHeader = [];
      json['columnHeader'].forEach((v) {
        columnHeader?.add(ColumnHeader.fromJson(v));
      });
    }
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    sortField = json['sortField'];
    sortFieldType = json['sortFieldType'];
    sortOrder = json['sortOrder'];
    editable = json['editable'];
    isIncludeSubFolder = json['isIncludeSubFolder'];
    totalListData = json['totalListData'];
  }
  int? totalDocs;
  int? recordBatchSize;
  int? listingType;
  int? currentPageNo;
  int? recordStartFrom;
  List<ColumnHeader>? columnHeader;
  List<Data>? data;
  String? sortField;
  String? sortFieldType;
  String? sortOrder;
  bool? editable;
  bool? isIncludeSubFolder;
  int? totalListData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['totalDocs'] = totalDocs;
    map['recordBatchSize'] = recordBatchSize;
    map['listingType'] = listingType;
    map['currentPageNo'] = currentPageNo;
    map['recordStartFrom'] = recordStartFrom;
    if (columnHeader != null) {
      map['columnHeader'] = columnHeader?.map((v) => v.toJson()).toList();
    }
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['sortField'] = sortField;
    map['sortFieldType'] = sortFieldType;
    map['sortOrder'] = sortOrder;
    map['editable'] = editable;
    map['isIncludeSubFolder'] = isIncludeSubFolder;
    map['totalListData'] = totalListData;
    return map;
  }

  static QualityPlanListVo parseJson(dynamic response){
    String jsonDataString = response.toString();
    final json = jsonDecode(jsonDataString);
    return QualityPlanListVo.fromJson(json);
  }

}
class Data {
  Data({
    this.id,
    this.projectId,
    this.projectName,
    this.planId,
    this.planTitle,
    this.percentageCompletion,
    this.createdBy,
    this.createdByUserid,
    this.planCreationDate,
    this.createdByName,
    this.lastupdatedate,
    this.updatedById,
    this.lastupdatedbyName,
    this.updatedDateInMS,
    this.planCreationDateInMS,
    this.firstName,
    this.lastName,
    this.orgName,
    this.lastUpdatedUserOrg,
    this.createdByUser,
    this.lastUpdatedUser,
    this.lastUpdatedUserFname,
    this.lastUpdatedUserLname,
    this.dcId,
    this.lastSyncDate,
    this.generateURI,});

  Data.fromJson(dynamic json) {
    id = json['id'];
    projectId = json['projectId'];
    projectName = json['projectName'];
    planId = json['planId'];
    planTitle = json['planTitle'];
    percentageCompletion = json['percentageCompletion'];
    createdBy = json['createdBy'];
    createdByUserid = json['createdByUserid'];
    planCreationDate = json['planCreationDate'];
    createdByName = json['createdByName'];
    lastupdatedate = json['lastupdatedate'];
    updatedById = json['updatedById'];
    lastupdatedbyName = json['lastupdatedbyName'];
    updatedDateInMS = json['updatedDateInMS'];
    planCreationDateInMS = json['planCreationDateInMS'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    orgName = json['orgName'];
    lastUpdatedUserOrg = json['lastUpdatedUserOrg'];
    createdByUser = json['createdByUser'];
    lastUpdatedUser = json['lastUpdatedUser'];
    lastUpdatedUserFname = json['lastUpdatedUserFname'];
    lastUpdatedUserLname = json['lastUpdatedUserLname'];
    dcId = json['dcId'];
    lastSyncDate = json['lastSyncDate'];
    generateURI = json['generateURI'];
  }
  int? id;
  String? projectId;
  String? projectName;
  String? planId;
  String? planTitle;
  int? percentageCompletion;
  String? createdBy;
  String? createdByUserid;
  String? planCreationDate;
  String? createdByName;
  String? lastupdatedate;
  String? updatedById;
  String? lastupdatedbyName;
  int? updatedDateInMS;
  int? planCreationDateInMS;
  String? firstName;
  String? lastName;
  String? orgName;
  String? lastUpdatedUserOrg;
  String? createdByUser;
  String? lastUpdatedUser;
  String? lastUpdatedUserFname;
  String? lastUpdatedUserLname;
  int? dcId;
  String? lastSyncDate;
  bool? generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['projectId'] = projectId;
    map['projectName'] = projectName;
    map['planId'] = planId;
    map['planTitle'] = planTitle;
    map['percentageCompletion'] = percentageCompletion;
    map['createdBy'] = createdBy;
    map['createdByUserid'] = createdByUserid;
    map['planCreationDate'] = planCreationDate;
    map['createdByName'] = createdByName;
    map['lastupdatedate'] = lastupdatedate;
    map['updatedById'] = updatedById;
    map['lastupdatedbyName'] = lastupdatedbyName;
    map['updatedDateInMS'] = updatedDateInMS;
    map['planCreationDateInMS'] = planCreationDateInMS;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['orgName'] = orgName;
    map['lastUpdatedUserOrg'] = lastUpdatedUserOrg;
    map['createdByUser'] = createdByUser;
    map['lastUpdatedUser'] = lastUpdatedUser;
    map['lastUpdatedUserFname'] = lastUpdatedUserFname;
    map['lastUpdatedUserLname'] = lastUpdatedUserLname;
    map['dcId'] = dcId;
    map['lastSyncDate'] = lastSyncDate;
    map['generateURI'] = generateURI;
    return map;
  }

}

class ColumnHeader {
  ColumnHeader({
    this.id,
    this.fieldName,
    this.solrIndexfieldName,
    this.colDisplayName,
    this.colType,
    this.userIndex,
    this.imgName,
    this.tooltipSrc,
    this.dataType,
    this.function,
    this.funParams,
    this.wrapData,
    this.widthOfColumn,
    this.isSortSupported,
    this.isCustomAttributeColumn,
    this.isActive,});

  ColumnHeader.fromJson(dynamic json) {
    id = json['id'];
    fieldName = json['fieldName'];
    solrIndexfieldName = json['solrIndexfieldName'];
    colDisplayName = json['colDisplayName'];
    colType = json['colType'];
    userIndex = json['userIndex'];
    imgName = json['imgName'];
    tooltipSrc = json['tooltipSrc'];
    dataType = json['dataType'];
    function = json['function'];
    funParams = json['funParams'];
    wrapData = json['wrapData'];
    widthOfColumn = json['widthOfColumn'];
    isSortSupported = json['isSortSupported'];
    isCustomAttributeColumn = json['isCustomAttributeColumn'];
    isActive = json['isActive'];
  }
  String? id;
  String? fieldName;
  String? solrIndexfieldName;
  String? colDisplayName;
  String? colType;
  int? userIndex;
  String? imgName;
  String? tooltipSrc;
  String? dataType;
  String? function;
  String? funParams;
  String? wrapData;
  int? widthOfColumn;
  bool? isSortSupported;
  bool? isCustomAttributeColumn;
  bool? isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['fieldName'] = fieldName;
    map['solrIndexfieldName'] = solrIndexfieldName;
    map['colDisplayName'] = colDisplayName;
    map['colType'] = colType;
    map['userIndex'] = userIndex;
    map['imgName'] = imgName;
    map['tooltipSrc'] = tooltipSrc;
    map['dataType'] = dataType;
    map['function'] = function;
    map['funParams'] = funParams;
    map['wrapData'] = wrapData;
    map['widthOfColumn'] = widthOfColumn;
    map['isSortSupported'] = isSortSupported;
    map['isCustomAttributeColumn'] = isCustomAttributeColumn;
    map['isActive'] = isActive;
    return map;
  }

}

