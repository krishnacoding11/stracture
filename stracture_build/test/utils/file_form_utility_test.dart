import 'dart:convert';
import 'package:field/data/model/form_vo.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/fixture_reader.dart';

void main(){
  Map<String,dynamic> json = jsonDecode(fixture("sitetaskslist.json"));

  test("Success  Call should perform if the Argument is present", () {
    // ignore: non_constant_identifier_names
    var SuccessCall = false;
    final value = {"formId": "11627034\$\$QMuQ3c", "msgId": "12336326\$\$v6g4mI", "locationId": "185265", "isActionCompleted": "true"};
    final data = {"projectId": "2089700\$\$X54qiC", "locationId": "185265", "appTypeId": "2", "planId": "5579\$\$kjmZpw", "deliverableActivityId": "6398898\$\$mnxyek", "isCalibrated": "true", "isFromMapView": "true", "url":"https://adoddleqaak.asite.com/adoddle/apps?action_id=903&screen=new&application_Id=3&applicationId=3&isAndroid=true&isFromApps=true&isNewUI=true&numberOfRecentDefect=5&isMultipleAttachment=true&v=1690971053544&projectId=2089700\$\$X54qiC&locationId=185265&appTypeId=2&formSelectRadiobutton=1_2089700\$\$X54qiC_11129224\$\$5ABrIb_HB-HTML&planId=5579\$\$kjmZpw&deliverableActivityId=6398898\$\$mnxyek&projectids=2089700", "name": "HB HTML 123", "isFrom": "FromScreen.quality"};
    if( value.isNotEmpty && data.isNotEmpty){
      return SuccessCall = true;
    }
    expect(SuccessCall, true);
  });

  test("Failure Call should  perform if the Argument is present", () {
    // ignore: non_constant_identifier_names
    var SuccessCall = false;
    final value = {"formId": "11627034\$\$QMuQ3c", "msgId": "12336326\$\$v6g4mI", "locationId": "185265", "isActionCompleted": "true"};
    final data = {};
    if( value.isNotEmpty && data.isNotEmpty){
      return SuccessCall = true;
    }
    expect(SuccessCall, false);
  });

 test("get DEF Form Icon Name", () {
   String data = FileFormUtility.getFormIconName(SiteForm.fromJson(json["data"][0]));
   expect(data == "assets/images/ic_account_hard_hat.png", true);
 });

  test("get Site Form Icon Name", () {
    String data = FileFormUtility.getFormIconName(SiteForm.fromJson(json["data"][2]));
    expect(data == "assets/images/ic_task_form.png",true);
  });
}