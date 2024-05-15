import 'package:field/presentation/screen/bottom_navigation/models/models_list_screen.dart';
import 'package:field/presentation/screen/help/help_page.dart';
import 'package:field/presentation/screen/quality/quality_plan_listing_screen.dart';
import 'package:field/presentation/screen/site_routes/site_plan_viewer_screen.dart';
import 'package:flutter/material.dart';

import '../../../../bloc/navigation/navigation_cubit.dart';
import '../../homepage/project_dashboard.dart';
import '../../task_listing/task_listing_screen.dart';
import '../../user_profile_setting/user_profile_screen.dart';

class TabNavigatorPage extends StatelessWidget {
  final NavigationMenuItemType tabItem;

  const TabNavigatorPage({
    Key? key,
    required this.tabItem,
  }) : super(key: key);

  Map<NavigationMenuItemType, Widget> _getBottomNavigationPages() {
    return {
      NavigationMenuItemType.home: const ProjectDashboard(),
      NavigationMenuItemType.sites: const SitePlanViewerScreen(),
      NavigationMenuItemType.quality: const QualityListingScreen(),
      NavigationMenuItemType.models: ModelsListPage(
        isFavourites: false,
        isShowSideToolBar: false,
        isFromHome: true,
      ),
      NavigationMenuItemType.files: const Text("Files"),
      NavigationMenuItemType.tasks: const TaskListingScreen(),
      NavigationMenuItemType.settings: const UserProfileSettingScreen(),
      NavigationMenuItemType.help: const HelpPage(),
      NavigationMenuItemType.more: const Text("More"),
      NavigationMenuItemType.logout: const Text("Logout"),
    };
  }

  @override
  Widget build(BuildContext context) {
    return _getBottomNavigationPages()[tabItem] ?? const SizedBox();
  }
}
