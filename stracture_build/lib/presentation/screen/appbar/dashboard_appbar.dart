import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as onlineViewerCubit;
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/sync/sync_state.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_state.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_offline_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/screen/toolbar/dashboard_toolbar.dart';
import 'package:field/presentation/screen/user_profile_setting/cbim_settings_dialog.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/global.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/tooltip_dialog/tooltip_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../logger/logger.dart';
import '../../../widgets/normaltext.dart';
import '../../../widgets/progressbar.dart';
import '../../managers/font_manager.dart';
import '../../managers/image_constant.dart';
import '../user_profile_setting/cbim_settings_dialog.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DashboardAppBar({super.key, required this.scaffoldKey});

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _DashboardAppBarState extends State<DashboardAppBar> with TickerProviderStateMixin {
  late SyncCubit _syncCubit;
  final _navigationCubit = getIt<NavigationCubit>();
  final UserProfileSettingOfflineCubit _userProfileSettingOfflineCubit = getIt<UserProfileSettingOfflineCubit>();
  final TooltipController _tooltipController = TooltipController();
  final TooltipController _tooltipMoreController = TooltipController();
  late ToolbarCubit _toolBarCubit;
  final Tween<double> turnsTween = Tween<double>(
    begin: 1,
    end: 0,
  );
  AnimationController? _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _syncCubit = context.read<SyncCubit>();
    _toolBarCubit = getIt<ToolbarCubit>();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    FireBaseEventAnalytics.setUserProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black26,
            width: 1,
          ),
        ),
      ),
      child: AppBar(
        elevation: 0,
        backgroundColor: AColors.white,
        title: DashboardToolbar(),
        centerTitle: true,
        leading: BlocBuilder<ToolbarCubit, FlowState>(
          builder: (context, state) {
            if (state is ToolbarNavigationItemSelectedState && NavigationUtils.canPop() && (state.navigationMenuItemType != NavigationMenuItemType.quality && state.navigationMenuItemType != NavigationMenuItemType.models)) {
              return IconButton(
                icon: Icon(Icons.arrow_back, color: AColors.grColorDark, size: 22),
                onPressed: () async {
                  navigatorKeys[state.navigationMenuItemType]!.currentState!.pop();
                },
              );
            } else {
              return IconButton(
                icon: Icon(Icons.menu, color: AColors.grColorDark, size: 22),
                onPressed: () {
                  widget.scaffoldKey.currentState?.openDrawer();
                  if (_navigationCubit.moreBottomBarView) {
                    _navigationCubit.toggleMoreBottomBarView();
                  }
                },
              );
            }
          },
        ),
        actions: [
          Visibility(
            // TODO FR-732 visibility off due to this case, will remove after first release
            visible: false,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, color: AColors.grColorDark, size: 22),
            ),
          ),
          BlocBuilder<ToolbarCubit, FlowState>(
            builder: (context, state) {
              return Visibility(
                // TODO FR-732 visibility off due to this case, will remove after first release
                visible: false,
                //visible: state is ToolbarNavigationItemSelectedState && state.navigationMenuItemType != NavigationMenuItemType.models,
                child: TooltipDialog(
                  toolTipContent: Container(
                    // constraints: const BoxConstraints(minWidth: 300, maxWidth: 400, minHeight: 200, maxHeight: 500),
                    height: 350,
                    width: 400,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: Center(
                            child: NormalTextWidget(context.toLocale!.notification_header_Task_center, fontWeight: AFontWight.regular, color: AColors.iconGreyColor, fontSize: 14),
                          ),
                        ),
                        BlocBuilder<ToolbarCubit, FlowState>(builder: (context, state) {
                          return Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                padding: const EdgeInsets.only(left: 8.0),
                                itemCount: state is SuccessState ? state.response.length : 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(left: BorderSide(color: AColors.iconGreyColor, width: 5)),
                                          color: AColors.white,
                                        ),
                                        child: _notificationItem(index),
                                      ),
                                      Divider(
                                        thickness: 0.5,
                                        color: AColors.greyColor1,
                                      )
                                    ],
                                  );
                                }),
                          );
                        })
                      ],
                    ),
                  ),
                  toolTipController: _tooltipController,
                  child: IconButton(
                    onPressed: () async {
                      //Display the toolbox for ///adoddle/search data
                      // _tooltipController.showTooltipDialog();
                      // await _toolBarCubit.notificationIconClicked();
                    },
                    icon: Icon(Icons.notifications_outlined, color: AColors.grColorDark, size: 22),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<ToolbarCubit, FlowState>(builder: (context, state) {
            return Visibility(
              visible: state is ToolbarNavigationItemSelectedState && state.navigationMenuItemType != NavigationMenuItemType.quality && state.navigationMenuItemType != NavigationMenuItemType.tasks,
              child: BlocBuilder<SyncCubit, FlowState>(
                buildWhen: (previous, current) {
                  return current is SyncStartState || current is SyncCompleteState && current is! SyncInitial;
                },
                builder: (_, state) {
                  if (state is SyncRunState) {
                    return IconButton(
                      icon: Icon(Icons.stop, color: AColors.grColorDark, size: 22),
                      onPressed: () {
                        context.read<SyncCubit>().stopSyncing();
                      },
                    );
                  } else if (isNetWorkConnected() &&(state is SyncStartState || state is SyncProgressState || state is SyncLocationProgressState)) {
                    return RotationTransition(turns: turnsTween.animate(_controller!), child: IconButton(icon: Icon(Icons.sync, color: AColors.greenColor, size: 22), onPressed: () {}));
                  } else {
                    return _syncIconWidget();
                    // return ;
                  }
                },
              ),
            );
          }),
          BlocBuilder<onlineViewerCubit.OnlineModelViewerCubit, onlineViewerCubit.OnlineModelViewerState>(builder: (_, state) {
            return context.read<onlineViewerCubit.OnlineModelViewerCubit>().isModelTreeOpen ? _moreMenuWidget(context.read<onlineViewerCubit.OnlineModelViewerCubit>()) : SizedBox.shrink();
          })
        ],
      ),
    );
  }

  Widget _syncIconWidget() {
    return TooltipDialog(
      key: Key("offline_tooltip"),
      toolTipContent: SizedBox(
        width: 340,
        child: _syncStatusWidget(),
      ),
      toolTipController: _tooltipController,
      child: IconButton(
        icon: isNetWorkConnected() ? Icon(semanticLabel: "Sync enabled",Icons.sync, color: AColors.grColorDark, size: 22) : Icon(Icons.sync_disabled, color: AColors.grColorDark, size: 22),
        onPressed: () async {
          await _syncCubit.showSyncLatestDataOption();
          Future.delayed(const Duration(milliseconds: 100)).then((value) async {
            _tooltipController.showTooltipDialog();
          });
        },
      ),
    );
  }

  Widget _moreMenuWidget(onlineViewerCubit.OnlineModelViewerCubit cubit) {
    return TooltipDialog(
      toolTipContent: SizedBox(
        width: 200,
        height: 100,
        child: _helpWidget(),
      ),
      onDismiss: () {
        if(getIt<onlineViewerCubit.OnlineModelViewerCubit>().isCalibListShow){
          getIt<onlineViewerCubit.OnlineModelViewerCubit>().emit(onlineViewerCubit.CalibrationListResponseSuccessState(items: getIt<onlineViewerCubit.OnlineModelViewerCubit>().calibList));
        }
      },
      toolTipController: _tooltipMoreController,
      child: IconButton(
        icon: Icon(
          Icons.more_vert_outlined,
          color: AColors.grColorDark,
        ),
        onPressed: () async {
          if (Utility.isIos) {
            getIt<onlineViewerCubit.OnlineModelViewerCubit>().callViewObjectFileAssociationDetails();
          }
          if (cubit.isModelLoaded) _tooltipMoreController.showTooltipDialog();
        },
      ),
    );
  }

  bool enableSetLatestDataOptionForTab(NavigationMenuItemType navigationMenuItemType) {
    switch (navigationMenuItemType) {
      case NavigationMenuItemType.sites:
        return true;
      default:
        return false;
    }
  }

  Widget _syncStatusWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(width: 8),
              Visibility(
                visible: enableSetLatestDataOptionForTab(_navigationCubit.currSelectedItem) && isNetWorkConnected(),
                child: Flexible(
                    flex: 7,
                    child: OutlinedButton(
                      onPressed: () async {
                        _tooltipController.hideTooltipDialog();
                        _syncCubit.autoSyncOnlineToOffline();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1.0, color: AColors.grColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: NormalTextWidget(
                          context.toLocale!.lbl_sync_latest_data,
                         color: AColors.grColor, fontSize: 17, fontWeight: AFontWight.regular,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )),
              ),
              Visibility(visible: isNetWorkConnected(), child: const SizedBox(width: 8)),
              Flexible(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: !isNetWorkConnected(),
                      child: Flexible(
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                size: 24,
                                color: AColors.bannerWaringColor,
                              ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: 5.0, horizontal: 15.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: NormalTextWidget(context.toLocale!.lbl_working_offline, color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold, textAlign: TextAlign.left,maxLines: 2,),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      NormalTextWidget(context.toLocale!.lbl_working_offline_msg, textAlign: TextAlign.left,color: AColors.textColor, fontSize: 13, fontWeight: AFontWight.regular,maxLines: 4,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            fit: isNetWorkConnected() ? FlexFit.tight : FlexFit.loose,
                            flex: isNetWorkConnected() ? 45 : 1,
                            child: OutlinedButton(
                              onPressed: () async {
                                isOnlineButtonSyncClicked = true;
                                _tooltipController.hideTooltipDialog();

                                // await Utility.showSyncRemainderBanner(context);
                                await _userProfileSettingOfflineCubit.toggleWorkOffline(isNetWorkConnected() ? true : false);
                                Utility.closeBanner();

                                if (isNetWorkConnected() == false) {
                                  await Utility.showBannerNotification(context, context.toLocale!.lbl_work_offline, context.toLocale!.lbl_working_offline_msg, Icons.warning, AColors.bannerWaringColor);
                                }
                                if (isNetWorkConnected()) {
                                  await StorePreference.checkAndSetSelectedProjectIdHash();
                                }
                                NavigationUtils.reloadApp();
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(width: 1.0, color: AColors.grColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: NormalTextWidget(
                                  isNetWorkConnected() ? context.toLocale!.lbl_work_offline : context.toLocale!.lbl_work_online,
                                  color: AColors.grColor, fontSize: 17, fontWeight: AFontWight.regular,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isNetWorkConnected() ? SizedBox(width: 8) : SizedBox(width: 3),
            ],
          ),
        ),
        Visibility(
          visible: _navigationCubit.currSelectedItem != NavigationMenuItemType.home && isNetWorkConnected(),
          child: Flexible(
            flex: 2,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                margin: EdgeInsetsDirectional.only(end: 7),
                child: OutlinedButton(
                  onPressed: () async {
                    _tooltipController.hideTooltipDialog();
                    getIt<SyncCubit>().autoSyncOfflineToOnline();
                    FireBaseEventAnalytics.setEvent(
                        FireBaseEventType.syncOfflineData,
                        FireBaseFromScreen.headerShortcut,
                        bIncludeProjectName: true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 1.0, color: AColors.grColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: NormalTextWidget(
                      context.toLocale!.lbl_sync_offline_data,
                      color: AColors.grColor, fontSize: 17, fontWeight: AFontWight.regular,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              BlocBuilder<SyncCubit, FlowState>(buildWhen: (previous, current) {
                return current is SyncStartState || current is SyncCompleteState && current is! SyncInitial;
              }, builder: (_, state) {
                return Visibility(
                  visible: _syncCubit.isSyncPending ? true : false,
                  child: Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                    ),
                  ),
                );
              }),
            ]),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _helpWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.help_outline,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              NormalTextWidget(
                "Help",
                fontSize: 18,
                fontWeight: AFontWight.regular,
                maxLines: 1,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            _tooltipMoreController.hideTooltipDialog();
            getIt<onlineViewerCubit.OnlineModelViewerCubit>().removePdfListView();
            showDialog(context: context, barrierDismissible: false, builder: (con) => CBimSettingsDialog()).then((value) {

            });
          },
          child: Ink(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.settings_outlined,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                NormalTextWidget(
                  context.toLocale!.lbl_models_settings,
                  fontSize: 18,
                  fontWeight: AFontWight.regular,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _notificationItem(index) {
    return BlocBuilder<ToolbarCubit, FlowState>(builder: (context, state) {
      if (state is SuccessState) {
        if (state.response.length == 0) {
          return Padding(padding: const EdgeInsets.all(20), child: NormalTextWidget(context.toLocale!.empty_notification_list_msg));
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ImageIcon(
                      size: 28,
                      color: AColors.greyColor,
                      AssetImage(
                        AImageConstants.accountHardHat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NormalTextWidget(
                        state.response[index].uploadFilename,
                        fontSize: 16,
                        fontWeight: AFontWight.regular,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      NormalTextWidget(
                        "> CON.150 > Ground Floor > Appartment 1",
                        fontSize: 13,
                        fontWeight: AFontWight.regular,
                        maxLines: 1,
                        color: AColors.themeBlueColor,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      NormalTextWidget(
                        state.response[index].activityDate,
                        fontSize: 13,
                        fontWeight: AFontWight.regular,
                        maxLines: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      } else if (state is ErrorState) {
        Log.d(state.message);
      } else if (state is LoadingState) {
        return const Center(
          child: ACircularProgress(
            key: Key("key_task_listing_progressbar"),
            color: Colors.black,
            strokeWidth: 2,
            backgroundColor: Colors.red,
          ),
        );
      }
      return const Divider();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller?.dispose();
    super.dispose();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
