import 'dart:async';

import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/atheme.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import '../data/model/model_vo.dart';
import '../injection_container.dart';
import '../presentation/managers/color_manager.dart';
import '../utils/constants.dart';

class ModelTreeWidget extends StatefulWidget {
  const ModelTreeWidget(this.arguments, {Key? key}) : super(key: key);
  final Map<String, dynamic> arguments;

  @override
  State<ModelTreeWidget> createState() => _ModelTreeWidgetState();
}

class _ModelTreeWidgetState extends State<ModelTreeWidget> with SingleTickerProviderStateMixin {
  ModelTreeCubit _modelTreeCubit = di.getIt<ModelTreeCubit>();
  late TabController _tabController;

  get model => Model();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
    _modelTreeCubit.setOfflineParamsData(widget.arguments);
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Dialog(
            key: Key('key_model_tree_dialog'),
            elevation: 12,
            insetPadding: Utility.isTablet ? EdgeInsets.fromLTRB(100, 30, 100, 30) : const EdgeInsets.all(16),
            backgroundColor: AColors.white,
            child: Theme(
              data: ATheme.transparentDividerTheme,
              child: MultiBlocListener(
                listeners: [
                  BlocListener<ModelTreeCubit, ModelTreeState>(
                    listener: (context, state) {},
                  ),
                ],
                child: BlocBuilder<ModelTreeCubit, ModelTreeState>(builder: (context, state) {
                  return Column(children: [
                    widgetHeaderSelectLocation(),
                    Expanded(flex: 3, child: modelTree(context, state)),
                    const SizedBox(
                      height: 18,
                    ),
                    bottomButton(orientation),
                  ]);
                }),
              ),
            ));
      },
    );
  }

  showMaterialBanner(String subMessage) {
    CustomFlushBar(
      message: context.toLocale!.warning,
      subMessage: subMessage,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.yellow,
      messageColor: Colors.black,
      icon: Icon(
        Icons.warning,
        color: Colors.yellow,
      ),
    ).show(context);
  }

  Widget widgetHeaderSelectLocation() {
    return Container(
      key: Key('key_model_tree_select_location_controller'),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
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
        key: Key('key_model_tree_row_icon_close'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: NormalTextWidget(
              AConstants.modelName,
              key: Key('key_model_tree_model_name_text'),
              fontWeight: AFontWight.semiBold,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            key: Key('key_model_tree_close_icon'),
            icon: const Icon(Icons.close_sharp),
            onPressed: () {
              closeModelTreeDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget bottomButton(Orientation orientation) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 1.0,
          color: AColors.lightGreyColor,
        ),
        Row(
          children: <Widget>[
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 42,
                width: 110,
                child: OutlinedButton(
                  onPressed: () {
                    getIt<online_model_viewer.OnlineModelViewerCubit>().emitNormalWebState();
                    getIt<online_model_viewer.OnlineModelViewerCubit>().isCalibListShow = false;
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey, width: .8)),
                  child: Text(
                    AConstants.cancel,
                    style: TextStyle(
                      color: AColors.themeBlueColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 42,
                width: 110,
                child: ElevatedButton(
                  onPressed: () {
                    getIt<online_model_viewer.OnlineModelViewerCubit>().isCalibListShow = false;
                    if (_modelTreeCubit.okButtonActive) {
                      if (_modelTreeCubit.selectedFloorList.isNotEmpty) {
                        _modelTreeCubit.updateModel(_modelTreeCubit.selectedFloorList, _modelTreeCubit.lastLoadedModels);
                        _modelTreeCubit.updateCalibList(orientation);
                        closeModelTreeDialog();
                      } else {
                        showMaterialBanner(context.toLocale!.please_select_at_least_one_floor);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: !_modelTreeCubit.okButtonActive ? AColors.lightGreyColor : AColors.aPrimaryColor, disabledForegroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  child: Text(
                    context.toLocale!.lbl_ok,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  void closeModelTreeDialog({Map<String, dynamic>? result}) {
    getIt<online_model_viewer.OnlineModelViewerCubit>().emitNormalWebState();
    getIt<online_model_viewer.OnlineModelViewerCubit>().isCalibListShow = false;
    Navigator.of(context).pop(result);
  }

  Widget modelTree(BuildContext context, ModelTreeState state) {
    if (state is LoadingState) {
      return const Center(
          child: ACircularProgress(
        key: Key('key_model_tree_a_circular_progress'),
      ));
    } else {
      return loadModelTree();
    }
  }

  Widget loadModelTree() {
    return Column(
      key: Key('key_model_tree_column'),
      children: [
        TabBar(
          key: const Key('key_model_tree_tab_bar'),
          indicatorColor: AColors.aPrimaryColor,
          padding: EdgeInsets.zero,
          controller: _tabController,
          tabs: [
            Container(
              key: Key('key_model_tree_model_container'),
              height: 50.0,
              alignment: Alignment.center,
              child: Text(
                AConstants.models,
                style: TextStyle(color: AColors.aPrimaryColor),
              ),
            ),
            Container(
              key: Key('key_model_tree_calibrated_container'),
              height: 50.0,
              alignment: Alignment.center,
              child: Text(
                "Calibrations",
                style: TextStyle(color: AColors.aPrimaryColor),
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            key: Key('key_model_tree_expanded_tab_bar_view'),
            controller: _tabController,
            children: [
              _modelTreeCubit.bimModelsDB.isEmpty
                  ? Align(
                      alignment: Alignment.center,
                      child: Text(context.toLocale!.no_record_available),
                    )
                  : ListView.builder(
                      key: Key('key_model_tree_list_view'),
                      shrinkWrap: true,
                      itemCount: _modelTreeCubit.bimModelsDB.length,
                      itemBuilder: (context, index) {
                        return ExpansionTile(
                          initiallyExpanded: true,
                          maintainState: true,
                          title: NormalTextWidget(
                            "${_modelTreeCubit.bimModelsNames[index]}",
                            fontWeight: AFontWight.bold,
                            textAlign: TextAlign.start,
                            fontSize: 16,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _modelTreeCubit.listOfFloors[index].length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FloorExpansionTile(
                                        modelIndex: index,
                                        revIndex: i,
                                      )
                                    ],
                                  );
                                }),
                          ],
                        );
                      },
                    ),
              _modelTreeCubit.calibrationList.isEmpty
                  ? Align(
                      alignment: Alignment.center,
                      child: Text(context.toLocale!.no_record_available),
                    )
                  : ListView.builder(
                      key: Key('key_model_tree_model_calib_list_view'),
                      shrinkWrap: true,
                      itemCount: _modelTreeCubit.calibrationList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.only(left: 20, top: 12),
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  if (getIt<online_model_viewer.OnlineModelViewerCubit>().selectedCalibrationName == _modelTreeCubit.calibrationList[index].calibrationName) {
                                    showMaterialBanner(context.toLocale!.unable_to_uncheck_floor);
                                    return;
                                  }
                                  _modelTreeCubit.emitNormalState();
                                  _modelTreeCubit.updateCalibrationList(index,!_modelTreeCubit.calibrationList[index].isChecked);
                                  _modelTreeCubit.emitUpdatedState();
                                },
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: _modelTreeCubit.calibrationList[index].isChecked ? AColors.themeBlueColor : Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      width: 2,
                                      color: AColors.grColor,
                                    ),
                                  ),
                                  child: _modelTreeCubit.calibrationList[index].isChecked
                                      ? const Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        )
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
                              NormalTextWidget(
                                "${_modelTreeCubit.calibrationList[index].calibrationName}",
                                fontWeight: AFontWight.regular,
                                textAlign: TextAlign.start,
                                fontSize: 14,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class FloorExpansionTile extends StatefulWidget {
  final int revIndex;
  final int modelIndex;

  const FloorExpansionTile({super.key, required this.revIndex, required this.modelIndex});

  @override
  State<FloorExpansionTile> createState() => _FloorExpansionTileState();
}

class _FloorExpansionTileState extends State<FloorExpansionTile> with SingleTickerProviderStateMixin {
  ModelTreeCubit _modelTreeCubit = di.getIt<ModelTreeCubit>();

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animationIcon;
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _animationIcon = _controller.drive(_halfTween.chain(_easeInTween));

    _controller.forward();
  }

  _toggleExpanded() {
    isExpanded = !isExpanded;
    if (isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28.0, top: 8),
      child: Column(
        children: [
          Row(
            children: [
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
                width: 6,
              ),
              InkWell(
                onTap: () {
                  if ((_modelTreeCubit.revisionsChecked[widget.modelIndex][widget.revIndex] && _modelTreeCubit.lastLoadedModels.isEmpty)) {
                    _modelTreeCubit.okButtonActive = false;
                  } else {
                    _modelTreeCubit.okButtonActive = true;
                  }
                  _modelTreeCubit.emitAfterLoadedState();
                  _modelTreeCubit.selectAll(widget.modelIndex, widget.revIndex);
                  _modelTreeCubit.emitLoadedState();
                },
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(color: _modelTreeCubit.revisionsChecked[widget.modelIndex][widget.revIndex] ? AColors.themeBlueColor : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(width: 2, color: AColors.grColor)),
                  child: _modelTreeCubit.revisionsChecked[widget.modelIndex][widget.revIndex]
                      ? Center(
                          child: Icon(
                            _modelTreeCubit.listOfIsCheckedFloors[widget.modelIndex][widget.revIndex].where((element) => element == true).length == _modelTreeCubit.listOfFloors[widget.modelIndex][widget.revIndex].length ? Icons.check : Icons.remove,
                            size: 20,
                            color: Colors.white,
                          ),
                        )
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
              Flexible(
                child: NormalTextWidget(
                  "${_modelTreeCubit.revisionNames[widget.modelIndex][widget.revIndex].replaceAll("\"", "")}",
                  fontWeight: AFontWight.regular,
                  textAlign: TextAlign.start,
                  fontSize: 14,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              padding: const EdgeInsets.only(left: 28.0, bottom: 16),
              child: Column(
                children: [
                  for (int j = 0; j < _modelTreeCubit.listOfFloors[widget.modelIndex][widget.revIndex].length; j++)
                    Container(
                      padding: const EdgeInsets.only(left: 20, top: 12),
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              _modelTreeCubit.emitLoadedState();
                              _modelTreeCubit.updatedFloor(widget.modelIndex, widget.revIndex, j);
                              _modelTreeCubit.emitUpdatedState();
                            },
                            child: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(color: _modelTreeCubit.listOfIsCheckedFloors[widget.modelIndex][widget.revIndex][j] ? AColors.themeBlueColor : Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(width: 2, color: AColors.grColor)),
                              child: _modelTreeCubit.floorList[widget.modelIndex].isChecked
                                  ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    )
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
                          Expanded(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: NormalTextWidget(
                                "Floor (${_modelTreeCubit.listOfFloors[widget.modelIndex][widget.revIndex][j].levelName})",
                                fontWeight: AFontWight.regular,
                                textAlign: TextAlign.start,
                                fontSize: 14,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomFlushBar extends StatefulWidget {
  final String message;
  final String? subMessage;
  final Duration duration;
  final Color backgroundColor;
  final Color messageColor;
  final Icon? icon;

  const CustomFlushBar({
    Key? key,
    required this.message,
    required this.duration,
    this.backgroundColor = Colors.black,
    this.messageColor = Colors.white,
    this.icon,
    this.subMessage,
  }) : super(key: key);

  void show(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return this;
      },
    );
    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  @override
  _CustomFlushBarState createState() => _CustomFlushBarState();
}

class _CustomFlushBarState extends State<CustomFlushBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _timer = Timer(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Positioned(
          top: MediaQuery.of(context).viewInsets.bottom + _controller.value * (18 + MediaQuery.of(context).padding.bottom),
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _controller.value,
            child: Container(
              height: kToolbarHeight + 16,
              margin: EdgeInsets.only(top: Utility.isTablet ? 12 : 20),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 8,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      color: widget.backgroundColor,
                    ),
                    const SizedBox(width: 8),
                    if (widget.icon != null) widget.icon!,
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message,
                          style: TextStyle(color: widget.messageColor, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        if (widget.subMessage != null)
                          Text(
                            widget.subMessage ?? "",
                            style: TextStyle(
                              color: widget.messageColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
