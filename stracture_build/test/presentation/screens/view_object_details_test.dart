import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/view_file_association/view_file_association_cubit.dart' as file_association;
import 'package:field/bloc/view_object_details/view_object_details_cubit.dart';
import 'package:field/data/model/file_association_model.dart';
import 'package:field/data/model/view_object_details_model.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/side_toolbar/side_toolbar_screen.dart';
import 'package:field/presentation/screen/view_object_details.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import '../../bloc/mock_method_channel.dart';

class MockViewObjectDetailsCubit extends MockCubit<ViewObjectDetailsState> implements ViewObjectDetailsCubit {}

class MockFileAssociationCubit extends MockCubit<file_association.FileAssociationState> implements file_association.FileAssociationCubit {}

class MockOnlineModelViewerCubit extends MockCubit<online_model_viewer.OnlineModelViewerState> implements online_model_viewer.OnlineModelViewerCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockViewObjectDetailsCubit mockViewObjectDetailsCubit = MockViewObjectDetailsCubit();
  MockOnlineModelViewerCubit mockOnlineModelViewerCubit = MockOnlineModelViewerCubit();
  MockFileAssociationCubit mockFileAssociationCubit = MockFileAssociationCubit();

  configureLoginCubitDependencies() {
    init(test: true);
    getIt.unregister<ViewObjectDetailsCubit>();
    getIt.unregister<online_model_viewer.OnlineModelViewerCubit>();
    getIt.unregister<file_association.FileAssociationCubit>();
    getIt.registerLazySingleton<ViewObjectDetailsCubit>(() => mockViewObjectDetailsCubit);
    getIt.registerLazySingleton<online_model_viewer.OnlineModelViewerCubit>(() => mockOnlineModelViewerCubit);
    getIt.registerLazySingleton<file_association.FileAssociationCubit>(() => mockFileAssociationCubit);
  }

  setUp(() async {
    when(() => mockViewObjectDetailsCubit.state).thenReturn(PaginationListInitial());
    when(() => mockOnlineModelViewerCubit.state).thenReturn(online_model_viewer.PaginationListInitial());
    when(() => mockFileAssociationCubit.state).thenReturn(file_association.PaginationListInitial());
  });

  Widget getViewObjectDetailsTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ViewObjectDetailsCubit>(
          create: (BuildContext context) => mockViewObjectDetailsCubit,
        ),
        BlocProvider<online_model_viewer.OnlineModelViewerCubit>(
          create: (BuildContext context) => mockOnlineModelViewerCubit,
        ),
        BlocProvider<file_association.FileAssociationCubit>(
          create: (BuildContext context) => mockFileAssociationCubit,
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
        home: ViewObjectDetails(),
      ),
    );
  }

  group('View Object Details Test', () {
    configureLoginCubitDependencies();
    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isFileAssociation).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.detailsList).thenReturn([]);
      when(() => mockOnlineModelViewerCubit.fileAssociationList).thenReturn([]);
      when(() => mockViewObjectDetailsCubit.isFullViewObjectDetails).thenReturn(false);
      when(() => mockViewObjectDetailsCubit.viewObjectDetailsModelList).thenReturn([]);
      when(() => mockViewObjectDetailsCubit.state).thenReturn(ExpandedDropdownState(true));
      List<Detail> detailsList = [];
      Detail detail = Detail(sectionName: "sectionName", property: [], isExpanded: false);
      detailsList.add(detail);
      when(() => mockViewObjectDetailsCubit.viewObjectDetailsModelList).thenReturn([]);
      await tester.pumpWidget(getViewObjectDetailsTestWidget());
      expect(find.byKey(Key('key_orientation_builder_view_object_details')), findsNothing);
      expect(find.byKey(Key('key_orientation_builder_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_gesture_detector_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_container_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_row_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_drawer_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_sized_box_file_association')), findsNWidgets(2));
      expect(find.byKey(Key('key_flexible_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_spacer_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_visibility_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_icon_button_file_association')), findsOneWidget);
      expect(find.byKey(Key('key_divider_file_association')), findsOneWidget);
    });

    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isFileAssociation).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.detailsList).thenReturn([]);
      when(() => mockOnlineModelViewerCubit.fileAssociationList).thenReturn([]);
      when(() => mockViewObjectDetailsCubit.isFullViewObjectDetails).thenReturn(false);
      when(() => mockViewObjectDetailsCubit.viewObjectDetailsModelList).thenReturn([]);
      when(() => mockFileAssociationCubit.viewFileAssociationList).thenReturn([]);
      when(() => mockFileAssociationCubit.state).thenReturn(file_association.ViewFullScreenFileAssociation(true));
      when(() => mockFileAssociationCubit.isFullViewObjectDetails).thenReturn(false);
      List<Detail> detailsList = [];
      Detail detail = Detail(sectionName: "sectionName", property: [], isExpanded: false);
      detailsList.add(detail);
      when(() => mockViewObjectDetailsCubit.viewObjectDetailsModelList).thenReturn([]);
      await tester.pumpWidget(getViewObjectDetailsTestWidget());
      expect(find.byKey(Key('key_list_view_association')), findsNothing);
      expect(find.byKey(Key('key_column_file_association')), findsNothing);
      expect(find.byKey(Key('key_file_name_text_widget')), findsNothing);
      expect(find.byKey(Key('key_display_size_text_widget')), findsNothing);
      expect(find.byKey(Key('key_attached_date_text_widget')), findsNothing);
      expect(find.byKey(Key('key_attached_by_row')), findsNothing);
      expect(find.byKey(Key('key_attached_by_name_text_widget')), findsNothing);
    });

    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      List<FileAssociation> fileAssociationList = [];
      FileAssociation fileAssociation = FileAssociation(revisionId: "revisionId", documentTypeId: 4, projectId: "projectId", folderId: "folderId", generateUri: true, filename: '', filepath: '', documentRevision: '', publisherName: '', publisherOrganization: '', revisionCounter: '', publishDate: '', documentTitle: '', documentId: '', associatedDate: '');
      fileAssociationList.add(fileAssociation);
      when(() => mockFileAssociationCubit.viewFileAssociationList).thenReturn(fileAssociationList);
      when(() => mockOnlineModelViewerCubit.isFileAssociation).thenReturn(true);
      when(() => mockViewObjectDetailsCubit.isFullViewObjectDetails).thenReturn(false);
      when(() => mockFileAssociationCubit.state).thenReturn(file_association.ViewFullScreenFileAssociation(true));
      when(() => mockFileAssociationCubit.isFullViewObjectDetails).thenReturn(false);
      await tester.pumpWidget(getViewObjectDetailsTestWidget());
      expect(find.byKey(Key('key_list_view_association')), findsOneWidget);
      expect(find.byKey(Key('key_column_file_association')), findsOneWidget);
    });

    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      List<FileAssociation> fileAssociationList = [];
      FileAssociation fileAssociation = FileAssociation(revisionId: "revisionId", documentTypeId: 4, projectId: "projectId", folderId: "folderId", generateUri: true, filename: '', filepath: '', documentRevision: '', publisherName: '', publisherOrganization: '', revisionCounter: '', publishDate: '', documentTitle: '', documentId: '', associatedDate: '');

      fileAssociationList.add(fileAssociation);
      when(() => mockFileAssociationCubit.viewFileAssociationList).thenReturn(fileAssociationList);
      when(() => mockOnlineModelViewerCubit.isFileAssociation).thenReturn(true);
      when(() => mockViewObjectDetailsCubit.isFullViewObjectDetails).thenReturn(true);
      when(() => mockFileAssociationCubit.isFullViewObjectDetails).thenReturn(false);
      await tester.pumpWidget(getViewObjectDetailsTestWidget());
      expect(find.byKey(Key('key_expanded_half_view_file_association')), findsOneWidget);
    });

    testWidgets('should show SideToolbarScreen when isShowSideToolBar is true', (WidgetTester tester) async {
      when(() => mockOnlineModelViewerCubit.isFileAssociation).thenReturn(true);
      when(() => mockOnlineModelViewerCubit.detailsList).thenReturn([]);
      when(() => mockOnlineModelViewerCubit.fileAssociationList).thenReturn([]);
      when(() => mockViewObjectDetailsCubit.isFullViewObjectDetails).thenReturn(false);
      when(() => mockViewObjectDetailsCubit.viewObjectDetailsModelList).thenReturn([]);
      when(() => mockFileAssociationCubit.viewFileAssociationList).thenReturn([]);
      when(() => mockFileAssociationCubit.state).thenReturn(file_association.ViewFullScreenFileAssociation(true));
      when(() => mockFileAssociationCubit.isFullViewObjectDetails).thenReturn(false);
      List<Detail> detailsList = [];
      Detail detail = Detail(sectionName: "sectionName", property: [], isExpanded: false);
      detailsList.add(detail);
      when(() => mockViewObjectDetailsCubit.viewObjectDetailsModelList).thenReturn(detailsList);
      await tester.pumpWidget(getViewObjectDetailsTestWidget());
      expect(find.byKey(Key('key_file_name_text_widget')), findsNothing);
      expect(find.byKey(Key('key_display_size_text_widget')), findsNothing);
      expect(find.byKey(Key('key_attached_date_text_widget')), findsNothing);
      expect(find.byKey(Key('key_attached_by_row')), findsNothing);
      expect(find.byKey(Key('key_attached_by_name_text_widget')), findsNothing);
    });
  });
}
