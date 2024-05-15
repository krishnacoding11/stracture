
import 'dart:convert';

import 'package:field/utils/extensions.dart';

import '../data/model/form_message_attach_assoc_vo.dart';
import '../data/model/form_message_vo.dart';
import '../data/model/form_vo.dart';
import '../data/model/site_form_action.dart';
import '../data_source/forms/form_local_data_source.dart';
import '../logger/logger.dart';

class FormParserUtility {
  static Future<bool> parseFormMessageBatchList({
    required dynamic responseData,
    required List<SiteForm> formList,
    required Function returnValueCallback,
  }) async {
    List<String> successFormIdList = [];
    List<String> failFormIdList = [];
    List<FormMessageVO> formMessageList = [];
    List<SiteFormAction> formMessagesActionList = [];
    List<FormMessageAttachAndAssocVO> formMessageAttachList = [];
    List<String> listOfInlineRevisionId = [];
    bool isSuccess = true;
    dynamic resultData = (responseData is String)
        ? jsonDecode(responseData)
        : responseData;
    try {
      for (var tmpForm in formList) {
        if (resultData.data is Map && (resultData.data as Map).containsKey(tmpForm.commId!.plainValue())) {
          bool isTrue = await FormParserUtility.parseFormMessageList(responseData: resultData.data[tmpForm.commId!.plainValue()], tmpForm: tmpForm, returnValueCallback: (
              List<FormMessageVO> frmMsgList,List<SiteFormAction> frmMsgActList, List<FormMessageAttachAndAssocVO> frmMsgAttachList, List<String> inlineRevisionIds) {
            formMessageList.addAll(frmMsgList);
            formMessagesActionList.addAll(frmMsgActList);
            formMessageAttachList.addAll(frmMsgAttachList);
            listOfInlineRevisionId.addAll(inlineRevisionIds);
          });
          ((isTrue) ? successFormIdList : failFormIdList).add(tmpForm.commId!.plainValue());
          isSuccess = isSuccess && isTrue;
        } else {
          failFormIdList.add(tmpForm.commId!.plainValue());
        }
      }
    } catch (e) {
      isSuccess = false;
      Log.d("FormParserUtility::parseFormMessageBatchList exception $e");
    }
    await returnValueCallback(formMessageList, formMessagesActionList, formMessageAttachList, listOfInlineRevisionId, successFormIdList, failFormIdList);
    return isSuccess;
  }

  static Future<bool> parseFormMessageList({
    required dynamic responseData,
    required SiteForm tmpForm,
    required Function returnValueCallback,
  }) async {
    FormLocalDataSource formLocalDataSource = FormLocalDataSource();
    List<FormMessageVO> formMessageList = [];
    List<SiteFormAction> formMessagesActionList = [];
    List<FormMessageAttachAndAssocVO> formMessageAttachList = [];
    List<String> inLineRevisionIdList = [];
    bool isSuccess = false;
    dynamic response = (responseData is String)
        ? jsonDecode(responseData)
        : responseData;
    try {
      final messageDataNode = response["messages"];
      for (final messageData in messageDataNode) {
        FormMessageVO formMessageObj = FormMessageVO.fromJson(messageData);
        formMessageObj.setFormTypeId = tmpForm.formTypeId;
        formMessageObj.setFormId = tmpForm.formId;
        formMessageObj.setObservationId = tmpForm.observationId?.toString();
        formMessageObj.setLocationId = tmpForm.locationId?.toString();
        formMessageObj.setProjectId = tmpForm.projectId;
        formMessageObj.setAppTypeId = tmpForm.appTypeId?.toString();
        formMessageList.add(formMessageObj);

        final actionListNode = messageData["allActions"] ?? [];
        for (final actionNode in actionListNode) {
          SiteFormAction siteFormActionObj = SiteFormAction.fromMessageJson(actionNode);
          siteFormActionObj.setFormId = formMessageObj.formId;
          siteFormActionObj.setProjectId = formMessageObj.projectId;
          //siteFormActionObj.setMsgId = formMessageObj.msgId;
          if (formMessageObj.msgId!=null && formMessageObj.msgId?.plainValue()==siteFormActionObj.msgId?.plainValue()) {
            formMessagesActionList.add(siteFormActionObj);
          }
        }
        if (formMessageObj.jsonData != null) {
          List<String> listOfInlineRevisionIdTmp = formLocalDataSource.getInlineAttachmentRevisionIdList(jsonDecode(formMessageObj.jsonData!));
          if (listOfInlineRevisionIdTmp.isNotEmpty) {
            inLineRevisionIdList.addAll(listOfInlineRevisionIdTmp);
          }
        }
      }
      if (response["combinedAttachAssocList"] != null && response["combinedAttachAssocList"] is List) {
        final attachmentListNode = response["combinedAttachAssocList"];
        for (final attachmentDataNode in attachmentListNode) {
          FormMessageAttachAndAssocVO formMessageAttachAndAssocObj = FormMessageAttachAndAssocVO.fromJson(attachmentDataNode);
          formMessageAttachAndAssocObj.setFormTypeId = tmpForm.formTypeId;
          formMessageAttachAndAssocObj.setFormId = tmpForm.formId;
          formMessageAttachAndAssocObj.setProjectId = tmpForm.projectId;
          formMessageAttachAndAssocObj.setLocationId = tmpForm.locationId?.toString();
          formMessageAttachList.add(formMessageAttachAndAssocObj);
        }
      }
      isSuccess = true;
      await returnValueCallback(formMessageList,formMessagesActionList,formMessageAttachList,inLineRevisionIdList);
    } catch (e) {
      Log.d("FormParserUtility::parseFormMessageList exception $e");
    }
    return isSuccess;
  }
}