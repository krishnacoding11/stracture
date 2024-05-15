import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/site_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:sprintf/sprintf.dart';

import '../logger/logger.dart';
import '../networking/network_request.dart';
import '../networking/network_service.dart';
import '../networking/request_body.dart';
import 'constants.dart';

typedef DownloadProgressCallback = void Function(int received, int total);

class DownloadService {
  Future<DownloadResponse> download(DownloadRequest downloadRequest,
      [DownloadProgressCallback? downloadProgressCallback, Dio? dio]) async {
    onReceiveDownloadProgress(received, total) {
      if (total != -1) {
        Log.d((received / total * 100).toStringAsFixed(0) + '%');
      }
      if (downloadProgressCallback != null) {
        downloadProgressCallback(received, total);
      }
    }

    var result = await NetworkService(
            dioClient: dio,
            baseUrl: downloadRequest.baseUrl,
            connectTimeout: const Duration(milliseconds: 600000),
            receiveTimeout: null, /// `null` meanings no timeout limit.
            isCsrfRequired: downloadRequest.isCsrfRequired,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.GET,
                path: downloadRequest.endPointUrl,
                callType: CallType.Download,
                data: const NetworkRequestBody.empty()))
        .execute(parseFile,
            filePath: downloadRequest.outputFilePath,
            onReceiveProgress: downloadProgressCallback != null
                ? onReceiveDownloadProgress
                : null);

    if (result is SUCCESS) {
      DownloadResponse downloadResponse = DownloadResponse(
          true, downloadRequest.outputFilePath, result,
          requestParam: downloadRequest.requestParam);
      return downloadResponse;
    }
    return DownloadResponse(false, null, result is FAIL ? result : null,
        requestParam: downloadRequest.requestParam);
  }

  Future<bool> isFileExist(String filePath) async {
    io.File saveFile = io.File(filePath);
    return await saveFile.exists() && await saveFile.length() > 0;
  }

  parseFile(dynamic data) {
    return null;
  }
}

class DownloadPdfFile extends DownloadService {
  /// @request request parameters
  /// @checkFileExist if It is passing true It's checking in local storage if file already downloaded then return its.
  Future<DownloadResponse> downloadPdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = true, Dio? dio}) async {
    String projectId = request["projectId"];
    String folderId = request["folderId"];
    String revisionId = request["revisionId"];

    String? outputFilePath = await AppPathHelper()
        .getPlanPDFFilePath(projectId: projectId, revisionId: revisionId);

    if (outputFilePath.isNullOrEmpty()) {
      return DownloadResponse(false, null, null, requestParam: request);
    }

    if (checkFileExist) {
      //check if already downloaded and return this
      if (await isFileExist(outputFilePath)) {
        DownloadResponse downloadResponse = DownloadResponse(true, outputFilePath, Result({"projectId": projectId, "folderId": folderId, "revisionId": revisionId}), requestParam: request);
        return downloadResponse;
      }
    }

    //  String endPointUrl = "/api/workspace/$projectId/folder/$folderId/singleFileDownload/$revisionId/false";
    String endPointUrl = sprintf(AConstants.pdfDownloadUrl, [projectId, folderId, revisionId]);
    bool isCsrfRequired = !projectId.isHashValue() || !revisionId.isHashValue();
    DownloadRequest downloadRequest = DownloadRequest(AConstants.collabUrl, endPointUrl, outputFilePath, isCsrfRequired, request);
    return super.download(downloadRequest, onReceiveProgress,dio);
  }

  /// Function is used to fetch offline plan
  Future<DownloadResponse> fetchPdfFile(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = true}) async {
    String projectId = request["projectId"];
    String revisionId = request["revisionId"];

    String? outputFilePath = await AppPathHelper()
        .getPlanPDFFilePath(projectId: projectId, revisionId: revisionId);

    if (!outputFilePath.isNullOrEmpty() && await isFileExist(outputFilePath)) {
      DownloadResponse downloadResponse =
          DownloadResponse(true, outputFilePath, null);
      return downloadResponse;
    } else {
      return DownloadResponse(false, null, null);
    }
  }
}

