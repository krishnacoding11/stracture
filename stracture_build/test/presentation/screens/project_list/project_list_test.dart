import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/project_list_item/project_item_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/screen/project_list.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockProjectListCubit extends MockCubit<FlowState> implements ProjectListCubit {}

class MockSyncCubit extends MockCubit<FlowState> implements SyncCubit {}

class MockProjectItemCubit extends MockCubit<FlowState> implements ProjectItemCubit {}

class MockInternetCubit extends Mock implements InternetCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  var mockProjectListCubit = MockProjectListCubit();
  var mockSyncCubit = MockSyncCubit();
  var mockProjectItemCubit = MockProjectItemCubit();
  var mockInternetCubit = MockInternetCubit();

  List<Popupdata> allItems = [];
  final TabController _tabController = TabController(vsync: const TestVSync(), length: 2);


  configureLoginCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<ProjectListCubit>();
    di.getIt.registerFactory<ProjectListCubit>(() => mockProjectListCubit);
    di.getIt.unregister<SyncCubit>();
    di.getIt.registerFactory<SyncCubit>(() => mockSyncCubit);
    di.getIt.unregister<ProjectItemCubit>();
    di.getIt.registerFactory<ProjectItemCubit>(() => mockProjectItemCubit);
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
  }

  setUpAll(() {
    final popUpData = json.decode(fixture('popupdata_list.json'));
    for (var item in popUpData["data"]) {
      Popupdata popupData = Popupdata.fromJson(item);
      popupData.isMarkOffline = false;
      popupData.projectSizeInByte = "0";
      popupData.progress = 0;
      popupData.syncStatus = null;
      popupData.hasLocationMarkOffline = null;
      popupData.locationSyncStatus = null;
      popupData.hasLocationSyncedSuccessfully = null;
      allItems.add(popupData);
    }
  });

  Widget getTestWidget(int index, Widget allProjectList, Widget favProjectList) {
    var tabBar = TabBar(
      controller: _tabController..index = index,
      labelColor: AColors.black,
      indicator: const UnderlineTabIndicator(borderSide: BorderSide(width: 2.0, color: Colors.deepOrange), insets: EdgeInsets.symmetric(horizontal: 0)),
      indicatorColor: Colors.orange,
      tabs: const [
        Tab(
          text: "All",
          height: 40,
        ),
        Tab(
          text: "Favourites",
          height: 40,
        ),
      ],
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectListCubit>(
          create: (BuildContext context) => di.getIt<ProjectListCubit>(),
        ),
        BlocProvider<SyncCubit>(create: (context) => di.getIt<SyncCubit>()),
        BlocProvider<ProjectItemCubit>(create: (context) => di.getIt<ProjectItemCubit>()),
      ],
      child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en')
          ],
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: tabBar,
              ),
              body: TabBarView(
                controller: _tabController,
                children: [allProjectList, favProjectList],
              ),
            ),
          )),
    );
  }

  group("Project List Testing", () {
    configureLoginCubitDependencies();
    setUp(() {
      // when(()=> mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      when(() => mockSyncCubit.state).thenReturn(FlowState());
      when(() => mockProjectItemCubit.state).thenReturn(FlowState());
      when(() => mockProjectListCubit.getRecentProject()).thenAnswer((invocation) async => allItems);
      when(() => mockProjectListCubit.pageFetch(any(), any(), any(), any(), any())).thenAnswer((invocation) async => allItems);
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
    });
    final ScrollController scrollController = ScrollController();
    final FocusNode focusNode = FocusNode();
    final TextEditingController controller = TextEditingController();

    Widget projectWidgetForAllTab = ProjectList(
      isFavourites: false,
      screenName: "All",
      onBack: backFunction,
      scrollController: scrollController,
      searchFocusNode: focusNode,
      searchProjectController: controller,
      tabController: _tabController,
    );
    Widget projectWidgetForFavTab = ProjectList(
      isFavourites: true,
      screenName: "Favourites",
      onBack: backFunction,
      scrollController: scrollController,
      searchFocusNode: focusNode,
      searchProjectController: controller,
      tabController: _tabController,
    );

    testWidgets("Find OrientationBuilder widget", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byType(OrientationBuilder), findsWidgets);
    });

    testWidgets("Find RefreshIndicator widget", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets("When We Unfavourite All Favourite Projects Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(FavProjectSuccessState(items: []));
      await tester.pumpWidget(getTestWidget(1, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.text('You haven\'t marked any projects as favourite'), findsWidgets);
    });

    testWidgets("Project Listing Listview Test For All Tab", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets("Refreshing State Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(RefreshingState(false));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byType(ACircularProgress), findsWidgets);
    });

    testWidgets("All Project Loading State Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectLoadingState());
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byType(ACircularProgress), findsWidgets);
    });

    testWidgets("No Match Found Test For All Tab", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectNotFoundState());
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.text('No matches found'), findsWidgets);
    });

    testWidgets("No Project Allocated Test For All Tab", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectNotAllocatedState());
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.text('You have not been allocated any projects yet.\nPlease contact your workspace administrator for help.'), findsWidgets);
    });

    testWidgets("Project Listing Listview Test For Favourite Tab", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(FavProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(1, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets("Fav Project Loading State Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(FavProjectLoadingState());
      await tester.pumpWidget(getTestWidget(1, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byType(ACircularProgress), findsWidgets);
    });

    testWidgets("No Match Found Test For Favourite Tab", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(FavProjectNotFoundState());
      await tester.pumpWidget(getTestWidget(1, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.text('No matches found'), findsWidgets);
    });

    testWidgets("No Project Allocated Test For Favourite Tab", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(FavProjectNotAllocatedState());
      await tester.pumpWidget(getTestWidget(1, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.text('You haven\'t marked any projects as favourite'), findsWidgets);
    });

    testWidgets("Pull To Refresh Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      await tester.drag(find.byType(RefreshIndicator), Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets("Tab Change Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      await tester.drag(find.byKey(ValueKey("List Item 2")), Offset(-5000, 0));
      await tester.pumpAndSettle();
      expect(_tabController.index, 1);
    });

    testWidgets("Sorting Icon Test", (tester) async {
      List<Popupdata> items = [];
      when(() => mockProjectListCubit.pageFetch(any(), any(), any(), any(), true)).thenAnswer((invocation) async {
        return allItems;
      });
      when(() => mockProjectListCubit.pageFetch(any(), any(), any(), any(), false)).thenAnswer((invocation) async {
        items = allItems.reversed.toList();
        return allItems.reversed.toList();
      });
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      await tester.tap(find.byKey(ValueKey("Sorting Icon")));
      await tester.pumpAndSettle();
      expect(items, allItems.reversed.toList());
    });

    testWidgets("Sorting Icon Test for Favourite Tab", (tester) async {
      List<Popupdata> items = [];
      when(() => mockProjectListCubit.pageFetch(any(), any(), any(), any(), true)).thenAnswer((invocation) async {
        return allItems;
      });
      when(() => mockProjectListCubit.pageFetch(any(), any(), any(), any(), false)).thenAnswer((invocation) async {
        items = allItems.reversed.toList();
        return allItems.reversed.toList();
      });
      when(() => mockProjectListCubit.state).thenReturn(FavProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(1, projectWidgetForAllTab, projectWidgetForFavTab));
      await tester.tap(find.byKey(ValueKey("Sorting Icon")));
      await tester.pumpAndSettle();
      expect(items, allItems.reversed.toList());
    });

   /* testWidgets("Sync Complete Successfully Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      final expectedStates = [ProjectSyncProgressState(100, "2061216", ESyncStatus.success)];
      whenListen(mockProjectListCubit, Stream.fromIterable(expectedStates));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byIcon(Icons.cloud_download_outlined), findsWidgets);
      await tester.pump();
      expect(find.byIcon(Icons.offline_pin), findsWidgets);
    });

    testWidgets("Sync Failure Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      final expectedStates = [ProjectSyncProgressState(100, "2061216", ESyncStatus.failed)];
      whenListen(mockProjectListCubit, Stream.fromIterable(expectedStates));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byIcon(Icons.cloud_download_outlined), findsWidgets);
      await tester.pump();
      expect(find.byIcon(Icons.cancel), findsWidgets);
    });
*/
    testWidgets("Offline Correct Icon when Project Synced Successfully", (tester) async {
      Popupdata element = allItems[0];
      element.imgId = -1;
      List<Popupdata> projectItems = [element];
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: projectItems));
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
    });

    testWidgets("Add Favourite", (tester) async {
      Popupdata element = allItems[0];
      element.imgId = -1;
      List<Popupdata> projectItems = [element];
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: projectItems));
      when(() => mockProjectListCubit.favouriteProject(projectItems[0], any(), any())).thenAnswer((invocation) => Future.value());
      final expectedStates = [AllProjectSuccessState(items: projectItems)];
      whenListen(mockProjectListCubit, Stream.fromIterable(expectedStates));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      expect(find.byIcon(Icons.star_border), findsWidgets);
      await tester.tap(find.byIcon(Icons.star_border));
      projectItems[0].imgId = 1;
      await tester.pump();
      expect(find.byIcon(Icons.star), findsWidgets);
    });


    testWidgets("Pagination Test", (tester) async {
      List<Popupdata> items = [];
      when(() => mockProjectListCubit.pageFetch(0, any(), any(), any(), any())).thenAnswer((invocation) async {
        return allItems;
      });
      when(() => mockProjectListCubit.pageFetch(1, any(), any(), any(), any())).thenAnswer((invocation) async {
        items = allItems.reversed.toList();
        return allItems.reversed.toList();
      });
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      when(() => mockProjectListCubit.isLastItem).thenReturn(false);
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      final ScrollableState state = tester.state(find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)));
      final ScrollPosition position = state.widget.controller!.position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      expect(items, equals(allItems.reversed.toList()));
    });

    testWidgets("Pagination Test For Favourites Tab", (tester) async {
      List<Popupdata> items = [];
      when(() => mockProjectListCubit.pageFetch(0, any(), any(), any(), any())).thenAnswer((invocation) async {
        return allItems;
      });
      when(() => mockProjectListCubit.pageFetch(1, any(), any(), any(), any())).thenAnswer((invocation) async {
        items = allItems.reversed.toList();
        return allItems.reversed.toList();
      });
      when(() => mockProjectListCubit.state).thenReturn(FavProjectSuccessState(items: allItems));
      when(() => mockProjectListCubit.isFavLastItem).thenReturn(false);
      await tester.pumpWidget(getTestWidget(1, projectWidgetForAllTab, projectWidgetForFavTab));
      final ScrollableState state = tester.state(find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)));
      final ScrollPosition position = state.position;
      position.jumpTo(position.maxScrollExtent);
      expect(items, equals(allItems.reversed.toList()));
    });

    testWidgets("Search Controller On Tap Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      await tester.tap(find.byKey(Key("searchBoxProjectList")));
      expect(focusNode.hasFocus, true);
    });

    testWidgets("CustomSearchSuggestionView Test", (tester) async {
      when(() => mockProjectListCubit.state).thenReturn(AllProjectSuccessState(items: allItems));
      when(() => mockProjectListCubit.getSuggestedSearchList(any(), any(), any(), any())).thenAnswer((invocation) => Future.value([allItems[0]]));
      await tester.pumpWidget(getTestWidget(0, projectWidgetForAllTab, projectWidgetForFavTab));
      await tester.tap(find.byKey(Key("searchBoxProjectList")));
      expect(focusNode.hasFocus, true);
      controller.text = "site";
      await tester.pump();
    });
  });
}

void backFunction() {}
