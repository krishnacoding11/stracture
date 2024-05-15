import 'package:field/data/model/online_model_viewer_arguments.dart';
import 'package:field/presentation/screen/bottom_navigation/files/folders/folder_page.dart';
import 'package:field/presentation/screen/online_model_viewer/online_model_viewer_screen.dart';
import 'package:flutter/material.dart';

import '../../../bloc/navigation/navigation_cubit.dart';
import '../quality/quality_plan_listing_screen.dart';
import '../site_routes/site_plan_viewer_screen.dart';
import '../task_listing/task_listing_screen.dart';
import 'files/folders/files/file_sub_page.dart';
import 'models/models_list_screen.dart';
import 'navigation_route_observer.dart';
import 'tab_navigator/tab_navigator_page.dart';

class TabNavigator extends StatefulWidget {
  const TabNavigator({Key? key, required this.navigatorKey, required this.tabItem}) : super(key: key);

  final GlobalKey<NavigatorState>? navigatorKey;
  final NavigationMenuItemType tabItem;

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> with RouteAware {
  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, RouteSettings routeSettings) {
    return {
      TabNavigatorRoutes.home: (context) => TabNavigatorPage(
            tabItem: widget.tabItem,
          ),
      TabNavigatorRoutes.folder: (context) => const FolderPage(),
      TabNavigatorRoutes.folderSub: (context) => const FolderSubPage(),
      TabNavigatorRoutes.sitePlanView: (context) => SitePlanViewerScreen(
            arguments: routeSettings.arguments,
          ),
      TabNavigatorRoutes.models: (context) => ModelsListPage(
            isFavourites: false,
            isShowSideToolBar: false,
            isFromHome: false,
          ),
      TabNavigatorRoutes.onlineModelViewer: (context) => OnlineModelViewerScreen(
            onlineModelViewerArguments: routeSettings.arguments as OnlineModelViewerArguments,
          ),
      TabNavigatorRoutes.tasks: (context) => TaskListingScreen(
            arguments: routeSettings.arguments,
          ),
      TabNavigatorRoutes.quality: (context) => const QualityListingScreen(),
      TabNavigatorRoutes.file: (context) => Text("Files"),
      TabNavigatorRoutes.form: (context) => Text("Forms"),
      TabNavigatorRoutes.more: (context) => Text("More"),
      TabNavigatorRoutes.setting: (context) => Text("Setting"),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: TabNavigatorRoutes.home,
      observers: [NavigationRouteObserver()],
      onGenerateRoute: (routeSettings) {
        final routeBuilders = _routeBuilders(context, routeSettings);
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }
}

class TabNavigatorRoutes {
  //declare all the internal page navigation routes here
  static const String home = '/';
  static const String folder = '/folder';
  static const String folderSub = '/FileSub';
  static const String sitePlanView = '/sitePlanView';
  static const String models = '/models';
  static const String onlineModelViewer = 'onlineModelViewer';
  static const String tasks = '/tasks';
  static const String quality = '/quality';
  static const String file = '/file';
  static const String form = '/form';
  static const String more = '/more';
  static const String setting = '/setting';
}
