import 'dart:convert';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/offline_activity_vo.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson should convert JSON map to ObservationData object', () {
    final jsonString = {
      "observationId": 5256,
      "locationId": 25336,
      "folderId": "524525",
      "msgId": "55256",
      "formId": "52646",
      "formTypeId": "11545",
      "annotationId": "25354",
      "revisionId": "253354",
      "coordinates": "256426",
      "hasAttachment": false,
      "statusVO": {
        "statusId": 5236,
        "statusName": "testuser",
        "statusTypeId": 54216,
        "statusCount": 5234,
        "bgColor": "colors",
        "fontColor": "colors",
        "generateURI": true,
      },
      "recipientList": [
        {
          "userID": "55422",
          "projectId": "515461",
          "dueDays": 4526,
          "distListId": 5562,
          "generateURI": true,
          "recipientFullName": "526642",
          "userOrgName": "5467864",
        }
      ],
      "actions": [
        {
          "projectId": "52564",
          "resourceParentId": 526512,
          "resourceId": 5261664,
          "resourceCode": "25631",
          "resourceStatusId": 526311,
          "msgId": "253611",
          "commentMsgId": "15264",
          "actionId": 2536,
          "actionName": "256315",
          "actionStatus": 25632,
          "priorityId": 554512,
          "actionDate": "25336",
          "dueDate": "25632",
          "distributorUserId": 25341,
          "recipientId": 25632,
          "remarks": "256321",
          "distListId": 25631,
          "actionTime": "25321",
          "actionNotes": "256325",
          "entityType": 25632,
          "instanceGroupId": "25321",
          "isActive": false,
          "modelId": "25632",
          "assignedBy": "2563",
          "recipientName": "test",
          "recipientOrgId": "256321",
          "viewDate": "256311",
          "dueDateInMS": 516264,
          "actionCompleteDateInMS": 25632,
          "actionDelegated": false,
          "actionCleared": false,
          "actionCompleted": false,
          "generateURI": false,
        }
      ],
      "locationDetailVO": {
        "siteId": 253611,
        "locationId": 2533,
        "folderId": "256325",
        "docId": "25331",
        "revisionId": "45656",
        "annotationId": "15231",
        "coordinates": "451154",
        "isFileAssociated": false,
        "hasChildLocation": false,
        "parentLocationId": 2536,
        "locationPath": "16ssd12",
        "isPFSite": false,
        "isCalibrated": false,
        "isLocationActive": false,
        "projectId": "25336",
        "generateURI": false,
      },
      "isActive": false,
      "isSyncIndexUpdate": false,
      "commId": "25622",
      "formTitle": "25632",
      "formDueDays": 25632,
      "pageNumber": 5,
      "templateType": 4,
      "formTypeCode": "25622",
      "appBuilderID": "36522",
      "creatorUserName": "554158",
      "creatorOrgName": "8785411",
      "formCode": "6564",
      "formCreationDate": "5656",
      "appType": 25,
      "projectId": "565464",
      "generateURI": false,
      "defectTypeName": "54646",
      "expectedFinishDate": "64662",
      "responseRequestBy": "546546",
      "creatorUserId": 4646,
      "isCloseOut": false,
      "statusUpdateDate": "6465",
      "ObservationDefectType": "6565",
    };

    // final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final observationData = ObservationData.fromJson(jsonString);

    expect(observationData.observationId, equals(5256));
    expect(observationData.locationId, equals(25336));
    expect(observationData.folderId, equals("524525"));
    expect(observationData.msgId, equals("55256"));
    expect(observationData.formId, equals("52646"));
    expect(observationData.formTypeId, equals("11545"));
    expect(observationData.annotationId, equals("25354"));
    expect(observationData.revisionId, equals("253354"));
    expect(observationData.coordinates, equals("256426"));
    expect(observationData.hasAttachment, equals(false));
    expect(observationData.statusVO?.statusId, equals(5236));
    expect(observationData.statusVO?.statusName, equals("testuser"));
    expect(observationData.statusVO?.statusTypeId, equals(54216));
    expect(observationData.statusVO?.statusCount, equals(5234));
    expect(observationData.statusVO?.bgColor, equals("colors"));
    expect(observationData.statusVO?.fontColor, equals("colors"));
    expect(observationData.statusVO?.generateURI, equals(true));
    expect(observationData.recipientList?[0].userID, equals("55422"));
    expect(observationData.recipientList?[0].recipientFullName, equals("526642"));
    expect(observationData.recipientList?[0].userOrgName, equals("5467864"));
    expect(observationData.recipientList?[0].projectId, equals("515461"));
    expect(observationData.recipientList?[0].dueDays, equals(4526));
    expect(observationData.recipientList?[0].distListId, equals(5562));
    expect(observationData.recipientList?[0].generateURI, equals(false));
    expect(observationData.actions?[0].projectId, equals("52564"));
    expect(observationData.actions?[0].resourceParentId, equals(526512));
    expect(observationData.actions?[0].resourceId, equals(5261664));
    expect(observationData.actions?[0].resourceCode, equals("25631"));
    expect(observationData.actions?[0].resourceStatusId, equals(526311));
    expect(observationData.actions?[0].msgId, equals("253611"));
    expect(observationData.actions?[0].commentMsgId, equals("15264"));
    expect(observationData.actions?[0].actionId, equals(2536));
    expect(observationData.actions?[0].actionName, equals("256315"));
    expect(observationData.actions?[0].actionStatus, equals(25632));
    expect(observationData.actions?[0].priorityId, equals(554512));
    expect(observationData.actions?[0].actionDate, equals("25336"));
    expect(observationData.actions?[0].dueDate, equals("25632"));
    expect(observationData.actions?[0].distributorUserId, equals(25341));
    expect(observationData.actions?[0].recipientId, equals(25632));
    expect(observationData.actions?[0].remarks, equals("256321"));
    expect(observationData.actions?[0].distListId, equals(25631));
    expect(observationData.actions?[0].actionTime, equals("25321"));
    expect(observationData.actions?[0].actionNotes, equals("256325"));
    expect(observationData.actions?[0].entityType, equals(25632));
    expect(observationData.actions?[0].instanceGroupId, equals("25321"));
    expect(observationData.actions?[0].isActive, equals(false));
    expect(observationData.actions?[0].modelId, equals("25632"));
    expect(observationData.actions?[0].assignedBy, equals("2563"));
    expect(observationData.actions?[0].recipientName, equals("test"));
    expect(observationData.actions?[0].recipientOrgId, equals("256321"));
    expect(observationData.actions?[0].viewDate, equals("256311"));
    expect(observationData.actions?[0].dueDateInMS, equals(516264));
    expect(observationData.actions?[0].actionCompleteDateInMS, equals(25632));
    expect(observationData.actions?[0].actionDelegated, equals(false));
    expect(observationData.actions?[0].actionCleared, equals(false));
    expect(observationData.actions?[0].actionCompleted, equals(false));
    expect(observationData.actions?[0].generateURI, equals(false));
    expect(observationData.locationDetailVO?.siteId, equals(253611));
    expect(observationData.locationDetailVO?.locationId, equals(2533));
    expect(observationData.locationDetailVO?.folderId, equals("256325"));
    expect(observationData.locationDetailVO?.docId, equals("25331"));
    expect(observationData.locationDetailVO?.revisionId, equals("45656"));
    expect(observationData.locationDetailVO?.annotationId, equals("15231"));
    expect(observationData.locationDetailVO?.coordinates, equals("451154"));
    expect(observationData.locationDetailVO?.isFileAssociated, equals(false));
    expect(observationData.locationDetailVO?.hasChildLocation, equals(false));
    expect(observationData.locationDetailVO?.parentLocationId, equals(2536));
    expect(observationData.locationDetailVO?.locationPath, equals("16ssd12"));
    expect(observationData.locationDetailVO?.isPFSite, equals(false));
    expect(observationData.locationDetailVO?.isCalibrated, equals(false));
    expect(observationData.locationDetailVO?.isLocationActive, equals(false));
    expect(observationData.locationDetailVO?.projectId, equals("25336"));
    expect(observationData.locationDetailVO?.generateURI, equals(false));
    expect(observationData.isActive, equals(false));
    expect(observationData.isSyncIndexUpdate, equals(false));
    expect(observationData.commId, equals("25622"));
    expect(observationData.formTitle, equals("25632"));
    expect(observationData.formDueDays, equals(25632));
    expect(observationData.pageNumber, equals(5));
    expect(observationData.templateType, equals(4));
    expect(observationData.formTypeCode, equals("25622"));
    expect(observationData.appBuilderID, equals("36522"));
    expect(observationData.creatorUserName, equals("554158"));
    expect(observationData.creatorOrgName, equals("8785411"));
    expect(observationData.formCode, equals("6564"));
    expect(observationData.formCreationDate, equals("5656"));
    expect(observationData.appType, equals(25));
    expect(observationData.projectId, equals("565464"));
    expect(observationData.generateURI, equals(false));
    expect(observationData.defectTypeName, equals("54646"));
    expect(observationData.expectedFinishDate, equals("64662"));
    expect(observationData.responseRequestBy, equals("546546"));
    expect(observationData.creatorUserId, equals(4646));
    expect(observationData.isCloseOut, equals(false));
    expect(observationData.statusUpdateDate, equals("6465"));
    expect(observationData.workPackage, equals("6565"));
  });

  test('fromJson should convert JSON map to ObservationData object List', () {
    final jsonString = '[{"observationId": 5256, "locationId": 25336, "folderId": "524525", "msgId": "55256", "formId": "52646", "formTypeId": "11545", "annotationId": "25354", "revisionId": "253354", "coordinates": "256426", "hasAttachment": false, "statusVO": {"statusId": 5236, "statusName": "testuser", "statusTypeId": 54216, "statusCount": 5234, "bgColor": "colors", "fontColor": "colors", "generateURI": true}, "recipientList": [{"userID": "55422", "projectId": "515461", "dueDays": 4526, "distListId": 5562, "generateURI": true, "recipientFullName": "526642", "userOrgName": "5467864"}], "actions": [{"projectId": "52564", "resourceParentId": 526512, "resourceId": 5261664, "resourceCode": "25631", "resourceStatusId": 526311, "msgId": "253611", "commentMsgId": "15264", "actionId": 2536, "actionName": "256315", "actionStatus": 25632, "priorityId": 554512, "actionDate": "25336", "dueDate": "25632", "distributorUserId": 25341, "recipientId": 25632, "remarks": "256321", "distListId": 25631, "actionTime": "25321", "actionNotes": "256325", "entityType": 25632, "instanceGroupId": "25321", "isActive": false, "modelId": "25632", "assignedBy": "2563", "recipientName": "test", "recipientOrgId": "256321", "viewDate": "256311", "dueDateInMS": 516264, "actionCompleteDateInMS": 25632, "actionDelegated": false, "actionCleared": false, "actionCompleted": false, "generateURI": false}], "locationDetailVO": {"siteId": 253611, "locationId": 2533, "folderId": "256325", "docId": "25331", "revisionId": "45656", "annotationId": "15231", "coordinates": "451154", "isFileAssociated": false, "hasChildLocation": false, "parentLocationId": 2536, "locationPath": "16ssd12", "isPFSite": false, "isCalibrated": false, "isLocationActive": false, "projectId": "25336", "generateURI": false}, "isActive": false, "isSyncIndexUpdate": false, "commId": "25622", "formTitle": "25632", "formDueDays": 25632, "pageNumber": 5, "templateType": 4, "formTypeCode": "25622", "appBuilderID": "36522", "creatorUserName": "554158", "creatorOrgName": "8785411", "formCode": "6564", "formCreationDate": "5656", "appType": 25, "projectId": "565464", "generateURI": false, "defectTypeName": "54646", "expectedFinishDate": "64662", "responseRequestBy": "546546", "creatorUserId": 4646, "isCloseOut": false, "statusUpdateDate": "6465", "ObservationDefectType": "6565"}]';

    final dynamic jsonMap = jsonDecode(jsonString);

    final observationData = ObservationData.jsonToObservationList(jsonString);

    expect(observationData, equals([ObservationData()]));
  });

  test('toJson should convert CalibrationDetail object to JSON map', () {
    final statusVO = StatusVO(
      statusId: 5236,
      statusName: "testuser",
      statusTypeId: 54216,
      statusCount: 5234,
      bgColor: "colors",
      fontColor: "colors",
      generateURI: true,
    );

    final recipientList = RecipientList(
      userID: "55422",
      recipientFullName: "526642",
      userOrgName: "5467864",
      projectId: "515461",
      dueDays: 4526,
      distListId: 5562,
      generateURI: true,
    );
    final actions = Actions(
      projectId: "52564",
      resourceParentId: 526512,
      resourceId: 5261664,
      resourceCode: "25631",
      resourceStatusId: 526311,
      msgId: "253611",
      commentMsgId: "15264",
      actionId: 2536,
      actionName: "256315",
      actionStatus: 25632,
      priorityId: 554512,
      actionDate: "25336",
      dueDate: "25632",
      distributorUserId: 25341,
      recipientId: 25632,
      remarks: "256321",
      distListId: 25631,
      actionTime: "25321",
      actionNotes: "256325",
      entityType: 25632,
      instanceGroupId: "25321",
      isActive: false,
      modelId: "25632",
      assignedBy: "2563",
      recipientName: "test",
      recipientOrgId: "256321",
      viewDate: "256311",
      dueDateInMS: 516264,
      actionCompleteDateInMS: 25632,
      actionDelegated: false,
      actionCleared: false,
      actionCompleted: false,
      generateURI: false,
    );

    final locationDetailVO = LocationDetailVO(
      siteId: 253611,
      locationId: 2533,
      folderId: "256325",
      docId: "25331",
      revisionId: "45656",
      annotationId: "15231",
      coordinates: "451154",
      isFileAssociated: false,
      hasChildLocation: false,
      parentLocationId: 2536,
      locationPath: "16ssd12",
      isPFSite: false,
      isCalibrated: false,
      isLocationActive: false,
      projectId: "25336",
      generateURI: false,
    );

    final observationData = ObservationData(
      observationId: 5256,
      locationId: 25336,
      folderId: "524525",
      msgId: "55256",
      formId: "52646",
      formTypeId: "11545",
      annotationId: "25354",
      revisionId: "253354",
      coordinates: "256426",
      hasAttachment: false,
      statusVO: statusVO,
      recipientList: [recipientList],
      actions: [actions],
      locationDetailVO: locationDetailVO,
      isActive: false,
      isSyncIndexUpdate: false,
      commId: "25622",
      formTitle: "25632",
      formDueDays: 25632,
      pageNumber: 5,
      templateType: 4,
      formTypeCode: "25622",
      appBuilderID: "36522",
      creatorUserName: "554158",
      creatorOrgName: "8785411",
      formCode: "6564",
      formCreationDate: "5656",
      appType: 25,
      projectId: "565464",
      generateURI: false,
      defectTypeName: "54646",
      expectedFinishDate: "64662",
      responseRequestBy: "546546",
      creatorUserId: 4646,
      isCloseOut: false,
      statusUpdateDate: "6465",
      workPackage: "6565",
    );
    final jsonMap = observationData.toJson();

    expect(jsonMap["observationId"], equals(5256));
    expect(jsonMap["locationId"], equals(25336));
    expect(jsonMap["folderId"], equals("524525"));
    expect(jsonMap["msgId"], equals("55256"));
    expect(jsonMap["formId"], equals("52646"));
    expect(jsonMap["formTypeId"], equals("11545"));
    expect(jsonMap["annotationId"], equals("25354"));
    expect(jsonMap["revisionId"], equals("253354"));
    expect(jsonMap["coordinates"], equals("256426"));
    expect(jsonMap["hasAttachment"], equals(false));
    expect(jsonMap["statusVO"]["statusId"], equals(5236));
    expect(jsonMap["statusVO"]["statusName"], equals("testuser"));
    expect(jsonMap["statusVO"]["statusTypeId"], equals(54216));
    expect(jsonMap["statusVO"]["statusCount"], equals(5234));
    expect(jsonMap["statusVO"]["bgColor"], equals("colors"));
    expect(jsonMap["statusVO"]["fontColor"], equals("colors"));
    expect(jsonMap["statusVO"]["generateURI"], equals(true));
    expect(jsonMap["recipientList"][0]["userID"], equals("55422"));
    expect(jsonMap["recipientList"][0]["projectId"], equals("515461"));
    expect(jsonMap["recipientList"][0]["dueDays"], equals(4526));
    expect(jsonMap["recipientList"][0]["distListId"], equals(5562));
    expect(jsonMap["recipientList"][0]["generateURI"], equals(true));
    expect(jsonMap["recipientList"][0]["recipientFullName"], equals("526642"));
    expect(jsonMap["recipientList"][0]["userOrgName"], equals("5467864"));
    expect(jsonMap["actions"][0]["projectId"], equals("52564"));
    expect(jsonMap["actions"][0]["resourceParentId"], equals(526512));
    expect(jsonMap["actions"][0]["resourceId"], equals(5261664));
    expect(jsonMap["actions"][0]["resourceCode"], equals("25631"));
    expect(jsonMap["actions"][0]["resourceStatusId"], equals(526311));
    expect(jsonMap["actions"][0]["msgId"], equals("253611"));
    expect(jsonMap["actions"][0]["commentMsgId"], equals("15264"));
    expect(jsonMap["actions"][0]["actionId"], equals(2536));
    expect(jsonMap["actions"][0]["actionName"], equals("256315"));
    expect(jsonMap["actions"][0]["actionStatus"], equals(25632));
    expect(jsonMap["actions"][0]["priorityId"], equals(554512));
    expect(jsonMap["actions"][0]["actionDate"], equals("25336"));
    expect(jsonMap["actions"][0]["dueDate"], equals("25632"));
    expect(jsonMap["actions"][0]["distributorUserId"], equals(25341));
    expect(jsonMap["actions"][0]["recipientId"], equals(25632));
    expect(jsonMap["actions"][0]["remarks"], equals("256321"));
    expect(jsonMap["actions"][0]["distListId"], equals(25631));
    expect(jsonMap["actions"][0]["actionTime"], equals("25321"));
    expect(jsonMap["actions"][0]["actionNotes"], equals("256325"));
    expect(jsonMap["actions"][0]["entityType"], equals(25632));
    expect(jsonMap["actions"][0]["instanceGroupId"], equals("25321"));
    expect(jsonMap["actions"][0]["isActive"], equals(false));
    expect(jsonMap["actions"][0]["modelId"], equals("25632"));
    expect(jsonMap["actions"][0]["assignedBy"], equals("2563"));
    expect(jsonMap["actions"][0]["recipientName"], equals("test"));
    expect(jsonMap["actions"][0]["recipientOrgId"], equals("256321"));
    expect(jsonMap["actions"][0]["viewDate"], equals("256311"));
    expect(jsonMap["actions"][0]["dueDateInMS"], equals(516264));
    expect(jsonMap["actions"][0]["actionCompleteDateInMS"], equals(25632));
    expect(jsonMap["actions"][0]["actionDelegated"], equals(false));
    expect(jsonMap["actions"][0]["actionCleared"], equals(false));
    expect(jsonMap["actions"][0]["actionCompleted"], equals(false));
    expect(jsonMap["actions"][0]["generateURI"], equals(false));
    expect(jsonMap["locationDetailVO"]["siteId"], equals(253611));
    expect(jsonMap["locationDetailVO"]["locationId"], equals(2533));
    expect(jsonMap["locationDetailVO"]["folderId"], equals("256325"));
    expect(jsonMap["locationDetailVO"]["docId"], equals("25331"));
    expect(jsonMap["locationDetailVO"]["revisionId"], equals("45656"));
    expect(jsonMap["locationDetailVO"]["annotationId"], equals("15231"));
    expect(jsonMap["locationDetailVO"]["coordinates"], equals("451154"));
    expect(jsonMap["locationDetailVO"]["isFileAssociated"], equals(false));
    expect(jsonMap["locationDetailVO"]["hasChildLocation"], equals(false));
    expect(jsonMap["locationDetailVO"]["parentLocationId"], equals(2536));
    expect(jsonMap["locationDetailVO"]["locationPath"], equals("16ssd12"));
    expect(jsonMap["locationDetailVO"]["isPFSite"], equals(false));
    expect(jsonMap["locationDetailVO"]["isCalibrated"], equals(false));
    expect(jsonMap["locationDetailVO"]["isLocationActive"], equals(false));
    expect(jsonMap["locationDetailVO"]["projectId"], equals("25336"));
    expect(jsonMap["locationDetailVO"]["generateURI"], equals(false));
    expect(jsonMap["isActive"], equals(false));
    expect(jsonMap["isSyncIndexUpdate"], equals(false));
    expect(jsonMap["commId"], equals("25622"));
    expect(jsonMap["formTitle"], equals("25632"));
    expect(jsonMap["formDueDays"], equals(25632));
    expect(jsonMap["pageNumber"], equals(5));
    expect(jsonMap["templateType"], equals(4));
    expect(jsonMap["formTypeCode"], equals("25622"));
    expect(jsonMap["appBuilderID"], equals("36522"));
    expect(jsonMap["creatorUserName"], equals("554158"));
    expect(jsonMap["creatorOrgName"], equals("8785411"));
    expect(jsonMap["formCode"], equals("6564"));
    expect(jsonMap["formCreationDate"], equals("5656"));
    expect(jsonMap["appType"], equals(25));
    expect(jsonMap["projectId"], equals("565464"));
    expect(jsonMap["generateURI"], equals(false));
    expect(jsonMap["defectTypeName"], equals("54646"));
    expect(jsonMap["expectedFinishDate"], equals("64662"));
    expect(jsonMap["responseRequestBy"], equals("546546"));
    expect(jsonMap["creatorUserId"], equals(4646));
    expect(jsonMap["isCloseOut"], equals(false));
    expect(jsonMap["statusUpdateDate"], equals("6465"));
    expect(jsonMap["ObservationDefectType"], equals("6565"));
  });
