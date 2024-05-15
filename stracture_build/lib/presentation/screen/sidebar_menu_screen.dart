import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as model;
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:field/widgets/sidebar/sidebar_header_widget.dart';
import 'package:field/widgets/sidebar/sidebar_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../analytics/event_analytics.dart';
import '../../bloc/pdf_tron/pdf_tron_cubit.dart' as pdf;
import '../../bloc/sidebar/sidebar_cubit.dart';
import '../../bloc/sidebar/sidebar_state.dart';
import '../../widgets/normaltext.dart';
import '../../widgets/progressbar.dart';
import '../managers/color_manager.dart';
import '../managers/routes_manager.dart';

class SidebarMenuWidget extends StatefulWidget {
  const SidebarMenuWidget({Key? key}) : super(key: key);

  @override
  State<SidebarMenuWidget> createState() => _SidebarMenuWidgetState();
}

class _SidebarMenuWidgetState extends State<SidebarMenuWidget> {
  final SidebarCubit _sidebarCubit = di.getIt<SidebarCubit>();
  final pdf.PdfTronCubit pdfTronCubit = di.getIt<pdf.PdfTronCubit>();

  @override
  void initState() {
    super.initState();
    Utility.closeBanner();
    context.closeKeyboard();
    _sidebarCubit.initData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: ((AppBar().preferredSize.height) + (MediaQuery.of(context).viewPadding.top)), bottom: AppBar().preferredSize.height),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: 10.0),
            child: _getSidebarMenuWidget(context),
          ),
          PositionedDirectional(
            end: -15,
            top: 15,
            child: FloatingActionButton(
              key: const Key("drawerClosBtn"),
              backgroundColor: AColors.themeBlueColor,
              elevation: 8,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.chevron_left,
                color: AColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSidebarMenuWidget(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: AColors.aPrimaryColor,
          borderRadius: const BorderRadiusDirectional.only(
            topEnd: Radius.circular(20.0),
            bottomEnd: Radius.circular(20.0),
          ),
        ),
        child: BlocBuilder<SidebarCubit, FlowState>(
          builder: (context, state) {
            if (state is UserProfileSidebarState) {
              return Column(
                children: [
                  _getHeaderWidget(context, state),
                  const SizedBox(
                    height: 20,
                  ),
                  Flexible(
                    child: _getMenuListWidget(context),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _getFooterWidget(context),
                ],
              );
            } else if (state is LoadingState || state is InitialState) {
              return Center(
                child: ACircularProgress(
                  color: AColors.greyColor,
                ),
              );
            } else if (state is ErrorState) {
              return _getLoadErrorWidget(context, state);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _getHeaderWidget(BuildContext context, UserProfileSidebarState state) {
    return ASidebarHeaderWidget(
      key: const Key("SidebarHeaderWidgetKey"),
      username: state.userFirstname,
      imageUrl: state.userImageUri,
      httpHeaders: state.headerData,
      isOnline: _sidebarCubit.isOnline,
      offlineFile: _sidebarCubit.offlineUserImageFile,
    );
  }

  Widget _getFooterWidget(BuildContext context) {
    return Column(
      key: const Key("SidebarFooterWidgetKey"),
      children: [
        ADividerWidget(key: const Key("FooterDividerKey"), thickness: 1),
        Visibility(
          // TODO FR-732 visibility off due to this case for alpha release
          visible: false,
          child: ASidebarMenuWidget(
            key: const Key("menu_lastsyncon"),
            text: context.toLocale!.lbl_sidebar_menu_last_synced("10 mins"),
            icon: Icons.sync,
          ),
        ),
      ],
    );
  }

  Widget _getMenuListWidget(BuildContext context) {
    var menuList = _sidebarCubit.getSidebarMenuList();
    return ListView.builder(
        key: const Key("MenuListKey"),
        reverse: false,
        shrinkWrap: true,
        itemCount: menuList.length,
        itemBuilder: (context, index) {
          SidebarMenuItemType itemType = menuList[index];
          return ASidebarMenuWidget(
            key: Key("menu_{$itemType.name}"),
            text: _getMenuLocaleName(context, itemType),
            icon: itemType.icon,
            onTap: () => selectItem(context, itemType),
          );
        });
  }

  String _getMenuLocaleName(BuildContext context, SidebarMenuItemType item) {
    switch (item) {
      case SidebarMenuItemType.projects:
        return context.toLocale!.lbl_sidebar_menu_projects;
      case SidebarMenuItemType.tasks:
        return context.toLocale!.lbl_task;
      case SidebarMenuItemType.settings:
        return context.toLocale!.lbl_sidebar_menu_settings;
      case SidebarMenuItemType.help:
        return context.toLocale!.lbl_sidebar_menu_help;
      case SidebarMenuItemType.about:
        return context.toLocale!.lbl_sidebar_menu_about;
      case SidebarMenuItemType.logout:
        return context.toLocale!.lbl_sidebar_menu_logout;
      default:
        return "";
    }
  }

  Widget _getLoadErrorWidget(BuildContext context, ErrorState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NormalTextWidget(
            key: const Key("ErrorTextViewKey"),
            state.message,
            fontWeight: FontWeight.normal,
            color: AColors.white,
          ),
        ],
      ),
    );
  }

  final model.OnlineModelViewerCubit _onlineModelViewerCubit = di.getIt<model.OnlineModelViewerCubit>();

  void selectItem(BuildContext context, SidebarMenuItemType item) {
    var screenName = "";
    Navigator.of(context).pop();
    switch (item) {
      case SidebarMenuItemType.projects:
        if (pdfTronCubit.selectedCalibration != null) {
          _onlineModelViewerCubit.resetPdfTronVisibility(false, pdfTronCubit.selectedCalibration!.fileName, false);
        }
        screenName = FireBaseScreenName.project.value;
        NavigationUtils.mainPushNamed(context, Routes.projectList, argument: "sideMenu");
        break;
      case SidebarMenuItemType.tasks:
        NavigationUtils.mainPushNamed(context, Routes.tasks);
        break;
      case SidebarMenuItemType.settings:
        NavigationUtils.mainPushNamed(context, Routes.settings);
        screenName = FireBaseScreenName.setting.value;
        break;
      case SidebarMenuItemType.help:
        NavigationUtils.mainPushNamed(context, Routes.help);
        break;
      case SidebarMenuItemType.about:
        NavigationUtils.mainPushNamed(context, Routes.about);
        break;
      case SidebarMenuItemType.logout:
        if (isNetWorkConnected()) {
          Utility.closeBanner();
          _sidebarCubit.onLogoutClick();
          FireBaseEventAnalytics.setEvent(FireBaseEventType.logOut, FireBaseFromScreen.settings, bIncludeProjectName: true);
          NavigationUtils.mainPushReplacementNamed(Routes.onboardingLogin);
        } else {
          context.showSnack(context.toLocale!.error_message_logout_offline);
        }
        break;
      default:
        NavigationUtils.mainPushReplacementNamed(Routes.dashboard);
        break;
    }
    if (screenName.isNotEmpty) {
      FireBaseEventAnalytics.setCurrentScreen(screenName);
    }
  }
}
