import 'dart:async';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/site/location_tree_state.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/user_vo.dart';
import '../../logger/logger.dart';
import '../../utils/app_config.dart';
import '../../utils/store_preference.dart';
import '../../utils/user_activity_preference.dart';
import '../../utils/utils.dart';
import 'navigation_state.dart';

var navigatorKeys = {
  NavigationMenuItemType.home: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.sites: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.quality: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.models: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.files: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.tasks: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.more: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.settings: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.help: GlobalKey<NavigatorState>(),
  NavigationMenuItemType.logout: GlobalKey<NavigatorState>(),
};

var navigationItems = {
  NavigationMenuItemType.home: NavigationItemType(Icons.home_filled, "Home"),
  NavigationMenuItemType.sites: NavigationItemType(Icons.gps_fixed, "Site Location"),
  NavigationMenuItemType.quality: NavigationItemType(Icons.assignment_turned_in_outlined, "Quality"),
  NavigationMenuItemType.models: NavigationItemType(CupertinoIcons.cube, "Models"),
  NavigationMenuItemType.files: NavigationItemType(Icons.text_snippet, "Files"),
  NavigationMenuItemType.tasks: NavigationItemType(Icons.task_alt_sharp, "Tasks"),
  NavigationMenuItemType.more: NavigationItemType(Icons.more_vert, "More"),
  NavigationMenuItemType.settings: NavigationItemType(Icons.settings, "Settings"),
  NavigationMenuItemType.help: NavigationItemType(Icons.help_outline_rounded, "Help"),
  NavigationMenuItemType.logout: NavigationItemType(Icons.logout, "Logout"),
};

class NavigationItemType {
  IconData icon;
  String title;
  var key = GlobalKey<NavigatorState>();

  NavigationItemType(this.icon, this.title);

  setTitle(String title) {
    this.title = title;
  }
}

enum NavigationMenuItemType {
  home("Home", Icons.home_filled),
  sites("Site Location", Icons.gps_fixed),
  models("Models", CupertinoIcons.cube),
  quality("Quality", Icons.assignment_turned_in_outlined),
  files("Files", Icons.text_snippet),
  tasks("Tasks", Icons.task_alt_sharp),
  settings("Settings", Icons.settings),
  help("Help", Icons.help_outline_rounded),
  logout("Logout", Icons.logout),
  more("More", Icons.more_vert),
  close("Close", Icons.close_outlined),
  scan("Scan", Icons.qr_code_outlined);

  const NavigationMenuItemType(this.value, this.icon);

  final String value;
  final IconData icon;
}

class UserSubscriptionPlan {
  static const keyLite = "1";
  static const keyPro = "2";
  static const keyBim = "3";
  static const keyUnlimited = "5";
  static const keyPremium = "15";

  static const listTabIdPlanBIM = [1, 2, 3, 6, 7, 8, 9, 10];
  static const listTabIdPlanUNLIMITED = [1, 2, 3, 6, 7, 8, 9, 10];
  static const listTabIdPlanLITE = [6, 7, 10];
  static const listTabIdPlanPRO = [1, 2, 3, 6, 7, 8, 9, 10];
  static const listTabIdPlanFREEMIUM = [10];
}

class NavigationCubit extends BaseCubit {
  StreamController<int> navigationItemSelection = StreamController();
  NavigationMenuItemType _currentSelected = NavigationMenuItemType.home;
  int _currentSelectedItemPosition = 0;

  bool moreBottomBarView = false;

  void toggleMoreBottomBarView() {
    moreBottomBarView = !moreBottomBarView;
    if (moreBottomBarView) {
      menuListPrimary.insert(0, NavigationMenuItemType.scan);
      menuListPrimary[menuListPrimary.indexOf(NavigationMenuItemType.more)] = NavigationMenuItemType.close;
    } else {
      menuListPrimary[menuListPrimary.indexOf(NavigationMenuItemType.close)] = NavigationMenuItemType.more;
      menuListPrimary.remove(NavigationMenuItemType.scan);
    }

    emitState(BottomNavigationToggleState(moreBottomBarView, menuListPrimary.length));
    emitState(BottomNavigationMenuListState(menuListPrimary, (menuListPrimary.indexOf(_currentSelected) > -1) ? menuListPrimary.indexOf(_currentSelected) : ((menuListPrimary.indexOf(NavigationMenuItemType.more) > -1) ? (menuListPrimary.indexOf(NavigationMenuItemType.more)) : (menuListPrimary.indexOf(NavigationMenuItemType.close))), '', (menuListPrimary.indexOf(NavigationMenuItemType.scan) > -1)  ? UniqueKey() : null));
  }

  int currentSelectedItemPosition() {
    return _currentSelectedItemPosition;
  }

  List<NavigationMenuItemType> menuList = List.empty(growable: true);
  List<NavigationMenuItemType> menuListAll = List.empty(growable: true);
  List<NavigationMenuItemType> menuListPrimary = List.empty(growable: true);
  List<NavigationMenuItemType> menuListSecondary = List.empty(growable: true);

