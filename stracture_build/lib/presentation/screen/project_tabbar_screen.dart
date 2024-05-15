import 'dart:async';

import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/screen/bottom_navigation/tab_navigator.dart';
import 'package:field/presentation/screen/dashboard.dart';
import 'package:field/presentation/screen/project_list.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/widgets/barcodescanner.dart';
import 'package:flutter/material.dart';

import '../../bloc/dashboard/home_page_cubit.dart';
import '../../analytics/event_analytics.dart';
import '../../utils/utils.dart';
import '../managers/font_manager.dart';
import '../managers/routes_manager.dart';

class ProjectTabbar extends StatefulWidget {
  final dynamic arguments;

  const ProjectTabbar({this.arguments, Key? key}) : super(key: key);

  @override
  State<ProjectTabbar> createState() => _ProjectTabbarState();
}

class _ProjectTabbarState extends State<ProjectTabbar>
    with SingleTickerProviderStateMixin {
  final StreamController<int> _childStreamController =
      StreamController<int>.broadcast();

  late TabController _tabController;
  final ScrollController scrollController = ScrollController();
  final FocusNode _searchAllFocusNode = FocusNode();
  final FocusNode _searchFavFocusNode = FocusNode();
  var index = 0;
  final TextEditingController searchAllProjectController =
      TextEditingController();
  final TextEditingController searchFavProjectController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: index);
    getSelectedProjectTab().then((value) {
      _tabController.index = index;
      _tabController.animation?.addListener(_setSelectedProjectTab);
    });
    FireBaseEventAnalytics.setCurrentScreen(FireBaseScreenName.project.value);
  }

  Future<int> getSelectedProjectTab() async {
    index = await StorePreference.getSelectedProjectTab();
    return index;
  }

  Future<void> _setSelectedProjectTab() async {
    final aniValue = _tabController.animation?.value;
    if (aniValue! > 0.5 && index != 1) {
      unfocusAllProject();
      await StorePreference.setSelectedProjectsTab(1);
      unfocusFavProject();
    } else if (aniValue <= 0.5 && index != 0) {
      unfocusFavProject();
      await StorePreference.setSelectedProjectsTab(0);
      unfocusAllProject();
    }
  }

  unfocusAllProject() {
    _searchAllFocusNode.unfocus();
    searchAllProjectController.text='';
  }

  unfocusFavProject() {
    _searchFavFocusNode.unfocus();
    searchFavProjectController.text='';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tabBar = TabBar(
      controller: _tabController,
      labelColor: AColors.black,
      indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: Colors.deepOrange),
          insets: EdgeInsets.symmetric(horizontal: 0)),
      indicatorColor: Colors.orange,
      tabs:  [
        Tab(
          text: context.toLocale!.lbl_all,
          height: 40,
        ),
        Tab(
          text: context.toLocale!.lbl_favorite,
          height: 40,
        ),
      ],
    );
    return Scaffold(
      body: Container(
        color: AColors.white,
        child: SafeArea(
          child: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverSafeArea(
                    top: false,
                    bottom: false,
                    sliver: SliverAppBar(
                      title:  Text(context.toLocale!.lbl_projects),
                      titleTextStyle: const TextStyle(
                        color: AColors.black,
                        fontFamily: "Sofia",
                        fontWeight: AFontWight.medium,
                        fontSize: 20,
                      ),
                      backgroundColor: AColors.white,
                      floating: true,
                      pinned: true,
                      snap: true,
                      primary: true,
                      elevation: 1,
                      forceElevated: innerBoxIsScrolled,
                      bottom: tabBar,
                      leading: InkWell(
                        onTap: () {
                          _childStreamController.add(0);
                          if (widget.arguments != null && (widget.arguments == AConstants.userFirstLogin || widget.arguments == AConstants.projectSelection)) {
                            NavigationUtils.mainPushAndRemoveUntilWithoutAnimation(const DashboardWidget());
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                ProjectList(
                  isFavourites: false,
                  screenName: "All",
                  stream: _childStreamController.stream,
                  scrollController: scrollController,
                  searchFocusNode: _searchAllFocusNode,
                  onBack: selectProject,
                  searchProjectController: searchAllProjectController,
                  tabController: _tabController,
                ),
                ProjectList(
                  isFavourites: true,
                  screenName: "Favourites",
                  stream: _childStreamController.stream,
                  scrollController: scrollController,
                  searchFocusNode: _searchFavFocusNode,
                  onBack: selectProject,
                  searchProjectController: searchFavProjectController,
                  tabController: _tabController,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: _buildFloatingActionButtonLocation(),
      floatingActionButton: const BarCodeScannerWidget(qrFromProject: true),
      //TODO: Removed for first release
      /*bottomNavigationBar: ScrollToHideWidget(
          controller: scrollController,
          animationType: AnimationType.DOWN,
          preferredWidgetSize: const Size.fromHeight(kToolbarHeight),
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: BottomAppBar(
              color: AColors.aPrimaryColor,
              elevation: 0,
              child: const Text(" "),
            ),
          ),
        ),*/
    );
  }

  void selectProject() async {
    if (widget.arguments != null &&
        (widget.arguments == AConstants.userFirstLogin ||
            widget.arguments == AConstants.projectSelection || widget.arguments =="sideMenu")) {
      NavigationUtils.mainPushAndRemoveUntilWithoutAnimation(
          const DashboardWidget());
    } else if (widget.arguments != null &&
        widget.arguments == AConstants.projectListFromSite) {
      Navigator.popUntil(
          NavigationUtils.mainNavigationKey.currentState!.context,
          (route) => route.isFirst);
      getIt<NavigationCubit>().emitLocationTreeState();
    } else if (widget.arguments != null && widget.arguments == AConstants.projectListFromQuality) {
        Navigator.popUntil(NavigationUtils.mainNavigationKey.currentState!.context,(route) => route.isFirst);
        await getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.quality);
        NavigationUtils.pushReplaceNamed( TabNavigatorRoutes.quality,);
    } else if(widget.arguments != null && widget.arguments == AConstants.homePage){
      Navigator.popUntil(NavigationUtils.mainNavigationKey.currentState!.context,(route) => route.isFirst);
     // final homePageCubit = getIt<HomePageCubit>();
      //await homePageCubit.initData();
    }
    else {
      Navigator.popUntil(
          NavigationUtils.mainNavigationKey.currentState!.context,
          (route) => route.isFirst);
      await getIt<NavigationCubit>()
          .updateSelectedItemByType(NavigationMenuItemType.home);

    }
  }

  FloatingActionButtonLocation _buildFloatingActionButtonLocation() {
    if (Utility.isTablet) {
      return FloatingActionButtonLocation.startDocked;
    } else {
      return FloatingActionButtonLocation.centerDocked;
    }
  }
}
