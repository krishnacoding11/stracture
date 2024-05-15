import 'dart:convert';

import 'package:field/bloc/site/location_tree_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/alisttile_location.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../analytics/event_analytics.dart';
import '../bloc/image_sequence/image_sequence_cubit.dart';
import '../bloc/site/location_tree_state.dart';
import '../bloc/sync/sync_state.dart';
import '../data/model/location_suggestion_search_vo.dart';
import '../data/model/project_vo.dart';
import '../data/model/search_location_list_vo.dart';
import '../data/model/site_location.dart';
import '../data/model/sync/sync_request_task.dart';
import '../data/repository/site/location_tree_repository.dart';
import '../injection_container.dart';
import '../networking/network_info.dart';
import '../presentation/base/state_renderer/state_render_impl.dart';
import '../presentation/base/state_renderer/state_renderer.dart';
import '../presentation/managers/color_manager.dart';
import '../presentation/screen/downloading_screen.dart';
import '../utils/constants.dart';
import '../utils/field_enums.dart';
import '../utils/store_preference.dart';
import 'a_progress_dialog.dart';
import 'atheme.dart';
import 'clickabletextwidget.dart';
import 'custom_search_view/custom_search_view.dart';
import 'elevatedbutton.dart';
import 'project_download_size_dialog.dart';

class LocationTreeWidget extends StatefulWidget {
  const LocationTreeWidget(this.arguments, {Key? key}) : super(key: key);
  final Map<String, dynamic> arguments;

  @override
  State<LocationTreeWidget> createState() => _LocationTreeWidgetState();
}

class _LocationTreeWidgetState extends State<LocationTreeWidget> {
  late LocationTreeCubit _locationTreeCubit;
  late final LocationTreeViewFrom _isFrom;
  final ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  final ScrollController _horizontalScrollController = ScrollController(keepScrollOffset: true);
  final TextEditingController _searchLocationController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  var searchString = '';
  String highlightSearch = "";

