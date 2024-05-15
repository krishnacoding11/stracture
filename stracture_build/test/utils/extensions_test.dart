import 'package:dio/dio.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  String snackbarTitle = "Showing snackbar for testing";
  String buttonToShowSnackbar = "Show Snackbar";

  test('PlainValue', () {
    String projectId = "110431628\$\$HTWZnL";
    expect(projectId.plainValue(), "110431628");
  });

  test('PlainValue', () {
    String projectId = "110431628";
    expect(projectId.plainValue(), "110431628");
  });

  test('check plainValue', () {
    String? projectId;
    expect(projectId.plainValue(), '');
  });

  test('check string value is Null Or Empty', () {
    String projectId = "";
    String? folderId;
    String? locationId ="null";
    expect(projectId.isNullOrEmpty(), true);
    expect(folderId.isNullOrEmpty(), true);
    expect(locationId.isNullOrEmpty(), true);
  });

  test('isNullEmptyZeroOrFalse', () {
    String revisionId = "0";
    expect(revisionId.isNullEmptyZeroOrFalse(), true);
  });

  test('isNullEmptyOrFalse', () {
    String? isNull;
    final isEmpty = '';
    final isFalse = 'false';
    final text = "Hello";
    expect(isNull.isNullEmptyZeroOrFalse(), true);
    expect(isEmpty.isNullEmptyZeroOrFalse(), true);
    expect(isFalse.isNullEmptyZeroOrFalse(), true);
    expect(text.isNullEmptyZeroOrFalse(), false);
  });

  test('check revisionId value is not zero', () {
    String revisionId = "111134\$\$HTWZnL";
    expect(revisionId.isNullOrEmpty(), false);
  });

  test('check overflow function, replace space with Zero Width Space char', () {
    String? testValue = "A B C D E F".overflow;
    expect(testValue!.characters.contains('\u{200B}'), true);
  });

  test('check file name validation', () {
    // file name length not getter 200 character
    String? fileNameLength = "today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy (4)today - Copy.jpg";
    bool charLength = fileNameLength.length > 200;
    expect(charLength, true);

    RegExp fileNameRegExp = new RegExp(r'^[^\\/\\\\:*?<>|;%#~\\\"]+$');
    // special character
    String? invalidFileName = "D@#@##?abc%^%^&{}&&&^&%%#@%^&&.jpg";
    expect(invalidFileName.contains(fileNameRegExp), false);

    String validFileName = "test.jpg";
    expect(validFileName.contains(fileNameRegExp), true);

    //uniCodePattern
    RegExp uniCodeRegExp = new RegExp(r'[\u200B-\u200F\u2028-\u2029\u202A-\u202E\u2060-\u2069\u206A-\u206F\uFEFF]');
    String? fileNameUniCodePattern = "\u{200B}Test.jpg";
    expect(fileNameUniCodePattern.contains(uniCodeRegExp), true);
    expect(validFileName.contains(uniCodeRegExp), false);
  });


  test('whitespace removal',(){
    final text = "H e l l o";
    expect(text.removeWhitespace(),"Hello");
  });

  test('check if value is hash value',(){
    final text1 = "Hello";
    final text2 = "hello\$\$hash";
    expect(text1.isHashValue(), false);
    expect(text2.isHashValue(), true);
  });

  test('get File extension',(){
    final text = "image.png";
    expect(text.getFileExtension(),".png");
  });

  test('get filename and extension separate',(){
    final text = "myFile.docx";
    expect(text.getExtension(),".docx");
    expect(text.getFileNameWithoutExtension(),"myFile");
  });

  test('get Work package',(){
    String? noText;
    final emptyText = '';
    final text = "mySite#Ground";
    expect(text.toWorkPackage(),"Ground");
    expect(emptyText.toWorkPackage(),"");
    expect(noText.toWorkPackage(),"");
  });

  test('to date format',(){
    final date = "2023-12-31";
    expect(date.toDateFormat(),"31-Dec-2023");
  });

  test('Check valid file name',(){
    final name1 = "FloorPlan.pdf";
    final name2 = "FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..FloorPlan.pdf..";
    expect(name1.isValidFileName(),{"valid": true, "validMsg": NavigationUtils.mainNavigationKey.currentContext?.toLocale?.special_character_validation_update_proceed ?? ""});
    expect(name2.isValidFileName(),{"valid": false, "validMsg": NavigationUtils.mainNavigationKey.currentContext?.toLocale?.filename_allow_max_200_characters_update_proceed ?? ""});
  });

  test('toColor should return a Color from a hex string', () {
    final hexColor = '#FFEA60'; // Magenta color
    final color = hexColor.toColor();
    expect(color, isNotNull);
    expect(color, equals(Color(0xFFFFEA60)));
  });

  testWidgets('shows and closes current SnackBar', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  context.showSnack(snackbarTitle);
                },
                child: Text(buttonToShowSnackbar),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text(buttonToShowSnackbar));
    await tester.pumpAndSettle();

    expect(find.text(snackbarTitle), findsOneWidget);

    scaffoldKey.currentContext!.closeCurrentSnackBar();
    await tester.pumpAndSettle();

    expect(find.text(snackbarTitle), findsNothing);
  });

  testWidgets('showSnackWithTimeLimit displays a SnackBar with a time limit', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  context.showSnackWithTimeLimit(snackbarTitle, false);
                },
                child: Text(buttonToShowSnackbar),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text(buttonToShowSnackbar));
    await tester.pumpAndSettle();

    expect(find.text(snackbarTitle), findsOneWidget);
    await tester.pumpAndSettle(Duration(milliseconds: 500));

    expect(find.text(snackbarTitle), findsNothing);
  });

  testWidgets('showBanner displays a banner', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  context.showBanner(snackbarTitle, "Banner visible", Icons.add_alert_outlined, Colors.red);
                },
                child: Text(buttonToShowSnackbar),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text(buttonToShowSnackbar));
    await tester.pumpAndSettle();
    expect(find.text(snackbarTitle), findsOneWidget);
    expect(find.text("Banner visible"), findsOneWidget);
  });

  testWidgets('nCircleShowBanner displays a banner', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  context.nCircleShowBanner(snackbarTitle, "Banner visible", Icons.add_alert_outlined, Colors.red);
                },
                child: Text(buttonToShowSnackbar),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text(buttonToShowSnackbar));
    await tester.pumpAndSettle();
    expect(find.text(snackbarTitle), findsOneWidget);
    expect(find.text("Banner visible"), findsOneWidget);
    await tester.pumpAndSettle(Duration(seconds: 3));
  });

  testWidgets('showSnackBarAsBanner displays a SnackBar as a banner', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  context.showSnackBarAsBanner(snackbarTitle, 'Banner visible', Icons.info, Colors.red);
                },
                child: Text(buttonToShowSnackbar),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text(buttonToShowSnackbar));
    await tester.pumpAndSettle();

    expect(find.text(snackbarTitle), findsOneWidget);
    expect(find.text('Banner visible'), findsOneWidget);
  });

  testWidgets('shownCircleSnackBarAsBanner displays a snackbar as banner', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: NavigationUtils.mainNavigationKey,
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  context.shownCircleSnackBarAsBanner(snackbarTitle, 'Banner visible', Icons.back_hand_outlined, Colors.blue);
                },
                child: Text(buttonToShowSnackbar),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text(buttonToShowSnackbar));
    await tester.pumpAndSettle();
    expect(find.text(snackbarTitle), findsOneWidget);
    expect(find.text('Banner visible'), findsOneWidget);
    await tester.pumpAndSettle(Duration(seconds: 3));
  });

  testWidgets('showSnackBarAsBannerDismissible displays a dismissible SnackBar as a banner', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  context.showSnackBarAsBannerDismissible(snackbarTitle, 'Banner visible', Icons.info, Colors.blue, isCloseManually: false);
                },
                child: Text(buttonToShowSnackbar),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text(buttonToShowSnackbar));
    await tester.pumpAndSettle();

    expect(find.text(snackbarTitle), findsOneWidget);
    expect(find.text('Banner visible'), findsOneWidget);
  });

  testWidgets('closeKeyboard unfocuses the keyboard', (WidgetTester tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final textField = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(builder: (context) {
            return Column(
              children: [
                TextField(controller: textField),
                ElevatedButton(
                  onPressed: () {
                    textField.text = "Hello";
                    context.closeKeyboard();
                  },
                  child: Text('Close Keyboard'),
                ),
              ],
            );
          }),
        ),
      ),
    );

    await tester.showKeyboard(find.byType(TextField));
    await tester.tap(find.text('Close Keyboard'));
    await tester.pumpAndSettle();
    expect(find.text("Hello"), findsOneWidget);
    expect(MediaQuery.of(scaffoldKey.currentContext!).viewInsets.bottom, 0);
  });

  testWidgets('globalPaintBounds returns correct bounds', (WidgetTester tester) async {
    final key = GlobalKey<ScaffoldState>();
    final containerKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: key,
          body: Center(
            child: Container(
              key: containerKey,
              width: 100,
              height: 50,
            ),
          ),
        ),
      ),
    );

    final container = containerKey.globalPaintBounds;
    final globalBounds = key.globalPaintBounds;

    expect(globalBounds, isNotNull);
    expect(globalBounds!.top, equals(0));
    expect(globalBounds.left, equals(0));
    expect(container!.width, equals(100));
    expect(container.height, equals(50));
  });

  testWidgets('globalPaintBounds returns null if no render object', (WidgetTester tester) async {
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('No RenderObject'),
          ),
        ),
      ),
    );

    final globalBounds = key.globalPaintBounds;

    expect(globalBounds, isNull);
  });

  test('groupBy groups elements correctly', () {
    final List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    final grouped = numbers.groupBy((n) => n % 2 == 0 ? 'even' : 'odd');

    expect(grouped['even'], equals([2, 4, 6, 8, 10]));
    expect(grouped['odd'], equals([1, 3, 5, 7, 9]));
  });

  test('groupBy handles empty input', () {
    final List<int> numbers = [];
    final grouped = numbers.groupBy((n) => n % 2 == 0 ? 'even' : 'odd');

    expect(grouped.isEmpty, isTrue);
  });

  test('isXSN returns true for xsn', () {
    final int? type = 1;
    final isXSN = type.isXSN;
    expect(isXSN, isTrue);
  });

  test('isHTML returns true for html', () {
    final int? type = 2;
    final isHTML = type.isHTML;
    expect(isHTML, isTrue);
  });

  test('isXSN returns false for other types', () {
    final int? type = 0;
    final isXSN = type.isXSN;
    expect(isXSN, isFalse);
  });

  test('isOne returns true for 1', () {
    final int? value = 1;
    final isOne = value.isOne;
    expect(isOne, isTrue);
  });

  test('isOne returns false for other values', () {
    final int? value = 2;
    final isOne = value.isOne;
    expect(isOne, isFalse);
  });

  test('toHoursMinutes converts duration to HH:mm format', () {
    final duration = Duration(hours: 7, minutes: 30);
    final formatted = duration.toHoursMinutes();
    expect(formatted, equals('07:30'));
  });

  test('toHoursMinutesSeconds converts duration to HH:mm:ss format', () {
    final duration = Duration(hours: 5, minutes: 45, seconds: 35);
    final formatted = duration.toHoursMinutesSeconds();
    expect(formatted, equals('05:45:35'));
  });

  test('getJSessionId returns JSESSIONID from headers', () {
    final headers = Headers.fromMap({
      'Set-Cookie': ['SESSIONID=12345; Path=/; HttpOnly', 'JSESSIONID=67890; Path=/; HttpOnly'],
      'Other-Header': ['SomeValue'],
    });

    final jSessionId = headers.getJSessionId();
    expect(jSessionId, equals('67890'));
  });

  test('getJSessionId returns empty string if JSESSIONID is not found', () {
    final headers = Headers.fromMap({
      'Set-Cookie': ['SESSIONID=12345; Path=/; HttpOnly'],
      'Other-Header': ['SomeValue'],
    });
    final jSessionId = headers.getJSessionId();
    expect(jSessionId, isEmpty);
  });

  test('getJSessionId returns empty string if headers are empty', () {
    final Headers? headers = Headers.fromMap({});
    final jSessionId = headers.getJSessionId();
    expect(jSessionId, '');
  });

  test('getJSessionId returns null if headers are null', () {
    final Headers? headers = null;
    final jSessionId = headers?.getJSessionId();
    expect(jSessionId, null);
  });

  testWidgets('getLocale returns AppLocalizations instance', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (BuildContext context) {
            final appLocalizations = context.toLocale;
            expect(appLocalizations, isA<AppLocalizations>());
            return const SizedBox();
          },
        ),
      ),
    );
  });

}
