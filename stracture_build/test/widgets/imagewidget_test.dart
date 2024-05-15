import 'package:field/widgets/imagewidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Test AImageWidget', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is set up

    const imagePath = 'angle.png';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AImageWidget(imagePath: imagePath),
        ),
      ),
    );

    // Wait for the image to load
    await tester.pumpAndSettle();

    // Verify that the image is displayed
    expect(find.byType(Image), findsOneWidget);

    // You can further test by checking the properties of the displayed image
    final imageFinder = find.byType(Image);
    final Image imageWidget = tester.widget(imageFinder);

    expect(imageWidget.image, isA<AssetImage>());
    expect((imageWidget.image as AssetImage).assetName, 'assets/images/$imagePath');
  });
}

