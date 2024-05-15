import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/bloc/web_view/web_view_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/screen/webview/asite_webview.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../bloc/mock_method_channel.dart';
import '../bloc/project_list_cubit_test.dart';

GetIt getIt = GetIt.instance;

void main(){
  configureLoginCubitDependencies() {
    TestWidgetsFlutterBinding.ensureInitialized();
    MockMethodChannel().setNotificationMethodChannel();
    init(test: true);
  }
  generateParamasToCreateForm(){
    Map<String, dynamic> obj = {};
    obj['projectId'] = "2089700\$\$jhhgbL";
    obj['appBuilderCode'] = "ASI-SITE";
    obj['projectName'] = "KrupalField19.8UK";
    obj['appTypeId'] = 2;
    obj['msgId'] = "0\$\$7hmZkN";
    obj['formId'] = "0\$\$U2zI2e";
    obj['formTypeID'] = "11104816\$\$Xx966t";
    obj['formTypeName'] = "Site Tasks";
    obj['instanceGroupId'] = "10443853\$\$VPlv09";
    obj['templateType'] = 2;
    obj['isFromWhere'] = 0;
    obj['formSelectRadiobutton'] = "1_2089700\$\$jhhgbL_11104816\$\$Xx966t";
    obj['locationId'] = "0";
    obj['url'] = "https://adoddleqaak.asite.com/adoddle/apps?action_id=903&screen=new&application_Id=3&applicationId=3&isAndroid=true&isFromApps=true&isNewUI=true&numberOfRecentDefect=5&isMultipleAttachment=true&v=1689749438693&projectId=2089700\$\$jhhgbL&appBuilderCode=ASI-SITE&projectName=KrupalField19.8UK&appTypeId=2&msgId=0\$\$7hmZkN&formId=0\$\$U2zI2e&formTypeID=11104816\$\$Xx966t&formTypeName=Site Tasks&instanceGroupId=10443853\$\$VPlv09&templateType=2&isFromWhere=0&formSelectRadiobutton=1_2089700\$\$jhhgbL_11104816\$\$Xx966t&projectids=2089700";
    obj['isFrom'] = FromScreen.dashboard;

    return obj;
  }
  group("Test Assign Site Task WebView widget", () {
    configureLoginCubitDependencies();
    AsiteWebView? myWidget;
    MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => getIt<WebViewCubit>(),
          child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: myWidget = AsiteWebView(
                url: Uri.decodeFull("https://adoddleqaak.asite.com/adoddle/apps?action_id=903&screen=new&application_Id=3&applicationId=3&isAndroid=true&isFromApps=true&isNewUI=true&numberOfRecentDefect=5&isMultipleAttachment=true&v=1689749438693&projectId=2089700\$\$jhhgbL&appBuilderCode=ASI-SITE&projectName=KrupalField19.8UK&appTypeId=2&msgId=0\$\$7hmZkN&formId=0\$\$U2zI2e&formTypeID=11104816\$\$Xx966t&formTypeName=Site Tasks&instanceGroupId=10443853\$\$VPlv09&templateType=2&isFromWhere=0&formSelectRadiobutton=1_2089700\$\$jhhgbL_11104816\$\$Xx966t&projectids=2089700"),
                title: "Site Task",
                data: generateParamasToCreateForm(),
                isAppbarRequired: true,
              )),
        ));

    testWidgets("Find Assign Site Task WebView widget", (tester) async {
      await tester.pump(const Duration(seconds: 5));
      Finder formWidgetFinder = find.byType(InAppWebView);
      expect(formWidgetFinder, findsNothing);
    });

    testWidgets("initialUrlRequest", (tester) async {
      await tester.pump(const Duration(seconds: 5));
      final String? currentUrl = myWidget?.url;
      expect(currentUrl,
          "https://adoddleqaak.asite.com/adoddle/apps?action_id=903&screen=new&application_Id=3&applicationId=3&isAndroid=true&isFromApps=true&isNewUI=true&numberOfRecentDefect=5&isMultipleAttachment=true&v=1689749438693&projectId=2089700\$\$jhhgbL&appBuilderCode=ASI-SITE&projectName=KrupalField19.8UK&appTypeId=2&msgId=0\$\$7hmZkN&formId=0\$\$U2zI2e&formTypeID=11104816\$\$Xx966t&formTypeName=Site Tasks&instanceGroupId=10443853\$\$VPlv09&templateType=2&isFromWhere=0&formSelectRadiobutton=1_2089700\$\$jhhgbL_11104816\$\$Xx966t&projectids=2089700");
    });
  });
}