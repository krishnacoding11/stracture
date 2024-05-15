import 'dart:convert';

import 'package:field/bloc/bim_model_list/bim_project_model_cubit.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_state.dart';
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/data/dao/bim_model_list_dao.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/bim_request_data.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/revision_data.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/model_dialogs/model_manage_request.dart';
import 'package:field/widgets/model_dialogs/model_request.dart';
import 'package:field/widgets/model_dialogs/model_request_set_offline_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/model/sync/sync_request_task.dart';
import '../../../../utils/field_enums.dart';
import '../../../../utils/store_preference.dart';
import '../../../../widgets/a_progress_dialog.dart';
import '../../../../widgets/normaltext.dart';
import '../../../managers/color_manager.dart';
import '../../../managers/font_manager.dart';
import 'models_list_screen.dart';

// ignore: must_be_immutable
class ModelListTile extends StatefulWidget {
  final List<Model> selectedProjectModelsList;
  final int index;
  final int? progress;
  int? totalProgress;
  final int selectedIndex;
  final Function(String?) onTap;
  final Model model;
  final ModelListState state;
  final bool isDownload;
  final Project? selectedProject;
  final bool isShowSideToolBar;
  final bool isTest;

  ModelListTile({
    super.key,
    required this.selectedProjectModelsList,
    required this.index,
    required this.selectedIndex,
    this.isDownload = false,
    this.progress = 0,
    this.isTest = false,
    required this.state,
    this.totalProgress = 0,
    required this.onTap,
    required this.selectedProject,
    required this.model,
    required this.isShowSideToolBar,
  });

  @override
  State<ModelListTile> createState() => ModelListTileState();
}

