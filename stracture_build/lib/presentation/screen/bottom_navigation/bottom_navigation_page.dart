import 'dart:async';
import 'dart:convert';

import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/download_size/download_size_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/navigation/navigation_state.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/site/location_tree_state.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/repository/site/location_tree_repository.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/scroll_to_hide/scroll_to_hide_widget.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/barcodescanner.dart';
import 'package:field/widgets/bottom_navigation_item/ABottomNavigationItem.dart';
import 'package:field/widgets/location_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../analytics/event_analytics.dart';
import '../../../bloc/dashboard/home_page_cubit.dart';
import '../../../bloc/download_size/download_size_state.dart';
import '../../../bloc/project_list/project_list_cubit.dart';
import '../../../data/model/project_vo.dart';
import '../../../data/model/qrcodedata_vo.dart';
import '../../../injection_container.dart';
import '../../../utils/constants.dart';
import '../../../utils/file_form_utility.dart';
import '../../../utils/global.dart';
import '../../../utils/qrcode_utils.dart';
import '../../../utils/store_preference.dart';
import '../../../widgets/a_progress_dialog.dart';
import '../../../widgets/download_size_dialog_widget.dart';
import '../../managers/image_constant.dart';
import '../../managers/routes_manager.dart';
import 'tab_navigator.dart';

