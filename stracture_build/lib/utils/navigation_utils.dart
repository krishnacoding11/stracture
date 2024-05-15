
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/screen/bottom_navigation/navigation_route_observer.dart';
import 'package:field/presentation/screen/dashboard.dart';
import 'package:flutter/material.dart';

class NavigationUtils {
  static final _navigationCubit = getIt<NavigationCubit>();
  //Note:- Don't initialize 'mainNavigationKey' again or it will affect the main navigation.
  static GlobalKey<NavigatorState> mainNavigationKey =
      GlobalKey<NavigatorState>();

  static mainPushNamed<T extends Object?>(
      BuildContext context, String routeName,
      {Object? argument}) {
    mainNavigationKey.currentState?.pushNamed(routeName, arguments: argument);
  }

  static mainPush<T extends Object?>(BuildContext context, Route<T> route) {
    mainNavigationKey.currentState?.push(route);
  }
  static Future<dynamic>? mainPushWithResult<T extends Object?>(BuildContext context, Route<T> route) async {
    return await mainNavigationKey.currentState?.push(route);
  }
  static mainPushReplacementNamed<T extends Object?>(String routeName) {
    mainNavigationKey.currentState?.pushReplacementNamed(routeName);
  }

  static mainPushAndRemoveUntilWithoutAnimation<T extends Object?>(
      Widget page) async {
    var routeStack = NavigationRouteObserver.routeStack;
    routeStack.forEach((key, value) async {
      await _popUntil(key);
    });
    await _navigationCubit.updateSelectedItemByType(NavigationMenuItemType.home);
    mainNavigationKey.currentState?.pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
            (route) => false);
    /*await Future.delayed(Duration(milliseconds: 300));
    DashboardWidget.of(mContext)?.reload();*/
  }

  static Future<void> _popUntil(key) async {
    //Do not remove this delay it will cause concurrent modification exception
    await Future.delayed(const Duration(milliseconds: 300));
    navigatorKeys[key]?.currentState?.popUntil((route) => route.isFirst);
  }

  static Future<void> reloadApp() async {
    //NavigationUtils.mainPushReplacementNamed(Routes.splash);
    NavigationUtils.mainPushAndRemoveUntilWithoutAnimation(
        const DashboardWidget());
  }

  static push<T extends Object?>(BuildContext context, Route<T> route) {
    Navigator.push(context, route);
  }

  static mainPushNamedAndRemoveUntil<T extends Object?>(String routeName,
      {Object? argument}) {
    mainNavigationKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  static mainPushNamedAndRemoveUntilNcircle<T extends Object?>(String routeName,
      {Object? argument}) {
    mainNavigationKey.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false,arguments: argument);
  }

  static mainPopUntil<T extends Object?>() {
    mainNavigationKey.currentState?.popUntil((route) => route.isFirst);
  }

  static pushNamed<T extends Object?>(String routeName, {Object? argument}) {
    navigatorKeys[_navigationCubit.currSelectedItem]
        ?.currentState
        ?.pushNamed(routeName, arguments: argument);
  }

  static pushReplaceNamed<T extends Object?>(String routeName,
      {Object? argument}) {
    navigatorKeys[_navigationCubit.currSelectedItem]
        ?.currentState
        ?.pushReplacementNamed(routeName, arguments: argument);
  }

  static pushNamedAndRemoveUntil<T extends Object?>(String routeName,
      {Object? argument}) {
    navigatorKeys[_navigationCubit.currSelectedItem]
        ?.currentState
        ?.pushNamedAndRemoveUntil(routeName, (route) => false,
            arguments: argument);
  }

  static bool mainCanPop() {
    if (mainNavigationKey.currentState != null) {
      return mainNavigationKey.currentState!.canPop();
    } else {
      return false;
    }
  }

  static bool canPop() {
    if (navigatorKeys[_navigationCubit.currSelectedItem]?.currentState !=
        null) {
      return navigatorKeys[_navigationCubit.currSelectedItem]!
          .currentState!
          .canPop();
    } else {
      return false;
    }
  }
  static mainPop() {
    if (mainNavigationKey.currentState != null && mainNavigationKey.currentContext != null)
    {
      mainNavigationKey.currentState!.pop(mainNavigationKey.currentContext);
    }
  }
  static mainPopWithResult(dynamic result) {
    if (mainNavigationKey.currentState != null && mainNavigationKey.currentContext != null)
    {
      mainNavigationKey.currentState!.pop(result);
    }
  }
}
