import 'package:dio/dio.dart';
import 'package:field/data/model/upload_fail.dart';
import 'package:field/data/remote/upload/upload_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/store_preference.dart';

import '../../../networking/network_response.dart';

class UploadUseCase {
  final UploadRemoteRepository _uploadRemoteRepository = di.getIt<UploadRemoteRepository>();

  String? _filePath, _fileName, _projectId, _folderId, _planId, _deliverableActivityId,_userId;

  Future<Result?> uploadFileToServer(
    String? filePath,
    String? fileName,
    String? projectId,
    String? folderId, {
    String? planId,
    String? deliverableActivityId,
  }) async {
    await setRequestData(projectId: projectId, fileName: fileName,folderId: folderId, planId: planId, filePath: filePath, deliverableActivityId: deliverableActivityId);
    var request = _getLockValidationDataMap();
    Result result = await _uploadRemoteRepository.getLockValidation(request);
    if (result is SUCCESS) {
      List uploadFileList = result.data;
      if (uploadFileList.isEmpty || (uploadFileList.first.toString().contains("nonExistingFileList")) || uploadFileList.first['messageCode'] == 2022) {
        Result? result = await checkUploadEventValidation();
        if (result is SUCCESS) {
          List emptyList = result.data;
          if (emptyList.isEmpty) {
            return simpleFileUploadToServer();
          }
          return Future.value(FAIL(result.failureMessage, result.responseCode));
        } else {
          return Future.value(FAIL(uploadEventValidationError(result!), 1504));
        }
      } else {
        return Future.value(FAIL(lockValidationError(result), 1504));
      }
    } else {
      return Future.value(FAIL(result.failureMessage, result.responseCode));
    }
  }

  Future<Result?> checkUploadEventValidation() async {
    var request = _getUploadEventValidationDataMap();
    return await _uploadRemoteRepository.checkUploadEventValidation(request);
  }

  Future<Result?> simpleFileUploadToServer() async {
    MultipartFile multipartFilepath = await MultipartFile.fromFile(_filePath!);
    var request = _getFileUploadToServerDataMap(multipartFilepath);
    return await _uploadRemoteRepository.simpleFileUploadToServer(request);
  }

  Future<void> setRequestData({
    String? filePath,
    String? fileName,
    String? projectId,
    String? folderId,
    String? planId,
    String? deliverableActivityId,
  }) async  {
    _userId = await StorePreference.getUserId();
    _projectId = projectId;
    _folderId = folderId;
    _filePath = filePath;
    _fileName = fileName;
    _planId = planId;
    _deliverableActivityId = deliverableActivityId;
  }

  Map<String, dynamic> _getLockValidationDataMap() {
    Map<String, dynamic> map = {};
    map["action_id"] = 138;
    map["project_id"] = _projectId;
    map["folder_id"] = _folderId;
    map["validationType"] = 1;
    map["forPublishing"] = false;
    map["rowNumbers"] = 1;
    map["caller"] = 2;
    map["filename1"] = _fileName ?? "";
    return map;
  }

  Map<String, dynamic> _getUploadEventValidationDataMap() {
    Map<String, dynamic> map = {};
    map["projectId"] = _projectId;
    map["folderId"] = _folderId;
    map["uploadType"] = 2;
    map["userId"] = _userId??""; //TODO: Pass user ID
    map["thinUploadDocs"] = [
      {"filename": _fileName ?? ""}
    ];
    return map;
  }

  Map<String, dynamic> _getFileUploadToServerDataMap(MultipartFile file) {
    Map<String, dynamic> map = {};
    map["projId"] = _projectId;
    map["folderId"] = _folderId;
    map["deliverableActivityId"] = _deliverableActivityId;
    map["planId"] = _planId;
    map["isMac"] = 1;
    map["totalFiles"] = 1;
    map["upFile0"] = file; //TODO: What if multiple files
    return map;
  }

  String? lockValidationError(Result result){
    String errorMessage ="";
    if(result.data != null) {
      List errorList = result.data;
      if(errorList.isNotEmpty && errorList.first.toString().contains("exceptionString")){
        errorMessage = "exceptionString";
      }else if(errorList.first.toString().contains("linkedFileList")){
        errorMessage = "linkedFileList";
      }else if(errorList.first.toString().contains("checkedOutFileList")){
        errorMessage = "checkedOutFileList";
      }
    }
    return errorMessage;
  }

  String? uploadEventValidationError(Result result){
    if(result.data != null){
      List<UploadFail> errorList = UploadFail.jsonToList(result.data);
      return errorList.first.messageString??"";
    }
    return null;
  }

}