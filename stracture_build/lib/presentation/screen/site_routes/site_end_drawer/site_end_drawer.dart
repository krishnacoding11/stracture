import 'dart:async';
import 'dart:convert';

import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/bloc/sitetask/unique_value_cubit.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/site_end_drawer_filter.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/custom_material_button_widget.dart';
import 'package:field/widgets/custom_search_view/custom_search_view.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/pagination_view/pagination_view.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/site/create_form_selection_cubit.dart';
import '../../../../bloc/sitetask/sitetask_state.dart';
import '../../../../bloc/sitetask/toggle_cubit.dart';
import '../../../../data/model/apptype_vo.dart';
import '../../../../domain/common/create_form_helper.dart';
import '../../../../enums.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/file_form_utility.dart';
import '../../../../utils/site_utils.dart';
import '../../../../widgets/overlay_banner.dart';
import '../../../../widgets/tooltip_dialog/tooltip_dialog.dart';
import '../../webview/asite_formwebview.dart';
import '../create_form_dialog/task_type_dialog.dart';

class SiteEndDrawerWidget extends StatefulWidget {
  dynamic isFromFormCreate;
  final SiteLocation? obj;
  final Function onClose;
  final AnimationStatus animationStatus;
  String? selectedFormId = "";
  final bool fromFilter;
  String? selectedFormCode = "";

  SiteEndDrawerWidget({Key? key, this.isFromFormCreate, this.selectedFormId, this.selectedFormCode, this.fromFilter = false, required this.obj, required this.onClose, required this.animationStatus}) : super(key: key);

  @override
  State<SiteEndDrawerWidget> createState() => _SiteEndDrawerWidgetState();
}

class _SiteEndDrawerWidgetState extends State<SiteEndDrawerWidget> {
  late SiteTaskCubit _siteTaskCubit;
  TextEditingController creationDate = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? dueDate;
  bool fullDrawer = false;
  double fullWidth = 0.0;
  bool isAttachmentRefresh = false;
  late final ScrollController paginationScrollController;
  late final ScrollController animatedScrollController;
  final TooltipController _tooltipController = TooltipController();
  double position = 0.0;
  late GlobalKey pWebViewKey;
  late GlobalKey filterKey;
  late UniqueValueCubit _uniqueValueCubit;
  late ToggleCubit _toggleEmptyMessageCubit;
  late PlanCubit _planCubit;
  OverlayState? overlayState;
  OverlayEntry? overlay1;
  bool noPlanVisibility = false;
  Timer? _timer;
  bool _isSearch = false;
  bool _showSearchFilter = false;
  String highlightSearch = "";
  var searchString = '';

