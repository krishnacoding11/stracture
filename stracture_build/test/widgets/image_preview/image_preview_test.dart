import 'dart:convert';

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:field/widgets/image_preview/image_preview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Test ImagePreview Widget", () {
    testWidgets('Test ImagePreviewWidget for Utility.isTablet = true', (WidgetTester tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final imagePath = '/path/to/mock/image.png';
      final xFile = MockXFile(imagePath);
      Utility.isTablet = true;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: ImagePreviewWidget(arguments: {"capturedFile": xFile}),
            ),
          ),
        ),
      );
      expect(find.byType(ImagePreviewWidget), findsOneWidget);
    });

    testWidgets('Test ImagePreviewWidget for Utility.isTablet = false', (WidgetTester tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final imagePath = '/path/to/mock/image.png';
      final xFile = MockXFile(imagePath);
      Utility.isTablet = false;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: ImagePreviewWidget(arguments: {"capturedFile": xFile}),
            ),
          ),
        ),
      );
      expect(find.byType(ImagePreviewWidget), findsOneWidget);
    });
  });
}

class MockXFile implements XFile {
  final String path;

  MockXFile(this.path);

  @override
  String get name => path;

  @override
  int get lengthSync => throw UnimplementedError();

  @override
  void writeAsBytesSync(List<int> bytes) {}

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> lastModified() {
    // TODO: implement lastModified
    throw UnimplementedError();
  }

  @override
  Future<int> length() {
    // TODO: implement length
    throw UnimplementedError();
  }

  @override
  // TODO: implement mimeType
  String? get mimeType => throw UnimplementedError();

  @override
  Future<Uint8List> readAsBytes() {
    // TODO: implement readAsBytes
    throw UnimplementedError();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    // TODO: implement readAsString
    throw UnimplementedError();
  }

  @override
  Future<void> saveTo(String path) {
    // TODO: implement saveTo
    throw UnimplementedError();
  }
}