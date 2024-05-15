import 'dart:convert';

import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/site_form_action.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import '../../lib/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/constants.dart';
import 'package:field/utils/url_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';
import 'load_url.dart';

class DBServiceMock extends Mock implements DBService {}

GetIt getIt = GetIt.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setAsitePluginsMethodChannel();
  AConstants.loadProperty();


  configureCubitDependencies() {
    di.init(test: true);
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      "userData": fixture("user_data.json"),
      "cloud_type_data": "1",
      "1_u1_project_": fixture("project.json")
    });
  });


  group("getORIFormURLByAction:", () {
    configureCubitDependencies();
    test('Url for Assign Status', () async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      final dataNode = json['data'];
      SiteForm form = SiteForm.fromJson(dataNode[0]);
      // SiteFormAction action = SiteFormAction(actionId: "2");
      form.actions = [SiteFormAction(actionId: "2", actionStatus: "0")];
      String result = await UrlHelper.getORIFormURLByAction(form);
      expect(
          'https://adoddleqaak.asite.com/adoddle/view/communications/viewForm.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&isMultipleAttachment=true&callFor=viewForm&projectId=2116416\$\$35785c&projectids=2116416&isDraft=false&checkHashing=false&formID=10955881\$\$XTWMOk&formTypeId=10597040\$\$mxbedK&dcId=1&statusId=1001&parentmsgId=0&msgTypeCode=ORI&msgCode=ORI001&originatorId=78994&msgId=11276706\$\$bBz4RR&toOpen=FromForms&commId=10955881\$\$D9nMPV&numberOfRecentDefect=5&appTypeId=2&projectids=2116416',
          result);
    });
    test('Url for Distribute', () async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      final dataNode = json['data'];
      SiteForm form = SiteForm.fromJson(dataNode[0]);
      // SiteFormAction action = SiteFormAction(actionId: "6");
      form.actions = [SiteFormAction(actionId: "6", actionStatus: "0")];
      String result = await UrlHelper.getORIFormURLByAction(form);
      expect('https://adoddleqaak.asite.com/adoddle/view/communications/viewForm.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&isMultipleAttachment=true&callFor=viewForm&projectId=2116416\$\$35785c&projectids=2116416&isDraft=false&checkHashing=false&formID=10955881\$\$XTWMOk&formTypeId=10597040\$\$mxbedK&dcId=1&statusId=1001&parentmsgId=0&msgTypeCode=ORI&msgCode=ORI001&originatorId=78994&msgId=11276706\$\$bBz4RR&toOpen=FromForms&commId=10955881\$\$D9nMPV&numberOfRecentDefect=5&appTypeId=2&projectids=2116416',
          result);
    });
    test('Url for For Acknowledgement', () async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      final dataNode = json['data'];
      SiteForm form = SiteForm.fromJson(dataNode[0]);
      // SiteFormAction action = SiteFormAction(actionId: "37");
      form.actions = [SiteFormAction(actionId: "37", actionStatus: "0")];
      String result = await UrlHelper.getORIFormURLByAction(form);
      expect('https://adoddleqaak.asite.com/adoddle/view/communications/viewForm.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&isMultipleAttachment=true&callFor=viewForm&projectId=2116416\$\$35785c&projectids=2116416&isDraft=false&checkHashing=false&formID=10955881\$\$XTWMOk&formTypeId=10597040\$\$mxbedK&dcId=1&statusId=1001&parentmsgId=0&msgTypeCode=ORI&msgCode=ORI001&originatorId=78994&msgId=11276706\$\$bBz4RR&toOpen=FromForms&commId=10955881\$\$D9nMPV&numberOfRecentDefect=5&appTypeId=2&projectids=2116416'
          , result);
    });
    test('Url for For Action', () async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      final dataNode = json['data'];
      SiteForm form = SiteForm.fromJson(dataNode[0]);
      // SiteFormAction action = SiteFormAction(actionId: "36");
      form.actions = [SiteFormAction(actionId: "36", actionStatus: "0")];
      String result = await UrlHelper.getORIFormURLByAction(form);
      expect('https://adoddleqaak.asite.com/adoddle/view/communications/viewForm.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&isMultipleAttachment=true&callFor=viewForm&projectId=2116416\$\$35785c&projectids=2116416&isDraft=false&checkHashing=false&formID=10955881\$\$XTWMOk&formTypeId=10597040\$\$mxbedK&dcId=1&statusId=1001&parentmsgId=0&msgTypeCode=ORI&msgCode=ORI001&originatorId=78994&msgId=11276706\$\$bBz4RR&toOpen=FromForms&commId=10955881\$\$D9nMPV&numberOfRecentDefect=5&appTypeId=2&projectids=2116416'
          , result);
    });
    test('Url for Respond', () async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      final dataNode = json['data'];
      SiteForm form = SiteForm.fromJson(dataNode[0]);
      // SiteFormAction action = SiteFormAction(actionId: "3");
      form.actions = [SiteFormAction(actionId: "3", actionStatus: "0")];
      String result = await UrlHelper.getORIFormURLByAction(form);
      expect('https://adoddleqaak.asite.com/adoddle/view/communications/viewForm.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&isMultipleAttachment=true&callFor=viewForm&projectId=2116416\$\$35785c&projectids=2116416&isDraft=false&checkHashing=false&formID=10955881\$\$XTWMOk&formTypeId=10597040\$\$mxbedK&dcId=1&statusId=1001&parentmsgId=0&msgTypeCode=ORI&msgCode=ORI001&originatorId=78994&msgId=11276706\$\$bBz4RR&toOpen=FromForms&commId=10955881\$\$D9nMPV&numberOfRecentDefect=5&appTypeId=2&projectids=2116416'
          , result);
    });
    test('Url for Review Draft', () async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      final dataNode = json['data'];
      SiteForm form = SiteForm.fromJson(dataNode[0]);
      // SiteFormAction action = SiteFormAction(actionId: "37");
      form.actions = [SiteFormAction(actionId: "37", actionStatus: "0")];
      String result = await UrlHelper.getORIFormURLByAction(form);
      expect('https://adoddleqaak.asite.com/adoddle/view/communications/viewForm.jsp?applicationId=3&application_Id=3&isNewUI=true&isAndroid=true&isMultipleAttachment=true&callFor=viewForm&projectId=2116416\$\$35785c&projectids=2116416&isDraft=false&checkHashing=false&formID=10955881\$\$XTWMOk&formTypeId=10597040\$\$mxbedK&dcId=1&statusId=1001&parentmsgId=0&msgTypeCode=ORI&msgCode=ORI001&originatorId=78994&msgId=11276706\$\$bBz4RR&toOpen=FromForms&commId=10955881\$\$D9nMPV&numberOfRecentDefect=5&appTypeId=2&projectids=2116416'
          , result);
    });
  });
}