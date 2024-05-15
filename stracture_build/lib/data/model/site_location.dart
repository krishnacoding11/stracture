import 'dart:convert';

import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter/material.dart';

import 'pflocationtreedetail.dart';

class SiteLocation {
  SiteLocation({this.globalKey, this.folderTitle, this.permissionValue, this.isActive, this.folderPath, this.folderId, this.folderPublishPrivateRevPref, this.clonedFolderId, this.isPublic, this.projectId, this.hasSubFolder, this.isFavourite, this.fetchRuleId, this.includePublicSubFolder, this.parentFolderId, this.pfLocationTreeDetail, this.isPFLocationTree, this.isWatching, this.instanceGroupIds, this.ownerName, this.isPlanSelected, this.isMandatoryAttribute, this.isShared, this.publisherId, this.imgModifiedDate, this.userImageName, this.orgName, this.isSharedByOther, this.permissionTypeId, this.generateURI, this.progress, this.locationSizeInByte});

  SiteLocation.fromJson(dynamic json) {
    folderTitle = json['folder_title'];
    permissionValue = json['permission_value'];
    isActive = json['isActive'];
    if (json['folderPath'] != null) {
      folderPath = json['folderPath'];
    } else {
      folderPath = json['baseFilePath'];
    }
    folderId = json['folderId'];
    folderPublishPrivateRevPref = json['folderPublishPrivateRevPref'];
    clonedFolderId = json['clonedFolderId'];
    isPublic = json['isPublic'];
    projectId = json['projectId'];
    hasSubFolder = json['hasSubFolder'];
    isFavourite = json['isFavourite'];
    fetchRuleId = json['fetchRuleId'];
    includePublicSubFolder = json['includePublicSubFolder'];
    parentFolderId = json['parentFolderId'];
    if (json['pfLocationTreeDetail'] != null) {
      pfLocationTreeDetail = PfLocationTreeDetail.fromJson(json['pfLocationTreeDetail']);
    } else if (json['pfLocationDetails'] != null) {
      pfLocationTreeDetail = PfLocationTreeDetail.fromJson(json['pfLocationDetails']);
    } else {
      pfLocationTreeDetail = null;
    }
    isPFLocationTree = json['isPFLocationTree'];
    isWatching = json['isWatching'];
    permissionValue = json['permissionValue'];
    instanceGroupIds = json['instanceGroupIds'];
    ownerName = json['ownerName'];
    isPlanSelected = json['isPlanSelected'];
    isMandatoryAttribute = json['isMandatoryAttribute'];
    isShared = json['isShared'];
    publisherId = json['publisherId'];
    imgModifiedDate = json['imgModifiedDate'];
    userImageName = json['userImageName'];
    orgName = json['orgName'];
    isSharedByOther = json['isSharedByOther'];
    permissionTypeId = json['permissionTypeId'];
    if (json['childfolderTreeVOList'] != null) {
      childTree = jsonListToLocationList(json['childfolderTreeVOList']);
    } else if (json['childLocationsList'] != null) {
      childTree = jsonListToLocationList(json['childLocationsList']);
    } else {
      childTree = [];
    }
    generateURI = json['generateURI'];
    hasPermissionError = json['hasPermissionError'];
    canRemoveOffline = json['canRemoveOffline'];
    isMarkOffline = json['isMarkOffline'];
    syncStatus = json['syncStatus'] != null ? ESyncStatus.fromNumber(json['syncStatus']) : null;
  }

  GlobalKey? globalKey = GlobalKey(debugLabel: 'site_location');
  String? folderTitle;
  int? permissionValue;
  int? isActive;
  String? folderPath;
  String? folderId;
  int? folderPublishPrivateRevPref;
  int? clonedFolderId;
  bool? isPublic;
  String? projectId;
  bool? hasSubFolder;
  bool? isFavourite;
  int? fetchRuleId;
  bool? includePublicSubFolder;
  int? parentFolderId;
  PfLocationTreeDetail? pfLocationTreeDetail;
  bool? isPFLocationTree;
  bool? isWatching;
  String? instanceGroupIds;
  String? ownerName;
  bool? isPlanSelected;
  bool? isMandatoryAttribute;
  bool? isShared;
  String? publisherId;
  String? imgModifiedDate;
  String? userImageName;
  String? orgName;
  bool? isSharedByOther;
  int? permissionTypeId;
  bool? generateURI;
  List<SiteLocation>? childLocation = [];
  List<SiteLocation> childTree = [];
  bool isLocationFetching = false;
  String? treeIndexPos;
  String? treeFolderIdPath;
  bool? hasPermissionError; // Added for handle recent location permission error
  bool? canRemoveOffline;
  bool? isMarkOffline;
  ESyncStatus? syncStatus;
  String? lastSyncTimeStamp;
  String? newSyncTimeStamp;
  bool? isCheckForMarkOffline;
  double? progress;
  String? locationSizeInByte = "0";

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['folder_title'] = folderTitle;
    map['permission_value'] = permissionValue;
    map['isActive'] = isActive;
    map['folderPath'] = folderPath;
    map['folderId'] = folderId;
    map['folderPublishPrivateRevPref'] = folderPublishPrivateRevPref;
    map['clonedFolderId'] = clonedFolderId;
    map['isPublic'] = isPublic;
    map['projectId'] = projectId;
    map['hasSubFolder'] = hasSubFolder;
    map['isFavourite'] = isFavourite;
    map['fetchRuleId'] = fetchRuleId;
    map['includePublicSubFolder'] = includePublicSubFolder;
    map['parentFolderId'] = parentFolderId;
    if (pfLocationTreeDetail != null) {
      map['pfLocationTreeDetail'] = pfLocationTreeDetail!.toJson();
    }
    if (childTree != null) {
      List<Map<String, dynamic>> childMaps = [];
      for (SiteLocation childLoc in childTree) {
        childMaps.add(childLoc.toJson());
      }
      map['childfolderTreeVOList'] = childMaps;
    }
    map['isPFLocationTree'] = isPFLocationTree;
    map['isWatching'] = isWatching;
    map['permissionValue'] = permissionValue;
    map['instanceGroupIds'] = instanceGroupIds;
    map['ownerName'] = ownerName;
    map['isPlanSelected'] = isPlanSelected;
    map['isMandatoryAttribute'] = isMandatoryAttribute;
    map['isShared'] = isShared;
    map['publisherId'] = publisherId;
    map['imgModifiedDate'] = imgModifiedDate;
    map['userImageName'] = userImageName;
    map['orgName'] = orgName;
    map['isSharedByOther'] = isSharedByOther;
    map['permissionTypeId'] = permissionTypeId;
    map['generateURI'] = generateURI;
    map['hasPermissionError'] = hasPermissionError;
    map['canRemoveOffline'] = canRemoveOffline;
    map['isMarkOffline'] = isMarkOffline;
    map['syncStatus'] = syncStatus?.value;
    return map;
  }

  static List<SiteLocation> jsonListToLocationList(dynamic response) {
    return List<SiteLocation>.from(response.map((x) => SiteLocation.fromJson(x))).toList();
  }

  static List<SiteLocation>? jsonToList(dynamic response) {
    var jsonData = json.decode(response);
    return jsonListToLocationList(jsonData);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is SiteLocation && runtimeType == other.runtimeType && folderId.plainValue() == other.folderId.plainValue();

  @override
  int get hashCode => folderId.hashCode;
}
