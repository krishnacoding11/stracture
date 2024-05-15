import 'package:field/widgets/textformfieldwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test ATextFormFieldWidget', (WidgetTester tester) async {
    TextEditingController controller = TextEditingController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ATextFormFieldWidget(
          key: const Key('TextField'),
          controller: controller,
          hintText: 'Enter your text',
          isPassword: true,
          obscureText: true,
        ),
      ),
    ));

    await tester.enterText(find.byType(TextFormField), 'Password123');

    expect(controller.text, 'Password123');

    /*await tester.pumpAndSettle();

    if (controller.text.isNotEmpty) {
      await tester.tap(find.byIcon(Icons.visibility_off, skipOffstage: false));
      await tester.pump();

      expect(tester.widget<ATextFormFieldWidget>(find.byType(ATextFormFieldWidget)).obscureText, false);
    }

    await tester.tap(find.byIcon(Icons.clear, skipOffstage: false));
    await tester.pump();

    expect(controller.text, '');*/
  });
}
