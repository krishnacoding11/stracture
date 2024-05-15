import 'dart:collection';

import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:flutter/material.dart';

class NavigationRouteObserver extends RouteObserver<PageRoute<void>> {
  final _toolbarCubit = getIt<ToolbarCubit>();
  final _navigationCubit = getIt<NavigationCubit>();
  static HashMap<NavigationMenuItemType, List<Route<dynamic>>> routeStack =
      HashMap();

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is MaterialPageRoute) {
      var stack = routeStack[_navigationCubit.currSelectedItem];
      stack ??= List.empty(growable: true);
      if (stack.isNotEmpty) {
        stack.removeLast();
      }
      routeStack[_navigationCubit.currSelectedItem] = stack;
      _updateState();
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is MaterialPageRoute) {
      var stack = routeStack[_navigationCubit.currSelectedItem];
      stack ??= List.empty(growable: true);
      stack.add(route);
      routeStack[_navigationCubit.currSelectedItem] = stack;
      _updateState();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is MaterialPageRoute) {
      var stack = routeStack[_navigationCubit.currSelectedItem];
      stack ??= List.empty(growable: true);
      stack.removeLast();
      routeStack[_navigationCubit.currSelectedItem] = stack;
      _updateState();
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is MaterialPageRoute) {
      var stack = routeStack[_navigationCubit.currSelectedItem];
      stack ??= List.empty(growable: true);
      if (stack.isNotEmpty) stack.removeLast();
      stack.add(newRoute);
      routeStack[_navigationCubit.currSelectedItem] = stack;
      _updateState();
    }
  }

  _updateState() async {
    var stack = routeStack[_navigationCubit.currSelectedItem];
    stack ??= List.empty(growable: true);
    if (stack.isNotEmpty) {
      //_toolbarCubit.updateTitleFromRoute(stack.last.settings.name);
      _toolbarCubit.updateTitleFromItemType(
        currentSelectedItem: _navigationCubit.currSelectedItem,
        routeName: stack.last.settings.name ?? ""
      );
    } else {
      //_toolbarCubit.updateTitleFromRoute('');
      _toolbarCubit.updateTitleFromItemType(currentSelectedItem: _navigationCubit.currSelectedItem,title: _navigationCubit.currSelectedItem.value);
    }
    await _toolbarCubit
        .updateSelectedItemByPosition(_navigationCubit.currSelectedItem);
  }
}
