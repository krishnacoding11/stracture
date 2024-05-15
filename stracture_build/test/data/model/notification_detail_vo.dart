import 'package:field/data/model/notification_detail_vo.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationDetailVo', () {
    test(
        'Constructor should initialize NotificationDetailVo instance with valid input',
            () {
          final vo = NotificationDetailVo(
            projectId: "2089700\$\$Otjm0d",
            projectName: "KrupalField19.8UK",
            code: "STS1748",
            commId: "11555629\$\$Rp39ND",
            formId: "11555629\$\$8yZmLN",
            title: "test n8",
            userID: "758244\$\$OiBKDu",
            orgId: "3\$\$A3VKEZ",
            firstName: "Krupal",
            lastName: "Patel (5345)",
            orgName: "Asite Solutions",
            originator:
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            originatorDisplayName: "Krupal Patel (5345), Asite Solutions",
            noOfActions: 0,
            observationId: 102652,
            locationId: 25016,
            pfLocFolderId: 0,
            updated: "01-Jun-2023#08:58 CST",
            hasAttachments: false,
            attachmentImageName: "",
            msgCode: "ORI001",
            typeImage: "icons/form.png",
            docType: "Apps",
            formTypeName: "Site Tasks",
            status: "Open",
            responseRequestBy: "08-Jun-2023#13:29 CST",
            hasDocAssocations: false,
            hasBimViewAssociations: false,
            hasBimListAssociations: false,
            hasFormAssocations: false,
            hasCommentAssocations: false,
            formHasAssocAttach: false,
            msgHasAssocAttach: false,
            formCreationDate: "01-Jun-2023#08:58 CST",
            msgCreatedDate: "2023-06-01T14:58:51Z",
            folderId: "0\$\$i8WujQ",
            msgId: "12244122\$\$wM8wRc",
            parentMsgId: 0,
            msgTypeId: 1,
            msgStatusId: 20,
            indent: -1,
            formTypeId: "10946131\$\$x73bKR",
            formNum: 1748,
            msgOriginatorId: 758244,
            formPrintEnabled: false,
            showPrintIcon: 0,
            templateType: 2,
            instanceGroupId: "10443853\$\$Jgvh7C",
            noOfMessages: 0,
            isDraft: false,
            dcId: 1,
            statusid: 1001,
            originatorId: 758244,
            isCloseOut: false,
            isStatusChangeRestricted: false,
            projectAPDFolderId: "0\$\$i8WujQ",
            allowReopenForm: false,
            hasOverallStatus: false,
            formUserSet: [],
            canOrigChangeStatus: false,
            canControllerChangeStatus: false,
            appType: "Field",
            msgTypeCode: "ORI",
            formGroupName: "Site Tasks",
            id: "STS1748",
            statusText: "Open",
            statusChangeUserId: 0,
            statusUpdateDate: "01-Jun-2023#08:58 CST",
            statusChangeUserName: "Krupal Patel (5345)",
            statusChangeUserPic:
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            statusChangeUserEmail: "krupalpatel@asite.com",
            statusChangeUserOrg: "Asite Solutions",
            originatorEmail: "krupalpatel@asite.com",
            invoiceCountAgainstOrder: "-1",
            invoiceColourCode: "-1",
            controllerUserId: 0,
            offlineFormId: "-1",
            updatedDateInMS: 1685627934000,
            formCreationDateInMS: 1685627931000,
            msgCreatedDateInMS: 0,
            flagType: 0,
            appTypeId: "2",
            latestDraftId: "0\$\$76WsW8",
            flagTypeImageName: "flag_type/flag_0.png",
            messageTypeImageName: "icons/form.png",
            workflowStage: "",
            workflowStatus: "",
            hasFormAccess: false,
            ownerOrgName: "Asite Solutions",
            ownerOrgId: 3,
            originatorOrgId: 3,
            msgUserOrgId: 3,
            msgUserOrgName: "Asite Solutions",
            msgUserName: "Krupal Patel (5345)",
            originatorName: "Krupal Patel (5345)",
            isPublic: false,
            isThumbnailSupports: false,
            canAccessHistory: true,
            projectStatusId: 5,
            generateURI: true,
          );

          expect(vo.projectId, equals("2089700\$\$Otjm0d"));
          expect(vo.projectName, equals("KrupalField19.8UK"));
          expect(vo.code, equals("STS1748"));
          expect(vo.commId, equals('11555629\$\$Rp39ND'));
          expect(vo.formId, equals("11555629\$\$8yZmLN"));
          expect(vo.title, equals("test n8"));
          expect(vo.userID, equals("758244\$\$OiBKDu"));
          expect(vo.orgId, equals("3\$\$A3VKEZ"));
          expect(vo.firstName, equals("Krupal"));
          expect(vo.lastName, equals("Patel (5345)"));
          expect(vo.orgName, equals("Asite Solutions"));
          expect(
              vo.originator,
              equals(
                  "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal"));
          expect(vo.originatorDisplayName,
              equals("Krupal Patel (5345), Asite Solutions"));
          expect(vo.noOfActions, equals(0));
          expect(vo.observationId, equals(102652));
          expect(vo.locationId, equals(25016));
          expect(vo.pfLocFolderId, equals(0));
          expect(vo.updated, equals("01-Jun-2023#08:58 CST"));
          expect(vo.hasAttachments, equals(false));
          expect(vo.attachmentImageName, equals(""));
          expect(vo.msgCode, equals("ORI001"));
          expect(vo.typeImage, equals("icons/form.png"));
          expect(vo.docType, equals("Apps"));
          expect(vo.formTypeName, equals("Site Tasks"));
          expect(vo.status, equals("Open"));
          expect(vo.responseRequestBy, equals("08-Jun-2023#13:29 CST"));
          expect(vo.hasDocAssocations, equals(false));
          expect(vo.hasBimViewAssociations, equals(false));
          expect(vo.hasBimListAssociations, equals(false));
          expect(vo.hasFormAssocations, equals(false));
          expect(vo.hasCommentAssocations, equals(false));
          expect(vo.formHasAssocAttach, equals(false));
          expect(vo.msgHasAssocAttach, equals(false));
          expect(vo.formCreationDate, equals("01-Jun-2023#08:58 CST"));
          expect(vo.msgCreatedDate, equals("2023-06-01T14:58:51Z"));
          expect(vo.folderId, equals("0\$\$i8WujQ"));
          expect(vo.msgId, equals("12244122\$\$wM8wRc"));
          expect(vo.parentMsgId, equals(0));
          expect(vo.msgTypeId, equals(1));
          expect(vo.msgStatusId, equals(20));
          expect(vo.indent, equals(-1));
          expect(vo.formTypeId, equals("10946131\$\$x73bKR"));
          expect(vo.formNum, equals(1748));
          expect(vo.msgOriginatorId, equals(758244));
          expect(vo.formPrintEnabled, equals(false));
          expect(vo.showPrintIcon, equals(0));
          expect(vo.templateType, equals(2));
          expect(vo.instanceGroupId, equals("10443853\$\$Jgvh7C"));
          expect(vo.noOfMessages, equals(0));
          expect(vo.isDraft, equals(false));
          expect(vo.dcId, equals(1));
          expect(vo.statusid, equals(1001));
          expect(vo.originatorId, equals(758244));
          expect(vo.isCloseOut, equals(false));
          expect(vo.isStatusChangeRestricted, equals(false));
          expect(vo.projectAPDFolderId, equals("0\$\$i8WujQ"));
          expect(vo.allowReopenForm, equals(false));
          expect(vo.hasOverallStatus, equals(false));
          expect(vo.formUserSet, equals([]));
          expect(vo.canOrigChangeStatus, equals(false));
          expect(vo.canControllerChangeStatus, equals(false));
          expect(vo.appType, equals("Field"));
          expect(vo.msgTypeCode, equals("ORI"));
          expect(vo.formGroupName, equals("Site Tasks"));
          expect(vo.id, equals("STS1748"));
          expect(vo.statusText, equals("Open"));
          expect(vo.statusChangeUserId, equals(0));
          expect(vo.statusUpdateDate, equals("01-Jun-2023#08:58 CST"));
          expect(vo.statusChangeUserName, equals("Krupal Patel (5345)"));
          expect(
              vo.statusChangeUserPic,
              equals(
                  "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal"));
          expect(vo.statusChangeUserEmail, equals("krupalpatel@asite.com"));
          expect(vo.statusChangeUserOrg, equals("Asite Solutions"));
          expect(vo.originatorEmail, equals("krupalpatel@asite.com"));
          expect(vo.invoiceCountAgainstOrder, equals("-1"));
          expect(vo.invoiceColourCode, equals("-1"));
          expect(vo.controllerUserId, equals(0));
          expect(vo.offlineFormId, equals("-1"));
          expect(vo.updatedDateInMS, equals(1685627934000));
          expect(vo.formCreationDateInMS, equals(1685627931000));
          expect(vo.msgCreatedDateInMS, equals(0));
          expect(vo.flagType, equals(0));
          expect(vo.appTypeId, equals("2"));
          expect(vo.latestDraftId, equals("0\$\$76WsW8"));
          expect(vo.flagTypeImageName, equals("flag_type/flag_0.png"));
          expect(vo.messageTypeImageName, equals("icons/form.png"));
          expect(vo.workflowStage, equals(""));
          expect(vo.workflowStatus, equals(""));
          expect(vo.hasFormAccess, equals(false));
          expect(vo.ownerOrgName, equals("Asite Solutions"));
          expect(vo.ownerOrgId, equals(3));
          expect(vo.originatorOrgId, equals(3));
          expect(vo.msgUserOrgId, equals(3));
          expect(vo.msgUserOrgName, equals("Asite Solutions"));
          expect(vo.msgUserName, equals("Krupal Patel (5345)"));
          expect(vo.originatorName, equals("Krupal Patel (5345)"));
          expect(vo.isPublic, equals(false));
          expect(vo.isThumbnailSupports, equals(false));
          expect(vo.canAccessHistory, equals(true));
          expect(vo.projectStatusId, equals(5));
          expect(vo.generateURI, equals(true));
        });

    test(
        'fromMap should initialize NotificationDetailVo instance with valid input for NotificationDetailVo',
            () {
          final mapData = {
            "projectId": "2089700\$\$Otjm0d",
            "projectName": "KrupalField19.8UK",
            "code": "STS1748",
            "commId": "11555629\$\$Rp39ND",
            "formId": "11555629\$\$8yZmLN",
            "title": "test n8",
            "userID": "758244\$\$OiBKDu",
            "orgId": "3\$\$A3VKEZ",
            "firstName": "Krupal",
            "lastName": "Patel (5345)",
            "orgName": "Asite Solutions",
            "originator":
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            "originatorDisplayName": "Krupal Patel (5345), Asite Solutions",
            "actions": [
              {
                "projectId": "0\$\$8H5V16",
                "resourceParentId": 11555629,
                "resourceId": 12244122,
                "resourceCode": "ORI001",
                "resourceStatusId": 0,
                "msgId": "12244122\$\$wM8wRc",
                "commentMsgId": "12244122\$\$uzRCct",
                "actionId": 3,
                "actionName": "Respond",
                "actionStatus": 0,
                "priorityId": 0,
                "actionDate": "Thu Jun 01 15:58:52 BST 2023",
                "dueDate": "Thu Jun 08 20:29:59 BST 2023",
                "distributorUserId": 758244,
                "recipientId": 2017529,
                "remarks": "",
                "distListId": 13611929,
                "transNum": "-1",
                "actionTime": "7 Days",
                "actionCompleteDate": "",
                "instantEmailNotify": "true",
                "actionNotes": "",
                "entityType": 0,
                "instanceGroupId": "0\$\$aPxwMb",
                "isActive": true,
                "modelId": "0\$\$hAmuCs",
                "assignedBy": "Krupal Patel (5345),Asite Solutions",
                "recipientName": "Mayur Raval m., Asite Solutions Ltd",
                "recipientOrgId": "5763307",
                "id": "ACTC13611929_2017529_3_1_12244122_11555629",
                "viewDate": "",
                "assignedByOrgName": "Asite Solutions",
                "distributionLevel": 0,
                "distributionLevelId": "0\$\$ezmxuh",
                "dueDateInMS": 0,
                "actionCompleteDateInMS": 0,
                "actionDelegated": false,
                "actionCleared": false,
                "actionCompleted": false,
                "assignedByEmail": "krupalpatel@asite.com",
                "assignedByRole": "",
                "generateURI": true,
              }
            ],
            "noOfActions": 0,
            "observationId": 102652,
            "locationId": 25016,
            "pfLocFolderId": 0,
            "updated": "01-Jun-2023#08:58 CST",
            "hasAttachments": false,
            "attachmentImageName": "",
            "msgCode": "ORI001",
            "typeImage": "icons/form.png",
            "docType": "Apps",
            "formTypeName": "Site Tasks",
            "status": "Open",
            "responseRequestBy": "08-Jun-2023#13:29 CST",
            "hasDocAssocations": false,
            "hasBimViewAssociations": false,
            "hasBimListAssociations": false,
            "hasFormAssocations": false,
            "hasCommentAssocations": false,
            "formHasAssocAttach": false,
            "msgHasAssocAttach": false,
            "formCreationDate": "01-Jun-2023#08:58 CST",
            "msgCreatedDate": "2023-06-01T14:58:51Z",
            "folderId": "0\$\$i8WujQ",
            "msgId": "12244122\$\$wM8wRc",
            "parentMsgId": 0,
            "msgTypeId": 1,
            "msgStatusId": 20,
            "indent": -1,
            "formTypeId": "10946131\$\$x73bKR",
            "formNum": 1748,
            "msgOriginatorId": 758244,
            "formPrintEnabled": false,
            "showPrintIcon": 0,
            "templateType": 2,
            "instanceGroupId": "10443853\$\$Jgvh7C",
            "noOfMessages": 0,
            "isDraft": false,
            "dcId": 1,
            "statusid": 1001,
            "originatorId": 758244,
            "isCloseOut": false,
            "isStatusChangeRestricted": false,
            "project_APD_folder_id": "0\$\$i8WujQ",
            "allowReopenForm": false,
            "hasOverallStatus": false,
            "formUserSet": [],
            "canOrigChangeStatus": false,
            "canControllerChangeStatus": false,
            "appType": "Field",
            "msgTypeCode": "ORI",
            "formGroupName": "Site Tasks",
            "id": "STS1748",
            "statusText": "Open",
            "statusChangeUserId": 0,
            "statusUpdateDate": "01-Jun-2023#08:58 CST",
            "statusChangeUserName": "Krupal Patel (5345)",
            "statusChangeUserPic":
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            "statusChangeUserEmail": "krupalpatel@asite.com",
            "statusChangeUserOrg": "Asite Solutions",
            "originatorEmail": "krupalpatel@asite.com",
            "statusRecordStyle": {
              "settingApplyOn": 1,
              "fontType": "PT Sans",
              "fontEffect": "0#0#0#0",
              "fontColor": "#000000",
              "backgroundColor": "#de4747",
              "isForOnlyStyleUpdate": false,
              "always_active": false,
              "userId": 0,
              "isDeactive": false,
              "defaultPermissionId": 0,
              "statusName": "Open",
              "statusID": 1001,
              "statusTypeID": 1,
              "projectId": "2089700\$\$Otjm0d",
              "orgId": "0\$\$2YKo1Z",
              "proxyUserId": 0,
              "isEnableForReviewComment": false,
              "generateURI": true,
            },
            "invoiceCountAgainstOrder": "-1",
            "invoiceColourCode": "-1",
            "controllerUserId": 0,
            "offlineFormId": "-1",
            "updatedDateInMS": 1685627934000,
            "formCreationDateInMS": 1685627931000,
            "msgCreatedDateInMS": 0,
            "flagType": 0,
            "appTypeId": "2",
            "latestDraftId": "0\$\$76WsW8",
            "flagTypeImageName": "flag_type/flag_0.png",
            "messageTypeImageName": "icons/form.png",
            "workflowStage": "",
            "workflowStatus": "",
            "hasFormAccess": false,
            "ownerOrgName": "Asite Solutions",
            "ownerOrgId": 3,
            "originatorOrgId": 3,
            "msgUserOrgId": 3,
            "msgUserOrgName": "Asite Solutions",
            "msgUserName": "Krupal Patel (5345)",
            "originatorName": "Krupal Patel (5345)",
            "isPublic": false,
            "isThumbnailSupports": false,
            "canAccessHistory": true,
            "projectStatusId": 5,
            "generateURI": true,
          };

          final vo = NotificationDetailVo.fromJson(mapData);

          expect(vo.projectId, equals("2089700\$\$Otjm0d"));
          expect(vo.projectName, equals("KrupalField19.8UK"));
          expect(vo.code, equals("STS1748"));
          expect(vo.commId, equals('11555629\$\$Rp39ND'));
          expect(vo.formId, equals("11555629\$\$8yZmLN"));
          expect(vo.title, equals("test n8"));
          expect(vo.userID, equals("758244\$\$OiBKDu"));
          expect(vo.orgId, equals("3\$\$A3VKEZ"));
          expect(vo.firstName, equals("Krupal"));
          expect(vo.lastName, equals("Patel (5345)"));
          expect(vo.orgName, equals("Asite Solutions"));
          expect(
              vo.originator,
              equals(
                  "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal"));
          expect(vo.originatorDisplayName,
              equals("Krupal Patel (5345), Asite Solutions"));
          expect(vo.noOfActions, equals(0));
          expect(vo.observationId, equals(102652));
          expect(vo.locationId, equals(25016));
          expect(vo.pfLocFolderId, equals(0));
          expect(vo.updated, equals("01-Jun-2023#08:58 CST"));
          expect(vo.hasAttachments, equals(false));
          expect(vo.attachmentImageName, equals(""));
          expect(vo.msgCode, equals("ORI001"));
          expect(vo.typeImage, equals("icons/form.png"));
          expect(vo.docType, equals("Apps"));
          expect(vo.formTypeName, equals("Site Tasks"));
          expect(vo.status, equals("Open"));
          expect(vo.responseRequestBy, equals("08-Jun-2023#13:29 CST"));
          expect(vo.hasDocAssocations, equals(false));
          expect(vo.hasBimViewAssociations, equals(false));
          expect(vo.hasBimListAssociations, equals(false));
          expect(vo.hasFormAssocations, equals(false));
          expect(vo.hasCommentAssocations, equals(false));
          expect(vo.formHasAssocAttach, equals(false));
          expect(vo.msgHasAssocAttach, equals(false));
          expect(vo.formCreationDate, equals("01-Jun-2023#08:58 CST"));
          expect(vo.msgCreatedDate, equals("2023-06-01T14:58:51Z"));
          expect(vo.folderId, equals("0\$\$i8WujQ"));
          expect(vo.msgId, equals("12244122\$\$wM8wRc"));
          expect(vo.parentMsgId, equals(0));
          expect(vo.msgTypeId, equals(1));
          expect(vo.msgStatusId, equals(20));
          expect(vo.indent, equals(-1));
          expect(vo.formTypeId, equals("10946131\$\$x73bKR"));
          expect(vo.formNum, equals(1748));
          expect(vo.msgOriginatorId, equals(758244));
          expect(vo.formPrintEnabled, equals(false));
          expect(vo.showPrintIcon, equals(0));
          expect(vo.templateType, equals(2));
          expect(vo.instanceGroupId, equals("10443853\$\$Jgvh7C"));
          expect(vo.noOfMessages, equals(0));
          expect(vo.isDraft, equals(false));
          expect(vo.dcId, equals(1));
          expect(vo.statusid, equals(1001));
          expect(vo.originatorId, equals(758244));
          expect(vo.isCloseOut, equals(false));
          expect(vo.isStatusChangeRestricted, equals(false));
          expect(vo.projectAPDFolderId, equals("0\$\$i8WujQ"));
          expect(vo.allowReopenForm, equals(false));
          expect(vo.hasOverallStatus, equals(false));
          expect(vo.canOrigChangeStatus, equals(false));
          expect(vo.canControllerChangeStatus, equals(false));
          expect(vo.appType, equals("Field"));
          expect(vo.msgTypeCode, equals("ORI"));
          expect(vo.formGroupName, equals("Site Tasks"));
          expect(vo.id, equals("STS1748"));
          expect(vo.statusText, equals("Open"));
          expect(vo.statusChangeUserId, equals(0));
          expect(vo.statusUpdateDate, equals("01-Jun-2023#08:58 CST"));
          expect(vo.statusChangeUserName, equals("Krupal Patel (5345)"));
          expect(
              vo.statusChangeUserPic,
              equals(
                  "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal"));
          expect(vo.statusChangeUserEmail, equals("krupalpatel@asite.com"));
          expect(vo.statusChangeUserOrg, equals("Asite Solutions"));
          expect(vo.originatorEmail, equals("krupalpatel@asite.com"));
          expect(vo.invoiceCountAgainstOrder, equals("-1"));
          expect(vo.invoiceColourCode, equals("-1"));
          expect(vo.controllerUserId, equals(0));
          expect(vo.offlineFormId, equals("-1"));
          expect(vo.updatedDateInMS, equals(1685627934000));
          expect(vo.formCreationDateInMS, equals(1685627931000));
          expect(vo.msgCreatedDateInMS, equals(0));
          expect(vo.flagType, equals(0));
          expect(vo.appTypeId, equals("2"));
          expect(vo.latestDraftId, equals("0\$\$76WsW8"));
          expect(vo.flagTypeImageName, equals("flag_type/flag_0.png"));
          expect(vo.messageTypeImageName, equals("icons/form.png"));
          expect(vo.workflowStage, equals(""));
          expect(vo.workflowStatus, equals(""));
          expect(vo.hasFormAccess, equals(false));
          expect(vo.ownerOrgName, equals("Asite Solutions"));
          expect(vo.ownerOrgId, equals(3));
          expect(vo.originatorOrgId, equals(3));
          expect(vo.msgUserOrgId, equals(3));
          expect(vo.msgUserOrgName, equals("Asite Solutions"));
          expect(vo.msgUserName, equals("Krupal Patel (5345)"));
          expect(vo.originatorName, equals("Krupal Patel (5345)"));
          expect(vo.isPublic, equals(false));
          expect(vo.isThumbnailSupports, equals(false));
          expect(vo.canAccessHistory, equals(true));
          expect(vo.projectStatusId, equals(5));
          expect(vo.generateURI, equals(true));
        });

    test(
        'copyWith should return a new NotificationDetailVo object with updated values',
            () {
          final vo = NotificationDetailVo(
            projectId: "2089700\$\$Otjm0d",
            projectName: "KrupalField19.8UK",
            code: "STS1748",
            commId: "11555629\$\$Rp39ND",
            formId: "11555629\$\$8yZmLN",
            title: "test n8",
            userID: "758244\$\$OiBKDu",
            orgId: "3\$\$A3VKEZ",
            firstName: "Krupal",
            lastName: "Patel (5345)",
            orgName: "Asite Solutions",
            originator:
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            originatorDisplayName: "Krupal Patel (5345), Asite Solutions",

            noOfActions: 0,
            observationId: 102652,
            locationId: 25016,
            pfLocFolderId: 0,
            updated: "01-Jun-2023#08:58 CST",
            hasAttachments: false,
            attachmentImageName: "",
            msgCode: "ORI001",
            typeImage: "icons/form.png",
            docType: "Apps",
            formTypeName: "Site Tasks",
            status: "Open",
            responseRequestBy: "08-Jun-2023#13:29 CST",
            hasDocAssocations: false,
            hasBimViewAssociations: false,
            hasBimListAssociations: false,
            hasFormAssocations: false,
            hasCommentAssocations: false,
            formHasAssocAttach: false,
            msgHasAssocAttach: false,
            formCreationDate: "01-Jun-2023#08:58 CST",
            msgCreatedDate: "2023-06-01T14:58:51Z",
            folderId: "0\$\$i8WujQ",
            msgId: "12244122\$\$wM8wRc",
            parentMsgId: 0,
            msgTypeId: 1,
            msgStatusId: 20,
            indent: -1,
            formTypeId: "10946131\$\$x73bKR",
            formNum: 1748,
            msgOriginatorId: 758244,
            formPrintEnabled: false,
            showPrintIcon: 0,
            templateType: 2,
            instanceGroupId: "10443853\$\$Jgvh7C",
            noOfMessages: 0,
            isDraft: false,
            dcId: 1,
            statusid: 1001,
            originatorId: 758244,
            isCloseOut: false,
            isStatusChangeRestricted: false,
            projectAPDFolderId: "0\$\$i8WujQ",
            allowReopenForm: false,
            hasOverallStatus: false,
            formUserSet: [],
            canOrigChangeStatus: false,
            canControllerChangeStatus: false,
            appType: "Field",
            msgTypeCode: "ORI",
            formGroupName: "Site Tasks",
            id: "STS1748",
            statusText: "Open",
            statusChangeUserId: 0,
            statusUpdateDate: "01-Jun-2023#08:58 CST",
            statusChangeUserName: "Krupal Patel (5345)",
            statusChangeUserPic:
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            statusChangeUserEmail: "krupalpatel@asite.com",
            statusChangeUserOrg: "Asite Solutions",
            originatorEmail: "krupalpatel@asite.com",
            invoiceCountAgainstOrder: "-1",
            invoiceColourCode: "-1",
            controllerUserId: 0,
            offlineFormId: "-1",
            updatedDateInMS: 1685627934000,
            formCreationDateInMS: 1685627931000,
            msgCreatedDateInMS: 0,
            flagType: 0,
            appTypeId: "2",
            latestDraftId: "0\$\$76WsW8",
            flagTypeImageName: "flag_type/flag_0.png",
            messageTypeImageName: "icons/form.png",
            workflowStage: "",
            workflowStatus: "",
            hasFormAccess: false,
            ownerOrgName: "Asite Solutions",
            ownerOrgId: 3,
            originatorOrgId: 3,
            msgUserOrgId: 3,
            msgUserOrgName: "Asite Solutions",
            msgUserName: "Krupal Patel (5345)",
            originatorName: "Krupal Patel (5345)",
            isPublic: false,
            isThumbnailSupports: false,
            canAccessHistory: true,
            projectStatusId: 5,
            generateURI: true,
          );

          final updated = vo.copyWith();

          expect(updated.projectId, equals("2089700\$\$Otjm0d"));
          expect(updated.projectName, equals("KrupalField19.8UK"));
          expect(updated.code, equals("STS1748"));
          expect(updated.commId, equals('11555629\$\$Rp39ND'));
          expect(vo.formId, equals("11555629\$\$8yZmLN"));
          expect(vo.title, equals("test n8"));
          expect(vo.userID, equals("758244\$\$OiBKDu"));
          expect(vo.orgId, equals("3\$\$A3VKEZ"));
          expect(vo.firstName, equals("Krupal"));
          expect(vo.lastName, equals("Patel (5345)"));
          expect(vo.orgName, equals("Asite Solutions"));
          expect(
              vo.originator,
              equals(
                  "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal"));
          expect(vo.originatorDisplayName,
              equals("Krupal Patel (5345), Asite Solutions"));
          expect(vo.noOfActions, equals(0));
          expect(vo.observationId, equals(102652));
          expect(vo.locationId, equals(25016));
          expect(vo.pfLocFolderId, equals(0));
          expect(vo.updated, equals("01-Jun-2023#08:58 CST"));
          expect(vo.hasAttachments, equals(false));
          expect(vo.attachmentImageName, equals(""));
          expect(vo.msgCode, equals("ORI001"));
          expect(vo.typeImage, equals("icons/form.png"));
          expect(vo.docType, equals("Apps"));
          expect(vo.formTypeName, equals("Site Tasks"));
          expect(vo.status, equals("Open"));
          expect(vo.responseRequestBy, equals("08-Jun-2023#13:29 CST"));
          expect(vo.hasDocAssocations, equals(false));
          expect(vo.hasBimViewAssociations, equals(false));
          expect(vo.hasBimListAssociations, equals(false));
          expect(vo.hasFormAssocations, equals(false));
          expect(vo.hasCommentAssocations, equals(false));
          expect(vo.formHasAssocAttach, equals(false));
          expect(vo.msgHasAssocAttach, equals(false));
          expect(vo.formCreationDate, equals("01-Jun-2023#08:58 CST"));
          expect(vo.msgCreatedDate, equals("2023-06-01T14:58:51Z"));
          expect(vo.folderId, equals("0\$\$i8WujQ"));
          expect(vo.msgId, equals("12244122\$\$wM8wRc"));
          expect(vo.parentMsgId, equals(0));
          expect(vo.msgTypeId, equals(1));
          expect(vo.msgStatusId, equals(20));
          expect(vo.indent, equals(-1));
          expect(vo.formTypeId, equals("10946131\$\$x73bKR"));
          expect(vo.formNum, equals(1748));
          expect(vo.msgOriginatorId, equals(758244));
          expect(vo.formPrintEnabled, equals(false));
          expect(vo.showPrintIcon, equals(0));
          expect(vo.templateType, equals(2));
          expect(vo.instanceGroupId, equals("10443853\$\$Jgvh7C"));
          expect(vo.noOfMessages, equals(0));
          expect(vo.isDraft, equals(false));
          expect(vo.dcId, equals(1));
          expect(vo.statusid, equals(1001));
          expect(vo.originatorId, equals(758244));
          expect(vo.isCloseOut, equals(false));
          expect(vo.isStatusChangeRestricted, equals(false));
          expect(vo.projectAPDFolderId, equals("0\$\$i8WujQ"));
          expect(vo.allowReopenForm, equals(false));
          expect(vo.hasOverallStatus, equals(false));
          expect(vo.formUserSet, equals([]));
          expect(vo.canOrigChangeStatus, equals(false));
          expect(vo.canControllerChangeStatus, equals(false));
          expect(vo.appType, equals("Field"));
          expect(vo.msgTypeCode, equals("ORI"));
          expect(vo.formGroupName, equals("Site Tasks"));
          expect(vo.id, equals("STS1748"));
          expect(vo.statusText, equals("Open"));
          expect(vo.statusChangeUserId, equals(0));
          expect(vo.statusUpdateDate, equals("01-Jun-2023#08:58 CST"));
          expect(vo.statusChangeUserName, equals("Krupal Patel (5345)"));
          expect(
              vo.statusChangeUserPic,
              equals(
                  "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal"));
          expect(vo.statusChangeUserEmail, equals("krupalpatel@asite.com"));
          expect(vo.statusChangeUserOrg, equals("Asite Solutions"));
          expect(vo.originatorEmail, equals("krupalpatel@asite.com"));
          expect(vo.invoiceCountAgainstOrder, equals("-1"));
          expect(vo.invoiceColourCode, equals("-1"));
          expect(vo.controllerUserId, equals(0));
          expect(vo.offlineFormId, equals("-1"));
          expect(vo.updatedDateInMS, equals(1685627934000));
          expect(vo.formCreationDateInMS, equals(1685627931000));
          expect(vo.msgCreatedDateInMS, equals(0));
          expect(vo.flagType, equals(0));
          expect(vo.appTypeId, equals("2"));
          expect(vo.latestDraftId, equals("0\$\$76WsW8"));
          expect(vo.flagTypeImageName, equals("flag_type/flag_0.png"));
          expect(vo.messageTypeImageName, equals("icons/form.png"));
          expect(vo.workflowStage, equals(""));
          expect(vo.workflowStatus, equals(""));
          expect(vo.hasFormAccess, equals(false));
          expect(vo.ownerOrgName, equals("Asite Solutions"));
          expect(vo.ownerOrgId, equals(3));
          expect(vo.originatorOrgId, equals(3));
          expect(vo.msgUserOrgId, equals(3));
          expect(vo.msgUserOrgName, equals("Asite Solutions"));
          expect(vo.msgUserName, equals("Krupal Patel (5345)"));
          expect(vo.originatorName, equals("Krupal Patel (5345)"));
          expect(vo.isPublic, equals(false));
          expect(vo.isThumbnailSupports, equals(false));
          expect(vo.canAccessHistory, equals(true));
          expect(vo.projectStatusId, equals(5));
          expect(vo.generateURI, equals(true));
        });

    test(
        'notificationDetailVo.toJson should convert a notificationDetailVo object to JSON',
            () {
          // Create a sample FloorDetail object
          final notificationVo = NotificationDetailVo(
            projectId: "2089700\$\$Otjm0d",
            projectName: "KrupalField19.8UK",
            code: "STS1748",
            commId: "11555629\$\$Rp39ND",
            formId: "11555629\$\$8yZmLN",
            title: "test n8",
            userID: "758244\$\$OiBKDu",
            orgId: "3\$\$A3VKEZ",
            firstName: "Krupal",
            lastName: "Patel (5345)",
            orgName: "Asite Solutions",
            originator:
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            originatorDisplayName: "Krupal Patel (5345), Asite Solutions",
            actions: [
              NotificationActions(
                projectId: "0\$\$8H5V16",
                resourceParentId: 11555629,
                resourceId: 12244122,
                resourceCode: "ORI001",
                resourceStatusId: 0,
                msgId: "12244122\$\$wM8wRc",
                commentMsgId: "12244122\$\$uzRCct",
                actionId: 3,
                actionName: "Respond",
                actionStatus: 0,
                priorityId: 0,
                actionDate: "Thu Jun 01 15:58:52 BST 2023",
                dueDate: "Thu Jun 08 20:29:59 BST 2023",
                distributorUserId: 758244,
                recipientId: 2017529,
                remarks: "",
                distListId: 13611929,
                transNum: "-1",
                actionTime: "7 Days",
                actionCompleteDate: "",
                instantEmailNotify: "true",
                actionNotes: "",
                entityType: 0,
                instanceGroupId: "0\$\$aPxwMb",
                isActive: true,
                modelId: "0\$\$hAmuCs",
                assignedBy: "Krupal Patel (5345),Asite Solutions",
                recipientName: "Mayur Raval m., Asite Solutions Ltd",
                recipientOrgId: "5763307",
                id: "ACTC13611929_2017529_3_1_12244122_11555629",
                viewDate: "",
                assignedByOrgName: "Asite Solutions",
                distributionLevel: 0,
                distributionLevelId: "0\$\$ezmxuh",
                dueDateInMS: 0,
                actionCompleteDateInMS: 0,
                actionDelegated: false,
                actionCleared: false,
                actionCompleted: false,
                assignedByEmail: "krupalpatel@asite.com",
                assignedByRole: "",
                generateURI: true,
              ),
            ],
            noOfActions: 0,
            observationId: 102652,
            locationId: 25016,
            pfLocFolderId: 0,
            updated: "01-Jun-2023#08:58 CST",
            hasAttachments: false,
            attachmentImageName: "",
            msgCode: "ORI001",
            typeImage: "icons/form.png",
            docType: "Apps",
            formTypeName: "Site Tasks",
            status: "Open",
            responseRequestBy: "08-Jun-2023#13:29 CST",
            hasDocAssocations: false,
            hasBimViewAssociations: false,
            hasBimListAssociations: false,
            hasFormAssocations: false,
            hasCommentAssocations: false,
            formHasAssocAttach: false,
            msgHasAssocAttach: false,
            formCreationDate: "01-Jun-2023#08:58 CST",
            msgCreatedDate: "2023-06-01T14:58:51Z",
            folderId: "0\$\$i8WujQ",
            msgId: "12244122\$\$wM8wRc",
            parentMsgId: 0,
            msgTypeId: 1,
            msgStatusId: 20,
            indent: -1,
            formTypeId: "10946131\$\$x73bKR",
            formNum: 1748,
            msgOriginatorId: 758244,
            formPrintEnabled: false,
            showPrintIcon: 0,
            templateType: 2,
            instanceGroupId: "10443853\$\$Jgvh7C",
            noOfMessages: 0,
            isDraft: false,
            dcId: 1,
            statusid: 1001,
            originatorId: 758244,
            isCloseOut: false,
            isStatusChangeRestricted: false,
            projectAPDFolderId: "0\$\$i8WujQ",
            allowReopenForm: false,
            hasOverallStatus: false,
            formUserSet: [],
            canOrigChangeStatus: false,
            canControllerChangeStatus: false,
            appType: "Field",
            msgTypeCode: "ORI",
            formGroupName: "Site Tasks",
            id: "STS1748",
            statusText: "Open",
            statusChangeUserId: 0,
            statusUpdateDate: "01-Jun-2023#08:58 CST",
            statusChangeUserName: "Krupal Patel (5345)",
            statusChangeUserPic:
            "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal",
            statusChangeUserEmail: "krupalpatel@asite.com",
            statusChangeUserOrg: "Asite Solutions",
            originatorEmail: "krupalpatel@asite.com",
            statusRecordStyle: StatusRecordStyle(
                settingApplyOn: 1,
                fontType: "PT Sans",
                fontEffect: "0#0#0#0",
                fontColor: "#000000",
                backgroundColor: "#de4747",
                isForOnlyStyleUpdate: false,
                alwaysActive: false,
                userId: 0,
                isDeactive: false,
                defaultPermissionId: 0,
                statusName: "Open",
                statusID: 1001,
                statusTypeID: 1,
                projectId: "2089700\$\$Otjm0d",
                orgId: "0\$\$2YKo1Z",
                proxyUserId: 0,
                isEnableForReviewComment: false,
                generateURI: true),
            invoiceCountAgainstOrder: "-1",
            invoiceColourCode: "-1",
            controllerUserId: 0,
            offlineFormId: "-1",
            updatedDateInMS: 1685627934000,
            formCreationDateInMS: 1685627931000,
            msgCreatedDateInMS: 0,
            flagType: 0,
            appTypeId: "2",
            latestDraftId: "0\$\$76WsW8",
            flagTypeImageName: "flag_type/flag_0.png",
            messageTypeImageName: "icons/form.png",
            workflowStage: "",
            workflowStatus: "",
            hasFormAccess: false,
            ownerOrgName: "Asite Solutions",
            ownerOrgId: 3,
            originatorOrgId: 3,
            msgUserOrgId: 3,
            msgUserOrgName: "Asite Solutions",
            msgUserName: "Krupal Patel (5345)",
            originatorName: "Krupal Patel (5345)",
            isPublic: false,
            isThumbnailSupports: false,
            canAccessHistory: true,
            projectStatusId: 5,
            generateURI: true,
          );

          // Convert the FloorDetail object to JSON
          final json = notificationVo.toJson();

          // Check if the JSON object is correctly generated
          expect(json['projectId'], "2089700\$\$Otjm0d");
          expect(json['projectName'], "KrupalField19.8UK");
          expect(json['code'], "STS1748");
          expect(json['commId'], "11555629\$\$Rp39ND");
          expect(json['formId'], "11555629\$\$8yZmLN");
          expect(json['title'], "test n8");
          expect(json['userID'], "758244\$\$OiBKDu");
          expect(json['orgId'], "3\$\$A3VKEZ");
          expect(json['firstName'], "Krupal");
          expect(json['lastName'], "Patel (5345)");
          expect(json['orgName'], "Asite Solutions");
          expect(json['originator'],
              "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal");
          expect(json['originatorDisplayName'],
              "Krupal Patel (5345), Asite Solutions");
          expect(json['actions'], [
            {
              "projectId": "0\$\$8H5V16",
              "resourceParentId": 11555629,
              "resourceId": 12244122,
              "resourceCode": "ORI001",
              "resourceStatusId": 0,
              "msgId": "12244122\$\$wM8wRc",
              "commentMsgId": "12244122\$\$uzRCct",
              "actionId": 3,
              "actionName": "Respond",
              "actionStatus": 0,
              "priorityId": 0,
              "actionDate": "Thu Jun 01 15:58:52 BST 2023",
              "dueDate": "Thu Jun 08 20:29:59 BST 2023",
              "distributorUserId": 758244,
              "recipientId": 2017529,
              "remarks": "",
              "distListId": 13611929,
              "transNum": "-1",
              "actionTime": "7 Days",
              "actionCompleteDate": "",
              "instantEmailNotify": "true",
              "actionNotes": "",
              "entityType": 0,
              "instanceGroupId": "0\$\$aPxwMb",
              "isActive": true,
              "modelId": "0\$\$hAmuCs",
              "assignedBy": "Krupal Patel (5345),Asite Solutions",
              "recipientName": "Mayur Raval m., Asite Solutions Ltd",
              "recipientOrgId": "5763307",
              "id": "ACTC13611929_2017529_3_1_12244122_11555629",
              "viewDate": "",
              "assignedByOrgName": "Asite Solutions",
              "distributionLevel": 0,
              "distributionLevelId": "0\$\$ezmxuh",
              "dueDateInMS": 0,
              "actionCompleteDateInMS": 0,
              "actionDelegated": false,
              "actionCleared": false,
              "actionCompleted": false,
              "assignedByEmail": "krupalpatel@asite.com",
              "assignedByRole": "",
              "generateURI": true
            }
          ]);
          expect(json['noOfActions'], 0);
          expect(json['observationId'], 102652);
          expect(json['locationId'], 25016);
          expect(json['pfLocFolderId'], 0);
          expect(json['updated'], "01-Jun-2023#08:58 CST");
          expect(json['hasAttachments'], false);
          expect(json['attachmentImageName'], "");
          expect(json['msgCode'], "ORI001");
          expect(json['typeImage'], "icons/form.png");
          expect(json['docType'], "Apps");
          expect(json['formTypeName'], "Site Tasks");
          expect(json['status'], "Open");
          expect(json['responseRequestBy'], "08-Jun-2023#13:29 CST");
          expect(json['hasDocAssocations'], false);
          expect(json['hasBimViewAssociations'], false);
          expect(json['hasBimListAssociations'], false);
          expect(json['hasFormAssocations'], false);
          expect(json['hasCommentAssocations'], false);
          expect(json['formHasAssocAttach'], false);
          expect(json['msgHasAssocAttach'], false);
          expect(json['formCreationDate'], "01-Jun-2023#08:58 CST");
          expect(json['msgCreatedDate'], "2023-06-01T14:58:51Z");
          expect(json['folderId'], "0\$\$i8WujQ");
          expect(json['msgId'], "12244122\$\$wM8wRc");
          expect(json['parentMsgId'], 0);
          expect(json['msgTypeId'], 1);
          expect(json['msgStatusId'], 20);
          expect(json['indent'], -1);
          expect(json['formTypeId'], "10946131\$\$x73bKR");
          expect(json['formNum'], 1748);
          expect(json['msgOriginatorId'], 758244);
          expect(json['formPrintEnabled'], false);
          expect(json['showPrintIcon'], 0);
          expect(json['templateType'], 2);
          expect(json['instanceGroupId'], "10443853\$\$Jgvh7C");
          expect(json['noOfMessages'], 0);
          expect(json['isDraft'], false);
          expect(json['dcId'], 1);
          expect(json['statusid'], 1001);
          expect(json['originatorId'], 758244);
          expect(json['isCloseOut'], false);
          expect(json['isStatusChangeRestricted'], false);
          expect(json['project_APD_folder_id'], "0\$\$i8WujQ");
          expect(json['allowReopenForm'], false);
          expect(json['hasOverallStatus'], false);
          expect(json['formUserSet'], []);
          expect(json['canOrigChangeStatus'], false);
          expect(json['canControllerChangeStatus'], false);
          expect(json['appType'], "Field");
          expect(json['msgTypeCode'], "ORI");
          expect(json['formGroupName'], "Site Tasks");
          expect(json['id'], "STS1748");
          expect(json['statusText'], "Open");
          expect(json['statusChangeUserId'], 0);
          expect(json['statusUpdateDate'], "01-Jun-2023#08:58 CST");
          expect(json['statusChangeUserName'], "Krupal Patel (5345)");
          expect(json['statusChangeUserPic'],
              "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal");
          expect(json['statusChangeUserEmail'], "krupalpatel@asite.com");
          expect(json['statusChangeUserOrg'], "Asite Solutions");
          expect(json['originatorEmail'], "krupalpatel@asite.com");
          expect(json['statusRecordStyle'], {
            "settingApplyOn": 1,
            "fontType": "PT Sans",
            "fontEffect": "0#0#0#0",
            "fontColor": "#000000",
            "backgroundColor": "#de4747",
            "isForOnlyStyleUpdate": false,
            "always_active": false,
            "userId": 0,
            "isDeactive": false,
            "defaultPermissionId": 0,
            "statusName": "Open",
            "statusID": 1001,
            "statusTypeID": 1,
            "projectId": "2089700\$\$Otjm0d",
            "orgId": "0\$\$2YKo1Z",
            "proxyUserId": 0,
            "isEnableForReviewComment": false,
            "generateURI": true
          });
          expect(json['invoiceCountAgainstOrder'], "-1");
          expect(json['invoiceColourCode'], "-1");
          expect(json['controllerUserId'], 0);
          expect(json['offlineFormId'], "-1");
          expect(json['updatedDateInMS'], 1685627934000);
          expect(json['formCreationDateInMS'], 1685627931000);
          expect(json['msgCreatedDateInMS'], 0);
          expect(json['flagType'], 0);
          expect(json['appTypeId'], "2");
          expect(json['latestDraftId'], "0\$\$76WsW8");
          expect(json['flagTypeImageName'], "flag_type/flag_0.png");
          expect(json['messageTypeImageName'], "icons/form.png");
          expect(json['workflowStage'], "");
          expect(json['workflowStatus'], "");
          expect(json['hasFormAccess'], false);
          expect(json['ownerOrgName'], "Asite Solutions");
          expect(json['ownerOrgId'], 3);
          expect(json['originatorOrgId'], 3);
          expect(json['msgUserOrgId'], 3);
          expect(json['msgUserOrgName'], "Asite Solutions");
          expect(json['msgUserName'], "Krupal Patel (5345)");
          expect(json['originatorName'], "Krupal Patel (5345)");
          expect(json['isPublic'], false);
          expect(json['isThumbnailSupports'], false);
          expect(json['canAccessHistory'], true);
          expect(json['projectStatusId'], 5);
          expect(json['generateURI'], true);
        });
  });

  group('NotificationActionsVo', () {
    test(
        'Constructor should initialize NotificationActionsVo instance with valid input',
            () {
          final vo = NotificationActions(
            projectId: "0\$\$8H5V16",
            resourceParentId: 11555629,
            resourceId: 12244122,
            resourceCode: "ORI001",
            resourceStatusId: 0,
            msgId: "12244122\$\$wM8wRc",
            commentMsgId: "12244122\$\$uzRCct",
            actionId: 3,
            actionName: "Respond",
            actionStatus: 0,
            priorityId: 0,
            actionDate: "Thu Jun 01 15:58:52 BST 2023",
            dueDate: "Thu Jun 08 20:29:59 BST 2023",
            distributorUserId: 758244,
            recipientId: 2017529,
            remarks: "",
            distListId: 13611929,
            transNum: "-1",
            actionTime: "7 Days",
            actionCompleteDate: "",
            instantEmailNotify: "true",
            actionNotes: "",
            entityType: 0,
            instanceGroupId: "0\$\$aPxwMb",
            isActive: true,
            modelId: "0\$\$hAmuCs",
            assignedBy: "Krupal Patel (5345),Asite Solutions",
            recipientName: "Mayur Raval m., Asite Solutions Ltd",
            recipientOrgId: "5763307",
            id: "ACTC13611929_2017529_3_1_12244122_11555629",
            viewDate: "",
            assignedByOrgName: "Asite Solutions",
            distributionLevel: 0,
            distributionLevelId: "0\$\$ezmxuh",
            dueDateInMS: 0,
            actionCompleteDateInMS: 0,
            actionDelegated: false,
            actionCleared: false,
            actionCompleted: false,
            assignedByEmail: "krupalpatel@asite.com",
            assignedByRole: "",
            generateURI: true,
          );

          expect(vo.projectId, equals("0\$\$8H5V16"));
          expect(vo.resourceParentId, equals(11555629));
          expect(vo.resourceId, equals(12244122));
          expect(vo.resourceCode, equals("ORI001"));
          expect(vo.resourceStatusId, equals(0));
          expect(vo.msgId, equals("12244122\$\$wM8wRc"));
          expect(vo.commentMsgId, equals("12244122\$\$uzRCct"));
          expect(vo.actionId, equals(3));
          expect(vo.actionName, equals("Respond"));
          expect(vo.actionStatus, equals(0));
          expect(vo.priorityId, equals(0));
          expect(vo.actionDate, equals("Thu Jun 01 15:58:52 BST 2023"));
          expect(vo.dueDate, equals("Thu Jun 08 20:29:59 BST 2023"));
          expect(vo.distributorUserId, equals(758244));
          expect(vo.recipientId, equals(2017529));
          expect(vo.remarks, equals(""));
          expect(vo.distListId, equals(13611929));
          expect(vo.transNum, equals("-1"));
          expect(vo.actionTime, equals("7 Days"));
          expect(vo.actionCompleteDate, equals(""));
          expect(vo.instantEmailNotify, equals("true"));
          expect(vo.actionNotes, equals(""));
          expect(vo.entityType, equals(0));
          expect(vo.instanceGroupId, equals("0\$\$aPxwMb"));
          expect(vo.isActive, equals(true));
          expect(vo.modelId, equals("0\$\$hAmuCs"));
          expect(vo.assignedBy, equals("Krupal Patel (5345),Asite Solutions"));
          expect(vo.recipientName, equals("Mayur Raval m., Asite Solutions Ltd"));
          expect(vo.recipientOrgId, equals("5763307"));
          expect(vo.id, equals("ACTC13611929_2017529_3_1_12244122_11555629"));
          expect(vo.viewDate, equals(""));
          expect(vo.assignedByOrgName, equals("Asite Solutions"));
          expect(vo.distributionLevel, equals(0));
          expect(vo.distributionLevelId, equals("0\$\$ezmxuh"));
          expect(vo.dueDateInMS, equals(0));
          expect(vo.actionCompleteDateInMS, equals(0));
          expect(vo.actionDelegated, equals(false));
          expect(vo.actionCleared, equals(false));
          expect(vo.actionCompleted, equals(false));
          expect(vo.assignedByEmail, equals("krupalpatel@asite.com"));
          expect(vo.assignedByRole, equals(""));
          expect(vo.generateURI, equals(true));
        });

    test(
        'fromMap should initialize NotificationActionsVo instance with valid input for NotificationActionsVo',
            () {
          final mapData = {
            "projectId": "0\$\$8H5V16",
            "resourceParentId": 11555629,
            "resourceId": 12244122,
            "resourceCode": "ORI001",
            "resourceStatusId": 0,
            "msgId": "12244122\$\$wM8wRc",
            "commentMsgId": "12244122\$\$uzRCct",
            "actionId": 3,
            "actionName": "Respond",
            "actionStatus": 0,
            "priorityId": 0,
            "actionDate": "Thu Jun 01 15:58:52 BST 2023",
            "dueDate": "Thu Jun 08 20:29:59 BST 2023",
            "distributorUserId": 758244,
            "recipientId": 2017529,
            "remarks": "",
            "distListId": 13611929,
            "transNum": "-1",
            "actionTime": "7 Days",
            "actionCompleteDate": "",
            "instantEmailNotify": "true",
            "actionNotes": "",
            "entityType": 0,
            "instanceGroupId": "0\$\$aPxwMb",
            "isActive": true,
            "modelId": "0\$\$hAmuCs",
            "assignedBy": "Krupal Patel (5345),Asite Solutions",
            "recipientName": "Mayur Raval m., Asite Solutions Ltd",
            "recipientOrgId": "5763307",
            "id": "ACTC13611929_2017529_3_1_12244122_11555629",
            "viewDate": "",
            "assignedByOrgName": "Asite Solutions",
            "distributionLevel": 0,
            "distributionLevelId": "0\$\$ezmxuh",
            "dueDateInMS": 0,
            "actionCompleteDateInMS": 0,
            "actionDelegated": false,
            "actionCleared": false,
            "actionCompleted": false,
            "assignedByEmail": "krupalpatel@asite.com",
            "assignedByRole": "",
            "generateURI": true,
          };

          final vo = NotificationActions.fromJson(mapData);
          expect(vo.projectId, equals("0\$\$8H5V16"));
          expect(vo.resourceParentId, equals(11555629));
          expect(vo.resourceId, equals(12244122));
          expect(vo.resourceCode, equals("ORI001"));
          expect(vo.resourceStatusId, equals(0));
          expect(vo.msgId, equals("12244122\$\$wM8wRc"));
          expect(vo.commentMsgId, equals("12244122\$\$uzRCct"));
          expect(vo.actionId, equals(3));
          expect(vo.actionName, equals("Respond"));
          expect(vo.actionStatus, equals(0));
          expect(vo.priorityId, equals(0));
          expect(vo.actionDate, equals("Thu Jun 01 15:58:52 BST 2023"));
          expect(vo.dueDate, equals("Thu Jun 08 20:29:59 BST 2023"));
          expect(vo.distributorUserId, equals(758244));
          expect(vo.recipientId, equals(2017529));
          expect(vo.remarks, equals(""));
          expect(vo.distListId, equals(13611929));
          expect(vo.transNum, equals("-1"));
          expect(vo.actionTime, equals("7 Days"));
          expect(vo.actionCompleteDate, equals(""));
          expect(vo.instantEmailNotify, equals("true"));
          expect(vo.actionNotes, equals(""));
          expect(vo.entityType, equals(0));
          expect(vo.instanceGroupId, equals("0\$\$aPxwMb"));
          expect(vo.isActive, equals(true));
          expect(vo.modelId, equals("0\$\$hAmuCs"));
          expect(vo.assignedBy, equals("Krupal Patel (5345),Asite Solutions"));
          expect(vo.recipientName, equals("Mayur Raval m., Asite Solutions Ltd"));
          expect(vo.recipientOrgId, equals("5763307"));
          expect(vo.id, equals("ACTC13611929_2017529_3_1_12244122_11555629"));
          expect(vo.viewDate, equals(""));
          expect(vo.assignedByOrgName, equals("Asite Solutions"));
          expect(vo.distributionLevel, equals(0));
          expect(vo.distributionLevelId, equals("0\$\$ezmxuh"));
          expect(vo.dueDateInMS, equals(0));
          expect(vo.actionCompleteDateInMS, equals(0));
          expect(vo.actionDelegated, equals(false));
          expect(vo.actionCleared, equals(false));
          expect(vo.actionCompleted, equals(false));
          expect(vo.assignedByEmail, equals("krupalpatel@asite.com"));
          expect(vo.assignedByRole, equals(""));
          expect(vo.generateURI, equals(true));
        });

    test(
        'copyWith should return a new NotificationActionsVo object with updated values',
            () {
          final vo = NotificationActions(
            projectId: "0\$\$8H5V16",
            resourceParentId: 11555629,
            resourceId: 12244122,
            resourceCode: "ORI001",
            resourceStatusId: 0,
            msgId: "12244122\$\$wM8wRc",
            commentMsgId: "12244122\$\$uzRCct",
            actionId: 3,
            actionName: "Respond",
            actionStatus: 0,
            priorityId: 0,
            actionDate: "Thu Jun 01 15:58:52 BST 2023",
            dueDate: "Thu Jun 08 20:29:59 BST 2023",
            distributorUserId: 758244,
            recipientId: 2017529,
            remarks: "",
            distListId: 13611929,
            transNum: "-1",
            actionTime: "7 Days",
            actionCompleteDate: "",
            instantEmailNotify: "true",
            actionNotes: "",
            entityType: 0,
            instanceGroupId: "0\$\$aPxwMb",
            isActive: true,
            modelId: "0\$\$hAmuCs",
            assignedBy: "Krupal Patel (5345),Asite Solutions",
            recipientName: "Mayur Raval m., Asite Solutions Ltd",
            recipientOrgId: "5763307",
            id: "ACTC13611929_2017529_3_1_12244122_11555629",
            viewDate: "",
            assignedByOrgName: "Asite Solutions",
            distributionLevel: 0,
            distributionLevelId: "0\$\$ezmxuh",
            dueDateInMS: 0,
            actionCompleteDateInMS: 0,
            actionDelegated: false,
            actionCleared: false,
            actionCompleted: false,
            assignedByEmail: "krupalpatel@asite.com",
            assignedByRole: "",
            generateURI: true,
          );

          final updated = vo.copyWith();

          expect(updated.projectId, equals("0\$\$8H5V16"));
          expect(updated.resourceParentId, equals(11555629));
          expect(updated.resourceId, equals(12244122));
          expect(updated.resourceCode, equals('ORI001'));
          expect(vo.resourceStatusId, equals(0));
          expect(vo.msgId, equals("12244122\$\$wM8wRc"));
          expect(vo.commentMsgId, equals("12244122\$\$uzRCct"));
          expect(vo.actionId, equals(3));
          expect(vo.actionName, equals("Respond"));
          expect(vo.actionStatus, equals(0));
          expect(vo.priorityId, equals(0));
          expect(vo.actionDate, equals("Thu Jun 01 15:58:52 BST 2023"));
          expect(vo.dueDate, equals("Thu Jun 08 20:29:59 BST 2023"));
          expect(vo.distributorUserId, equals(758244));
          expect(vo.recipientId, equals(2017529));
          expect(vo.remarks, equals(""));
          expect(vo.distListId, equals(13611929));
          expect(vo.transNum, equals("-1"));
          expect(vo.actionTime, equals("7 Days"));
          expect(vo.actionCompleteDate, equals(""));
          expect(vo.instantEmailNotify, equals("true"));
          expect(vo.actionNotes, equals(""));
          expect(vo.entityType, equals(0));
          expect(vo.instanceGroupId, equals("0\$\$aPxwMb"));
          expect(vo.isActive, equals(true));
          expect(vo.modelId, equals("0\$\$hAmuCs"));
          expect(vo.assignedBy, equals("Krupal Patel (5345),Asite Solutions"));
          expect(vo.recipientName, equals("Mayur Raval m., Asite Solutions Ltd"));
          expect(vo.recipientOrgId, equals("5763307"));
          expect(vo.id, equals("ACTC13611929_2017529_3_1_12244122_11555629"));
          expect(vo.viewDate, equals(""));
          expect(vo.assignedByOrgName, equals("Asite Solutions"));
          expect(vo.distributionLevel, equals(0));
          expect(vo.distributionLevelId, equals("0\$\$ezmxuh"));
          expect(vo.dueDateInMS, equals(0));
          expect(vo.actionCompleteDateInMS, equals(0));
          expect(vo.actionDelegated, equals(false));
          expect(vo.actionCleared, equals(false));
          expect(vo.actionCompleted, equals(false));
          expect(vo.assignedByEmail, equals("krupalpatel@asite.com"));
          expect(vo.assignedByRole, equals(""));
          expect(vo.generateURI, equals(true));
        });

    test(
        'NotificationActionsVo.toJson should convert a NotificationActionsVo object to JSON',
            () {
          // Create a sample FloorDetail object
          final notificationVo = NotificationActions(
            projectId: "0\$\$8H5V16",
            resourceParentId: 11555629,
            resourceId: 12244122,
            resourceCode: "ORI001",
            resourceStatusId: 0,
            msgId: "12244122\$\$wM8wRc",
            commentMsgId: "12244122\$\$uzRCct",
            actionId: 3,
            actionName: "Respond",
            actionStatus: 0,
            priorityId: 0,
            actionDate: "Thu Jun 01 15:58:52 BST 2023",
            dueDate: "Thu Jun 08 20:29:59 BST 2023",
            distributorUserId: 758244,
            recipientId: 2017529,
            remarks: "",
            distListId: 13611929,
            transNum: "-1",
            actionTime: "7 Days",
            actionCompleteDate: "",
            instantEmailNotify: "true",
            actionNotes: "",
            entityType: 0,
            instanceGroupId: "0\$\$aPxwMb",
            isActive: true,
            modelId: "0\$\$hAmuCs",
            assignedBy: "Krupal Patel (5345),Asite Solutions",
            recipientName: "Mayur Raval m., Asite Solutions Ltd",
            recipientOrgId: "5763307",
            id: "ACTC13611929_2017529_3_1_12244122_11555629",
            viewDate: "",
            assignedByOrgName: "Asite Solutions",
            distributionLevel: 0,
            distributionLevelId: "0\$\$ezmxuh",
            dueDateInMS: 0,
            actionCompleteDateInMS: 0,
            actionDelegated: false,
            actionCleared: false,
            actionCompleted: false,
            assignedByEmail: "krupalpatel@asite.com",
            assignedByRole: "",
            generateURI: true,
          );
          // Convert the FloorDetail object to JSON
          final json = notificationVo.toJson();

          // Check if the JSON object is correctly generated
          expect(json['projectId'], "0\$\$8H5V16");
          expect(json['resourceParentId'], 11555629);
          expect(json['resourceId'], 12244122);
          expect(json['resourceCode'], "ORI001");
          expect(json['resourceStatusId'], 0);
          expect(json['msgId'], "12244122\$\$wM8wRc");
          expect(json['commentMsgId'], "12244122\$\$uzRCct");
          expect(json['actionId'], 3);
          expect(json['actionName'], "Respond");
          expect(json['actionStatus'], 0);
          expect(json['priorityId'], 0);
          expect(json['actionDate'], "Thu Jun 01 15:58:52 BST 2023");
          expect(json['dueDate'], "Thu Jun 08 20:29:59 BST 2023");
          expect(json['distributorUserId'], 758244);
          expect(json['recipientId'], 2017529);
          expect(json['remarks'], "");
          expect(json['distListId'], 13611929);
          expect(json['transNum'], "-1");
          expect(json['actionTime'], "7 Days");
          expect(json['actionCompleteDate'], "");
          expect(json['instantEmailNotify'], "true");
          expect(json['actionNotes'], "");
          expect(json['entityType'], 0);
          expect(json['instanceGroupId'], "0\$\$aPxwMb");
          expect(json['isActive'], true);
          expect(json['modelId'], "0\$\$hAmuCs");
          expect(json['assignedBy'], "Krupal Patel (5345),Asite Solutions");
          expect(json['recipientName'], "Mayur Raval m., Asite Solutions Ltd");
          expect(json['recipientOrgId'], "5763307");
          expect(json['id'], "ACTC13611929_2017529_3_1_12244122_11555629");
          expect(json['viewDate'], "");
          expect(json['assignedByOrgName'], "Asite Solutions");
          expect(json['distributionLevel'], 0);
          expect(json['distributionLevelId'], "0\$\$ezmxuh");
          expect(json['dueDateInMS'], 0);
          expect(json['actionCompleteDateInMS'], 0);
          expect(json['actionDelegated'], false);
          expect(json['actionCleared'], false);
          expect(json['actionCompleted'], false);
          expect(json['assignedByEmail'], "krupalpatel@asite.com");
          expect(json['assignedByRole'], "");
          expect(json['generateURI'], true);
        });
  });

  group('StatusRecordStyleVo', () {
    test(
        'Constructor should initialize StatusRecordStyleVo instance with valid input',
            () {
          final vo = StatusRecordStyle(
              settingApplyOn: 1,
              fontType: "PT Sans",
              fontEffect: "0#0#0#0",
              fontColor: "#000000",
              backgroundColor: "#de4747",
              isForOnlyStyleUpdate: false,
              alwaysActive: false,
              userId: 0,
              isDeactive: false,
              defaultPermissionId: 0,
              statusName: "Open",
              statusID: 1001,
              statusTypeID: 1,
              projectId: "2089700\$\$Otjm0d",
              orgId: "0\$\$2YKo1Z",
              proxyUserId: 0,
              isEnableForReviewComment: false,
              generateURI: true);

          expect(vo.settingApplyOn, equals(1));
          expect(vo.fontType, equals("PT Sans"));
          expect(vo.fontEffect, equals("0#0#0#0"));
          expect(vo.fontColor, equals("#000000"));
          expect(vo.backgroundColor, equals("#de4747"));
          expect(vo.isForOnlyStyleUpdate, equals(false));
          expect(vo.alwaysActive, equals(false));
          expect(vo.userId, equals(0));
          expect(vo.isDeactive, equals(false));
          expect(vo.defaultPermissionId, equals(0));
          expect(vo.statusName, equals("Open"));
          expect(vo.statusTypeID, equals(1));
          expect(vo.projectId, equals("2089700\$\$Otjm0d"));
          expect(vo.orgId, equals("0\$\$2YKo1Z"));
          expect(vo.proxyUserId, equals(0));
          expect(vo.isEnableForReviewComment, equals(false));
          expect(vo.generateURI, equals(true));
        });

    test(
        'fromMap should initialize StatusRecordStyleVo instance with valid input for StatusRecordStyleVo',
            () {
          final mapData = {
            "settingApplyOn": 1,
            "fontType": "PT Sans",
            "fontEffect": "0#0#0#0",
            "fontColor": "#000000",
            "backgroundColor": "#de4747",
            "isForOnlyStyleUpdate": false,
            "always_active": false,
            "userId": 0,
            "isDeactive": false,
            "defaultPermissionId": 0,
            "statusName": "Open",
            "statusID": 1001,
            "statusTypeID": 1,
            "projectId": "2089700\$\$Otjm0d",
            "orgId": "0\$\$2YKo1Z",
            "proxyUserId": 0,
            "isEnableForReviewComment": false,
            "generateURI": true,
          };

          final vo = StatusRecordStyle.fromJson(mapData);
          expect(vo.settingApplyOn, equals(1));
          expect(vo.fontType, equals("PT Sans"));
          expect(vo.fontEffect, equals("0#0#0#0"));
          expect(vo.fontColor, equals("#000000"));
          expect(vo.backgroundColor, equals("#de4747"));
          expect(vo.isForOnlyStyleUpdate, equals(false));
          expect(vo.alwaysActive, equals(false));
          expect(vo.userId, equals(0));
          expect(vo.isDeactive, equals(false));
          expect(vo.defaultPermissionId, equals(0));
          expect(vo.statusName, equals("Open"));
          expect(vo.statusTypeID, equals(1));
          expect(vo.projectId, equals("2089700\$\$Otjm0d"));
          expect(vo.orgId, equals("0\$\$2YKo1Z"));
          expect(vo.proxyUserId, equals(0));
          expect(vo.isEnableForReviewComment, equals(false));
          expect(vo.generateURI, equals(true));
        });

    test(
        'copyWith should return a new StatusRecordStyleVo object with updated values',
            () {
          final vo = StatusRecordStyle(
              settingApplyOn: 1,
              fontType: "PT Sans",
              fontEffect: "0#0#0#0",
              fontColor: "#000000",
              backgroundColor: "#de4747",
              isForOnlyStyleUpdate: false,
              alwaysActive: false,
              userId: 0,
              isDeactive: false,
              defaultPermissionId: 0,
              statusName: "Open",
              statusID: 1001,
              statusTypeID: 1,
              projectId: "2089700\$\$Otjm0d",
              orgId: "0\$\$2YKo1Z",
              proxyUserId: 0,
              isEnableForReviewComment: false,
              generateURI: true);

          final updated = vo.copyWith();

          expect(vo.settingApplyOn, equals(1));
          expect(vo.fontType, equals("PT Sans"));
          expect(vo.fontEffect, equals("0#0#0#0"));
          expect(vo.fontColor, equals("#000000"));
          expect(vo.backgroundColor, equals("#de4747"));
          expect(vo.isForOnlyStyleUpdate, equals(false));
          expect(vo.alwaysActive, equals(false));
          expect(vo.userId, equals(0));
          expect(vo.isDeactive, equals(false));
          expect(vo.defaultPermissionId, equals(0));
          expect(vo.statusName, equals("Open"));
          expect(vo.statusTypeID, equals(1));
          expect(vo.projectId, equals("2089700\$\$Otjm0d"));
          expect(vo.orgId, equals("0\$\$2YKo1Z"));
          expect(vo.proxyUserId, equals(0));
          expect(vo.isEnableForReviewComment, equals(false));
          expect(vo.generateURI, equals(true));
        });

    test(
        'StatusRecordStyleVo.toJson should convert a StatusRecordStyleVo object to JSON',
            () {
          // Create a sample FloorDetail object
          final notificationVo = StatusRecordStyle(
              settingApplyOn: 1,
              fontType: "PT Sans",
              fontEffect: "0#0#0#0",
              fontColor: "#000000",
              backgroundColor: "#de4747",
              isForOnlyStyleUpdate: false,
              alwaysActive: false,
              userId: 0,
              isDeactive: false,
              defaultPermissionId: 0,
              statusName: "Open",
              statusID: 1001,
              statusTypeID: 1,
              projectId: "2089700\$\$Otjm0d",
              orgId: "0\$\$2YKo1Z",
              proxyUserId: 0,
              isEnableForReviewComment: false,
              generateURI: true);
          // Convert the FloorDetail object to JSON
          final json = notificationVo.toJson();

          // Check if the JSON object is correctly generated
          expect(json['settingApplyOn'], 1);
          expect(json['fontType'], "PT Sans");
          expect(json['fontEffect'], "0#0#0#0");
          expect(json['fontColor'], "#000000");
          expect(json['backgroundColor'], "#de4747");
          expect(json['isForOnlyStyleUpdate'], false);
          expect(json['always_active'], false);
          expect(json['userId'], 0);
          expect(json['isDeactive'], false);
          expect(json['defaultPermissionId'], 0);
          expect(json['statusName'], "Open");
          expect(json['statusID'], 1001);
          expect(json['statusTypeID'], 1);
          expect(json['projectId'], "2089700\$\$Otjm0d");
          expect(json['orgId'], "0\$\$2YKo1Z");
          expect(json['proxyUserId'], 0);
          expect(json['isEnableForReviewComment'], false);
          expect(json['generateURI'], true);
        });
  });
}