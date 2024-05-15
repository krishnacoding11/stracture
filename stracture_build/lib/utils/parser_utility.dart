
import 'dart:convert';

import 'package:field/utils/extensions.dart';

import '../logger/logger.dart';

class ParserUtility {
  static const _formTypeJsonKeyList = ["formTypeID","default_action","instance_group_id","parent_formtype_id","xsnFile","revisionId","formId","customObjectInstanceId","docId",
    "projectId","linkedWorkspaceProjectId","default_folder_id","formTypeId","bfpc","had","actionID","orgId","displayFileName"];

  static const _formTypeDistributionJsonKeyList = ["orgID","hashedOrgId","roleID","userID","projectID","actionID","projectId","revisionId","formId","customObjectInstanceId","docId",
    "roleId","hashedId","defaultActionID","folderID"];

  static const _formTypeControllerUserJsonKeyList = ["projectId","userID"];

  static const _formTypeStatusJsonKeyList = ["orgId"];

  static const _formAttachAndAssocJsonKeyList = ["projectId", "folderId", "msgId", "entityId", "assocsParentId", "revisionId", "modelId", "docId", "allowDownloadToken", "commId", "commentMsgId", "formTypeId", "formId", "userID", "instance_group_id", "dist_list_id", "instanceGroupId", "project_APD_folder_id", "attachmentId", "commentMsgId"];

  static const _sentActionsJsonKeyList = ["projectId","msgId","commentMsgId","instanceGroupId","modelId","distributionLevelId"];

  static const _draftSentActionsJsonKeyList = ["actionID","userID","projectId"];

  static String deHashJsonData({required String jsonData, required List<String> deHashKeys}) {
    String newJson = jsonData;
    if (newJson.isNotEmpty) {
      try {
        var jsonNode = jsonDecode(newJson);
        jsonNode = ParserUtility._deHashJsonData(jsonNode, deHashKeys);
        newJson = jsonEncode(jsonNode);
      } on Exception catch (e) {
        Log.d("ParserUtility::deHashJsonData exception=$e");
      }
    }
    return newJson;
  }

  static dynamic _deHashJsonData(dynamic node, List<String> keys, {String parentKey = ""}) {
    if (node is Map) {
      node.forEach((key, value) {
        node[key] = ParserUtility._deHashJsonData(value, keys, parentKey: key);
      });
    } else if (node is List) {
      for (int i = 0; i < node.length; i++) {
        node[i] = ParserUtility._deHashJsonData(node[i], keys, parentKey: parentKey);
      }
    } else if (node is String) {
      if (keys.contains(parentKey)) {
        if (node.contains("\$\$")) {
          node = node.plainValue();
        }
      }
    }
    return node;
  }

  static dynamic getObjectValueFromJson(String jsonData, String objectKey) {
    dynamic itemObject;
    if (jsonData.isNotEmpty) {
      itemObject = ParserUtility.getObjectValueFromJsonObject(jsonDecode(jsonData), objectKey);
    }
    return itemObject;
  }

  static dynamic getObjectValueFromJsonObject(dynamic jsonObject, String objectKey) {
    dynamic itemObject;
    if (jsonObject is Map) {
      if (jsonObject.containsKey(objectKey)) {
        itemObject = jsonObject[objectKey].toString();
      } else {
        for (var dataMap in jsonObject.entries) {
          itemObject = ParserUtility.getObjectValueFromJsonObject(dataMap.value, objectKey);
          if (itemObject != null) {
            break;
          }
        }
      }
    } else if (jsonObject is List) {
      for (int i = 0; i < jsonObject.length; i++) {
        itemObject = ParserUtility.getObjectValueFromJsonObject(jsonObject[i], objectKey);
        if (itemObject != null) {
          break;
        }
      }
    }
    return itemObject;
  }

  static String formTypeJsonDeHashed({required String jsonData}) {
    String newJsonData = jsonData;
    if (newJsonData.isNotEmpty) {
      newJsonData = ParserUtility.deHashJsonData(jsonData: newJsonData,deHashKeys: ParserUtility._formTypeJsonKeyList);
    }
    return newJsonData;
  }

  static String formTypeDistributionJsonDeHashed({required String jsonData}) {
    String newJsonData = jsonData;
    if (newJsonData.isNotEmpty) {
      newJsonData = ParserUtility.deHashJsonData(jsonData: newJsonData,deHashKeys: ParserUtility._formTypeDistributionJsonKeyList);
    }
    return newJsonData;
  }

  static String formTypeControllerUserJsonDeHashed({required String jsonData}) {
    String newJsonData = jsonData;
    if (newJsonData.isNotEmpty) {
      newJsonData = ParserUtility.deHashJsonData(jsonData: newJsonData,deHashKeys: ParserUtility._formTypeControllerUserJsonKeyList);
    }
    return newJsonData;
  }

  static String formTypeStatusJsonDeHashed({required String jsonData}) {
    String newJsonData = jsonData;
    if (newJsonData.isNotEmpty) {
      newJsonData = ParserUtility.deHashJsonData(jsonData: newJsonData,deHashKeys: ParserUtility._formTypeStatusJsonKeyList);
    }
    return newJsonData;
  }

  static String formAttachAndAssociationJsonDeHashed({required String jsonData}) {
    String newJsonData = jsonData;
    if (newJsonData.isNotEmpty) {
      newJsonData = ParserUtility.deHashJsonData(jsonData: newJsonData,deHashKeys: ParserUtility._formAttachAndAssocJsonKeyList);
    }
    return newJsonData;
  }

  static Map<String,dynamic> removeKeysFromMap(Map<String,dynamic> dataMap, List<String> removeKeyList) {
    for (var removeKey in removeKeyList) {
      if (dataMap.containsKey(removeKey)) {
        dataMap.remove(removeKey);
      }
    }
    return dataMap;
  }

  static String sentActionsJsonDeHashed({required String jsonData}) {
    String newJsonData = jsonData;
    if (newJsonData.isNotEmpty) {
      newJsonData = ParserUtility.deHashJsonData(jsonData: newJsonData,deHashKeys: ParserUtility._sentActionsJsonKeyList);
    }
    return newJsonData;
  }

  static String draftSentActionsJsonDeHashed({required String jsonData}) {
    String newJsonData = jsonData;
    if (newJsonData.isNotEmpty) {
      newJsonData = ParserUtility.deHashJsonData(jsonData: newJsonData,deHashKeys: ParserUtility._draftSentActionsJsonKeyList);
    }
    return newJsonData;
  }
}