  SyncCubit? _syncCubit;
  bool _isEnableOfflineSelection = false;
  bool _locationUnMarkEnable = false;
  int? wantToDeleteLocationId;
  bool selected = false;
  late ImageSequenceCubit imageSeqCubit;
  late bool isOnline;
  AProgressDialog? aProgressDialog;
  // bool _isLocationMarkedOffline = false;
  @override
  void initState() {
    super.initState();
    isOnline = isNetWorkConnected();
    imageSeqCubit = getIt<ImageSequenceCubit>();
    imageSeqCubit.simulateProgress();
    _locationTreeCubit = BlocProvider.of<LocationTreeCubit>(context);
    _syncCubit = context.read<SyncCubit>();
    if (widget.arguments.containsKey('isFrom')) {
      _isFrom = widget.arguments['isFrom'];
    }
    _locationTreeCubit.getRecentProject(true);
    getLocationData();
    aProgressDialog = AProgressDialog(context, useSafeArea: true, isWillPopScope: true, isAnimationRequired: true);
    FireBaseEventAnalytics.setCurrentScreen(FireBaseScreenName.locationTree.value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      insetPadding: Utility.isTablet ? EdgeInsets.fromLTRB(100, (FocusManager.instance.primaryFocus?.hasFocus ?? false) ? 10 : 100, 100, (FocusManager.instance.primaryFocus?.hasFocus ?? false) ? 10 : 100) : const EdgeInsets.all(16),
      backgroundColor: AColors.white,
      child: Theme(
        data: ATheme.transparentDividerTheme,
        child: MultiBlocListener(
          listeners: [
            BlocListener<LocationTreeCubit, FlowState>(
              listener: (context, state) {
                if (state is SuccessState) {
                  closeLocationTreeDialog(result: state.response);
                } else if (state is LocationUnMarkEnableState) {
                  _locationUnMarkEnable = state.isEnableUnmarkSelection ? state.isEnableUnmarkSelection : false;
                } else if (state is MarkOfflineEnableState) {
                  _isEnableOfflineSelection = state.isEnableOfflineSelection ? state.isEnableOfflineSelection : false;
                } else if (state is LocationUnMarkDeleteApprovalState) {
                  wantToDeleteLocationId = state.locationId;
                  selected = state.isAnimate;
                } else if (state is LocationUnMarkProgressDialogState) {
                  if (!state.show) {
                    aProgressDialog!.dismiss();
                  }
                }
              },
            ),
            BlocListener<SyncCubit, FlowState>(listener: (_, state) async {
              if (state is SyncLocationProgressState) {
                _locationTreeCubit.refreshListAfterSync((state).locationSitesSyncDataVo);
                // _isLocationMarkedOffline = false;
                // } else if (state is SyncStartState) {
                //   _isLocationMarkedOffline = false;
                // } else if (state is SyncCompleteState) {
                //   if (await getIt<ProjectListLocalRepository>().isSiteDataMarkedOffline()) {
                //     _isLocationMarkedOffline = true;
                //   }
              }
            })
          ],
          child: BlocBuilder<LocationTreeCubit, FlowState>(builder: (context, state) {
            return Column(children: [
              widgetHeaderSelectALocation(),
              widgetProjectNameAndBreadcrumb(),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 60,
                margin: const EdgeInsetsDirectional.only(start: 8),
                child: locationTreeSearch(),
              ),
              Expanded(
                flex: 3,
                key: const Key("LocationList"),
                child: getLocationTreeWidget(context, state),
              ),
              widgetBottomSelectedLocationAndViewButton(),
            ]);
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Widget widgetHeaderSelectALocation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AColors.greyColor1)),
        boxShadow: [
          BoxShadow(
            color: AColors.lightGreyColor,
            offset: const Offset(0, 1),
            blurRadius: 1,
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          showList(context)
              ? (_locationTreeCubit.listBreadCrumb.length > 1)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: AColors.iconGreyColor,
                      iconSize: 20,
                      onPressed: () {
                        _locationTreeCubit.removeItemFromBreadCrumb();
                      },
                    )
                  : const SizedBox(
                      width: 40,
                    )
              : const SizedBox(
                  width: 40,
                ),
          Flexible(
            fit: FlexFit.tight,
            child: NormalTextWidget(
              context.toLocale!.lbl_project_select_location,
              fontWeight: AFontWight.semiBold,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(

            icon: const Icon(semanticLabel: "CloseDialogIcon", Icons.close_sharp),
            color: AColors.iconGreyColor,
            iconSize: 20,
            onPressed: () {
              closeLocationTreeDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget widgetProjectNameAndBreadcrumb() {
    return IgnorePointer(
      key: const Key("ListBreadCrumb"),
      ignoring: !showList(context),
      child: Container(
        height: 48.0,
        width: double.maxFinite,
        color: showList(context) ? AColors.btnDisableClr : AColors.iconGreyColor.withOpacity(0.25),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
          controller: _horizontalScrollController,
          physics: const ClampingScrollPhysics(),
          itemCount: _locationTreeCubit.listBreadCrumb.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return InkWell(
              key: _locationTreeCubit.getKeyForBreadCrumb(index),
              onTap: () {
                if (!_isEnableOfflineSelection && !_locationUnMarkEnable) {
                  _locationTreeCubit.removeItemFromBreadCrumb(index: index);
                  FireBaseEventAnalytics.setEvent(FireBaseEventType.locationTreeBreadCrumbsClick, FireBaseFromScreen.locationTree, bIncludeProjectName: true);
                }
              },
              child: Row(
                children: [
                  Icon(index == 0 ? Icons.business : Icons.chevron_right, color: AColors.iconGreyColor, size: 15),
                  NormalTextWidget(
                    ' ${getBreadCrumbTitle(index)} ',
                    textAlign: TextAlign.center,
                    fontSize: 15.0,
                    fontWeight: AFontWight.regular,
                    color: (index == _locationTreeCubit.listBreadCrumb.length - 1) ? AColors.menuSelectedColor : AColors.iconGreyColor,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget widgetBottomSelectedLocationAndViewButton() {
    bool isNeedToEnable = _locationTreeCubit.listBreadCrumb.length > 0;
    return BlocBuilder<LocationTreeCubit, FlowState>(builder: (context, state) {
      bool isNeedToVisible = state is VisibleSelectBtn
          ? state.props[0] as bool
          : state is LocationSearchSate || state is ErrorState
              ? false
              : true;
      return Visibility(
        visible: isNeedToVisible,
        child: IgnorePointer(
          ignoring: !showList(context),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              alignment: Directionality.of(context) == TextDirection.rtl ? Alignment.centerLeft : Alignment.centerRight,
              decoration: BoxDecoration(color: showList(context) ? Colors.white : AColors.iconGreyColor.withOpacity(0.4), border: Border(top: BorderSide(color: showList(context) ? AColors.dividerColor : AColors.iconGreyColor.withOpacity(0.4)))),
              child: Builder(
                builder: (context) {
                  if (_isEnableOfflineSelection) {
                    bool isNeedToEnableForOffline = (_locationTreeCubit.isOnlyOneLocationSelectForOffline());
                    return Visibility(
                      visible: _isEnableOfflineSelection,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClickableTextWidget(
                            context.toLocale!.lbl_btn_cancel,
                            onPressed: () {
                              _locationTreeCubit.enableMarkOfflineSelection(false);
                            },
                          ),
                          const SizedBox(width: 10),
                          AElevatedButtonWidget(
                            btnLabel: context.toLocale!.lbl_btn_save,
                            btnLabelClr: isNeedToEnableForOffline ? AColors.white : AColors.lightGreyColor,
                            btnBackgroundClr: isNeedToEnableForOffline ? AColors.themeBlueColor : AColors.btnDisableClr,
                            onPressed: isNeedToEnableForOffline
                                ? () {
                                    _showDownloadDialog(context);
                                  }
                                : null,
                          )
                        ],
                      ),
                    );
                  } else {
                    return AElevatedButtonWidget(
                      height: 39,
                      fontWeight: AFontWight.medium,
                      borderRadius: 4,
                      fontFamily: AFonts.fontFamily,
                      fontSize: 14,
                      btnLabelClr: isNeedToEnable ? AColors.white : AColors.lightGreyColor,
                      btnBackgroundClr: isNeedToEnable ? AColors.themeBlueColor : AColors.btnDisableClr,
                      btnLabel: context.toLocale!.button_text_select,
                      onPressed: isNeedToEnable
                          ? () async {
                              if(_locationTreeCubit.listBreadCrumb.last is Project) {
                                await _locationTreeCubit.setCurrentSiteProject(_locationTreeCubit.listBreadCrumb.last);
                              }else {
                                await _locationTreeCubit.setCurrentSiteLocation(_locationTreeCubit.traversedLocation ?? _locationTreeCubit.selectedLocation ?? _locationTreeCubit.listBreadCrumb.last);
                              }
                              openSitePlanView();
                            }
                          : null,
                    );
                  }
                },
              )),
        ),
      );
    });
  }

  Widget getLocationTreeWidget(BuildContext context, FlowState state) {
    switch (state.runtimeType) {
      case LoadingState:
        return const Center(child: ACircularProgress());
      case NoProjectSelectedState:
        return Center(child: NormalTextWidget(context.toLocale!.lbl_no_project_data));
      case ErrorState:
        String errorMessage = state.getStateRendererType() == StateRendererType.FULL_SCREEN_ERROR_STATE ? context.toLocale!.error_message_something_wrong : (state.getStateRendererType() == StateRendererType.EMPTY_SCREEN_STATE ? context.toLocale!.no_matches_found : context.toLocale!.no_data_available);
        return Center(child: NormalTextWidget(errorMessage));
      case LocationSearchSate:
        return _loadLocationSearchView();
      case const (SuccessState<Object>):
        return _loadLocationTree();
      case InitialState:
      case ContentState:
        if (_locationTreeCubit.listBreadCrumb.isNotEmpty && _locationTreeCubit.listBreadCrumb.last is SiteLocation) {
          SiteLocation location = _locationTreeCubit.listBreadCrumb.last as SiteLocation;
          scrollToLastCrumb(location.globalKey!, location.folderTitle!.length);
        }
        return _loadLocationTree();
      case MarkOfflineEnableState:
      case CheckboxClickState:
      case LocationUnMarkEnableState:
      case LocationUnMarkDeleteApprovalState:
        return _loadLocationTree(state);
      default:
        return Container(
          color: showList(context) ? AColors.white : AColors.iconGreyColor.withOpacity(0.4),
        );
    }
  }

  Widget _loadLocationTree([FlowState? state]) {
    bool isSelected = _locationTreeCubit.isParentLocationSelected();

    return IgnorePointer(
      ignoring: !showList(context),
      child: Container(
        decoration: BoxDecoration(color: showList(context) ? AColors.white : AColors.iconGreyColor.withOpacity(0.4)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 5),
                child: NormalTextWidget(
                  _locationUnMarkEnable ? context.toLocale!.lbl_offline_locations : context.toLocale!.lbl_header_location,
                  textAlign: TextAlign.left,
                  fontSize: 13,
                  color: AColors.iconGreyColor,
                  fontWeight: AFontWight.regular,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: showList(context) && MediaQuery.of(context).viewInsets.bottom <= 0,
                child: Container(
                  color: isSelected ? AColors.listItemSelected : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  width: double.maxFinite,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: NormalTextWidget(
                          getBreadCrumbTitle(_locationTreeCubit.listBreadCrumb.length - 1) ?? "",
                          textAlign: TextAlign.left,
                          color: isSelected ? AColors.iconGreyColor : AColors.textColor,
                          fontWeight: AFontWight.regular,
                        ),
                      ),
                      Visibility(
                        visible: isOnline && !_locationUnMarkEnable,
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.only(bottom: 1),
                            onPressed: _locationTreeCubit.listSiteLocation.isNotEmpty
                                ? () async {
                                    String? projectId = _locationTreeCubit.listSiteLocation.first.projectId;
                                    if (await _locationTreeCubit.isProjectLocationMarkedOffline(projectId)) {
                                      _showDialogOnAnyProjectMarked();
                                    } else {
                                      if (!_isEnableOfflineSelection) _locationTreeCubit.enableMarkOfflineSelection(true);
                                    }
                                    FireBaseEventAnalytics.setEvent(FireBaseEventType.locationTreeMarkOfflineSelect, FireBaseFromScreen.locationTree,bIncludeProjectName: true);
                                  }
                                : null,
                            icon: Icon(
                              semanticLabel: "CloudDownloadBtn",
                              Icons.cloud_download_outlined,
                            ),
                            color: AColors.iconGreyColor,
                            disabledColor: AColors.btnDisableClr,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: _isEnableOfflineSelection,
                child: Row(
                  children: [
                    ClickableTextWidget(
                      context.toLocale!.lbl_select_all,
                      isEnable: !_locationTreeCubit.isAllLocationSelectForOffline(),
                      onPressed: () {
                        _locationTreeCubit.locationCheckForOffline(true,screenName: FireBaseFromScreen.locationTree);
                        FireBaseEventAnalytics.setEvent(
                            FireBaseEventType.locationTreeSelectAll,
                            FireBaseFromScreen.locationTree,
                            bIncludeProjectName: true);
                      },
                    ),
                    const NormalTextWidget("/"),
                    ClickableTextWidget(
                      context.toLocale!.lbl_clear_all,
                      isEnable: (_locationTreeCubit.isOnlyOneLocationSelectForOffline()),
                      onPressed: () {
                        _locationTreeCubit.locationCheckForOffline(false,screenName: FireBaseFromScreen.locationTree);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    itemCount: _locationUnMarkEnable ? _locationTreeCubit.offlineSiteLocationListCount() : _locationTreeCubit.getCountSiteLocationList(),
                    itemBuilder: (BuildContext context, int index) {
                      List<SiteLocation> locationListToView;
                      if (_locationUnMarkEnable) {
                        locationListToView = _locationTreeCubit.offlineSiteLocationList();
                      } else {
                        locationListToView = _locationTreeCubit.listSiteLocation;
                      }
                      return _buildLocationList(locationListToView[index]);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationList(SiteLocation list) {
    bool isSelected = (list.folderId == _locationTreeCubit.selectedLocation?.folderId && !(_locationTreeCubit.selectedLocation!.hasSubFolder!));
    double deviceWidth = MediaQuery.of(context).size.width;
    bool isUnMarkLocationSelected = _locationUnMarkEnable && list.pfLocationTreeDetail!.locationId! == wantToDeleteLocationId && list.syncStatus != ESyncStatus.inProgress;
    // _locationTreeCubit.getCountForChildLocation(list);
    return Container(
      color: isSelected ? AColors.listItemSelected : Colors.transparent,
      child: Row(
        children: [
          Flexible(
            child: Stack(
              alignment: Directionality.of(context) == TextDirection.rtl ? Alignment.centerLeft : Alignment.centerRight,
              children: [
                Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration( border: Border(bottom: BorderSide(color: AColors.darkGreyColor)),),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          if (_isEnableOfflineSelection) {
                            return Checkbox(
                              key: const Key("OfflineCheckbox"),
                              value: (list.isCheckForMarkOffline ?? false) || (list.isMarkOffline ?? false),
                              onChanged: (list.isMarkOffline != null && list.isMarkOffline!)
                                  ? null
                                  : (value) {
                                      _locationTreeCubit.locationCheckForOffline(value!, location: list);
                                    },
                            );
                          } else if (list.isMarkOffline ?? false) {
                            if (list.syncStatus == ESyncStatus.inProgress) {
                              return _downloadingWidget(list);
                            } else if (list.syncStatus == ESyncStatus.success) {
                              return Semantics(label: "offline_pin", child: Icon(Icons.offline_pin, color: AColors.offlineSyncDoneColor));
                            } else if (list.syncStatus == ESyncStatus.failed) {
                              return const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              );
                            } else {
                              return const SizedBox(
                                width: 20.0,
                              );
                            }
                          } else {
                            return const SizedBox(
                              width: 20.0,
                            );
                          }
                        },
                      ),
                      Expanded(
                        // flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AListTile(
                              isSelected: (list.folderId == _locationTreeCubit.selectedLocation?.folderId && !(_locationTreeCubit.selectedLocation!.hasSubFolder!)),
                              onTap: () => {
                                if (_isEnableOfflineSelection)
                                  {
                                    if (list.isMarkOffline == null || !list.isMarkOffline!)
                                      {
                                        _locationTreeCubit.locationCheckForOffline(!(list.isCheckForMarkOffline ?? false), location: list),
                                      }
                                  }
                                else if (!_locationUnMarkEnable)
                                  {
                                    if (list.childLocation != null && list.childLocation!.isEmpty && !(list.hasSubFolder!))
                                      {
                                        _locationTreeCubit.setCurrentSiteLocation(list),
                                        openSitePlanView(),
                                        FireBaseEventAnalytics.setEvent(FireBaseEventType.selectLocation, FireBaseFromScreen.locationTree, bIncludeProjectName: true)
                                      }
                                    else
                                      {
                                        _locationTreeCubit.getLocationTree(location: list, isLoading: false),
                                        scrollToLastCrumb(list.globalKey!, list.folderTitle!.length),
                                        _locationTreeCubit.downloadLocationPdfXfdf(list),
                                      },
                                  }
                              },
                              title: list.folderTitle.toString(),
                            ),
                            // !Utility.isTablet && list.progress != null? showProjectSizeWithProgress(list.progress!, list!) :Container(),
                            // list.syncStatus == ESyncStatus.inProgress && list.progress != null? LinearProgressIndicator(value: (list.progress!) / 100, backgroundColor: AColors.offlineSyncProgressBarColor, color: AColors.offlineSyncProgressColor) : Container()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                  decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(5), color: AColors.deleteBannerBgGrey),
                  height: 50.0,
                  width: isUnMarkLocationSelected
                      ? (Utility.isTablet
                          ? (MediaQuery.of(context).orientation == Orientation.landscape)
                              ? deviceWidth / 4
                              : deviceWidth / 3
                          : deviceWidth)
                      : 0.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        flex: 7,
                        fit: FlexFit.tight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                width: 5.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(0), bottomLeft: Radius.circular(0)),
                                  color: AColors.userOnlineColor,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: BlocBuilder<LocationTreeCubit, FlowState>(builder: (context, state) {
                                        if (state is LocationUnMarkDeleteApprovalState) {
                                          return NormalTextWidget(context.toLocale!.lbl_remove_records, color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold, textAlign: TextAlign.left);
                                        }
                                        return NormalTextWidget(context.toLocale!.lbl_removing_records, color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold, textAlign: TextAlign.left);
                                      }),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Flexible(
                                        child: NormalTextWidget(
                                      context.toLocale!.lbl_including_sublocations,
                                      maxLines: 2,
                                      textAlign: TextAlign.left,
                                      color: AColors.textColor,
                                      fontSize: 13,
                                      fontWeight: AFontWight.regular,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Visibility(
                          visible: isUnMarkLocationSelected,
                          child: IconButton(
                            onPressed: () {
                              _locationTreeCubit.showLocationUnMarkConfirmation(0, false);
                            },
                            icon: const Icon(
                              Icons.close,
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
          Visibility(
            visible: _locationUnMarkEnable && (list.canRemoveOffline ?? false),
            child: Container(
              color: isUnMarkLocationSelected ? AColors.deleteBannerBgGrey : Colors.transparent,
              child: IconButton(
                  onPressed: () async {
                    if (isUnMarkLocationSelected && selected) {
                      aProgressDialog!.show();
                      _locationTreeCubit.refreshListOnDeleteAction(list, wantToDeleteLocationId);
                      FireBaseEventAnalytics.setEvent(
                          FireBaseEventType.locationTreeDeleteClick,
                          FireBaseFromScreen.locationTree,
                          bIncludeProjectName: true);
                    } else {
                      _locationTreeCubit.showLocationUnMarkConfirmation(list.pfLocationTreeDetail!.locationId ?? 0, true);
                    }
                  },
                  icon: const Icon(Icons.delete_outline_sharp),
                  color: isUnMarkLocationSelected ? AColors.userOnlineColor : AColors.grColorDark),
            ),
          ),
        ],
      ),
    );
  }

  String? getBreadCrumbTitle(int index) {
    if (_locationTreeCubit.listBreadCrumb.isNotEmpty) {
      if (_locationTreeCubit.listBreadCrumb[index] is Project) {
        return (_locationTreeCubit.listBreadCrumb[index] as Project).projectName!;
      } else if (_locationTreeCubit.listBreadCrumb[index] is SiteLocation) {
        return (_locationTreeCubit.listBreadCrumb[index] as SiteLocation).folderTitle!;
      }
    }
    return '';
  }

  Widget showProjectSizeWithProgress(double progress, SiteLocation project) {
    return progress != 100
        ? Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: NormalTextWidget(
              "$progress% of  ${Utility.getFileSizeWithMetaData(bytes: int.parse(project.locationSizeInByte!))}",
              fontSize: 13,
              fontWeight: AFontWight.regular,
              color: AColors.grColorDark,
            ),
          )
        : Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: NormalTextWidget(
              Utility.getFileSizeWithMetaData(bytes: int.parse(project.locationSizeInByte!)),
              fontSize: 13,
              fontWeight: AFontWight.regular,
              color: AColors.grColorDark,
            ),
          );
  }

  void openSitePlanView({FireBaseFromScreen screenName = FireBaseFromScreen.twoDPlan}) async {
    var arguments = _locationTreeCubit.setArgumentDataForLocation();
    closeLocationTreeDialog(result: arguments);
  }

  void closeLocationTreeDialog({Map<String, dynamic>? result}) {
    Navigator.of(context).pop(result);
  }

  void scrollUp() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  Future<void> scrollToLastCrumb(GlobalKey globalKey, [int length = 0]) async {
    await Future.delayed(const Duration(milliseconds: 100));
    double? width = globalKey.currentContext?.size?.width;
    width ??= length * 13;
    _horizontalScrollController.animateTo(_horizontalScrollController.position.maxScrollExtent + width, duration: const Duration(milliseconds: 100), curve: Curves.linear);
  }

  void getLocationData() async {
    await _locationTreeCubit.getDataFromArgument(widget.arguments);
    if (_isFrom == LocationTreeViewFrom.projectList) {
      FireBaseEventAnalytics.setEvent(FireBaseEventType.locationTreeSearch, FireBaseFromScreen.locationTree, bIncludeProjectName: true);
      _locationTreeCubit.getLocationTree();
      _locationTreeCubit.clearAllData();
      _locationTreeCubit.addBreadCrumbItemToList(_locationTreeCubit.project);
    } else {
      if (_locationTreeCubit.listBreadCrumb.last is SiteLocation) {
        _locationTreeCubit.getLocationTree(location: _locationTreeCubit.listBreadCrumb.last, isLoading: true);
      } else {
        _locationTreeCubit.getLocationTree();
      }
    }
  }

  Widget locationTreeSearch() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: IgnorePointer(
              ignoring: _isEnableOfflineSelection || _locationUnMarkEnable,
              child: CustomSearchSuggestionView<SearchDropdownList>(
                key: const Key("searchBoxLocationList"),
                textFieldConfiguration: SearchTextFormFieldConfiguration(
                  controller: _searchLocationController,
                  focusNode: _searchFocusNode,
                  textInputAction: TextInputAction.search,
                  suffixIconOnClick: () {
                    FocusScope.of(context).unfocus();
                    _searchLocationController.clear();
                    _locationTreeCubit.onClearSearch();
                    _searchFocusNode.unfocus();
                  },
                  onSubmitted: (value) async {
                    context.closeKeyboard();
                    if (value.trim().isNotEmpty) {
                      await _locationTreeCubit.addRecentProject(newSearch: value);
                      await _locationTreeCubit.getSearchList(value);
                    } else {
                      _locationTreeCubit.setLocationTreeState();
                    }
                  },
                ),
                suggestionsCallback: (value) async {
                  searchString = value.trim();
                  highlightSearch = searchString;
                  if (showList(context)) {
                    return [];
                  } else {
                    if (value.isEmpty && showList(context)) {
                      return _locationTreeCubit.recentList;
                    } else {
                      if (value.trim().length >= 3) {
                        return await _locationTreeCubit.getSuggestedSearchList(value.toLowerCase());
                      } else if (value.trim().length <= 2) {
                        _locationTreeCubit.changeSearchMode(LocationSearchMode.recentSearches);
                        _locationTreeCubit.setLocationTreeState();
                        return _locationTreeCubit.recentList;
                      } else {
                        return [];
                      }
                    }
                  }
                },
                currentSearchHeader: BlocBuilder<LocationTreeCubit, FlowState>(
                    buildWhen: (prev, current) => current is LocationSearchSuggestionMode,
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NormalTextWidget(
                          _locationTreeCubit.searchMode == LocationSearchMode.recentSearches ? context.toLocale!.text_recent_searches : context.toLocale!.text_suggested_searches,
                          fontWeight: AFontWight.regular,
                          fontSize: 13,
                          color: AColors.iconGreyColor,
                        ),
                      );
                    }),
                itemBuilder: (context, suggestion, suggestionsCallback) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 18.0, end: 16.0, top: 0.0, bottom: 0.0),
                          child: _locationTreeCubit.searchMode == LocationSearchMode.suggestedSearches
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                          text: TextSpan(
                                            style: DefaultTextStyle.of(context).style,
                                            children: Utility.getTextSpans(suggestion.searchKey!, highlightSearch),
                                          ),
                                          maxLines: 1,
                                          strutStyle: StrutStyle(fontFamily: AFonts.fontFamily, forceStrutHeight: true, fontSize: 16, fontStyle: FontStyle.normal)),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            color: AColors.lightGreyColor,
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          Flexible(
                                            child: RichText(
                                                text: TextSpan(
                                                  style: DefaultTextStyle.of(context).style,
                                                  children: Utility.getTextSpans(suggestion.searchKey!, highlightSearch),
                                                ),
                                                maxLines: 1,
                                                strutStyle: StrutStyle(fontFamily: AFonts.fontFamily, forceStrutHeight: true, fontSize: 16, fontStyle: FontStyle.normal)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        await _locationTreeCubit.removeLocationFromRecentSearch(newSearch: suggestion.searchKey!);

                                        await suggestionsCallback();

                                        _locationTreeCubit.setLocationTreeState();
                                        if (_locationTreeCubit.recentList.isEmpty) {
                                          _searchLocationController.clear();
                                          _searchFocusNode.unfocus();
                                          _locationTreeCubit.setLocationTreeState();
                                        }
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        color: AColors.iconGreyColor,
                                        size: 24,
                                      ),
                                    )
                                  ],
                                ),
                        ),
                      )
                    ],
                  );
                },
                onSuggestionSelected: (suggestion) async {
                  _searchLocationController.text = suggestion.searchKey!;
                  searchString = suggestion.searchKey!;
                  highlightSearch = searchString;
                  await _locationTreeCubit.getSearchList(suggestion.searchKey!.toLowerCase());
                  FireBaseEventAnalytics.setEvent(FireBaseEventType.locationTreeSearch, FireBaseFromScreen.locationTree, bIncludeProjectName: true);
                  if (_locationTreeCubit.searchMode == LocationSearchMode.suggestedSearches) {
                    if (searchString.trim().isNotEmpty) {
                      await _locationTreeCubit.addRecentProject(newSearch: searchString);
                    }
                  }
                },
              ),
            ),
          ),
          Visibility(
            child: IgnorePointer(
              ignoring: !isOnline || _isEnableOfflineSelection,
              child: IconButton(
                  onPressed: (_locationTreeCubit.isOfflineLocationAvailableForDelete())
                      ? () {
                          wantToDeleteLocationId = 0;
                          _locationTreeCubit.enableUnMarkOfflineSelection(!_locationUnMarkEnable);
                        }
                      : null,
                  icon: Icon(
                    semanticLabel: "deleteFolderIcon",
                    Icons.folder_delete_outlined,
                    color: ((!_locationTreeCubit.isOfflineLocationAvailableForDelete() || _isEnableOfflineSelection) ? AColors.btnDisableClr : (_locationUnMarkEnable ? AColors.offlineSyncDoneColor : AColors.grColorDark)),
                  )),
            ),
            visible: isOnline,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
          ),
        ],
      ),
    );
  }

  Widget _loadLocationSearchView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          NormalTextWidget(
            context.toLocale!.lbl_results,
            textAlign: TextAlign.left,
            fontSize: 13,
            color: AColors.iconGreyColor,
            fontWeight: AFontWight.regular,
          ),
          Expanded(
            child: _locationTreeCubit.searchLocationList.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    itemCount: _locationTreeCubit.searchLocationList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildSearchList(_locationTreeCubit.searchLocationList[index]);
                    })
                : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchList(SearchLocationData listItem) {
    return ASearchListTile(
      searchTitle: listItem.searchTitle,
      onTap: () async => {_locationTreeCubit.getLocationDetailsAndNavigateFromSearch(listItem.id!)},
      locationPath: listItem.value,
    );
  }

  bool showList(BuildContext context) {
    return !_searchFocusNode.hasFocus;
  }

  Future<void> startSyncForSelectedLocation(downloadSizeResponse) async {
    if (_locationTreeCubit.listBreadCrumb.isNotEmpty) {
      if (_locationTreeCubit.listBreadCrumb[0] is Project) {
        Project project = _locationTreeCubit.listBreadCrumb[0];
        List<SyncRequestLocationVo> syncLocationList = [];
        bool includeAttachments = await StorePreference.isIncludeAttachmentsSyncEnabled();
        int? downloadSize = await _locationTreeCubit.getSyncProjectSize(projectId: project.projectID!);
        for (var element in _locationTreeCubit.listSiteLocation) {
          if ((element.isCheckForMarkOffline ?? false) && !(element.isMarkOffline ?? false)) {
            element.canRemoveOffline = true;
            element.isMarkOffline = true;
            element.syncStatus = ESyncStatus.inProgress;
            SyncRequestLocationVo syncRequestLocationVo = SyncRequestLocationVo()
              ..folderId = element.folderId?.plainValue()
              ..folderTitle = element.folderTitle?.plainValue()
              ..locationId = element.pfLocationTreeDetail?.locationId.toString()
              ..lastSyncTime = element.lastSyncTimeStamp
              ..isPlanOnly = true;
            syncLocationList.add(syncRequestLocationVo);
          }
        }

        SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
          ..syncRequestId = DateTime.now().millisecondsSinceEpoch
          ..projectId = project.projectID?.plainValue()
          ..projectName = project.projectName?.plainValue()
          ..isMarkOffline = true
          ..isMediaSyncEnable = includeAttachments
          ..syncRequestLocationList = syncLocationList
          ..projectSizeInByte = downloadSize.toString()
          ..eSyncType = ESyncType.siteLocation;

        _syncCubit?.syncProjectData({"buildFlavor": AConstants.buildFlavor!, "tab": AConstants.siteTab, "syncRequest": jsonEncode(syncRequestTask)}, context: context);
      }
    }
    _locationTreeCubit.enableMarkOfflineSelection(false);
  }

  _downloadingWidget(SiteLocation siteLocation) {
    int index = 0;
    if (siteLocation.progress != null) {
      if (siteLocation.progress! > 75) {
        index = 4;
      } else if (siteLocation.progress! <= 75 && siteLocation.progress! > 50) {
        index = 3;
      } else if (siteLocation.progress! <= 50 && siteLocation.progress! > 25) {
        index = 2;
      } else if (siteLocation.progress! <= 25 && siteLocation.progress! > 0) {
        index = 1;
      }
    }

    return ImageSequenceAnimation(imagePath: imageSeqCubit.imagePaths[index], currentIndex: index);
  }

  void _showDialogOnAnyProjectMarked() {
    showDialog(
        context: context,
        builder: (context) {
          return const Dialog(
            insetPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: ProjectAlreadyMarkOffline(),
          );
        });
  }

  _showDownloadDialog(BuildContext context) async {
    // Log.d("Selected location ${_locationTreeCubit.offlineSiteLocationIdList()}");
    await showDialog(
        context: this.context,
        builder: (context) {
          return Dialog(
            key: Key("DownloadSize Dialog"),
            insetPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: ProjectDownloadSizeWidget(strProjectId: _locationTreeCubit.project!.projectID!, locationId: _locationTreeCubit.offlineSiteLocationIdList()),
          );
        }).then((value) async {
      if (value != null && value is int) {
        startSyncForSelectedLocation(value);
      } else {
        _locationTreeCubit.deleteSyncSize(_locationTreeCubit.project!.projectID!, _locationTreeCubit.offlineSiteLocationIdList());
      }
    });
  }
}
