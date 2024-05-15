import 'dart:convert';
import 'dart:io';

import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/form_status_history_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/offline_activity_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/dao/status_style_dao.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/form_message_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/parser_utility.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:intl/intl.dart';

import '../../data/dao/form_message_action_dao.dart';
import '../../data/dao/form_message_attachAndAssoc_dao.dart';
import '../../data/dao/location_dao.dart';
import '../../data/model/form_message_attach_assoc_vo.dart';
import '../../data/model/site_form_action.dart';
import '../../data/model/site_location.dart';
import '../../utils/field_enums.dart';
import '../../utils/file_utils.dart';
import '../base/base_local_data_source.dart';

class FormLocalDataSource extends BaseLocalDataSource {
  Future<String> getFormTypeViewCustomAttributeData({required String projectId, required String formTypeId, String viewName = ""}) async {
    String customAttribute = await getFormTypeViewAttributeData(projectId, formTypeId, "CA_", viewName);
    Log.d("FormLocalDataSource::getFormTypeViewCustomAttributeData customAttribute=$customAttribute");
    return customAttribute;
  }

  Future<String> getFormTypeViewCustomAttributeSetData({required String projectId, required String formTypeId, String viewName = ""}) async {
    String customAttribute = await getFormTypeViewAttributeData(projectId, formTypeId, "", "attributeSetId");
    Log.d("FormLocalDataSource::getFormTypeViewCustomAttributeData customAttribute=$customAttribute");
    return customAttribute;
  }

  Future<String> getFormTypeViewFixFieldSPData({required String projectId, required String formTypeId, String viewName = ""}) async {
    String fixFieldSpData = await getFormTypeViewAttributeData(projectId, formTypeId, "SP_", viewName);
    Log.d("FormLocalDataSource::getFormTypeViewFixFieldSPData fixFieldSpData=$fixFieldSpData");
    return fixFieldSpData;
  }

  Future<String> getFormTypeViewAttributeData(String projectId, String formTypeId, String attributePrefix, String viewName) async {
    String attributeData = "";
    String dataJsonPath = await AppPathHelper().getFormTypeDataJsonFilePath(projectId: projectId, formTypeId: formTypeId);
    Log.d("FormLocalDataSource::getFormTypeViewAttributeData dataJsonPath=$dataJsonPath");
    String strDataJson = readFromFile(dataJsonPath);
    if (strDataJson.isNotEmpty) {
      try {
        var dataJsonNode = jsonDecode(strDataJson);
        var oriMsgFieldslist = dataJsonNode["Asite_System_Data_Read_Write"]?["ORI_MSG_Fields"];
        if (oriMsgFieldslist is Map && oriMsgFieldslist.isNotEmpty) {
          if (viewName == "") {
            Map<String, dynamic> strCustomAttributeDataNode = {};
            oriMsgFieldslist.forEach((key, value) {
              if (key.toString().startsWith(attributePrefix)) {
                strCustomAttributeDataNode[key] = value;
              }
            });
            if (strCustomAttributeDataNode.isNotEmpty) {
              attributeData = jsonEncode(strCustomAttributeDataNode);
            }
          } else {
            attributeData = oriMsgFieldslist["$attributePrefix$viewName"]?.toString() ?? "";
          }
        }
      } catch (e) {
        Log.d("FormLocalDataSource::getFormTypeViewAttributeData exception=$e");
      }
    }
    return attributeData;
  }

  Future<String> addFormTypeCustomAttributeInHtml(String htmlData, String customAttribute, String projectId, String formTypeId) async {
    if (htmlData.isNotEmpty && customAttribute.isNotEmpty && projectId.isNotEmpty && formTypeId.isNotEmpty) {
      String filePath = await AppPathHelper().getFormTypeCustomAttributeFilePath(projectId: projectId, formTypeId: formTypeId);
      String customAttributeJson = readFromFile(filePath);
      if (customAttributeJson != "") {
        try {
          var custAttrNode = jsonDecode(customAttributeJson);
          List<String> customAttributeList = customAttribute.split("##");
          for (var element in customAttributeList) {
            if (custAttrNode[element] != null) {
              String value = jsonEncode(custAttrNode[element]);
              value = value.replaceAll("\"", "&quot;");
              htmlData = htmlData.replaceAll("\${#vars.getVariable(#strings.unescapeJava('$element'))}", value);
            }
          }
        } on Exception catch (e) {
          Log.d("FormLocalDataSource::addFormTypeCustomAttributeInHtml exception=$e");
        }
      }
    }
    return htmlData;
  }

  Future<String> addFormTypeSPDataInHtml(String htmlData, String spDataAttribute, Map<String, dynamic> paramData, String formFixFieldJson) async {
    if (htmlData.isNotEmpty && spDataAttribute.isNotEmpty && paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      String fixFieldJson = await getFormTypeFixFieldDataJson(projectId, formTypeId);
      if (fixFieldJson.isNotEmpty) {
        List<String> spDataAttributeList = spDataAttribute.split(",");
        for (var attributeName in spDataAttributeList) {
          attributeName = attributeName.trim();
          try {
            String attribValue = "";
            switch (attributeName) {
              case "DS_getAllLocationByProject_PF":
                attribValue = await getSPData_DS_getAllLocationByProject_PF(paramData);
                break;
              case "DS_ASI_SITE_getAllLocationByProject_PF":
                attribValue = await getSPData_DS_ASI_SITE_getAllLocationByProject_PF(paramData);
                break;
              case "DS_SNG_AUS_GETALLLOCATIONBYPROJECT_PF":
                attribValue = await getSPData_DS_SNG_AUS_GETALLLOCATIONBYPROJECT_PF(paramData);
                break;
              case "DS_INCOMPLETE_ACTIONS":
                attribValue = await getSPData_DS_INCOMPLETE_ACTIONS(paramData);
                break;
              case "DS_SNG_GET_RECENT_DEFECTS":
                attribValue = await getSPData_DS_SNG_GET_RECENT_DEFECTS(paramData);
                break;
              case "DS_ASI_SITE_GET_RECENT_DEFECTS":
                attribValue = await getSPData_DS_ASI_SITE_GET_RECENT_DEFECTS(paramData);
                break;
              case "DS_SNG_AUS_GET_RECENT_DEFECTS":
                attribValue = await getSPData_DS_SNG_AUS_GET_RECENT_DEFECTS(paramData);
                break;
              case "DS_ALL_STATUS_WithCloseout":
                attribValue = await getSPData_DS_SNG_AUS_DS_ALL_STATUS_WithCloseout(paramData);
                break;
              case "DS_Get_All_Responses":
                attribValue = await getSPData_DS_Get_All_Responses(paramData);
                break;
              case "DS_ALDR_SITE_GET_RECENT_DEFECTS":
                attribValue = await getSPData_DS_ALDR_SITE_GET_RECENT_DEFECTS(paramData);
                break;
              case "ORI_FORMTITLE":
                attribValue = await getSPData_ORI_FORMTITLE(paramData);
                break;
              case "ORI_USERREF":
                attribValue = await getSPData_ORI_USERREF(paramData);
                break;
              case "DS_FORMID":
                attribValue = await getSPData_DS_FORMID(paramData);
                break;
              case "DS_ORIGINATOR":
                attribValue = await getSPData_DS_ORIGINATOR(paramData);
                break;
              case "DS_DATEOFISSUE":
                attribValue = await getSPData_DS_DATEOFISSUE(paramData);
                break;
              case "DS_CLOSE_DUE_DATE":
                attribValue = await getSPData_DS_CLOSE_DUE_DATE(paramData);
                break;
              case "DS_ISDRAFT":
                attribValue = await getSPData_DS_ISDRAFT(paramData);
                break;
              case "DS_ISDRAFT_RES_MSG":
                attribValue = await getSPData_DS_ISDRAFT_RES_MSG(paramData);
                break;
              case "DS_GET_MSG_DISTRIBUTION_LIST":
                attribValue = await getSPData_DS_GET_MSG_DISTRIBUTION_LIST(paramData);
                break;
              case "DS_DOC_ATTACHMENTS_ALL":
                attribValue = await getSPData_DS_DOC_ATTACHMENTS_ALL(paramData);
                break;
              case "DS_DOC_ASSOCIATIONS_ALL":
                attribValue = await getSPData_DS_DOC_ASSOCIATIONS_ALL(paramData);
                break;
              case "DS_FORMSTATUS":
                attribValue = await getSPData_DS_FORMSTATUS(paramData);
                break;
              default:
                String? tempAttribValue;
                if (formFixFieldJson.isNotEmpty) {
                  tempAttribValue = (jsonDecode(formFixFieldJson))[attributeName];
                }
                tempAttribValue ??= (jsonDecode(fixFieldJson))[attributeName] ?? "";
                attribValue = tempAttribValue!;
                if (attribValue.isEmpty) {
                  switch (attributeName) {
                    case "DS_WORKINGUSER":
                      attribValue = await getSPData_DS_WORKINGUSER(paramData, "");
                      break;
                    case "DS_WORKINGUSER_ID":
                      attribValue = await getSPData_DS_WORKINGUSER_ID(paramData, "");
                      break;
                    case "DS_PROJECTNAME":
                      attribValue = await getSPData_DS_PROJECTNAME(paramData, "");
                      break;
                    case "DS_FORMNAME":
                      attribValue = await getSPData_DS_FORMNAME(paramData, "");
                      break;
                    case "DS_FORMGROUPCODE":
                      attribValue = await getSPData_DS_FORMGROUPCODE(paramData, "");
                      break;
                    default:
                      attribValue = "";
                      break;
                  }
                }
                break;
            }
            Log.d("FormLocalDataSource::addFormTypeSPDataInHtml $attributeName=$attribValue");
            attribValue = attribValue.replaceAll("\"", "&quot;");
            String strSearchToken = "\${#vars.getVariable(#strings.unescapeJava('$attributeName'))}";
            if (htmlData.contains(strSearchToken, 0)) {
              htmlData = htmlData.replaceAll(strSearchToken, attribValue);
            }
            strSearchToken = "\${$attributeName}";
            if (htmlData.contains(strSearchToken, 0)) {
              htmlData = htmlData.replaceAll(strSearchToken, attribValue);
            }
          } on Exception catch (e) {
            Log.d("FormLocalDataSource::addFormTypeSPDataInHtml '$attributeName' exception=$e");
          }
        }
      }
    }
    return htmlData;
  }

