import 'dart:async';

import 'package:dio/dio.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/data_source/sync_size/sync_size_data_source.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/utils/utils.dart';

import '../../../logger/logger.dart';
import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';
import '../../model/project_vo.dart';
import '../../repository/project_list/project_list_repository.dart';

class ProjectListRemoteRepository extends ProjectListRepository {
  ProjectListRemoteRepository();

  SyncSizeDataSource syncSizeDataSource = SyncSizeDataSource();

  @override
  Future<List<Project>> getProjectList(int page, int batchSize, Map<String, dynamic> request, [dioInstance]) async {
    List<Project> list = [];

    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.projectListUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(projectListFromJson);
    if (result is SUCCESS) {
      for (var item in result.data!) {
        list.add(item);
      }
      Log.d("Get project listing in successfully");
      return list;
    }
    return list;
  }

  static List<Project>? projectListFromJson(dynamic response) {
    var projectList = List<Project>.from(response.map((x) => Project.fromJson(x)));
    List<Project> outputList = projectList.where((o) => o.iProjectId == 0).toList();
    return outputList;
  }

  static List<Popupdata>? popupDataListFromJson(dynamic response) {
    dynamic data = response["data"];
    var projectList = List<Popupdata>.from(data.map((x) => Popupdata.fromJson(x)));
    return projectList;
  }

  @override
  Future<dynamic> setFavProject(Map<String, dynamic> request, [dioInstance]) async {
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.favoriteProjectUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(parseFavProjectJson);
    if (result is SUCCESS) {
      return result;
    }
    return result;
  }

  static String parseFavProjectJson(dynamic data) {
    String success = data.toString();
    return success;
  }

  @override
  Future<List<Popupdata>> getPopupDataList(int page, int batchSize, Map<String, dynamic> request, [dioInstance]) async {
    List<Popupdata> list = [];
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getPopupData,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(popupDataListFromJson);
    if (result is SUCCESS) {
      return result.data ?? [];
    }
    return list;
  }

  @override
  Future<Result> getProjectAndLocationList(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.projectListForSyncUrl,
        data: NetworkRequestBody.json(request),
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getColumnHeaderList(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.columnHeaderListSyncUrl,
        data: NetworkRequestBody.json(request),
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getFormList(Map<String, dynamic> request) async {
    bool isCsrfTokenRequired = !(request["folderId"].toString().contains(Utility.keyDollar) && request["projectId"].toString().contains(Utility.keyDollar));
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      isCsrfRequired: isCsrfTokenRequired,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getFormListSyncUrl,
        data: NetworkRequestBody.json(request),
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getFormMessageBatchList(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      connectTimeout: const Duration(milliseconds: 600000),
      receiveTimeout: const Duration(milliseconds: 600000),
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getFormMessageDataInBatchUrl,
        data: NetworkRequestBody.json(request),
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> downloadFormAttachmentInBatch(Map<String, dynamic> request, {bool bAkamaiDownload = true}) async {
    String baseUrl = await UrlHelper.getDownloadURL(null, bAkamaiDownload: bAkamaiDownload);
    String projectId = request['projectId'];
    String attachmentPath = request['attachmentPath'];
    // bool isCsrfTokenRequired = !(request["projectId"].toString().contains(Utility.keyDollar));
    Log.d("Download progress project : start >> $projectId at >> $attachmentPath");
    var result = await NetworkService(
      baseUrl: baseUrl,
      headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
      isRequiredRetry: true,
      responseType: ResponseType.stream,
      connectTimeout: null,
      receiveTimeout: null,
      isAkamaiDownload: bAkamaiDownload,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        callType: CallType.Download,
        path: AConstants.getFormAttachmentBatchDownloadUrl,
        data: NetworkRequestBody.json(request),
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((_) {
      return attachmentPath;
    }, filePath: attachmentPath);
    return result;
  }

  @override
  Future<Result> getServerTime(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getServerTime,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getHashedValue(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getFieldsHashedValueUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getStatusStyle(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getStatusStyleForProjectUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getManageTypeList(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getManageTypeListUrl,
        data: NetworkRequestBody.json(request),
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getDiscardedFormIds(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.discardedFormIdsUrl,
        data: NetworkRequestBody.json(request),
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<List<SyncSizeVo>> deleteItemFromSyncTable(Map<String, dynamic> request) async {
    await syncSizeDataSource.init();
    return await syncSizeDataSource.deleteProjectSync(request);
  }

  @override
  Future<Result> getWorkspaceSettings(Map<String, dynamic> request,[dioInstance]) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      dioClient: dioInstance,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getWorkspaceSetting,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }
}
