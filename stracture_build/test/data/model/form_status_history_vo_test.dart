import 'dart:convert';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/form_status_history_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson should convert JSON map to BimModelCalibrationModel object', () {
final jsonString = '{"appTypeId": "12345", "projectId": "556361", "formTypeId": "516196", "selectedFormId": "1516261", "messageId": "152641", "actionUserId": "516261", "actionUserName": "action_username", "actionUserOrgName": "testname", "actionProxyUserId": "66151", "actionProxyUserName": "textProxyUserName", "actionProxyUserOrgName": "testUserOrgName", "actionUserTypeId": "511664", "actionId": "26", "actionDate": "15152641", "description": "15166415", "remarks": "sd6613", "createDateInMS": "test", "jsonData": "61616116162", "locationId": "16646162", "observationId": "1646626"}';
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final formStatusHistoryVO = FormStatusHistoryVO.fromJson(jsonMap);

    expect(formStatusHistoryVO.strAppTypeId, equals("12345"));
    expect(formStatusHistoryVO.strProjectId, equals("556361"));
    expect(formStatusHistoryVO.strFormTypeId, equals("516196"));
    expect(formStatusHistoryVO.strFormId, equals("1516261"));
    expect(formStatusHistoryVO.strMessageId, equals("152641"));
    expect(formStatusHistoryVO.strActionUserId, equals("516261"));
    expect(formStatusHistoryVO.strActionUserName, equals("action_username"));
    expect(formStatusHistoryVO.strActionUserOrgName, equals("testname"));
    expect(formStatusHistoryVO.strActionProxyUserId, equals("66151"));
    expect(formStatusHistoryVO.strActionProxyUserName, equals("textProxyUserName"));
    expect(formStatusHistoryVO.strActionProxyUserOrgName, equals("testUserOrgName"));
    expect(formStatusHistoryVO.strActionUserTypeId, equals("511664"));
    expect(formStatusHistoryVO.strActionId, equals("26"));
    expect(formStatusHistoryVO.strActionDate, equals("15152641"));
    expect(formStatusHistoryVO.strDescription, equals("15166415"));
    expect(formStatusHistoryVO.strRemarks, equals("sd6613"));
    expect(formStatusHistoryVO.strCreateDateInMS, equals("test"));
    expect(formStatusHistoryVO.strJsonData, equals("61616116162"));
    expect(formStatusHistoryVO.strLocationId, equals("16646162"));
    expect(formStatusHistoryVO.strObservationId, equals("1646626"));
  });

  test('toJson should convert BimModelCalibrationModel object to JSON map', () {
    final formStatusHistoryVO = FormStatusHistoryVO(
        strAppTypeId:"12345",
        strProjectId:"556361",
        strFormTypeId:"516196",
        strFormId:"1516261",
        strMessageId:"152641",
        strActionUserId:"516261",
        strActionUserName:"action_username",
        strActionUserOrgName:"testname",
        strActionProxyUserId:"66151",
        strActionProxyUserName:"textProxyUserName",
        strActionProxyUserOrgName:"testUserOrgName",
        strActionUserTypeId:"511664",
        strActionId:"26",
        strActionDate:"15152641",
        strDescription:"15166415",
        strRemarks:"sd6613",
        strCreateDateInMS:"test",
        strJsonData:"61616116162",
        strLocationId:"16646162",
        strObservationId:"1646626"
    );
    expect(formStatusHistoryVO.strAppTypeId, equals("12345"));
    expect(formStatusHistoryVO.strProjectId, equals("556361"));
    expect(formStatusHistoryVO.strFormTypeId, equals("516196"));
    expect(formStatusHistoryVO.strFormId, equals("1516261"));
    expect(formStatusHistoryVO.strMessageId, equals("152641"));
    expect(formStatusHistoryVO.strActionUserId, equals("516261"));
    expect(formStatusHistoryVO.strActionUserName, equals("action_username"));
    expect(formStatusHistoryVO.strActionUserOrgName, equals("testname"));
    expect(formStatusHistoryVO.strActionProxyUserId, equals("66151"));
    expect(formStatusHistoryVO.strActionProxyUserName, equals("textProxyUserName"));
    expect(formStatusHistoryVO.strActionProxyUserOrgName, equals("testUserOrgName"));
    expect(formStatusHistoryVO.strActionUserTypeId, equals("511664"));
    expect(formStatusHistoryVO.strActionId, equals("26"));
    expect(formStatusHistoryVO.strActionDate, equals("15152641"));
    expect(formStatusHistoryVO.strDescription, equals("15166415"));
    expect(formStatusHistoryVO.strRemarks, equals("sd6613"));
    expect(formStatusHistoryVO.strCreateDateInMS, equals("test"));
    expect(formStatusHistoryVO.strJsonData, equals("61616116162"));
    expect(formStatusHistoryVO.strLocationId, equals("16646162"));
    expect(formStatusHistoryVO.strObservationId, equals("1646626"));
  });
  test('toJson should convert FormStatusHistoryVO object to fromJsonOffline', () async {
    final jsonString = '{"appTypeId": "12345", "projectId": "556361", "formTypeId": "516196", "selectedFormId": "1516261", "messageId": "152641", "actionUserId": "", "actionUserName": "", "actionUserOrgName": "", "actionProxyUserId": "", "actionProxyUserName": "", "actionProxyUserOrgName": "", "actionUserTypeId": "", "actionId": "26", "actionDate": "15152641", "description": "15166415", "remarks": "", "createDateInMS": "test", "jsonData": "61616116162", "locationId": "16646162", "observationId": "1646626"}';
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    User? currentUser = User();
    final formStatusHistoryVO = FormStatusHistoryVO.fromJsonOffline(jsonMap,currentUser);
    expect(formStatusHistoryVO.strAppTypeId, equals("12345"));
    expect(formStatusHistoryVO.strProjectId, equals("556361"));
    expect(formStatusHistoryVO.strFormTypeId, equals("516196"));
    expect(formStatusHistoryVO.strFormId, equals("1516261"));
    expect(formStatusHistoryVO.strMessageId, equals("152641"));
    expect(formStatusHistoryVO.strActionUserId, equals(currentUser.usersessionprofile?.userID ?? ""));
    expect(formStatusHistoryVO.strActionUserName, equals(currentUser.usersessionprofile?.tpdUserName ?? ""));
    expect(formStatusHistoryVO.strActionUserOrgName, equals(currentUser.usersessionprofile?.tpdOrgName ?? ""));
    expect(formStatusHistoryVO.strActionProxyUserId, equals(currentUser.usersessionprofile?.proxyUserID ?? ""));
    expect(formStatusHistoryVO.strActionProxyUserName, equals( currentUser.usersessionprofile?.proxyUserName ?? ""));
    expect(formStatusHistoryVO.strActionProxyUserOrgName, equals(currentUser.usersessionprofile?.proxyOrgName ?? ""));
    expect(formStatusHistoryVO.strActionUserTypeId, equals(currentUser.usersessionprofile?.userTypeId ?? ""));
    expect(formStatusHistoryVO.strActionId, equals("26"));
    expect(formStatusHistoryVO.strDescription, equals("Status Changed to null"));
    expect(formStatusHistoryVO.strRemarks, equals(""));
    expect(formStatusHistoryVO.strJsonData, equals(jsonEncode(jsonMap)));
    expect(formStatusHistoryVO.strLocationId, equals("16646162"));
    expect(formStatusHistoryVO.strObservationId, equals("1646626"));

  });
}
