import 'dart:convert';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson should convert JSON map to AppType object', () {
    final jsonString = '{"formTypeID" : "11070321\$\$Vk5Nkt","formTypeName" : "C HTML","code" : "CHTM","appBuilderCode" : "CHTM","projectID" : "2116416\$\$oWL9LO","msgId" : "0\$\$g0ex35","dataCenterId" : 1,"formId" : "0\$\$Q6LYWg","createFormsLimit" : 0,"createdMsgCount" : 247,"draftCount" : 126,"draftMsgId" : 12303660,"appTypeId" : 1,"isFromWhere" : 0,"projectName" : "!!PIN_ANY_APP_TYPE_20_9","instanceGroupId" : "10390542\$\$Qf2DQI","templateType" : 2,"isRecent" : true,"formTypeGroupName" : "Construction","formTypeGroupID" : null,"formTypeDetailJson" : null,"generateURI" : true,"isMarkDefault" : false,"allowLocationAssociation" : null,"canCreateForms" : null,"isUseController" : null}';

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final appTypeVo = AppType.fromJson(jsonMap);

    expect(appTypeVo.formTypeID, equals("11070321\$\$Vk5Nkt"));
    expect(appTypeVo.formTypeName, equals("C HTML"));
    expect(appTypeVo.code, equals("CHTM"));
    expect(appTypeVo.appBuilderCode, equals("CHTM"));
    expect(appTypeVo.projectID, equals("2116416\$\$oWL9LO"));
    expect(appTypeVo.msgId, equals("0\$\$g0ex35"));
    expect(appTypeVo.dataCenterId, equals(1));
    expect(appTypeVo.formId, equals("0\$\$Q6LYWg"));
    expect(appTypeVo.createFormsLimit, equals(0));
    expect(appTypeVo.createdMsgCount, equals(247));
    expect(appTypeVo.draftCount, equals(null));
    expect(appTypeVo.draftMsgId, equals(12303660));
    expect(appTypeVo.appTypeId, equals(1));
    expect(appTypeVo.isFromWhere, equals(0));
    expect(appTypeVo.projectName, equals("!!PIN_ANY_APP_TYPE_20_9"));
    expect(appTypeVo.instanceGroupId, equals("10390542\$\$Qf2DQI"));
    expect(appTypeVo.templateType, equals(2));
    expect(appTypeVo.isRecent, equals(true));
    expect(appTypeVo.formTypeGroupName, equals("Construction"));
    expect(appTypeVo.formTypeGroupID, equals(null));
    expect(appTypeVo.formTypeDetailJson, equals(null));
    expect(appTypeVo.generateURI, equals(true));
    expect(appTypeVo.isMarkDefault, equals(false));
    expect(appTypeVo.allowLocationAssociation, equals(null));
    expect(appTypeVo.canCreateForms, equals(null));
    expect(appTypeVo.isUseController, equals(null));
  });


  test('fromJsonSync should convert JSON map to AppType object', () {
    final jsonString = '{"formTypeID" : "11070321\$\$Vk5Nkt","formTypeName" : "C HTML","code" : "CHTM","appBuilderCode" : "CHTM","projectID" : "2116416\$\$oWL9LO","msgId" : "0\$\$g0ex35","dataCenterId" : 1,"formId" : "0\$\$Q6LYWg","createFormsLimit" : 0,"createdMsgCount" : 247,"draftCount" : 126,"draftMsgId" : 12303660,"appId" : 1,"isFromWhere" : 0,"projectName" : "!!PIN_ANY_APP_TYPE_20_9","instanceGroupId" : "10390542\$\$Qf2DQI","templateType" : 2,"isRecent" : true,"formTypeGroupName" : "Construction","formTypeGroupID" : null,"formTypeDetailJson" : null,"generateURI" : true,"isMarkDefault" : false,"allowLocationAssociation" : null,"canCreateForms" : null,"isUseController" : null}';

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final appTypeVo = AppType.fromJsonSync(jsonMap);

    expect(appTypeVo.formTypeID, equals("11070321\$\$Vk5Nkt"));
    expect(appTypeVo.formTypeName, equals("C HTML"));
    expect(appTypeVo.code, equals(null));
    expect(appTypeVo.appBuilderCode, equals(null));
    expect(appTypeVo.projectID, equals(null));
    expect(appTypeVo.msgId, equals(null));
    expect(appTypeVo.dataCenterId, equals(null));
    expect(appTypeVo.formId, equals(null));
    expect(appTypeVo.createFormsLimit, equals(null));
    expect(appTypeVo.createdMsgCount, equals(null));
    expect(appTypeVo.draftCount, equals(null));
    expect(appTypeVo.draftMsgId, equals(null));
    expect(appTypeVo.appTypeId, equals(1));
    expect(appTypeVo.isFromWhere, equals(null));
    expect(appTypeVo.projectName, equals(null));
    expect(appTypeVo.instanceGroupId, equals("10390542\$\$Qf2DQI"));
    expect(appTypeVo.templateType, equals(null));
    expect(appTypeVo.isRecent, equals(null));
    expect(appTypeVo.formTypeGroupName, equals("Construction"));
    expect(appTypeVo.formTypeGroupID, equals(null));
    expect(appTypeVo.generateURI, equals(null));
    expect(appTypeVo.isMarkDefault, equals(false));
    expect(appTypeVo.allowLocationAssociation, equals(null));
    expect(appTypeVo.canCreateForms, equals(null));
    expect(appTypeVo.isUseController, equals(null));
  });

  test('toJson should convert AppType object to JSON map', () {
    final appType = AppType(
        formTypeID : "11070321\$\$Vk5Nkt",
        formTypeName : "C HTML",
        code : "CHTM",
        appBuilderCode : "CHTM",
        projectID : "2116416\$\$oWL9LO",
        msgId : "0\$\$g0ex35",
        dataCenterId : 1,
        formId : "0\$\$Q6LYWg",
        createFormsLimit : 0,
        createdMsgCount : 247,
        draftCount : 126,
        draftMsgId : 12303660,
        appTypeId : 1,
        isFromWhere : 0,
        projectName : "!!PIN_ANY_APP_TYPE_20_9",
        instanceGroupId : "10390542\$\$Qf2DQI",
        templateType : 2,
        isRecent : true,
        formTypeGroupName : "Construction",
        generateURI : true,
        isMarkDefault : false,
    );

    appType.formTypeDetailJson='{}';

    final jsonMap = appType.toJson();

    expect(jsonMap['formTypeID'], equals("11070321\$\$Vk5Nkt"));
    expect(jsonMap['formTypeName'], equals("C HTML"));
    expect(jsonMap['code'], equals("CHTM"));
    expect(jsonMap['appBuilderCode'], equals("CHTM"));
    expect(jsonMap['projectID'], equals("2116416\$\$oWL9LO"));
    expect(jsonMap['msgId'], equals("0\$\$g0ex35"));
    expect(jsonMap['dataCenterId'], equals(1));
    expect(jsonMap['formId'], equals("0\$\$Q6LYWg"));
    expect(jsonMap['createFormsLimit'], equals(0));
    expect(jsonMap['createdMsgCount'], equals(247));
    expect(jsonMap['draftCount'], equals(null));
    expect(jsonMap['draftMsgId'], equals(12303660));
    expect(jsonMap['appTypeId'], equals(1));
    expect(jsonMap['isFromWhere'], equals(0));
    expect(jsonMap['projectName'], equals("!!PIN_ANY_APP_TYPE_20_9"));
    expect(jsonMap['instanceGroupId'], equals("10390542\$\$Qf2DQI"));
    expect(jsonMap['templateType'], equals(2));
    expect(jsonMap['isRecent'], equals(true));
    expect(jsonMap['formTypeGroupName'], equals("Construction"));
    expect(jsonMap['generateURI'], equals(true));
    expect(jsonMap['isMarkDefault'], equals(false));

  });
}