class BottomNavigationPage extends StatefulWidget {
  BottomNavigationPage({Key? key}) : super(key: key);

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> with WidgetsBindingObserver {
  final _navigationCubit = getIt<NavigationCubit>();
  final _toolbarCubit = getIt<ToolbarCubit>();
  late AProgressDialog? aProgressDialog;
  final _navigatorCubit = getIt<FieldNavigatorCubit>();
  final _projectListCubit = getIt<ProjectListCubit>();

  @override
  void initState() {
    super.initState();
    aProgressDialog = AProgressDialog(context, isAnimationRequired: true, isWillPopScope: true);
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  Future<void> _selectTab(NavigationMenuItemType navigationMenuItemType, [BuildContext? context]) async {
    var screenName = "";
    if (navigationMenuItemType == NavigationMenuItemType.sites) {
      Project? selectedProject = await StorePreference.getSelectedProjectData();
      if (selectedProject == null || await _projectListCubit.isProjectLocationMarkedOffline(isNetWorkConnected())) {
        Navigator.pushNamed(context!, Routes.projectList, arguments: AConstants.projectListFromSite);
      } else {
        _navigationCubit.emitLocationTreeState();
      }
    } else if (_navigationCubit.currSelectedItem == navigationMenuItemType) {
      // pop to first route
      if (_navigationCubit.currSelectedItem != NavigationMenuItemType.models) {
        navigatorKeys[navigationMenuItemType]!.currentState!.popUntil((route) => route.isFirst);
        _toolbarCubit.updateSelectedItemByPosition(navigationMenuItemType);
      }
    } else if (navigationMenuItemType == NavigationMenuItemType.quality) {
      Project? selectedProject = await StorePreference.getSelectedProjectData();
      if (selectedProject == null) {
        Navigator.pushNamed(context!, Routes.projectList, arguments: AConstants.projectListFromQuality);
      } else {
        setSelectedTab(navigationMenuItemType);
        NavigationUtils.pushReplaceNamed(
          TabNavigatorRoutes.quality,
        );
      }
    } else {
      setSelectedTab(navigationMenuItemType);
      switch (navigationMenuItemType) {
        case NavigationMenuItemType.tasks:
          {
            NavigationUtils.pushReplaceNamed(
              TabNavigatorRoutes.tasks,
            );
          }
          break;
        case NavigationMenuItemType.home:
          {
            getIt<TaskActionCountCubit>().getTaskActionCount();
            screenName = FireBaseScreenName.home.value;
          }
          break;
        case NavigationMenuItemType.models:
          {
            NavigationUtils.pushReplaceNamed(
              TabNavigatorRoutes.models,
            );
          }
          break;
        case NavigationMenuItemType.sites:
          break;
        case NavigationMenuItemType.quality:
          break;
        case NavigationMenuItemType.files:
          break;
        case NavigationMenuItemType.settings:
          break;
        case NavigationMenuItemType.help:
          break;
        case NavigationMenuItemType.logout:
          break;
        case NavigationMenuItemType.more:
          break;
        case NavigationMenuItemType.close:
          break;
        case NavigationMenuItemType.scan:
          break;
      }
      if (screenName.isNotEmpty) {
        FireBaseEventAnalytics.setCurrentScreen(screenName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return BlocProvider(
      create: (_) => _navigatorCubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<NavigationCubit, FlowState>(
            listenWhen: (previous, current) => current is LocationTreeState,
            listener: (_, state) {
              if (state.runtimeType == LocationTreeState) {
                showLocationTreeDialog(context);
              }
            },
          ),
          BlocListener<FieldNavigatorCubit, FlowState>(
            listener: (_, state) async {
              if (state is SuccessState) {
                aProgressDialog?.dismiss();
                aProgressDialog?.dismiss();
                if (state.response["qrCodeType"] == QRCodeType.qrLocation) {
                  if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.sites) {
                    getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.sites);
                    getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.sites);
                  }
                  await Future.delayed(const Duration(milliseconds: 100));
                  NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.sitePlanView, argument: state.response["arguments"]);
                } else {
                  var map = state.response["arguments"];
                  map['isFrom'] = FromScreen.qrCode;
                  await FileFormUtility.showFormCreateDialog(context, frmViewUrl: map["url"], data: map, title: map["name"] ?? "");
                }
              } else if (state is ErrorState) {
                aProgressDialog?.dismiss();
                Log.d(state.message);
                if (state.code == 601 || state.code == 404) {
                  dynamic jsonResponse = jsonDecode(state.message);
                  String errorMsg = jsonResponse['msg'];
                  errorMsg = errorMsg.isNullOrEmpty() ? QrCodeUtility.getQrError(jsonResponse['key']) : errorMsg;
                  Utility.showAlertWithOk(context, errorMsg);
                } else {
                  Utility.showQRAlertDialog(context, state.message.isNullOrEmpty() ? context.toLocale!.lbl_invalid_qr : state.message);
                }
              } else if (state is LoadingState) {
                aProgressDialog?.show();
              }
            },
          ),
          BlocListener<DownloadSizeCubit, FlowState>(
              bloc: downloadSizeCubit,
              listener: (_, state) {
                if (state is SyncDownloadStartState) {
                  aProgressDialog = AProgressDialog(context, useSafeArea: true, isWillPopScope: true);
                  aProgressDialog?.show();
                } else if (state is SyncDownloadLimitState) {
                  aProgressDialog?.dismiss();
                  _showDownloadSizeLimitDialog(context, state.storage, state.displaySize);
                } else if (state is SyncDownloadErrorState) {
                  aProgressDialog?.dismiss();
                  _showDownloadSizeErrorDialog(context, state);
                } else {
                  aProgressDialog?.dismiss();
                }
              })
        ],
        child: WillPopScope(
          onWillPop: () async {
            final isFirstRouteInCurrentTab = !await navigatorKeys[_navigationCubit.currSelectedItem]!.currentState!.maybePop();
            if (isFirstRouteInCurrentTab) {
              if (_navigationCubit.currSelectedItem != NavigationMenuItemType.home) {
                _selectTab(NavigationMenuItemType.home);
                return false;
              }
            } else {
              _toolbarCubit.updateSelectedItemByPosition(_navigationCubit.currSelectedItem);
            }
            return isFirstRouteInCurrentTab;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<NavigationCubit, FlowState>(
              buildWhen: (previous, current) {
                return current is BottomNavigationToggleState;
              },
              builder: (context, stateBottomNavigationToggle) {
                return GestureDetector(
                    onPanDown: _navigationCubit.moreBottomBarView
                        ? (onPanDownValue) {
                            if (_navigationCubit.moreBottomBarView) {
                              _navigationCubit.toggleMoreBottomBarView();
                            }
                          }
                        : null,
                    child: _buildStackForBottomNavigation());
              },
            ),
            floatingActionButtonLocation: _buildFloatingActionButtonLocation(),
            floatingActionButton: BlocBuilder<NavigationCubit, FlowState>(buildWhen: (previous, current) {
              return current is BottomNavigationToggleState;
            }, builder: (context, stateBottomNavigationToggle) {
              return _navigationCubit.moreBottomBarView ? SizedBox() : const BarCodeScannerWidget();
            }),
            bottomNavigationBar: isKeyboardOpen ? null : ABottomNavigationBar(key: Key('bottom_navigation_bar_test_key')),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeMetrics() {
    Orientation orientation = MediaQueryData.fromWindow(WidgetsBinding.instance.window).orientation;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (MediaQueryData.fromWindow(WidgetsBinding.instance.window).orientation != orientation) {
        _navigationCubit.initData(isFromOrientation: true);
      }
    });
  }

  FloatingActionButtonLocation _buildFloatingActionButtonLocation() {
    if (Utility.isTablet) {
      return FloatingActionButtonLocation.startDocked;
    } else {
      // return FloatingActionButtonLocation.centerDocked;
      return FloatingActionButtonLocation.startDocked;
    }
  }

  Widget _buildStackForBottomNavigation() {
    return BlocBuilder<NavigationCubit, FlowState>(
      buildWhen: (previous, current) => (current is BottomNavigationMenuListState || current is BottomNavigationToggleState),
      builder: (context, state) {
        var menuList = _navigationCubit.menuListPrimary + _navigationCubit.menuListSecondary;
        try {
          menuList.remove(NavigationMenuItemType.close);
          menuList.remove(NavigationMenuItemType.more);
        } catch (e) {
          menuList.remove(NavigationMenuItemType.more);
        }
        List<Widget> widgets = List.empty(growable: true);
        for (var element in menuList.sublist(_navigationCubit.moreBottomBarView ? 1 : 0)) {
          widgets.add(_buildOffstageNavigator(element));
        }
        return Stack(children: widgets);
      },
    );
  }

  Widget _buildOffstageNavigator(NavigationMenuItemType tabItem) {
    return Offstage(
      offstage: _navigationCubit.currSelectedItem != tabItem,
      child: TabNavigator(navigatorKey: navigatorKeys[tabItem], tabItem: tabItem),
    );
  }

  void setSelectedTab(NavigationMenuItemType selectedMenuItemType) {
    _navigationCubit.updateSelectedItemByType(selectedMenuItemType);
    _toolbarCubit.updateSelectedItemByPosition(selectedMenuItemType);
  }

  void showLocationTreeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          Map<String, dynamic> arguments = {};
          arguments['isFrom'] = LocationTreeViewFrom.projectList;
          return ScaffoldMessenger(child: Builder(builder: (context) {
            return Scaffold(backgroundColor: Colors.transparent, body: LocationTreeWidget(arguments));
          }));
        }).then((value) async {
      if (value != null) {
        setSelectedTab(NavigationMenuItemType.sites);
        await Future.delayed(const Duration(milliseconds: 100));
        // NavigationUtils.pushReplaceNamed(TabNavigatorRoutes.sitePlanView, argument: value);
        NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.sitePlanView, argument: value);
      }
    });
  }

  void onSitesBottomTabClicked(SiteLocation lastLocation) {
    QRCodeDataVo? qrObj = QrCodeUtility.getQrCodeDataVoFormLocation(lastLocation);
    if (qrObj != null) {
      _navigatorCubit.checkQRCodePermission(qrObj);
    }
  }

  _showDownloadSizeLimitDialog(BuildContext context, storage, displaySize) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: DownloadSizeLimit(
              storage: storage,
              displaySize: displaySize,
            ),
          );
        });
  }

  _showDownloadSizeErrorDialog(BuildContext context, state) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: DownloadSizeError(
              state: state,
            ),
          );
        });
  }
}

