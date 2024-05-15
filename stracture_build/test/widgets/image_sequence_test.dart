
import 'package:field/bloc/image_sequence/image_sequence_cubit.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/presentation/screen/downloading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  int currentIndex = 0;
  List<String> imagePaths = [
    'assets/images/cloud_download_outlined.png',
    'assets/images/cloud_downloading_progress_a.png',
    'assets/images/cloud_downloading_progress_b.png',
    'assets/images/cloud_downloading_progress_c.png',
    'assets/images/cloud_downloading_progress_d.png',
  ];


  for (int i = 0; i < imagePaths.length; i++) {
    currentIndex = i;
    group("image animation widget", () {

    Widget makeTestableWidget() {
      return BlocProvider<ImageSequenceCubit>(
          create: (BuildContext context) => ImageSequenceCubit(),
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(body: ImageSequenceAnimation(imagePath: imagePaths[i], currentIndex: currentIndex)),
          ));
    }

    testWidgets('image sequence testing', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.widget<ImageSequenceAnimation>(find.byType(ImageSequenceAnimation)).imagePath, imagePaths[i]);
    });

  });}}