class ModelListTileState extends State<ModelListTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animationIcon;
  List<IfcObjects> ifcObjects = [];
  List<BimModel> bimList = [];
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  double modelSize = 0.0;
  final ModelListCubit _modelListCubit = getIt<ModelListCubit>();
  final ModelListItemCubit itemCubit = ModelListItemCubit();
  final StorageDetailsCubit _storageCubit = getIt<StorageDetailsCubit>();
  String projectName = '';
  final BimProjectModelListCubit _bimProjectModelCubit = getIt<BimProjectModelListCubit>();

  @override
  void initState() {
    super.initState();
    itemCubit.initializeVars(_modelListCubit, widget.selectedProjectModelsList, widget.model, widget.onTap);
    if (!widget.isTest) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      );

      _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );
      _animationIcon = _controller.drive(_halfTween.chain(_easeInTween));
    } else {
      _controller = AnimationController(
        vsync: TestVSync(),
        duration: const Duration(milliseconds: 250),
      );
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );
      _animationIcon = _controller.drive(_halfTween.chain(_easeInTween));
    }
    getProjectName();
  }

  Future<void> getProjectName() async {
    projectName = await _modelListCubit.getProjectName(widget.selectedProject?.projectID ?? "", true);
  }

  @override
  void didUpdateWidget(covariant ModelListTile oldWidget) {
    if (!(widget.model.isDropOpen ?? false)) {
      _controller.reverse();
      dropdownDispose();
    }
    if (widget.isDownload) {}
    super.didUpdateWidget(oldWidget);
  }

  void dropdownDispose() {
    ifcObjects.clear();
    itemCubit.isExpanded = false;
    itemCubit.isModelSelected = true;
    itemCubit.isCalibrateLoading = true;
    itemCubit.isChopped = true;
    itemCubit.isModelLoaded = false;
    itemCubit.calibrationList.clear();
    itemCubit.selectedFloorList.clear();
    itemCubit.loadedFloorList.clear();
  }

  void toggleExpanded() async {
    itemCubit.initializeVars(_modelListCubit, widget.selectedProjectModelsList, widget.model, widget.onTap);
    _modelListCubit.selectedModel = null;
    _modelListCubit.itemDropdownClick(
      widget.index,
    );
    if (itemCubit.tempFloorList.isNotEmpty) {
      widget.onTap(AConstants.resetLower);
    }
    if (!itemCubit.isExpanded) {
      itemCubit.isModelSelected = true;
      itemCubit.onExpansionClick(true);
      _storageCubit.modelSelectState(widget.model);
      _controller.forward();
      if (isNetWorkConnected()) {
        _modelListCubit.selectedModelData = null;
        _modelListCubit.selectedModel = null;
        _modelListCubit.dropdownStateEmit(true, widget.model.isDownload ?? false);
      }
      if ((widget.model.setAsOffline ?? false) && ifcObjects.isEmpty) {
        if (isNetWorkConnected()) {
          _modelLoading();
        } else {
          _offlineModelLoading(widget.model);
        }
      } else {
        if ((ifcObjects.first.ifcObjects?.isEmpty ?? false)) {
          _modelLoading();
        }
      }
    } else {
      itemCubit.onExpansionClick(false);
      _controller.reverse();
      _modelListCubit.selectedFloorList.clear();
      _modelListCubit.selectedCalibrate.clear();
      itemCubit.onTabChange(false, widget.selectedProject!.projectID.toString());
      itemCubit.tempFloorList.clear();
      _modelListCubit.selectedModel = null;
      ifcObjects.clear();
      itemCubit.calibrationList.clear();
      _storageCubit.modelSelectState(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    itemCubit.aProgressDialog = AProgressDialog(context, isAnimationRequired: true);
    return BlocListener<ModelListCubit, ModelListState>(
      listener: (BuildContext context, state) {
        if (state is DownloadModelState && state.downloadStart) {
          _controller.reverse();
          dropdownDispose();
          _modelListCubit.lastSelectedIndex = -1;
          modelSize = state.totalModelSize;
          if (state.totalSize != 0 && widget.index == _modelListCubit.selectedModelIndex) {
            itemCubit.downloadedValue = "${((state.progressValue / state.totalSize) * 100).round()}";
            itemCubit.downloadProgressState(widget.progress);
          }
        } else {
          widget.totalProgress = 0;
          itemCubit.downloadedValue = '';
        }
      },
      child: BlocBuilder<ModelListCubit, ModelListState>(
        builder: (context, modelState) {
          return IgnorePointer(
            key: Key('key_ignore_pointer_model_list_state'),
            ignoring: modelState is DownloadModelState,
            child: BlocProvider.value(
              value: itemCubit,
              child: BlocListener<ModelListItemCubit, ModelListItemState>(
                listener: (context, state) {
                  if (state is SendAdministratorState) {
                    if (state.responseData) {
                       NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.request_sent, context.toLocale!.request_administrator_sent, Icons.check_circle, Colors.green);
                    } else {
                       NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.failed, context.toLocale!.something_went_wrong_only, Icons.report, Colors.red);
                    }
                  }
                },
                child: BlocBuilder<ModelListItemCubit, ModelListItemState>(
                  builder: (cont, state) {
                    return Container(
                      key: Key('key_model_list_tile_container'),
                      decoration: BoxDecoration(color: itemCubit.isExpanded ? AColors.themeLightColor : null),
                      child: Column(
                        children: [
                          InkWell(
                            key: const Key('key_model_list_tile_ink_well'),
                            onTap: () {
                              if (isNetWorkConnected()) {
                                if (!itemCubit.isExpanded) {
                                  widget.onTap(AConstants.itemTile);
                                }
                                if ((modelState is DropdownOpenState && modelState.isOpen) || modelState is ItemCheckedState) {
                                  itemCubit.onExpansionClick(false);
                                  _controller.reverse();
                                  _modelListCubit.itemDropdownClick(
                                    widget.index,
                                  );
                                  _modelListCubit.dropdownStateEmit(false, widget.model.isDownload ?? false);
                                }
                              }
                            },
                            child: Container(
                              color: _modelListCubit.selectedModel != null && (widget.model.userModelName == _modelListCubit.selectedModel?.userModelName && widget.model.bimModelId == _modelListCubit.selectedModel?.bimModelId) ? AColors.themeLightColor : Colors.transparent,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                (widget.model.modelSupportedOffline ?? false) ? tileIcon(state) : SizedBox.shrink(),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: NormalTextWidget(
                                              widget.model.userModelName ?? "",
                                              fontWeight: AFontWight.regular,
                                              textAlign: TextAlign.start,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if ((modelState is DownloadModelState && modelState.downloadStart) && itemCubit.downloadedValue.isNotEmpty) ...[
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            NormalTextWidget(
                                              "${itemCubit.downloadedValue} % of ${formatFileSize(modelSize)}",
                                              key: const Key('key_model_list_tile_downloaded_value'),
                                              fontWeight: AFontWight.semiBold,
                                              color: Colors.grey,
                                              textAlign: TextAlign.start,
                                              fontSize: 12,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (!(modelState is DownloadModelState && modelState.downloadStart && widget.index == _modelListCubit.selectedModelIndex) && (widget.model.fileSize?.isNotEmpty ?? false) && (widget.model.fileSize != "0") && (widget.model.fileSize != "0.00")) ...[
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      NormalTextWidget(
                                        formatFileSize(double.parse((widget.model.fileSize?.isNotEmpty ?? false)
                                            ? widget.model.fileSize!.contains("-")
                                                ? widget.model.fileSize!.split("-").last
                                                : widget.model.fileSize!
                                            : "0.0")),
                                        fontWeight: AFontWight.semiBold,
                                        color: Colors.grey,
                                        textAlign: TextAlign.start,
                                        fontSize: 12,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                    (widget.model.modelSupportedOffline ?? false)
                                        ? IconButton(
                                            key: const Key('model_list_tile_icon_button'),
                                            icon: RotationTransition(
                                              turns: _animationIcon,
                                              child: Icon(
                                                Icons.expand_more,
                                                color: (state is FileChoppedState) || (widget.model.setAsOffline ?? false) ? AColors.black : Colors.grey.shade400,
                                              ),
                                            ),
                                            onPressed: () async {
                                              if ((state is FileChoppedState) || (state is ExpandedState && state.isExpanded) || (widget.model.setAsOffline ?? false)) {
                                                  toggleExpanded();
                                              }
                                            },
                                          )
                                        : IconButton(
                                            key: const Key('key_model_list_tile_animated_icon'),
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: RotationTransition(
                                              turns: _animationIcon,
                                              child: Icon(
                                                null,
                                              ),
                                            ),
                                            onPressed: () async {},
                                          ),
                                    GestureDetector(
                                      onTap: () async {
                                        itemCubit.loadingFavCheckState();
                                        await _modelListCubit.favouriteModel(widget.model, widget.model.isFavoriteModel == 0 ? 1 : 0);
                                        itemCubit.favCheckedState();
                                      },
                                      child: (widget.model.isFavoriteModel == 1)
                                          ? const Icon(
                                              Icons.star,
                                              key: Key("key_star"),
                                              size: 20,
                                              color: Color(0xFFF79120),
                                            )
                                          : const Icon(
                                              Icons.star_border,
                                              key: Key("key_star_border"),
                                              size: 20,
                                              color: Color(0xFFBDBDBD),
                                            ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                          SizeTransition(
                            key: Key('key_size_transition_animation'),
                            sizeFactor: _animation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      key: Key('key_models_tab'),
                                      child: GestureDetector(
                                        onTap: () {
                                          if(!itemCubit.isModelSelected){
                                            itemCubit.onTabChange(true, widget.selectedProject!.projectID.toString());

                                          }
                                        },
                                        child: Container(
                                          key: const Key('key_model_list_tile_con'),
                                          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: itemCubit.isModelSelected ? 3 : 0, color: AColors.themeBlueColor), right: const BorderSide(width: .5))),
                                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                                          child: const Center(
                                              child: NormalTextWidget(
                                            AConstants.models,
                                            fontSize: 16,
                                          )),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      key: Key('key_calibration_tab'),
                                      child: GestureDetector(
                                        onTap: () {
                                          itemCubit.onTabChange(false, widget.selectedProject!.projectID.toString());
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: !itemCubit.isModelSelected ? 3 : 0, color: AColors.themeBlueColor), left: const BorderSide(width: .5))),
                                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                                          child:  Center(
                                            child: NormalTextWidget(
                                              context.toLocale!.lbl_calibration,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                itemCubit.isModelSelected ? modelWidget(state) : calibratedList()
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget modelWidget(ModelListItemState state) {
    if ((state is ModelLoadingState && state.modelStatus == ModelStatus.loaded)) {
      if (itemCubit.mapGroupBimList.isEmpty) {
        itemCubit.isModelEmpty = true;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(46),
            child: Text(context.toLocale!.no_record_available),
          ),
        );
      }
      itemCubit.isModelEmpty = false;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: itemCubit.mapGroupBimList.keys
            .toList()
            .map((e) => BimListWidget(
                  title: e,
                  itemCubit: itemCubit,
                  bimList: itemCubit.mapGroupBimList[e]!,
                  globalIndex: widget.index,
                  model: widget.model,
                  isShowSideToolBar: widget.isShowSideToolBar,
                ))
            .toList(),
      );
    } else if (state is ModelLoadingState && state.modelStatus == ModelStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    else if (state is ModelLoadingState && state.modelStatus == ModelStatus.failed) {
      itemCubit.isModelEmpty = true;
      return Center(
        child: Padding(
          padding: EdgeInsets.all(46),
          child: Text(context.toLocale!.no_record_available),
        ),
      );
    } else {
      if (itemCubit.isChopped) {

        if(itemCubit.isModelLoading){
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (itemCubit.mapGroupBimList.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(46),
              child: Text(context.toLocale!.no_record_available),
            ),
          );
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: itemCubit.mapGroupBimList.keys
                .toList()
                .map((e) => BimListWidget(
                      title: e,
                      itemCubit: itemCubit,
                      bimList: itemCubit.mapGroupBimList[e]!,
                      model: widget.model,
                      globalIndex: widget.index,
                      isShowSideToolBar: widget.isShowSideToolBar,
                    ))
                .toList());
      }
    }

    return const SizedBox();
  }

  Widget tileIcon(ModelListItemState state) {
    if (state is FileChoppingState || itemCubit.isChopping || (state is DownloadedProgressState && widget.progress! > 0 && widget.index == _modelListCubit.selectedModelIndex)) {
      return const ProcessIcon();
    } else if (state is UnableChoppedState && !widget.model.setAsOffline!) {
      return InkWell(
        onTap: () async {
            onIconClicked(widget.index);
        },
        child: Image.asset(
          AImageConstants.requestCloud,
          scale: 1,
          height: 22,
          width: 22,
        ),
      );
    } else if (state is FileChoppedState) {
      if (widget.model.isDownload ?? false) {
        return InkWell(
          onTap: () async {
              onIconClicked(widget.index);
          },
          child: const Icon(
            Icons.offline_pin_rounded,
            size: 23,
            color: Colors.green,
          ),
        );
      }
      return InkWell(
        onTap: () async {
            onIconClicked(widget.index);
        },
        child: Image.asset(
          AImageConstants.cloudDownloadOutlined,
          scale: 1,
          height: 22,
          width: 22,
        ),
      );
    } else {
      if (widget.model.setAsOffline ?? false) {
        if (widget.model.isDownload ?? false) {
          return InkWell(
            onTap: () async {
              Future.delayed(Duration(seconds: 2));
                onIconClicked(widget.index);
            },
            child: const Icon(
              Icons.offline_pin_rounded,
              size: 23,
              color: Colors.green,
            ),
          );
        }
        return InkWell(
          onTap: () async {
              onIconClicked(widget.index);
          },
          child: Image.asset(
            AImageConstants.cloudDownloadOutlined,
            scale: 1,
            height: 22,
            width: 22,
          ),
        );
      } else {
        return InkWell(
          onTap: () async {
              onIconClicked(widget.index);
          },
          child: Image.asset(
            AImageConstants.requestCloud,
            scale: 1,
            height: 22,
            width: 22,
          ),
        );
      }
    }
  }

  Widget calibratedList() {
    if (itemCubit.isModelEmpty) {
      itemCubit.calibrationList.clear();
    }
    if (itemCubit.isCalibrateLoading) {
      return const Center(
        key: Key('key_center_calib'),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (itemCubit.calibrationList.isNotEmpty) {
      return Column(key: Key('key_calib_list_column'), crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var data in itemCubit.calibrationList) ...[
          InkWell(
            onTap: () {
              data.isChecked = !data.isChecked;
              var newList = itemCubit.calibrationList.where((element) => element.isChecked == true).toList();
              itemCubit.onCalibratedFileClick(newList);
              _modelListCubit.calibratedItemSelect(itemCubit.calibrationList, newList.isNotEmpty, data, widget.model);
            },
            child: Ink(
              padding: const EdgeInsets.only(
                top: 16,
                left: 28,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(color: data.isChecked ? AColors.themeBlueColor : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(width: 2, color: AColors.grColor)),
                    child: data.isChecked
                        ? const Center(
                            child: Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.white,
                          ))
                        : null,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Icon(
                    CupertinoIcons.cube,
                    color: AColors.blueColor,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Flexible(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: NormalTextWidget(
                        data.calibrationName,
                        fontWeight: AFontWight.regular,
                        textAlign: TextAlign.start,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ]);
    } else {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(46),
          child: Text(context.toLocale!.no_record_available),
        ),
      );
    }
  }

  void onIconClicked(index, {bool isTest = false}) async {
    if(_modelListCubit.isIconClicked || !isNetWorkConnected())return;

    _modelListCubit.isIconClicked=true;
    List<IfcObjects> bimModelList = [];
    List<String> revIds = [];
    ifcObjects.clear();
    _modelListCubit.projectId = widget.selectedProject!.projectID!;
    try {
      itemCubit.mapGroupBimList.clear();
      bimList.clear();
      if (context.mounted && (!isTest)) {
        NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.warning_title_please_wait, context.toLocale!.warning_system_processing, Icons.warning, Colors.orange);
      }
      bool canManage = await _modelListCubit.canManageModel(widget.selectedProject!.projectID!);
      _modelListCubit.isIconClicked=false;
      if (canManage && !widget.model.setAsOffline! && !widget.model.isDownload!) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (con) => ModelRequestSetOfflineDialog(
            context,
            onTap: () {
              onIconClicked(widget.index);
            },
            model: widget.model,
          ),
        ).then((value) async {
          if (context.mounted && value.toString().toLowerCase() == AConstants.ok.toLowerCase()) {
            Utility.closeBanner();
            await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (con) {
                  return ModelManageRequestDialog(
                    modelId: widget.model.bimModelId!,
                    projectId: widget.selectedProject!.projectID!,
                  );
                }).then((value) async {
              if (value != null && value == AConstants.ok) {
                itemCubit.fileChoppingState();
                BimProjectModelRequestModel bimProjectModelRequestModel = _modelListCubit.buildBimRequestBody(index, widget.selectedProjectModelsList, widget.selectedProject);
                try {
                  var value = await _bimProjectModelCubit.getBimProjectModel(project: bimProjectModelRequestModel);
                  bimModelList = value[0].bIMProjectModelVO?.ifcObject?.ifcObjects ?? [];
                  ifcObjects = bimModelList;
                  if (ifcObjects.isEmpty) {
                    if (context.mounted) {
                      NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.error_cant_set_offline, Icons.report, Colors.red);
                    }
                    ifcObjects.clear();
                    itemCubit.unableChoppedState();
                    return;
                  }
                  switch (_modelListCubit.selectedOption) {
                    case AConstants.latest:
                      for (var object in ifcObjects) {
                        object.ifcObjects?.removeRange(1, object.ifcObjects!.length);
                      }
                      break;
                    case AConstants.superseded:
                      for (var object in ifcObjects) {
                        object.ifcObjects?.removeAt(0);
                      }
                      break;
                  }
                  for (var ifo in ifcObjects) {
                    ifo.ifcObjects?.forEach((element) {
                      if (element.revId != null) {
                        revIds.add(element.revId!);
                      }
                    });
                  }
                  Map<String, dynamic> request = {
                    RequestConstants.projectId: widget.selectedProject!.projectID,
                    RequestConstants.revisionIds: revIds.join(','),
                  };
                  List<RevisionId> revisionIdList = [];
                  if (context.mounted) {
                    revisionIdList = await _modelListCubit.fetchChoppedFileStatus(request);
                  }
                  var list = revisionIdList.where((element) => element.status.toLowerCase() == AConstants.failed.toLowerCase()).toList();

                  if (list.length == revisionIdList.length) {
                    if (context.mounted) {
                      NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.failed_chopping_message, Icons.report, Colors.red);
                    }
                    ifcObjects.clear();
                    itemCubit.unableChoppedState();
                    return;
                  } else if (list.length > 0) {
                    if (context.mounted) {
                      NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.failed_chopping_message, Icons.report, Colors.red);
                    }
                    ifcObjects.clear();
                    itemCubit.unableChoppedState();
                    return;
                  }
                  if (revisionIdList.isNotEmpty) {
                    int item = 0;
                    for (var data in revisionIdList) {
                      if (data.status.toLowerCase() == AConstants.inProcess) {
                        if (context.mounted) {
                          NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.in_process, context.toLocale!.chopping_in_process_check_after_sometime, Icons.warning_rounded, AColors.warningIconColor);
                        }
                        break;
                      }
                      if (data.status.toLowerCase() == AConstants.inQueue) {
                        if (context.mounted) {
                          NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.in_process, context.toLocale!.chopping_in_queue_check_after_sometime, Icons.warning_rounded, AColors.warningIconColor);
                        }
                        break;
                      }
                      if (data.status.toLowerCase() == AConstants.failed.toLowerCase()) {
                        if (context.mounted) {
                          NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.failed_chopping_message, Icons.report, Colors.red);
                        }
                        break;
                      }
                      if (data.status.toLowerCase() == AConstants.revisionNotYetProcessed) {
                        if (context.mounted) {
                          NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.warning, context.toLocale!.revision_not_yet_processed, Icons.warning, Colors.orange);
                        }
                        break;
                      }
                      if (data.status.toLowerCase() == AConstants.reProcess) {
                        if (context.mounted) {
                          NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.failed, context.toLocale!.revision_need_to_reprocess_again, Icons.report, Colors.red);
                        }
                        break;
                      }
                      item++;
                    }
                    if (item == revisionIdList.length) {
                      for (var object in ifcObjects) {
                        bimList.addAll(object.ifcObjects!);
                      }
                      itemCubit.mapGroupBimList = bimList.groupBy((BimModel obj) => obj.ifcName!);
                      itemCubit.fileChoppedState();
                      if (context.mounted) {
                        NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.model_set_for_offline, context.toLocale!.request_model_successfully_set_for_offline_usage, Icons.check_circle, Colors.green);
                      }
                      //return;
                    } else {
                      ifcObjects.clear();
                      itemCubit.unableChoppedState();
                    }
                  } else {
                    ifcObjects.clear();
                    itemCubit.unableChoppedState();
                  }
                } on Exception {
                  ifcObjects.clear();
                  itemCubit.unableChoppedState();
                }
              } else {
                ifcObjects.clear();
                itemCubit.unableChoppedState();
              }
            });
          }
        });
      } else if (canManage && widget.model.setAsOffline!) {
        if (context.mounted) {
          Utility.closeBanner();
          await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (con) {
                return ModelManageRequestDialog(
                  modelId: widget.model.bimModelId!,
                  projectId: widget.selectedProject!.projectID!,
                );
              }).then((value) async {
            if (value != null && value == AConstants.ok) {
              itemCubit.fileChoppingState();
              BimProjectModelRequestModel bimProjectModelRequestModel = _modelListCubit.buildBimRequestBody(index, widget.selectedProjectModelsList, widget.selectedProject);
              try {
                var value = await _bimProjectModelCubit.getBimProjectModel(project: bimProjectModelRequestModel);
                bimModelList = value[0].bIMProjectModelVO?.ifcObject?.ifcObjects ?? [];
                ifcObjects = bimModelList;
                if (ifcObjects.isEmpty) {
                  if (context.mounted) {
                    NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.error_cant_set_offline, Icons.report, Colors.red);
                  }
                  ifcObjects.clear();
                  itemCubit.unableChoppedState();
                  return;
                }
                switch (_modelListCubit.selectedOption) {
                  case AConstants.latest:
                    for (var object in ifcObjects) {
                      object.ifcObjects?.removeRange(1, object.ifcObjects!.length);
                    }
                    break;
                  case AConstants.superseded:
                    for (var object in ifcObjects) {
                      object.ifcObjects?.removeAt(0);
                    }
                    break;
                }
                for (var ifo in ifcObjects) {
                  ifo.ifcObjects?.forEach((element) {
                    if (element.revId != null) {
                      revIds.add(element.revId!);
                    }
                  });
                }
                Map<String, dynamic> request = {
                  RequestConstants.projectId: widget.selectedProject!.projectID,
                  RequestConstants.revisionIds: revIds.join(','),
                };
                List<RevisionId> revisionIdList = [];
                if (context.mounted) {
                  revisionIdList = await _modelListCubit.fetchChoppedFileStatus(request);
                }
                var list = revisionIdList.where((element) => element.status.toLowerCase() == AConstants.failed.toLowerCase()).toList();

                if (list.length == revisionIdList.length) {
                  if (context.mounted) {
                    NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.failed_chopping_message, Icons.report, Colors.red);
                  }
                  ifcObjects.clear();
                  itemCubit.unableChoppedState();
                  return;
                } else if (list.length > 0) {
                  if (context.mounted) {
                    NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.failed_chopping_message, Icons.report, Colors.red);
                  }
                  ifcObjects.clear();
                  itemCubit.unableChoppedState();
                  return;
                }
                if (revisionIdList.isNotEmpty) {
                  int item = 0;
                  for (var data in revisionIdList) {
                    if (data.status.toLowerCase() == AConstants.inProcess) {
                      if (context.mounted) {
                        NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.in_process, context.toLocale!.chopping_in_process_check_after_sometime, Icons.warning_rounded, AColors.warningIconColor);
                      }
                      break;
                    }
                    if (data.status.toLowerCase() == AConstants.inQueue) {
                      if (context.mounted) {
                        NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.in_process, context.toLocale!.chopping_in_queue_check_after_sometime, Icons.warning_rounded, AColors.warningIconColor);
                      }
                      break;
                    }
                    if (data.status.toLowerCase() == AConstants.failed.toLowerCase()) {
                      if (context.mounted) {
                        NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.something_went_wrong, context.toLocale!.failed_chopping_message, Icons.report, Colors.red);
                      }
                      break;
                    }
                    if (data.status.toLowerCase() == AConstants.revisionNotYetProcessed) {
                      if (context.mounted) {
                        NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.warning, context.toLocale!.revision_not_yet_processed, Icons.warning, Colors.orange);
                      }
                      break;
                    }
                    if (data.status.toLowerCase() == AConstants.reProcess) {
                      if (context.mounted) {
                        NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.failed, context.toLocale!.revision_need_to_reprocess_again, Icons.report, Colors.red);
                      }
                      break;
                    }
                    item++;
                  }
                  if (item == revisionIdList.length) {
                    for (var object in ifcObjects) {
                      bimList.addAll(object.ifcObjects!);
                    }
                    itemCubit.mapGroupBimList = bimList.groupBy((BimModel obj) => obj.ifcName!);
                    itemCubit.fileChoppedState();
                    if (context.mounted) {
                      NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.model_set_for_offline, context.toLocale!.request_model_successfully_set_for_offline_usage, Icons.check_circle, Colors.green);
                    }
                    //return;
                  } else {
                    ifcObjects.clear();
                    itemCubit.unableChoppedState();
                  }
                } else {
                  ifcObjects.clear();
                  itemCubit.unableChoppedState();
                }
              } on Exception {
                ifcObjects.clear();
                itemCubit.unableChoppedState();
              }
            } else {
              ifcObjects.clear();
              itemCubit.unableChoppedState();
            }
          });
        }
      } else {
        Utility.closeBanner();
        itemCubit.unableChoppedState();
        ifcObjects.clear();
        if (context.mounted) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (con) => ModelRequestDialog(
              context,
              onTap: () {
                itemCubit.sendModelOfflineRequest(
                  bimModelId: widget.model.bimModelId!,
                  projectId: widget.selectedProject!.projectID!,
                );
              },
            ),
          );
        }
      }
    } catch (e) {
      itemCubit.unableChoppedState();
      ifcObjects.clear();
    }
  }

  void _modelLoading() async {
    if (!itemCubit.isModelLoading) {
      List<IfcObjects> bimModelList = [];
      List<String> revIds = [];
      ifcObjects.clear();
      BimProjectModelRequestModel bimProjectModelRequestModel = _modelListCubit.buildBimRequestBody(
        widget.index,
        widget.selectedProjectModelsList,
        widget.selectedProject,
      );
      _modelListCubit.projectId = widget.selectedProject!.projectID!;
      itemCubit.modelLoadingState(ModelStatus.loading);
      try {
        itemCubit.mapGroupBimList.clear();
        bimList.clear();
        var value = await _bimProjectModelCubit.getBimProjectModel(project: bimProjectModelRequestModel);
        bimModelList = value.isNotEmpty ? value[0].bIMProjectModelVO?.ifcObject?.ifcObjects ?? [] : [];
        ifcObjects = bimModelList;
        for (var ifo in bimModelList) {
          ifo.ifcObjects?.forEach((element) {
            if (element.revId != null) {
              revIds.add(element.revId!);
            }
          });
        }
        Map<String, dynamic> request = {
          RequestConstants.projectId: widget.selectedProject!.projectID,
          RequestConstants.revisionIds: revIds.join(','),
        };
        List<RevisionId> revisionIdList = [];
        if (context.mounted) {
          revisionIdList = await _modelListCubit.fetchChoppedFileStatusOnDrop(request);
        }
        if (revisionIdList.isNotEmpty) {
          var completedFiles = revisionIdList.where((data) => data.status.toLowerCase() == AConstants.completed).toList();
          List<String> completedRevId = completedFiles.map((e) => e.revisionId.toString()).toList();
          if (completedRevId.isNotEmpty) {
            for (var object in ifcObjects) {
              for (int i = 0; i < object.ifcObjects!.length; i++) {
                if (!completedRevId.contains(object.ifcObjects![i].revId.plainValue())) {
                  object.ifcObjects?.removeAt(i);
                }
              }
              for (var bimModel in object.ifcObjects!) {
               await itemCubit.bimModelDownload(bimModel);
              }
              bimList.addAll(object.ifcObjects!);
            }
          } else {
            for (var data in revisionIdList) {
              if (data.status.toLowerCase() == AConstants.inProcess) {
                itemCubit.onExpansionClick(!itemCubit.isExpanded);
                _controller.reverse();
                ifcObjects.clear();
                if (context.mounted) {
                   NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.in_process, context.toLocale!.chopping_in_process_check_after_sometime, Icons.warning_rounded, AColors.warningIconColor);
                }
                break;
              }
              if (data.status.toLowerCase() == AConstants.inQueue) {
                itemCubit.onExpansionClick(!itemCubit.isExpanded);
                _controller.reverse();
                ifcObjects.clear();
                if (context.mounted) {
                   NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.in_process, context.toLocale!.chopping_in_queue_check_after_sometime, Icons.warning_rounded, AColors.warningIconColor);
                }
                break;
              }
              if (data.status.toLowerCase() == AConstants.failed.toLowerCase()) {
                itemCubit.onExpansionClick(!itemCubit.isExpanded);
                _controller.reverse();
                ifcObjects.clear();
                if (context.mounted) {
                   NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.failed, context.toLocale!.chopping_process_failed, Icons.report, Colors.red);
                }
                break;
              }
              if (data.status.toLowerCase() == AConstants.revisionNotYetProcessed) {
                itemCubit.onExpansionClick(!itemCubit.isExpanded);
                _controller.reverse();
                ifcObjects.clear();
                break;
              }
              if (data.status.toLowerCase() == AConstants.reProcess) {
                itemCubit.onExpansionClick(!itemCubit.isExpanded);
                _controller.reverse();
                ifcObjects.clear();
                if (context.mounted) {
                   NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.failed, "${data.status}. ${context.toLocale!.revision_need_to_reprocess_again}", Icons.report, Colors.red);
                }
                break;
              }
            }
          }
          itemCubit.mapGroupBimList = bimList.groupBy((BimModel obj) => obj.ifcName!);
          itemCubit.modelLoadingState(ModelStatus.loaded);
        } else {
          itemCubit.modelLoadingState(ModelStatus.failed);
        }
      } on Exception {
        itemCubit.modelLoadingState(ModelStatus.failed);
        if (context.mounted) {
           NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.failed, context.toLocale!.internal_server_error, Icons.report, Colors.red);
        }
      }
    }
  }

  void _offlineModelLoading(Model model) async {
    itemCubit.modelLoadingState(ModelStatus.loading);
    try {
      BimModelListDao dao = BimModelListDao();
      bimList = await dao.fetch(model.bimModelId!);
    for(var element in bimList){
        element.isChecked = false;
        element.floorList = await itemCubit.getFloorByRevId(element.revId.plainValue());
        element.floorList.forEach((element) {
          element.isChecked = false;
        });
    }
      itemCubit.mapGroupBimList = bimList.groupBy((BimModel obj) => obj.ifcName!);
    } catch (e) {
      Log.d(e);
    }
    itemCubit.modelLoadingState(ModelStatus.loaded);
  }
}

