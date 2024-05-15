

import 'package:field/data/local/formtype/formtype_local_repository_impl.dart';
import 'package:field/data/remote/formtype/formtype_repository_impl.dart';
import 'package:field/data/repository/formtype/formtype_repository.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/extensions.dart';

import '../../../offline_injection_container.dart' as di;

class FormTypeUseCase extends BaseUseCase<FormTypeRepository> {
  FormTypeRepository? _repository;

  Future<Result> getProjectFormTypeListFromSync({required String projectId, String? formTypeIds, required NetworkExecutionType networkExecutionType, num? taskNumber}) async {
    var request = {
      "offlineProjectId": projectId,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
      "isExcludeXSNForms": "true",
    };
    if (!(formTypeIds.isNullOrEmpty())) {
      formTypeIds = formTypeIds?.split(",").map((e) => e.trim().plainValue()).join(",");
      request.addAll({"formTypeIds": formTypeIds!});
    }
    await getInstance();
    var result = await _repository?.getLatestProjectDefectFormTypeIdList(request);
    return result;
  }

  Future<Result> getFormTypeHTMLTemplateZipDownload({required String projectId, required String formTypeId, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "project_id": projectId,
      "formTypeId": formTypeId,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeHTMLTemplateZipDownload(request);
    return result;
  }

  Future<Result> getFormTypeXSNTemplateZipDownload({required String projectId, required String formTypeId, required String userId, required String jSFolderPath, bool isMobileView = false, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "action_id": "1203",
      "applicationId": "3",
      "application_Id": "3",
      "isFromApps": "true",
      "isNewUI": "true",
      "supportOfflineMultipleAttachments": "true",
      "isFromAndroidApp": "true",
      "isgenratedZip": "true",
      "isMobileView":isMobileView,
      "offlineProjectId": projectId.plainValue(),
      "formTypeIds": formTypeId,
      "userId":userId,
      "offlineJsFilePath":jSFolderPath,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeXSNTemplateZipDownload(request);
    return result;
  }

  Future<Result> getFormTypeCustomAttributeList({required String projectId, required String formTypeId, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "projectId": projectId,
      "formTypeId": formTypeId,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeCustomAttributeList(request);
    return result;
  }
  Future<Result> getFormTypeAttributeSetDetail({required String projectId, required String attributeSetId,required callingArea, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "attributeSetId": attributeSetId,
      "callingArea": callingArea,
      "projectId": projectId,
      "applicationId" : "3",
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeAttributeSetDetail(request);
    return result;
  }

  Future<Result> getFormTypeDistributionList({required String projectId, required String formTypeId, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "applicationId": "3",
      "action_id": "11",
      "isFormActionsRequired": "true",
      "checkHashing": "false",
      "project_id": projectId,
      "projectIds": projectId,
      "projectId": projectId,
      "rmft": formTypeId,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeDistributionList(request);
    return result;
  }

  Future<Result> getFormTypeControllerUserList({required String projectId, required String formTypeId, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "projectId": projectId,
      "formTypeId": formTypeId,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeControllerUserList(request);
    return result;
  }

  Future<Result> getFormTypeStatusList({required String projectId, required String formTypeId, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "projectId": projectId,
      "formTypeId": formTypeId,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeStatusList(request);
    return result;
  }

  Future<Result> getFormTypeFixFieldList({required String projectId, required String formTypeId, required String userId, required NetworkExecutionType networkExecutionType, required num? taskNumber}) async {
    var request = {
      "user_id": userId.plainValue(),
      "projectID": projectId,
      "formTypeId": formTypeId,
      "networkExecutionType": networkExecutionType,
      "taskNumber": taskNumber,
    };
    await getInstance();
    var result = await _repository?.getFormTypeFixFieldData(request);
    return result;
  }

  Future<void> getAppTypeList(String projectId, isFromMap,String appTypeId) async {
    await getInstance();
   await _repository?.getAppTypeList(projectId, isFromMap, appTypeId);
  }

  @override
  Future<FormTypeRepository?> getInstance() async{
    if (isNetWorkConnected()) {
      _repository = di.getIt<FormTypeRemoteRepository>();
      return _repository;
    } else {
      _repository = di.getIt<FormTypeLocalRepository>();
      return _repository;
    }
  }
}