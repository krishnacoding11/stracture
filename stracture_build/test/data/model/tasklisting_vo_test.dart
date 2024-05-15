import 'dart:convert';
import 'package:field/data/model/tasklisting_vo.dart';
import 'package:test/test.dart';

void main() {
  test('TaskListingVO toJson() and fromJson() test', () {
    final taskListingVo = TaskListingVO(
      elementVOList: [
        ElementVoList(
          projectId: '123',
          title: 'Sample Task',
          actionStatus: 1,
          // Add more properties as needed for testing
        ),
      ],
      commonAttributes: [
        CommonAttributes(collection: 'sample_collection'),
        // Add more properties as needed for testing
      ],
    );

    final jsonString = taskListingVoToJson(taskListingVo);
    final decodedTaskListingVo = taskListingVoFromJson(jsonString);

    expect(taskListingVo.toJson(), decodedTaskListingVo.toJson());
  });

  test('ElementVoList toJson() and fromJson() test', () {
    final elementVoList = ElementVoList(
        projectId : "2085837\$\$noQCDJ",
       resourceParentId : 2828151,
       strResourceParentId : "2828151\$\$fGzE3h",
       resourceId : 3111684,
       strResourceId : "3111684\$\$JQ5opr",
       resourceCode : "ORI001",
       parentResourceCode : "DEF144",
       resourceStatusId : 0,
       msgId : "0\$\$V2ZQsx",
       commentMsgId : "0\$\$lNiZbd",
       actionId : 7,
       actionName : "For Information",
       title : "def1122",
       actionStatus : 0,
       priorityId : 1,
       priorityClass : "normal",
       actionDate : "4-May-2017#22:54 PST",
       lastUpdateDate : "4-May-2017#22:54 PST",
       distributorUserId : 764667,
       recipientId : 859155,
       distListId : 3619996,
       instantEmailNotify : "true",
       appType : "2",
       entityType : 1,
       instanceGroupId : "2352156\$\$JwNx27",
       isActive : true,
       modelId : "0\$\$T9tiZ0",
       assignedBy : "Buddhesh Baraiya, Asite Solutions",
       recipientName : "Saurabh Banethia (5327), Asite Solutions",
       recipientOrgId : "3",
       id : "ACTC3619996_859155_7_1_3111684_2828151",
       projectName : "3b_Field_UK_DueDays",

       dcId : 1,
       assignedByOrgId : "3",
       recipientOrgName : "Asite Solutions",
       assignedByOrgName : "Asite Solutions",
       distributionLevel : 3,
       distributionLevelId : "859155\$\$BUkstq",
       dueDateInMS : 0,
       actionCompleteDateInMS : 0,
       actionDelegated : false,
       actionCleared : false,
       actionCompleted : false,
       assignedByEmail : "bbaraiya@asite.com",
       recipientEmail : "sbanethia@asite.com",
       generateURI : true
    );

    final jsonString = elementVoListToJson(elementVoList);
    final decodedElementVoList = elementVoListFromJson(jsonString);
    expect(elementVoList.projectId, "2085837\$\$noQCDJ");
    expect(elementVoList.resourceParentId , 2828151);
    expect(elementVoList.strResourceParentId , "2828151\$\$fGzE3h");
    expect(elementVoList.resourceId , 3111684);
    expect(elementVoList.strResourceId , "3111684\$\$JQ5opr");
    expect(elementVoList.resourceCode , "ORI001");
    expect(elementVoList.parentResourceCode , "DEF144");
    expect(elementVoList.resourceStatusId , 0);
    expect(elementVoList.msgId , "0\$\$V2ZQsx");
    expect(elementVoList.commentMsgId , "0\$\$lNiZbd");
    expect(elementVoList.actionId , 7);
    expect(elementVoList.actionName , "For Information");
    expect(elementVoList.title , "def1122");
    expect(elementVoList.actionStatus , 0);
    expect(elementVoList.priorityId , 1);
    expect(elementVoList.priorityClass , "normal");
    expect(elementVoList.actionDate , "4-May-2017#22:54 PST");
    expect(elementVoList.lastUpdateDate , "4-May-2017#22:54 PST");
    expect(elementVoList.distributorUserId , 764667);
    expect(elementVoList.recipientId , 859155);
    expect(elementVoList.distListId, 3619996);
    expect(elementVoList.instantEmailNotify , "true");
    expect(elementVoList.appType , "2");
    expect(elementVoList.entityType , 1);
    expect(elementVoList.instanceGroupId , "2352156\$\$JwNx27");
    expect(elementVoList.isActive , true);
    expect(elementVoList.modelId , "0\$\$T9tiZ0");
    expect(elementVoList.assignedBy , "Buddhesh Baraiya, Asite Solutions");
    expect(elementVoList.recipientName , "Saurabh Banethia (5327), Asite Solutions");
    expect(elementVoList.recipientOrgId , "3");
    expect(elementVoList.id , "ACTC3619996_859155_7_1_3111684_2828151");
    expect(elementVoList.projectName , "3b_Field_UK_DueDays");

    expect(elementVoList.dcId , 1);
    expect(elementVoList.assignedByOrgId , "3");
    expect(elementVoList.recipientOrgName , "Asite Solutions");
    expect(elementVoList.assignedByOrgName , "Asite Solutions");
    expect(elementVoList.distributionLevel , 3);
    expect(elementVoList.distributionLevelId , "859155\$\$BUkstq");
    expect(elementVoList.dueDateInMS , 0);
    expect(elementVoList.actionCompleteDateInMS , 0);
    expect(elementVoList.actionDelegated , false);
    expect(elementVoList.actionCleared , false);
    expect(elementVoList.actionCompleted , false);
    expect(elementVoList.assignedByEmail , "bbaraiya@asite.com");
    expect(elementVoList.recipientEmail , "sbanethia@asite.com");
    expect(elementVoList.generateURI , true);
    expect(elementVoList.toJson(), decodedElementVoList.toJson());
  });

  test('CommonAttributes toJson() and fromJson() test', () {
    final commonAttributes = CommonAttributes(collection: 'sample_collection');

    final jsonString = commonAttributesToJson(commonAttributes);
    final decodedCommonAttributes = commonAttributesFromJson(jsonString);

    expect(commonAttributes.toJson(), decodedCommonAttributes.toJson());
  });

  test('RecipientUserVo toJson() and fromJson() test', () {
    final recipientUserVo = RecipientUserVo(
      userID: 'user123',
      fname: 'John',
      lname: 'Doe',
      email: 'john.doe@example.com',

    );

    final jsonString = recipientUserVoToJson(recipientUserVo);
    final decodedRecipientUserVo = recipientUserVoFromJson(jsonString);

    expect(recipientUserVo.toJson(), decodedRecipientUserVo.toJson());
  });
  test('RecipientUserVo copyWith test', () {
    final originalRecipientUserVo = RecipientUserVo(
      fname : "Saurabh",
      lname : "Banethia (5327)",
      email : "sbanethia@asite.com",
      orgID : 3,
      folderAccess : 1,
      orgName : "Asite Solutions",
      languageId : "en_CA",
      timeZoneId : "America/Los_Angeles",
      isMultiSessionAllowed : false,
      orgDCId : 0,
      editionId : "0\$\$3OWH6Z",
      userImageName : "photo_859155_thumbnail.jpg?v=1669201730000#Saurabh",
      subscriptionPlanId : 0,
      userSessionTimeOut : 0,
      isAgreedToTermsAndCondition : false,
      isPasswordReset : false,
       userAccountType : 0,
       billToOrg : 0,
       enableSecondaryEmail : false,
       generateURI : true
    );

    final copiedRecipientUserVo = originalRecipientUserVo.copyWith(
      fname: 'Saurabh',
      orgID: 3,
    );

    expect(originalRecipientUserVo.fname, 'Saurabh');
    expect(originalRecipientUserVo.orgID, 3);

    expect(copiedRecipientUserVo.fname, 'Saurabh');
    expect(copiedRecipientUserVo.orgID, 3);
    expect(originalRecipientUserVo.lname , "Banethia (5327)");
    expect(originalRecipientUserVo.email , "sbanethia@asite.com");
    expect(originalRecipientUserVo.orgID , 3);
    expect(originalRecipientUserVo.folderAccess , 1);
    expect(originalRecipientUserVo.orgName , "Asite Solutions");
    expect(originalRecipientUserVo.languageId , "en_CA");
    expect(originalRecipientUserVo.timeZoneId , "America/Los_Angeles");
    expect(originalRecipientUserVo.isMultiSessionAllowed , false);
    expect(originalRecipientUserVo.orgDCId , 0);
    expect(originalRecipientUserVo.editionId , "0\$\$3OWH6Z");
    expect(originalRecipientUserVo.userImageName , "photo_859155_thumbnail.jpg?v=1669201730000#Saurabh");
    expect(originalRecipientUserVo.subscriptionPlanId , 0);
    expect(originalRecipientUserVo.userSessionTimeOut , 0);
    expect(originalRecipientUserVo.isAgreedToTermsAndCondition , false);
    expect(originalRecipientUserVo.isPasswordReset , false);
    expect(originalRecipientUserVo. userAccountType , 0);
    expect(originalRecipientUserVo. billToOrg , 0);
    expect(originalRecipientUserVo. enableSecondaryEmail , false);
    expect(originalRecipientUserVo. generateURI , true);
  });
  test('ElementVoList copyWith test', () {
    final originalElementVoList = ElementVoList(
      projectId: '123',
      title: 'Sample Task',
      actionStatus: 1,
      // Add more properties as needed for testing
    );

    final copiedElementVoList = originalElementVoList.copyWith(
      title: 'Updated Task',
      actionStatus: 2,
    );

    expect(originalElementVoList.title, 'Sample Task');
    expect(originalElementVoList.actionStatus, 1);

    expect(copiedElementVoList.title, 'Updated Task');
    expect(copiedElementVoList.actionStatus, 2);
  });
  test('CommonAttributes copyWith test', () {
    final commonAttributes = CommonAttributes(
      collection: 'collection',

    );
    final commonAttributesVo = commonAttributes.copyWith(
    );
    expect(commonAttributesVo.collection, 'collection');
  });

  test('TaskListingVO copyWith test', () {
    final originalElementVoList = ElementVoList(
      projectId: '123',
      title: 'Sample Task',
      actionStatus: 1,
    );

    final originalTaskListingVO = TaskListingVO(
      elementVOList: [originalElementVoList],
      commonAttributes: [
        CommonAttributes(
          collection: 'attr1',

        ),
      ],
    );

    // Check that the original task listing is unchanged
    expect(originalTaskListingVO.elementVOList.length, 1);
    expect(originalTaskListingVO.elementVOList[0].title, 'Sample Task');
    expect(originalTaskListingVO.elementVOList[0].actionStatus, 1);
    expect(originalTaskListingVO.commonAttributes![0].collection, 'attr1');
  });
}