  NavigationCubit()
      : super(BottomNavigationMenuListState(const [
    NavigationMenuItemType.home,
    NavigationMenuItemType.sites,
    NavigationMenuItemType.models,
    NavigationMenuItemType.quality,
    NavigationMenuItemType.tasks,
    NavigationMenuItemType.more,
  ], 0,'')) {
    menuList = [
      NavigationMenuItemType.home,
      NavigationMenuItemType.sites,
      NavigationMenuItemType.models,
      NavigationMenuItemType.settings,
      NavigationMenuItemType.help,
    ];
  }

  initData({bool isFromOrientation = false}) async {
    LoadingState(
        stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE);
    User? user = await StorePreference.getUserData();
    if (user != null) {
      AppConfig appConfig = di.getIt<AppConfig>();
      appConfig.storedTimestamp = DateTime.now().millisecondsSinceEpoch;

      initMenuList(
          subscriptionPlanId: user.usersessionprofile!.subscriptionPlanId!,isFromOrientation: isFromOrientation);
    } else {
      emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE,
          "Login issue, try with re-login"));
    }
  }

  initMenuList({required String subscriptionPlanId,bool isFromOrientation = false}) {
    moreBottomBarView = false;
    emitState(BottomNavigationToggleState(moreBottomBarView, menuListPrimary.length));
    //todo: itemList tobe defined from API response according to plan ID
    menuList = [
      NavigationMenuItemType.home,
      NavigationMenuItemType.sites,
      NavigationMenuItemType.quality,
      NavigationMenuItemType.models,
      NavigationMenuItemType.tasks,
    ];

    // TODO FR-732 removed 'Quality' from bottom navigation bar due to this case, for alpha release.
   // menuList.remove(NavigationMenuItemType.quality);

    if (subscriptionPlanId == UserSubscriptionPlan.keyLite || subscriptionPlanId == UserSubscriptionPlan.keyPremium) {
      menuList.remove(NavigationMenuItemType.sites);
    }
    menuListAll.clear();
    menuListAll.addAll(menuList);
    menuListPrimary.clear();
    menuListPrimary.addAll(menuListAll);
    menuListSecondary.clear();

    int? bottomNavigationBarLength = getBottomNavBarLength();
    if (menuListAll.length > bottomNavigationBarLength) {
      menuListPrimary.clear();
      menuListPrimary.addAll(menuListAll.sublist(0, bottomNavigationBarLength - 1));
      menuListPrimary.insert(bottomNavigationBarLength - 1, NavigationMenuItemType.more);
      menuListSecondary.addAll(menuListAll.sublist(bottomNavigationBarLength - 1).reversed);
    }
    bottomNavigationBarLength = null;

    if(isFromOrientation){
      emitState(BottomNavigationMenuListState(menuListPrimary, _currentSelectedItemPosition, ''));
    }
    else{
      _currentSelected = NavigationMenuItemType.home;
      emitState(BottomNavigationMenuListState(menuListPrimary, 0, ''));
    }
  }

  NavigationMenuItemType get currSelectedItem => _currentSelected;

  updateSelectedItemByType(NavigationMenuItemType navigationMenuItemType) {
    if ((menuListPrimary.indexOf(navigationMenuItemType) > -1)) {
      _currentSelectedItemPosition = menuListPrimary.indexOf(navigationMenuItemType);
      _currentSelected = navigationMenuItemType;
    } else {
      if (menuListPrimary.indexOf(NavigationMenuItemType.more) > -1) {
        _currentSelectedItemPosition = menuListPrimary.indexOf(NavigationMenuItemType.more);
        _currentSelected = navigationMenuItemType;
      } else {
        _currentSelectedItemPosition = menuListPrimary.indexOf(NavigationMenuItemType.close);
        _currentSelected = moreBottomBarView ? NavigationMenuItemType.close : NavigationMenuItemType.more;
      }
    }
    navigationItemSelection.sink.add(_currentSelectedItemPosition);
    emitState(BottomNavigationMenuListState(menuListPrimary, _currentSelectedItemPosition, ''));
  }

  void updateSelectedItemByPosition(int positionOfSelectedItem) {
    if (positionOfSelectedItem < menuListPrimary.length) {
      _currentSelected = menuListPrimary[positionOfSelectedItem];
      _currentSelectedItemPosition = positionOfSelectedItem;
    } else {
      _currentSelected = moreBottomBarView ? NavigationMenuItemType.close : NavigationMenuItemType.more;
      _currentSelectedItemPosition = menuListPrimary.indexOf(_currentSelected);
    }

    navigationItemSelection.sink.add(_currentSelectedItemPosition);
    Log.d("menuSelectionChange: positionOfSelectedItem >> $positionOfSelectedItem");
    emitState(BottomNavigationMenuListState(menuListPrimary, _currentSelectedItemPosition, ''));
  }

  bool isMenuSelected(NavigationItemType currSelected) {
    return (_currentSelected == currSelected);
  }


  Future<SiteLocation?> getLastSelectedLocation() async {
    return await getLastLocationData();
  }

  void emitLocationTreeState() {
    emitState(LocationTreeState(menuListPrimary, _currentSelectedItemPosition, ''));
  }

  int getBottomNavBarLength() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    if (Utility.isPhone) {
      return 4;
    } else if (Utility.isTablet && data.orientation == Orientation.portrait) {
      return 5;
    } else if (Utility.isTablet && data.orientation == Orientation.landscape) {
      return 7;
    } else {
      return double.maxFinite.toInt();
    }
  }
}
