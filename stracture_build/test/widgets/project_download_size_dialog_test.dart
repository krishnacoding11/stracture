import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/download_size/download_size_cubit.dart';
import 'package:field/bloc/download_size/download_size_state.dart';
import 'package:field/bloc/sync/sync_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/project_download_size_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage_space/storage_space.dart';

import '../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockDownloadSizeCubit mockDownloadSizeCubit = MockDownloadSizeCubit();
  late Widget makeTestableWidget;
  late Widget projectAlreadyMarkWidget;
  MockMethodChannel().setGetFreeSpaceMethodChannel();
  late StorageSpace storageSpace;

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<DownloadSizeCubit>();
    di.getIt.registerFactory<DownloadSizeCubit>(() => mockDownloadSizeCubit);
  }

  setUp(() async {
    makeTestableWidget = BlocProvider<DownloadSizeCubit>(
        create: (context) => mockDownloadSizeCubit,
        child: MediaQuery(
            data: const MediaQueryData(),
            child: MaterialApp(
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: Scaffold(
                  body: ProjectDownloadSizeWidget(strProjectId: '', locationId: []),
                ))));
    when(() => mockDownloadSizeCubit.getProjectOfflineSyncDataSize(any(), any())).thenAnswer((_) => Future.value(12345));
    storageSpace = await getStorageSpace(
      lowOnSpaceThreshold: 123454566788567, // 2GB
      fractionDigits: 1,
    );
  });

  group("Project download dialog widget", () {
    configureCubitDependencies();

    testWidgets('Download size [Loading]', (tester) async {
      when(() => mockDownloadSizeCubit.state).thenReturn(SyncStartState());

      await tester.pumpWidget(makeTestableWidget);
      var loadingWidget = find.byKey(const Key("download_size_loading_state"));
      expect(loadingWidget, findsOneWidget);

      var cancelButton = find.byKey(Key("key_loading_cancel"));
      await tester.tap(cancelButton, warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('Download size [Success]', (tester) async {
      when(() => mockDownloadSizeCubit.state).thenReturn(SyncDownloadSizeState(12345));
      await tester.pumpWidget(makeTestableWidget);
      var widget = find.byKey(const Key("download_size_success_state"));
      expect(widget, findsOneWidget);

      var cancelButton = find.byKey(Key("key_cancel_button"));

      await tester.tap(cancelButton, warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('Download size [Success] button click', (tester) async {
      when(() => mockDownloadSizeCubit.state).thenReturn(SyncDownloadSizeState(12345));
      await tester.pumpWidget(makeTestableWidget);
      var widget = find.byKey(const Key("download_size_success_state"));
      expect(widget, findsOneWidget);

      var selectButton = find.byKey(Key("key_select_button"));
      await tester.tap(selectButton, warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('Download size [Limit]', (tester) async {
      when(() => mockDownloadSizeCubit.state).thenReturn(SyncDownloadLimitState(storageSpace, 12345456678));
      await tester.pumpWidget(makeTestableWidget);
      var loadingWidget = find.byKey(const Key("download_size_limit_state"));
      expect(loadingWidget, findsOneWidget);

      var okButton = find.byKey(Key("key_ok_button_limit"));
      await tester.tap(okButton, warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('Download size [Error]', (tester) async {
      when(() => mockDownloadSizeCubit.state).thenReturn(SyncDownloadErrorState("", ""));
      await tester.pumpWidget(makeTestableWidget);
      var widgetError = find.byKey(const Key("download_size_error_state"));
      expect(widgetError, findsOneWidget);

      var okButton = find.byKey(Key("key_ok_button_error"));
      await tester.tap(okButton, warnIfMissed: false);
      await tester.pump();

      when(() => mockDownloadSizeCubit.state).thenReturn(SyncDownloadErrorState("message", "1234599679876"));
      await tester.pumpWidget(makeTestableWidget);
      var errorWidget = find.byKey(const Key("download_size_error_state"));
      expect(errorWidget, findsOneWidget);
    });
  });

  setUp(() {
    projectAlreadyMarkWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: ProjectAlreadyMarkOffline(),
            )));
  });

  group("Project already downloaded widget", () {
    testWidgets("Widget test", (tester) async {
      await tester.pumpWidget(projectAlreadyMarkWidget);
      var widget = find.byKey(const Key("key_project_already_download"));
      expect(widget, findsOneWidget);

      var okButton = find.byKey(Key("key_ok_button"));
      await tester.tap(okButton, warnIfMissed: false);
      await tester.pump();
    });
  });
}

class MockDownloadSizeCubit extends MockCubit<FlowState> implements DownloadSizeCubit {}
