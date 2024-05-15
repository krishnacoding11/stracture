import 'dart:convert';

import 'package:field/data/model/quality_plan_location_listing_vo.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/quality/activity_listing_screen.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/alisttile_quality_navigation.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/QR/navigator_cubit.dart';
import '../../../bloc/navigation/navigation_cubit.dart';
import '../../../bloc/quality/quality_plan_location_listing_cubit.dart';
import '../../../bloc/quality/quality_plan_location_listing_state.dart';
import '../../../bloc/toolbar/toolbar_cubit.dart';
import '../../../data/model/quality_plan_list_vo.dart';
import '../../../injection_container.dart';
import '../../../logger/logger.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/qrcode_utils.dart';
import '../../../widgets/a_progress_dialog.dart';
import '../../base/state_renderer/state_render_impl.dart';
import '../../base/state_renderer/state_renderer.dart';
import '../../managers/image_constant.dart';
import '../bottom_navigation/tab_navigator.dart';

class LocationListingScreen extends StatefulWidget {
  final Data? qualityPlanData;

  const LocationListingScreen({
    super.key,
    required this.qualityPlanData,
  });

  @override
  State<LocationListingScreen> createState() => _LocationListingScreenState();
}

class _LocationListingScreenState extends State<LocationListingScreen> {
  final ScrollController _horizontalScrollController = ScrollController(keepScrollOffset: true);
  AProgressDialog? aProgressDialog;
  late QualityPlanLocationListingCubit _qualityPlanLocationListingCubit;
  late FieldNavigatorCubit _navigatorCubit;
  late ScrollController animatedScrollController;
  late ScrollController listScrollController;