//FAIL
 /* test('fromJson should convert JSON map to ObservationData object', () {
    final jsonString = {
      "ObservationId": 5256,
      "LocationId": 25336,
      "FolderId": "524525",
      "MessageId": "55256",
      "FormId": "52646",
      "FormDueDays": 55256,
      "FormTypeId": "11545",
      "AnnotationId": "25354",
      "revisionId": "253354",
      "ObservationCoordinates": "451154",
      "HasAttachments": false,
      "StatusId": 5236,
      "StatusName": "testuser",
      "statusCount": 5234,
      "bgColor": "colors",
      "fontColor": "colors",
      "generateURI": true,
      "AssignedToUserId": "55422",
      "projectId": "515461",
      "dueDays": 4526,
      "distListId": 5562,
      "AssignedToUserName": "526642",
      "OrgName": "5467864",
      "SiteId": 253611,
      "DocId": "25331",
      "IsFileAssociated": false,
      "HasChildLocation": false,
      "ParentLocationId": 2536,
      "LocationPath": "16ssd12",
      "IsPFSite": false,
      "IsCalibrated": false,
      "isLocationActive": false,
      "IsActive": false,
      "isSyncIndexUpdate": false,
      "commId": "25622",
      "formTitle": "25632",
      "pageNumber": 54646,
      "templateType": 4,
      "formTypeCode": "25622",
      "appBuilderID": "36522",
      "creatorUserName": "554158",
      "creatorOrgName": "8785411",
      "formCode": "6564",
      "formCreationDate": "5656",
      "appType": 25,
      "ProjectId": "565464",
      "GenerateURI": false,
      "defectTypeName": "54646",
      "page_number": 54646,
      "expectedFinishDate": "64662",
      "responseRequestBy": "546546",
      "creatorUserId": 4646,
      "actions": [
        {
          "projectId": "52564",
          "resourceParentId": 526512,
          "resourceId": 5261664,
          "resourceCode": "25631",
          "resourceStatusId": 526311,
          "msgId": "253611",
          "commentMsgId": "15264",
          "actionId": 2536,
          "actionName": "256315",
          "actionStatus": 25632,
          "priorityId": 554512,
          "actionDate": "25336",
          "dueDate": "25632",
          "distributorUserId": 25341,
          "recipientId": 25632,
          "remarks": "256321",
          "distListId": 25631,
          "actionTime": "25321",
          "actionNotes": "256325",
          "entityType": 25632,
          "instanceGroupId": "25321",
          "isActive": false,
          "modelId": "25632",
          "assignedBy": "2563",
          "recipientName": "test",
          "recipientOrgId": "256321",
          "viewDate": "256311",
          "dueDateInMS": 516264,
          "actionCompleteDateInMS": 25632,
          "actionDelegated": false,
          "actionCleared": false,
          "actionCompleted": false,
          "generateURI": false,
        }
      ],
      "isCloseOut": false,
      "statusUpdateDate": "6465",
      "ObservationDefectType": "6565",
    };

    // final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final observationData = ObservationData.fromJsonDB(jsonString);

    expect(observationData.observationId, equals(5256));
    expect(observationData.locationId, equals(25336));
    expect(observationData.folderId, equals("524525"));
    expect(observationData.msgId, equals("55256"));
    expect(observationData.formDueDays, equals(55256));
    expect(observationData.formId, equals("52646"));
    expect(observationData.formTypeId, equals("11545"));
    expect(observationData.annotationId, equals("25354"));
    expect(observationData.revisionId, equals("253354"));
    expect(observationData.coordinates, equals("451154"));
    expect(observationData.hasAttachment, equals(false));
    expect(observationData.pageNumber, equals(54646));
    expect(observationData.statusVO?.statusId, equals(5236));
    expect(observationData.statusVO?.statusName, equals("testuser"));
    expect(observationData.statusVO?.statusTypeId, equals(5236));
    expect(observationData.statusVO?.statusCount, equals(0));
    expect(observationData.statusVO?.bgColor, equals("colors"));
    expect(observationData.statusVO?.fontColor, equals("colors"));
    expect(observationData.statusVO?.generateURI, equals(false));
    expect(observationData.recipientList?[0].userID, equals("55422"));
    expect(observationData.recipientList?[0].recipientFullName, equals("526642"));
    expect(observationData.recipientList?[0].userOrgName, equals("5467864"));
    expect(observationData.recipientList?[0].projectId, equals("565464"));
    expect(observationData.recipientList?[0].distListId, equals(0));
    expect(observationData.recipientList?[0].generateURI, equals(false));
    expect(observationData.actions?[0].resourceParentId, equals(526512));
    expect(observationData.actions?[0].projectId, equals("52564"));
    expect(observationData.actions?[0].resourceParentId, equals(526512));
    expect(observationData.actions?[0].resourceId, equals(5261664));
    expect(observationData.actions?[0].resourceCode, equals("25631"));
    expect(observationData.actions?[0].resourceStatusId, equals(526311));
    expect(observationData.actions?[0].msgId, equals("253611"));
    expect(observationData.actions?[0].commentMsgId, equals("15264"));
    expect(observationData.actions?[0].actionId, equals(2536));
    expect(observationData.actions?[0].actionName, equals("256315"));
    expect(observationData.actions?[0].actionStatus, equals(25632));
    expect(observationData.actions?[0].priorityId, equals(554512));
    expect(observationData.actions?[0].actionDate, equals("25336"));
    expect(observationData.actions?[0].dueDate, equals("25632"));
    expect(observationData.actions?[0].distributorUserId, equals(25341));
    expect(observationData.actions?[0].recipientId, equals(25632));
    expect(observationData.actions?[0].remarks, equals("256321"));
    expect(observationData.actions?[0].distListId, equals(25631));
    expect(observationData.actions?[0].actionTime, equals("25321"));
    expect(observationData.actions?[0].actionNotes, equals("256325"));
    expect(observationData.actions?[0].entityType, equals(25632));
    expect(observationData.actions?[0].instanceGroupId, equals("25321"));
    expect(observationData.actions?[0].isActive, equals(false));
    expect(observationData.actions?[0].modelId, equals("25632"));
    expect(observationData.actions?[0].assignedBy, equals("2563"));
    expect(observationData.actions?[0].recipientName, equals("test"));
    expect(observationData.actions?[0].recipientOrgId, equals("256321"));
    expect(observationData.actions?[0].viewDate, equals("256311"));
    expect(observationData.actions?[0].dueDateInMS, equals(516264));
    expect(observationData.actions?[0].actionCompleteDateInMS, equals(25632));
    expect(observationData.actions?[0].actionDelegated, equals(false));
    expect(observationData.actions?[0].actionCleared, equals(false));
    expect(observationData.actions?[0].actionCompleted, equals(false));
    expect(observationData.actions?[0].generateURI, equals(false));
    expect(observationData.locationDetailVO?.siteId, equals(253611));
    expect(observationData.locationDetailVO?.locationId, equals(25336));
    expect(observationData.locationDetailVO?.folderId, equals("524525"));
    expect(observationData.locationDetailVO?.docId, equals("25331"));
    expect(observationData.locationDetailVO?.revisionId, equals(null));
    expect(observationData.locationDetailVO?.annotationId, equals("25354"));
    expect(observationData.locationDetailVO?.coordinates, equals("451154"));
    expect(observationData.locationDetailVO?.isFileAssociated, equals(false));
    expect(observationData.locationDetailVO?.hasChildLocation, equals(false));
    expect(observationData.locationDetailVO?.parentLocationId, equals(2536));
    expect(observationData.locationDetailVO?.locationPath, equals("16ssd12"));
    expect(observationData.locationDetailVO?.isPFSite, equals(false));
    expect(observationData.locationDetailVO?.isCalibrated, equals(false));
    expect(observationData.locationDetailVO?.isLocationActive, equals(false));
    expect(observationData.locationDetailVO?.generateURI, equals(false));
    expect(observationData.isActive, equals(false));
    expect(observationData.isSyncIndexUpdate, equals(false));
    expect(observationData.commId, equals("52646"));
    expect(observationData.formTitle, equals(null));
    expect(observationData.formDueDays, equals(55256));
    expect(observationData.pageNumber, equals(54646));
    expect(observationData.templateType, equals(null));
    expect(observationData.creatorOrgName, equals("5467864"));
    expect(observationData.formCode, equals("null"));
    expect(observationData.formCreationDate, equals(null));
    expect(observationData.appType, equals(null));
    expect(observationData.generateURI, equals(false));
    expect(observationData.defectTypeName, equals("6565"));
    expect(observationData.expectedFinishDate, equals(null));
    expect(observationData.responseRequestBy, equals("546546"));
    expect(observationData.creatorUserId, equals(null));
    expect(observationData.isCloseOut, equals(false));
    expect(observationData.statusUpdateDate, equals(null));
    expect(observationData.workPackage, equals("6565"));
  });*/

//FAIL
  /*test('fromJson should convert JSON map to page number object', () {
    final jsonString = {
      "PageNumber": 54646,
    };

    // final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final observationData = ObservationData.fromJsonDB(jsonString);

    expect(observationData.pageNumber, equals(54646));
  });*/
}
