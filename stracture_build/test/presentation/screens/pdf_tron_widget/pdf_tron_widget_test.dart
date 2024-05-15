import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/pdftron/pdftron_document_view.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/pdf_tron_widget/pdf_tron_widget.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart' as pdf_tron;
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:mocktail/mocktail.dart';
import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockModelListCubit extends MockCubit<ModelListState> implements ModelListCubit {}
class MockOnlineModelViewerCubit extends MockCubit<online_model_viewer.OnlineModelViewerState> implements online_model_viewer.OnlineModelViewerCubit {}
class MockSideToolBarCubit extends MockCubit<FlowState> implements side_tool_bar.SideToolBarCubit {}
class MockPdfTronCubit extends MockCubit<pdf_tron.PdfTronState> implements pdf_tron.PdfTronCubit {}
class MockModelTreeCubit extends MockCubit<ModelTreeState> implements ModelTreeCubit {}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  List<IfcObjects> bimModelList = [];
  MockOnlineModelViewerCubit mockOnlineModelViewerCubit = MockOnlineModelViewerCubit();
  MockSideToolBarCubit mockSideToolBarCubit = MockSideToolBarCubit();
  MockPdfTronCubit mockPdfTronCubit = MockPdfTronCubit();
  late ScrollController scrollController;

  configureLoginCubitDependencies() {
    init(test: true);
    AConstants.adoddleUrl = "https://adoddleqaak.asite.com";
    final ifcObjects = json.decode(fixture('bim_model.json'));
    var modelList = BimProjectModel.fromJson(ifcObjects);
    List<BimProjectModel> outputList = [];
    outputList.add(modelList);
    for (var item in outputList[0].bIMProjectModelVO!.ifcObject!.ifcObjects!) {
      bimModelList.add(item);
    }
    scrollController = ScrollController();
    getIt.unregister<online_model_viewer.OnlineModelViewerCubit>();
    getIt.unregister<side_tool_bar.SideToolBarCubit>();
    getIt.unregister<PdfTronCubit>();
    getIt.registerLazySingleton<online_model_viewer.OnlineModelViewerCubit>(() => mockOnlineModelViewerCubit);
    getIt.registerLazySingleton<side_tool_bar.SideToolBarCubit>(() => mockSideToolBarCubit);
    getIt.registerLazySingleton<PdfTronCubit>(() => mockPdfTronCubit);
  }

  setUp(() async {
    when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
    when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.PaginationListInitial());
    when(() => mockOnlineModelViewerCubit.selectedModelId).thenReturn("");
    when(() => mockOnlineModelViewerCubit.offlineFilePath).thenReturn([]);
    when(() => mockOnlineModelViewerCubit.bimModelListData).thenReturn([]);
    when(() => mockOnlineModelViewerCubit.isDialogShowing).thenReturn(false);
    when(() => mockSideToolBarCubit.isSideToolBarEnabled).thenReturn(false);
    when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.isShowPdf).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.isShowSideToolBar).thenReturn(true);
    when(() => mockPdfTronCubit.isFullViewPdfTron).thenReturn(false);
    when(() => mockOnlineModelViewerCubit.totalNumbersOfModelsLoad).thenReturn('1');
    when(() => mockOnlineModelViewerCubit.totalNumbersOfModels).thenReturn('1');
    when(() => mockOnlineModelViewerCubit.selectedPdfFileName).thenReturn('');
    when(() => mockOnlineModelViewerCubit.key).thenReturn(GlobalKey<ScaffoldState>());
  });

  group('Stack Widget Test', () {
    configureLoginCubitDependencies();
    Widget makeTestableWidget() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
            create: (BuildContext context) => mockOnlineModelViewerCubit,
          ),
          BlocProvider<side_tool_bar.SideToolBarCubit>(
            create: (BuildContext context) => mockSideToolBarCubit,
          ),
          BlocProvider<pdf_tron.PdfTronCubit>(
            create: (BuildContext context) => mockPdfTronCubit,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: PdfTronWidget(
              pdfFileName: mockOnlineModelViewerCubit.selectedPdfFileName,
              onlineModelViewerCubit: mockOnlineModelViewerCubit,
              orientation: Orientation.landscape,
              scrollController: scrollController,
              modelId: "",
          ),
        ),
      );
    }
    testWidgets('Widget should contain PdftronDocumentView and Positioned widgets', (WidgetTester tester) async {
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn([]);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('testValue.pdf');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      await tester.pumpWidget(makeTestableWidget(),);
      expect(find.byKey(const Key("key_pdf_tron_widget")), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('Widget should contain dropdown widgets', (WidgetTester tester) async {
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PaginationListInitial());
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn([]);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('testValue.pdf');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      await tester.pumpWidget(makeTestableWidget(),);
      expect(find.byKey(const Key("key_drop_down_widget_row")), findsOneWidget);
      expect(find.byKey(const Key("key_drop_down_widget_flexible")), findsOneWidget);
      expect(find.byKey(const Key("key_pdf_dialog")), findsNothing);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('Widget should contain dropdown widgets', (WidgetTester tester) async {
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.EmptyFilteredListState());
      when(() => mockPdfTronCubit.state).thenReturn(pdf_tron.PDFDownloaded());
      when(() => mockOnlineModelViewerCubit.calibList).thenReturn([]);
      when(() => mockOnlineModelViewerCubit.selectedCalibrationName).thenReturn('testValue.pdf');
      when(() => mockOnlineModelViewerCubit.isFullPdf).thenReturn(false);
      await tester.pumpWidget(makeTestableWidget());
      expect(find.byKey(const Key("key_empty_filtered_list_view")), findsNothing);
    });
  });
}