  @override
  void initState() {
    animatedScrollController = getIt<ScrollController>();
    paginationScrollController = ScrollController();
    _siteTaskCubit = getIt<SiteTaskCubit>();
    if (!SiteUtility.isLocationHasPlan(widget.obj)) {
      fullDrawer = true;
    }
    if (widget.fromFilter) {
      _siteTaskCubit.setDrawerValue(StackDrawerOptions.filter);
    } else {
      _siteTaskCubit.setDrawerValue(StackDrawerOptions.drawerBody);
    }
    _toggleEmptyMessageCubit = getIt<ToggleCubit>();
    _uniqueValueCubit = getIt<UniqueValueCubit>();
    pWebViewKey = GlobalKey();
    filterKey = GlobalKey();
    _siteTaskCubit.setCurrentLocation(widget.obj);
    _planCubit = context.read<PlanCubit>();
    _siteTaskCubit.setCurrentProject(_planCubit.project);
    _siteTaskCubit.setSummaryFilterValue(_planCubit.getSummaryFilterValue());

    if (widget.isFromFormCreate == FromScreen.dashboard || widget.isFromFormCreate == FromScreen.qrCode || (!SiteUtility.isLocationHasPlan(_planCubit.selectedLocation) && _siteTaskCubit.totalCount == 0)) {
      fullDrawer = true;
      if (!widget.selectedFormId.isNullOrEmpty()) {
        _siteTaskCubit.setSelectedFormId(widget.selectedFormId);
      }
    } else if (widget.isFromFormCreate == FromScreen.listing && !widget.selectedFormId.isNullOrEmpty()) {
      _siteTaskCubit.setSelectedFormId(widget.selectedFormId);
    }
    if (!widget.selectedFormCode.isNullOrEmpty()) _siteTaskCubit.setSelectedFormCode(widget.selectedFormCode);
    // <---- Notice the new variable here.
    if (_planCubit.selectedLocation != null && !SiteUtility.isLocationHasPlan(_planCubit.selectedLocation)) {
      _timer = Timer(const Duration(milliseconds: 500), () {
        overlayState = Overlay.of(context);
        overlay1 = overlayBanner(context, context.toLocale!.lbl_location_plan_unavailable, context.toLocale!.lbl_location_does_not_plan_associated, Icons.warning, AColors.bannerWaringColor, isCloseManually: true, onTap: () {
          overlay1!.remove();
        });
        overlayState!.insert(overlay1!);
      });
    }
    paginationScrollController.addListener(() {
      if (!Utility.isTablet) {
        if (paginationScrollController.position.userScrollDirection == ScrollDirection.reverse) {
          if (animatedScrollController.hasClients) {
            animatedScrollController.animateTo(
              animatedScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        }
        if (paginationScrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (animatedScrollController.hasClients) {
            animatedScrollController.animateTo(
              animatedScrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        }
      }
    });
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.trim().isNotEmpty) {
        _showSearchFilter = true;
        setState(() {});
      } else {
        _showSearchFilter = false;
        setState(() {});
      }
    });
    super.initState();
  }

  refreshPagination() {
    _uniqueValueCubit.updateValue();
  }

  updateForStatusValue(SiteForm siteForm) {
    _siteTaskCubit.updateItemValues(siteForm);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    paginationScrollController.dispose();
    if (_timer != null) {
      _timer?.cancel();
    }
    if (overlay1 != null && overlay1!.mounted) {
      overlay1!.remove();
    }
    _planCubit.isFromScreen = FromScreen.listing;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget = Stack(
      children: [
        Container(
          margin: EdgeInsetsDirectional.only(start: (Utility.isTablet || MediaQuery.of(context).orientation == Orientation.landscape) ? 30.0 : 0),
          child: _getSidebarMenuWidget(context),
        ),
        /*PositionedDirectional(
          start: (Utility.isTablet || MediaQuery.of(context).orientation == Orientation.landscape) ? 0 : 15,
          top: 15,
          child: AnimatedOpacity(
            opacity: Utility.isTablet && fullDrawer ? 0.0 : 1.0,
            duration: const Duration(seconds: 1),
            child: FloatingActionButton(
              key: const Key("drawerClosBtn"),
              backgroundColor: AColors.themeBlueColor,
              elevation: 8,
              onPressed: () async {
                if (!Utility.isTablet) {
                  if (paginationScrollController.hasClients) {
                    paginationScrollController.jumpTo(paginationScrollController.position.minScrollExtent);
                    FireBaseEventAnalytics.setEvent(
                        FireBaseEventType.siteListingDrawerToggle,
                        FireBaseFromScreen.twoDPlan,
                        bIncludeProjectName: true);
                  }
                  if (animatedScrollController.hasClients) {
                    animatedScrollController.animateTo(
                      animatedScrollController.position.minScrollExtent,
                      duration: const Duration(seconds: 4),
                      curve: Curves.linear,
                    );
                  }
                }
                context.closeKeyboard();
                widget.onClose();

                if (!Utility.isTablet && _siteTaskCubit.selectedItem != null && _planCubit.highLightFormId != _siteTaskCubit.selectedItem!.formId) {
                  await _planCubit.refreshPinsAndHighLight({"formId": _siteTaskCubit.selectedItem!.formId}, refreshTaskList: false);
                }
              },
              child: const Icon(
                Icons.chevron_right,
                color: AColors.white,
              ),
            ),
          ),
        ),*/
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _siteTaskCubit),
        BlocProvider(create: (context) => _toggleEmptyMessageCubit),
        BlocProvider(create: (context) => _uniqueValueCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<PlanCubit, FlowState>(
              listenWhen: (previous, current) => current is RefreshSiteTaskListItemState || current is SelectedFormDataState,
              listener: (_, state) {
                if (state is RefreshSiteTaskListItemState) {
                  pWebViewKey = GlobalKey();
                  updateForStatusValue(state.siteForm!);
                } else if (state is SelectedFormDataState) {
                  _siteTaskCubit.setCurrentPinSelectLocation(state.observationData.locationDetailVO?.locationId ?? 0);
                  widget.selectedFormId = state.observationData.formId;
                  _siteTaskCubit.highLightSelectedFormData(state.observationData);
                }
              }),
          BlocListener<SiteTaskCubit, FlowState>(
              listenWhen: (previous, current) => current is FormItemViewState || current is ScrollState || current is RefreshWebViewGlobalKeyState || current is RefreshSiteTaskListItemState,
              listener: (_, state) async {
                if (state is RefreshSiteTaskListItemState && state.siteForm == null) {
                  refreshPagination();
                } else if (state is FormItemViewState && !Utility.isTablet) {
                  Color? headerIconColor = (state.headerIconColor != "") ? state.headerIconColor.toColor() : null;
                  await FileFormUtility.showFileFormViewDialog(context, frmViewUrl: state.frmViewUrl, data: state.webviewData, color: headerIconColor, callback: (value) {
                    if (value is Map && value.isNotEmpty) {
                      Map<String, dynamic> dict = json.decode(json.encode(value)) as Map<String, dynamic>;
                      String projectId = dict['projectId'] as String;
                      String formId = dict['formId'] as String;
                      bool isCopySiteTask = dict['isCopySiteTask'] ?? false;
                      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
                        if (dict.containsKey('isFromDiscardDraft')) {
                          bool isFromDiscardDraft = dict['isFromDiscardDraft'];
                          if (isFromDiscardDraft == true) {
                            _planCubit.refreshPins();
                            _planCubit.refreshSiteTaskList();
                          }
                        } else if (isCopySiteTask) {
                          await _planCubit.refreshPinsAndHighLight({"formId": formId});
                        } else {
                          await _planCubit.getUpdatedSiteTaskItem(projectId, formId.plainValue());
                        }
                      });
                    }
                  });
                } else if (state is ScrollState) {
                  if (widget.isFromFormCreate == FromScreen.dashboard || widget.isFromFormCreate == FromScreen.qrCode || state.isScrollRequired) {
                    final item = _siteTaskCubit.loadedItems.indexWhere((element) => element.item.formId == widget.selectedFormId);
                    double? height = 160; // 138; // pHeight.currentContext?.size?.height??;
                    height = (height * item);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (paginationScrollController.hasClients) {
                        paginationScrollController.animateTo(height!, duration: Duration(seconds: 2), curve: Curves.linear);
                      }
                    });
                  }
                } else if (state is RefreshWebViewGlobalKeyState) {
                  pWebViewKey = GlobalKey();
                }
              })
        ],
        child: contentWidget,
      ),
    );
  }

  Widget _getSidebarMenuWidget(BuildContext context) {
    if (widget.animationStatus == AnimationStatus.reverse) {
      fullDrawer = false;
      fullWidth = 0.0;
    }
    double width = MediaQuery.of(context).size.width;
    final mediaQueryData = MediaQuery.of(context);
    if (mediaQueryData.orientation == Orientation.landscape && fullDrawer) {
      setState(() {
        fullWidth = (width * 62) / 100;
      });
    } else if (mediaQueryData.orientation == Orientation.portrait && fullDrawer) {
      setState(() {
        fullWidth = (width * 62) / 100;
      });
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (Utility.isTablet && fullDrawer == false)
          BlocBuilder<SiteTaskCubit, FlowState>(
              buildWhen: (previous, current) => current is SortChangeState || current is TaskListCountUpdateState || current is StackDrawerState,
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (_siteTaskCubit.getDrawerValue() != StackDrawerOptions.drawerBody) {
                            _siteTaskCubit.setDrawerValue(StackDrawerOptions.drawerBody);
                          } else {
                            if (Utility.isTablet) {
                              context.closeKeyboard();
                              if (fullWidth <= 0.0) {
                                setState(() {
                                  fullDrawer = true;
                                  fullWidth = (width * 62) / 100;
                                });
                              }
                              pWebViewKey = GlobalKey();
                            }
                            if (!isNetWorkConnected() && (_siteTaskCubit.selectedItem?.templateType.isXSN ?? false)) {
                              Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
                            } else {
                              await _siteTaskCubit.onFormItemClicked(_siteTaskCubit.selectedItem ?? SiteForm());
                              if (!Utility.isTablet && _siteTaskCubit.selectedItem != null && _planCubit.highLightFormId != _siteTaskCubit.selectedItem!.formId) {
                                await _planCubit.refreshPinsAndHighLight({"formId": _siteTaskCubit.selectedItem?.formId}, refreshTaskList: false);
                              }
                            }
                          }
                        },
                        child: Container(
                          height: 55,
                          width: 48,
                          decoration: BoxDecoration(
                            color: AColors.themeBlueColor,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(5),
                            ),
                          ),
                          child: ImageIcon(
                            AssetImage(
                              Utility.isTablet ? AImageConstants.tabletSidebarIcon : AImageConstants.openSidebarIcon,
                            ),
                            color: AColors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<SiteTaskCubit, FlowState>(
                        buildWhen: (previous, current) => current is DefaultFormCodeFilterState,
                        builder: (context, state) {
                          if (state is DefaultFormCodeFilterState && state.isFormCodeFilterApply) {
                            return SizedBox.shrink();
                          }
                          return CustomMaterialButtonWidget(
                            color: AColors.greyColor,
                            elevation: 4,
                            onPressed: () async {
                              if (_siteTaskCubit.getDrawerValue() == StackDrawerOptions.drawerBody) {
                                _siteTaskCubit.setDrawerValue(StackDrawerOptions.filter);
                              } else {
                                if (!Utility.isTablet) {
                                  if (paginationScrollController.hasClients) {
                                    paginationScrollController.jumpTo(paginationScrollController.position.minScrollExtent);
                                  }
                                  if (animatedScrollController.hasClients) {
                                    animatedScrollController.animateTo(
                                      animatedScrollController.position.minScrollExtent,
                                      duration: const Duration(seconds: 4),
                                      curve: Curves.linear,
                                    );
                                  }
                                }
                                context.closeKeyboard();
                                widget.onClose();
                                if (!Utility.isTablet && _siteTaskCubit.selectedItem != null && _planCubit.highLightFormId != _siteTaskCubit.selectedItem!.formId) {
                                  await _planCubit.refreshPinsAndHighLight({"formId": _siteTaskCubit.selectedItem!.formId}, refreshTaskList: false);
                                }
                              }
                            },
                            height: 55,
                            width: 48,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(5),
                              ),
                            ),
                            child: ImageIcon(
                              AssetImage(
                                _siteTaskCubit.filterApplied ? AImageConstants.closeAppliedFilterIcon : AImageConstants.closeFilterIcon,
                              ),
                              size: 30,
                              color: AColors.themeBlueColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
        Container(
          color: AColors.filterBgColor,
          width: Utility.isTablet && fullDrawer == true
              ? MediaQuery.of(context).orientation == Orientation.landscape
                  ? (width * 38) / 100
                  : (width * 40) / 100
              : Utility.isTablet
                  ? MediaQuery.of(context).orientation == Orientation.landscape
                      ? width / 3
                      : width / 2
                  : MediaQuery.of(context).orientation == Orientation.landscape
                      ? width / 2
                      : width,
          child: Column(
            children: [
              BlocBuilder<SiteTaskCubit, FlowState>(
                buildWhen: (previous, current) => current is DefaultFormCodeFilterState || current is StackDrawerState,
                builder: (context, state) {
                  if (state is DefaultFormCodeFilterState && state.isFormCodeFilterApply) {
                    _siteTaskCubit.applyStaticFilter = true;
                    _planCubit.emitState(AppliedStaticFilter(true));
                    refreshPagination();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomMaterialButtonWidget(
                            color: AColors.themeBlueColor,
                            elevation: 0,
                            onPressed: () async {
                              if (Utility.isTablet && fullDrawer) {
                                fullDrawer = false;
                                fullWidth = 0.0;
                                setState(() {});
                              } else {
                                if (!Utility.isTablet) {
                                  if (paginationScrollController.hasClients) {
                                    paginationScrollController.jumpTo(paginationScrollController.position.minScrollExtent);
                                  }
                                  if (animatedScrollController.hasClients) {
                                    animatedScrollController.animateTo(
                                      animatedScrollController.position.minScrollExtent,
                                      duration: const Duration(seconds: 4),
                                      curve: Curves.linear,
                                    );
                                  }
                                }
                                context.closeKeyboard();
                                widget.onClose();
                                if (!Utility.isTablet && _siteTaskCubit.selectedItem != null && _planCubit.highLightFormId != _siteTaskCubit.selectedItem!.formId) {
                                  await _planCubit.refreshPinsAndHighLight({"formId": _siteTaskCubit.selectedItem!.formId}, refreshTaskList: false);
                                }
                              }
                            },
                            height: 55,
                            width: 48,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(5),
                              ),
                            ),
                            child: Utility.isTablet && fullDrawer == false
                                ? Icon(
                                    Icons.close,
                                    color: AColors.white,
                                    size: 30,
                                  )
                                : ImageIcon(
                                    AssetImage(AImageConstants.closeSidebarIcon),
                                    color: AColors.white,
                                    size: 50,
                                  ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: NormalTextWidget(
                              context.toLocale!.form_code + ": " + state.formCode,
                              key: const Key('key_default_form_code_filter'),
                              fontWeight: AFontWight.light,
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                              color: AColors.textColor,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right: Utility.isTablet
                                    ? fullDrawer
                                        ? 18
                                        : 26
                                    : 15),
                            child: InkWell(
                              onTap: () async {
                                _siteTaskCubit.applyStaticFilter = false;
                                await _planCubit.refreshPinsAndHighLight({"formId": ""}, refreshTaskList: true, isShowProgressDialog: false);
                                _siteTaskCubit.clearDefaultFormCodeFilter();
                              },
                              child: Icon(
                                Icons.clear,
                                color: AColors.iconGreyColor,
                                size: 24,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    if (state.props[0] == StackDrawerOptions.filter) {
                      return SizedBox.shrink();
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMaterialButtonWidget(
                                color: AColors.themeBlueColor,
                                elevation: 0,
                                onPressed: () async {
                                  if (Utility.isTablet && fullDrawer) {
                                    fullDrawer = false;
                                    fullWidth = 0.0;
                                    setState(() {});
                                  } else {
                                    if (!Utility.isTablet) {
                                      if (paginationScrollController.hasClients) {
                                        paginationScrollController.jumpTo(paginationScrollController.position.minScrollExtent);
                                      }
                                      if (animatedScrollController.hasClients) {
                                        animatedScrollController.animateTo(
                                          animatedScrollController.position.minScrollExtent,
                                          duration: const Duration(seconds: 4),
                                          curve: Curves.linear,
                                        );
                                      }
                                    }
                                    context.closeKeyboard();
                                    widget.onClose();
                                    if (!Utility.isTablet && _siteTaskCubit.selectedItem != null && _planCubit.highLightFormId != _siteTaskCubit.selectedItem!.formId) {
                                      await _planCubit.refreshPinsAndHighLight({"formId": _siteTaskCubit.selectedItem!.formId}, refreshTaskList: false);
                                    }
                                  }
                                },
                                height: 55,
                                width: 48,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(5),
                                  ),
                                ),
                                child: Utility.isTablet && fullDrawer == false
                                    ? Icon(
                                        Icons.close,
                                        color: AColors.white,
                                        size: 30,
                                      )
                                    : ImageIcon(
                                        AssetImage(AImageConstants.closeSidebarIcon),
                                        color: AColors.white,
                                        size: 50,
                                      )),
                            SizedBox(width: 10),
                            if (_isSearch)
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_showSearchFilter)
                                      CustomMaterialButtonWidget(
                                        color: AColors.white,
                                        elevation: 0,
                                        onPressed: () {
                                          context.closeKeyboard();
                                          if (_siteTaskCubit.loadedItems.isNotEmpty) {
                                            SiteTaskCubit.sortOrder = !SiteTaskCubit.sortOrder;
                                            _siteTaskCubit.emitState(SortChangeState());
                                            refreshPagination();
                                          }
                                        },
                                        height: 55,
                                        width: 50,
                                        child: ImageIcon(
                                          AssetImage(
                                            SiteTaskCubit.sortOrder ? AImageConstants.descendingOrderIcon : AImageConstants.ascendingOrderIcon,
                                          ),
                                          size: 24,
                                          color: AColors.themeBlueColor,
                                        ),
                                      ),
                                    if (_showSearchFilter) SizedBox(width: 10),
                                    if (!Utility.isTablet && _showSearchFilter)
                                      CustomMaterialButtonWidget(
                                        color: AColors.white,
                                        elevation: 0,
                                        onPressed: () {
                                          context.closeKeyboard();
                                          _siteTaskCubit.setDrawerValue(StackDrawerOptions.filter);
                                        },
                                        height: 55,
                                        width: 50,
                                        child: ImageIcon(
                                          AssetImage(
                                            _siteTaskCubit.filterApplied ? AImageConstants.appliedFilterIcon : AImageConstants.filterIcon,
                                          ),
                                          size: 24,
                                          color: AColors.themeBlueColor,
                                        ),
                                      )
                                    else if (Utility.isTablet && fullDrawer == true && _showSearchFilter)
                                      CustomMaterialButtonWidget(
                                        color: AColors.white,
                                        elevation: 0,
                                        onPressed: () {
                                          context.closeKeyboard();
                                          _siteTaskCubit.setDrawerValue(StackDrawerOptions.filter);
                                        },
                                        height: 55,
                                        width: 50,
                                        child: ImageIcon(
                                          AssetImage(
                                            _siteTaskCubit.filterApplied ? AImageConstants.appliedFilterIcon : AImageConstants.filterIcon,
                                          ),
                                          size: 24,
                                          color: AColors.themeBlueColor,
                                        ),
                                      ),
                                    if (!Utility.isTablet && _showSearchFilter) SizedBox(width: 10) else if (Utility.isTablet && fullDrawer == true && _showSearchFilter) SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                          height: 60,
                                          padding: EdgeInsets.only(
                                              right: Utility.isTablet
                                                  ? fullDrawer
                                                      ? 18
                                                      : 26
                                                  : 15),
                                          child: BlocBuilder<SiteTaskCubit, FlowState>(builder: (context, state) {
                                            return Container(
                                              color: AColors.white,
                                              child: CustomSearchSuggestionView<SiteForm>(
                                                key: const Key("searchBoxSiteTaskList"),
                                                placeholder: context.toLocale!.search_for,
                                                hideSuggestionsOnKeyboardHide: true,
                                                textFieldConfiguration: SearchTextFormFieldConfiguration(
                                                  controller: _searchController,
                                                  focusNode: _searchFocusNode,
                                                  textInputAction: TextInputAction.search,
                                                  suffixIconOnClick: () async {
                                                    _searchController.clear();
                                                    _showSearchFilter = false;
                                                    searchString = "";
                                                    context.closeKeyboard();
                                                    highlightSearch = "";
                                                    setFormTitleFilterValue(searchString);
                                                    refreshPagination();
                                                    _toggleEmptyMessageCubit.toggleChange(!searchString.toString().isNullOrEmpty());
                                                    _isSearch = false;
                                                    setState(() {});
                                                  },
                                                  onSubmitted: (value) async {
                                                    setFormTitleFilterValue(value);
                                                    refreshPagination();
                                                    _toggleEmptyMessageCubit.toggleChange(!value.toString().isNullOrEmpty());
                                                  },
                                                ),
                                                suggestionsCallback: (value) async {
                                                  searchString = value.trim();
                                                  if (!_searchFocusNode.hasFocus) {
                                                    return [];
                                                  } else {
                                                    if (value.isEmpty && !_searchFocusNode.hasFocus) {
                                                      _siteTaskCubit.setSearchMode = SearchMode.recent;
                                                      List<String> list = await _siteTaskCubit.getRecentSearchedSiteList();
                                                      List<SiteForm> siteFormList = list.map((e) => SiteForm(title: e)).toList();
                                                      return siteFormList;
                                                    } else {
                                                      highlightSearch = searchString;
                                                      if (value.trim().length >= 3) {
                                                        _siteTaskCubit.setSearchMode = SearchMode.suggested;
                                                        setFormTitleFilterValue(searchString);
                                                        final list = await _siteTaskCubit.pageFetch(0);
                                                        List<SiteForm> siteFormList = list.map((e) => e.item).toList();
                                                        return siteFormList;
                                                      } else if (value.trim().length <= 2) {
                                                        _siteTaskCubit.setSearchMode = SearchMode.recent;
                                                        List<String> list = await _siteTaskCubit.getRecentSearchedSiteList();
                                                        List<SiteForm> siteFormList = list.map((e) => SiteForm(title: e)).toList();
                                                        return siteFormList;
                                                      } else {
                                                        return [];
                                                      }
                                                    }
                                                  }
                                                },
                                                currentSearchHeader: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: NormalTextWidget(
                                                    _siteTaskCubit.getSearchMode == SearchMode.recent ? context.toLocale!.text_recent_searches : context.toLocale!.text_suggested_searches,
                                                    fontWeight: AFontWight.regular,
                                                    fontSize: 13,
                                                    color: AColors.iconGreyColor,
                                                  ),
                                                ),
                                                itemBuilder: (context, suggestion, suggestionsCallback) {
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 40,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 18.0, right: 16.0, top: 0.0, bottom: 0.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                    style: DefaultTextStyle.of(context).style,
                                                                    children: Utility.getTextSpans(suggestion.title ?? "", highlightSearch),
                                                                  ),
                                                                  maxLines: 1,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                onSuggestionSelected: (suggestion) async {
                                                  searchString = suggestion.title!.trim();
                                                  _searchController.text = searchString;
                                                  if (searchString.isNotEmpty) {
                                                    highlightSearch = searchString;
                                                    List<String> list = await _siteTaskCubit.getRecentSearchedSiteList();
                                                    list.add(searchString);
                                                    await _siteTaskCubit.saveRecentSearchSiteList(list.toSet().toList());
                                                    setFormTitleFilterValue(searchString);
                                                    refreshPagination();
                                                    _toggleEmptyMessageCubit.toggleChange(
                                                      !searchString.toString().isNullOrEmpty(),
                                                    );
                                                  }
                                                },
                                                noItemsFoundBuilder: (context) {
                                                  return Center(
                                                    child: NormalTextWidget(
                                                      context.toLocale!.no_matches_found,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          })
                                          /*SearchTask(
                                    onCloseIconPressed: () {
                                      setState(() {
                                        _isSearch = false;
                                      });
                                    },
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 17),
                                    initialValue: _siteTaskCubit.getSummaryFilterValue(),
                                    setInitialOptionsValue: (List<String> options) async {
                                      options.addAll(
                                          await _siteTaskCubit.getRecentSearchedSiteList());
                                    },
                                    onRecentSearchListUpdated:
                                        (List<String> options) async {
                                      await _siteTaskCubit
                                          .saveRecentSearchSiteList(options);
                                    },
                                    onSearchChanged: (searchValue, isFromCloseButton) {
                                      if (_siteTaskCubit.getSummaryFilterValue() !=
                                          searchValue) {
                                        setFormTitleFilterValue(searchValue);
                                        refreshPagination();
                                        _toggleEmptyMessageCubit.toggleChange(
                                            !searchValue.toString().isNullOrEmpty());
                                      }
                                    },
                                  )*/
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (Utility.isTablet || fullDrawer) Spacer(),
                                    if (!Utility.isTablet || fullDrawer)
                                      Expanded(
                                        child: CustomMaterialButtonWidget(
                                          color: AColors.white,
                                          elevation: 0,
                                          onPressed: () {
                                            context.closeKeyboard();
                                            _siteTaskCubit.setDrawerValue(StackDrawerOptions.filter);
                                          },
                                          height: 55,
                                          width: double.maxFinite,
                                          child: ImageIcon(
                                            AssetImage(
                                              _siteTaskCubit.filterApplied ? AImageConstants.appliedFilterIcon : AImageConstants.filterIcon,
                                            ),
                                            size: 24,
                                            color: AColors.themeBlueColor,
                                          ),
                                        ),
                                      ),
                                    if (!Utility.isTablet || fullDrawer) SizedBox(width: 10),
                                    if (!Utility.isTablet || fullDrawer)
                                      Expanded(
                                        child: CustomMaterialButtonWidget(
                                          color: AColors.white,
                                          elevation: 0,
                                          onPressed: () async {
                                            setState(() {
                                              _isSearch = true;
                                              _showSearchFilter = false;
                                              _searchFocusNode.requestFocus();
                                            });
                                          },
                                          height: 55,
                                          width: double.maxFinite,
                                          child: ImageIcon(
                                            AssetImage(AImageConstants.searchIcon),
                                            size: 24,
                                            color: AColors.themeBlueColor,
                                          ),
                                        ),
                                      )
                                    else
                                      CustomMaterialButtonWidget(
                                        color: AColors.white,
                                        elevation: 0,
                                        onPressed: () async {
                                          setState(() {
                                            _isSearch = true;
                                            _showSearchFilter = false;
                                            _searchFocusNode.requestFocus();
                                          });
                                        },
                                        height: 55,
                                        width: 50,
                                        child: ImageIcon(
                                          AssetImage(AImageConstants.searchIcon),
                                          size: 24,
                                          color: AColors.themeBlueColor,
                                        ),
                                      ),
                                    if (!Utility.isTablet || fullDrawer) SizedBox(width: 10),
                                    if (!Utility.isTablet || fullDrawer)
                                      Expanded(
                                        child: CustomMaterialButtonWidget(
                                          color: AColors.white,
                                          elevation: 0,
                                          onPressed: () async {
                                            _showCreateFormDialog(createFormSelectionCubit: await CreateFormHelper().onPostApiCall(false, "2")).then((value) {});
                                          },
                                          height: 55,
                                          width: double.maxFinite,
                                          child: ImageIcon(
                                            AssetImage(AImageConstants.createTaskIcon),
                                            size: 24,
                                            color: AColors.themeBlueColor,
                                          ),
                                        ),
                                      ),
                                    SizedBox(width: 10),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: Utility.isTablet
                                              ? fullDrawer
                                                  ? 18
                                                  : 26
                                              : 15),
                                      child: CustomMaterialButtonWidget(
                                        color: AColors.white,
                                        elevation: 0,
                                        onPressed: () {},
                                        height: 55,
                                        width: 155,
                                        child: Row(
                                          children: [
                                            TooltipDialog(
                                              toolTipContent: Container(
                                                constraints: const BoxConstraints(minWidth: 100, maxWidth: 140, minHeight: 150, maxHeight: 170),
                                                child: _showTitlePopupMenu(),
                                              ),
                                              toolTipController: _tooltipController,
                                              child: InkWell(
                                                onTap: () {
                                                  _tooltipController.showTooltipDialog();
                                                },
                                                child: NormalTextWidget(
                                                  getLocallySortFieldName(),
                                                  fontSize: 16,
                                                  fontWeight: AFontWight.medium,
                                                  color: AColors.themeBlueColor,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: SiteTaskCubit.sortOrder ? const Icon(Icons.keyboard_arrow_down) : const Icon(Icons.keyboard_arrow_up),
                                              color: AColors.themeBlueColor,
                                              iconSize: 25,
                                              onPressed: () {
                                                context.closeKeyboard();
                                                if (_siteTaskCubit.loadedItems.isNotEmpty) {
                                                  SiteTaskCubit.sortOrder = !SiteTaskCubit.sortOrder;
                                                  _siteTaskCubit.emitState(SortChangeState());
                                                  refreshPagination();
                                                }
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
              BlocBuilder<SiteTaskCubit, FlowState>(
                buildWhen: (previous, current) => current is SortChangeState || current is TaskListCountUpdateState || current is StackDrawerState,
                builder: (context, state) {
                  switch (state.props[0]) {
                    case StackDrawerOptions.filter:
                      return _filter();
                    case StackDrawerOptions.drawerBody:
                      return _drawerBody();
                    default:
                      return _drawerBody();
                  }
                },
              ),
            ],
          ),
        ),
        if (Utility.isTablet)
          AnimatedContainer(
              duration: const Duration(milliseconds: AConstants.siteEndDrawerDuration),
              width: fullDrawer ? fullWidth + 5 : fullWidth,
              color: AColors.filterBgColor,
              child: AnimatedOpacity(
                opacity: fullDrawer ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 700),
                child: Card(
                  margin: Utility.isTablet ? EdgeInsetsDirectional.fromSTEB(0, 20, 20, 20) : EdgeInsetsDirectional.fromSTEB(15, 20, 15, 20),
                  elevation: 8,
                  child: ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    ),
                    child: BlocBuilder<SiteTaskCubit, FlowState>(
                        buildWhen: (prev, current) => current is FormItemViewState || current is CreateTaskState,
                        builder: (_, state) {
                          if (state is FormItemViewState) {
                            String loadUrl = state.frmViewUrl;
                            if (isNetWorkConnected()) {
                              loadUrl = "$loadUrl&${AConstants.fieldAppParam}";
                            }
                            Color? headerIconColor = (state.headerIconColor != "") ? state.headerIconColor.toColor() : null;
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: _siteTaskCubit,
                                ),
                                BlocProvider.value(
                                  value: _planCubit,
                                ),
                              ],
                              child: AsiteFormWebView(
                                key: pWebViewKey,
                                url: loadUrl,
                                headerIconColor: headerIconColor,
                                data: state.webviewData,
                              ),
                            );
                          } else if (state is CreateTaskState) {
                            return createFormWhenNoTask();
                          }
                          return Container();
                        }),
                  ),
                ),
              )),
      ],
    );
  }

  Widget createFormWhenNoTask() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AImageConstants.emptySiteTask),
        const SizedBox(
          height: 12,
        ),
        NormalTextWidget(context.toLocale!.lbl_no_new_task_yet, fontWeight: AFontWight.regular, fontSize: 17, color: AColors.textColor.withOpacity(0.5), style: const TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(
          height: 12,
        ),
        createFormButton(),
      ],
    );
  }

  Widget _drawerBody() {
    double width = MediaQuery.of(context).size.width;
    final mediaQueryData = MediaQuery.of(context);
    if (mediaQueryData.orientation == Orientation.landscape && fullDrawer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fullWidth = (width * 62) / 100;
      });
    } else if (mediaQueryData.orientation == Orientation.portrait && fullDrawer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fullWidth = (width * 62) / 100;
      });
    }
    return Flexible(
      child: Column(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: BlocBuilder<UniqueValueCubit, String>(builder: (context, state) {
                    return PaginationView<SiteItem>(
                      padding: (Utility.isTablet) ? (fullDrawer ? const EdgeInsetsDirectional.only(end: 3) : const EdgeInsetsDirectional.only(end: 12)) : EdgeInsetsDirectional.zero,
                      key: Key(state),
                      shrinkWrap: true,
                      scrollController: paginationScrollController,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (_, item, index) {
                        return InkWell(
                          onTap: () async {
                            if (isNetWorkConnected() && item.item.isSyncPending == true) {
                              Utility.showAlertDialog(context, context.toLocale!.lbl_cant_open_form, context.toLocale!.lbl_open_unsynced_form_in_online);
                              return;
                            }

                            if (Utility.isTablet) {
                              context.closeKeyboard();
                              if (fullWidth <= 0.0) {
                                setState(() {
                                  fullDrawer = true;
                                  fullWidth = (width * 62) / 100;
                                });
                              }
                              pWebViewKey = GlobalKey();
                            }
                            if (!isNetWorkConnected() && item.item.templateType.isXSN) {
                              Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
                            } else {
                              await _siteTaskCubit.onFormItemClicked(item.item);
                              if (!Utility.isTablet && _siteTaskCubit.selectedItem != null && _planCubit.highLightFormId != _siteTaskCubit.selectedItem!.formId) {
                                await _planCubit.refreshPinsAndHighLight({"formId": item.item.formId}, refreshTaskList: false);
                              }
                            }
                          },
                          child: item,
                        );
                      },
                      pageFetch: pageFetch,
                      pullToRefresh: true,
                      onError: (dynamic error) => Center(
                        child: NormalTextWidget('$error'),
                      ),
                      onEmpty: BlocBuilder<ToggleCubit, bool>(builder: (context, state) {
                        return (!Utility.isTablet && !SiteUtility.isLocationHasPlan(_planCubit.selectedLocation) && _siteTaskCubit.getTotalCount() == 0)
                            ? Center(child: createFormWhenNoTask())
                            : Center(
                                child: NormalTextWidget(_siteTaskCubit.applyStaticFilter
                                    ? context.toLocale!.unable_show_details_data_corrupted
                                    : state
                                        ? context.toLocale!.no_matches_found
                                        : context.toLocale!.no_data_available));
                      }),
                      bottomLoader: const Center(
                        child: ACircularProgress(),
                      ),
                      initialLoader: const Center(
                        child: ACircularProgress(),
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filter() {
    return Expanded(
      child: SiteEndDrawerFilter(
        animationScrollController: paginationScrollController,
        key: filterKey,
        curScreen: FilterScreen.screenSite,
        onClose: () async {
          if (widget.fromFilter) {
            if (!Utility.isTablet) {
              if (paginationScrollController.hasClients) {
                paginationScrollController.jumpTo(paginationScrollController.position.minScrollExtent);
              }
              if (animatedScrollController.hasClients) {
                animatedScrollController.animateTo(
                  animatedScrollController.position.minScrollExtent,
                  duration: const Duration(seconds: 4),
                  curve: Curves.linear,
                );
              }
            }
            context.closeKeyboard();
            widget.onClose();
            if (!Utility.isTablet && _siteTaskCubit.selectedItem != null && _planCubit.highLightFormId != _siteTaskCubit.selectedItem!.formId) {
              await _planCubit.refreshPinsAndHighLight({"formId": _siteTaskCubit.selectedItem!.formId}, refreshTaskList: false);
            }
          } else {
            _siteTaskCubit.setDrawerValue(StackDrawerOptions.drawerBody);
          }
        },
        onApply: (value) async {
          _planCubit.refreshPins(isShowProgressDialog: false);
          await _siteTaskCubit.isFilterApplied();
          _siteTaskCubit.setDrawerValue(StackDrawerOptions.drawerBody);
          refreshPagination();
        },
      ),
    );
  }

  Future<List<SiteItem>> pageFetch(int offset) async {
    var items = await _siteTaskCubit.pageFetch(offset);

    if (offset == 0 && fullDrawer) {
      //'fullDrawer' is set as true default if selected location has no plan or It is opened/created from 'Dashboard' or 'qrCode'
      //Set 'fullDrawer' as false for Mobile device once list data retrieve,
      //Otherwise it will cause during search scenario, First matched form will auto open if 'fullDrawer' is true
      if (!Utility.isTablet) {
        fullDrawer = false;
      }

      if (_siteTaskCubit.selectedItem != null) {
        if (isNetWorkConnected() && _siteTaskCubit.selectedItem!.isSyncPending == true) {
          Utility.showAlertDialog(context, context.toLocale!.lbl_cant_open_form, context.toLocale!.lbl_open_unsynced_form_in_online);
        } else if (!isNetWorkConnected() && _siteTaskCubit.selectedItem!.templateType.isXSN) {
          Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
        } else {
          pWebViewKey = GlobalKey();
          await _siteTaskCubit.onFormItemClicked(_siteTaskCubit.selectedItem!);
        }
      } else if (!_siteTaskCubit.isClosed) {
        _siteTaskCubit.emitState(CreateTaskState());
      }
    }
    _siteTaskCubit.emitState(TaskListCountUpdateState());
    return items;
  }

  Widget _showTitlePopupMenu() => Column(
        children: <Widget>[
          _getTile(context.toLocale!.placeholder_task_creation_date, ListSortField.creation_date),
          const Divider(height: 1.0),
          _getTile(context.toLocale!.placeholder_task_due_date, ListSortField.due_date),
          const Divider(height: 1.0),
          _getTile(context.toLocale!.placeholder_task_title, ListSortField.siteTitle),
        ],
      );

  Widget _getTile(String siteTitle, ListSortField date) {
    return Flexible(
      child: ListTile(
          title: NormalTextWidget(
            siteTitle,
            fontWeight: AFontWight.regular,
            fontSize: 16.0,
            textAlign: TextAlign.start,
          ),
          onTap: () {
            _tooltipController.hideTooltipDialog();
            if (SiteTaskCubit.sortValue != date) {
              SiteTaskCubit.sortValue = date;
              SiteTaskCubit.sortValue == ListSortField.siteTitle ? SiteTaskCubit.sortOrder = false : SiteTaskCubit.sortOrder = true;
              _siteTaskCubit.emitState(SortChangeState());
              refreshPagination();
            }
          }),
    );
  }

  Widget createFormButton() {
    return InkWell(
      onTap: () async {
        _showCreateFormDialog(createFormSelectionCubit: await CreateFormHelper().onPostApiCall(false, "2")).then((value) {});
      },
      child: OrientationBuilder(builder: (context, orientation) {
        return Container(
          width: orientation == Orientation.portrait ? 100 : 200,
          decoration: BoxDecoration(color: AColors.themeBlueColor, borderRadius: BorderRadius.circular(4)),
          child: Padding(
            padding: orientation == Orientation.portrait ? const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 8) : const EdgeInsetsDirectional.fromSTEB(20, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Flexible(
                  flex: 3,
                  child: Icon(
                    Icons.add_task,
                    color: AColors.white,
                  ),
                ),
                SizedBox(
                  width: orientation == Orientation.portrait ? 2 : 8,
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: NormalTextWidget(
                    context.toLocale!.lbl_create,
                    fontSize: 15,
                    color: AColors.white,
                    fontWeight: AFontWight.medium,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget getFilter() {
    return BlocBuilder<SiteTaskCubit, FlowState>(
      buildWhen: (previous, current) => current is SortChangeState || current is TaskListCountUpdateState,
      builder: (context, state) => Padding(
          padding: EdgeInsetsDirectional.only(
              end: 8,
              start: 15,
              top: _siteTaskCubit.applyStaticFilter
                  ? Utility.isTablet
                      ? 15
                      : 25
                  : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: Utility.isTablet ? (!SiteUtility.isLocationHasPlan(_planCubit.selectedLocation) && _siteTaskCubit.getTotalCount() != 0) : (!SiteUtility.isLocationHasPlan(_planCubit.selectedLocation) && _siteTaskCubit.getTotalCount() != 0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 8),
                      child: createFormButton(),
                    ),
                  ),
                  NormalTextWidget(
                    context.toLocale!.lbl_task_list_count(_siteTaskCubit.getTaskListCount().toString(), _siteTaskCubit.getTotalCount().toString()),
                    key: const Key('key_pagination_count'),
                    textAlign: TextAlign.start,
                    fontSize: 16,
                    fontWeight: AFontWight.medium,
                    color: AColors.iconGreyColor,
                  ),
                ],
              ),
              if (!_siteTaskCubit.applyStaticFilter)
                Expanded(
                  child: Container(
                    padding: EdgeInsetsDirectional.only(start: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TooltipDialog(
                          toolTipContent: Container(
                            constraints: const BoxConstraints(minWidth: 100, maxWidth: 140, minHeight: 150, maxHeight: 170),
                            child: _showTitlePopupMenu(),
                          ),
                          toolTipController: _tooltipController,
                          child: InkWell(
                            onTap: () {
                              _tooltipController.showTooltipDialog();
                            },
                            child: NormalTextWidget(
                              getLocallySortFieldName(),
                              fontSize: 16,
                              fontWeight: AFontWight.medium,
                              color: AColors.iconGreyColor,
                            ),
                          ),
                        ),
                        // const SizedBox(width: 10),
                        IconButton(
                          icon: SiteTaskCubit.sortOrder ? const Icon(Icons.keyboard_arrow_down) : const Icon(Icons.keyboard_arrow_up),
                          color: AColors.iconGreyColor,
                          iconSize: 25,
                          onPressed: () {
                            context.closeKeyboard();
                            if (_siteTaskCubit.loadedItems.isNotEmpty) {
                              SiteTaskCubit.sortOrder = !SiteTaskCubit.sortOrder;
                              _siteTaskCubit.emitState(SortChangeState());
                              refreshPagination();
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        //const SizedBox(width: 5),
                        Flexible(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: _siteTaskCubit.filterApplied ? const Icon(Icons.filter_alt) : const Icon(Icons.filter_alt_outlined),
                            color: _siteTaskCubit.filterApplied ? AColors.themeBlueColor : AColors.iconGreyColor,
                            iconSize: 30,
                            onPressed: () {
                              context.closeKeyboard();
                              _siteTaskCubit.setDrawerValue(StackDrawerOptions.filter);
                            },
                          ),
                        ),
                        //if (Utility.isTablet && !fullDrawer) const SizedBox(width: 8)
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  String getLocallySortFieldName() {
    String name = context.toLocale!.placeholder_task_creation_date;
    switch (SiteTaskCubit.sortValue) {
      case ListSortField.due_date:
        {
          name = context.toLocale!.placeholder_task_due_date;
        }
        break;
      case ListSortField.siteTitle:
        {
          name = context.toLocale!.placeholder_task_title;
        }
        break;
      case ListSortField.creation_date:
        {
          name = context.toLocale!.placeholder_task_creation_date;
        }
        break;
      case ListSortField.creationDate:
        break;
      case ListSortField.lastUpdatedDate:
        break;
      case ListSortField.title:
        break;
    }
    return name;
  }

  void setFormTitleFilterValue(String searchValue) {
    _planCubit.setSummaryFilterValue(searchValue);
    _siteTaskCubit.setSummaryFilterValue(searchValue);
  }

  Future<void> _showCreateFormDialog({CreateFormSelectionCubit? createFormSelectionCubit}) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TaskTypeDialog(
            key: const Key('Key_ShowPinDialog'),
            createFormSelectionCubit: createFormSelectionCubit!,
          );
        }).then((value) {
      if (value != null && value is AppType) {
        _planCubit.navigateToCreateTask(appType: value, from: "site_end_drawer");
      }
    });
  }
}