  Future<String> getFormTypeFixFieldDataJson(String projectId, String formTypeId) async {
    String value = "";
    if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
      String fixFieldPath = await AppPathHelper().getFormTypeFixFieldFilePath(projectId: projectId, formTypeId: formTypeId);
      value = readFromFile(fixFieldPath);
    }
    return value;
  }

  String getSPValueFromFormTypeFixFieldDataJson(String fixFieldDataJson, String key) {
    String value = "";
    try {
      if (fixFieldDataJson.isNotEmpty) {
        value = jsonDecode(fixFieldDataJson)[key]?.toString() ?? "";
      }
    } on Exception catch (e) {
      Log.d("FormLocalDataSource::getSPValueFromFormTypeFixFieldDataJson $key exception=$e");
    }
    return value;
  }

  Future<String> getHTML5ChangeSPDataInJsonData(EHtmlRequestType eReqType, String dataJson, Map<String, dynamic> paramData) async {
    if (dataJson.isNotEmpty && paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      String fixFieldJson = await getFormTypeFixFieldDataJson(projectId, formTypeId);
      try {
        var dataJsonNode = jsonDecode(dataJson);
        switch (eReqType) {
          case EHtmlRequestType.create:
            {
              try {
                if (dataJsonNode.containsKey("Asite_System_Data_Read_Only")) {
                  if (dataJsonNode["Asite_System_Data_Read_Only"]?["_1_User_Data"]?["DS_WORKINGUSER"] != null) {
                    dataJsonNode["Asite_System_Data_Read_Only"]["_1_User_Data"]["DS_WORKINGUSER"] = await getSPData_DS_WORKINGUSER(paramData, fixFieldJson);
                  }
                  if (dataJsonNode["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_ISDRAFT"] != null) {
                    dataJsonNode["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT"] = await getSPData_DS_ISDRAFT(paramData);
                  }
                  if (dataJsonNode["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_ISDRAFT_RES_MSG"] != null) {
                    dataJsonNode["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT_RES_MSG"] = await getSPData_DS_ISDRAFT_RES_MSG(paramData);
                  }
                  if (dataJsonNode["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_ISDRAFT_FWD_MSG"] != null) {
                    dataJsonNode["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT_FWD_MSG"] = "NO";
                  }
                  if (dataJsonNode["Asite_System_Data_Read_Only"]?["_3_Project_Data"]?["DS_PROJECTNAME"] != null) {
                    dataJsonNode["Asite_System_Data_Read_Only"]["_3_Project_Data"]["DS_PROJECTNAME"] = await getSPData_DS_PROJECTNAME(paramData, fixFieldJson);
                  }
                  if (dataJsonNode["Asite_System_Data_Read_Only"]?["_4_Form_Type_Data"]?["DS_FORMNAME"] != null) {
                    dataJsonNode["Asite_System_Data_Read_Only"]["_4_Form_Type_Data"]["DS_FORMNAME"] = await getSPData_DS_FORMNAME(paramData, fixFieldJson);
                  }
                  if (dataJsonNode["Asite_System_Data_Read_Only"]?["_4_Form_Type_Data"]?["DS_FORMGROUPCODE"] != null) {
                    dataJsonNode["Asite_System_Data_Read_Only"]["_4_Form_Type_Data"]["DS_FORMGROUPCODE"] = await getSPData_DS_FORMGROUPCODE(paramData, fixFieldJson);
                  }
                }
              } catch (e) {
                Log.d("FormLocalDataSource::getHTML5ChangeSPDataInJsonData exception=$e");
              }
            }
            break;
          case EHtmlRequestType.respond:
          case EHtmlRequestType.reply:
          case EHtmlRequestType.replyAll:
            try {
              if (dataJsonNode.containsKey("myFields") && dataJsonNode["myFields"].containsKey("Asite_System_Data_Read_Only")) {
                try {
                  if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_1_User_Data"]?["DS_WORKINGUSER"] != null) {
                    dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_1_User_Data"]["DS_WORKINGUSER"] = await getSPData_DS_WORKINGUSER(paramData, fixFieldJson);
                  }
                } catch (_) {}
                try {
                  String? strStatusData = dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["Status_Data"]?["DS_ALL_FORMSTATUS"];
                  if (strStatusData != null && strStatusData.isNotEmpty) {
                    var formStatusDataList = strStatusData.split("#");
                    if (formStatusDataList.length >= 2) {
                      String strStatusName = formStatusDataList[1].trim();
                      dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["Status_Data"]["DS_FORMSTATUS"] = strStatusName;
                    }
                  }
                } catch (_) {}
              }
            } catch (_) {}
            break;
          case EHtmlRequestType.editDraft:
          case EHtmlRequestType.editAndDistribute:
            try {
              if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"] != null) {
                dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_FORMID"] = await getSPData_DS_FORMID(paramData);
              }
            } catch (e) {
              Log.d("FormLocalDataSource::getHTML5ChangeSPDataInJsonData exception=$e");
            }
            break;
          case EHtmlRequestType.editOri:
            try {
              if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"] != null) {
                dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_FORMID"] = await getSPData_DS_FORMID(paramData);
              }
            } catch (e) {
              Log.d("FormLocalDataSource::getHTML5ChangeSPDataInJsonData exception=$e");
            }
            break;
          case EHtmlRequestType.viewForm:
            {
              try {
                if (dataJsonNode.containsKey("myFields") && dataJsonNode["myFields"].containsKey("Asite_System_Data_Read_Only") && dataJsonNode["myFields"]["Asite_System_Data_Read_Only"].containsKey("_5_Form_Data")) {
                  if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_DATEOFISSUE"] != null) {
                    dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_DATEOFISSUE"] = await getSPData_DS_DATEOFISSUE(paramData);
                  }
                  if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_ISDRAFT"] != null) {
                    dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT"] = await getSPData_DS_ISDRAFT(paramData);
                  }
                  if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_ISDRAFT_RES_MSG"] != null) {
                    dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT_RES_MSG"] = await getSPData_DS_ISDRAFT_RES_MSG(paramData);
                  }
                  if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_ORIGINATOR"] != null) {
                    dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ORIGINATOR"] = await getSPData_DS_ORIGINATOR(paramData);
                  }
                  if (dataJsonNode["myFields"]?["Asite_System_Data_Read_Only"]?["_5_Form_Data"]?["DS_FORMID"] != null) {
                    dataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_FORMID"] = await getSPData_DS_FORMID(paramData);
                  }
                }
              } catch (e) {
                Log.d("FormLocalDataSource::getHTML5ChangeSPDataInJsonData exception=$e");
              }
            }
            break;
        }
        dataJson = jsonEncode(dataJsonNode);
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getHTML5ChangeSPDataInJsonData exception=$e");
      }
    }
    return dataJson;
  }

  dynamic getSPValueListNode({dynamic items = const []}) {
    return {
      "Items": {"Item": items}
    };
  }

  Future<String> getSPData_DS_WORKINGUSER(Map<String, dynamic> paramData, String fixFieldDataJson) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
          value = getSPValueFromFormTypeFixFieldDataJson(fixFieldDataJson, "DS_WORKINGUSER");
          if (value.isEmpty) {
            User? user = await StorePreference.getUserData();
            if (user != null) {
              value = "${user.usersessionprofile?.firstName} ${user.usersessionprofile?.lastName}, ${user.usersessionprofile?.tpdOrgName}";
            }
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_WORKINGUSER exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_WORKINGUSER_ID(Map<String, dynamic> paramData, String fixFieldDataJson) async {
    List<dynamic> items = [];
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
          value = getSPValueFromFormTypeFixFieldDataJson(fixFieldDataJson, "DS_WORKINGUSER_ID");
          if (value.isEmpty) {
            User? user = await StorePreference.getUserData();
            if (user != null && user.usersessionprofile != null) {
              String name = "${user.usersessionprofile?.firstName} ${user.usersessionprofile?.lastName}, ${user.usersessionprofile?.tpdOrgName}";
              String nameValue = "${user.usersessionprofile?.userID?.plainValue()}|$name#$name";
              items = [
                {"value": nameValue, "Name": name}
              ];
            }
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_WORKINGUSER_ID exception=$e");
      }
    }
    if (value.isEmpty) {
      value = jsonEncode(getSPValueListNode(items: items));
    }
    return value;
  }

  Future<String> getSPData_DS_PROJECTNAME(Map<String, dynamic> paramData, String fixFieldDataJson) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
          value = getSPValueFromFormTypeFixFieldDataJson(fixFieldDataJson, "DS_PROJECTNAME");
          if (value.isEmpty) {
            String query = "SELECT ${ProjectDao.projectNameField} FROM ${ProjectDao.tableName}\n"
                "WHERE ${ProjectDao.projectIdField}=$projectId";
            var result = databaseManager.executeSelectFromTable(ProjectDao.tableName, query);
            if (result.isNotEmpty) {
              value = (result.first)[ProjectDao.projectNameField].toString();
            }
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_PROJECTNAME exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_FORMNAME(Map<String, dynamic> paramData, String fixFieldDataJson) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
          value = getSPValueFromFormTypeFixFieldDataJson(fixFieldDataJson, "DS_FORMNAME");
          if (value.isEmpty) {
            String query = "SELECT ${FormTypeDao.formTypeNameField} FROM ${FormTypeDao.tableName}\n"
                "WHERE ${FormTypeDao.projectIdField}=$projectId AND ${FormTypeDao.formTypeIdField}=$formTypeId";
            var result = databaseManager.executeSelectFromTable(FormTypeDao.tableName, query);
            if (result.isNotEmpty) {
              value = (result.first)[FormTypeDao.formTypeNameField].toString();
            }
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_FORMNAME exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_FORMGROUPCODE(Map<String, dynamic> paramData, String fixFieldDataJson) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
          value = getSPValueFromFormTypeFixFieldDataJson(fixFieldDataJson, "DS_FORMGROUPCODE");
          if (value.isEmpty) {
            String query = "SELECT ${FormTypeDao.formTypeGroupCodeField} FROM ${FormTypeDao.tableName}\n"
                "WHERE ${FormTypeDao.projectIdField}=$projectId AND ${FormTypeDao.formTypeIdField}=$formTypeId";
            var result = databaseManager.executeSelectFromTable(FormTypeDao.tableName, query);
            if (result.isNotEmpty) {
              value = (result.first)[FormTypeDao.formTypeGroupCodeField].toString();
            }
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_FORMGROUPCODE exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_ORI_FORMTITLE(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormDao.formTitleField} FROM ${FormDao.tableName}\n"
              "WHERE ${FormDao.projectIdField}=$projectId AND ${FormDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormDao.tableName, query);
          if (result.isNotEmpty) {
            value = (result.first)[FormDao.formTitleField].toString();
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_ORI_FORMTITLE exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_ORI_USERREF(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormDao.userRefCodeField} FROM ${FormDao.tableName}\n"
              "WHERE ${FormDao.projectIdField}=$projectId AND ${FormDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormDao.tableName, query);
          if (result.isNotEmpty) {
            value = (result.first)[FormDao.userRefCodeField].toString();
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_ORI_USERREF exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_FORMID(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT CASE WHEN INSTR(frmTbl.${FormDao.codeField},'(')>0 THEN SUBSTR(frmTbl.${FormDao.codeField},0,INSTR(frmTbl.${FormDao.codeField},'(')) WHEN LOWER(frmTbl.${FormDao.codeField})='draft' OR frmTbl.${FormDao.isDraftField}=1 OR (frmTbl.${FormDao.codeField}='' AND frmTbl.${FormDao.isOfflineCreatedField}=1) THEN frmTpView.${FormTypeDao.formTypeGroupCodeField} || '000' ELSE frmTbl.${FormDao.codeField} END AS DS_FORMID FROM ${FormDao.tableName} frmTbl\n"
              "INNER JOIN ${FormTypeDao.tableName} frmTpView ON frmTpView.${FormTypeDao.projectIdField}=frmTbl.${FormDao.projectIdField} AND frmTpView.${FormTypeDao.formTypeIdField}=frmTbl.${FormDao.formTypeIdField}\n"
              "WHERE frmTbl.${FormDao.projectIdField}=$projectId AND frmTbl.${FormDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormDao.tableName, query);
          if (result.isNotEmpty) {
            value = (result.first)["DS_FORMID"].toString();
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_DS_FORMID exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_ORIGINATOR(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormDao.originatorDisplayNameField} FROM ${FormDao.tableName}\n"
              "WHERE ${FormDao.projectIdField}=$projectId AND ${FormDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormDao.tableName, query);
          if (result.isNotEmpty) {
            value = (result.first)[FormDao.originatorDisplayNameField].toString();
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_DS_ORIGINATOR exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_DATEOFISSUE(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormDao.formCreationDateInMSField} FROM ${FormDao.tableName}\n"
              "WHERE ${FormDao.projectIdField}=$projectId AND ${FormDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormDao.tableName, query);
          if (result.isNotEmpty) {
            value = (result.first)[FormDao.formCreationDateInMSField].toString();
            value = Utility.getDateTimeFromTimeStamp(value);
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_DS_DATEOFISSUE exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_CLOSE_DUE_DATE(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      String msgId = paramData["msgId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty && msgId.isNotEmpty) {
          String query = "SELECT ${FormMessageDao.jsonDataField} FROM ${FormMessageDao.tableName}\n"
              "WHERE ${FormMessageDao.projectIdField}=$projectId AND ${FormMessageDao.formIdField}=$formId\n"
              "AND ${FormMessageDao.msgIdField}=$msgId";
          var result = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
          if (result.isNotEmpty) {
            value = (result.first)[FormMessageDao.jsonDataField].toString();
            value = jsonDecode(value)["myFields"]?["DS_CLOSE_DUE_DATE"] ?? "";
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_DS_CLOSE_DUE_DATE exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_ISDRAFT(Map<String, dynamic> paramData) async {
    String value = "NO";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormMessageDao.msgStatusIdField} FROM ${FormMessageDao.tableName}\n"
              "WHERE ${FormMessageDao.projectIdField}=$projectId AND ${FormMessageDao.formIdField}=$formId\n"
              "AND ${FormMessageDao.msgTypeIdField}=${EFormMessageType.ori.value} AND (${FormMessageDao.msgStatusIdField}=19 OR ${FormMessageDao.offlineRequestDataField}<>'')"; //19 for draft
          var result = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
          if (result.isNotEmpty) {
            value = "YES";
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_DS_ISDRAFT exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_ISDRAFT_RES_MSG(Map<String, dynamic> paramData) async {
    String value = "NO";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId") && paramData.containsKey("msgId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      String msgId = paramData["msgId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty && msgId.isNotEmpty) {
          String query = "SELECT ${FormMessageDao.msgStatusIdField} FROM ${FormMessageDao.tableName}\n"
              "WHERE ${FormMessageDao.projectIdField}=$projectId AND ${FormMessageDao.formIdField}=$formId AND ${FormMessageDao.msgIdField}=$msgId\n"
              "AND ${FormMessageDao.msgTypeIdField}=${EFormMessageType.res.value} AND (${FormMessageDao.msgStatusIdField}=19 OR ${FormMessageDao.offlineRequestDataField}<>'')"; //19 for draft
          var result = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
          if (result.isNotEmpty) {
            value = "YES";
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_DS_ISDRAFT_RES_MSG exception=$e");
      }
    }
    return value;
  }

  Future<String> getSPData_DS_GET_MSG_DISTRIBUTION_LIST(Map<String, dynamic> paramData) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId") && paramData.containsKey("formId") && paramData.containsKey("msgId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      String msgId = paramData["msgId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty && msgId.isNotEmpty) {
          String query = "SELECT frmMsgTbl.${FormMessageDao.projectIdField},frmMsgTbl.${FormMessageDao.formIdField},frmMsgTbl.${FormMessageDao.msgIdField},frmTpCTE.${FormTypeDao.appBuilderIdField} || CASE LENGTH(CAST(frmTbl.${FormDao.formNumberField} AS TEXT)) WHEN 0 THEN '000' WHEN 1 THEN '00' WHEN 2 THEN '0' ELSE '' END\n"
              " || CAST(frmTbl.${FormDao.formNumberField} AS TEXT) AS AppBuilderIdCode,frmMsgTbl.${FormMessageDao.sentActionsField} FROM ${FormMessageDao.tableName} frmMsgTbl\n"
              "INNER JOIN ${FormTypeDao.tableName} frmTpCTE ON frmTpCTE.${FormTypeDao.projectIdField}=frmMsgTbl.${FormMessageDao.projectIdField} AND frmTpCTE.${FormTypeDao.formTypeIdField}=frmMsgTbl.${FormMessageDao.formTypeIdField}\n"
              "INNER JOIN ${FormDao.tableName} frmTbl ON frmTbl.${FormDao.projectIdField}=frmMsgTbl.${FormMessageDao.projectIdField} AND frmTbl.${FormDao.formIdField}=frmMsgTbl.${FormMessageDao.formIdField}\n"
              "WHERE frmMsgTbl.${FormMessageDao.projectIdField}=$projectId AND frmMsgTbl.${FormMessageDao.formIdField}=$formId AND frmMsgTbl.${FormMessageDao.msgIdField}=$msgId";
          var result = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
          if (result.isNotEmpty) {
            final dataMap = result.first;
            if (dataMap[FormMessageDao.sentActionsField].toString().isNotEmpty) {
              final actionList = jsonDecode(dataMap[FormMessageDao.sentActionsField].toString()) as List;
              for (var element in actionList) {
                String value5 = "InCompleted", value6 = "0", value7 = "0", value8 = "", value9 = "", value10 = "", value11 = "", value12 = "";
                try {
                  if (element["actionDelegated"] as bool) {
                    value5 = "Delegated";
                  } else if (element["actionCleared"] as bool) {
                    value5 = "Cleared";
                  } else if (element["actionCompleted"] as bool) {
                    value5 = "Completed";
                  }
                } on Exception {}
                try {
                  value6 = Utility.getDateTimeFromTimeStamp(element["dueDateInMS"].toString(), dateFormat: "dd/MM/yyyy");
                } on Exception {}
                try {
                  value7 = Utility.getDateTimeFromTimeStamp(element["actionCompleteDateInMS"].toString(), dateFormat: "dd/MM/yyyy");
                } on Exception {}
                value8 = (element["recipientId"] ?? element["userID"] ?? "").toString();
                if (element["recipientName"] != null) {
                  var listdata = element["recipientName"].toString().split(",");
                  if (listdata.isNotEmpty) {
                    value9 = listdata[0];
                    if (listdata.length > 1) {
                      value12 = listdata[1];
                    }
                  }
                } else {
                  value9 = "${element["fname"].toString()} ${element["lname"].toString()}";
                  value12 = element["userOrgName"].toString();
                }
                value10 = (element["distributorUserId"] ?? (await StorePreference.getUserId())?.plainValue() ?? "").toString();
                if (element["assignedBy"] != null) {
                  var listdata = element["assignedBy"].toString().split(",");
                  if (listdata.isNotEmpty) {
                    value11 = listdata[0];
                  }
                } else {
                  value11 = ((await StorePreference.getUserData())?.usersessionprofile?.tpdUserName ?? "").toString();
                }
                var item = {
                  "Value1": dataMap[FormMessageDao.projectIdField].toString(),
                  "Value2": dataMap["AppBuilderIdCode"].toString(),
                  "Value3": dataMap[FormMessageDao.msgIdField].toString(),
                  "Value4": element["actionName"].toString(),
                  "Value5": value5,
                  "Value6": value6,
                  "Value7": value7,
                  "Value8": value8,
                  "Value9": value9,
                  "Value10": value10,
                  "Value11": value11,
                  "Value12": value12,
                  "Name": "DS_GET_MSG_DISTRIBUTION_LIST",
                };
                items.add(item);
              }
            }
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_GET_MSG_DISTRIBUTION_LIST exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_DS_DOC_ATTACHMENTS_ALL(Map<String, dynamic> paramData) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormMessageAttachAndAssocDao.projectIdField},${FormMessageAttachAndAssocDao.attachAssocDetailJsonField} FROM ${FormMessageAttachAndAssocDao.tableName}\n"
              "WHERE ${FormMessageAttachAndAssocDao.attachmentTypeField}=${EAttachmentAndAssociationType.attachments.value} AND ${FormMessageAttachAndAssocDao.projectIdField}=$projectId AND ${FormMessageAttachAndAssocDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, query);
          for (var element in result) {
            var attachNode = jsonDecode(element[FormMessageAttachAndAssocDao.attachAssocDetailJsonField].toString());
            var item = {"Value1": attachNode["parentMsgCode"].toString(), "Value2": attachNode["fileName"].toString(), "Value3": attachNode["attachedByName"].toString(), "Value4": attachNode["attachedDate"].toString(), "Value5": "1", "Value6": attachNode["revisionId"].toString(), "Value7": attachNode["projectId"].toString(), "Value8": attachNode["projectName"].toString(), "Name": "DS_DOC_ATTACHMENTS_ALL", "OfflineAttachmentPath": await AppPathHelper().getAttachmentFilePath(projectId: projectId, revisionId: attachNode["revisionId"].toString(), fileExtention: Utility.getFileExtension(attachNode["fileName"].toString()))};
            items.add(item);
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_DOC_ATTACHMENTS_ALL exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_DS_DOC_ASSOCIATIONS_ALL(Map<String, dynamic> paramData) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT frmMsgTbl.${FormMessageDao.msgTypeCodeField},frmMsgAttacTbl.${FormMessageAttachAndAssocDao.attachAssocDetailJsonField} FROM ${FormMessageAttachAndAssocDao.tableName} frmMsgAttacTbl\n"
              "INNER JOIN ${FormMessageDao.tableName} frmMsgTbl ON frmMsgTbl.${FormMessageDao.projectIdField}=frmMsgAttacTbl.${FormMessageAttachAndAssocDao.projectIdField}\n"
              "AND frmMsgTbl.${FormMessageDao.formIdField}=frmMsgAttacTbl.${FormMessageAttachAndAssocDao.formIdField} AND frmMsgTbl.${FormMessageDao.msgIdField}=frmMsgAttacTbl.${FormMessageAttachAndAssocDao.msgIdField}\n"
              "WHERE frmMsgAttacTbl.${FormMessageAttachAndAssocDao.attachmentTypeField}=${EAttachmentAndAssociationType.files.value} AND frmMsgAttacTbl.${FormMessageAttachAndAssocDao.projectIdField}=$projectId AND frmMsgAttacTbl.${FormMessageAttachAndAssocDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, query);
          for (var element in result) {
            var attachNode = jsonDecode(element[FormMessageAttachAndAssocDao.attachAssocDetailJsonField].toString());
            var item = {
              "Value1": element[FormMessageDao.msgTypeCodeField].toString(),
              "Value2": attachNode["docRef"].toString(),
              "Value3": attachNode["title"].toString(),
              "Value4": attachNode["revisionNum"].toString(),
              "Value5": attachNode["issueNo"].toString(),
              "Value6": attachNode["poiId"].toString(),
              "Value7": attachNode["purposeOfIssue"].toString(),
              "Value8": attachNode["statusId"].toString(),
              "Value9": attachNode["status"].toString(),
              "Value10": attachNode["publisherUserId"].toString(),
              "Value11": attachNode["publisherName"] ?? "".toString(),
              "Value12": attachNode["publisherOrgName"] ?? "".toString(),
              "Value13": attachNode["publishDate"].toString(),
              "Name": attachNode["uploadFileName"].toString(),
            };
            items.add(item);
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_DOC_ASSOCIATIONS_ALL exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_getAllLocationByProject_PF(Map<String, dynamic> paramData, String spName) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty) {
          String query = "SELECT prjTbl.${ProjectDao.projectNameField}, locTbl.* FROM ${LocationDao.tableName} locTbl\n"
              "INNER JOIN ${ProjectDao.tableName} prjTbl ON prjTbl.${ProjectDao.projectIdField}=locTbl.${LocationDao.projectIdField}\n"
              "WHERE locTbl.${LocationDao.isActiveField}=1 AND locTbl.${LocationDao.isMarkOfflineField}=1 AND locTbl.${LocationDao.projectIdField}=$projectId\n"
              "ORDER BY locTbl.${LocationDao.locationPathField} COLLATE NOCASE";
          var result = databaseManager.executeSelectFromTable(LocationDao.tableName, query);
          for (var element in result) {
            String locationPath = element["LocationPath"].toString();
            String locationTitle = element["LocationTitle"].toString();
            String locationId = element["LocationId"].toString();
            if (locationPath.startsWith("${element["ProjectName"].toString()}\\")) {
              locationPath = locationPath.replaceFirst("${element["ProjectName"].toString()}\\", "");
            }
            locationPath = locationPath.replaceAll("\\", ">");
            var item = {
              "Value1": locationPath,
              "Value2": locationTitle,
              "Value3": locationId,
              "Value4": element["ParentLocationId"].toString(),
              "Value5": element["RevisionId"].toString(),
              "Value6": element["AnnotationId"].toString(),
              "Value7": element["LocationCoordinate"].toString(),
              "Value8": element["FolderId"].toString(),
              "Value9": "$locationId|$locationTitle|$locationPath",
              "Value10": "$locationTitle|$locationPath",
              "Value11": element["PageNumber"].toString(),
              "Name": spName,
            };
            items.add(item);
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_getAllLocationByProject_PF exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_DS_getAllLocationByProject_PF(Map<String, dynamic> paramData) async {
    return await getSPData_getAllLocationByProject_PF(paramData, "DS_getAllLocationByProject_PF");
  }

  Future<String> getSPData_DS_ASI_SITE_getAllLocationByProject_PF(Map<String, dynamic> paramData) async {
    return await getSPData_getAllLocationByProject_PF(paramData, "DS_ASI_SITE_getAllLocationByProject_PF");
  }

  Future<String> getSPData_DS_SNG_AUS_GETALLLOCATIONBYPROJECT_PF(Map<String, dynamic> paramData) async {
    return await getSPData_getAllLocationByProject_PF(paramData, "DS_SNG_AUS_GETALLLOCATIONBYPROJECT_PF");
  }

  Future<String> getSPData_GET_RECENT_DEFECTS(Map<String, dynamic> paramData, String spName) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      String recordSize = paramData["numberOfRecentDefect"]?.toString() ?? "";
      String userId = (await StorePreference.getUserId())?.plainValue() ?? "";
      try {
        if (recordSize.isEmpty) {
          recordSize = "5";
        }
        if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
          String query = "SELECT frmTbl.${FormDao.projectIdField},frmTbl.${FormDao.formIdField},frmTbl.${FormDao.codeField},frmTpTbl.${FormTypeDao.formTypeGroupCodeField},frmTbl.${FormDao.formTitleField},frmTbl.${FormDao.observationDefectTypeField},frmTbl.${FormDao.locationIdField},locTbl.${LocationDao.locationTitleField},locTbl.${LocationDao.locationPathField},frmMsgTbl.${FormMessageDao.jsonDataField} FROM ${FormDao.tableName} frmTbl\n"
              "INNER JOIN ${FormTypeDao.tableName} frmTpTbl ON frmTpTbl.${FormTypeDao.projectIdField}=frmTbl.${FormDao.projectIdField} AND frmTpTbl.${FormTypeDao.formTypeIdField}=frmTbl.${FormDao.formTypeIdField}\n"
              "INNER JOIN ${LocationDao.tableName} locTbl ON locTbl.${LocationDao.projectIdField}=frmTbl.${FormDao.projectIdField} AND locTbl.${LocationDao.locationIdField}=frmTbl.${FormDao.locationIdField}\n"
              "INNER JOIN ${FormMessageDao.tableName} frmMsgTbl ON frmMsgTbl.${FormMessageDao.projectIdField}=frmTbl.${FormDao.projectIdField} AND frmMsgTbl.${FormMessageDao.formIdField}=frmTbl.${FormDao.formIdField} AND frmMsgTbl.${FormMessageDao.msgTypeIdField}=${EFormMessageType.ori.value} AND frmMsgTbl.${FormMessageDao.isDraftField}=0\n"
              "WHERE frmTbl.${FormDao.projectIdField}=$projectId AND frmTbl.${FormDao.originatorIdField}=$userId AND frmTpTbl.${FormTypeDao.instanceGroupIdField}=\n"
              "(SELECT ${FormTypeDao.instanceGroupIdField} FROM ${FormTypeDao.tableName} WHERE ${FormTypeDao.projectIdField}=$projectId AND ${FormTypeDao.formTypeIdField}=$formTypeId)\n"
              "ORDER BY frmTbl.${FormDao.formCreationDateInMSField} DESC\n"
              "LIMIT $recordSize OFFSET 0";
          var result = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, query);
          for (var element in result) {
            String value1 = element["Code"].toString();
            if (value1 == element["FormTypeGroupCode"].toString()) {
              sleep(const Duration(milliseconds: 5));
              value1 = "$value1${DateTime.now().millisecondsSinceEpoch.toString()}"; // append timestamp
            }
            var item = {
              "Value1": value1,
              "Value2": element["FormTitle"].toString(),
              "Value3": element["ObservationDefectType"].toString(),
              "Value4": "${element["LocationId"].toString()}|${element["LocationTitle"].toString()}|${element["LocationPath"].toString()}",
              "Value5": element["LocationPath"].toString(),
            };
            try {
              var ORI_MSG_Custom_FieldsNode = (jsonDecode(element["JsonData"].toString()))["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"];
              String strValue6 = ORI_MSG_Custom_FieldsNode["ExpectedFinishDays"].toString();
              String strValue7 = (ORI_MSG_Custom_FieldsNode["DefectDescription"] ?? ORI_MSG_Custom_FieldsNode["Defect_Description"] ?? "").toString();
              if (strValue7.isEmpty) {
                strValue7 = (ORI_MSG_Custom_FieldsNode["Defect_Description"] ?? ORI_MSG_Custom_FieldsNode["Defect_Description"] ?? "").toString();
              }
              String strValue8 = "", strValue9 = "";
              String assignedToUser = (ORI_MSG_Custom_FieldsNode["AssignedToUsersGroup"]["AssignedToUsers"]["AssignedToUser"] ?? "").toString();
              var dataList = assignedToUser.split("#");
              if (dataList.length > 1) {
                strValue8 = dataList[0].trim();
                strValue9 = dataList[1].trim();
              }
              item["Value6"] = strValue6;
              item["Value7"] = strValue7;
              item["Value8"] = strValue8;
              item["Value9"] = strValue9;
              //Below changes for ALDAR issue APPSBLDBTR-10670
              if ((element["ObservationDefectType"] ?? "").toString() == "") {
                item["Value3"] = (ORI_MSG_Custom_FieldsNode["DefectTyoe"] ?? "").toString();
              }
              //change end for ALDAR issue APPSBLDBTR-10670
              if (spName == "DS_ASI_SITE_GET_RECENT_DEFECTS") {
                if (ORI_MSG_Custom_FieldsNode["TaskType"] != null) {
                  item["Value10"] = (ORI_MSG_Custom_FieldsNode["TaskType"] ?? "").toString();
                  item["Value11"] = (ORI_MSG_Custom_FieldsNode["configAttrName"] ?? "").toString();
                  item["Value12"] = (ORI_MSG_Custom_FieldsNode["configAttrValue"] ?? "").toString();
                }
              } else if (spName == "DS_ALDR_SITE_GET_RECENT_DEFECTS") {
                if (ORI_MSG_Custom_FieldsNode["TaskType"] != null) {
                  item["Value10"] = (ORI_MSG_Custom_FieldsNode["TaskType"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["IssueType"] != null) {
                  item["Value11"] = (ORI_MSG_Custom_FieldsNode["IssueType"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["IssueDescription"] != null) {
                  item["Value12"] = (ORI_MSG_Custom_FieldsNode["IssueDescription"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["SubDefectType"] != null) {
                  item["Value13"] = (ORI_MSG_Custom_FieldsNode["SubDefectType"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["Lead"] != null) {
                  item["Value14"] = (ORI_MSG_Custom_FieldsNode["Lead"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["Maintenance"] != null) {
                  item["Value15"] = (ORI_MSG_Custom_FieldsNode["Maintenance"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["severity"] != null) {
                  item["Value16"] = (ORI_MSG_Custom_FieldsNode["severity"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["PWcurrRating"] != null) {
                  item["Value17"] = (ORI_MSG_Custom_FieldsNode["PWcurrRating"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["MIcurrRating"] != null) {
                  item["Value18"] = (ORI_MSG_Custom_FieldsNode["MIcurrRating"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["DIcurrRating"] != null) {
                  item["Value19"] = (ORI_MSG_Custom_FieldsNode["DIcurrRating"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["PWcurrRating"] != null) {
                  item["Value20"] = (ORI_MSG_Custom_FieldsNode["PWcurrRating"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["MIcurrRating"] != null) {
                  item["Value21"] = (ORI_MSG_Custom_FieldsNode["MIcurrRating"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["DIcurrRating"] != null) {
                  item["Value22"] = (ORI_MSG_Custom_FieldsNode["DIcurrRating"] ?? "").toString();
                }
              } else if (spName == "DS_SNG_AUS_GET_RECENT_DEFECTS") {
                if (ORI_MSG_Custom_FieldsNode["TaskType"] != null) {
                  item["Value10"] = (ORI_MSG_Custom_FieldsNode["TaskType"] ?? "").toString();
                }
                if (ORI_MSG_Custom_FieldsNode["AssignedToRole"] != null) {
                  item["Value11"] = (ORI_MSG_Custom_FieldsNode["AssignedToRole"] ?? "").toString();
                }
              }
            } on Exception {}
            item["Name"] = spName;
            items.add(item);
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_GET_RECENT_DEFECTS exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_DS_SNG_GET_RECENT_DEFECTS(Map<String, dynamic> paramData) async {
    return await getSPData_GET_RECENT_DEFECTS(paramData, "DS_SNG_GET_RECENT_DEFECTS");
  }

  Future<String> getSPData_DS_ASI_SITE_GET_RECENT_DEFECTS(Map<String, dynamic> paramData) async {
    return await getSPData_GET_RECENT_DEFECTS(paramData, "DS_ASI_SITE_GET_RECENT_DEFECTS");
  }

  Future<String> getSPData_DS_SNG_AUS_GET_RECENT_DEFECTS(Map<String, dynamic> paramData) async {
    return await getSPData_GET_RECENT_DEFECTS(paramData, "DS_SNG_AUS_GET_RECENT_DEFECTS");
  }

  Future<String> getSPData_DS_ALDR_SITE_GET_RECENT_DEFECTS(Map<String, dynamic> paramData) async {
    return await getSPData_GET_RECENT_DEFECTS(paramData, "DS_ALDR_SITE_GET_RECENT_DEFECTS");
  }

  Future<String> getSPData_DS_SNG_AUS_DS_ALL_STATUS_WithCloseout(Map<String, dynamic> paramData) async {
    return await getSPData_DS_ALL_STATUS_WithCloseout(paramData, "DS_ALL_STATUS_WithCloseout");
  }

  Future<String> getSPData_DS_ALL_STATUS_WithCloseout(Map<String, dynamic> paramData, String spName) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId") && paramData.containsKey("formTypeId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formTypeId = paramData["formTypeId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
          String statusListPath = await AppPathHelper().getFormTypeStatusListFilePath(projectId: projectId, formTypeId: formTypeId);
          if (statusListPath.isNotEmpty) {
            String fileData = readFromFile(statusListPath);
            if (fileData.isNotEmpty) {
              var jsonData = (jsonDecode(fileData))["statusList"];
              for (var element in jsonData) {
                var item = {
                  "Value1": element["statusName"].toString(),
                  "Value2": "${element["statusID"].toString()}|${element["statusName"].toString()}|${(element["isDeactive"] ?? false) ? "YES" : "NO"}",
                  "Name": spName,
                };
                items.add(item);
              }
            }
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_ALL_STATUS_WithCloseout exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_DS_INCOMPLETE_ACTIONS(Map<String, dynamic> paramData) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      String userId = (await StorePreference.getUserId())?.plainValue() ?? "";
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT * FROM ${FormMessageActionDao.tableName}\n"
              "WHERE ${FormMessageActionDao.projectIdField}=$projectId AND ${FormMessageActionDao.formIdField}=$formId\n"
              "AND ${FormMessageActionDao.actionStatusField}=0 AND ${FormMessageActionDao.recipientUserIdField}=$userId";
          var result = databaseManager.executeSelectFromTable(FormMessageActionDao.tableName, query);
          for (var element in result) {
            var item = {
              "Value": "|${element["RecipientUserId"].toString()}| # ${element[FormMessageActionDao.actionNameField].toString()}",
              "Name": element[FormMessageActionDao.actionNameField].toString(),
            };
            items.add(item);
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_INCOMPLETE_ACTIONS exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_DS_Get_All_Responses(Map<String, dynamic> paramData) async {
    List<dynamic> items = [];
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormMessageDao.msgCodeField},${FormMessageDao.originatorDisplayNameField},${FormMessageDao.msgCreatedDateField},${FormMessageDao.jsonDataField},${FormMessageDao.msgCreatedDateInMSField} FROM ${FormMessageDao.tableName}\n"
              "WHERE ${FormMessageDao.msgStatusIdField}<>19 AND ${FormMessageDao.msgTypeIdField}=${EFormMessageType.res.value}\n"
              "AND ${FormMessageDao.projectIdField}=$projectId AND ${FormMessageDao.formIdField}=$formId\n"
              "ORDER BY ${FormMessageDao.msgCreatedDateInMSField} ASC";
          var result = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
          for (var element in result) {
            var item = {
              "Value1": element[FormMessageDao.msgCodeField].toString(),
              "Value2": element[FormMessageDao.originatorDisplayNameField].toString(),
              "Value3": element[FormMessageDao.msgCreatedDateField].toString().split("#").first,
            };
            int iCounter = 4;
            try {
              var tmpDS_Response_PARAM = ParserUtility.getObjectValueFromJson(element[FormMessageDao.jsonDataField].toString(), "DS_Response_PARAM");
              if (tmpDS_Response_PARAM != null && tmpDS_Response_PARAM is String) {
                List<String> valueList = [];
                tmpDS_Response_PARAM.split("#").forEach((key) {
                  if (key.isNotEmpty) {
                    var tmpValue = ParserUtility.getObjectValueFromJson(element[FormMessageDao.jsonDataField].toString(), key);
                    if (tmpValue != null && tmpValue is String && tmpValue.isNotEmpty) {
                      valueList.addAll(tmpValue.split("#"));
                    } else {
                      valueList.add("-");
                    }
                  }
                });
                for (var value in valueList) {
                  if (value.isNotEmpty) {
                    item["Value$iCounter"] = value.trim();
                    iCounter++;
                  }
                }
              }
            } on Exception catch (e) {
              Log.d("FormLocalDataSource::getSPData_DS_Get_All_Responses JsonData parse exception=$e");
            }
            item["Value$iCounter"] = element[FormMessageDao.msgCreatedDateField].toString().replaceAll("#", " ");
            items.add(item);
          }
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getSPData_DS_Get_All_Responses exception=$e");
      }
    }
    return jsonEncode(getSPValueListNode(items: items));
  }

  Future<String> getSPData_DS_FORMSTATUS(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("projectId") && paramData.containsKey("formId")) {
      String projectId = paramData["projectId"].toString().plainValue();
      String formId = paramData["formId"].toString().plainValue();
      try {
        if (projectId.isNotEmpty && formId.isNotEmpty) {
          String query = "SELECT ${FormDao.statusField} FROM ${FormDao.tableName}\n"
              "WHERE ${FormDao.projectIdField}=$projectId AND ${FormDao.formIdField}=$formId";
          var result = databaseManager.executeSelectFromTable(FormDao.tableName, query);
          if (result.isNotEmpty) {
            value = (result.first)[FormDao.statusField].toString();
          }
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getSPData_DS_FORMSTATUS exception=$e");
      }
    }
    return value;
  }

  Future<String> getOfflineFormMessageAttachmentAndAssociationColumnHeadersListJson(Map<String, dynamic> paramData) async {
    String value = "";
    if (paramData.containsKey("ListingType") && paramData["ListingType"] != null) {
      try {
        String listingType = paramData["ListingType"].toString();
        bool isForSiteTask = paramData["isForSiteTask"];

        String path = await AppPathHelper().getColumnHeaderFilePath(listingType: listingType);
        value = readFromFile(path);

        if ((listingType == "71" || listingType == "72" || listingType == "73") && isForSiteTask) {
          // For Attachment Column Header
          return value;
        } else {
          if (value.isNotEmpty) {
            dynamic jsonData = jsonDecode(value);
            if (jsonData is List) {
              for (var element in (jsonData)) {
                element["function"] = "";
                element["funParams"] = "";
              }
            }
            return jsonEncode(jsonData);
          }
          return '';
        }
      } on Exception catch (e) {
        Log.e("FormLocalDataSource::getOfflineFormMessageAttachmentAndAssociationColumnHeadersListJson exception=$e");
      }
    }
    return value;
  }

  Future<String> getOfflineConfigDataJson(Map<String, dynamic> paramData, EHtmlRequestType eReqType) async {
    String strProjectId = paramData["projectId"].toString();
    String strFormTypeId = paramData["formTypeId"].toString();
    String strLocationId = paramData["locationId"]?.toString() ?? "0";
    String strFormId = paramData["formId"]?.toString().plainValue() ?? "";
    // String strObservationId = paramData["observationId"].toString();
    String strMsgId = paramData["msgId"]?.toString() ?? "";
    bool bIsCalibrated = paramData["isCalibrated"] ?? false;
    bool hideBackButton = paramData["hideBackButton"] ?? false;
    String strParentMsgId = paramData.containsKey('parent_msg_id') ? paramData["parent_msg_id"].toString().plainValue() : "";
    String strFormCreationDate = "";
    String strResponseJson = "";
    User? loginUser = await user;
    Map<String, dynamic> uspJsonNode = loginUser!.toJson()["usersessionprofile"];
    try {
      bool bIsFromPlanView = paramData["isFromMapView"] ?? false;

      String strSelectQuery = "SELECT prjTbl.ProjectId,prjTbl.ProjectName,prjTbl.DcId AS DcId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeDetailJson,frmTpTbl.FormTypeName,frmTpTbl.FormTypeGroupCode AS FormGroupCode,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.AppTypeId FROM ${ProjectDao.tableName} prjTbl";
      strSelectQuery = "$strSelectQuery INNER JOIN ${FormTypeDao.tableName} frmTpTbl ON frmTpTbl.ProjectId=prjTbl.ProjectId";
      strSelectQuery = "$strSelectQuery WHERE frmTpTbl.ProjectId=${strProjectId.plainValue()} AND frmTpTbl.FormTypeId=${strFormTypeId.plainValue()}";
      Log.d("FormLocalDataSource getConfigDataJsonForCreateorView strSelectQuery=$strSelectQuery");
      var mapOfConfigList = databaseManager.executeSelectFromTable(ProjectDao.tableName, strSelectQuery);

      Map<String, dynamic> configeDataMap = {};
      if (mapOfConfigList.length == 1) {
        configeDataMap = mapOfConfigList.first;
      }
      dynamic strFormTypeDetailJson = jsonDecode(configeDataMap["FormTypeDetailJson"])["formTypesDetail"];
      if (strFormTypeDetailJson != null) {
        strFormTypeDetailJson = strFormTypeDetailJson["formTypeVO"];
      }

      Map<String, dynamic> configDataJsonNode = {};
      Map<String, dynamic> dcMapSuffixMap = {};
      configDataJsonNode["dcMapSuffix"] = dcMapSuffixMap;
      Map<String, dynamic> caMapSuffixMap = {};
      configDataJsonNode["caMapSuffix"] = caMapSuffixMap;
      configDataJsonNode["appTypeId"] = configeDataMap["AppTypeId"];
      configDataJsonNode["dcRegEx"] = "";
      configDataJsonNode["adoddleWebURL"] = "";
      List<dynamic> usrDCJsonNode = jsonDecode("[{\"id\":1,\"suffix\":\"\"},{\"id\":2,\"suffix\":\"b\"}]");
      configDataJsonNode["USER_DC_JSON"] = usrDCJsonNode;
      List<dynamic> accelerationJsonNode = jsonDecode("[{\"id\":0,\"suffix\":\"\"},{\"id\":1,\"suffix\":\"ak\"},{\"id\":2,\"suffix\":\"ca2\"}]");
      configDataJsonNode["CONTENT_ACCELERATION_JSON"] = accelerationJsonNode;
      configDataJsonNode["dcExtnExistedList"] = "suploadqa2,downloadqa2";
      configDataJsonNode["USER_CDN_TYPE_ID"] = "1";
      configDataJsonNode["USP"] = uspJsonNode;
      configDataJsonNode["retainNoOfShow"] = 10;
      configDataJsonNode["isNewUI"] = true;
      configDataJsonNode["isOfflineMode"] = true;
      configDataJsonNode["applicationId"] = 3;
      configDataJsonNode["staticContentVersion"] = "20838";
      configDataJsonNode["isAndroid"] = true;
      configDataJsonNode["isAndroidPhone"] = true;
      configDataJsonNode["selectedProIdsForApp"] = "";
      configDataJsonNode["ELEARNING_URL"] = "";
      configDataJsonNode["SUBSCRIPTION_PLAN_ID"] = int.tryParse(uspJsonNode["subscriptionPlanId"].toString()) ?? 0; // get Login User Sub Plan id
      configDataJsonNode["pingInterval"] = 600000;
      configDataJsonNode["maxHtmlUploadSize"] = 1536;
      configDataJsonNode["expoContext"] = "";
      configDataJsonNode["isFromDirectAccessURL"] = false;
      configDataJsonNode["MOVE_DOC_MAX_REV_LIMIT"] = 1000;
      configDataJsonNode["maxTab"] = 0;
      configDataJsonNode["formListingType"] = "-1"; //formListingType 11 = All, 4 = Overdue Actions Only, 5 = Incomplete only
      configDataJsonNode["uploadChunkSize"] = 4194304;
      configDataJsonNode["timezoneOffset"] = 0;
      configDataJsonNode["resordsParPage"] = 10;
      configDataJsonNode["baseUrl"] = "";
      configDataJsonNode["LOCAL_DC_ID"] = configeDataMap["DcId"];
      configDataJsonNode["contextpath"] = "/";
      configDataJsonNode["isFromDirectAccess"] = false;
      configDataJsonNode["isFromFileView"] = "false";
      configDataJsonNode["isFromFileViewForDomain"] = "false";
      String strDateFormat = await Utility.getUserDateFormat();
      String strDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      /// Using dd-MM-yyyy for todays date hardcoded for UI datepicker
      configDataJsonNode["todaysDate"] = strDate;
      configDataJsonNode["userLanguage"] = uspJsonNode["languageId"]?.toString() ?? "";
      configDataJsonNode["currUserDateFormat"] = strDateFormat;
      configDataJsonNode["directProjId"] = "-1";
      configDataJsonNode["directFormTypeId"] = "-1";
      configDataJsonNode["brandingId"] = uspJsonNode["tpdOrgName"]?.toString() ?? ""; // company id
      configDataJsonNode["locationId"] = strLocationId;

      configDataJsonNode["projectId"] = strProjectId;
      configDataJsonNode["formTypeId"] = strFormTypeId;
      configDataJsonNode["formExternalAccess"] = 0;
      //std::string offlineAttachmentPath = getAppDataPath() + "/" + Utils::deHashString(strProjectId) + "/Defect/Attachments";
      String offlineAttachmentPath = await AppPathHelper().getAttachmentDirectory(projectId: strProjectId.plainValue());
      configDataJsonNode["offlineAttachmentPath"] = offlineAttachmentPath;
      String offllineBasePath = await AppPathHelper().getUserDataDBFilePath();
      configDataJsonNode["offlineBasePath"] = offllineBasePath;
      if (eReqType == EHtmlRequestType.viewForm) {
        configDataJsonNode["isOfflineView"] = true;
        configDataJsonNode["assocParentProjectId"] = strProjectId;
      } else {
        configDataJsonNode["callFromCreateForm"] = true; // Discard from View Html
      }
      bool bIsSaveDraft = false;
      if (eReqType == EHtmlRequestType.reply || eReqType == EHtmlRequestType.replyAll || eReqType == EHtmlRequestType.respond) {
        if (strFormTypeDetailJson["enableDraftResponses"] == 1) {
          bIsSaveDraft = true;
        }
      } else {
        bIsSaveDraft = true;
      }
      configDataJsonNode["isSaveDraft"] = bIsSaveDraft;
      int iMandatoryDistribution = strFormTypeDetailJson["mandatoryDistribution"];
      configDataJsonNode["distORICreation"] = iMandatoryDistribution;
      configDataJsonNode["distORIOptional"] = 0;
      bool bCanDistribute = false;
      bool useController = strFormTypeDetailJson["use_controller"];
      if (iMandatoryDistribution != 2 && useController == false) {
        //NOT Required
        bCanDistribute = true;
      }
      configDataJsonNode["canDistribute"] = bCanDistribute;
      bool ballowAttachments = strFormTypeDetailJson["allow_attachments"];
      configDataJsonNode["canAttachDocs"] = ballowAttachments;
      if (strFormCreationDate != "" && eReqType == EHtmlRequestType.create) {
        configDataJsonNode["formCreationDate"] = strFormCreationDate;
      }
      if (eReqType == EHtmlRequestType.create) {
        configDataJsonNode["isCalibrated"] = (bIsCalibrated) ? "true" : "false";
      }
      configDataJsonNode["isFromPlanView"] = bIsFromPlanView;
      configDataJsonNode["code"] = configeDataMap["FormGroupCode"];
      configDataJsonNode["AppBuilderFormIDCode"] = configeDataMap["AppBuilderId"];
      configDataJsonNode["FormTypeName"] = configeDataMap["FormTypeName"];
      configDataJsonNode["ProjectName"] = configeDataMap["ProjectName"];

      switch (eReqType) {
        case EHtmlRequestType.reply:
        case EHtmlRequestType.replyAll:
        case EHtmlRequestType.editDraft:
        case EHtmlRequestType.editOri:
        case EHtmlRequestType.editAndDistribute:
        case EHtmlRequestType.create:
          {
            configDataJsonNode["PROJECTID_FORM"] = strProjectId;
            configDataJsonNode["MODELID_FORM"] = "null";
            configDataJsonNode["IFCC_FORM_MESSAGE_NAME"] = "messageName";
            configDataJsonNode["IFCC_FORM_USER_REF"] = "formUserRef";
            configDataJsonNode["IFCC_FORM_HYPERLINK"] = "formHyperlink";
            configDataJsonNode["IFCC_FORM_MESSAGE_TEXT"] = "messageText";
            configDataJsonNode["RESPOND_BY"] = "respondBy";
            configDataJsonNode["ISC_ACTION_FORM_REVIEW_DRAFTS"] = "34";
            bool ballowDocAssociates = strFormTypeDetailJson["allow_doc_associates"];
            configDataJsonNode["canAssociateDocs"] = ballowDocAssociates;
            bool ballowFormAssociations = strFormTypeDetailJson["allow_form_associations"];
            configDataJsonNode["canAssociateForms"] = ballowFormAssociations;
            bool ballowCommentAssociations = strFormTypeDetailJson["allow_comment_associations"];
            configDataJsonNode["canAssociateComments"] = ballowCommentAssociations;
            bool ballowLocationAssociations = strFormTypeDetailJson["allowLocationAssociation"];
            configDataJsonNode["canAssociateLocation"] = ballowLocationAssociations;
            bool bIsLocationAssocManadatory = strFormTypeDetailJson["isLocationAssocMandatory"];
            configDataJsonNode["isLocationAssocMandatory"] = bIsLocationAssocManadatory;
            int strMandatoryDistribution = strFormTypeDetailJson["mandatoryDistribution"];
            configDataJsonNode["isDistMandatory"] = strMandatoryDistribution.toString();
            String strHasOverAllStatus = strFormTypeDetailJson["has_overall_status"].toString();
            configDataJsonNode["hasOverallStatus"] = strHasOverAllStatus;
            configDataJsonNode["MSG_TYPE_ORI"] = "1";
            configDataJsonNode["MSG_TYPE_FWD"] = "3";
            configDataJsonNode["DISTRIBUTION_MANDATORY"] = "1";
            configDataJsonNode["doAutoSaveForm"] = false;
            configDataJsonNode["autoSaveMsgInterval"] = 2;
            configDataJsonNode["AUTO_SAVE_MESSAGE_TEXT"] = "962";
            configDataJsonNode["SUBMIT_MESSAGE_TEXT_DETAILS"] = "924";
            configDataJsonNode["SAVE_DRAFT_TRUE"] = "1";
            configDataJsonNode["SAVE_DRAFT_FALSE"] = "0";
            configDataJsonNode["ACTION_EDIT_FORM_MSG"] = "edit";
            configDataJsonNode["DISCARD_DRAFT_MESSAGE"] = "963";
            configDataJsonNode["FormTypeID"] = strFormTypeId;
            configDataJsonNode["enableButtons"] = false;
            configDataJsonNode["delayTime"] = 60 * 1000;
            configDataJsonNode["FORM_TEMPLATE_TYPE_BASIC"] = "0";
            configDataJsonNode["MSG_TYPE_RES"] = "2";
            configDataJsonNode["FORM_RESPONSE_PATTERN_REPETITIVE"] = "1";
            configDataJsonNode["delayAutoSaveMsg"] = 5000;
            configDataJsonNode["isCustomForm"] = false;
            configDataJsonNode["editORI"] = (eReqType == EHtmlRequestType.editOri || eReqType == EHtmlRequestType.editAndDistribute) ? "true" : "false";
            configDataJsonNode["hashEORIMsgId"] = "0";
            configDataJsonNode["COMM_DCID"] = configeDataMap["DcId"] ?? 0;
            configDataJsonNode["assocRevIds"] = "";
            configDataJsonNode["callingArea"] = "";
            configDataJsonNode["isAutoSaved"] = 0;
            String strformSelectRadiobutton = "${configeDataMap["DcId"]}_${configeDataMap["ProjectId"]}_${configeDataMap["FormTypeId"]}_";
            if (eReqType == EHtmlRequestType.create) {
              strformSelectRadiobutton = strformSelectRadiobutton + configeDataMap["AppBuilderId"];
            }
            configDataJsonNode["formSelectRadiobutton"] = strformSelectRadiobutton;
            configDataJsonNode["flgDeleteOldDraftForImport"] = "true";
            if (eReqType == EHtmlRequestType.reply || eReqType == EHtmlRequestType.replyAll) {
              configDataJsonNode["isForReply"] = true;
            } else {
              configDataJsonNode["isForReply"] = false;
            }
            configDataJsonNode["observationId"] = 0;
            if (eReqType == EHtmlRequestType.create || eReqType == EHtmlRequestType.editOri || eReqType == EHtmlRequestType.editAndDistribute) {
              configDataJsonNode["isForRespondDirect"] = false;
            } else {
              configDataJsonNode["isForRespondDirect"] = true;
            }
            configDataJsonNode["isFromCbim"] = "false";
            configDataJsonNode["isDisplayFormPrintView"] = false;
            configDataJsonNode["isFromCatalogue"] = "";
            List<Map<String, dynamic>> deleteassocCommsObjList = [];
            configDataJsonNode["deleteassocCommsObj"] = deleteassocCommsObjList;
            configDataJsonNode["bim_model_id"] = "null";
            configDataJsonNode["viewName"] = "null";
            configDataJsonNode["viewId"] = "null";
            configDataJsonNode["listName"] = "null";
            configDataJsonNode["listId"] = "null";
            configDataJsonNode["hashprojectId"] = strProjectId;
            configDataJsonNode["modelName"] = "null";
            configDataJsonNode["allowImportFromExcel"] = false;
            configDataJsonNode["allowImportExcelInEditORI"] = false;
            configDataJsonNode["dcId"] = int.tryParse(configeDataMap["DcId"].toString()) ?? 0;
            configDataJsonNode["viewAlwaysDocAssociation"] = true;
            configDataJsonNode["viewAlwaysFormAssociation"] = true;
            configDataJsonNode["buyerCookie"] = "";
            configDataJsonNode["isFromApps"] = true;
            configDataJsonNode["copyAttachAndAssoc"] = false;
            configDataJsonNode["documentName"] = "null";
            configDataJsonNode["revisionId"] = "";
            configDataJsonNode["folderId"] = "";
            configDataJsonNode["fileSize"] = "";
            configDataJsonNode["isFromWhere"] = "null";
            configDataJsonNode["isFullScreenForm"] = false;
            configDataJsonNode["catalogConfig"] = "";
            configDataJsonNode["isEditORI"] = (eReqType == EHtmlRequestType.editOri) ? "true" : "false";
            configDataJsonNode["allowEditingORI"] = "false";
            configDataJsonNode["infojetServerVersion"] = "0";
            if (eReqType == EHtmlRequestType.editOri || eReqType == EHtmlRequestType.editAndDistribute) {
              configDataJsonNode["hasCreateFormPriv"] = false;
            } else {
              configDataJsonNode["hasCreateFormPriv"] = true;
            }
            configDataJsonNode["submitType"] = "2";
            configDataJsonNode["responseBy"] = "";
            configDataJsonNode["createFormsLimit"] = 0;
            configDataJsonNode["integrateExchange"] = false;
            configDataJsonNode["nonCDNUrl"] = "";
            configDataJsonNode["prequalType"] = 1;
            configDataJsonNode["akamaiUploadLimit"] = "2147483648";
          }
          break;
        default:
          {}
          break;
      }

      switch (eReqType) {
        case EHtmlRequestType.reply:
        case EHtmlRequestType.replyAll:
        case EHtmlRequestType.editDraft:
        case EHtmlRequestType.editOri:
        case EHtmlRequestType.editAndDistribute:
        case EHtmlRequestType.create:
          {
            SiteForm? formData;
            if (strProjectId.isNotEmpty && strProjectId != "0" && strFormId.isNotEmpty && strFormId != "0") {
              formData = await getFormVOFromDB(projectId: strProjectId, formId: strFormId);
              if (formData != null) {
                String strControllerUserId = formData.controllerUserId.plainValue();
                if (strControllerUserId.isNotEmpty && strControllerUserId != "0") {
                  configDataJsonNode["selectedControllerId"] = strControllerUserId;
                }
              }
            }
            FormMessageVO? formMsgData;
            if (strMsgId.isNotEmpty && strMsgId != "0") {
              formMsgData = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strMsgId);
            }

            if (strFormTypeDetailJson["use_controller"] == true && (eReqType == EHtmlRequestType.create || (eReqType == EHtmlRequestType.editDraft && formMsgData != null))) {
              bool buse_controller = false;
              if (eReqType == EHtmlRequestType.create) {
                buse_controller = true;
              } else if (formMsgData?.msgTypeId == "1") {
                buse_controller = true;
              }

              if (buse_controller == true) {
                configDataJsonNode["showController"] = true;
                String filePath = await AppPathHelper().getFormTypeDistributionFilePath(projectId: strProjectId, formTypeId: strFormTypeId);
                String distributionListData = readFromFile(filePath);
                try {
                  Map<String, dynamic> cntrlUserParentNode = jsonDecode(distributionListData);
                  Map<String, dynamic> formTypeControllerUsersListNode = cntrlUserParentNode["formTypeControllerUsers"];
                  configDataJsonNode["controllerUserList"] = formTypeControllerUsersListNode;
                } catch (e) {}
              }
            }

            bool bCanResponseBy = false;
            String strXmlData = strFormTypeDetailJson["xmlData"];
            if (strFormTypeDetailJson["has_overall_status"] == true && !strXmlData.contains("DS_CLOSE_DUE_DATE")) {
              if (eReqType == EHtmlRequestType.create) {
                bCanResponseBy = true;
              } else if (eReqType == EHtmlRequestType.editDraft) {
                if (formMsgData != null) {
                  if (formMsgData.msgTypeId == "1") {
                    bCanResponseBy = true;
                    try {
                      configDataJsonNode.remove("responseBy");
                    } catch (e) {}
                    String strresponseRequestBy = formMsgData.responseRequestBy!;
                    if (strresponseRequestBy.contains("#", 0)) {
                      strresponseRequestBy = strresponseRequestBy.split("#")[0];
                    }
                    configDataJsonNode["responseBy"] = strresponseRequestBy;
                  }
                }
              }
            }
            configDataJsonNode["canResponseBy"] = bCanResponseBy;
            if (formData != null) {
              configDataJsonNode["observationId"] = formData.observationId;
              configDataJsonNode["FOLDERID_FORM"] = formData.folderId;
              configDataJsonNode["FORMID_FORM"] = formData.formId;
              configDataJsonNode["hashFormId"] = formData.formId;
              configDataJsonNode["formId"] = formData.formId;
              configDataJsonNode["ATTACHTEMP_FOLDERID"] = formData.folderId;
            } else {
              configDataJsonNode["observationId"] = 0;
              configDataJsonNode["FOLDERID_FORM"] = "";
              configDataJsonNode["FORMID_FORM"] = "";
              configDataJsonNode["hashFormId"] = "";
              configDataJsonNode["ATTACHTEMP_FOLDERID"] = "";
            }
            if (formMsgData != null) {
              configDataJsonNode["isEditFormOffline"] = eReqType == EHtmlRequestType.editOri ? true : (formMsgData.offlineRequestData != "" && !(formMsgData.isDraft ?? false));
              configDataJsonNode["msgTypeId"] = formMsgData.msgTypeId;
              if (formData != null) {
                configDataJsonNode["isDraft"] = formData.isDraft! ? "true" : "false";
              }
              configDataJsonNode["hashMsgId"] = formMsgData.msgId;
              configDataJsonNode["msgId"] = formMsgData.msgId;
              configDataJsonNode["hashedMsgId"] = formMsgData.msgId;
              configDataJsonNode["enableBtnDiscardDraft"] = true;
              if (eReqType != EHtmlRequestType.editAndDistribute) {
                //getAttachment List
                Map<String, dynamic> pAttachAssocNode = await getFieldEditDraftAttachAndAssocList(projectid: formMsgData.projectId!, formId: formData!.formId!, msgId: formMsgData.msgId!);
                if (pAttachAssocNode.isNotEmpty) {
                  configDataJsonNode.addAll(pAttachAssocNode);
                  pAttachAssocNode.clear();
                } else {
                  configDataJsonNode["viewName"] = "null";
                  configDataJsonNode["listName"] = "null";
                }
              }
            } else {
              configDataJsonNode["isEditFormOffline"] = false;
              if (eReqType == EHtmlRequestType.create || eReqType == EHtmlRequestType.editOri) {
                configDataJsonNode["msgTypeId"] = "1";
              } else if (eReqType == EHtmlRequestType.editAndDistribute) {
                configDataJsonNode["msgTypeId"] = "3";
              } else {
                configDataJsonNode["msgTypeId"] = "2";
              }
              configDataJsonNode["isDraft"] = "false";
              configDataJsonNode["hashMsgId"] = "";
              configDataJsonNode["hashedMsgId"] = "";
              configDataJsonNode["enableBtnDiscardDraft"] = false;
              configDataJsonNode["viewName"] = "null";
              configDataJsonNode["listName"] = "null";
            }
            if (eReqType == EHtmlRequestType.reply || eReqType == EHtmlRequestType.replyAll || (eReqType == EHtmlRequestType.editDraft && formMsgData != null)) {
              if (eReqType == EHtmlRequestType.editDraft) {
                String? strDraftSentActions = formMsgData?.draftSentActions;
                if (strDraftSentActions != null) {
                  try {
                    Map<String, dynamic> distSelectedJSONNodeList = jsonDecode(strDraftSentActions);
                    configDataJsonNode["distSelectedJSON"] = distSelectedJSONNodeList;
                  } catch (e) {
                    Log.d("SiteFormListingLocalDataSource getObservationVOFromDB edit distSelectedJSON default::exception");
                  }
                } else {
                  Log.d("SiteFormListingLocalDataSource getObservationVOFromDB exception edit distSelectedJSON strDraftSentActions empty");
                }
              } else {
                String filePath = await AppPathHelper().getFormTypeDistributionFilePath(projectId: strProjectId, formTypeId: strFormTypeId);
                String distributionListData = readFromFile(filePath);
                if (distributionListData.isNotEmpty) {
                  try {
                    formMsgData = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strMsgId);
                    if (formMsgData != null) {
                      Map<String, dynamic> distListNode = jsonDecode(distributionListData);
                      List<Map<String, dynamic>> distSelectedJSONNodeList = [];
                      List<Map<String, dynamic>> userListNode = (distListNode["distData"]["userList"] as List).map((e) => e as Map<String, dynamic>).toList();
                      List<Map<String, dynamic>> actionListNode = (distListNode["distData"]["actionList"] as List).map((e) => e as Map<String, dynamic>).toList();
                      Map<String, dynamic> forInfoActionNode = getActionNodeFromActionList(actionListNode, "7"); // get For Information Action
                      for (var userNodeTmp in userListNode) {
                        if (userNodeTmp["userID"] == formMsgData.msgOriginatorId.plainValue() && (formMsgData.msgOriginatorId != loginUser.usersessionprofile?.userID.plainValue()) && forInfoActionNode != null) {
                          Map<String, dynamic> selectUserNode = {};
                          selectUserNode["actionID"] = forInfoActionNode["actionID"].toString();
                          selectUserNode["userID"] = userNodeTmp["userID"].toString();
                          selectUserNode["actionDueDate"] = "";
                          selectUserNode["userOrgName"] = userNodeTmp["orgName"].toString();
                          selectUserNode["fname"] = userNodeTmp["fname"].toString();
                          selectUserNode["lname"] = userNodeTmp["lname"].toString();
                          selectUserNode["actionName"] = forInfoActionNode["actionName"].toString();
                          selectUserNode["emailId"] = userNodeTmp["emailId"].toString();
                          selectUserNode["userImageName"] = userNodeTmp["userImageName"].toString();
                          selectUserNode["isSendNotification"] = true;
                          selectUserNode["userCannotOverrideNotification"] = false;
                          selectUserNode["user_type"] = userNodeTmp["userTypeId"].toString();
                          selectUserNode["projectId"] = strProjectId;
                          selectUserNode["dueDays"] = 0;
                          selectUserNode["distListId"] = 0;
                          selectUserNode["generateURI"] = true;
                          distSelectedJSONNodeList.add(selectUserNode);
                        }
                      }
                      if (eReqType == EHtmlRequestType.replyAll) {
                        String? strSentActions = formMsgData.sentActions;
                        if (strSentActions != null) {
                          try {
                            List<Map<String, dynamic>> sentActionsListNode = (jsonDecode(strSentActions) as List).map((e) => e as Map<String, dynamic>).toList();
                            for (var sentActionsNodeTmp in sentActionsListNode) {
                              String strRecipientIdTmp = sentActionsNodeTmp["recipientId"].toString();
                              for (var userNodeTmp in userListNode) {
                                if (userNodeTmp["userID"].toString().plainValue() != formMsgData.msgOriginatorId.plainValue()) {
                                  if (userNodeTmp["userID"].toString().plainValue() == strRecipientIdTmp.plainValue() && strRecipientIdTmp.plainValue() != loginUser.usersessionprofile?.userID.plainValue() && forInfoActionNode != null) {
                                    Map<String, dynamic> selectUserNode = {};
                                    selectUserNode["actionID"] = forInfoActionNode["actionID"].toString();
                                    selectUserNode["userID"] = userNodeTmp["userID"].toString();
                                    selectUserNode["actionDueDate"] = "";
                                    selectUserNode["userOrgName"] = userNodeTmp["orgName"].toString();
                                    selectUserNode["fname"] = userNodeTmp["fname"].toString();
                                    selectUserNode["lname"] = userNodeTmp["lname"].toString();
                                    selectUserNode["actionName"] = forInfoActionNode["actionName"].toString();
                                    selectUserNode["emailId"] = userNodeTmp["emailId"].toString();
                                    selectUserNode["userImageName"] = userNodeTmp["userImageName"].toString();
                                    selectUserNode["isSendNotification"] = true;
                                    selectUserNode["userCannotOverrideNotification"] = false;
                                    selectUserNode["user_type"] = userNodeTmp["userTypeId"].toString();
                                    selectUserNode["projectId"] = strProjectId;
                                    selectUserNode["dueDays"] = 0;
                                    selectUserNode["distListId"] = 0;
                                    selectUserNode["generateURI"] = true;
                                    distSelectedJSONNodeList.add(selectUserNode);
                                  }
                                }
                              }
                            }
                          } catch (e, stacktrace) {
                            Log.d("SiteFormListingLocalDataSource getConfigDataJsonForCreateorView distSelectedJSON dstrParentMsgId strSentActions default::exception $e");
                            Log.d("SiteFormListingLocalDataSource getConfigDataJsonForCreateorView distSelectedJSON dstrParentMsgId strSentActions default::exception $stacktrace");
                          }
                        } else {
                          Log.d("SiteFormListingLocalDataSource getConfigDataJsonForCreateorView distSelectedJSON dstrParentMsgId strSentActions empty");
                        }
                      }
                      configDataJsonNode["distSelectedJSON"] = distSelectedJSONNodeList;
                    }
                  } catch (e) {
                    Log.d("SiteFormListingLocalDataSource getObservationVOFromDB distSelectedJSON default::exception");
                  }
                }
              }
            }

            if ((eReqType == EHtmlRequestType.create || eReqType == EHtmlRequestType.editDraft || eReqType == EHtmlRequestType.editOri || eReqType == EHtmlRequestType.editAndDistribute)) {
              //Assoc location changes
              bool isAssocLocationAdded = false;
              String strAnnotationId = "", strCoordinates = "";
              if (eReqType == EHtmlRequestType.create) {
                isAssocLocationAdded = true;
                strAnnotationId = paramData["annotationId"] ?? "";
                strCoordinates = paramData["coordinates"] ?? "";
              } else if (formData != null && formMsgData != null && !formMsgData.msgTypeId.isNullOrEmpty()) {
                EFormMessageType eFormMessageType = EFormMessageType.fromNumber(int.parse(formMsgData.msgTypeId.toString()));
                if (eFormMessageType == EFormMessageType.ori || eFormMessageType == EFormMessageType.fwd) {
                  isAssocLocationAdded = true;
                  strAnnotationId = formData.annotationId!;
                  strCoordinates = formData.observationCoordinates!;
                  strLocationId = formData.locationId?.toString() ?? "0";
                }
              }
              if (isAssocLocationAdded) {
                configDataJsonNode["annotationId"] = strAnnotationId;
                configDataJsonNode["coordinates"] = strCoordinates;

                String selectQuery = "SELECT * FROM ${LocationDao.tableName}";
                selectQuery = "$selectQuery WHERE ProjectId=${strProjectId.plainValue()} AND LocationId=${strLocationId.plainValue()};";

                var mapOfLocationList = databaseManager.executeSelectFromTable(LocationDao.tableName, selectQuery);
                Map<String, dynamic> locationDetailNode = {};
                if (mapOfLocationList.length == 1) {
                  for (var locationList in mapOfLocationList) {
                    var locationItem = locationList;
                    bool bIsAssociatedLocationActive = (locationItem["IsActive"] == 1) ? true : false;
                    configDataJsonNode["isAssociatedLocationActive"] = bIsAssociatedLocationActive;
                    if (bIsAssociatedLocationActive) {
                      locationDetailNode["permission_value"] = int.tryParse(locationItem["PermissionValue"].toString()) ?? 0;
                      locationDetailNode["folder_title"] = locationItem["LocationTitle"];
                      locationDetailNode["folderId"] = locationItem["FolderId"];
                      locationDetailNode["projectId"] = locationItem["ProjectId"];
                      String strFolderPath = locationItem["LocationPath"];
                      locationDetailNode["folderPath"] = strFolderPath;

                      Map<String, dynamic> pfLocationTreeDetailNode = {};
                      pfLocationTreeDetailNode["docId"] = locationItem["DocId"];
                      pfLocationTreeDetailNode["revisionId"] = locationItem["RevisionId"];
                      pfLocationTreeDetailNode["annotationId"] = locationItem["AnnotationId"];
                      pfLocationTreeDetailNode["locationCoordinates"] = locationItem["LocationCoordinate"];
                      pfLocationTreeDetailNode["locationId"] = int.tryParse(locationItem["LocationId"].toString()) ?? 0;
                      pfLocationTreeDetailNode["siteId"] = int.tryParse(locationItem["SiteId"].toString()) ?? 0;
                      pfLocationTreeDetailNode["parentLocationId"] = int.tryParse(locationItem["ParentLocationId"].toString()) ?? 0;
                      pfLocationTreeDetailNode["pageNumber"] = locationItem["PageNumber"];
                      pfLocationTreeDetailNode["isSite"] = locationItem["IsSite"] == 1 ? true : false;
                      pfLocationTreeDetailNode["isFileUploaded"] = locationItem["IsFileUploaded"] == 1 ? true : false;
                      pfLocationTreeDetailNode["isCalibrated"] = locationItem["IsCalibrated"] == 1 ? true : false;
                      locationDetailNode["pfLocationTreeDetail"] = pfLocationTreeDetailNode;
                    }
                  }
                }
                configDataJsonNode["selectedLocation"] = locationDetailNode;
              }
            }
          }
          break;
        default:
          {}
          break;
      }

      switch (eReqType) {
        case EHtmlRequestType.respond:
          {
            configDataJsonNode["viewForm_PID"] = strProjectId;
            configDataJsonNode["viewerProjectId"] = strProjectId;
            bool isAllowLocationAssociations = strFormTypeDetailJson["allowLocationAssociation"];
            configDataJsonNode["canAssociateLocation"] = isAllowLocationAssociations;
            bool isLocationAssocMandatory = strFormTypeDetailJson["isLocationAssocMandatory"];
            configDataJsonNode["isLocationAssocMandatory"] = isLocationAssocMandatory;
            SiteForm? formData = await getFormVOFromDB(projectId: strProjectId, formId: strFormId);
            if (formData != null) {
              String strControllerUserId = formData.controllerUserId.toString().plainValue();
              if (strControllerUserId != "" && strControllerUserId != "0") {
                configDataJsonNode["selectedControllerId"] = strControllerUserId;
              }
            }
            FormMessageVO? formMsgData = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strMsgId);
            try {
              configDataJsonNode.remove("locationId");
            } catch (_) {}
            if (formData != null) {
              configDataJsonNode["locationId"] = (formData.locationId ?? 0) == 0 ? "0" : formData.locationId;
              configDataJsonNode["observationId"] = formData.observationId ?? 0;
              configDataJsonNode["formId"] = formData.formId;
              configDataJsonNode["commId"] = formData.commId;
            } else {
              configDataJsonNode["locationId"] = "0";
              configDataJsonNode["observationId"] = 0;
              configDataJsonNode["formId"] = "";
              configDataJsonNode["commId"] = "";
              configDataJsonNode["templateType"] = "2";
            }
            if (formMsgData != null) {
              configDataJsonNode["isDraft"] = "true";
              configDataJsonNode["msgId"] = formMsgData.msgId;
              configDataJsonNode["enableBtnDiscardDraft"] = true;

              //getAttachment List
              Map<String, dynamic> pAttachAssocNode = await getFieldEditDraftAttachAndAssocList(projectid: formMsgData.projectId!, formId: formData!.formId!, msgId: formMsgData.msgId!);
              if (pAttachAssocNode.isNotEmpty) {
                Log.d("SiteFormListingLocalDataSource getHTMLConfigDataJson pAttachAssocNode=${pAttachAssocNode.length}");
                configDataJsonNode.addAll(pAttachAssocNode);
                pAttachAssocNode.clear();
              } else {
                configDataJsonNode["viewName"] = "null";
                configDataJsonNode["listName"] = "null";
                Log.d("SiteFormListingLocalDataSource getHTMLConfigDataJson pAttachAssocNode=nullptr");
              }
              String strDraftSentActions = formMsgData?.draftSentActions ?? "";
              if (strDraftSentActions != "") {
                try {
                  Map<String, dynamic> distSelectedJSONNodeList = jsonDecode(strDraftSentActions);
                  configDataJsonNode["distSelectedJSON"] = distSelectedJSONNodeList;
                } catch (_) {
                  Log.d("SiteFormListingLocalDataSource getHTMLConfigDataJson distSelectedJSON default::exception");
                }
              } else {
                Log.d("SiteFormListingLocalDataSource getHTMLConfigDataJson strDraftSentActions empty");
              }
            } else {
              configDataJsonNode["viewName"] = "null";
              configDataJsonNode["listName"] = "null";
              configDataJsonNode["msgId"] = "0";
              configDataJsonNode["isDraft"] = "false";
              configDataJsonNode["enableBtnDiscardDraft"] = false;
              String distributionData = await getDistributionList({"projectId": strProjectId, "formTypeId": strFormTypeId});
              if (distributionData.isNotEmpty) {
                try {
                  formMsgData = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strParentMsgId);
                  if (formMsgData != null) {
                    Map<String, dynamic> distListNode = jsonDecode(distributionData);
                    List<Map<String, dynamic>> distSelectedJSONNodeList = [];
                    List<Map<String, dynamic>> userListNode = (distListNode["distData"]["userList"] as List).map((e) => e as Map<String, dynamic>)?.toList() ?? [];
                    List<Map<String, dynamic>> actionListNode = (distListNode["distData"]["actionList"] as List).map((e) => e as Map<String, dynamic>)?.toList() ?? [];
                    Map<String, dynamic> forInfoActionNode = getActionNodeFromActionList(actionListNode, "7"); // get For Information Action
                    for (var userNodeTmp in userListNode) {
                      if (userNodeTmp["userID"].toString().plainValue() == formMsgData.msgOriginatorId.toString().plainValue() && (formMsgData.msgOriginatorId.toString().plainValue() != loginUser.usersessionprofile?.userID.toString().plainValue())) {
                        Map<String, dynamic> selectUserNode = _getDistributionUserNode(strProjectId, userNodeTmp, forInfoActionNode);
                        distSelectedJSONNodeList.add(selectUserNode);
                      }
                    }
                    String strSentActions = formMsgData.sentActions ?? "";
                    if (strSentActions.isNotEmpty) {
                      try {
                        List<Map<String, dynamic>> sentActionsListNode = (jsonDecode(strSentActions) as List).map((e) => e as Map<String, dynamic>)?.toList() ?? [];
                        for (var sentActionsNodeTmp in sentActionsListNode) {
                          String strRecipientIdTmp = sentActionsNodeTmp["recipientId"].toString();
                          for (var userNodeTmp in userListNode) {
                            if (userNodeTmp["userID"].toString().plainValue() != formMsgData.msgOriginatorId.plainValue()) {
                              if (userNodeTmp["userID"].toString().plainValue() == strRecipientIdTmp.plainValue() && strRecipientIdTmp.plainValue() != loginUser.usersessionprofile?.userID.toString().plainValue()) {
                                Map<String, dynamic> selectUserNode = _getDistributionUserNode(strProjectId, userNodeTmp, forInfoActionNode);
                                distSelectedJSONNodeList.add(selectUserNode);
                              }
                            }
                          }
                        }
                      } catch (e, stacktrace) {
                        Log.d("SiteFormListingLocalDataSource getConfigDataJsonForCreateorView distSelectedJSON dstrParentMsgId strSentActions default::exception $e");
                        Log.d("SiteFormListingLocalDataSource getConfigDataJsonForCreateorView distSelectedJSON dstrParentMsgId strSentActions default::exception $stacktrace");
                      }
                    }
                    configDataJsonNode["distSelectedJSON"] = distSelectedJSONNodeList;
                  } else {
                    Log.d("SiteFormListingLocalDataSource getHTMLConfigDataJson Respond distSelectedJSON dstrParentMsgId strSentActions empty");
                  }
                } catch (e) {
                  Log.d("SiteFormListingLocalDataSource getHTMLConfigDataJson Respond distSelectedJSON default::exception $e");
                }
              } else {
                Log.d("SiteFormListingLocalDataSource getHTMLConfigDataJson Respond distResponse= empty");
              }
            }
            configDataJsonNode["hashedLatestMsgId"] = "";
            configDataJsonNode["toOpen"] = "Respond";
            configDataJsonNode["actionId"] = "";
            configDataJsonNode["actionTime"] = "null";
            configDataJsonNode["templateType"] = configeDataMap["TemplateTypeId"];
            configDataJsonNode["formMsgActionId"] = "";
            configDataJsonNode["viewAlwaysFormAssociation"] = "";
            configDataJsonNode["assocParentProjectId"] = strProjectId;
            configDataJsonNode["assocParentFormTypeId"] = strFormTypeId;
            configDataJsonNode["resCollaborate"] = "";
            configDataJsonNode["hLatestFormType"] = strFormTypeId;

            configDataJsonNode["msgTypeCode"] = "null";
            configDataJsonNode["originatorId"] = "null";
            configDataJsonNode["parentMsgId"] = "null";
            configDataJsonNode["statusid"] = "null";
            configDataJsonNode["docType"] = "null";
            configDataJsonNode["isAndroidDevice"] = true;
            configDataJsonNode["isOpenToCompleteAction"] = false;
            configDataJsonNode["isProjectArchived"] = false;
            configDataJsonNode["isForReply"] = true;
          }
          break;
        case EHtmlRequestType.viewForm:
          {
            configDataJsonNode["viewForm_PID"] = strProjectId;
            configDataJsonNode["viewerProjectId"] = strProjectId;
            String strToOpen = paramData["toOpen"] ?? "";
            if (strToOpen.isEmpty) {
              strToOpen = "FromForms";
            }
            configDataJsonNode["toOpen"] = strToOpen;
            configDataJsonNode["actionId"] = "";
            configDataJsonNode["actionTime"] = "null";
            configDataJsonNode["formMsgActionId"] = "";
            configDataJsonNode["templateType"] = configeDataMap["TemplateTypeId"];
            configDataJsonNode["assocParentProjectId"] = strProjectId;
            configDataJsonNode["assocParentFormTypeId"] = "0";
            configDataJsonNode["hLatestFormType"] = strFormTypeId;
            configDataJsonNode["viewAlwaysFormAssociation"] = "";
            configDataJsonNode["isAndroidDevice"] = true;
            configDataJsonNode["isOpenToCompleteAction"] = false;
            configDataJsonNode["isProjectArchived"] = false;
            configDataJsonNode["resCollaborate"] = "";
            configDataJsonNode["docType"] = "";
            SiteForm? formData;
            if (strProjectId.isNotEmpty && strFormId.isNotEmpty && ((strProjectId.isHashValue() ? strProjectId.plainValue() : strProjectId) != "") && ((strFormId.isHashValue() ? strFormId.plainValue() : strFormId) != "0")) {
              formData = await getFormVOFromDB(projectId: strProjectId, formId: strFormId);
            }

            if (formData != null && formData.formId != null) {
              configDataJsonNode["observationId"] = int.tryParse(formData.observationId.toString()) ?? 0;
              configDataJsonNode["formId"] = formData.formId;
              configDataJsonNode["originatorId"] = formData.originatorId;
              configDataJsonNode["commId"] = formData.formId;
              configDataJsonNode["statusid"] = formData.statusid;
              configDataJsonNode["msgId"] = formData.msgId;
            } else {
              configDataJsonNode["observationId"] = 0;
              configDataJsonNode["formId"] = "";
              configDataJsonNode["originatorId"] = "";
              configDataJsonNode["commId"] = "";
              configDataJsonNode["statusid"] = "null";
            }
            FormMessageVO? formMsgData;
            if (strFormId.isNotEmpty && ((strMsgId.isHashValue() ? strMsgId.plainValue() : strMsgId) != "") && ((strMsgId.isHashValue() ? strMsgId.plainValue() : strMsgId) != "0")) {
              formMsgData = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strMsgId);
            }

            if (formMsgData != null && formMsgData.msgId != null) {
              configDataJsonNode["isEditFormOffline"] = (formMsgData.offlineRequestData != "" && !(formMsgData.isDraft ?? false));
              configDataJsonNode["isDraft"] = "true";
              configDataJsonNode["msgId"] = formMsgData.msgId;
              configDataJsonNode["hashedLatestMsgId"] = formMsgData.msgId;
              configDataJsonNode["msgTypeCode"] = formMsgData.msgCode;
              configDataJsonNode["parentMsgId"] = formMsgData.parentMsgId;
              Map<String, dynamic> pAttachAssocNode = await getCreateAndRespondAttachAndAssocList(projectid: formMsgData.projectId!, formId: formMsgData.formId!, msgId: formMsgData.msgId!);
              if (pAttachAssocNode.isNotEmpty) {
                configDataJsonNode = {...pAttachAssocNode};
                pAttachAssocNode.clear();
              } else {}
            } else {
              configDataJsonNode["isEditFormOffline"] = false;
              configDataJsonNode["msgId"] = "0";
              configDataJsonNode["hashedLatestMsgId"] = "";
              configDataJsonNode["isDraft"] = "null";
              configDataJsonNode["msgTypeCode"] = "null";
              configDataJsonNode["parentMsgId"] = "null";

              List<Map<String, dynamic>> AttachmentArrayNode = [];
              configDataJsonNode["attachFilesobj"] = AttachmentArrayNode;
              List<Map<String, dynamic>> AssocFileArrayNode = [];
              configDataJsonNode["assocDocsObj"] = AssocFileArrayNode;
              List<Map<String, dynamic>> AssocFormArrayNode = [];
              configDataJsonNode["assocCommsObj"] = AssocFormArrayNode;
              List<Map<String, dynamic>> AssocComArrayNode = [];
              configDataJsonNode["assocDiscussObj"] = AssocComArrayNode;
            }
          }
          break;
        default:
          {}
          break;
      }
      configDataJsonNode["hideBackButton"] = hideBackButton;
      strResponseJson = jsonEncode(configDataJsonNode);
    } catch (e, stacktrace) {
      strResponseJson = "{}";
      Log.d("SiteFormListingLocalDataSource getOfflineObservationListJson exception $e");
      Log.d("SiteFormListingLocalDataSource getOfflineObservationListJson exception $stacktrace");
    }
    return strResponseJson;
  }

  Future<FormMessageVO?> getFormMessageVOFromDB({required String projectId, required String formId, required String msgId}) async {
    FormMessageVO? frmMsgVo;
    projectId = projectId.plainValue();
    formId = formId.plainValue();
    msgId = msgId.plainValue();
    if (projectId.isNotEmpty && formId.isNotEmpty && msgId.isNotEmpty) {
      try {
        String selectQuery = "SELECT * FROM ${FormMessageDao.tableName}\n"
            "WHERE ${FormMessageDao.projectIdField}=$projectId AND ${FormMessageDao.formIdField}=$formId AND ${FormMessageDao.msgIdField}=$msgId";
        var resultData = databaseManager.executeSelectFromTable(FormMessageDao.tableName, selectQuery);
        if (resultData.isNotEmpty) {
          frmMsgVo = FormMessageDao().fromMap(resultData.first);
        }
      } on Exception catch (e, stacktrace) {
        Log.d("FormLocalDataSource::getFormMessageVOFromDB exception $e");
        Log.d("FormLocalDataSource::getFormMessageVOFromDB exception $stacktrace");
      }
    } else {
      Log.d("FormLocalDataSource::getFormMessageVOFromDB empty projectId=$projectId, formId=$formId, msgId=$msgId");
    }
    return frmMsgVo;
  }

  Future<SiteForm?> getFormVOFromDB({required String projectId, required String formId}) async {
    SiteForm? frmVo;
    projectId = projectId.plainValue();
    formId = formId.plainValue();
    if (projectId.isNotEmpty && formId.isNotEmpty) {
      try {
        String query = "WITH OfflineSyncData AS (SELECT ";
        query = "$query CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN ${EOfflineSyncRequestType.BatchProcess.value} ELSE ${EOfflineSyncRequestType.CreateOrRespond.value} END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds";
        query = "$query FROM ${FormMessageDao.tableName} frmMsgTbl";
        query = "$query INNER JOIN ${FormDao.tableName} frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId";
        query = "$query INNER JOIN ${FormTypeDao.tableName} frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId";
        query = "$query WHERE frmMsgTbl.OfflineRequestData<>''";
        query = "$query AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1))";
        query = "$query SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM ${FormDao.tableName} frmTbl";
        query = "$query LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId";
        query = "$query AND fldSycDataView.Type IN (${EOfflineSyncRequestType.CreateOrRespond.value},${EOfflineSyncRequestType.StatusChange.value},${EOfflineSyncRequestType.BatchProcess.value})";
        query = "$query WHERE frmTbl.ProjectId=$projectId ";
        query = "$query AND frmTbl.FormId=$formId";
        var resultData = databaseManager.executeSelectFromTable(FormDao.tableName, query);
        if (resultData.isNotEmpty) {
          frmVo = FormDao().fromMap(resultData.first);
        }
      } on Exception catch (e, stacktrace) {
        Log.d("FormLocalDataSource::getFormVOFromDB exception $e");
        Log.d("FormLocalDataSource::getFormVOFromDB exception $stacktrace");
      }
    } else {
      Log.d("FormLocalDataSource::getFormVOFromDB empty projectId=$projectId, formId=$formId");
    }
    return frmVo;
  }

  Future<AppType?> getFormTypeVOFromDB({required String projectId, required String formTypeId}) async {
    AppType? formType;
    projectId = projectId.plainValue();
    formTypeId = formTypeId.plainValue();
    if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
      try {
        String query = "SELECT * FROM ${FormTypeDao.tableName}\n"
            "WHERE ${FormTypeDao.projectIdField}=$projectId AND ${FormTypeDao.formTypeIdField}=$formTypeId";
        var resultData = databaseManager.executeSelectFromTable(FormTypeDao.tableName, query);
        if (resultData.isNotEmpty) {
          formType = FormTypeDao().fromMap(resultData.first);
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getFormTypeVOFromDB exception $e");
      }
    }
    return formType;
  }

  Future<SiteLocation?> getLocationVOFromDB({required String projectId, required String locationId}) async {
    SiteLocation? object;
    projectId = projectId.plainValue();
    if (projectId.isNotEmpty && locationId.isNotEmpty) {
      try {
        String query = "SELECT * FROM ${LocationDao.tableName}\n"
            "WHERE ${LocationDao.projectIdField}=$projectId AND ${LocationDao.locationIdField}=$locationId";
        var resultData = databaseManager.executeSelectFromTable(LocationDao.tableName, query);
        if (resultData.isNotEmpty) {
          object = LocationDao().fromMap(resultData.first);
        }
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getFormTypeVOFromDB exception $e");
      }
    }
    return object;
  }

  Future<Map<String, dynamic>> getCreateAndRespondAttachAndAssocList({required String projectid, required String formId, String msgId = ""}) async {
    Map<String, dynamic> pAttachAndAssocListNode = {};
    try {
      Map<String, dynamic> paramData = {};
      paramData["projectId"] = projectid;
      paramData["formId"] = formId;
      paramData["msgId"] = msgId;

      String response = await getOfflineAttachmentAndAssociationListJson(paramData);
      if (response.isNotEmpty) {
        List<dynamic> attachAndAssocListNode = jsonDecode(response);
        List<Map<String, dynamic>> AttachmentArrayNode = [];
        List<Map<String, dynamic>> AssocFileArrayNode = [];
        List<Map<String, dynamic>> AssocFormArrayNode = [];
        List<Map<String, dynamic>> AssocComArrayNode = [];
        try {
          for (var attachAndAssocNode in attachAndAssocListNode) {
            Map<String, dynamic> attachmentDetailNode = {};

            attachmentDetailNode["FileName"] = attachAndAssocNode["fileName"].toString();
            attachmentDetailNode["FileType"] = attachAndAssocNode["fileType"].toString();
            attachmentDetailNode["revisionId"] = attachAndAssocNode["revisionId"].toString();
            attachmentDetailNode["hasBravaSupport"] = (attachAndAssocNode["hasBravaSupport"].toString().toLowerCase() == "true") ? true : false;
            attachmentDetailNode["DocumentId"] = attachAndAssocNode["docId"].toString();
            try {
              if (attachAndAssocNode["attachedByName"].toString() != "") {
                attachmentDetailNode["attachedBy"] = attachAndAssocNode["attachedByName"].toString();
              }
            } catch (e) {}

            try {
              if (attachAndAssocNode["attachedById"].toString() != "") {
                attachmentDetailNode["PublisherUserId"] = int.tryParse(attachAndAssocNode["attachedById"].toString()) ?? 0;
              }
            } catch (e) {}

            String strFileSize = attachAndAssocNode["fileSize"].toString();
            List<String> strFileVect = strFileSize.split(" ");
            if (strFileVect.length == 2) {
              double lSize = double.tryParse(strFileVect[0].toString()) ?? 0.0;
              if (lSize > 0) {
                if (strFileVect[1].toUpperCase() == "KB") {
                  lSize = lSize * 1000;
                } else if (strFileVect[1].toUpperCase() == "MB") {
                  lSize = lSize * 1000 * 1000;
                } else if (strFileVect[1].toUpperCase() == "GB") {
                  lSize = lSize * 1000 * 1000 * 1000;
                }
              }
              attachmentDetailNode["FileSize"] = lSize.toInt();
            } else {
              attachmentDetailNode["FileSize"] = strFileSize;
            }

            try {
              if (attachAndAssocNode["attachedDate"].toString() != "") {
                attachmentDetailNode["attachedDate"] = attachAndAssocNode["attachedDate"].toString();
              }
            } catch (e) {}
          }
        } catch (e) {}

        if (AttachmentArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["attachFilesobj"] = AttachmentArrayNode;
        }
        if (AssocFileArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["assocDocsObj"] = AssocFileArrayNode;
        }
        if (AssocFormArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["assocCommsObj"] = AssocFormArrayNode;
        }
        if (AssocComArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["assocDiscussObj"] = AssocComArrayNode;
        }
      }
    } catch (e, stacktrace) {
      Log.d("SiteFormListingLocalDataSource getOfflineAttachmentAndAssociationListJson exception $e");
      Log.d("SiteFormListingLocalDataSource getOfflineAttachmentAndAssociationListJson exception $stacktrace");
    }
    return pAttachAndAssocListNode;
  }

  Future<String> getOfflineAttachmentAndAssociationListJson(Map<String, dynamic> paramData) async {
    String value = "";
    try {
      String projectId = paramData["projectId"].toString();
      String formId;
      if (paramData.containsKey('commId')) {
        formId = paramData["commId"].toString();
      } else {
        formId = paramData["formId"].toString();
      }
      String? msgId = paramData["msgId"]?.toString();
      String? requestedEntityType = paramData["requestedEntityType"];

      if (!requestedEntityType.isNullOrEmpty()) {
        if (requestedEntityType!.toLowerCase() == "views" || requestedEntityType.toLowerCase() == "lists") {
          return "[]";
        }
      }

      String attachmentListQuery = "SELECT frmMsgAttachTbl.*, prjTbl.DcId, IFNULL(frmView.LocationId,0) AS LocationId, IFNULL(frmView.FormId,0) AS IsAvailableOffline,"
          " IFNULL(frmView.ObservationId,0) AS ObservationId, IFNULL(frmView.AppBuilderId,'') AS AppBuilderId, "
          "IFNULL(frmView.TemplateType,0) AS TemplateType FROM ${FormMessageAttachAndAssocDao.tableName} frmMsgAttachTbl "
          "INNER JOIN ${ProjectDao.tableName} prjTbl ON prjTbl.ProjectId=frmMsgAttachTbl.ProjectId "
          "LEFT JOIN ${FormDao.tableName} frmView ON frmView.ProjectId=frmMsgAttachTbl.AssocProjectId AND frmView.FormId=frmMsgAttachTbl.AssocFormCommId AND frmMsgAttachTbl.AttachmentType IN (2,6)";

      attachmentListQuery = "$attachmentListQuery WHERE frmMsgAttachTbl.ProjectId=${projectId.plainValue()}";
      attachmentListQuery = "$attachmentListQuery AND frmMsgAttachTbl.FormId=${formId.plainValue()}";

      if (!msgId.isNullOrEmpty()) {
        attachmentListQuery = "$attachmentListQuery AND frmMsgAttachTbl.MsgId=$msgId \n";
      }

      Log.d("getOfflineAttachmentAndAssociationListJson query=$attachmentListQuery");
      var mapOfAttachmentList = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, attachmentListQuery);
      Log.d("getOfflineAttachmentAndAssociationListJson mapOfAttachmentList size=${mapOfAttachmentList.length}");

      List<Map<String, dynamic>> formAssocAttachmentList = [];

      for (var element in mapOfAttachmentList) {
        Map<String, dynamic> attachAssocDetailJson = jsonDecode(element[FormMessageAttachAndAssocDao.attachAssocDetailJsonField]);

        switch (EAttachmentAndAssociationType.fromString(element[FormMessageAttachAndAssocDao.attachmentTypeField].toString())) {
          case EAttachmentAndAssociationType.attachments:
            String strAttachFilePath = await AppPathHelper().getAttachmentFilePath(projectId: projectId, revisionId: attachAssocDetailJson["revisionId"].toString(), fileExtention: Utility.getFileExtension(attachAssocDetailJson["fileName"].toString()));
            if (strAttachFilePath.isNotEmpty) {
              attachAssocDetailJson["attachFilePath"] = strAttachFilePath;
            }
            attachAssocDetailJson["OfflineAttachFilePath"] = strAttachFilePath;
            break;

          case EAttachmentAndAssociationType.files:
            /*Uncomment this code in future use */

            // if (element["IsAvailableOffline"]) {
            //   String strProjectId = element["ProjectId"]; // hashvalue
            //   String strDocId = attachAssocDetailJson["docId"];
            //
            //   attachAssocDetailJson["documentId"] = strDocId;
            //   attachAssocDetailJson["projectViewerId"] = element["ProjectViewerId"];
            //   attachAssocDetailJson["pdfFilePath"] = await AppPathHelper().getPlanPDFFilePath(projectId: strProjectId, revisionId: strDocId);
            //   attachAssocDetailJson["xfdfFilePath"] = await AppPathHelper().getPlanXFDFFilePath(projectId: strProjectId, revisionId: strDocId);
            // }
            attachAssocDetailJson["isAvailableOffline"] = false;

            break;

          case EAttachmentAndAssociationType.apps:
          case EAttachmentAndAssociationType.references:
            if ((int.tryParse(element["IsAvailableOffline"].toString()) ?? 0) > 0) {
              attachAssocDetailJson["locationId"] = element["LocationId"];
              attachAssocDetailJson["observationId"] = element["ObservationId"];
              attachAssocDetailJson["appBuilderId"] = element["AppBuilderId"];

              attachAssocDetailJson["templateType"] = element["TemplateType"];
            }
            attachAssocDetailJson["isAvailableOffline"] = (int.tryParse(element["IsAvailableOffline"].toString()) ?? 0) > 0 ? true : false;
            break;

          default:
            /*Uncomment this code in future use */

            // if (element["IsAvailableOffline"]) {
            //   attachmentMap["locationId"] = element["LocationId"];
            //   attachmentMap["observationId"] = element["ObservationId"];
            //   attachmentMap["appBuilderId"] = element["AppBuilderId"];
            //
            //   attachmentMap["templateType"] = element["TemplateType"];
            // }
            // attachmentMap["isAvailableOffline"] = element["IsAvailableOffline"] ? true : false;

            attachAssocDetailJson["isAvailableOffline"] = false;
            break;
        }
        formAssocAttachmentList.add(attachAssocDetailJson);
      }

      if (requestedEntityType == "views" || requestedEntityType == "lists") {
        Map responseMap = <String, dynamic>{};
        int listingType = 0;
        if (requestedEntityType == "views") {
          listingType = 75;
          responseMap["assocViewList"] = jsonEncode(formAssocAttachmentList);
        } else if (requestedEntityType == "lists") {
          listingType = 76;
          responseMap["assocObjectListList"] = jsonEncode(formAssocAttachmentList);
        }
        responseMap["totalDocs"] = 0;
        responseMap["recordBatchSize"] = 250;
        responseMap["listingType"] = listingType;
        responseMap["currentPageNo"] = 1;
        responseMap["recordStartFrom"] = 1;
        String columnHeadersResponse = await getOfflineFormMessageAttachmentAndAssociationColumnHeadersListJson({"ListingType": listingType});
        responseMap["columnHeader"] = columnHeadersResponse;
        return jsonEncode(responseMap);
      } else {
        return jsonEncode(formAssocAttachmentList);
      }
    } on Exception catch (e) {
      Log.d("getOfflineAttachmentAndAssociationListJson error=${e.toString()}");
    }
    return value;
  }

  Future<Map<String, dynamic>> getFieldEditDraftAttachAndAssocList({required String projectid, required String formId, String msgId = ""}) async {
    Map<String, dynamic> pAttachAndAssocListNode = {};
    try {
      Map<String, dynamic> paramData = {};
      paramData["projectId"] = projectid;
      paramData["formId"] = formId;
      paramData["msgId"] = msgId;
      var httpResponse = jsonDecode(await getOfflineFieldMessagesAttachmentAndAssociationListJson(paramData));
      if (httpResponse.isNotEmpty) {
        pAttachAndAssocListNode = jsonDecode(getCommonEditDraftAttachAndAssocList(httpResponse));
      }
    } catch (e) {
      Log.e("Exception is::", "->$e");
    }
    return pAttachAndAssocListNode;
  }

  Future<String> getOfflineFieldMessagesAttachmentAndAssociationListJson(Map<String, dynamic> paramData) async {
    try {
      String projectId = paramData["projectId"].toString();
      String formId = paramData["formId"].toString();
      String? msgId = paramData["msgId"]?.toString();
      String? strRequestedEntityType = paramData["requestedEntityType"];
      String strListingType = "";
      if (!strRequestedEntityType.isNullOrEmpty()) {
        strRequestedEntityType = strRequestedEntityType!.toLowerCase();
        if (strRequestedEntityType == "views" || strRequestedEntityType == "lists") {
          return "[]";
        }
      }

      String selectQuery = "SELECT frmMsgAttachTbl.*, prjTbl.DcId, IFNULL(frmView.LocationId,0) AS LocationId,"
          " IFNULL(frmView.ObservationId,0) AS ObservationId, IFNULL(frmView.AppBuilderId,'') AS AppBuilderId, "
          "IFNULL(frmView.TemplateType,0) AS TemplateType FROM ${FormMessageAttachAndAssocDao.tableName} frmMsgAttachTbl "
          "INNER JOIN ${ProjectDao.tableName} prjTbl ON prjTbl.ProjectId=frmMsgAttachTbl.ProjectId "
          "LEFT JOIN ${FormDao.tableName} frmView ON frmView.ProjectId=frmMsgAttachTbl.AssocProjectId AND frmView.FormId=frmMsgAttachTbl.AssocFormCommId AND frmMsgAttachTbl.AttachmentType IN (2,6)";
      // "WHERE frmMsgAttachTbl.ProjectId=2089700 AND frmMsgAttachTbl.FormId=1685695997981 AND frmMsgAttachTbl.MsgId=1685696123049";

      // String selectQuery = "SELECT frmMsgAttachTbl.*, prjTbl.DcId, ";
      // selectQuery = "${selectQuery} (CASE frmMsgAttachTbl.AttachmentType WHEN ${EAttachmentAndAssociationType.files.value} THEN IFNULL(frmMsgAttachTbl.AttachRevId,0) WHEN ${EAttachmentAndAssociationType.apps.value} THEN IFNULL(frmView.FormId,0) WHEN ${EAttachmentAndAssociationType.references.value} THEN IFNULL(frmView.FormId,0) ELSE 0 END) AS IsAvailableOffline,
      // IFNULL(frmView.LocationId,0) AS LocationId, IFNULL(frmView.ObservationId,0) AS ObservationId,
      // IFNULL(frmView.AppBuilderId,'') AS AppBuilderId, IFNULL(frmView.TemplateType,0) AS TemplateType,
      // IFNULL(frmMsgAttachTbl.AssocViewId,1) AS ProjectViewerId FROM ${FormMessageAttachAndAssocDao.tableName} frmMsgAttachTbl ";
      // selectQuery = "${selectQuery} INNER JOIN ${ProjectDao.tableName} prjTbl ON prjTbl.ProjectId=frmMsgAttachTbl.ProjectId ";
      // //selectQuery = "${selectQuery} LEFT JOIN " + FILE_DOCUMENT_TABLENAME + " docTbl ON docTbl.ProjectId=frmMsgAttachTbl.AssocProjectId AND docTbl.FolderId=frmMsgAttachTbl.AssocDocFolderId AND docTbl.RevisionId=frmMsgAttachTbl.AssocDocRevisionId AND frmMsgAttachTbl.AttachmentType=" + NumberToStdString(EAttachmentAndAssociationType_Files) + " ";
      // selectQuery = "${selectQuery} LEFT JOIN ${FormDao.tableName} frmView ON frmView.ProjectId=frmMsgAttachTbl.AssocProjectId AND frmView.FormId=frmMsgAttachTbl.AssocFormCommId AND frmMsgAttachTbl.AttachmentType IN (${EAttachmentAndAssociationType.apps.value},${EAttachmentAndAssociationType.references.value})";
      selectQuery = "$selectQuery WHERE frmMsgAttachTbl.ProjectId=${projectId.plainValue()}";
      selectQuery = "$selectQuery AND frmMsgAttachTbl.FormId=${formId.plainValue()}";
      if (msgId != "") {
        selectQuery = "$selectQuery AND frmMsgAttachTbl.MsgId=${msgId.plainValue()}";
      }
      Log.d("getOfflineFieldMessagesAttachmentAndAssociationListJson query=$selectQuery");
      var mapOfMessagesAttachmentList = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, selectQuery);
      Log.d("getOfflineFieldMessagesAttachmentAndAssociationListJson mapOfAttachmentList size=${selectQuery.length}");

      List<Map<String, dynamic>> AttachmentArrayNode = [];
      for (var objAttachment in mapOfMessagesAttachmentList) {
        var objAttachmentDetail = objAttachment;
        Map<String, dynamic> attachmentDetailNode = jsonDecode(objAttachmentDetail["AttachAssocDetailJson"]);
        switch (EAttachmentAndAssociationType.fromString(objAttachmentDetail["AttachmentType"].toString())) {
          case EAttachmentAndAssociationType.attachments:
            {
              String strRevisionId = attachmentDetailNode["revisionId"].toString().plainValue();
              String? strFileExtension = attachmentDetailNode["fileName"].toString().getFileExtension();
              String strLocalProjectId = attachmentDetailNode["projectId"].toString().plainValue();
              String strAttachFilePath = await AppPathHelper().getAttachmentFilePath(projectId: strLocalProjectId, revisionId: strRevisionId, fileExtention: strFileExtension!, isExtensionNameOnly: (strFileExtension.contains(".")) ? true : false);
              if (await isFileExists(File(strAttachFilePath))) {
                attachmentDetailNode["attachFilePath"] = strAttachFilePath;
              }
              attachmentDetailNode["OfflineAttachFilePath"] = strAttachFilePath; //objAttachmentDetail["OfflineAttachFilePath"].toString();
            }
            break;
          case EAttachmentAndAssociationType.files:
            {
              /*if (atoll(objAttachmentDetail["IsAvailableOffline"].c_str()) > 0) {
  std::string strLocalProjectId = attachmentDetailNode->at("projectId").as_string();
  std::string strLocalDocumentId = attachmentDetailNode->at("docId").as_string();

  attachmentDetailNode->push_back(new JSONNode("documentId", json_string(strLocalDocumentId)));
  attachmentDetailNode->push_back(new JSONNode("projectViewerId", json_string(objAttachmentDetail["ProjectViewerId"])));
  attachmentDetailNode->push_back(new JSONNode("pdfFilePath", json_string(getDocumentPDFFilePath(strLocalProjectId, strLocalDocumentId))));
  attachmentDetailNode->push_back(new JSONNode("xfdfFilePath", json_string(getDocumentXFDFFilePath(strLocalProjectId, strLocalDocumentId))));
  }
  attachmentDetailNode->push_back(new JSONNode("isAvailableOffline", (atoll(objAttachmentDetail["IsAvailableOffline"].c_str()) > 0) ? true : false));*/
            }
            break;
          case EAttachmentAndAssociationType.apps:
          case EAttachmentAndAssociationType.references:
            {
              /*if (atoll(objAttachmentDetail["IsAvailableOffline"].c_str()) > 0) {
  attachmentDetailNode->push_back(new JSONNode("locationId", json_string(objAttachmentDetail["LocationId"])));
  attachmentDetailNode->push_back(new JSONNode("observationId", json_string(objAttachmentDetail["ObservationId"])));
  attachmentDetailNode->push_back(new JSONNode("appBuilderId", json_string(objAttachmentDetail["AppBuilderId"])));
  try {
  delete attachmentDetailNode->pop_back("templateType");
  }
  catch (...) {}
  attachmentDetailNode->push_back(new JSONNode("templateType", json_string(objAttachmentDetail["TemplateType"])));
  }
  attachmentDetailNode->push_back(new JSONNode("isAvailableOffline", (atoll(objAttachmentDetail["IsAvailableOffline"].c_str()) > 0) ? true : false));*/
            }
            break;
          default:
            if ((int.tryParse(objAttachmentDetail["IsAvailableOffline"].toString()) ?? 0) > 0) {
              attachmentDetailNode["locationId"] = objAttachmentDetail["LocationId"].toString();
              attachmentDetailNode["observationId"] = objAttachmentDetail["ObservationId"].toString();
              attachmentDetailNode["appBuilderId"] = objAttachmentDetail["AppBuilderId"].toString();
              try {
                attachmentDetailNode.remove("templateType");
              } catch (e) {}
              attachmentDetailNode["templateType"] = objAttachmentDetail["TemplateType"].toString();
            }
            attachmentDetailNode["isAvailableOffline"] = ((int.tryParse(objAttachmentDetail["IsAvailableOffline"].toString()) ?? 0) > 0) ? true : false;
            break;
        }
        AttachmentArrayNode.add(attachmentDetailNode);
      }
      Map<String, dynamic> pParentAttachmentDataNode = {};
      if (strRequestedEntityType == "views" || strRequestedEntityType == "lists") {
        Map<String, dynamic> pParentAttachmentNode = {};
        if (strRequestedEntityType == "views") {
          strListingType = "75";
          pParentAttachmentDataNode["assocViewList"] = AttachmentArrayNode;
        } else if (strRequestedEntityType == "lists") {
          strListingType = "76";
          pParentAttachmentDataNode["assocObjectListList"] = AttachmentArrayNode;
        }
        pParentAttachmentNode["totalDocs"] = 0;
        pParentAttachmentNode["recordBatchSize"] = 250;
        pParentAttachmentNode["listingType"] = int.tryParse(strListingType.toString()) ?? 0;
        pParentAttachmentNode["currentPageNo"] = 1;
        pParentAttachmentNode["recordStartFrom"] = 1;

        String columnHeadersResponse = await getOfflineFormMessageAttachmentAndAssociationColumnHeadersListJson({"ListingType": strListingType});
        pParentAttachmentNode["columnHeader"] = columnHeadersResponse;

        List<Map<String, dynamic>> pParentAttachmentDataFormUserSetNode = [];
        pParentAttachmentNode["formUserSet"] = pParentAttachmentDataFormUserSetNode;
        pParentAttachmentDataNode["allowSelectedDocsDownload"] = false;
        pParentAttachmentDataNode["allowAllDocsDownload"] = false;
        pParentAttachmentDataNode["generateURI"] = true;
        pParentAttachmentNode["data"] = pParentAttachmentDataNode;

        return jsonEncode(pParentAttachmentNode);
      } else {
        return jsonEncode(AttachmentArrayNode);
      }
    } catch (e, stacktrace) {
      Log.d("SiteFormListingLocalDataSource getOfflineFieldMessagesAttachmentAndAssociationListJson exception $e");
      Log.d("SiteFormListingLocalDataSource getOfflineFieldMessagesAttachmentAndAssociationListJson exception $stacktrace");
    }

    return "";
  }

  String getCommonEditDraftAttachAndAssocList(List<dynamic> strResponseData) {
    Map<String, dynamic> pAttachAndAssocListNode = {};
    try {
      if (strResponseData.isNotEmpty) {
        List<Map<String, dynamic>> attachAndAssocListNode = ((strResponseData).map((e) => e as Map<String, dynamic>).toList());
        List<Map<String, dynamic>> AttachmentArrayNode = [];
        List<Map<String, dynamic>> AssocFileArrayNode = [];
        List<Map<String, dynamic>> AssocFormArrayNode = [];
        List<Map<String, dynamic>> AssocComArrayNode = [];
        try {
          for (var attachAndAssocNode in attachAndAssocListNode) {
            switch (EAttachmentAndAssociationType.fromString(attachAndAssocNode["type"].toString())) {
              case EAttachmentAndAssociationType.files:
                {
                  Map<String, dynamic> assocDetailNode = {};
                  assocDetailNode["fileName"] = attachAndAssocNode["uploadFileName"].toString();
                  assocDetailNode["viewerId"] = int.tryParse(attachAndAssocNode["viewerId"].toString().plainValue()) ?? 0;
                  assocDetailNode["documentTypeId"] = int.tryParse(attachAndAssocNode["documentTypeId"].toString().plainValue()) ?? 0;
                  assocDetailNode["attachmentImgName"] = attachAndAssocNode["attachmentImgName"].toString();
                  assocDetailNode["publishDate"] = attachAndAssocNode["publishDate"].toString();
                  assocDetailNode["is_access"] = (attachAndAssocNode["isAccess"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["description"] = attachAndAssocNode["title"].toString();
                  assocDetailNode["revisionNum"] = attachAndAssocNode["revisionNum"].toString();
                  assocDetailNode["flagTypeImageName"] = attachAndAssocNode["flagTypeImageName"].toString();
                  assocDetailNode["issueNo"] = (attachAndAssocNode["issueNo"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["purposeOfIssue"] = attachAndAssocNode["purposeOfIssue"].toString();
                  assocDetailNode["docRef"] = attachAndAssocNode["docRef"].toString();
                  assocDetailNode["dcId"] = (attachAndAssocNode["dcId"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["assocFormImgName"] = attachAndAssocNode["assocFormImgName"].toString();
                  assocDetailNode["chkStatusImgName"] = attachAndAssocNode["chkStatusImgName"].toString();
                  assocDetailNode["publisherImage"] = attachAndAssocNode["publisherImage"].toString();
                  assocDetailNode["folderId"] = attachAndAssocNode["folderId"].toString();
                  assocDetailNode["revisionId"] = attachAndAssocNode["revisionId"].toString();
                  assocDetailNode["documentFolderPath"] = attachAndAssocNode["folderPath"].toString();
                  assocDetailNode["fileSize"] = attachAndAssocNode["fileSize"].toString();
                  assocDetailNode["commentImgName"] = attachAndAssocNode["commentImgName"].toString();
                  assocDetailNode["projectId"] = attachAndAssocNode["projectId"].toString();
                  assocDetailNode["is_document_active"] = (attachAndAssocNode["isDocActive"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["fileType"] = attachAndAssocNode["fileType"].toString();
                  assocDetailNode["status"] = attachAndAssocNode["status"].toString();
                  AssocFileArrayNode.add(assocDetailNode);
                }
                break;
              case EAttachmentAndAssociationType.discussions:
                {
                  Map<String, dynamic> assocDetailNode = {};
                  assocDetailNode["code"] = attachAndAssocNode["commentCode"].toString();
                  assocDetailNode["oriCommentTitle"] = attachAndAssocNode["commentTitle"].toString();
                  assocDetailNode["viewerId"] = int.tryParse(attachAndAssocNode["viewerId"].toString().plainValue()) ?? 0;
                  assocDetailNode["modelId"] = attachAndAssocNode["modelId"].toString();
                  assocDetailNode["is_access"] = (attachAndAssocNode["isAccess"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["originator"] = attachAndAssocNode["originator"].toString();
                  assocDetailNode["issueNo"] = int.tryParse(attachAndAssocNode["issueNo"].toString().plainValue()) ?? 0;
                  assocDetailNode["folderId"] = attachAndAssocNode["folderId"].toString();
                  assocDetailNode["file_is_access"] = (attachAndAssocNode["fileIsAccess"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["doctype"] = "Comments";
                  assocDetailNode["revisionId"] = attachAndAssocNode["revisionId"].toString();
                  assocDetailNode["commentMsgId"] = attachAndAssocNode["commentMsgId"].toString();
                  assocDetailNode["dcId"] = int.tryParse(attachAndAssocNode["dcId"].toString().plainValue()) ?? 0;
                  assocDetailNode["docTypeId"] = int.tryParse(attachAndAssocNode["documentTypeId"].toString().plainValue()) ?? 0;
                  assocDetailNode["commId"] = attachAndAssocNode["commId"].toString();
                  assocDetailNode["commentID"] = attachAndAssocNode["commId"].toString();
                  assocDetailNode["typeImage"] = attachAndAssocNode["typeImage"].toString();
                  assocDetailNode["hasAttachments"] = (attachAndAssocNode["has_attachment"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["projectId"] = attachAndAssocNode["projectId"].toString();
                  assocDetailNode["updated"] = attachAndAssocNode["updated"].toString();
                  assocDetailNode["attachmentImageName"] = attachAndAssocNode["attachmentImageName"].toString();
                  assocDetailNode["is_document_active"] = (attachAndAssocNode["isDocActive"].toString().toLowerCase() == "true") ? true : false;
                  AssocComArrayNode.add(assocDetailNode);
                }
                break;
              case EAttachmentAndAssociationType.apps:
                {
                  Map<String, dynamic> assocDetailNode = {};
                  assocDetailNode["code"] = attachAndAssocNode["code"].toString();
                  assocDetailNode["formGroupName"] = attachAndAssocNode["formGroupName"].toString();
                  assocDetailNode["hasAssocations"] = (attachAndAssocNode["hasAssocations"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["is_document_active"] = (attachAndAssocNode["isDocActive"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["formTypeId"] = attachAndAssocNode["formTypeId"].toString();
                  assocDetailNode["msgId"] = attachAndAssocNode["msgId"].toString();
                  assocDetailNode["originator"] = attachAndAssocNode["originator"].toString();
                  assocDetailNode["title"] = attachAndAssocNode["title"].toString();
                  assocDetailNode["flagTypeImageName"] = attachAndAssocNode["flagTypeImageName"].toString();
                  assocDetailNode["hasViewAccess"] = (attachAndAssocNode["hasViewAccess"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["doctype"] = "Apps";
                  assocDetailNode["dcId"] = (attachAndAssocNode["dcId"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["is_document_active"] = (attachAndAssocNode["isDocActive"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["commId"] = attachAndAssocNode["commId"].toString();
                  assocDetailNode["formTypeName"] = attachAndAssocNode["formTypeName"].toString();
                  assocDetailNode["typeImage"] = attachAndAssocNode["typeImage"].toString();
                  assocDetailNode["projectName"] = attachAndAssocNode["projectName"].toString();
                  assocDetailNode["hasAttachments"] = (attachAndAssocNode["hasAttachments"].toString().toLowerCase() == "true") ? true : false;
                  assocDetailNode["projectId"] = attachAndAssocNode["projectId"].toString();
                  assocDetailNode["status"] = attachAndAssocNode["status"].toString();
                  AssocFormArrayNode.add(assocDetailNode);
                }
                break;
              case EAttachmentAndAssociationType.attachments:
                {
                  Map<String, dynamic> attachmentDetailNode = {};

                  String strFileName = attachAndAssocNode["fileName"].toString();
                  attachmentDetailNode["FileName"] = strFileName;
                  attachmentDetailNode["FileType"] = strFileName.getFileExtension();
                  attachmentDetailNode["revisionId"] = attachAndAssocNode["revisionId"].toString();
                  attachmentDetailNode["hasBravaSupport"] = (attachAndAssocNode["hasBravaSupport"].toString().toLowerCase() == "true") ? true : false;
                  attachmentDetailNode["DocumentId"] = attachAndAssocNode["docId"].toString();
                  attachmentDetailNode["attachedBy"] = attachAndAssocNode["attachedByName"].toString();
                  attachmentDetailNode["PublisherUserId"] = int.tryParse(attachAndAssocNode["attachedById"].toString().plainValue()) ?? 0;
                  String strFileSize = attachAndAssocNode["fileSize"].toString();
                  List<String> strFileVect = strFileSize.split(" ");
                  if (strFileVect.length == 2) {
                    int lSize = int.tryParse(strFileVect[0].toString()) ?? 0;
                    if (lSize > 0) {
                      if (strFileVect[1].toUpperCase() == "KB") {
                        lSize = lSize * 1000;
                      } else if (strFileVect[1].toUpperCase() == "MB") {
                        lSize = lSize * 1000 * 1000;
                      } else if (strFileVect[1].toUpperCase() == "GB") {
                        lSize = lSize * 1000 * 1000 * 1000;
                      }
                    }
                    attachmentDetailNode["FileSize"] = lSize;
                  } else {
                    attachmentDetailNode["FileSize"] = strFileSize;
                  }
                  attachmentDetailNode["attachedDate"] = attachAndAssocNode["attachedDate"].toString();
                  try {
                    attachmentDetailNode["attachFilePath"] = attachAndAssocNode["attachFilePath"].toString();
                  } catch (e) {}
                  if (attachAndAssocNode["OfflineAttachFilePath"].toString() != "") {
                    attachmentDetailNode["OfflineAttachFilePath"] = attachAndAssocNode["OfflineAttachFilePath"].toString();
                  }
                  AttachmentArrayNode.add(attachmentDetailNode);
                }
                break;
              case EAttachmentAndAssociationType.references:
                {}
                break;
              case EAttachmentAndAssociationType.views:
                {}
                break;
              case EAttachmentAndAssociationType.lists:
                {}
                break;
              default:
                {}
                break;
            }
          }
        } catch (e, stacktrace) {
          Log.d("SiteFormListingLocalDataSource getCommonEditDraftAttachAndAssocList inner exception $e");
          Log.d("SiteFormListingLocalDataSource getCommonEditDraftAttachAndAssocList inner exception $stacktrace");
        }

        if (AttachmentArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["attachFilesobj"] = AttachmentArrayNode;
        }
        if (AssocFileArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["assocDocsObj"] = AssocFileArrayNode;
        }
        if (AssocFormArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["assocCommsObj"] = AssocFormArrayNode;
        }
        if (AssocComArrayNode.isNotEmpty) {
          pAttachAndAssocListNode["assocDiscussObj"] = AssocComArrayNode;
        }

        pAttachAndAssocListNode["viewName"] = "null";
        pAttachAndAssocListNode["listName"] = "null";
      }
    } catch (e, stacktrace) {
      Log.d("SiteFormListingLocalDataSource getCommonEditDraftAttachAndAssocList exception $e");
      Log.d("SiteFormListingLocalDataSource getCommonEditDraftAttachAndAssocList exception $stacktrace");
    }
    return jsonEncode(pAttachAndAssocListNode);
  }

  Map<String, dynamic> getActionNodeFromActionList(List actionListNode, String strActionId) {
    Map<String, dynamic> actionNode = {};
    try {
      for (var actionNodeTmp in actionListNode) {
        if (actionNodeTmp["actionID"].toString().plainValue() == strActionId.plainValue()) {
          actionNode = actionNodeTmp;
          break;
        }
      }
    } catch (e, stacktrace) {
      Log.d("SiteFormListingLocalDataSource getActionNodeFromActionList exception $e");
      Log.d("SiteFormListingLocalDataSource getActionNodeFromActionList exception $stacktrace");
    }
    return actionNode;
  }

  String getOfflineProjectListJson(Map<String, dynamic> request) {
    List<Map<String, dynamic>> projectList = [];
    String? strProjectIds = request['projectId'].toString();
    if (!strProjectIds.isNullOrEmpty()) {
      String selectQuery = "SELECT * FROM\n"
          "${ProjectDao.tableName} \n"
          "WHERE StatusId <>${EProjectStatus.archived.value}\n"
          "AND \n"
          "ProjectId IN ($strProjectIds)";
      Log.d("FormLocalDataSource::getOfflineProjectListJson query=$selectQuery");
      var mapOfProjectList = databaseManager.executeSelectFromTable(ProjectDao.tableName, selectQuery);
      Log.d("FormLocalDataSource::getOfflineProjectListJson mapOfLocationList.size=${mapOfProjectList.length}");
      for (var element in mapOfProjectList) {
        Map<String, dynamic> projectMap = {};
        projectMap["isMarkOffline"] = (element["IsMarkOffline"] == 1) ? true : false;
        projectMap["canRemoveOffline"] = (element["CanRemoveOffline"] == 1) ? true : false;
        projectMap["isUserAdminforProj"] = (element["IsUserAdminforProject"] == 1) ? true : false;
        projectMap["bimEnabled"] = (element["BimEnabled"] == 1) ? true : false;
        projectMap["isFavorite"] = (element["IsFavorite"] == 1) ? true : false;
        projectMap["canAssignApps"] = (element["CanAssignApps"] == 1) ? true : false;
        projectMap["isAdminAccess"] = (element["IsAdminAccess"] == 1) ? true : false;
        projectMap["dcId"] = element["DC_Id"];
        projectMap["ownerOrgId"] = element["OwnerOrgId"];
        projectMap["projectsubscriptiontypeid"] = element["ProjectSubscriptionTypeId"];
        projectMap["projectID"] = element["ProjectId"];
        projectMap["projectName"] = element["ProjectName"];
        projectMap["projectAdmins"] = element["ProjectAdmins"];
        projectMap["privilege"] = element["Privilege"];
        projectMap["projectLogoPath"] = element["ProjectLogoPath"];
        projectMap["logoUpdateDateTime"] = element["LogoUpdateDateTime"];
        projectMap["iProjectId"] = 0;
        projectMap["parentId"] = -1;
        projectMap["isWorkspace"] = 1;
        projectMap["projectBaseUrl"] = "";
        projectMap["projectBaseUrlForCollab"] = "";
        projectMap["canManageWorkspaceRoles"] = false;
        projectMap["canManageWorkspaceFormStatus"] = false;
        projectMap["isFromExchange"] = false;
        projectMap["space_type_id"] = "1";
        projectMap["isTemplate"] = false;
        projectMap["isCloned"] = false;
        projectMap["activeFilesCount"] = 0;
        projectMap["formsCount"] = 0;
        projectMap["statusId"] = 0;
        projectMap["users"] = 0;
        projectMap["fetchRuleId"] = 0;
        projectMap["canManageWorkspaceDocStatus"] = false;
        projectMap["canCreateAutoFetchRule"] = false;
        projectMap["canManagePurposeOfIssue"] = false;
        projectMap["canManageMailBox"] = false;
        projectMap["editWorkspaceFormSettings"] = false;
        projectMap["canManageDistributionGroup"] = false;
        projectMap["defaultpermissiontypeid"] = 0;
        projectMap["checkoutPref"] = false;
        projectMap["restrictDownloadOnCheckout"] = false;
        projectMap["canManageAppSetting"] = false;
        projectMap["isAdminAccess"] = false;
        projectMap["isUseAccess"] = false;
        projectMap["canManageWorkflowRules"] = false;
        projectMap["canAccessAuditInformation"] = true;
        projectMap["countryId"] = 0;
        projectMap["generateURI"] = true;
        projectList.add(projectMap);
      }
    }
    return jsonEncode(projectList);
  }

  String getOfflineLocationListJson(Map<String, dynamic> request) {
    List<Map<String, dynamic>> locationList = [];
    String? strProjectIds = request["projectId"];
    String strFolderIds = (request["folderId"] ?? "0").toString().plainValue();
    String? strIsThumbnail = request["isThumbnail"];
    String selectQuery = "SELECT locTbl.ProjectId AS projectId, locTbl.FolderId AS folderId,locTbl.LocationId AS locationId, locTbl.LocationTitle AS folder_title, locTbl.IsActive AS isActive, locTbl.LocationPath AS baseFilePath,\n"
        "locTbl.PermissionValue AS permission_value, locTbl.LocationPath AS folderPath, locTbl.IsPublic AS isPublic, locTbl.HasSubFolder AS hasSubFolder, locTbl.IsFavorite AS isFavourite,\n"
        "locTbl.ParentFolderId AS parentFolderId, locTbl.SiteId AS siteId, locTbl.IsSite AS isSite, locTbl.ParentLocationId AS parentLocationId, locTbl.DocumentId AS docId, locTbl.RevisionId AS revisionId,\n"
        "locTbl.IsFileUploaded AS isFileUploaded, locTbl.AnnotationId AS annotationId, locTbl.LocationCoordinate AS locationCoordinates,locTbl.IsCalibrated AS isCalibrated,\n"
        "locTbl.IsMarkOffline AS isMarkOffline, locTbl.CanRemoveOffline AS canRemoveOffline, locTbl.SyncStatus AS lastSyncStatus, locTbl.PageNumber AS pageNumber\n"
        "FROM ${LocationDao.tableName} locTbl";
    if (!strProjectIds.isNullOrEmpty()) {
      if (strProjectIds!.contains(",")) {
        selectQuery = "$selectQuery WHERE locTbl.ProjectId IN ($strProjectIds)";
      } else {
        selectQuery = "$selectQuery WHERE locTbl.ProjectId=$strProjectIds";
        if (strFolderIds.isNotEmpty) {
          if (strFolderIds == "0") {
            selectQuery = "$selectQuery AND locTbl.ParentLocationId=0";
          } else {
            selectQuery = "$selectQuery AND locTbl.ParentFolderId=$strFolderIds";
          }
        }
      }
      selectQuery = "$selectQuery AND locTbl.IsActive=1";
    } else {
      selectQuery = "$selectQuery WHERE locTbl.IsActive=1";
    }
    selectQuery = "$selectQuery ORDER BY locTbl.LocationTitle COLLATE NOCASE ASC";
    Log.d("FormLocalDataSource::getOfflineLocationListJson query=$selectQuery");
    var mapOfLocationList = databaseManager.executeSelectFromTable(LocationDao.tableName, selectQuery);
    Log.d("FormLocalDataSource::getOfflineLocationListJson mapOfLocationList.size=${mapOfLocationList.length}");
    for (var locationItem in mapOfLocationList) {
      Map<String, dynamic> locationMap = {};
      String tmpLocationId = locationItem["locationId"].toString();
      String tmpProjectId = locationItem["projectId"].toString();
      locationMap["permission_value"] = locationItem["permission_value"];
      locationMap["isActive"] = locationItem["isActive"];
      locationMap["parentFolderId"] = locationItem["parentFolderId"];
      locationMap["lastSyncStatus"] = locationItem["lastSyncStatus"];
      locationMap["isPublic"] = locationItem["isPublic"] == 1 ? true : false;
      locationMap["hasSubFolder"] = locationItem["hasSubFolder"] == 1 ? true : false;
      locationMap["isFavourite"] = locationItem["isFavourite"] == 1 ? true : false;
      locationMap["isMarkOffline"] = locationItem["isMarkOffline"] == 1 ? true : false;
      locationMap["canRemoveOffline"] = locationItem["canRemoveOffline"] == 1 ? true : false;
      locationMap["folder_title"] = locationItem["folder_title"];
      locationMap["baseFilePath"] = locationItem["baseFilePath"];
      locationMap["folderPath"] = locationItem["baseFilePath"];
      locationMap["folderId"] = locationItem["folderId"];
      locationMap["projectId"] = locationItem["projectId"];
      locationMap["folderPublishPrivateRevPref"] = 0;
      locationMap["clonedFolderId"] = 0;
      locationMap["fetchRuleId"] = 0;
      locationMap["includePublicSubFolder"] = false;
      locationMap["isPFLocationTree"] = true;
      locationMap["generateURI"] = true;
      Map<String, dynamic> locationNodeMap = {};

      locationNodeMap["locationId"] = locationItem["locationId"];
      locationNodeMap["siteId"] = locationItem["siteId"];
      locationNodeMap["parentLocationId"] = locationItem["parentLocationId"];
      locationNodeMap["pageNumber"] = locationItem["pageNumber"];
      locationNodeMap["isSite"] = locationItem["isSite"] == "1" ? true : false;
      locationNodeMap["isFileUploaded"] = locationItem["isFileUploaded"] == "1" ? true : false;
      locationNodeMap["isCalibrated"] = locationItem["isCalibrated"] == "1" ? true : false;
      locationNodeMap["docId"] = locationItem["docId"];
      locationNodeMap["revisionId"] = locationItem["revisionId"];
      locationNodeMap["annotationId"] = locationItem["annotationId"];
      locationNodeMap["locationCoordinates"] = locationItem["locationCoordinates"];
      if (strIsThumbnail.isNullOrEmpty()) {
        String locationStatusQuery = "SELECT statusTable.StatusId AS statusId, statusTable.StatusName AS statusName, statusTable.FontColor AS fontColor, statusTable.BackgroundColor AS bgColor,";
        locationStatusQuery = "${locationStatusQuery}statusTable.StatusTypeId AS statusTypeId, locationTable.StatusCount AS statusCount FROM ";
        locationStatusQuery = "$locationStatusQuery ${LocationDao.tableName} locationTable INNER JOIN ${StatusStyleListDao.tableName} statusTable";
        locationStatusQuery = "$locationStatusQuery ON locationTable.ProjectId = statusTable.ProjectId AND locationTable.StatusId = statusTable.StatusId";
        locationStatusQuery = "$locationStatusQuery AND locationTable.ProjectId = $tmpProjectId";
        locationStatusQuery = "$locationStatusQuery AND locationTable.LocationId = $tmpLocationId";
        Log.d("FormLocalDataSource::getOfflineLocationListJson locationStatusQuery $locationStatusQuery");
        var mapOfLocationStatusList = databaseManager.executeSelectFromTable(StatusStyleListDao.tableName, locationStatusQuery);
        Log.d("FormLocalDataSource::getOfflineLocationListJson locationStatusSize ${mapOfLocationStatusList.length}");
        List<Map<String, dynamic>> locationStatusList = [];
        for (var locationStatusItem in mapOfLocationStatusList) {
          Map<String, dynamic> locationStatusMap = {};
          locationStatusMap["statusId"] = locationStatusItem["statusId"];
          locationStatusMap["statusTypeId"] = locationStatusItem["statusTypeId"];
          locationStatusMap["statusCount"] = locationStatusItem["statusCount"];
          locationStatusMap["statusName"] = locationStatusItem["statusName"];
          locationStatusMap["bgColor"] = locationStatusItem["bgColor"];
          locationStatusMap["fontColor"] = locationStatusItem["fontColor"];
          locationStatusMap["generateURI"] = true;
          locationStatusList.add(locationStatusMap);
        }
        locationNodeMap["statusCountList"] = locationStatusList;
      }
      locationNodeMap["generateURI"] = true;
      locationMap["childfolderTreeVOList"] = List.empty();
      locationMap["pfLocationTreeDetail"] = locationNodeMap;
      locationList.add(locationMap);
    }
    return jsonEncode(locationList);
  }

  String getFieldAssociateSearchLocationList(Map<String, dynamic> request) {
    Map<String, dynamic> responseParentNodeMap = {};
    try {
      String strProjectId = request["selectedProjectIds"] ?? "";
      String strSearchValue = request["searchValue"] ?? "";
      String selectQuery = "SELECT (FolderId||'#'||ProjectId) AS Id, LocationPath AS Value FROM LocationDetailTbl\n"
          "WHERE ProjectId=$strProjectId";
      if (strSearchValue != "") {
        strSearchValue = strSearchValue.replaceAll("'", "''");
        if (strSearchValue.contains("_")) {
          strSearchValue = strSearchValue.replaceAll("_", "^_");
          selectQuery = "$selectQuery AND LocationTitle LIKE ('%$strSearchValue%') escape '^'";
        } else {
          selectQuery = "$selectQuery AND LocationTitle LIKE ('%$strSearchValue%')";
        }
      }
      selectQuery = "$selectQuery ORDER BY Value COLLATE NOCASE ASC";
      Log.d("FormLocalDataSource::getFieldAssociateSearchLocationList query=$selectQuery");
      var mapOfSearchLocationList = databaseManager.executeSelectFromTable(ProjectDao.tableName, selectQuery);
      Log.d("FormLocalDataSource::getFieldAssociateSearchLocationList mapOfSearchLocationList.size=${mapOfSearchLocationList.length}");
      responseParentNodeMap["totalDocs"] = mapOfSearchLocationList.length;
      responseParentNodeMap["recordBatchSize"] = 0;
      List<Map<String, dynamic>> searchList = [];
      for (var element in mapOfSearchLocationList) {
        Map<String, dynamic> childNodeMap = {};
        childNodeMap["id"] = element["Id"].toString();
        childNodeMap["value"] = element["Value"].toString();
        childNodeMap["dataCenterId"] = 0;
        childNodeMap["isSelected"] = false;
        childNodeMap["imgId"] = -1;
        childNodeMap["isActive"] = true;
        searchList.add(childNodeMap);
      }
      responseParentNodeMap["data"] = searchList;
      responseParentNodeMap["isSortRequired"] = true;
      responseParentNodeMap["generateURI"] = true;
    } catch (e) {
      Log.d("FormLocalDataSource::getFieldAssociateSearchLocationList Error $e");
    }
    return jsonEncode(responseParentNodeMap);
  }

  String getFieldAssociateSearchLocationSelectTreeList(Map<String, dynamic> request) {
    var projectListResponse = jsonDecode(getOfflineProjectListJson(request));
    try {
      if (projectListResponse is List && projectListResponse.isNotEmpty) {
        String projectId = request["projectId"];
        String folderId = request["folder_id"];
        String selectQuery = "WITH ParentLocation AS (\n"
            "SELECT ProjectId,LocationId,ParentLocationId,FolderId,0 AS TreeLevel FROM ${LocationDao.tableName}\n"
            "WHERE ProjectId=$projectId AND FolderId IN($folderId)\n"
            "UNION ALL\n"
            "SELECT locTbl.ProjectId,locTbl.LocationId,locTbl.ParentLocationId,locTbl.FolderId,prntLoc.TreeLevel + 1 AS TreeLevel FROM ${LocationDao.tableName} locTbl\n"
            "INNER JOIN ParentLocation prntLoc ON prntLoc.ProjectId=locTbl.ProjectId AND prntLoc.ParentLocationId=locTbl.LocationId\n"
            ")\n"
            "SELECT FolderId FROM ParentLocation ORDER BY TreeLevel DESC";
        Log.d("FormLocalDataSource::getFieldAssociateSearchLocationSelectTreeList query=$selectQuery");
        var parentFolderIdList = databaseManager.executeSelectFromTable(LocationDao.tableName, selectQuery);
        List<String> folderList = [];
        for (var element in parentFolderIdList) {
          folderList.add(element['FolderId']);
        }
        Log.d("FormLocalDataSource::getFieldAssociateSearchLocationSelectTreeList parentFolderIdList.size=${parentFolderIdList.length}");
        var childLocationList = jsonDecode(getChildLocationList(projectId: projectId, folderId: "0", folderIdList: folderList));
        projectListResponse[0]['childfolderTreeVOList'] = childLocationList;
      }
    } catch (e) {
      Log.d("FormLocalDataSource::getFieldAssociateSearchLocationSelectTreeList Error=$e");
    }
    return jsonEncode(projectListResponse);
  }

  String getChildLocationList({required String projectId, required String folderId, required List<String> folderIdList}) {
    var childFolderTreeVOList = jsonDecode(getOfflineLocationListJson({"projectId": projectId, "folderId": folderId}));
    try {
      if (childFolderTreeVOList is List) {
        for (var element in childFolderTreeVOList) {
          String tempFolderId = element['folderId'];
          if (!folderIdList.last.contains(tempFolderId)) {
            var tempChildFolderTreeVOList = jsonDecode(getChildLocationList(projectId: projectId, folderId: tempFolderId, folderIdList: folderIdList));
            element['childfolderTreeVOList'] = tempChildFolderTreeVOList;
          }
        }
      }
    } catch (e) {
      Log.d("FormLocalDataSource::getChildLocationList Error=$e");
    }
    return jsonEncode(childFolderTreeVOList);
  }

  List<String> getInlineAttachmentRevisionIdList(Map<String, dynamic> strJsonData) {
    List<String> listRevisionIds = [];
    if (strJsonData.isNotEmpty && strJsonData["myFields"] != null) {
      Map myFields = strJsonData["myFields"];
      if (myFields.containsKey('attachment_fields')) {
        String? strValue = myFields["attachment_fields"];
        if (!strValue!.isNullOrEmpty()) {
          List<String> keyList = strValue.split('#');
          _getInlineAttachmentRevisionIdList(strJsonData, keyList, listRevisionIds);
        }
      }
    }
    return listRevisionIds;
  }

  void _getInlineAttachmentRevisionIdList(Map<String, dynamic> jsonNode, List<String> keyList, List<String> listOfRevisionId) {
    switch (jsonNode.runtimeType) {
      case List:
        {
          for (var jIt = jsonNode[0]; jIt != jsonNode.length; ++jIt) {
            _getInlineAttachmentRevisionIdList(jIt, keyList, listOfRevisionId);
          }
        }
        break;
      case Map:
        {
          for (var jIt = jsonNode[0]; jIt != jsonNode.length; ++jIt) {
            if (jIt.key() == "content") {
              if (jsonNode.containsKey("@inline")) {
                String strKeyName = jsonNode["@inline"].toString();
                bool containsKey = keyList.contains(strKeyName);
                if (containsKey) {
                  String strValueSplitChar = "#";
                  List<String> listOfValueData = jIt.toString().split(strValueSplitChar);
                  if (listOfValueData.length > 5) {
                    listOfRevisionId.add(listOfValueData[5].plainValue());
                  }
                }
              }
            }
            _getInlineAttachmentRevisionIdList(jIt, keyList, listOfRevisionId);
          }
        }
        break;
    }
  }

  String getFormMessageInlineAttachmentContentValue(String strTableName, String strOldValue, String strKeyName) {
    String strContentValue = strOldValue;
    if (strOldValue.isNotEmpty) {
      List<String> oldValueDataList = strOldValue.split('#');
      if (oldValueDataList.length > 5) {
        String strAttachQuery = "SELECT ProjectId,FormTypeId,MsgId,AttachRevId,AssocDocRevisionId,AttachmentType,AttachAssocDetailJson FROM $strTableName";
        strAttachQuery = "$strAttachQuery WHERE ProjectId=${oldValueDataList[0]}";
        strAttachQuery = "$strAttachQuery AND MsgId=${oldValueDataList[2]}";
        strAttachQuery = "$strAttachQuery AND (AttachRevId=${oldValueDataList[5].plainValue()} OR AssocDocRevisionId=${oldValueDataList[5].plainValue()})";
        var inlineAttachmentList = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery);
        if (inlineAttachmentList.isNotEmpty) {
          String strKeyName1 = strKeyName.split(':')[0];
          var AttachRow = inlineAttachmentList[0];
          String strFilename = "", strRevId = "";

          EAttachmentAndAssociationType attachmentType = EAttachmentAndAssociationType.fromString(AttachRow["AttachmentType"]);
          switch (attachmentType) {
            case EAttachmentAndAssociationType.attachments:
              {
                strFilename = jsonDecode(AttachRow["AttachAssocDetailJson"])["fileName"].toString();
                strRevId = AttachRow["AttachRevId"];
              }
              break;
            case EAttachmentAndAssociationType.files:
              {
                strFilename = jsonDecode(AttachRow["AttachAssocDetailJson"])["uploadFileName"].toString();
                strRevId = AttachRow["AssocDocRevisionId"];
              }
              break;
            default:
              break;
          }
          strContentValue = AttachRow["ProjectId"] + "#" + AttachRow["FormTypeId"] + "#" + AttachRow["MsgId"] + "#" + AttachRow["MsgId"] + "_" + strKeyName1 + "#" + AttachRow["MsgId"] + "_" + strKeyName1 + "_" + strFilename + "#" + strRevId;
        }
      }
    }
    return strContentValue;
  }

  String getFormMessageInlineAttachmentFilename(String strTableName, String projectId, String revisionId) {
    String fileName = "";
    projectId = projectId.plainValue();
    revisionId = revisionId.plainValue();
    if (projectId.isNotEmpty && revisionId.isNotEmpty) {
      String strAttachQuery = "SELECT AttachmentType,AttachAssocDetailJson,AttachFileName FROM $strTableName";
      strAttachQuery = "$strAttachQuery WHERE ProjectId=$projectId";
      strAttachQuery = "$strAttachQuery AND (AttachRevId=$revisionId OR AssocDocRevisionId=$revisionId)";
      var inlineAttachmentList = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery);
      if (inlineAttachmentList.isNotEmpty) {
        var attachRow = inlineAttachmentList.first;
        EAttachmentAndAssociationType attachmentType = EAttachmentAndAssociationType.fromString(attachRow["AttachmentType"]);
        switch (attachmentType) {
          case EAttachmentAndAssociationType.attachments:
            fileName = jsonDecode(attachRow["AttachAssocDetailJson"])["fileName"].toString();
            break;
          case EAttachmentAndAssociationType.files:
            fileName = jsonDecode(attachRow["AttachAssocDetailJson"])["uploadFileName"].toString();
            break;
          default:
            break;
        }
      }
    }
    return fileName;
  }

  Future<String> getInlineAttachmentServerRequestData(String strJson, Function returnValueCallback) async {
    List arrInlineAttDetailsList = [];
    List arrInlineAttReqParamList = [];
    Map arrInlineAttUploadPath = {};
    var jsonDataNode = jsonDecode(strJson);
    jsonDataNode = await _getInlineAttachmentServerRequestData(
        jsonNode: jsonDataNode,
        inlineAttDetailsListCallback: (dynamic inlineAttDetailsList) {
          arrInlineAttDetailsList.add(inlineAttDetailsList);
        },
        inlineAttReqParamListCallback: (dynamic inlineAttReqParamList) {
          arrInlineAttReqParamList.add(inlineAttReqParamList);
        },
        inlineAttUploadPathCallback: (dynamic inlineAttUploadPath) {

          arrInlineAttUploadPath.addAll(inlineAttUploadPath);
        },
        getFilenameCallback: (String strProjectId, String strRevId) async {
          return await getFormMessageInlineAttachmentFilename(FormMessageAttachAndAssocDao.tableName, strProjectId, strRevId);
        });
    if (arrInlineAttReqParamList.isNotEmpty) {
      String strInlineAttDetailsList = "";
      String strInlineAttReqParamList = jsonEncode(arrInlineAttReqParamList);
      if (arrInlineAttDetailsList.isNotEmpty) {
        strJson = jsonEncode(jsonDataNode);
        strInlineAttDetailsList = jsonEncode(arrInlineAttDetailsList);
      }
      await returnValueCallback(strInlineAttDetailsList, strInlineAttReqParamList, arrInlineAttUploadPath);
    }
    return strJson;
  }

  Future<dynamic> _getInlineAttachmentServerRequestData({required dynamic jsonNode, required Function inlineAttDetailsListCallback, required Function inlineAttReqParamListCallback, required Function inlineAttUploadPathCallback, required Function getFilenameCallback}) async {
    if (jsonNode is List) {
      for (int i = 0; i < jsonNode.length; i++) {
        jsonNode[i] = await _getInlineAttachmentServerRequestData(jsonNode: jsonNode[i], inlineAttDetailsListCallback: inlineAttDetailsListCallback, inlineAttReqParamListCallback: inlineAttReqParamListCallback, inlineAttUploadPathCallback: inlineAttUploadPathCallback, getFilenameCallback: getFilenameCallback);
      }
    } else if (jsonNode is Map) {
      for (var entry in jsonNode.entries) {
        var key = entry.key;
        var value = entry.value;
        if (key.toString() == "content") {
          if (jsonNode.containsKey("@inline")) {
            String strKeyName = jsonNode["@inline"].toString();
            String strContent = value.toString();
            String fixInlineAttPath = "C:/fakePath/";
            String fixInlineAttPathPrefix = "xdInlineFile:/";
            String fixInlineAttUpFilePrefix = "inlineUpFile_attchment_";
            String fixInlineAttachementPrefix = "attchment_";
            if (jsonNode.containsKey("OfflineContent")) {
              String strUploadFilePath = jsonNode["OfflineContent"]["upFilePath"].toString();
              int iFileType = jsonNode["OfflineContent"]["fileType"];
              bool bIsThumbnameSupports = jsonNode["OfflineContent"]["isThumbnailSupports"];
              var inlineAttDetailNode = {};
              var inlineAttReqParamNode = {};
              var vecValueData = strKeyName.split(":");
              String fileName = strUploadFilePath.split("/").last;
              if (vecValueData.length >= 2) {
                inlineAttDetailNode["fieldId"] = "$fixInlineAttachementPrefix${vecValueData[0]}";
                inlineAttReqParamNode["$fixInlineAttachementPrefix${vecValueData[0]}"] = "$fixInlineAttPath$fileName";
                inlineAttReqParamNode[strKeyName] = "$fixInlineAttPathPrefix$fileName";
                if (bIsThumbnameSupports == true) {
                  inlineAttReqParamNode["isThumbnailSupports"] = bIsThumbnameSupports;
                }
                await inlineAttUploadPathCallback({"$fixInlineAttUpFilePrefix${vecValueData[0]}": strUploadFilePath});
              }
              inlineAttDetailNode["fileType"] = iFileType;
              if (bIsThumbnameSupports == true) {
                inlineAttDetailNode["isThumbnailSupports"] = bIsThumbnameSupports;
              }
              inlineAttDetailNode["fileName"] = fileName;
              inlineAttDetailNode["fileSize"] = getFileSizeSync(strUploadFilePath);
              await inlineAttDetailsListCallback(inlineAttDetailNode);
              await inlineAttReqParamListCallback(inlineAttReqParamNode);
              jsonNode.remove("OfflineContent");
              jsonNode["content"] = "";
              break;
            } else if (strContent.isNotEmpty) {
              var contentList = strContent.split("#");
              String strProjectId = contentList[0];
              String strRevisionId = contentList[5];
              String strCombineKey = strKeyName.split(":")[0];
              String strFileName = await getFilenameCallback(strProjectId, strRevisionId);
              var inlineAttReqParamNode = {
                "$fixInlineAttachementPrefix$strCombineKey": "#REV#$strRevisionId",
                strKeyName: "$fixInlineAttPathPrefix$strFileName",
              };
              await inlineAttReqParamListCallback(inlineAttReqParamNode);
            }
          }
        } else {
          jsonNode[key] = await _getInlineAttachmentServerRequestData(jsonNode: jsonNode[key], inlineAttDetailsListCallback: inlineAttDetailsListCallback, inlineAttReqParamListCallback: inlineAttReqParamListCallback, inlineAttUploadPathCallback: inlineAttUploadPathCallback, getFilenameCallback: getFilenameCallback);
        }
      }
    }
    return jsonNode;
  }

  Future<String> getDistributionList(Map<String, dynamic> request) async {
    String response = "";
    try {
      String projectId = request['projectId'];
      String formTypeId = request['formTypeId'];
      String path = await AppPathHelper().getFormTypeDistributionFilePath(projectId: projectId, formTypeId: formTypeId);
      response = readFromFile(path);
    } catch (e) {
      Log.d("FormLocalDataSource::getDistributionList Error=$e");
    }
    return response;
  }

  Future<bool> getFormDistributionDataFromDistList({required String projectId, required String formTypeId, required String jsonData, required Function onReturnReferences}) async {
    bool isSuccess = false;
    String distributionData = await getDistributionList({"projectId": projectId, "formTypeId": formTypeId});
    if (distributionData.isNotEmpty && jsonData.isNotEmpty) {
      try {
        var formTypeDistListNode = jsonDecode(distributionData);
        var userListNode = formTypeDistListNode["distData"]["userList"];
        var actionListNode = formTypeDistListNode["distData"]["actionList"];

        var distListNode = jsonDecode(jsonDecode(jsonData)["myFields"]?["dist_list"]?.toString() ?? "{}");

        List<dynamic> distActionListNode = [], distNameListNode = [];

        //selected distribution group handle
        String selectedDistGroups = distListNode["selectedDistGroups"]?.toString() ?? "";
        if (selectedDistGroups.isNotEmpty) {
          List<String> selectedDistGroupsList = selectedDistGroups.split(",");
          List groupuserListNode = formTypeDistListNode["distData"]?["groupuserList"] ?? [];
          for (var groupuserNode in groupuserListNode) {
            String distGroupId = groupuserNode["distGroupId"]?.toString().plainValue() ?? "";
            if (selectedDistGroupsList.contains(distGroupId)) {
              String distUserName = "${groupuserNode["fname"].toString()} ${groupuserNode["lname"].toString()}, ${groupuserNode["orgName"].toString()}";
              distNameListNode.add(distUserName);

              var distActionNode = {
                "actionID": groupuserNode["actionID"].toString(),
                "userID": groupuserNode["userID"].toString(),
                "actionDueDate": "", //groupuserNode["actionDueDate"].toString(),
                "userOrgName": groupuserNode["orgName"].toString(),
                "fname": groupuserNode["fname"].toString(),
                "lname": groupuserNode["lname"].toString(),
                "actionName": groupuserNode["actionName"].toString(),
                "emailId": groupuserNode["emailId"].toString(),
                "userImageName": groupuserNode["userImageName"].toString(),
                "isSendNotification": false,
                "userCannotOverrideNotification": false,
                "user_type": int.tryParse(groupuserNode["user_type"].toString()) ?? 0,
                "projectId": projectId,
                //"actionDueDateForLocale": groupuserNode["defaultActionDueDate"].toString(),
                "dueDays": int.tryParse(groupuserNode["defaultDays"].toString()) ?? 0,
                "distListId": 0,
                "generateURI": false,
              };
              distActionListNode.add(distActionNode);
            }
          }
        }

        //selected distribution orgs handle
        List selectedDistOrgsListNode = distListNode["selectedDistOrgs"] ?? [];
        for (var selectedDistOrgsNode in selectedDistOrgsListNode) {
          Map distOrgActionNode = getActionNodeFromActionList(actionListNode, selectedDistOrgsNode["hActionID"].toString().plainValue());
          if (distOrgActionNode.isNotEmpty) {
            for (var userNode in userListNode) {
              if (selectedDistOrgsNode["hOrgID"].toString().plainValue() == userNode["orgID"].toString().plainValue()) {
                String distUserName = "${userNode["userName"].toString()}, ${userNode["orgName"].toString()}";
                distNameListNode.add(distUserName);

                var distActionNode = {
                  "actionID": distOrgActionNode["actionID"].toString(),
                  "userID": userNode["userID"].toString(),
                  "actionDueDate": selectedDistOrgsNode["actionDueDate"].toString(),
                  "userOrgName": userNode["orgName"].toString(),
                  "fname": userNode["fname"].toString(),
                  "lname": userNode["lname"].toString(),
                  "actionName": distOrgActionNode["actionName"].toString(),
                  "emailId": userNode["emailId"].toString(),
                  "userImageName": userNode["userImageName"].toString(),
                  "isSendNotification": false,
                  "userCannotOverrideNotification": false,
                  "user_type": int.tryParse(userNode["userTypeId"].toString()) ?? 0,
                  "projectId": projectId,
                  "actionDueDateForLocale": selectedDistOrgsNode["actionDueDate"].toString(),
                  "dueDays": int.tryParse(distOrgActionNode["num_days"].toString()) ?? 0,
                  "distListId": 0,
                  "generateURI": false,
                };
                distActionListNode.add(distActionNode);
              }
            }
          }
        }

        //selected distribution roles handle
        List selectedDistRolesListNode = distListNode["selectedDistRoles"] ?? [];
        if (selectedDistRolesListNode.isNotEmpty) {
          List systemRoleTOListNode = formTypeDistListNode["distData"]?["systemRoleTOList"] ?? [];
          for (var selectedDistRolesNode in selectedDistRolesListNode) {
            Map distOrgActionNode = getActionNodeFromActionList(actionListNode, selectedDistRolesNode["hActionID"].toString().plainValue());
            if (distOrgActionNode.isNotEmpty) {
              for (var systemRoleTONode in systemRoleTOListNode) {
                if (systemRoleTONode["workspaceRoleTO"]["roleId"].toString().plainValue() == selectedDistRolesNode["hRoleID"].toString().plainValue()) {
                  List permissionVOListNode = systemRoleTONode["workspaceRoleTO"]?["permissionVOList"] ?? [];
                  for (var userNode in permissionVOListNode) {
                    distNameListNode.add(userNode["name"].toString());

                    var distActionNode = {
                      "actionID": distOrgActionNode["actionID"].toString(),
                      "userID": userNode["hashedId"].toString(),
                      "actionDueDate": selectedDistRolesNode["actionDueDate"].toString(),
                      "userOrgName": userNode["orgName"].toString(),
                      "fname": userNode["fname"].toString(),
                      "lname": userNode["lname"].toString(),
                      "actionName": distOrgActionNode["actionName"].toString(),
                      "emailId": userNode["emailId"].toString(),
                      "userImageName": userNode["userImageName"].toString(),
                      "isSendNotification": false,
                      "userCannotOverrideNotification": false,
                      "user_type": int.tryParse(userNode["userTypeId"].toString()) ?? 0,
                      "projectId": projectId,
                      "actionDueDateForLocale": selectedDistRolesNode["actionDueDate"].toString(),
                      "dueDays": int.tryParse(distOrgActionNode["num_days"].toString()) ?? 0,
                      "distListId": 0,
                      "generateURI": false,
                    };
                    distActionListNode.add(distActionNode);
                  }
                }
              }
            }
          }
        }

        //selected distribution users handle
        List selectedDistUsersListNode = distListNode["selectedDistUsers"] ?? [];
        for (var selectedDistUsersNode in selectedDistUsersListNode) {
          Map distOrgActionNode = getActionNodeFromActionList(actionListNode, selectedDistUsersNode["hActionID"].toString().plainValue());
          if (distOrgActionNode.isNotEmpty) {
            for (var userNode in userListNode) {
              if (selectedDistUsersNode["hUserID"].toString().plainValue() == userNode["userID"].toString().plainValue()) {
                String distUserName = "${userNode["userName"].toString()}, ${userNode["orgName"].toString()}";
                distNameListNode.add(distUserName);

                var distActionNode = {
                  "actionID": distOrgActionNode["actionID"].toString(),
                  "userID": userNode["userID"].toString(),
                  "actionDueDate": selectedDistUsersNode["actionDueDate"].toString(),
                  "userOrgName": userNode["orgName"].toString(),
                  "fname": userNode["fname"].toString(),
                  "lname": userNode["lname"].toString(),
                  "actionName": distOrgActionNode["actionName"].toString(),
                  "emailId": userNode["emailId"].toString(),
                  "userImageName": userNode["userImageName"].toString(),
                  "isSendNotification": false,
                  "userCannotOverrideNotification": false,
                  "user_type": int.tryParse(userNode["userTypeId"].toString()) ?? 0,
                  "projectId": projectId,
                  "actionDueDateForLocale": selectedDistUsersNode["actionDueDate"].toString(),
                  "dueDays": int.tryParse(distOrgActionNode["num_days"].toString()) ?? 0,
                  "distListId": 0,
                  "generateURI": false,
                };
                distActionListNode.add(distActionNode);
              }
            }
          }
        }

        if (selectedDistGroups.isNotEmpty || selectedDistOrgsListNode.isNotEmpty || selectedDistRolesListNode.isNotEmpty || selectedDistUsersListNode.isNotEmpty) {
          isSuccess = true;
        }
        String strSentNames = "", strUserActionJson = "";
        if (distNameListNode.isNotEmpty) {
          strSentNames = jsonEncode(distNameListNode);
        }
        if (distActionListNode.isNotEmpty) {
          strUserActionJson = jsonEncode(distActionListNode);
        }
        onReturnReferences(strSentNames, strUserActionJson);
      } on Exception catch (e) {
        Log.d("FormLocalDataSource::getFormDistributionDataFromDistList Error=$e");
      }
    }
    return isSuccess;
  }

  Future<bool> isPushToServerData() async {
    bool hasData = false;
    try {
      var result = await getPushToServerFormData();
      hasData = result.isNotEmpty;
    } on Exception catch (e) {
      Log.d("FormLocalDataSource::isPushToServerFormData Error=$e");
    }
    return hasData;
  }

  Future<List<Map<String, dynamic>>> getPushToServerFormData() async {
    List<Map<String, dynamic>> dataList = [];
    try {
      String query = "SELECT * FROM (\n"
          "SELECT ${EOfflineSyncRequestType.CreateOrRespond.value} AS RequestType,${FormMessageDao.projectIdField},${FormMessageDao.formIdField},${FormMessageDao.msgIdField},${FormMessageDao.updatedDateInMSField} FROM ${FormMessageDao.tableName}\n"
          "WHERE OfflineRequestData<>''\n"
          "UNION\n"
          "SELECT ${EOfflineSyncRequestType.StatusChange.value} AS RequestType,${FormStatusHistoryDao.projectId},${FormStatusHistoryDao.formId},${FormStatusHistoryDao.messageId} AS MsgId,${FormStatusHistoryDao.createDateInMS} AS UpdatedDateInMS FROM ${FormStatusHistoryDao.tableName}\n"
          "WHERE ${FormStatusHistoryDao.jsonData}<>''\n"
          "UNION\n"
          "SELECT IIF(${OfflineActivityDao.actionIdField}=6,${EOfflineSyncRequestType.DistributeAction.value},${EOfflineSyncRequestType.OtherAction.value}) AS RequestType,${OfflineActivityDao.projectIdField},${OfflineActivityDao.formIdField},${OfflineActivityDao.msgIdField},${OfflineActivityDao.createdDateInMsField} AS UpdatedDateInMS FROM ${OfflineActivityDao.tableName}\n"
          "WHERE OfflineRequestData<>''\n"
          ")\n"
          "ORDER BY CAST(UpdatedDateInMS AS INTEGER) ASC";
      dataList = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
    } on Exception catch (e) {
      Log.d("FormLocalDataSource::getPushToServerFormData Error=$e");
    }
    return dataList;
  }

  Future<String> getPushToServerRequestData(Map<String, dynamic> paramData) async {
    String requestData = "";
    try {
      EOfflineSyncRequestType eRequestType = EOfflineSyncRequestType.fromString(paramData["RequestType"].toString());
      String projectId = paramData["ProjectId"]?.toString().plainValue() ?? "";
      String formId = paramData["FormId"]?.toString().plainValue() ?? "";
      String msgId = paramData["MsgId"]?.toString().plainValue() ?? "";
      String updatedDateInMS = paramData["UpdatedDateInMS"]?.toString() ?? "";
      String query = "";
      switch (eRequestType) {
        case EOfflineSyncRequestType.CreateOrRespond:
          String requestFilePath = await AppPathHelper().getOfflineRequestDataFilePath(projectId: projectId, msgId: msgId);
          requestData = readFromFile(requestFilePath);
          var requestNode = jsonDecode(requestData);
          requestNode["CreateDateInMS"] = updatedDateInMS;
          if (msgId.isNotEmpty) {
            requestNode["offlineMessageId"] = msgId;
          }
          requestData = jsonEncode(requestNode);
          break;
        case EOfflineSyncRequestType.StatusChange:
          query = "SELECT frmTbl.AppTypeId,frmTbl.LocationId,frmTbl.ObservationId,frmHstrTbl.${FormStatusHistoryDao.jsonData} AS ${FormMessageDao.offlineRequestDataField} FROM ${FormStatusHistoryDao.tableName} frmHstrTbl\n"
              "INNER JOIN ${FormDao.tableName} frmTbl ON frmTbl.ProjectId=frmHstrTbl.ProjectId AND frmTbl.FormId=frmHstrTbl.FormId\n"
              "WHERE frmHstrTbl.${FormStatusHistoryDao.projectId}=$projectId AND frmHstrTbl.${FormStatusHistoryDao.formId}=$formId ${(msgId.isNotEmpty) ? "AND frmHstrTbl.${FormStatusHistoryDao.messageId}=$msgId " : ""}AND frmHstrTbl.${FormStatusHistoryDao.createDateInMS}=$updatedDateInMS";
          break;
        case EOfflineSyncRequestType.DistributeAction:
        case EOfflineSyncRequestType.OtherAction:
          query = "SELECT IFNULL(frmTbl.AppTypeId,'') AS AppTypeId, IFNULL(frmTbl.LocationId,'') AS LocationId, IFNULL(frmTbl.ObservationId,'') AS ObservationId,IFNULL(frmTbl.TemplateType,'') AS TemplateType,offlineActivityTbl.* FROM ${OfflineActivityDao.tableName} offlineActivityTbl\n"
              "LEFT JOIN FormListTbl frmTbl ON OfflineActivityTbl.FormId=frmTbl.FormId\n"
              "WHERE offlineActivityTbl.ProjectId=$projectId AND offlineActivityTbl.FormId=$formId ${(msgId.isNotEmpty) ? " AND offlineActivityTbl.MsgId=$msgId" : ""} AND offlineActivityTbl.CreatedDateInMs=$updatedDateInMS";
          break;
        default:
          break;
      }
      if (query.isNotEmpty) {
        var result = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
        if (result.isNotEmpty) {
          var rowData = (result.first);
          requestData = rowData[FormMessageDao.offlineRequestDataField].toString();
          var requestNode = jsonDecode(requestData);
          if (eRequestType == EOfflineSyncRequestType.StatusChange) {
            requestNode["appTypeId"] = rowData['AppTypeId'];
            requestNode["locationId"] = rowData['LocationId'];
            requestNode["observationId"] = rowData['ObservationId'];
            requestNode["projectIds"] = projectId;
            requestNode["checkHashing"] = "false";
          } else if (eRequestType == EOfflineSyncRequestType.DistributeAction) {
            requestNode["appTypeId"] = rowData['AppTypeId'];
            requestNode["formTypeId"] = rowData['FormTypeId'];
            requestNode["form_type_id"] = rowData['FormTypeId'];
            requestNode["form_template_type"] = rowData['TemplateType'];
            requestNode["locationId"] = rowData['LocationId'];
            requestNode["observationId"] = rowData['ObservationId'];
            requestNode["projectIds"] = projectId;
            requestNode["checkHashing"] = "false";
          }
          requestNode["CreateDateInMS"] = updatedDateInMS;
          if (msgId.isNotEmpty) {
            requestNode["offlineMessageId"] = msgId;
          }
          requestData = jsonEncode(requestNode);
        }
      }
    } on Exception catch (e) {
      Log.d("FormLocalDataSource::getPushToServerRequestData Error=$e");
    }
    return requestData;
  }

  Future<bool> updateOfflineCreatedOrRespondedFormData({required Map<String, dynamic> paramData, required Map<String, dynamic> requestData, required SiteForm frmVO, required List<FormMessageVO> frmMsgList, required List<SiteFormAction> frmMsgActList, required List<FormMessageAttachAndAssocVO> frmMsgAttachList, required List<String> inlineRevisionIdList}) async {
    bool isSuccess = false;
    try {
      String formId = requestData["offlineFormId"]?.toString() ?? requestData["formId"]?.toString() ?? "";
      if (frmMsgAttachList.isNotEmpty) {
        String attachQuery = "SELECT * FROM ${FormMessageAttachAndAssocDao.tableName}\n"
            "WHERE ProjectId=${frmVO.projectId?.plainValue() ?? ""} AND FormId=${formId.plainValue()}";
        var resultAttachList = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, attachQuery);
        if (resultAttachList.isNotEmpty) {
          String attachmentDirPath = await AppPathHelper().getAttachmentDirectory(projectId: frmVO.projectId?.plainValue() ?? "");
          for (var attachVO in frmMsgAttachList) {
            EAttachmentAndAssociationType eAttachType = EAttachmentAndAssociationType.fromString(attachVO.attachType ?? "");
            if (eAttachType == EAttachmentAndAssociationType.files || eAttachType == EAttachmentAndAssociationType.attachments) {
              String uploadFileName = attachVO.attachFileName ?? "";
              String fileExt = Utility.getFileExtension(uploadFileName);
              String newRevId = ((eAttachType == EAttachmentAndAssociationType.attachments) ? attachVO.attachRevId : attachVO.assocDocRevisionId)?.plainValue() ?? "";
              String newFilePath = "$attachmentDirPath/$newRevId.$fileExt";
              if (!isFileExist(newFilePath)) {
                for (var objAttachmentDetail in resultAttachList) {
                  if (objAttachmentDetail["AttachFileName"].toString() == uploadFileName) {
                    String oldFilePath = "";
                    Map<String, dynamic> attachmentDetailNode = jsonDecode(objAttachmentDetail["AttachAssocDetailJson"]);
                    switch (EAttachmentAndAssociationType.fromString(objAttachmentDetail["AttachmentType"].toString())) {
                      case EAttachmentAndAssociationType.attachments:
                      case EAttachmentAndAssociationType.files:
                        String oldRevisionId = attachmentDetailNode["revisionId"].toString().plainValue();
                        oldFilePath = "$attachmentDirPath/$oldRevisionId.$fileExt";
                        break;
                      default:
                        break;
                    }
                    if (oldFilePath.isNotEmpty && isFileExist(oldFilePath) && oldFilePath != newFilePath) {
                      renameFile(oldFilePath,newFilePath);
                      break;
                    }
                  }
                }
              }
            }
          }
        }
      }
      List<String> deleteDataTableList = [FormDao.tableName, FormMessageDao.tableName, FormMessageActionDao.tableName, FormMessageAttachAndAssocDao.tableName];
      for (var tableName in deleteDataTableList) {
        String query = "DELETE FROM $tableName\n"
            "WHERE ProjectId=${frmVO.projectId?.plainValue() ?? ""} AND FormId=${formId.plainValue()}";
        databaseManager.executeTableRequest(query);
      }
      await FormDao().insert([frmVO]);
      await FormMessageDao().insert(frmMsgList);
      if (frmMsgActList.isNotEmpty) {
        await FormMessageActionDao().insert(frmMsgActList);
      }
      if (frmMsgAttachList.isNotEmpty) {
        await FormMessageAttachAndAssocDao().insert(frmMsgAttachList);
      }
      String projectId = paramData["ProjectId"]?.toString().plainValue() ?? "";
      String msgId = paramData["MsgId"]?.toString().plainValue() ?? "";
      String requestFilePath = await AppPathHelper().getOfflineRequestDataFilePath(projectId: projectId, msgId: msgId);
      await deleteFileAtPath(requestFilePath);
      isSuccess = true;
    } catch (e) {
      Log.d("FormLocalDataSource::updateOfflineCreatedOrRespondedFormData Error=$e");
    }
    return isSuccess;
  }

  String updateJsonDataForInlineAttachments(Map<String, dynamic> strJsonData, Function? getContentValueCallback) {
    try {
      if (strJsonData.isNotEmpty && strJsonData.containsKey("myFields") && strJsonData["myFields"]["attachment_fields"] != null) {
        String? strValue = strJsonData["myFields"]["attachment_fields"];
        if (!strValue.isNullOrEmpty()) {
          List<String> keyList = strValue!.split('#');
          strJsonData = _updateJsonDataForInlineAttachment(strJsonData, keyList, getContentValueCallback);
          return jsonEncode(strJsonData);
        }
      }
    } catch (e) {
      Log.d("FormLocalDataSource::updateJsonDataForInlineAttachments error=${e.toString()}");
    }
    return jsonEncode(strJsonData);
  }

  dynamic _updateJsonDataForInlineAttachment(dynamic jsonNode, List<String> keyList, Function? getContentValueCallback) {
    if (jsonNode is List) {
      for (var i = 0; i < jsonNode.length; i++) {
        jsonNode[i] = _updateJsonDataForInlineAttachment(jsonNode[i], keyList, getContentValueCallback);
      }
    } else if (jsonNode is Map) {
      for (var entry in jsonNode.entries) {
        var key = entry.key;
        if (key.toString() == "content") {
          if (jsonNode.containsKey("@inline")) {
            String strKeyName = jsonNode["@inline"].toString();
            if (keyList.contains(strKeyName)) {
              jsonNode[key] = getContentValueCallback!(jsonNode[key].toString(), strKeyName);
            }
          }
        } else {
          jsonNode[key] = _updateJsonDataForInlineAttachment(jsonNode[key], keyList, getContentValueCallback);
        }
      }
    }
    return jsonNode;
  }

  removeOfflineFormDistributionAction(var response, Map<String, dynamic> postDataNode) async {
    try {
      String strProjectId = postDataNode["projectId"]?.toString().plainValue() ?? "";
      String strFormId = postDataNode["formId"]?.toString().plainValue() ?? "";
      String strMsgId = postDataNode["msgId"]?.toString().plainValue() ?? "";
      String strActionId = postDataNode["actionId"]?.toString().plainValue() ?? "";
      String strCreatedDateInMs = postDataNode["CreateDateInMS"]?.toString() ?? "";
      if (strActionId.isEmpty) {
        strActionId = "6";
      }
      String strDeleteQuery = "DELETE FROM ${OfflineActivityDao.tableName}\n"
          "WHERE ${OfflineActivityDao.projectIdField}=$strProjectId AND ${OfflineActivityDao.formIdField}=$strFormId\n"
          "AND ${OfflineActivityDao.msgIdField}=$strMsgId AND ${OfflineActivityDao.actionIdField}=$strActionId AND ${OfflineActivityDao.createdDateInMsField}=$strCreatedDateInMs";
      databaseManager.executeTableRequest(strDeleteQuery);
    } catch (e) {
      Log.e("FormLocalDataSource::removeOfflineFormDistributionAction strRequestData empty :: $e");
    }
  }

  removeOfflineFormActivityForAction(var response, Map<String, dynamic> postDataNode) async {
    try {
      String strProjectId = postDataNode["projectId"]?.toString().plainValue() ?? "";
      String strFormId = postDataNode["formId"]?.toString().plainValue() ?? "";
      String strMsgId = postDataNode["msgId"]?.toString().plainValue() ?? "";
      String strActionId = postDataNode["actionId"]?.toString().plainValue() ?? "";
      if (strActionId.isEmpty) {
        strActionId = "0";
      }
      String strDeleteQuery = "DELETE FROM ${OfflineActivityDao.tableName}\n"
          "WHERE ${OfflineActivityDao.projectIdField}=$strProjectId AND ${OfflineActivityDao.formIdField}=$strFormId\n"
          "AND ${OfflineActivityDao.msgIdField}=$strMsgId AND ${OfflineActivityDao.actionIdField}=$strActionId";
      databaseManager.executeTableRequest(strDeleteQuery);
    } catch (e) {
      Log.e("FormLocalDataSource::removeOfflineFormActivityForAction strRequestData empty :: $e");
    }
  }

  updateOfflineFormStatusChangedData(var response, Map<String, dynamic> postDataNode) async {
    try {
      String strProjectId = postDataNode["projectId"]?.toString().plainValue() ?? "";
      String strFormId = postDataNode["selectedFormId"]?.toString().plainValue() ?? "";
      String strCreateDateInMS = postDataNode["CreateDateInMS"]?.toString().plainValue() ?? "";

      String strUpdateStatus = "UPDATE ${FormStatusHistoryDao.tableName} SET JsonData=''\n"
          "WHERE ProjectId=$strProjectId AND FormId=$strFormId AND CreateDateInMS=$strCreateDateInMS";
      databaseManager.executeTableRequest(strUpdateStatus);
    } catch (e) {
      Log.e("FormLocalDataSource::updateOfflineFormStatusChangedData strRequestData empty :: $e");
    }
  }

  Map<String, dynamic> _getDistributionUserNode(String strProjectId, Map<String, dynamic> userNodeTmp, Map<String, dynamic> forInfoActionNode) {
    Map<String, dynamic> selectUserNode = {};

    selectUserNode["actionID"] = forInfoActionNode["actionID"].toString();
    selectUserNode["userID"] = userNodeTmp["userID"].toString();
    selectUserNode["distributionLevel"] = EDistributionLevel.users.value;
    selectUserNode["distributionLevelId"] = userNodeTmp["userID"].toString();
    selectUserNode["distributionLevelName"] = "${userNodeTmp["fname"]} ${userNodeTmp["lname"]}";
    selectUserNode["noOfDaysForAction"] = 0;
    selectUserNode["actionDueDate"] = "";
    selectUserNode["userOrgName"] = userNodeTmp["orgName"].toString();
    selectUserNode["fname"] = userNodeTmp["fname"].toString();
    selectUserNode["lname"] = userNodeTmp["lname"].toString();
    selectUserNode["actionName"] = forInfoActionNode["actionName"].toString();
    selectUserNode["emailId"] = userNodeTmp["emailId"].toString();
    selectUserNode["userImageName"] = userNodeTmp["userImageName"].toString();
    selectUserNode["isSendNotification"] = true;
    selectUserNode["userCannotOverrideNotification"] = false;
    selectUserNode["user_type"] = userNodeTmp["userTypeId"].toString();
    selectUserNode["projectId"] = strProjectId;
    selectUserNode["dueDays"] = 0;
    selectUserNode["distListId"] = 0;
    selectUserNode["generateURI"] = true;

    return selectUserNode;
  }

  Future<Map<String, String>> getOfflineAttachFileList(String projectId, String formId, String msgId) async {
    String strQuery = "SELECT ${FormMessageAttachAndAssocDao.attachRevIdField},${FormMessageAttachAndAssocDao.offlineUploadFilePath} FROM ${FormMessageAttachAndAssocDao.tableName}";
    strQuery = "$strQuery WHERE ProjectId=$projectId AND FormId=$formId AND MsgId=$msgId AND ${FormMessageAttachAndAssocDao.offlineUploadFilePath} <> ''";
    final attachmentList = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strQuery);
    Map<String, String> offlineAttachmentMap = {};
    attachmentList.forEach((element) {
      offlineAttachmentMap[element[FormMessageAttachAndAssocDao.attachRevIdField].toString()] = element[FormMessageAttachAndAssocDao.offlineUploadFilePath].toString();
    });
    return offlineAttachmentMap;
  }

  void updateOfflineFieldFormMessageActionStatus(String projectId, String formId, String? msgId, String actionIds) {
    try {
      String strUpdateAction = "UPDATE ${FormMessageActionDao.tableName} SET ${FormMessageActionDao.actionStatusField}=1,${FormMessageActionDao.isActionCompleteField}=1"
          "\nWHERE ${FormMessageActionDao.projectIdField}=$projectId AND ${FormMessageActionDao.formIdField}=$formId"
          "\nAND ${FormMessageActionDao.actionStatusField}=0 AND ${FormMessageActionDao.actionIdField} IN ($actionIds)";
      if (!msgId.isNullOrEmpty()) {
        strUpdateAction = "$strUpdateAction AND ${FormMessageActionDao.msgIdField}=$msgId";
      }
      Log.d("CreateFormLocalDataSource:: updateOfflineFieldFormMessageActionStatus strUpdateAction=$strUpdateAction");
      var result = databaseManager.executeSelectFromTable(FormMessageActionDao.tableName, strUpdateAction);
      Log.d("CreateFormLocalDataSource:: updateOfflineFieldFormMessageActionStatus strUpdateAction result=$result");
    } catch (_) {
      Log.d("CreateFormLocalDataSource:: updateOfflineFieldFormMessageActionStatus default::exception");
    }
  }
}