class ABottomNavigationBar extends StatefulWidget {
  const ABottomNavigationBar({super.key});

  @override
  State<ABottomNavigationBar> createState() => _ABottomNavigationBarState();
}

class _ABottomNavigationBarState extends State<ABottomNavigationBar> {
  final navigationCubit = getIt<NavigationCubit>();
  final toolbarCubit = getIt<ToolbarCubit>();
  final projectListCubit = getIt<ProjectListCubit>();

  Future<void> _selectTab(NavigationMenuItemType navigationMenuItemType, [BuildContext? context]) async {
    if (navigationMenuItemType == NavigationMenuItemType.sites) {
      Project? selectedProject = await StorePreference.getSelectedProjectData();
      if (selectedProject == null || await projectListCubit.isProjectLocationMarkedOffline(isNetWorkConnected())) {
        Navigator.pushNamed(context!, Routes.projectList, arguments: AConstants.projectListFromSite);
      } else {
        navigationCubit.emitLocationTreeState();
      }
    } else if (navigationCubit.currSelectedItem == navigationMenuItemType) {
      // pop to first route
      if (navigationCubit.currSelectedItem != NavigationMenuItemType.models) {
        navigatorKeys[navigationMenuItemType]!.currentState!.popUntil((route) => route.isFirst);
        toolbarCubit.updateSelectedItemByPosition(navigationMenuItemType);
      }
    } else if (navigationMenuItemType == NavigationMenuItemType.quality) {
      Project? selectedProject = await StorePreference.getSelectedProjectData();
      if (selectedProject == null) {
        Navigator.pushNamed(context!, Routes.projectList, arguments: AConstants.projectListFromQuality);
      } else {
        setSelectedTab(navigationMenuItemType);
        NavigationUtils.pushReplaceNamed(
          TabNavigatorRoutes.quality,
        );
      }
    } else {
      setSelectedTab(navigationMenuItemType);
      switch (navigationMenuItemType) {
        case NavigationMenuItemType.tasks:
          {
            NavigationUtils.pushReplaceNamed(
              TabNavigatorRoutes.tasks,
            );
          }
          break;
        case NavigationMenuItemType.home:
          {
            getIt<RecentLocationCubit>().initData();
            getIt<TaskActionCountCubit>().getTaskActionCount();
          }
          break;
        case NavigationMenuItemType.models:
          {
            NavigationUtils.pushReplaceNamed(
              TabNavigatorRoutes.models,
            );
          }
          break;
        case NavigationMenuItemType.sites:
          break;
        case NavigationMenuItemType.quality:
          break;
        case NavigationMenuItemType.files:
          break;
        case NavigationMenuItemType.settings:
          break;
        case NavigationMenuItemType.help:
          break;
        case NavigationMenuItemType.logout:
          break;
        case NavigationMenuItemType.more:
          break;
        case NavigationMenuItemType.close:
          break;
        case NavigationMenuItemType.scan:
          break;
      }
    }
  }

