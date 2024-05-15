import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/screen/appbar/dashboard_appbar.dart';
import 'package:field/presentation/scroll_to_hide/scroll_to_hide_widget.dart';
import 'package:flutter/material.dart';

import '../../injection_container.dart';
import 'bottom_navigation/bottom_navigation_page.dart';
import 'sidebar_menu_screen.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: AColors.aPrimaryColor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white,AColors.aPrimaryColor],
          stops: [0.5, 0.5],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          drawer: const SidebarMenuWidget(),
          appBar: ScrollToHideWidget(
            enableOpacity: true,
            controller: getIt<ScrollController>(),
            child: DashboardAppBar(
              scaffoldKey: _scaffoldKey,
            ),
          ),
          drawerEnableOpenDragGesture: true,
          body: BottomNavigationPage(),
        ),
      ),
    );
  }
}
