import 'dart:collection';
import 'dart:convert';

import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:flutter/foundation.dart';

import '../../analytics/event_analytics.dart';

class FieldNavigator {
  Future<Object?> navigate(QRCodeDataVo voObj, dynamic response) async {
    switch (voObj?.qrCodeType) {
      case QRCodeType.qrLocation:
        {
          return navigateToPlan(voObj, response);
        }
      case QRCodeType.qrFormType:
        {
          return await navigateToCreateForm(voObj, response);
        }
      default:
        return null;
    }
  }

  Object navigateToPlan(QRCodeDataVo voObj, dynamic response) async {
    List<Project> items = [];
    if (response.data != null) {
      for (var item in response.data!) {
        items.add(item);
      }
    }
    if (items.isNotEmpty) {
      Project objProj = items.first;
      await StorePreference.setSelectedProjectData(objProj);
      getIt<ToolbarCubit>().updateTitleFromItemType(currentSelectedItem: NavigationMenuItemType.home, title: objProj.projectName);
      List<SiteLocation>? siteLocationList = List<SiteLocation>.from(objProj.childfolderTreeVOList.map((x) => SiteLocation.fromJson(x))).toList();
      LinkedHashMap<String, List<SiteLocation>?>? mapLocations = await compute(getLocationMap, objProj);
      List<dynamic> listBreadCrumb = [objProj];
      listBreadCrumb.addAll(await compute(addListCrumbData, siteLocationList));
      Map<String, dynamic> arguments = {};
      arguments['projectDetail'] = objProj;
      arguments['mapLocations'] = mapLocations;
      arguments['selectedLocation'] = getSelectedLocationFromFolderId(voObj.folderId!, siteLocationList);
      arguments['listBreadCrumb'] = listBreadCrumb;
      return arguments;
    } else {
      Log.d("ProjectList empty or Not available");
      return null;
    }
  }

  SiteLocation? getSelectedLocationFromFolderId(String parentFolderId, List<SiteLocation>? listChild) {
    for (var element in listChild!) {
      if (element.folderId.plainValue() == parentFolderId.plainValue()) {
        return element;
      } else if (element.childTree.isNotEmpty) {
        SiteLocation? siteLocation = getSelectedLocationFromFolderId(parentFolderId, element.childTree);
        if (siteLocation != null) return siteLocation;
      }
    }
    return null;
  }

  static LinkedHashMap<String, List<SiteLocation>?> getLocationMap(Project project) {
    LinkedHashMap<String, List<SiteLocation>?> mapLocations = LinkedHashMap();
    List<SiteLocation>? siteLocationList = List<SiteLocation>.from(project.childfolderTreeVOList.map((x) => SiteLocation.fromJson(x))).toList();
    mapLocations.putIfAbsent(project.projectID!, () => siteLocationList);
    for (var element in siteLocationList) {
      if (element.childTree.isNotEmpty) {
        //List<SiteLocation> childList = List<SiteLocation>.from(element.childTree.map((x) => SiteLocation.fromJson(x))).toList();
        LinkedHashMap<String, List<SiteLocation>?> result = getMap(element.childTree, element);
        if (result.isNotEmpty) {
          mapLocations.addAll(result);
        }
      }
    }
    return mapLocations;
  }

  static getMap(List<SiteLocation>? listChild, SiteLocation parent) {
    LinkedHashMap<String, List<SiteLocation>?> mapLocations = LinkedHashMap();
    mapLocations.putIfAbsent(parent.folderId!, () => listChild);
    for (var element in listChild!) {
      if (element.childTree.isNotEmpty) {
        //List<SiteLocation> childList = List<SiteLocation>.from(element.childTree.map((x) => SiteLocation.fromJson(x))).toList();
        LinkedHashMap<String, List<SiteLocation>?> result = getMap(element.childTree, element);
        if (result.isNotEmpty) {
          mapLocations.addAll(result);
        }
      }
    }
    return mapLocations;
  }

  static List<dynamic> addListCrumbData(List<SiteLocation>? listChild) {
    List<dynamic> returnList = [];
    for (var element in listChild!) {
      if (element.childTree.isNotEmpty) {
        returnList.add(element);
        //List<SiteLocation> childList = List<SiteLocation>.from(element.childTree.map((x) => SiteLocation.fromJson(x))).toList();
        List<dynamic> result = addListCrumbData(element.childTree);
        if (result.isNotEmpty) {
          returnList.addAll(result);
        }
      }
    }
    return returnList;
  }

  Future<Object> navigateToCreateForm(QRCodeDataVo voObj, dynamic response) async {
    String projectID = voObj?.projectId ?? "";
    String locationID = voObj?.locationId ?? "";
    String instanceGroupID = voObj?.instanceGroupId ?? "";
    String appTypeID = "";
    String appBuilderID = "";
    String name = "";
    var jsonObject = {};
    Map<String, dynamic> obj = {};
    if (response.data != null) {
      try {
        String jsonString = response.data;
        jsonObject = json.decode(jsonString);
        jsonObject = jsonObject['formTypeGroupList'].first;
        jsonObject = jsonObject['formType_List'].first;
        var formTypeDetail = jsonObject['formTypesDetail'];
        formTypeDetail = formTypeDetail['formTypeVO'];
        appTypeID = formTypeDetail['appTypeId'].toString();
        appBuilderID = jsonObject['appBuilderID'];
        instanceGroupID = formTypeDetail['formTypeID'];
        projectID = formTypeDetail['projectId'];
        name = formTypeDetail['formTypeName'] ?? "";
      } catch (_) {}
    }

    obj['projectId'] = projectID;
    if (locationID.isNotEmpty) {
      obj['locationId'] = locationID;
    }
    obj['appTypeId'] = appTypeID;
    if (appBuilderID.isNotEmpty) {
      obj['formSelectRadiobutton'] = "${voObj.dcId ?? 1}_${projectID}_${instanceGroupID}_$appBuilderID";
    } else {
      obj['formSelectRadiobutton'] = "${voObj.dcId ?? 1}_${projectID}_$instanceGroupID";
    }

    String url = "";
    if (isNetWorkConnected()) {
      url = await UrlHelper.getCreateFormURL(obj,screenName: FireBaseFromScreen.qrcode);
    } else {
      Project? project = await StorePreference.getSelectedProjectData();
      obj['appBuilderCode'] = jsonObject['appBuilderCode'];
      obj['projectName'] = jsonObject['projectName'];
      obj['msgId'] = jsonObject['msgId'];
      obj['formId'] = jsonObject['formId'];
      obj['formTypeID'] = jsonObject['formTypeID'];
      obj['formTypeName'] = jsonObject['formTypeName'];
      obj['instanceGroupId'] = instanceGroupID;
      obj['isFromWhere'] = jsonObject['isFromWhere'];
      obj['formSelectRadiobutton'] = "${project?.dcId ?? "1"}_${projectID}_${jsonObject['formTypeID']}";

      obj['formTypeId'] = instanceGroupID;
      obj['templateType'] = jsonObject['templateType'];
      obj['appBuilderId'] = appBuilderID;
      obj['offlineFormId'] = DateTime.now().millisecondsSinceEpoch;
      obj['isUploadAttachmentInTemp'] = true;
      url = await FileFormUtility.getOfflineCreateFormPath(obj);
    }

    obj['projectId'] = projectID;
    obj['locationId'] = locationID;
    obj['url'] = url;
    obj['name'] = name;
    return obj;
  }
}
