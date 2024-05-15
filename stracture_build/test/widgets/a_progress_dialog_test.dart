import 'package:field/presentation/screen/bottom_navigation/bottom_navigation_page.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:field/injection_container.dart' as di;

//class MockBuildContext extends Mock implements BuildContext{}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  const buttonOneKey = Key("buttonOne");
  //BuildContext? mockContext;
  late Widget testWidget;
  late var aProgressDialog;
  setUpAll(() {
    //navigatorKey = GlobalKey<ScaffoldState>();
    //var mockContext = navigatorKey.currentContext;
    testWidget = MaterialApp(home: Scaffold(body: Builder(builder: (context) {
      aProgressDialog = AProgressDialog(context,
          isAnimationRequired: true,
          backgroundColor: Colors.grey,
          blur: 0.6,
          animationDuration: Duration(milliseconds: 500),
          dismissable: false,
          isWillPopScope: false,
          loadingWidget: ACircularProgress(
            strokeWidth: 3,
            color: Colors.blue,
            progressValue: 0.5,
            backgroundColor: Colors.grey,
          ),
          onDismiss: () {},
          useSafeArea: true);
      return TextButton(
        key: buttonOneKey,
        child: const Text("Show dialog"),
        onPressed: () {
          aProgressDialog.show();
        },
      );
    })));
  });
  testWidgets('Test AProgressDialog', (WidgetTester tester) async {
    configureLoginCubitDependencies();
    await tester.pumpWidget(testWidget);

    final buttonOne = find.byKey(buttonOneKey);
    expect(buttonOne, findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(buttonOne);
      //         Or alternatively press then "up":
      //         final response = await tester.press(button);
     //         await response.up();
    });
    await tester.pump(Duration(milliseconds: 200));
  });
}