  @override
  void initState() {
    _navigatorCubit = getIt<FieldNavigatorCubit>();
    super.initState();
    _qualityPlanLocationListingCubit = getIt<QualityPlanLocationListingCubit>();
    _qualityPlanLocationListingCubit.setArgument(widget.qualityPlanData!);
    _qualityPlanLocationListingCubit.setCurrentPlanOrLocationPercentage = widget.qualityPlanData!.percentageCompletion;

    //Load locations
    _qualityPlanLocationListingCubit.getLocationListFromServer(isLoading: true);

    listScrollController = ScrollController();
    _scrollingAnimation();

    animatedScrollController = getIt<ScrollController>();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => _navigatorCubit),
          BlocProvider(create: (_) => _qualityPlanLocationListingCubit),
        ],
        child: MultiBlocListener(
            listeners: [
              BlocListener<FieldNavigatorCubit, FlowState>(
                listener: (BuildContext context, state) async {
                  if (state is SuccessState) {
                    aProgressDialog?.dismiss();
                    if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.sites) {
                      getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.sites);
                      getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.sites);
                    }
                    state.response["arguments"]["isFromQuality"] =
                        true; // Used for condition for back to quality  which will not get affected by any change in location while in site plan
                    state.response["arguments"]["isFrom"] = FromScreen.quality;
                    await Future.delayed(const Duration(milliseconds: 100));
                    NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.sitePlanView, argument: state.response["arguments"]);
                  } else if (state is ErrorState) {
                    aProgressDialog?.dismiss();
                    Log.d(state.message);
                    if (state.code == 401 || state.code == 404) {
                      dynamic jsonResponse = jsonDecode(state.message);
                      String errorMsg = jsonResponse['msg'];
                      errorMsg = errorMsg.isNullOrEmpty() ? QrCodeUtility.getQrError(jsonResponse['key']) : errorMsg;
                      Utility.showAlertWithOk(context, errorMsg);
                    } else {
                      context.showSnack(state.message);
                    }
                  } else if (state is LoadingState) {
                    aProgressDialog ??= AProgressDialog(context, useSafeArea: true, isWillPopScope: true);
                    aProgressDialog?.show();
                  }
                },
              ),
              BlocListener<QualityPlanLocationListingCubit, FlowState>(
                listener: (context, state) {
                  if (state is ActivityListState && state.internalState == InternalState.refreshError) {
                    context.showSnack(_handleUploadError(state.message!)!);
                  }
                },
              )
            ],
            child: BlocBuilder<QualityPlanLocationListingCubit, FlowState>(builder: (_, state) {
              bool isProcessData = state is LoadingState ||
                  ((state is LocationListState && state.internalState == InternalState.refresh) ||
                      state is ActivityListState && state.internalState == InternalState.refresh);
              return WillPopScope(
                onWillPop: () async {
                  backNavigationToLocations();
                  return false;
                },
                child: Scaffold(
                    backgroundColor: AColors.white,
                    body: Stack(
                      children: [
                        IgnorePointer(
                          ignoring: isProcessData,
                          child: Column(children: [
                            getPlanLocationBreadcrumbWidget(),
                            const SizedBox(
                              height: 12.0,
                            ),
                            Utility.isTablet
                                ? Padding(
                                    padding: const EdgeInsetsDirectional.only(start: 22, end: 38, top: 4, bottom: 4),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: getSelectedLocationWidget(),
                                        ),
                                        Flexible(child: getQualityActionRowWidget(state)),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(6.0, 2.0, 12.0, 2.0),
                                        child: getSelectedLocationWidget(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                                        child: getQualityActionRowWidget(state),
                                      ),
                                    ],
                                  ),
                            Padding(
                              padding: Utility.isTablet
                                  ? const EdgeInsetsDirectional.fromSTEB(20.0, 6.0, 20.0, 6.0)
                                  : const EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                              child: Divider(
                                color: AColors.dividerColor,
                                thickness: 1.0,
                                height: 1.0,
                              ),
                            ),
                            if (state is QualityListState)
                              Expanded(
                                  child: state.qualityListInternalState == QualityListInternalState.activityList
                                      ? BlocProvider.value(value: _qualityPlanLocationListingCubit, child: const ActivityListingScreen())
                                      : getLocationListingWidget(context, state))
                          ]),
                        ),
                        if (isProcessData)
                          Container(
                            color: Colors.black45,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const ACircularProgress(key: Key("key_quality_plan_location_listing_progressbar")),
                                const SizedBox(height: 20),
                                NormalTextWidget(context.toLocale!.lbl_quality_plan_refresh, color: Colors.white,)
                              ],
                            ),
                          )
                      ],
                    )),
              );
            })));
  }

  Widget getPlanLocationBreadcrumbWidget() {
    return Container(
        height: 48.0,
        width: double.maxFinite,
        color: AColors.filterBgColor,
        padding: const EdgeInsetsDirectional.only(end: 8.0),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          controller: _horizontalScrollController,
          physics: const ClampingScrollPhysics(),
          itemCount: _qualityPlanLocationListingCubit.locationBreadcrumbList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Row(
              children: [
                index == 0
                    ? Icon(
                        Icons.business,
                        size: Utility.isTablet ? 22 : 20,
                        color: AColors.iconGreyColor,
                      )
                    : index == 1
                        ? Icon(
                            Icons.assignment_turned_in_outlined,
                            size: Utility.isTablet ? 22 : 20,
                            color: AColors.iconGreyColor,
                          )
                        : Container(),
                InkWell(
                  onTap: () {
                    if (index == 1) {
                      popBack();
                    } else if (index != 0) {
                      _qualityPlanLocationListingCubit.removeItemFromBreadCrumb(index: index);
                      FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityBreadCrumbsNavigation, FireBaseFromScreen.quality, bIncludeProjectName: true);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                    child: NormalTextWidget(
                      ' ${getBreadCrumbTitle(index, _qualityPlanLocationListingCubit.locationBreadcrumbList[index])} ',
                      textAlign: TextAlign.center,
                      fontSize: 13.0,
                      fontWeight: AFontWight.regular,
                      color: (index == _qualityPlanLocationListingCubit.locationBreadcrumbList.length - 1)
                          ? AColors.menuSelectedColor
                          : AColors.iconGreyColor,
                    ),
                  ),
                ),
                (index == _qualityPlanLocationListingCubit.locationBreadcrumbList.length - 1 || index == 0)
                    ? Container(
                        width: 10,
                      )
                    : Icon(Icons.arrow_forward_ios_rounded, color: AColors.iconGreyColor, size: 20),
              ],
            );
          },
        ));
  }

  Widget getSelectedLocationWidget() {
    return BlocBuilder<QualityPlanLocationListingCubit, FlowState>(builder: (context, state) {
      List<dynamic> breadCrumb = _qualityPlanLocationListingCubit.locationBreadcrumbList.toList();

      return SizedBox(
          width: double.maxFinite,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  backNavigationToLocations();
                  FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityLocationNavigation, FireBaseFromScreen.quality, bIncludeProjectName: true);
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 0.0, 4.0),
                  child: Icon(semanticLabel: "BackBtnIcon", Icons.arrow_back_ios, color: AColors.iconGreyColor, size: 18),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 8.0, 8.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: () => backNavigationToLocations(),
                          child: NormalTextWidget(
                            '${getBreadCrumbTitle(breadCrumb.length - 1, breadCrumb.last)} ',
                            textAlign: TextAlign.start,
                            fontSize: Utility.isTablet ? 18.0 : 16.0,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            color: AColors.textColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      !Utility.isTablet && _qualityPlanLocationListingCubit.selectedQualityLocation != null ? planImage() : Container()
                    ],
                  ),
                ),
              )
            ],
          ));
    });
  }

  Widget getQualityActionRowWidget(FlowState state) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.max, children: [
      /*IconButton(
        icon: const Icon(Icons.search),
        padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 6.0),
        color: AColors.iconGreyColor,
        onPressed: () {},
      ),*/
      IconButton(
        key: const Key('quality_plan_Listing_refresh_icon'),
        icon: const Icon(semanticLabel: "refreshIcon", Icons.sync),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        color: AColors.iconGreyColor,
        onPressed: () {
          onRefresh(state: state, isPullToRefresh: false);
          FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityViewRefreshClick, FireBaseFromScreen.quality, bIncludeProjectName: true);
        },
      ),
      Utility.isTablet && _qualityPlanLocationListingCubit.selectedQualityLocation != null ? Flexible(child: planImage()) : Container(),
      showActivityButton()
          ? Container(
              width: 140,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(width: 1, color: AColors.dividerColor)),
              child: InkWell(
                onTap: () {
                  if (state is QualityListState && state.internalState != InternalState.loading) {
                    if (_qualityPlanLocationListingCubit.qualityListInternalState == QualityListInternalState.activityList) {
                      _qualityPlanLocationListingCubit.getLocationListFromServer(
                          isLoading: true, currentLocationId: _qualityPlanLocationListingCubit.locationId);
                    } else {
                      _qualityPlanLocationListingCubit.navigateToActivityList();
                    }
                  }
                  FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityLocationActivityToggle, FireBaseFromScreen.quality, bIncludeProjectName: true);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
                  child: Row(
                    children: [
                      Image.asset(AImageConstants.factCheckAlt, color: AColors.iconGreyColor, fit: BoxFit.fill, width: 18, height: 18),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: NormalTextWidget(
                              // (state is QualityListState &&
                              //             state.internalState !=
                              //                 InternalState.loading) &&
                              (_qualityPlanLocationListingCubit.qualityListInternalState == QualityListInternalState.activityList)
                                  ? context.toLocale!.lbl_header_location
                                  : context.toLocale!.activities,
                              color: AColors.iconGreyColor,
                              //maxLines: 1,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          : Container(),
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
        child: NormalTextWidget(
          "${_qualityPlanLocationListingCubit.getCurrentPlanOrLocationPercentage}%",
          color: AColors.iconGreyColor,
          fontWeight: AFontWight.regular,
          fontSize: 13,
        ),
      ),
      ACircularProgress(
          color: AColors.lightGreenColor,
          strokeWidth: 7,
          progressValue: (_qualityPlanLocationListingCubit.getCurrentPlanOrLocationPercentage ?? 0) / 100,
          backgroundColor: AColors.progressBarBgColor),
    ]);
  }

  Widget getLocationListingWidget(BuildContext context, FlowState state) {
    if (state is LocationListState) {
      switch (state.internalState) {
        case InternalState.loading:
          _forwardAnimation();
          return const Center(
            child: ACircularProgress(
              key: Key("key_location_listing_progressbar"),
            ),
          );
        case InternalState.failure:
          String errorMessage = state.getStateRendererType() == StateRendererType.FULL_SCREEN_ERROR_STATE
              ? context.toLocale!.error_message_something_wrong
              : (state.getStateRendererType() == StateRendererType.EMPTY_SCREEN_STATE
                  ? context.toLocale!.no_matches_found
                  : context.toLocale!.no_data_available);
          return Center(
            child: NormalTextWidget(errorMessage, key: const Key('something_went_wrong')),
          );
        case InternalState.refresh:
        case InternalState.refreshError:
        case InternalState.success:
          //Empty state message
          if (_qualityPlanLocationListingCubit.qualityLocationList.isEmpty ||
              (_qualityPlanLocationListingCubit.getCountQualityLocationList() == 1 &&
                  _qualityPlanLocationListingCubit.qualityLocationList.first.qiParentId.isNullEmptyOrFalse())) {
            return Center(
              child: NormalTextWidget(context.toLocale!.no_location_found, key: const Key('key_no_location_found')),
            );
          }
          return getLocationTreeWidget(state);
        default:
          return Container();
      }
    }
    return Container();
  }

  Widget getLocationTreeWidget(FlowState state) {
    return RefreshIndicator(
      color: AColors.blueColor,
      onRefresh: () async => onRefresh(state: state, isPullToRefresh: true),
      child: ListView.builder(
        key: const PageStorageKey<String>("location_listing"),
        controller: listScrollController,
        padding: const EdgeInsets.all(0),
        itemCount: _qualityPlanLocationListingCubit.getCountQualityLocationList() ?? 0,
        itemBuilder: (context, index) {
          final Locations item = _qualityPlanLocationListingCubit.qualityLocationList[index];
          return _buildLocationListTile(item);
        },
      ),
    );
  }

  Widget _buildLocationListTile(Locations listItem) {
    if (listItem.qiParentId.isNullEmptyOrFalse()) {
      return Container();
    }

    return AListTileQualityNavigation(
      title: listItem.name ?? '',
      percentage: listItem.percentageCompelition ?? 0,
      hasLocation: listItem.hasLocation ?? false,
      onTap: () {
        _qualityPlanLocationListingCubit.setCurrentPlanOrLocationPercentage = listItem.percentageCompelition;
        if (listItem.hasLocation!) {
          _qualityPlanLocationListingCubit.selectedQualityLocation = listItem;
          _qualityPlanLocationListingCubit.addLocationToBreadcrumb(listItem);
          _qualityPlanLocationListingCubit.getLocationListFromServer(
              currentLocationId: _qualityPlanLocationListingCubit.locationId, isLoading: true);
          scrollToLastCrumb(listItem.globalKey!, listItem.name!.length);

          return;
        } else {
          _qualityPlanLocationListingCubit.selectedQualityLocation = listItem;
          _qualityPlanLocationListingCubit.addLocationToBreadcrumb(listItem);
          _qualityPlanLocationListingCubit.navigateToActivityList(listItem);
          scrollToLastCrumb(listItem.globalKey!);
        }
      },
    );
  }

  String? getBreadCrumbTitle(int index, dynamic breadcrumbItem) {
    if (index == 0) {
      return breadcrumbItem['projectName'];
    }

    if (index == 1) {
      return context.toLocale!.quality_plans;
    }

    if (index == 2) {
      return breadcrumbItem['planName'];
    }

    return breadcrumbItem.name;
  }

  Future<void> scrollToLastCrumb(GlobalKey globalKey, [int length = 0]) async {
    await Future.delayed(const Duration(milliseconds: 100));
    double? width = globalKey.currentContext?.size?.width;
    width ??= length * 13;
    _horizontalScrollController.animateTo(_horizontalScrollController.position.maxScrollExtent + width,
        duration: const Duration(milliseconds: 100), curve: Curves.linear);
  }

  navigateToPlan() {
    if (_navigatorCubit.state is! LoadingState) {
      _navigatorCubit.checkQRCodePermission(_qualityPlanLocationListingCubit.createQrObject());
    }
  }

  void backNavigationToLocations() {
    if (_qualityPlanLocationListingCubit.locationBreadcrumbList.length > 3) {
      _qualityPlanLocationListingCubit.removeItemFromBreadCrumb();
    } else {
      popBack();
    }
  }

  onRefresh({state, bool? isPullToRefresh}) async {
    if (state is QualityListState && state.internalState != InternalState.loading) {
      await getRefreshList(isPullToRefresh: isPullToRefresh);
    }
  }

  getRefreshList({bool? isPullToRefresh}) async {
    if (!isPullToRefresh!) _qualityPlanLocationListingCubit.emitRefreshState();
    _qualityPlanLocationListingCubit.updateAndRefreshData();
  }

  bool showActivityButton() {
    return (_qualityPlanLocationListingCubit.selectedQualityLocation != null &&
        _qualityPlanLocationListingCubit.selectedQualityLocation!.hasLocation!);
  }

  Widget planImage() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 12.0, 0.0),
      child: IconButton(
        key: const Key("key_quality_site_plan_widget"),
        icon: Image.asset(
          AImageConstants.floorPlan,
          fit: BoxFit.fill,
          width: 20,
          height: 20,
        ),
        onPressed: () {
          FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityViewTwoDPlanNavigation, FireBaseFromScreen.quality, bIncludeProjectName: true);
          navigateToPlan();
        },
      ),
    );
  }

  popBack() {
    _forwardAnimation();
    if (_qualityPlanLocationListingCubit.getPlanPercentage != null) {
      Navigator.pop(context,
          {"percentageCompletion": _qualityPlanLocationListingCubit.getPlanPercentage, "planId": _qualityPlanLocationListingCubit.planId});
    } else {
      Navigator.pop(context);
    }
  }

  String? _handleUploadError(String error) {
    switch (error) {
      case "checkedOutFileList":
        return context.toLocale!.error_message_checked_out_file;
      case "linkedFileList":
        return context.toLocale!.error_message_same_name_file_linked;
      case "ErrorInSimpleUpload":
        return context.toLocale!.error_message_upload_file;
      case "SomethingWentWrong":
        return context.toLocale!.error_message_something_wrong;
    }
    return error;
  }



  void _scrollingAnimation() {
    listScrollController.addListener(() {
      _filterAnimationController();
    });
  }


  void _filterAnimationController() {
    if (!Utility.isTablet) {
      if (listScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _reverseAnimation();
      }
    }
    if (listScrollController.position.userScrollDirection == ScrollDirection.forward) {
      _forwardAnimation();
    }
  }

  void _reverseAnimation() {
    if (Utility.isTablet || !animatedScrollController.hasClients) {
      return;
    }

    animatedScrollController.animateTo(
      animatedScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
  }

  void _forwardAnimation() {
    if(animatedScrollController.hasClients) {
      animatedScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    }
  }

}
