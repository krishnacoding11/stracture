import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/presentation/screen/onboarding_login_screen.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:field/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';
import 'load_url.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  AppConfigTestData().setupAppConfigTestData();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setUpCheckPermissionStatus();
  MockMethodChannel().setAsitePluginsMethodChannel();
  MockMethodChannel().setgetapplabel();
  SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});
  AConstants.loadProperty();

  test('Random Number String is not empty', () {
    String strRandomNumber = Utility.generateRandomNumberForDocument();
    expect(true, strRandomNumber.isNotEmpty);
  });

  test('Is Random Number String length = 8', () {
    String strRandomNumber = Utility.generateRandomNumberForDocument();
    expect(8, strRandomNumber.length);
  });

  testWidgets('Find noModelWidget returns a center widget with text content', (WidgetTester tester) async {
    final widget = MediaQuery(data: MediaQueryData(), child: MaterialApp(home: Utility().noModelWidget('Hello')));
    await tester.pumpWidget(widget);
    expect(find.byType(Center), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('Device type found to be phone', (tester) async {
    tester.binding.window.physicalSizeTestValue = Size(800, 500);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    DeviceType deviceType = Utility.getDeviceType();
    expect(true, deviceType == DeviceType.phone);
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('Device type found to be tablet', (tester) async {
    tester.binding.window.physicalSizeTestValue = Size(800, 600);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    DeviceType deviceType = Utility.getDeviceType();
    expect(true, deviceType == DeviceType.tablet);
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('DeviceTablet type found to be phone', (tester) async {
    tester.binding.window.physicalSizeTestValue = Size(800, 600);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    DeviceType deviceTabletType = Utility.getDeviceTabletType();
    expect(true, deviceTabletType == DeviceType.phone);
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  testWidgets('DeviceTablet type found to be tablet', (tester) async {
    tester.binding.window.physicalSizeTestValue = Size(800, 700);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    DeviceType deviceTabletType = Utility.getDeviceTabletType();
    expect(true, deviceTabletType == DeviceType.tablet);
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  });

  //FAIL
  /*test('External Directory Path is not empty', () async {
    String? value = await Utility.getExternalDirectoryPath();
    expect(value?.isNotEmpty, true);
  });*/

  test('User Directory Path is not null', () async {
    String? value = await Utility.getUserDirPath();
    expect(value, isNotNull);
  });

  test('App Dir Path is not null', () async {
    String? value = await Utility.getAppDirPath();
    expect(value, isNotNull);
  });

  group('utils dialogs test', () {
    final key = GlobalKey();
    final testWidget = BlocProvider<LoginCubit>(
      create: (context) => di.getIt<LoginCubit>(),
      child: MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(
          navigatorKey: NavigationUtils.mainNavigationKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            key: key,
          ),
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ),
    );

    testWidgets('Find showAlertWithOk widget', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showAlertWithOk(key.currentContext!, "Failed", onPress: null);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("Message"), findsOneWidget);
      expect(find.text("Failed"), findsOneWidget);
      expect(find.text("OK"), findsOneWidget);
      await tester.tap(find.text("OK"));
      await tester.pump();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Find showAlertDialog widget', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showAlertDialog(key.currentContext!,"Asite field","Continue");
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("Asite field"), findsOneWidget);
      expect(find.text("Continue"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      await tester.tap(find.text("Continue"));
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Find showReLoginDialog widget', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showReLoginDialog(FAIL('Failed 401', 401));
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("Failed 401"), findsOneWidget);
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(OnBoardingLoginScreen), findsOneWidget);
    });

    testWidgets('Find showConfirmationDialog widget', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showConfirmationDialog( context: key.currentContext!, title: 'showConfirmationDialog',msg: 'Show Dialog', onPressOkButton: null , onPressCancelButton: null);
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text("showConfirmationDialog"), findsOneWidget);
      expect(find.text("Show Dialog"), findsOneWidget);
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.pumpWidget(testWidget);
      Utility.showConfirmationDialog( context: key.currentContext!, title: 'Check cancel button', msg: 'Show Dialog', onPressOkButton: null , onPressCancelButton: null);
      await tester.pump();
      expect(find.text("Check cancel button"), findsOneWidget);
      expect(find.text("Show Dialog"), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.pumpWidget(testWidget);
      Utility.showConfirmationDialog( context: key.currentContext!, title: 'Check ok button', msg: 'Show Dialog', onPressOkButton: (context) {
        Navigator.of(context).pop();
      } , onPressCancelButton: null);
      await tester.pump();
      expect(find.text('Check ok button'), findsOneWidget);
      expect(find.text("Show Dialog"), findsOneWidget);
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      Utility.showConfirmationDialog( context: key.currentContext!, title: 'Check cancel button with callback not null',msg: 'Show Dialog', onPressOkButton: null , onPressCancelButton: (context) {
        Navigator.of(context).pop();
      });
      await tester.pump();
      expect(find.text("Check cancel button with callback not null"), findsOneWidget);
      expect(find.text("Show Dialog"), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Find showQRAlertDialog widget', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showQRAlertDialog(key.currentContext!,'Show Dialog');
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.byKey(Key('dialog_close_btn')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Show and close Banner Notification', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showBannerNotification(key.currentContext!,key.currentContext!.toLocale!.connection_lost,
          key.currentContext!.toLocale!.reconnect_network_offline,
          Icons.warning,
          AColors.warningIconColor);
      await tester.pump();
      expect(find.byKey(Key("banner")), findsOneWidget);
      Utility.closeBanner();
      await tester.pumpAndSettle();
      expect(find.byKey(Key("banner")), findsNothing);
    });

    testWidgets('Show Network Lost Banner', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showNetworkLostBanner(key.currentContext!);
      await tester.pump();
      expect(find.byKey(Key("banner")), findsOneWidget);
      Utility.closeBanner();
      await tester.pumpAndSettle();
      expect(find.byKey(Key("banner")), findsNothing);
    });

    testWidgets('Show Sync Remainder Banner', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      Utility.showSyncRemainderBanner(key.currentContext!);
      await tester.pump();
      expect(find.byKey(Key("banner")), findsOneWidget);
      Utility.closeBanner();
      await tester.pumpAndSettle();
      expect(find.byKey(Key("banner")), findsNothing);
    });
  });

  test('error message for 221', () {
    String errMessage = Utility.getErrorMessage(221);
    expect(errMessage, "Account locked due to multiple invalid login attempts. Please contact the Asite Helpdesk");
  });

  test('error message for 224', () {
    String errMessage = Utility.getErrorMessage(224);
    expect(errMessage, "Your login account is not active. Please contact the administrator for more help");
  });


  test('error message for 403', () {
    String errMessage = Utility.getErrorMessage(403);
    expect(errMessage, "You have been logged Out!. Another login to Asite app on this or another device with the same login details terminated your Asite app session");
  });

  test('error message for 401', () {
    String errMessage = Utility.getErrorMessage(401);
    expect(errMessage,  "You have been logged Out!. Another login to Asite app on this or another device with the same login details terminated your Asite app session");
  });

  test('error message for 404', () {
    String errMessage = Utility.getErrorMessage(404,message: '');
    expect(errMessage, "Something went wrong please try again later");
  });

  test('error message for 502', () {
    String errMessage = Utility.getErrorMessage(502);
    expect(errMessage, "Server is not available. Please try after sometime.");
  });

  test('error message for default', () {
    String errMessage = Utility.getErrorMessage(null,message: '');
    expect(errMessage, "Something went wrong. Please try again later");
  });

  test('File size in string is not empty', () {
    String fileSize = Utility.getFileSizeString(bytes: 20.0);
    expect(fileSize.isNotEmpty, true);
  });

  test('File size with meta data is not empty', () {
    String fileSize = Utility.getFileSizeWithMetaData(bytes: 20);
    expect(fileSize.isNotEmpty, true);
  });

  test('PDFTron not supported for empty extension', () {
    bool isSupported = Utility.isPDFTronSupported('');
    expect(isSupported, false);
  });

  test('PDFTron supported for PDF extension', () {
    bool isSupported = Utility.isPDFTronSupported('PDF');
    expect(isSupported, true);
  });

  test('Current date for WeatherWidget not empty', () {
    initializeDateFormatting("en_GB", null).then((value) {
      Utility.getCurrentDateForWeatherWidget().then((currentDate) {
        expect(currentDate.isNotEmpty, true);
      });
    });
  });

  test('Find one week start and end date', () {
    final weekStartEndDate = Utility.getWeekStartEndDate(DateTime.now());
    expect(weekStartEndDate.isNotEmpty, true);
    expect(weekStartEndDate.keys.toList(), ["start_date","end_date"]);
  });

  test('DateTime from TimeStamp is not empty', () {
    final dateTime = Utility.getDateTimeFromTimeStamp(DateTime.now().millisecondsSinceEpoch.toString());
    expect(dateTime.isNotEmpty, true);
  });

  test('Find two week start and end date', () {
    final twoWeekStartEndDate = Utility.get2WeekStartEndDate(DateTime.now());
    expect(twoWeekStartEndDate.isNotEmpty, true);
  });

  test('Find month start and end date', () {
    final monthStartEndDate = Utility.getMonthStartEndDate(DateTime.now());
    expect(monthStartEndDate.isNotEmpty, true);
  });

  test('Check whether ImageFile, with png extension', () {
    final monthStartEndDate = Utility.isImageFile('assets/images/account_tree.png');
    expect(monthStartEndDate, true);
  });

  test('Check whether ImageFile, without extension', () {
    final isImageFile = Utility.isImageFile('assets/images/account_tree');
    expect(isImageFile, false);
  });

  test('Parsed Event Action Url match with the expected value', () async {
    const expectedParsedValue =
        r'{observationId: 107100, locationId: 0, folderId: 0$$NzGzeH, msgId: 12305709$$W9Pc7l, formId: 11604299$$WKpFR1, formTypeId: 11105298$$O92J6k, annotationId: 75bd0a2f-6dc8-4258-8df0-d490b1f63952-1689338513419, revisionId: 0$$bQsThT, coordinates: {"y1":311.0,"x1":938.0,"y2":280.0,"x2":969.0}, hasAttachment: false, statusVO: {statusId: 2, statusName: Open, statusTypeId: 0, statusCount: 0, bgColor: #848484, fontColor: #ffffff, generateURI: true}, recipientList: [{userID: 0$$c9QEQb, projectId: 0$$xhDxRB, dueDays: 0, distListId: 0, distributorId: 0, generateURI: true}], locationDetailVO: {siteId: 0, locationId: 63777, folderId: 113014508$$iXr8zN, docId: 11022621$$UPCZtN, revisionId: 7947153$$hsQRUg, annotationId: 153b2c8f-e028-a3f1-c356-5c20435b0c72, coordinates: {"x1":934.520215487983,"y1":432.62455487578995,"x2":1189.7297845120172,"y2":242.65544512421025}, isFileAssociated: false, hasChildLocation: false, parentLocationId: 0, locationPath: KrupalField19.8UK\20.8.4\First Floor\ABC, isPFSite: false, isCalibrated: true, isLocationActive: true, projectId: 0$$xhDxRB, generateURI: true}, isActive: true, isSyncIndexUpdate: false, commId: 11604299$$vrrjBo, formTitle: Bvvhjhf, formDueDays: 0, pageNumber: 1, templateType: 2, formTypeCode: HBHT, appBuilderID: HB-HTML, creatorUserName: Kirti P, creatorOrgName: Asite Solutions Ltd, formCode: HBHT369, formCreationDate: 14-Jul-2023#01:41 SST, appType: 2, creatorUserId: 758244, responseRequestBy: 14-Jul-2023#23:59 SST, isCloseOut: false, projectId: 2089700$$OHUTUl, generateURI: true}';
    final actualParsedValue = await Utility.parseEventActionUrl(
        r"js-frame:navigateToPlanView:%7B%22observationId%22:107100,%22locationId%22:0,%22folderId%22:%220$$NzGzeH%22,%22msgId%22:%2212305709$$W9Pc7l%22,%22formId%22:%2211604299$$WKpFR1%22,%22formTypeId%22:%2211105298$$O92J6k%22,%22annotationId%22:%2275bd0a2f-6dc8-4258-8df0-d490b1f63952-1689338513419%22,%22revisionId%22:%220$$bQsThT%22,%22coordinates%22:%22%7B/%22y1/%22:311.0,/%22x1/%22:938.0,/%22y2/%22:280.0,/%22x2/%22:969.0%7D%22,%22hasAttachment%22:false,%22statusVO%22:%7B%22statusId%22:2,%22statusName%22:%22Open%22,%22statusTypeId%22:0,%22statusCount%22:0,%22bgColor%22:%22#848484%22,%22fontColor%22:%22%23ffffff%22,%22generateURI%22:true%7D,%22recipientList%22:%5B%7B%22userID%22:%220$$c9QEQb%22,%22projectId%22:%220$$xhDxRB%22,%22dueDays%22:0,%22distListId%22:0,%22distributorId%22:0,%22generateURI%22:true%7D%5D,%22locationDetailVO%22:%7B%22siteId%22:0,%22locationId%22:63777,%22folderId%22:%22113014508$$iXr8zN%22,%22docId%22:%2211022621$$UPCZtN%22,%22revisionId%22:%227947153$$hsQRUg%22,%22annotationId%22:%22153b2c8f-e028-a3f1-c356-5c20435b0c72%22,%22coordinates%22:%22%7B%5C%22x1%5C%22:934.520215487983,%5C%22y1%5C%22:432.62455487578995,%5C%22x2%5C%22:1189.7297845120172,%5C%22y2%5C%22:242.65544512421025%7D%22,%22isFileAssociated%22:false,%22hasChildLocation%22:false,%22parentLocationId%22:0,%22locationPath%22:%22KrupalField19.8UK%5C%5C20.8.4%5C%5CFirst%20Floor%5C%5CABC%22,%22isPFSite%22:false,%22isCalibrated%22:true,%22isLocationActive%22:true,%22projectId%22:%220$$xhDxRB%22,%22generateURI%22:true%7D,%22isActive%22:true,%22isSyncIndexUpdate%22:false,%22commId%22:%2211604299$$vrrjBo%22,%22formTitle%22:%22Bvvhjhf%22,%22formDueDays%22:0,%22pageNumber%22:1,%22templateType%22:2,%22formTypeCode%22:%22HBHT%22,%22appBuilderID%22:%22HB-HTML%22,%22creatorUserName%22:%22Kirti%20P%22,%22creatorOrgName%22:%22Asite%20Solutions%20Ltd%22,%22formCode%22:%22HBHT369%22,%22formCreationDate%22:%2214-Jul-2023%2301:41%20SST%22,%22appType%22:2,%22creatorUserId%22:758244,%22responseRequestBy%22:%2214-Jul-2023%2323:59%20SST%22,%22isCloseOut%22:false,%22projectId%22:%222089700$$OHUTUl%22,%22generateURI%22:true%7D",
        'navigateToPlanView');
    expect(actualParsedValue.toString(), expectedParsedValue);
  });

  test('User date format never become empty or null', () async {
    final dateFormat = await Utility.getUserDateFormat();
    expect(dateFormat.isNullOrEmpty(), false);
  });

  test('User date format is dd-MMM-yyyy', () async {
    final dateFormat = await Utility.getUserDateFormat();
    expect(dateFormat, 'dd-MMM-yyyy');
  });

  test('Check File extension given a file path having extension', () {
    final fileExtension = Utility.getFileExtension('assets/images/account_tree.png');
    expect(fileExtension, 'png');
  });

  test('Check File extension given a file path not  having extension', () {
    final fileExtension = Utility.getFileExtension('assets/images/account_tree.');
    expect(fileExtension, '');
  });

  test('Find value from json', () {
    String jsonDataString = fixture("user_profile_setting.json").toString();
    final value = Utility.getValueFromJson(jsonDataString, 'jobTitle');
    expect(value, 'C++ Developer');
  });

  test('offline form creation date is not empty and returns a date only', () {
    final timeString = Utility.offlineFormCreationDate();
    expect(DateTime.tryParse(timeString) != null, true);
  });

  test('Find application label', () async {
    var platform = const MethodChannel('flutter.native/getapplabel');
    final String appLabel = await platform.invokeMethod('getapplabel');
    final actualAppLabel = await Utility.getApplicationLabel();
    expect(actualAppLabel, appLabel);
  });

  test('Find previous days timeStamp', () {
    final previousDaysStamp = Utility.getPreviousDaysTimeStamp(days: 20);
    final days = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(previousDaysStamp)).inDays;
    expect(days, 20);
  });

  test('Time stamp from Date is valid ', () async {
    final timeStamp = Utility.getTimeStampFromDate('22-Dec-2021 00:00:00', "dd-MMM-yyyy");
    expect(timeStamp, 1640111400000);
  });

  test('Find total size of meta data', () async {
    final totalSizeOfMetaData = Utility.getTotalSizeOfMetaData(10);
    expect(totalSizeOfMetaData, 5000);
  });

  testWidgets('Is scale between range 1 and 1.3', (WidgetTester tester) async {
    Widget buildTestableWidget(Widget widget) {
      return MediaQuery(data: MediaQueryData(), child: MaterialApp(home: widget));
    }
    var key = GlobalKey();
    await tester.pumpWidget(buildTestableWidget(Container(key: key,)));
    double scale = Utility.getFontScale(key.currentContext);
    expect(true,1 <= scale && scale <= 1.3);
  });


    test('getTextSpans returns the correct list of TextSpans', () {
      String input1 = "This is a sample text";
      String input2 = "sample";

      List<TextSpan> expectedOutput = [
        TextSpan(
          text: "This is a ",
          style: TextStyle(
            fontSize: 15,
            overflow: TextOverflow.ellipsis,
            color: AColors.textColor,
          ),
        ),
        TextSpan(
          text: "sample",
          style: TextStyle(
            fontWeight: AFontWight.bold,
            fontSize: 15,
            color: AColors.textColor,
          ),
        ),
        TextSpan(
          text: " text",
          style: TextStyle(
            fontSize: 15,
            overflow: TextOverflow.ellipsis,
            color: AColors.textColor,
          ),
        ),
      ];

      expect(Utility.getTextSpans(input1, input2), equals(expectedOutput));
    });

    test('getTextSpans handles case-insensitive search', () {
      String input1 = "This is a sample text";
      String input2 = "SAMPLE";

      List<TextSpan> expectedOutput = [
        TextSpan(
          text: "This is a ",
          style: TextStyle(
            fontSize: 15,
            overflow: TextOverflow.ellipsis,
            color: AColors.textColor,
          ),
        ),
        TextSpan(
          text: "sample",
          style: TextStyle(
            fontWeight: AFontWight.bold,
            fontSize: 15,
            color: AColors.textColor,
          ),
        ),
        TextSpan(
          text: " text",
          style: TextStyle(
          fontSize: 15,
          overflow: TextOverflow.ellipsis,
          color: AColors.textColor,
        ),
      ),
    ];

    expect(Utility.getTextSpans(input1, input2), equals(expectedOutput));
  });

  testWidgets('showAlertDialog test', (WidgetTester tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: Builder(builder: (context) {
        return MediaQuery(
            data: MediaQueryData(),
            child: MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Scaffold(
                body: Builder(
                  builder: (BuildContext context) {
                    return ElevatedButton(
                      onPressed: () {
                        Utility.showAlertDialog(context, "Test Title", "Test Message");
                      },
                      child: Text("Show AlertDialog"),
                    );
                  },
                ),
              ),
            ));
      }),
    ));
    await tester.tap(find.text("Show AlertDialog"));
    await tester.pumpAndSettle();
    expect(find.text("Test Title"), findsOneWidget);
    expect(find.text("Test Message"), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

}