class BimListWidget extends StatefulWidget {
  final List<BimModel> bimList;
  final String title;
  final int globalIndex;
  final ModelListItemCubit itemCubit;
  final Model model;
  final bool isShowSideToolBar;

  BimListWidget({
    super.key,
    required this.bimList,
    required this.title,
    required this.globalIndex,
    required this.itemCubit,
    required this.model,
    required this.isShowSideToolBar,
  });

  @override
  State<BimListWidget> createState() => _BimListWidgetState();
}

class _BimListWidgetState extends State<BimListWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key("bimlist_padding_1"),
      padding: const EdgeInsets.only(left: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            key: Key("bimlist_padding_2"),
            padding: const EdgeInsets.only(top: 14, bottom: 15),
            child: NormalTextWidget(
              widget.title,
              fontWeight: AFontWight.semiBold,
              textAlign: TextAlign.start,
              fontSize: 16,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          for (var temData in widget.bimList)
            FloorsExpansionTile(
              bimModel: temData,
              itemCubit: widget.itemCubit,
              globalIndex: widget.globalIndex,
              model: widget.model,
              title: widget.title,
              bimList: widget.bimList,
              isShowSideToolBar: widget.isShowSideToolBar,
            )
        ],
      ),
    );
  }
}

class FloorsExpansionTile extends StatefulWidget {
  final BimModel bimModel;
  final ModelListItemCubit itemCubit;
  final int globalIndex;
  final Model model;
  final List<BimModel> bimList;
  final String title;
  final bool isShowSideToolBar;

