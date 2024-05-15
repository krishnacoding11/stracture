import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:field/data/remote/site/create_form_remote_repository.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import 'mock_dio_adpater.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CreateFormRemoteRepository mockCreateFormRemoteRepository;
  late MockDioAdapter mockDioAdapter;

  configurationMethodChannel() {
    MockMethodChannel().setNotificationMethodChannel();
    di.init(test: true);
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    MockMethodChannel().setBuildFlavorMethodChannel();
    mockCreateFormRemoteRepository = CreateFormRemoteRepository();
    AConstants.loadProperty();
    mockDioAdapter = MockDioAdapter();
  }

  Future<Map<String, dynamic>> getUploadAttachmentMap() async {
    String filePath = fixtureFile("test.pdf");
    return <String, dynamic>{'appType': "2", 'checkHashing': 'false', 'extra': '', 'isMac': 'false', 'projectIds': '-2', 'totalFiles': '0', 'attachTempFolderId': "11638014", 'projectid': "2089700\$\$AwdiSe", "files": await MultipartFile.fromFile(filePath)};
  }

  group("Create Form Remote repository Implementation: ", () {
    configurationMethodChannel();

    test("Test Case - Download Inline Attachment", () async {
      mockDioAdapter.dioAdapter.onPost(AConstants.formPermissionUrl, (server) => server.reply(200, "Downloaded"), data: {});
      final result = await mockCreateFormRemoteRepository.downloadInLineAttachment({}, mockDioAdapter.dio);
      expect(result.responseCode, 200);
    });

    test("Test Case - Upload Attachment", () async {
      final dataMap = await getUploadAttachmentMap();
      dataMap.remove("projectid");
      FormData formData = FormData.fromMap(dataMap);
      final response = "20211116_161135.jpg|jpg|1783403|2017529||";
      mockDioAdapter.dioAdapter.onPost("${AConstants.uploadAttachmentUrl}?action_id=1125&isUploadAttachmentInTemp=true&project_id=2089700\$\$AwdiSe&appType=2", (server) => server.reply(200, response), data: formData);
      final result = await mockCreateFormRemoteRepository.uploadAttachment(await getUploadAttachmentMap(), mockDioAdapter.dio);
      expect(result.data, response);
    });

    test("Test Case - Upload Inline Attachment", () async {
      String filePath = fixtureFile("test.pdf");
      final dataMap = <String, dynamic>{"projectid": "2089700\$\$AwdiSe", "msgId": "12350939\$\$6Gt0kN", "eOriDraftMsgId": "0\$\$A5tBQd", "editORI": "false", "save_draft": "0", "fieldId": "attchment_xdoc_0_2_3_9_my", "attachTempFolderId": "11639150", "autoPublishToFolder": false, "isThumbnailSupports": true, "uploadedAttachmentFileDetails": "", "appTypeId": "1", "fileType": "6", "UploadFile": await MultipartFile.fromFile(filePath), "fileSize": await File(filePath).length()};
      FormData formData = FormData.fromMap(dataMap);
      final response = '{"fileName":"12350939_xdoc_0_2_3_9_my_CAP4662848286400558199.jpg","virus_infected":"false","chunkUploaded":"true","uploadedAttachmentFileDetails":"12350939_xdoc_0_2_3_9_my_CAP4662848286400558199.jpg|jpg|451370|0||"}';
      mockDioAdapter.dioAdapter.onPost("${AConstants.uploadInlineAttachmentUrl}?action_id=1203", (server) => server.reply(200, response), data: formData);
      final result = await mockCreateFormRemoteRepository.uploadInlineAttachment(dataMap, mockDioAdapter.dio);
      expect(result.data, response);
    });

    test("Test Case - Upload Inline Attachment For XSN Form", () async {
      String filePath = fixtureFile("test.pdf");
      final dataMap = <String, dynamic>{"projectid": "2063696\$\$Kr1NsU", "project_id": "2063696\$\$Kr1NsU", "msgId": "12354084\$\$mBGZv5", "eOriDraftMsgId": "0\$\$axTmz5", "editORI": "false", "save_draft": "0", "xdoc_param_command": "Update_File", "xdoc_param_form_id": "092fd0d1-19d7-4a43-ac67-de3439ddb368", "xdoc_param_uploadfile_type": "xFileAttachment", "fieldId": "attchment_xdoc_0_39_0_1_my", "publishURL": "2356970", "isXsn": "true", "UploadFile": await MultipartFile.fromFile(filePath), "action": "1730"};
      FormData formData = FormData.fromMap(dataMap);
      final response = fixture("upload_inline_attachment_xsn_response.html");
      mockDioAdapter.dioAdapter.onPost(AConstants.uploadInlineAttachmentUrlXSN, (server) => server.reply(200, response), data: formData);
      final result = await mockCreateFormRemoteRepository.uploadInlineAttachment(dataMap, mockDioAdapter.dio);
      expect(result.data, response);
    });

    test("Test case - Save Form To Server", () async {
      final dataMap = jsonDecode(fixture("save_form_to_server_request_params.json"));
      dataMap["networkExecutionType"] = NetworkExecutionType.SYNC;
      FormData formData = FormData.fromMap(dataMap);
      final response = fixture("save_form_to_server_response.json");
      mockDioAdapter.dioAdapter.onPost(AConstants.saveForm, (server) => server.reply(200, response), data: formData);
      final result = await mockCreateFormRemoteRepository.saveFormToServer(dataMap, mockDioAdapter.dio);
      expect(result.data, response);
    });

    test("Test Case - Form Distribution Action Task To Server", () async {
      NetworkService.csrfTokenKey = <String, String>{"CSRF_SECURITY_TOKEN": "NjAwMDAwOjA5MWY2YjljOWY0ZjJjNjhjYjBmZDk2YWZjZTZmYTU1"};
      final dataMap = <String, dynamic>{"action_id": 19, "projectId": "2130192", "dist_list": "{\"nonReviewDraftDistGroupUsers\":[],\"reviewDraftDistGroupUsers\":[],\"selectedDistGroups\":\"\",\"selectedD...", "save_draft": false, "folderId": "0", "msg_num": "001", "msg_type": "ORI", "rmft": "11076066", "msg_type_code": "ORI", "msgId": "12285861", "formId": "11588148", "commitType": 2, "originatorId": 2017529, "parent_msg_id": "0", "statusId": 2, "noAccessUsers": "", "actionId": "6", "appTypeId": 2, "formTypeId": "11076066", "form_type_id": "11076066", "form_template_type": 2, "locationId": 183682, "observationId": 105610, "projectIds": "2130192", "checkHashing": "false", "CreateDateInMS": "1691561617061", "offlineMessageId": "12285861", "isFromAndroidApp": true, "offlineFormCreatedDateInMS": "1691561617061"};
      final response = '{"status":"Apps Distributed Successfully"}';
      mockDioAdapter.dioAdapter.onPost(
        AConstants.formDistAction,
        (server) => server.reply(200, response),
        data: dataMap,
        headers: NetworkService.csrfTokenKey,
      );
      final result = await mockCreateFormRemoteRepository.formDistActionTaskToServer(dataMap, mockDioAdapter.dio);
      expect(result.data, response);
    });

    test("Test Case - Form Discard Draft Action Task To Server", () async {
      NetworkService.csrfTokenKey = <String, String>{"CSRF_SECURITY_TOKEN": "NjAwMDAwOjA5MWY2YjljOWY0ZjJjNjhjYjBmZDk2YWZjZTZmYTU1"};
      final dataMap = <String, dynamic>{"msgId": "12291749", "assocRevIds": "", "action_id": 963, "appTypeId": "2", "isFromApps": true, "projectId": "2130192", "formId": "11592856", "formTypeId": "11079409", "observationId": null, "locationId": "183682", "CreateDateInMS": "1691570473473", "offlineMessageId": "12291749"};
      mockDioAdapter.dioAdapter.onPost(
        AConstants.discardDraftUri,
        (server) => server.reply(200, "true"),
        data: dataMap,
        headers: NetworkService.csrfTokenKey,
      );
      final result = await mockCreateFormRemoteRepository.formOtherActionTaskToServer(dataMap, mockDioAdapter.dio);
      expect(result.data, "true");
    });

    test("Test Case - Form Status Change Task To Server", () async {
      NetworkService.csrfTokenKey = <String, String>{"CSRF_SECURITY_TOKEN": "NjAwMDAwOjA5MWY2YjljOWY0ZjJjNjhjYjBmZDk2YWZjZTZmYTU1"};
      final dataMap = <String, dynamic>{"action_id": 572, "formNum": "2", "formTypeId": "11154276", "newStatusReason": "Tryon to change", "projectId": "2130192", "selectedFormId": 11640939, "statusName": "Resolved", "statusId": 1002, "formId": "11640939", "appTypeId": 2, "locationId": 177295, "observationId": 113347, "projectIds": "2130192", "checkHashing": "false", "CreateDateInMS": "1691586807427"};
      mockDioAdapter.dioAdapter.onPost(
        AConstants.formStatusChange,
        (server) => server.reply(200, "Status Change Successfully"),
        data: dataMap,
        headers: NetworkService.csrfTokenKey,
      );
      final result = await mockCreateFormRemoteRepository.formStatusChangeTaskToServer(dataMap, mockDioAdapter.dio);
      expect(result.data, "Status Change Successfully");
    });
  });
}
