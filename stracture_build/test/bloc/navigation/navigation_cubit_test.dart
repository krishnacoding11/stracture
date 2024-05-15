import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/navigation/navigation_state.dart';
import 'package:field/bloc/site/location_tree_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/fixture_reader.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setAsitePluginsMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  di.init(test: true);
  group("Navigation Cubit:", () {
    NavigationCubit navigationCubit = NavigationCubit();
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});

    var menuList = [
      NavigationMenuItemType.home,
      NavigationMenuItemType.sites,
      NavigationMenuItemType.models,
      NavigationMenuItemType.quality,
      NavigationMenuItemType.tasks,
      NavigationMenuItemType.more,
    ];

    test("Initial State", () {
      expect(navigationCubit.state, BottomNavigationMenuListState(menuList, 0, ''));
    });

    test("Initial State is instance of FlowState", () {
      expect(navigationCubit.state, isA<FlowState>());
    });

    test("Initial State is instance of BaseFlowState", () {
      expect(navigationCubit.state, isA<BaseFlowState>());
    });

    blocTest<NavigationCubit, FlowState>(
      'when initData() is called with success response',
      build: () => NavigationCubit(),
      act: (cubit) async {
        await cubit.initData();
      },
      expect: () => [
        BottomNavigationToggleState(false, 0),
        BottomNavigationMenuListState(
          [NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.more],
          0,
          '',
        ),
      ],
    );

    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationMenuListState] when updateSelectedItemByType() is called',
      build: () => NavigationCubit(),
      act: (cubit) async {
        cubit.moreBottomBarView = false;
        cubit.menuListAll = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.menuListPrimary = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.more,
        ];
        cubit.menuListSecondary = [
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.updateSelectedItemByType(NavigationMenuItemType.home);
      },
      expect: () => [
        BottomNavigationMenuListState([NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.more], 0, '')
      ],
    );

    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationMenuListState] when updateSelectedItemByType() is called',
      build: () => NavigationCubit(),
      act: (cubit) async {
        cubit.moreBottomBarView = false;
        cubit.menuListAll = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.menuListPrimary = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.more,
        ];
        cubit.menuListSecondary = [
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.updateSelectedItemByType(NavigationMenuItemType.models);
      },
      expect: () => [
        BottomNavigationMenuListState([NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.more], 3, '')
      ],
    );

    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationMenuListState] when updateSelectedItemByType() is called',
      build: () => NavigationCubit(),
      act: (cubit) async {
        cubit.moreBottomBarView = true;
        cubit.menuListAll = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.menuListPrimary = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.close,
        ];
        cubit.menuListSecondary = [
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.updateSelectedItemByType(NavigationMenuItemType.models);
      },
      expect: () => [
        BottomNavigationMenuListState([NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.close], 3, '')
      ],
    );

    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationMenuListState] when updateSelectedItemByPosition() is called',
      build: () => NavigationCubit(),
      act: (cubit) async {
        cubit.moreBottomBarView = false;
        cubit.menuListAll = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.menuListPrimary = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.more,
        ];
        cubit.menuListSecondary = [
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.updateSelectedItemByPosition(1);
      },
      expect: () => [
        BottomNavigationMenuListState([NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.more], 1, '')
      ],
    );
    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationMenuListState] when updateSelectedItemByPosition() is called',
      build: () => NavigationCubit(),
      act: (cubit) async {
        cubit.moreBottomBarView = false;
        cubit.menuListAll = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.menuListPrimary = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.more,
        ];
        cubit.menuListSecondary = [
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.updateSelectedItemByPosition(5);
      },
      expect: () => [
        BottomNavigationMenuListState([NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.more], 3, '')
      ],
    );

    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationMenuListState] when changeMenuList() is called',
      build: () => NavigationCubit(),
      act: (cubit) async => cubit.emitLocationTreeState(),
      expect: () => [isA<LocationTreeState>()],
    );

    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationToggleState] when toggleMoreBottomBarView() is called when moreBottomBarView = false',
      build: () => NavigationCubit(),
      act: (cubit) async {
        cubit.menuListAll = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.menuListPrimary = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.more,
        ];
        cubit.menuListSecondary = [
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.toggleMoreBottomBarView();
      },
      expect: () => [
        BottomNavigationToggleState(true, navigationCubit.getBottomNavBarLength() + 1),
        BottomNavigationMenuListState([NavigationMenuItemType.scan, NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.close], 1, '')
      ],
    );
    blocTest<NavigationCubit, FlowState>(
      'emits [BottomNavigationToggleState] when toggleMoreBottomBarView() is called when moreBottomBarView = true',
      build: () => NavigationCubit(),
      act: (cubit) async {
        cubit.moreBottomBarView = true;
        cubit.menuListAll = [
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.menuListPrimary = [
          NavigationMenuItemType.scan,
          NavigationMenuItemType.home,
          NavigationMenuItemType.sites,
          NavigationMenuItemType.quality,
          NavigationMenuItemType.close,
        ];
        cubit.menuListSecondary = [
          NavigationMenuItemType.models,
          NavigationMenuItemType.tasks,
        ];
        cubit.toggleMoreBottomBarView();
      },
      expect: () => [
        BottomNavigationToggleState(false, navigationCubit.getBottomNavBarLength()),
        BottomNavigationMenuListState([NavigationMenuItemType.home, NavigationMenuItemType.sites, NavigationMenuItemType.quality, NavigationMenuItemType.more], 0, '')
      ],
    );

    test("getBottomNavBarLength is called returned 4", () {
      var len = navigationCubit.getBottomNavBarLength();
      expect(len, 4);
    });

    /* test("getBottomNavBarLength is called returned 5", () async {
      Utility.isPhone = false;
      Utility.isTablet = true;
      var len = navigationCubit.getBottomNavBarLength();
      expect(len, 5);
    });*/

    test("getBottomNavBarLength is called returned 7", () {
      Utility.isPhone = false;
      Utility.isTablet = true;
      var len = navigationCubit.getBottomNavBarLength();
      expect(len, 7);
    });
    test("getBottomNavBarLength is called in else part", () {
      Utility.isPhone = false;
      Utility.isTablet = false;

      var len = navigationCubit.getBottomNavBarLength();
      expect(len, double.maxFinite.toInt());
    });

    test("menuList", () {
      navigationCubit.menuList.clear();
      expect(navigationCubit.menuList, []);
    });

    test("menuListAll", () {
      navigationCubit.menuListAll.clear();
      expect(navigationCubit.menuListAll, []);
    });
    test("menuListAll", () {
      navigationCubit.menuListAll.clear();
      expect(navigationCubit.menuListAll, []);
    });
    test("menuListPrimary", () {
      navigationCubit.menuListPrimary.clear();
      expect(navigationCubit.menuListAll, []);
    });
    test("menuListSecondary", () {
      navigationCubit.menuListSecondary.clear();
      expect(navigationCubit.menuListAll, []);
    });

    blocTest<NavigationCubit, FlowState>(
      'emits [ErrorState] when initData() is called',
      build: () => NavigationCubit(),
      act: (cubit) async {
        await StorePreference.clearUserPreferenceData();
        await cubit.initData();
      },
      expect: () => [ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, "Login issue, try with re-login")],
    );
  });
}
