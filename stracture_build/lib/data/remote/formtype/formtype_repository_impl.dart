import 'package:dio/dio.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/custom_attribute_set_vo.dart';
import 'package:field/data/repository/formtype/formtype_repository.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';
import 'package:sprintf/sprintf.dart';

import '../../../utils/global.dart' as globals;
import '../../../utils/utils.dart';

class FormTypeRemoteRepository extends FormTypeRepository<Map, Result> {
  FormTypeRemoteRepository();

  @override
  Future<Result?> getLatestProjectDefectFormTypeIdList(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["offlineProjectId"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        isCsrfRequired: isCsrfTokenRequired,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.siteFormTypeListForSyncUrl,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result?> getFormTypeHTMLTemplateZipDownload(Map<String, dynamic> request) async {
    String finalURL = sprintf(AConstants.siteFormTypeHTMLTemplateZipSyncUrl, [request["project_id"], request["formTypeId"]]);
    bool isCsrfTokenRequired = !(request["project_id"].toString().contains(Utility.keyDollar) && request["formTypeId"].toString().contains(Utility.keyDollar));

    var result = await NetworkService(
        baseUrl: AConstants.collabUrl,
        isRequiredRetry: true,
        responseType: ResponseType.bytes,
        isCsrfRequired: isCsrfTokenRequired,
        receiveTimeout: null,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.GET,
            path: finalURL,
            data: const NetworkRequestBody.empty(),
            networkExecutionType: request["networkExecutionType"],
            taskNumber: request["taskNumber"],
        ))
        .execute((response) => response);
    return result;
  }

  @override
  Future<Result?> getFormTypeXSNTemplateZipDownload(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["formTypeIds"].toString().contains(Utility.keyDollar)
        && request["userId"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        responseType: ResponseType.bytes,
        isCsrfRequired: isCsrfTokenRequired,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.adoddleApps,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result?> getFormTypeControllerUserList(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["projectId"].toString().contains(Utility.keyDollar)
        && request["formTypeId"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        responseType: ResponseType.plain,
        isCsrfRequired: isCsrfTokenRequired,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.siteControllerFormTypeSyncUrl,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result?> getFormTypeCustomAttributeList(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["projectId"].toString().contains(Utility.keyDollar)
        && request["formTypeId"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        responseType: ResponseType.plain,
        isCsrfRequired: isCsrfTokenRequired,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.siteCustomAttributeFormTypeSyncUrl,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((response) {
      return response;
    });
    return result;
  }
  @override
  Future<Result?> getFormTypeAttributeSetDetail(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["projectId"].toString().contains(Utility.keyDollar)
        && request["attributeSetId"].toString().contains(Utility.keyDollar) && request["callingArea"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        responseType: ResponseType.plain,
        isCsrfRequired: isCsrfTokenRequired,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.formTypeAttributeSetDetailSyncUrl,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((CustomAttributeSetVo.getCustomAttributeVOList));
    return result;
  }
  @override
  Future<Result?> getFormTypeDistributionList(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["projectId"].toString().contains(Utility.keyDollar)
        && request["rmft"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        responseType: ResponseType.plain,
        isCsrfRequired: isCsrfTokenRequired,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.siteDistributionFormTypeSyncUrl,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result?> getFormTypeFixFieldData(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["projectID"].toString().contains(Utility.keyDollar)
        && request["formTypeId"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        isCsrfRequired: isCsrfTokenRequired,
        responseType: ResponseType.plain,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.siteFixFieldFormTypeSyncUrl,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result?> getFormTypeStatusList(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["projectId"].toString().contains(Utility.keyDollar)
        && request["formTypeId"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        responseType: ResponseType.plain,
        isCsrfRequired: isCsrfTokenRequired,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.siteStatusFormTypeSyncUrl,
          data: NetworkRequestBody.json(request),
          networkExecutionType: request["networkExecutionType"],
          taskNumber: request["taskNumber"],
        )
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<void> getAppTypeList(String projectId, isFromMap,String appTypeId) async {
    List<AppType> items = [];
    var request = getRequestMapDataAppTypeList(projectId);
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
        isRequiredRetry: true,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.getFieldAppTypeList,
            data: NetworkRequestBody.json(request)))
        .execute(appTypeListFromJson);
    if (result is SUCCESS) {
      for (var item in result.data!) {
        items.add(item);
      }
      globals.appTypeList = [...items];
    } else {
      globals.appTypeList.clear();
    }
  }
}