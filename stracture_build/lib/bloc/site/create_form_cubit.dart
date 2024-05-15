import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/site/offline_attachment_success_state.dart';
import 'package:field/bloc/site/xsn_inline_attachment_success_state.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/file_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/foundation.dart';

import '../../injection_container.dart';
import '../../networking/network_response.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import 'inline_attachment_success_state.dart';

class CreateFormCubit extends BaseCubit {
  CreateFormCubit({CreateFormUseCase? createFormCubit, AppPathHelper? appPathHelper})
      : _createFormUseCase = createFormCubit ?? getIt<CreateFormUseCase>(),
      _appPathHelper = appPathHelper ?? AppPathHelper(),
        super(
          FlowState(),
        );

  final CreateFormUseCase _createFormUseCase;
  final AppPathHelper _appPathHelper;
  final List<String> _documentRandomNumList = [];

  Future<void> uploadAttachment(String projectID, String filePath, String folderID, String appTypeID) async {
    try {
      emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
      String? userId = await StorePreference.getUserId();
      String fileName = filePath.split("/").last;
      String path = await _appPathHelper.getTemporaryAttachmentPath(fileName: fileName, projectId: projectID);
      await createFileFromFile(filePath, path);

      if (kDebugMode) {
        print("Upload image:$path");
      }
      if (isNetWorkConnected()) {
        Map<String, dynamic> data = {};
        data['appType'] = appTypeID;
        data['checkHashing'] = 'false';
        data['extra'] = '';
        data['isMac'] = 'false';
        data['projectIds'] = '-2';
        data['totalFiles'] = '0';
        data['attachTempFolderId'] = folderID;
        data['projectid'] = projectID;
        data["files"] = await MultipartFile.fromFile(path);

        final result = await _createFormUseCase.uploadAttachment(data);
        if (result is SUCCESS) {
          emitState(SuccessState(result, time: path));
        } else {
          emitState(ErrorState(StateRendererType.isValid, result.failureMessage ?? "Something went wrong", code: result.responseCode, time: path));
        }
      } else {
//IMG_1683725385284.jpg|jpg|110609|2017529|/data/user/0/com.asite.Adoddle/cache/compressor/IMG_1683725385284.jpg
        //StringBuilder mAttachmentPathBuilder = new StringBuilder();
        //             mAttachmentPathBuilder.append(mFile.getName() + "|");
        //             mAttachmentPathBuilder.append(FileUtils.getExtensionWithoutDot(offlineAttachmentFilePath) + "|");
        //             mAttachmentPathBuilder.append(mFile.length() + "|");
        //             mAttachmentPathBuilder.append(CommonUtilities.getUserID(mActivity, true) + "|");
        //             mAttachmentPathBuilder.append(offlineAttachmentFilePath);
        var fileSize = await File(path).length();
        String attachmentFilePathString = "$fileName|${Utility.getFileExtension(fileName)}|$fileSize|$userId|$path";
        emitState(OfflineAttachmentSuccessState(attachmentFilePathString, time: path));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  Future<void> uploadInlineAttachment(String projectID, String filePath, Map<dynamic, dynamic> dicAttachment, String appTypeID) async {
    try {
      emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
      String fileName = filePath.split("/").last;
      String path = await AppPathHelper().getTemporaryAttachmentPath(fileName: fileName, projectId: projectID);
      await createFileFromFile(filePath, path);
      if (kDebugMode) {
        print("Upload image:$path");
      }
      String randomNumber = Utility.generateRandomNumberForDocument();
      if (_documentRandomNumList.isNotEmpty && _documentRandomNumList.contains(randomNumber)) {
        randomNumber = Utility.generateRandomNumberForDocument();
      }
      _documentRandomNumList.add(randomNumber);

      if (isNetWorkConnected()) {
        Map<String, dynamic> data = {};
        data['projectid'] = projectID;
        data['msgId'] = dicAttachment['msgId'];
        data['eOriDraftMsgId'] = dicAttachment['eOriDraftMsgId'];
        data['editORI'] = dicAttachment['editORI'];
        data['save_draft'] = dicAttachment['save_draft'];

        if (dicAttachment.containsKey('xdoc_param_command')) {
          data['xdoc_param_command'] = 'Update_File';
        }

        if (dicAttachment.containsKey('xdoc_param_form_id')) {
          data['xdoc_param_form_id'] = dicAttachment['xdoc_param_form_id'];
        }

        if (dicAttachment.containsKey('xdoc_param_uploadfile_type')) {
          data['xdoc_param_uploadfile_type'] = dicAttachment['xdoc_param_uploadfile_type'];
        }

        if (dicAttachment.containsKey('fieldId') && dicAttachment['fieldId'] != null && dicAttachment['fieldId'].toString().isNotEmpty && dicAttachment['fieldId'].toString() != "null") {
          data['fieldId'] = dicAttachment['fieldId'];
        }
        else{
          data['fieldId'] = "attchment_xdoc_${randomNumber}my";
        }
        if (dicAttachment.containsKey('publishURL')) {
          data["publishURL"] = dicAttachment["publishURL"];
          data["isXsn"] = "true";
          data["UploadFile"] = await MultipartFile.fromFile(path);
          data["action"] = "1730";
        } else {
          data['attachTempFolderId'] = dicAttachment['attachTempFolderId'];
          data['autoPublishToFolder'] = dicAttachment['autoPublishToFolder'];
          data['isThumbnailSupports'] = dicAttachment['isThumbnailSupports'];
          data['uploadedAttachmentFileDetails'] = dicAttachment['uploadedAttachmentFileDetails'] ?? "";
          if (dicAttachment['isThumbnailSupports'] ?? false) {
            data['appTypeId'] = appTypeID;
          }
          data['fileType'] = '6';
          data["UploadFile"] = await MultipartFile.fromFile(path);
          data["fileSize"] = await File(path).length();
        }

        final result = await _createFormUseCase.uploadInlineAttachment(data);
        if (result is SUCCESS) {
          if (data.containsKey('isXsn')) {
            emitState(XSNInlineAttachmentSuccessState(result.data, time: path));
          } else {
            var responseJsonMap = json.decode(result.data);
            responseJsonMap["fieldId"] = data["fieldId"];
            responseJsonMap["attachTempFolderId"] = data["attachTempFolderId"];
            emitState(InlineAttachmentSuccessState(json.encode(responseJsonMap), time: path));
          }
        } else {
          emitState(ErrorState(StateRendererType.isValid, result.failureMessage ?? "Something went wrong", code: result.responseCode, time: path));
        }
      } else {
        Map<String, dynamic> data = {};
        String fId = "xdoc_${randomNumber}my";
        data['fieldId'] = "attchment_$fId";
        String attachTempFolderId = "0";
        String attachFileName = "${attachTempFolderId}_${fId}_$fileName";
        data['attachTempFolderId'] = attachTempFolderId;
        data['fileName'] = attachFileName;
        data['chunkUploaded'] = true;
        data['virus_infected'] = false;
        data['offlineAttachmentPath'] = path;

        final result = await _createFormUseCase.uploadInlineAttachment(data);
        if (result is SUCCESS) {
          emitState(InlineAttachmentSuccessState(json.encode(result.data), time: path));
        } else {
          emitState(ErrorState(StateRendererType.isValid, result.failureMessage ?? "Something went wrong", code: result.responseCode, time: path));
        }
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }
}
