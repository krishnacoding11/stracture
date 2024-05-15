import 'package:field/bloc/image_annotation/annotation_selection_cubit.dart';
import 'package:field/bloc/image_annotation/image_annotation_cubit.dart';
import 'package:field/image_annotation/image_annotation.dart';
import 'package:field/image_annotation/paint.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../bloc/mock_method_channel.dart';
import '../fixtures/fixture_reader.dart';
import '../presentation/screens/site_routes/create_form_dialog/create_form_dialog_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  group("Annotation options", () {
    configureLoginCubitDependencies();
    var dummyPath = fixtureFile("temp_img_annotation.png");
    List<dynamic> imgPath = [
      PlatformFile(
          path: dummyPath,
          name: "temp_img_annotation.png",
          bytes: null,
          readStream: null,
          size: 408906),
    ];
    var imageAnnotationCubit = getIt<ImageAnnotationCubit>();
    var annotationSelectionCubit = getIt<AnnotationSelectionCubit>();

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => imageAnnotationCubit),
              BlocProvider(create: (_) => annotationSelectionCubit),
            ],
            child: ImageAnnotationWidget(
              arguments: {"capturedFile": imgPath, "imagesFrom": AConstants.gallery},
            ),
          ),
        ));

    testWidgets("Find annotation widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder findCancelButton = find.bySemanticsLabel(RegExp('Cancel'));
      Finder findAttachButton = find.bySemanticsLabel(RegExp('Attach'));
      Finder findPageView = find.byType(PageView);
      Finder findPainterView = find.byType(FlutterPainterEx);
      Finder findAddAttachmentButton = find.byKey(const Key("AddAttachment"));

      expect(findCancelButton, findsOneWidget);
      expect(findAttachButton, findsOneWidget);
      expect(findPageView, findsOneWidget);
      expect(findPainterView, findsOneWidget);
      expect(findAddAttachmentButton, findsOneWidget);
    });
  });
}
