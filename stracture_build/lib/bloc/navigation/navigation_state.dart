import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:flutter/material.dart';

import '../../presentation/base/state_renderer/state_render_impl.dart';
import 'navigation_cubit.dart';

/*class
UserProfileSidebarState extends FlowState {
  final String userFirstname;
  final String userImageUri;
  final Map<String, String> headerData;

  UserProfileSidebarState(
      this.userFirstname, this.userImageUri, this.headerData);

  @override
  List<Object> get props => [userFirstname, userImageUri, headerData];

  @override
  String getMessage() => "";

  @override
  StateRendererType getStateRendererType() =>
      StateRendererType.CONTENT_SCREEN_STATE;
}*/

class BottomNavigationMenuListState extends FlowState {
  final List<NavigationMenuItemType> menuList;
  final int selectedItemIndex;
  String online = '';
  Key? bottomNavigationKey;

  BottomNavigationMenuListState(this.menuList, this.selectedItemIndex, this.online,[this.bottomNavigationKey]);

  @override
  List<Object> get props => [menuList, selectedItemIndex, online];

  @override
  String getMessage() => "";

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class BottomNavigationToggleState extends FlowState {
  final bool moreBottomBarView;
  final int menuListLength;

  BottomNavigationToggleState(this.moreBottomBarView, this.menuListLength);

  @override
  List<Object> get props => [moreBottomBarView, menuListLength];

  @override
  String getMessage() => "";

  @override
  StateRendererType getStateRendererType() => StateRendererType.CONTENT_SCREEN_STATE;
}

class NavigationMenuSelectedItemState extends FlowState {
  final NavigationMenuItemType selectedItem;

  NavigationMenuSelectedItemState(this.selectedItem);

  @override
  List<Object> get props => [selectedItem];

  @override
  String getMessage() {
    return "";
  }

  @override
  StateRendererType getStateRendererType() {
    return StateRendererType.CONTENT_SCREEN_STATE;
  }
}

class PopTabNavigatorNavigation {
  final int stackCount;

  PopTabNavigatorNavigation(this.stackCount);
}