  FloorsExpansionTile({
    super.key,
    required this.bimModel,
    required this.bimList,
    required this.itemCubit,
    required this.globalIndex,
    required this.model,
    required this.title,
    required this.isShowSideToolBar,
  });

  @override
  State<FloorsExpansionTile> createState() => FloorsExpansionTileState();
}

class FloorsExpansionTileState extends State<FloorsExpansionTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animationIcon;
  List<FloorDetail> floorList = [];
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  bool isAllCheck = false, isSomeChecked = false, isBimModelExpanded = false;
  final ModelListCubit _modelListCubit = getIt<ModelListCubit>();

  @override
  void initState() {
    super.initState();
    floorList = _modelListCubit.selectedFloorList[widget.bimModel.revId.plainValue()]?.floorList ?? [];
    if (floorList.isEmpty) {
      floorList = widget.bimModel.floorList.where((element) {
        if (!element.isDownloaded && element.isChecked) {
          element.isChecked = false;
        }
        return element.isDownloaded == true;
      }).toList();
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _animationIcon = _controller.drive(_halfTween.chain(_easeInTween));
    if (floorList.isNotEmpty) {
      _controller.forward();
    } else {
      widget.bimModel.floorList = widget.bimModel.floorList.where((element) => element.isDownloaded == true).toList();
    }
    if (!isNetWorkConnected()) {
      Future.delayed(Duration(milliseconds: 248)).then((value) => _toggleExpanded());
    }
  }

  fetchFloor({bool isTest = false}) async {
    widget.itemCubit.loadingFloor(true);
    if (floorList.isEmpty || widget.bimModel.floorList.isEmpty) {
      try {
        widget.itemCubit.selectedBimModelData = widget.bimModel;
        _modelListCubit.selectedModel = widget.model;
        floorList.clear();
        floorList = await widget.itemCubit.getFloorData(widget.bimModel.revId!, bimModel: widget.bimModel);
        if (floorList.isEmpty) {
          widget.itemCubit.loadingFloor(false);
          _controller.reverse();
          widget.itemCubit.deleteByRevision(widget.bimModel);
          if (mounted && isNetWorkConnected()) {
             NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.failed, context.toLocale!.internal_server_error, Icons.report, Colors.red);
          }
        } else {
          if (isNetWorkConnected()) {
            widget.bimModel.floorList = floorList;
            var list = floorList.where((element) => element.isChecked == true).toList();
            widget.bimModel.isChecked = widget.bimModel.floorList.length == list.length;
          } else {
            floorList.forEach((element) => element.isChecked = false);
            widget.bimModel.floorList = floorList;
          }
          widget.itemCubit.loadingFloor(false);
        }
      } catch (e) {
        Log.e("message $e");
        widget.itemCubit.loadingFloor(false);
        _controller.reverse();
        if (mounted && (!isTest)) {
           NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale?.failed ?? "", context.toLocale?.internal_server_error ?? "", Icons.report, Colors.red);
        }
      }
    }
  }

  _toggleExpanded() {
    isBimModelExpanded = !isBimModelExpanded;
    if (isBimModelExpanded) {
      _controller.forward();
      if (!widget.itemCubit.isTesting) {
        fetchFloor();
      }
    } else {
      _controller.reverse();
    }
  }

  bool get isAnyChecked {
    var index = widget.bimModel.floorList.where((element) => element.isChecked == true);
    if (index.length == widget.bimModel.floorList.length) {
      return false;
    } else if (index.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.itemCubit,
      child: BlocBuilder<ModelListItemCubit, ModelListItemState>(
        builder: (con, state) {
          return Container(
            key: Key("floor_expansion_container"),
            padding: const EdgeInsets.only(bottom: 8),
            color: AColors.themeLightColor,
            child: Column(
              key: Key("floor_expansion_column"),
              children: [
                Container(
                  key: Key("floor_expansion_container_2"),
                  color: AColors.themeLightColor,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          key: Key("floor_expansion_row"),
                          children: <Widget>[
                            GestureDetector(
                              key: Key("floor_expansion_gesture"),
                              onTap: () {
                                _toggleExpanded();
                              },
                              child: RotationTransition(
                                key: Key("floor_expansion_rotation"),
                                turns: _animationIcon,
                                child: const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            InkWell(
                              key: Key("floor_expansion_revision_check"),
                              onTap: () {
                                if (widget.bimModel.floorList.isEmpty && (!widget.itemCubit.isTesting)) {
                                  fetchFloor();
                                } else {
                                  widget.bimModel.isChecked = !widget.bimModel.isChecked!;
                                  widget.bimModel.isDownloaded = false;
                                  widget.itemCubit.checkedFloor(!widget.bimModel.isChecked!, widget.bimModel);
                                  List<String> tempList = [];
                                  if (widget.bimModel.isChecked!) {
                                    for (var element in widget.bimModel.floorList) {
                                      element.isChecked = true;
                                      tempList.add(element.fileName);
                                    }
                                    onAllTapHandel(widget.bimModel.revId.plainValue(), tempList);
                                    _modelListCubit.itemCheckToggle(true, widget.bimModel, false, widget.itemCubit.model);
                                  } else {
                                    for (var element in widget.bimModel.floorList) {
                                      element.isChecked = false;
                                      tempList.remove(element.fileName);
                                    }
                                    _modelListCubit.itemCheckToggle(false, widget.bimModel, true, widget.itemCubit.model);
                                    onAllTapHandel(widget.bimModel.revId.plainValue(), tempList);
                                  }
                                }
                              },
                              child: Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(color: isAnyChecked || widget.bimModel.isChecked! || (widget.bimModel.isDownloaded ?? false) ? AColors.themeBlueColor : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(width: 2, color: AColors.grColor)),
                                child: isAnyChecked
                                    ? const Center(
                                        key: Key("check_remove_icon"),
                                        child: Icon(
                                          Icons.remove,
                                          size: 20,
                                          color: Colors.white,
                                        ))
                                    : (widget.bimModel.isChecked!
                                        ? const Center(
                                            key: Key("check_icon"),
                                            child: Icon(
                                              Icons.check,
                                              size: 20,
                                              color: Colors.white,
                                            ))
                                        : (widget.bimModel.isDownloaded ?? false)
                                            ? const Center(
                                                child: Icon(
                                                Icons.remove,
                                                size: 20,
                                                color: Colors.white,
                                              ))
                                            : null),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Icon(
                              CupertinoIcons.cube,
                              key: Key("floor_expansion_cube_icon"),
                              color: AColors.blueColor,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            SizedBox(
                              width: Utility.isTablet
                                  ? MediaQuery.of(context).orientation == Orientation.landscape
                                      ? MediaQuery.of(context).size.width / 2.2
                                      : MediaQuery.of(context).size.width / 1.5
                                  : MediaQuery.of(context).size.width / 2.2,
                              child: NormalTextWidget(
                                widget.bimModel.name!.split("-").first.replaceAll("\"", "") + "- ${widget.bimModel.docTitle ?? widget.title}",
                                fontWeight: AFontWight.regular,
                                textAlign: TextAlign.start,
                                fontSize: 14,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      !isNetWorkConnected()
                          ? Positioned(
                              right: 0.0,
                              child: AnimatedContainer(
                                curve: Curves.easeOut,
                                duration: Duration(milliseconds: 500),
                                color: widget.bimModel.isDeleteExpanded ? Colors.white : Colors.transparent,
                                width: widget.bimModel.isDeleteExpanded
                                    ? Utility.isTablet
                                        ? MediaQuery.of(context).orientation == Orientation.landscape
                                            ? MediaQuery.of(context).size.width / 3
                                            : MediaQuery.of(context).size.width / 2
                                        : MediaQuery.of(context).size.width / 2
                                    : 90,
                                height: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: widget.bimModel.isDeleteExpanded ? AColors.userOnlineColor : Colors.transparent,
                                            width: 5,
                                          ),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          widget.bimModel.isDeleteExpanded
                                              ? Flexible(
                                                  child: SizedBox(
                                                    child: NormalTextWidget(
                                                      Utility.isTablet ? "Remove Offline Data" : "Remove",
                                                      fontWeight: AFontWight.bold,
                                                      textAlign: TextAlign.start,
                                                      fontSize: 16,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          widget.bimModel.isDeleteExpanded
                                              ? Flexible(
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          widget.bimModel.isDeleteExpanded = false;
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Icon(Icons.close),
                                                      )),
                                                )
                                              : Container(),
                                          Flexible(
                                            key: const Key('key_flexible_delete_single_floor'),
                                            child: IconButton(
                                              key: const Key('key_gesture_detector_delete_single_floor'),
                                              onPressed: () async {
                                                widget.itemCubit.deletedSingleFloorState(true);
                                                if (widget.bimModel.isDeleteExpanded) {
                                                  await widget.itemCubit.deleteByRevision(widget.bimModel);
                                                  widget.itemCubit.onTap(AConstants.checkBox);
                                                } else {
                                                  widget.bimModel.isDeleteExpanded = true;
                                                }
                                                widget.itemCubit.deletedSingleFloorState(false);
                                                _modelListCubit.emitDeleteModelListState();
                                              },
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                key: const Key('key_icon_delete_single_floor'),
                                                color: widget.bimModel.isDeleteExpanded ? Colors.red : AColors.grColorDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(
                              key: const Key('key_sized_box_network_connected'),
                            ),
                    ],
                  ),
                ),
                SizeTransition(
                  sizeFactor: _animation,
                  child: Container(
                    padding: const EdgeInsets.only(left: 40, top: 12),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        if (widget.itemCubit.isFloorLoading && floorList.isEmpty) ...[
                          const Center(
                            key: Key("floor_expansion_circularProgressIndicator"),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        ] else if (floorList.isEmpty) ...[
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(46),
                              child: Text(context.toLocale!.no_record_available),
                            ),
                          )
                        ] else ...[
                          for (int i = 0; i < widget.bimModel.floorList.length; i++) ...[
                            Column(
                              key: Key("floor_expansion_column_floors$i"),
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: isNetWorkConnected() ? 25 : 60,
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              widget.bimModel.floorList[i].isChecked = !widget.bimModel.floorList[i].isChecked;
                                              var itemIndex = widget.bimModel.floorList
                                                  .where(
                                                    (element) => element.isChecked == true,
                                                  )
                                                  .toList();

                                              if (itemIndex.isEmpty) {
                                                widget.bimModel.isChecked = false;
                                                _modelListCubit.itemCheckToggle(false, widget.bimModel, itemIndex.isEmpty, widget.itemCubit.model);
                                              } else {
                                                if (itemIndex.length == widget.bimModel.floorList.length) {
                                                  widget.bimModel.isChecked = true;
                                                }
                                                _modelListCubit.itemCheckToggle(true, widget.bimModel, false, widget.itemCubit.model);
                                              }
                                              onTapHandle(widget.bimModel.revId.plainValue(), widget.bimModel.floorList[i].fileName);
                                              widget.itemCubit.checkedFloor(!widget.bimModel.floorList[i].isChecked, widget.bimModel);
                                            },
                                            child: Container(
                                              height: 24,
                                              width: 24,
                                              decoration: BoxDecoration(color: widget.bimModel.floorList[i].isChecked ? AColors.themeBlueColor : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(width: 2, color: AColors.grColor)),
                                              child: widget.bimModel.floorList[i].isChecked
                                                  ? const Center(
                                                      child: Icon(
                                                      Icons.check,
                                                      size: 20,
                                                      color: Colors.white,
                                                    ))
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Icon(
                                            CupertinoIcons.cube,
                                            color: AColors.blueColor,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          SizedBox(
                                            width: Utility.isTablet
                                                ? MediaQuery.of(context).orientation == Orientation.landscape
                                                    ? MediaQuery.of(context).size.width / 2.2
                                                    : MediaQuery.of(context).size.width / 1.5
                                                : MediaQuery.of(context).size.width / 2.6,
                                            child: NormalTextWidget(
                                              "Floor (${widget.bimModel.floorList[i].levelName})",
                                              fontWeight: AFontWight.regular,
                                              textAlign: TextAlign.start,
                                              fontSize: 14,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    !isNetWorkConnected()
                                        ? Positioned(
                                            right: 0.0,
                                            child: AnimatedContainer(
                                              curve: Curves.easeOut,
                                              duration: Duration(milliseconds: 500),
                                              color: widget.bimModel.floorList[i].isDeleteExpanded ? Colors.white : Colors.transparent,
                                              width: widget.bimModel.floorList[i].isDeleteExpanded
                                                  ? Utility.isTablet
                                                      ? MediaQuery.of(context).orientation == Orientation.landscape
                                                          ? MediaQuery.of(context).size.width / 3
                                                          : MediaQuery.of(context).size.width / 2
                                                      : MediaQuery.of(context).size.width / 2
                                                  : 90,
                                              height: 60,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          color: widget.bimModel.floorList[i].isDeleteExpanded ? AColors.userOnlineColor : Colors.transparent,
                                                          width: 5,
                                                        ),
                                                        SizedBox(
                                                          width: 14,
                                                        ),
                                                        widget.bimModel.floorList[i].isDeleteExpanded
                                                            ? Flexible(
                                                                child: SizedBox(
                                                                  child: NormalTextWidget(
                                                                    Utility.isTablet ? "Remove Offline Data" : "Remove",
                                                                    fontWeight: AFontWight.bold,
                                                                    textAlign: TextAlign.start,
                                                                    fontSize: 16,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        widget.bimModel.floorList[i].isDeleteExpanded
                                                            ? Flexible(
                                                                child: GestureDetector(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        widget.bimModel.floorList[i].isDeleteExpanded = false;
                                                                      });
                                                                    },
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Icon(Icons.close),
                                                                    )),
                                                              )
                                                            : Container(),
                                                        Flexible(
                                                          key: const Key('key_flexible_delete_single_floor'),
                                                          child: IconButton(
                                                            key: const Key('key_gesture_detector_delete_single_floor'),
                                                            onPressed: () async {
                                                              widget.itemCubit.deletedSingleFloorState(true);
                                                              if (widget.bimModel.floorList[i].isDeleteExpanded) {
                                                                await widget.itemCubit.deleteSingleFloor(widget.bimModel, i, widget.bimList, widget.bimModel.floorList[i]);
                                                              } else {
                                                                widget.bimModel.floorList[i].isDeleteExpanded = true;
                                                              }
                                                              widget.itemCubit.deletedSingleFloorState(false);
                                                              _modelListCubit.emitDeleteModelListState();
                                                            },
                                                            icon: Icon(
                                                              Icons.delete_outline_rounded,
                                                              key: const Key('key_icon_delete_single_floor'),
                                                              color: widget.bimModel.floorList[i].isDeleteExpanded ? Colors.red : AColors.grColorDark,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            key: const Key('key_sized_box_network_connected'),
                                          ),
                                  ],
                                ),
                                if (!isNetWorkConnected()) ...[
                                  Container(
                                    color: Colors.black54,
                                    height: 0.2,
                                  ),
                                ] else ...[
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Divider()
                                ]
                              ],
                            ),
                          ],
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void onTapHandle(String revId, String fileName) {
    if (isNetWorkConnected()) return;

    if (widget.itemCubit.tempFloorList.containsKey(revId)) {
      if (widget.itemCubit.tempFloorList[revId]!.contains(fileName)) {
        widget.itemCubit.tempFloorList[revId]!.remove(fileName);
        if (widget.itemCubit.tempFloorList[revId]!.isEmpty) {
          widget.itemCubit.tempFloorList.remove(revId);
        }
        if (widget.itemCubit.tempFloorList.isEmpty) {
          widget.itemCubit.onTap(AConstants.checkBox);
        }
      } else {
        widget.itemCubit.tempFloorList[revId]!.add(fileName);
      }
    } else {
      if (widget.itemCubit.tempFloorList.isEmpty) {
        widget.itemCubit.onTap(AConstants.checkBox);
      }
      widget.itemCubit.tempFloorList[revId] = [fileName];
    }
  }

  void onAllTapHandel(String revId, List<String> fileName) {
    if (isNetWorkConnected()) return;
    if (widget.itemCubit.tempFloorList.containsKey(revId)) {
      if (fileName.isEmpty) {
        widget.itemCubit.tempFloorList.remove(revId);
        if (widget.itemCubit.tempFloorList.isEmpty) {
          widget.itemCubit.onTap(AConstants.checkBox);
        }
      }
    } else {
      if (widget.itemCubit.tempFloorList.isEmpty) {
        widget.itemCubit.onTap(AConstants.checkBox);
      }
      widget.itemCubit.tempFloorList[revId] = fileName;
    }
  }
}

class ProcessIcon extends StatefulWidget {
  const ProcessIcon({Key? key}) : super(key: key);

  @override
  State<ProcessIcon> createState() => ProcessIconState();
}

class ProcessIconState extends State<ProcessIcon> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animationController, curve: Curves.ease));
    animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      width: 26,
      child: Center(
        child: RotationTransition(
            key: Key("progress_icon"),
            turns: animation,
            child: const Icon(
              Icons.cached_rounded,
              color: Colors.green,
            )),
      ),
    );
  }
}

class SelectedProjectNotSetForOffline extends StatelessWidget {
  final Project selectedProject;
  final bool isShowValidation;
  final String projectName;

  SelectedProjectNotSetForOffline({Key? key, required this.selectedProject, required this.isShowValidation, required this.projectName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = 200;
    if (Utility.isTablet) {
      if ((MediaQuery.of(context).orientation == Orientation.portrait)) {
        width = MediaQuery.of(context).size.width * 0.6;
      } else {
        width = MediaQuery.of(context).size.width * 0.5;
      }
    } else {
      width = MediaQuery.of(context).size.width * 0.8;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              NormalTextWidget(
                context.toLocale!.lbl_offline_data_already_exists,
                fontWeight: AFontWight.bold,
                fontSize: 24,
                color: AColors.textColor,
              ),
              const SizedBox(height: 20),
              NormalTextWidget(
                isShowValidation ? "Please make current selected project as offline to mark model as offline." : context.toLocale!.lbl_offline_project_data_already_exists_model_list_tile(projectName ?? 'NA'),
                textAlign: TextAlign.center,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: AColors.grColorDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(color: AColors.lightGreyColor, height: 2, width: width),
        InkWell(
          onTap: () async {
            String projectId = await getIt<ModelListCubit>().getProjectId(selectedProject.projectID!, false);
            if (projectId.toLowerCase().length == 0) {
              bool includeAttachments = await StorePreference.isIncludeAttachmentsSyncEnabled();
              SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
                ..syncRequestId = DateTime.now().millisecondsSinceEpoch
                ..projectId = selectedProject.projectID
                ..projectName = selectedProject.projectName
                ..isMarkOffline = true
                ..isMediaSyncEnable = includeAttachments
                ..eSyncType = ESyncType.project
                ..projectSizeInByte = '0';
              getIt<SyncCubit>().syncProjectData({"buildFlavor": AConstants.buildFlavor!, "tab": AConstants.siteTab, "syncRequest": jsonEncode(syncRequestTask)});
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            height: 50,
            width: width,
            alignment: Alignment.center,
            child: NormalTextWidget(
              context.toLocale!.lbl_ok,
              textAlign: TextAlign.center,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AColors.userOnlineColor,
            ),
          ),
        ),
      ],
    );
  }
}

class TestVSync extends TickerProvider {
  @override
  Ticker createTicker(onTick) {
    return TestTicker(onTick);
  }
}

class TestTicker extends Ticker {
  TestTicker(super.onTick);

  @override
  start() async {}

  @override
  void stop({bool canceled = false}) {}

  @override
  bool get isActive => false;
}
