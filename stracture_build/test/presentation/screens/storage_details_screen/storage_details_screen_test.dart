import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/bottom_navigation/models/model_storage_details.dart';
import 'package:field/presentation/screen/bottom_navigation/models/models_list_screen.dart';
import 'package:field/presentation/screen/bottom_navigation/models/storageDetails/model_storage_widget.dart';
import 'package:field/presentation/screen/bottom_navigation/models/storageDetails/model_storage_widget_landscape.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockStorageDetailsCubit extends MockCubit<StorageDetailsState> implements StorageDetailsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  List<Popupdata> allItems = [];
  final TabController tabController = TabController(vsync: const TestVSync(), length: 2);
  MockStorageDetailsCubit mockStorageDetailsCubit = MockStorageDetailsCubit();
  AnimationController _controller = AnimationController(
    vsync: TestVSync(),
    duration: const Duration(milliseconds: 200),
  );
  Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );
  configureLoginCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<StorageDetailsCubit>();
    di.getIt.registerFactory<StorageDetailsCubit>(() => mockStorageDetailsCubit);
  }

  setUp(() async {
    when(() => mockStorageDetailsCubit.getCurrentDate()).thenReturn("23-12-1995");
    when(() => mockStorageDetailsCubit.state).thenReturn(ShowHideDetailsState(false));
    when(() => mockStorageDetailsCubit.modelsFileSize).thenReturn("0");
    when(() => mockStorageDetailsCubit.calibFileSize).thenReturn("0");
    when(() => mockStorageDetailsCubit.isDataLoading).thenReturn(true);
    when(() => mockStorageDetailsCubit.maxDataValue).thenReturn(0.0);
    when(() => mockStorageDetailsCubit.data).thenReturn([]);
    when(()=> mockStorageDetailsCubit.initStorageSpace()).thenAnswer((invocation) => Future.value());
    final popUpData = json.decode(fixture('model_list.json'));
  });

  group("Storage Widget", () {
    configureLoginCubitDependencies();
    final ScrollController scrollController = ScrollController();
    final FocusNode focusNode = FocusNode();
    final TextEditingController controller = TextEditingController(text: "test");

    Widget portraitStorageWidget = MultiBlocProvider(
      providers: [
        BlocProvider<StorageDetailsCubit>(
          create: (BuildContext context) => mockStorageDetailsCubit,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: Scaffold(body: ModelStorageWidget(selectedProject: Project(),)),
      ),
    );

    testWidgets("Find User First Login widget", (tester) async {
      when(() => mockStorageDetailsCubit.showDetails).thenReturn(false);
      await tester.pumpWidget(portraitStorageWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(Key('key_container_model_storage_portrait')), findsOneWidget);
      expect(find.byKey(Key('key_column')), findsOneWidget);
      expect(find.byKey(Key('key_padding')), findsOneWidget);
      expect(find.byKey(Key('key_download_size_text_widget')), findsOneWidget);
    });

    Widget landscapeStorageWidget = MultiBlocProvider(
      providers: [
        BlocProvider<StorageDetailsCubit>(
          create: (BuildContext context) => mockStorageDetailsCubit,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: Scaffold(body: ModelStorageLandscapeWidget(selectedProject: Project(),)),
      ),
    );

    testWidgets("Find User First Login widget", (tester) async {
      when(() => mockStorageDetailsCubit.showDetails).thenReturn(false);
      await tester.pumpWidget(landscapeStorageWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(Key('key_container_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_column_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_last_downloaded_text_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_storage_space_text_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_build_stack_bar_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_container')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_calibrate')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_model')), findsOneWidget);
      expect(find.byKey(Key('key_center_clear_project_button')), findsOneWidget);
      expect(find.byKey(Key('key_outlined_landscape_button')), findsOneWidget);
    });

    testWidgets("Storage widget", (tester) async {
      when(() => mockStorageDetailsCubit.showDetails).thenReturn(false);
      when(() => mockStorageDetailsCubit.totalSpace).thenReturn(5000);
      when(() => mockStorageDetailsCubit.maxDataValue).thenReturn(1.0);
      when(() => mockStorageDetailsCubit.data).thenReturn([
        StorageData(name: 'Models', value: 150, color: AColors.modelColorForStorage),
        StorageData(name: 'Files', value: 100, color: AColors.blueColor),
        StorageData(name: 'Free Space', value: 3000, color: AColors.lightBlueColor),
      ]);
      await tester.pumpWidget(landscapeStorageWidget);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(Key('key_container_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_container_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_column_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_last_downloaded_text_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_storage_space_text_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_build_stack_bar_landscape_storage')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_container')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_calibrate')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_model')), findsOneWidget);
      expect(find.byKey(Key('key_center_clear_project_button')), findsOneWidget);
      expect(find.byKey(Key('key_outlined_landscape_button')), findsOneWidget);
    });


    testWidgets("key_refresh_button widget", (tester) async {
      when(() => mockStorageDetailsCubit.showDetails).thenReturn(false);
      when(() => mockStorageDetailsCubit.totalSpace).thenReturn(5000);
      when(() => mockStorageDetailsCubit.maxDataValue).thenReturn(1.0);
      when(() => mockStorageDetailsCubit.data).thenReturn([
        StorageData(name: 'Models', value: 150, color: AColors.modelColorForStorage),
        StorageData(name: 'Files', value: 100, color: AColors.blueColor),
        StorageData(name: 'Free Space', value: 3000, color: AColors.lightBlueColor),
      ]);
      await tester.pumpWidget(landscapeStorageWidget);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(Key('key_refresh_button')), findsOneWidget);
      await tester.tap(find.byKey(Key('key_refresh_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('key_outlined_landscape_button')), findsOneWidget);
      await tester.tap(find.byKey(Key('key_outlined_landscape_button')));
      await tester.pumpAndSettle();

    });

    testWidgets("key_refresh_button portraitStorageWidget", (tester) async {
      when(() => mockStorageDetailsCubit.showDetails).thenReturn(false);
      when(() => mockStorageDetailsCubit.totalSpace).thenReturn(5000);
      when(() => mockStorageDetailsCubit.maxDataValue).thenReturn(1.0);
      when(() => mockStorageDetailsCubit.data).thenReturn([
        StorageData(name: 'Models', value: 150, color: AColors.modelColorForStorage),
        StorageData(name: 'Files', value: 100, color: AColors.blueColor),
        StorageData(name: 'Free Space', value: 3000, color: AColors.lightBlueColor),
      ]);
      await tester.pumpWidget(portraitStorageWidget);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(Key('key_refresh_button')), findsOneWidget);
      await tester.tap(find.byKey(Key('key_refresh_button')));
      await tester.pumpAndSettle();
    });

    testWidgets("key_details_toggle_button portraitStorageWidget", (tester) async {
      when(() => mockStorageDetailsCubit.showDetails).thenReturn(false);
      when(() => mockStorageDetailsCubit.totalSpace).thenReturn(5000);
      when(() => mockStorageDetailsCubit.maxDataValue).thenReturn(1.0);
      when(() => mockStorageDetailsCubit.data).thenReturn([
        StorageData(name: 'Models', value: 150, color: AColors.modelColorForStorage),
        StorageData(name: 'Files', value: 100, color: AColors.blueColor),
        StorageData(name: 'Free Space', value: 3000, color: AColors.lightBlueColor),
      ]);
      await tester.pumpWidget(portraitStorageWidget);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(Key('key_details_toggle_button')), findsOneWidget);
      await tester.tap(find.byKey(Key('key_details_toggle_button')));
      await tester.pumpAndSettle();
    });



    testWidgets('RefreshButton renders correctly with default size', (WidgetTester tester) async {
      // Define a mock onTap callback.
      VoidCallback mockOnTap = () {};

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<StorageDetailsCubit>(
              create: (BuildContext context) => mockStorageDetailsCubit,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(body:  RefreshButton(
              onTap: mockOnTap,
              size: 30.0,
            )),
          ),
        ),
      );

      // Verify the presence of InkWell, Icon, and Text widgets.
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);


      final iconFinder = find.byIcon(Icons.refresh);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.size, 34.0);

      final textFinder = find.text('Refresh');
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, 30.0);
    });

    testWidgets('RefreshButton renders correctly with custom size', (WidgetTester tester) async {

      VoidCallback mockOnTap = () {};
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<StorageDetailsCubit>(
              create: (BuildContext context) => mockStorageDetailsCubit,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(body:  RefreshButton(
              onTap: mockOnTap,
              size: 30.0,
            )),
          ),
        ),
      );
      final iconFinder = find.byIcon(Icons.refresh);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.size, 34.0); // Custom size + 4
    });

  });
}