  void setSelectedTab(NavigationMenuItemType selectedMenuItemType) {
    navigationCubit.updateSelectedItemByType(selectedMenuItemType);
    toolbarCubit.updateSelectedItemByPosition(selectedMenuItemType);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, FlowState>(
      buildWhen: (previous, current) {
        return current is BottomNavigationToggleState;
      },
      builder: (context, stateBottomNavigationToggle) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (navigationCubit.moreBottomBarView) moreOptionMenuContainer(),
            SafeArea(
              child: ScrollToHideWidget(
                controller: getIt<ScrollController>(),
                animationType: AnimationType.DOWN,
                preferredWidgetSize: const Size.fromHeight(kToolbarHeight + 5),
                child: OrientationBuilder(builder: (context, orientation1) {
                  return BottomAppBar(
                    padding: EdgeInsetsDirectional.only(start: navigationCubit.moreBottomBarView ? 0 : 55),
                    color: AColors.aPrimaryColor,
                    elevation: 0,
                    child: BlocBuilder<NavigationCubit, FlowState>(
                      buildWhen: (previous, current) {
                        return current is BottomNavigationMenuListState;
                      },
                      builder: (context, state) {
                        if (state is BottomNavigationMenuListState) {
                          List<NavigationMenuItemType> menuList = [];
                          menuList.addAll(state.menuList);
                          navigationCubit.menuListAll = [];
                          List<ABottomNavigationItem> menuItems = List.empty(growable: true);
                          for (var i = 0; i < menuList.length; i++) {
                            menuItems.add(_buildItem(menuList[i], context));
                          }

                          if (menuItems.isNotEmpty) {
                            return BottomNavigationBar(
                              key: state.bottomNavigationKey,
                              elevation: 0.0,
                              type: BottomNavigationBarType.fixed,
                              items: menuItems,
                              onTap: (index) async {
                                NavigationMenuItemType navigationMenuItemType = navigationCubit.menuListPrimary[index];
                                if (navigationMenuItemType == NavigationMenuItemType.tasks || navigationMenuItemType == NavigationMenuItemType.quality) {
                                  if (!isNetWorkConnected()) {
                                    return;
                                  }
                                }
                                if ((navigationMenuItemType == NavigationMenuItemType.more || navigationMenuItemType == NavigationMenuItemType.close)) {
                                  navigationCubit.toggleMoreBottomBarView();
                                } else if ((navigationMenuItemType == NavigationMenuItemType.scan)) {
                                  if (navigationCubit.moreBottomBarView) {
                                    navigationCubit.toggleMoreBottomBarView();
                                  }
                                  /*BarCodeScannerWidgetState.scanQR(context);*/
                                  final _fieldNavigatorCubit = BlocProvider.of<FieldNavigatorCubit>(context);

                                  _fieldNavigatorCubit.scanQR(context.toLocale!.lbl_btn_cancel);
                                } else {
                                  if (navigationCubit.moreBottomBarView) {
                                    navigationCubit.toggleMoreBottomBarView();
                                  }
                                  _selectTab(navigationMenuItemType, context);
                                }
                              },
                              currentIndex: state.selectedItemIndex.isNegative ? 0 : state.selectedItemIndex,
                              backgroundColor: AColors.aPrimaryColor,
                              selectedItemColor: Colors.white,
                              unselectedItemColor: Colors.grey,
                            );
                          }
                        }
                        return Container();
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget moreOptionMenuContainer() {
    return Container(
      key: Key('key_more_option_menu_container'),
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: AColors.optionMenuBottomBar,
        border: Border(top: BorderSide(color: AColors.aPrimaryColor, width: 4)),
      ),
      height: kBottomNavigationBarHeight + 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...List<Widget>.generate(
              (navigationCubit.menuListPrimary.length) - (navigationCubit.menuListSecondary.length),
              (index) => Expanded(
                    child: SizedBox(),
                  )).toList(),
          ...secondaryContainerList()
        ],
      ),
    );
  }

  List<Widget> secondaryContainerList() {
    return List.generate(
        navigationCubit.menuListSecondary.length,
        (index) => Expanded(
              child: InkWell(
                  key: Key(navigationCubit.menuListSecondary[index].value),
                  onTap: () {
                    if (navigationCubit.moreBottomBarView) {
                      navigationCubit.toggleMoreBottomBarView();
                    }
                    NavigationMenuItemType navigationMenuItemType = navigationCubit.menuListSecondary[index];
                    if (navigationMenuItemType == NavigationMenuItemType.tasks && !isNetWorkConnected()) {
                      return;
                    } else
                      _selectTab(navigationCubit.menuListSecondary[index], context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Icon(navigationCubit.menuListSecondary[index].icon, color: navigationCubit.menuListSecondary[index] == navigationCubit.currSelectedItem ? Colors.white : Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          _buildLabel(context, navigationCubit.menuListSecondary[index])!,
                          style: TextStyle(color: navigationCubit.menuListSecondary[index] == navigationCubit.currSelectedItem ? Colors.white : Colors.grey),
                        )
                      ],
                    ),
                  )),
            ));
  }

  ABottomNavigationItem _buildItem(NavigationMenuItemType navigationMenuItemType, BuildContext context) {
    return ABottomNavigationItem(
      icon: _buildIcon(context, navigationMenuItemType),
      label: _buildLabel(context, navigationMenuItemType),
    );
  }

  Widget _buildIcon(BuildContext context, NavigationMenuItemType navigationMenuItemType) {
    switch (navigationMenuItemType) {
      case NavigationMenuItemType.sites:
        return ImageIcon(
          AssetImage(AImageConstants.floorPlan),
          size: 22,
          key: Key(navigationMenuItemType.value),
        );
      case NavigationMenuItemType.home:
        break;
      case NavigationMenuItemType.models:
        break;
      case NavigationMenuItemType.quality:
        break;
      case NavigationMenuItemType.files:
        break;
      case NavigationMenuItemType.tasks:
        break;
      case NavigationMenuItemType.settings:
        break;
      case NavigationMenuItemType.help:
        break;
      case NavigationMenuItemType.logout:
        break;
      case NavigationMenuItemType.more:
        break;
      case NavigationMenuItemType.close:
        break;
      case NavigationMenuItemType.scan:
        break;
    }
    return Icon(
      navigationMenuItemType.icon,
      size: 22,
      key: Key(navigationMenuItemType.value),
    );
  }

  String? _buildLabel(BuildContext context, NavigationMenuItemType navigationMenuItemType) {
    switch (navigationMenuItemType) {
      case NavigationMenuItemType.home:
        return context.toLocale!.home;
      case NavigationMenuItemType.sites:
        return context.toLocale!.sites;
      case NavigationMenuItemType.quality:
        return context.toLocale!.quality;
      case NavigationMenuItemType.models:
        return context.toLocale!.models;
      case NavigationMenuItemType.files:
        return context.toLocale!.files;
      case NavigationMenuItemType.tasks:
        return context.toLocale!.tasks;
      case NavigationMenuItemType.settings:
        return context.toLocale!.settings;
      case NavigationMenuItemType.help:
        return context.toLocale!.help;
      case NavigationMenuItemType.logout:
        return context.toLocale!.logout;
      case NavigationMenuItemType.more:
        return context.toLocale!.more;
      case NavigationMenuItemType.close:
        return context.toLocale!.lbl_btn_close;
      case NavigationMenuItemType.scan:
        return context.toLocale!.lbl_scan;
    }
  }
}
