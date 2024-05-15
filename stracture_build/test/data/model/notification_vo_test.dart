import 'dart:convert';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/form_status_history_vo.dart';
import 'package:field/data/model/notification_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationVo', () {
    test('Constructor should initialize NotificationVo instance with valid input', () {
      final vo = NotificationVo(
        activityBy: "test",
        activityDate: "test",
        activityDateTime: "test timew",
        activityFeedId: "test",
        activityName: "test user",
        activityTypeId: "4445gg",
        commentMsgId: "5414",
        dcId: "ssds1251515",
        docId: "51511",
        docRef: "fest test",
        documentTypeId: "4525652",
        folderId: "125426",
        folderName: "test",
        id: "145263",
        imgUpdatedDate: "1452563",
        isDashboardNotificationRead: false,
        isPasswordProtected: false,
        projectId: "528252",
        projectName: "test",
        recipientId: "45654",
        resourceTypeId: "415263",
        revisionId: "458722",
        uploadFilename: "test",
        userId: "456123",
        viewerId: "125423",
        hasOnlineViewerSupport: false,
      );

      expect(vo.activityBy, equals("test"));
      expect(vo.activityDate, equals("test"));
      expect(vo.activityDateTime, equals("test timew"));
      expect(vo.activityFeedId, equals('test'));
      expect(vo.activityName, equals("test user"));
      expect(vo.activityTypeId, equals("4445gg"));
      expect(vo.commentMsgId, equals("5414"));
      expect(vo.dcId, equals("ssds1251515"));
      expect(vo.docId, equals("51511"));
      expect(vo.docRef, equals("fest test"));
      expect(vo.documentTypeId, equals("4525652"));
      expect(vo.folderId, equals("125426"));
      expect(vo.folderName, equals("test"));
      expect(vo.id, equals("145263"));
      expect(vo.imgUpdatedDate, equals("1452563"));
      expect(vo.isDashboardNotificationRead, equals(false));
      expect(vo.isPasswordProtected, equals(false));
      expect(vo.projectId, equals("528252"));
      expect(vo.projectName, equals("test"));
      expect(vo.recipientId, equals("45654"));
      expect(vo.resourceTypeId, equals("415263"));
      expect(vo.revisionId, equals("458722"));
      expect(vo.uploadFilename, equals("test"));
      expect(vo.userId, equals("456123"));
      expect(vo.viewerId, equals("125423"));
      expect(vo.hasOnlineViewerSupport, equals(false));
    });

    test('fromMap should initialize NotificationVo instance with valid input for NotificationVo', () {
      final mapData = {
        'activityBy': "test",
        'activityDate': 'test',
        'activityDateTime': 'test timew',
        'activityFeedId': "test",
        'activityName': "test user",
        'activityTypeId': "4445gg",
        'commentMsgId': "5414",
        'dcId': "ssds1251515",
        'doc_id': "51511",
        'doc_ref': "fest test",
        'document_type_id': "4525652",
        'folder_id': "125426",
        'folder_name': "test",
        'id': "145263",
        'imgUpdatedDate': "1452563",
        'isDashboardNotificationRead': false,
        'isPasswordProtected': false,
        'project_id': "528252",
        'project_name': "test",
        'recipientId': "45654",
        'resourceTypeId': "415263",
        'revision_id': "458722",
        'upload_filename': "test",
        'user_id': "456123",
        'viewer_id': "125423",
        'hasOnlineViewerSupport': false,
      };

      final vo = NotificationVo.fromJson(mapData);

      expect(vo.activityBy, equals("test"));
      expect(vo.activityDate, equals("test"));
      expect(vo.activityDateTime, equals("test timew"));
      expect(vo.activityFeedId, equals('test'));
      expect(vo.activityName, equals("test user"));
      expect(vo.activityTypeId, equals("4445gg"));
      expect(vo.commentMsgId, equals("5414"));
      expect(vo.dcId, equals("ssds1251515"));
      expect(vo.docId, equals("51511"));
      expect(vo.docRef, equals("fest test"));
      expect(vo.documentTypeId, equals("4525652"));
      expect(vo.folderId, equals("125426"));
      expect(vo.folderName, equals("test"));
      expect(vo.id, equals("145263"));
      expect(vo.imgUpdatedDate, equals("1452563"));
      expect(vo.isDashboardNotificationRead, equals(false));
      expect(vo.isPasswordProtected, equals(false));
      expect(vo.projectId, equals("528252"));
      expect(vo.projectName, equals("test"));
      expect(vo.recipientId, equals("45654"));
      expect(vo.resourceTypeId, equals("415263"));
      expect(vo.revisionId, equals("458722"));
      expect(vo.uploadFilename, equals("test"));
      expect(vo.userId, equals("456123"));
      expect(vo.viewerId, equals("125423"));
      expect(vo.hasOnlineViewerSupport, equals(false));
    });
    test('copyWith should return a new QRCodeDataVo object with updated values', () {
      final vo = NotificationVo(
        activityBy: "test",
        activityDate: "test",
        activityDateTime: "test timew",
        activityFeedId: "test",
        activityName: "test user",
        activityTypeId: "4445gg",
        commentMsgId: "5414",
        dcId: "ssds1251515",
        docId: "51511",
        docRef: "fest test",
        documentTypeId: "4525652",
        folderId: "125426",
        folderName: "test",
        id: "145263",
        imgUpdatedDate: "1452563",
        isDashboardNotificationRead: false,
        isPasswordProtected: false,
        projectId: "528252",
        projectName: "test",
        recipientId: "45654",
        resourceTypeId: "415263",
        revisionId: "458722",
        uploadFilename: "test",
        userId: "456123",
        viewerId: "125423",
        hasOnlineViewerSupport: false,
      );

      final updated = vo.copyWith();

      expect(updated.activityBy, equals("test"));
      expect(updated.activityDate, equals("test"));
      expect(updated.activityDateTime, equals("test timew"));
      expect(updated.activityFeedId, equals('test'));
      expect(updated.activityName, equals("test user"));
      expect(updated.activityTypeId, equals("4445gg"));
      expect(updated.commentMsgId, equals("5414"));
      expect(updated.dcId, equals("ssds1251515"));
      expect(updated.docId, equals("51511"));
      expect(updated.docRef, equals("fest test"));
      expect(updated.documentTypeId, equals("4525652"));
      expect(updated.folderId, equals("125426"));
      expect(updated.folderName, equals("test"));
      expect(updated.id, equals("145263"));
      expect(updated.imgUpdatedDate, equals("1452563"));
      expect(updated.isDashboardNotificationRead, equals(false));
      expect(updated.isPasswordProtected, equals(false));
      expect(updated.projectId, equals("528252"));
      expect(updated.projectName, equals("test"));
      expect(updated.recipientId, equals("45654"));
      expect(updated.resourceTypeId, equals("415263"));
      expect(updated.revisionId, equals("458722"));
      expect(updated.uploadFilename, equals("test"));
      expect(updated.userId, equals("456123"));
      expect(updated.viewerId, equals("125423"));
      expect(updated.hasOnlineViewerSupport, equals(false));
    });
  });
  test('notificationVo.toJson should convert a notificationVo object to JSON', () {
    // Create a sample FloorDetail object
    final notificationVo = NotificationVo(
      activityBy: "test",
      activityDate: "test",
      activityDateTime: "test timew",
      activityFeedId: "test",
      activityName: "test user",
      activityTypeId: "4445gg",
      commentMsgId: "5414",
      dcId: "ssds1251515",
      docId: "51511",
      docRef: "fest test",
      documentTypeId: "4525652",
      folderId: "125426",
      folderName: "test",
      id: "145263",
      imgUpdatedDate: "1452563",
      isDashboardNotificationRead: false,
      isPasswordProtected: false,
      projectId: "528252",
      projectName: "test",
      recipientId: "45654",
      resourceTypeId: "415263",
      revisionId: "458722",
      uploadFilename: "test",
      userId: "456123",
      viewerId: "125423",
      hasOnlineViewerSupport: false,
    );

    // Convert the FloorDetail object to JSON
    final json = notificationVo.toJson();

    // Check if the JSON object is correctly generated
    expect(json['activityBy'], "test");
    expect(json['activityDate'], "test");
    expect(json['activityDateTime'], "test timew");
    expect(json['activityFeedId'], "test");
    expect(json['activityName'], "test user");
    expect(json['activityTypeId'], "4445gg");
    expect(json['commentMsgId'], "5414");
    expect(json['dcId'], "ssds1251515");
    expect(json['doc_id'], "51511");
    expect(json['doc_ref'], "fest test");
    expect(json['document_type_id'], "4525652");
    expect(json['folder_id'], "125426");
    expect(json['folder_name'], "test");
    expect(json['id'], "145263");
    expect(json['imgUpdatedDate'], "1452563");
    expect(json['isDashboardNotificationRead'], false);
    expect(json['isPasswordProtected'], false);
    expect(json['project_id'], "528252");
    expect(json['project_name'], "test");
    expect(json['recipientId'], "45654");
    expect(json['resourceTypeId'], "415263");
    expect(json['revision_id'], "458722");
    expect(json['upload_filename'], "test");
    expect(json['user_id'], "456123");
    expect(json['viewer_id'], "125423");
    expect(json['hasOnlineViewerSupport'], false);
  });
}