class DownloadScsFile extends DownloadService {
  /// @request request parameters
  /// @checkFileExist if It is passing true It's checking in local storage if file already downloaded then return its.
  Future<DownloadResponse> downloadScs(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = true}) async {
    String projectId = request["projectId"];
    String folderId = request["folderId"];
    String revisionId = request["revisionId"];
    String floorName = request["floorName"];
    String modelId = request["modelId"]??"";
    String floorNumber = request["floorNumber"].toString();

    String? outputFilePath = await AppPathHelper().getModelScsFilePath(
      projectId: projectId,
      revisionId: revisionId,
      filename: floorName,
      modelId: modelId,
    );

    if (outputFilePath == null || outputFilePath.isEmpty) {
      return DownloadResponse(false, null, null);
    }

    if (checkFileExist) {
      if (await isFileExist(outputFilePath)) {
        DownloadResponse downloadResponse =
            DownloadResponse(true, outputFilePath, null);
        return downloadResponse;
      }
    }

    String endPointUrl = sprintf(AConstants.scsDownloadUrl,
        [projectId, revisionId, folderId, floorNumber]);

    DownloadRequest downloadRequest = DownloadRequest(AConstants.adoddleUrl,
        endPointUrl, outputFilePath, !projectId.isHashValue(), request);

    return super.download(downloadRequest, onReceiveProgress);
  }
}

class DownloadXfdfFile extends DownloadService {
  /// @request request parameters
  /// @checkFileExist if It is passing true It's checking in local storage if file already downloaded then return its.
  Future<DownloadResponse> downloadXfdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = false, Dio? dio}) async {
    String projectId = request["projectId"];
    String revisionId = request["revisionId"];

    String? outputFilePath = await AppPathHelper().getPlanXFDFFilePath(projectId: projectId, revisionId: revisionId);

    if (outputFilePath.isNullOrEmpty()) {
      return DownloadResponse(false, null, null, requestParam: request);
    }

    String endPointUrl = sprintf(AConstants.xfdfDownloadUrl, [projectId, revisionId]);
    bool isCsrfRequired = !projectId.isHashValue() || !revisionId.isHashValue();
    DownloadRequest downloadRequest = DownloadRequest(AConstants.adoddleUrl, endPointUrl, outputFilePath, isCsrfRequired, request);

    //check file if already downloaded
    if (checkFileExist) {
      if (await isFileExist(outputFilePath)) {
        String? content = await SiteUtility.getContentXfdfFile(outputFilePath);
        if (content.isNullOrEmpty()) {
          DownloadResponse downloadResponse = DownloadResponse(true, outputFilePath, null, requestParam: request);

          /// Downloading Xfdf file in the background for updating existing Xfdf file.
          super.download(downloadRequest, onReceiveProgress);

          return downloadResponse;
        }
      }
    }

    return super.download(downloadRequest, onReceiveProgress, dio);
  }

  Future<DownloadResponse> fetchXFDFFile(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = true}) async {
    String projectId = request["projectId"];
    String revisionId = request["revisionId"];

    String? outputFilePath = await AppPathHelper()
        .getPlanXFDFFilePath(projectId: projectId, revisionId: revisionId);

    if (!outputFilePath.isNullOrEmpty() && await isFileExist(outputFilePath)) {
      DownloadResponse downloadResponse =
          DownloadResponse(true, outputFilePath, null);
      return downloadResponse;
    } else {
      return DownloadResponse(false, null, null);
    }
  }
}

class DownloadFile extends DownloadService {
  Future<DownloadResponse> downloadFileWithSameExtension(Map<String, dynamic> request, {DownloadProgressCallback? onReceiveProgress}) async {
    String externalDirPath = await Utility.getExternalDirectoryPath() as String;

    String fileName = request['fileName'];
    String projectId = request['projectId'];
    String folderId = request['folderId'];
    String revisionId = request['revisionId'];

    String pathWithFileName = '$externalDirPath/$fileName';

    String endPointUrl =
    sprintf(AConstants.pdfDownloadUrl, [projectId, folderId, revisionId]);

    DownloadRequest downloadRequest =
    DownloadRequest(AConstants.collabUrl, endPointUrl, pathWithFileName, !projectId.isHashValue(), request);

    return super.download(downloadRequest, onReceiveProgress);
  }
}

class DownloadRequest {
  const DownloadRequest(this.baseUrl, this.endPointUrl, this.outputFilePath,
      this.isCsrfRequired, this.requestParam);

  final String baseUrl;
  final String endPointUrl;
  final String outputFilePath;
  final bool isCsrfRequired;
  final Map<String, dynamic> requestParam;
}

class DownloadResponse {
  bool isSuccess = false;
  String? outputFilePath;
  Result? result;
  String? errorMsg;
  Map<String, dynamic>? requestParam;

  DownloadResponse(this.isSuccess, this.outputFilePath, this.result,
      {this.requestParam, this.errorMsg = "Something went wrong"});
}
