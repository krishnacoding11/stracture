import 'dart:collection';
import 'dart:io';

import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';

import '../data/model/site_location.dart';

class SiteUtility {
  static Future<SiteLocation?> getLocationFromAnnotationId(String annotationId, List<SiteLocation>? listChild,
      {LinkedHashMap<String, List<SiteLocation>?>? mapSiteLocation}) async {
    if (mapSiteLocation != null && mapSiteLocation.isNotEmpty) {
      for (var mapElement in mapSiteLocation.values) {
        SiteLocation? siteLocation = await getLocationFromAnnotationId(annotationId, mapElement);
        if (siteLocation != null) return siteLocation;
      }
    }

    for (var element in listChild!) {
      if (element.pfLocationTreeDetail!.annotationId.toString() == annotationId) {
        return element;
      } else if (element.childLocation != null && element.childLocation!.isNotEmpty) {
        SiteLocation? siteLocation = await getLocationFromAnnotationId(annotationId, element.childLocation!);
        if (siteLocation != null) return siteLocation;
      } else if (element.childTree.isNotEmpty) {
        SiteLocation? siteLocation = await getLocationFromAnnotationId(annotationId, element.childTree);
        if (siteLocation != null) return siteLocation;
      }
    }
    return null;
  }

  static Future<String?> getModelDirPath(String projectId, String revisionId, String modelID, String ext) async {
    String plainProjectId = projectId.plainValue();
    String modelId = modelID.plainValue();
    String plainRevisionId = revisionId.plainValue();
    String fileName = "$modelId/$plainRevisionId$ext";
    String dirPath = await Utility.getUserDirPath(path: plainProjectId) as String;
    return "$dirPath/$fileName";
  }

  static SiteLocation? getLocationFromLocationId(int locationId, List<SiteLocation>? listChild,
      {LinkedHashMap<String, List<SiteLocation>?>? mapSiteLocation}) {
    if (mapSiteLocation != null) {
      for (var mapElement in mapSiteLocation.values) {
        SiteLocation? siteLocation = getLocationFromLocationId(locationId, mapElement);
        if (siteLocation != null) return siteLocation;
      }
    }
    if (listChild != null) {
      for (var element in listChild) {
        if (element.pfLocationTreeDetail!.locationId! == locationId) {
          return element;
        } else if (element.childLocation != null && element.childLocation!.isNotEmpty) {
          SiteLocation? siteLocation = getLocationFromLocationId(locationId, element.childLocation!);
          if (siteLocation != null) return siteLocation;
        } else if (element.childTree.isNotEmpty) {
          SiteLocation? siteLocation = getLocationFromLocationId(locationId, element.childTree);
          if (siteLocation != null) return siteLocation;
        }
      }
    }
    return null;
  }

  static Future<String?> getSiteDirPath(String projectId, String revisionId, String ext) async {
    String plainProjectId = projectId.plainValue();
    String plainRevisionId = revisionId.plainValue();
    String fileName = "$plainRevisionId$ext";
    String dirPath = await Utility.getUserDirPath(path: plainProjectId) as String;
    return "$dirPath/$fileName";
  }

  static bool isLocationHasPlan(SiteLocation? location) {
    if (location == null ||
        location.pfLocationTreeDetail == null ||
        location.pfLocationTreeDetail!.revisionId.isNullOrEmpty() ||
        location.pfLocationTreeDetail!.revisionId.plainValue() == "0") {
      return false;
    }
    String plainRevisionId = location.pfLocationTreeDetail!.revisionId.plainValue();
    return location.isActive == 1 && !plainRevisionId.isNullEmptyZeroOrFalse();
  }

  static Future<String?>? getContentXfdfFile(String xfdfPath) async {
    String contents = await File(xfdfPath).readAsString();
    if (!contents.isNullOrEmpty() && contents.startsWith("<?xml")) {
      return contents;
    }
    return null;
  }
}
