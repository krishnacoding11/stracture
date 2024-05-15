import 'package:field/data/model/calibrated.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

import '../../data/model/floor_details.dart';

class ModelDataRemovalDialog extends StatefulWidget {
  final VoidCallback onTapSelect;
  final List<FloorDetail> floorList;
  final List<CalibrationDetails> calibList;
  final String modelFileSize;
  final List<CalibrationDetails> calibrate;
  final String calibrateFileSize;
  final String removeFileSize;
  final List<FloorDetail> removeList;
  final List<CalibrationDetails> caliRemoveList;
  final String caliRemoveFileSize;

  const ModelDataRemovalDialog({
    Key? key,
    required this.onTapSelect,
    required this.floorList,
    required this.calibList,
    required this.modelFileSize,
    required this.calibrate,
    required this.calibrateFileSize,
    required this.removeList,
    required this.caliRemoveList,
    required this.removeFileSize,
    required this.caliRemoveFileSize,
  }) : super(key: key);

  @override
  State<ModelDataRemovalDialog> createState() => _ModelDataRemovalDialogState();
}

class _ModelDataRemovalDialogState extends State<ModelDataRemovalDialog> {
  Map<String, List<FloorDetail>> groupRemoveFloorsList = {};
  @override
  void initState() {
    groupRemoveFloorsList = widget.floorList.groupBy((FloorDetail obj) => obj.revName!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      key: Key('key_model_data_removal_dialog_test_center'),
      child: Container(
        key: Key('key_model_data_removal_dialog_test_container'),
        width: Utility.isTablet ? MediaQuery.of(context).size.width * .60 : MediaQuery.of(context).size.width * .90,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Material(
          child: Column(
            key: Key('key_model_data_removal_dialog_test_column'),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16),
              Icon(
                Icons.offline_pin_outlined,
                key: Key('key_model_download_dialog_offline_pin_icon'),
                size: 36,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              NormalTextWidget(
                "Remove",
                key: Key('key_model_data_removal_dialog_test_remove_text'),
                fontWeight: AFontWight.bold,
                textAlign: TextAlign.start,
                fontSize: 18,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              NormalTextWidget(
                context.toLocale!.are_sure_remove,
                key: Key('key_model_data_removal_dialog_test_are_sure_move'),
                fontWeight: AFontWight.regular,
                textAlign: TextAlign.start,
                color: AColors.iconGreyColor,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (widget.modelFileSize != "0" && widget.floorList.isNotEmpty) ...[
                FileContainer(
                  key: Key('key_model_data_removal_dialog_test_file_container_floor'),
                  title: "Remove ${double.parse(widget.modelFileSize.contains("MB") || widget.modelFileSize.contains("KB") ? widget.modelFileSize.split(" ")[0] : widget.modelFileSize).toStringAsFixed(2)} MB of model data.",
                  removeList:  groupRemoveFloorsList,
                  fileList: groupRemoveFloorsList,
                  calibrateList: [],
                  isRemove: true,
                ),
                const SizedBox(height: 8),
              ],
              if (widget.calibrateFileSize != "0" && widget.calibrateFileSize != "0.00 B" && widget.calibList.isNotEmpty) ...[
                FileContainer(
                  key: Key('key_model_data_removal_dialog_test_file_container_calib'),
                  title: "Remove ${widget.calibrateFileSize} of calibrated drawings data.",
                  calibrateList: widget.calibList,
                  isActive: widget.calibList.isNotEmpty,
                  fileList: {},
                  isCalibrate: true,
                ),
                const SizedBox(height: 8)
              ],
              NormalTextWidget(
                context.toLocale!.please_note_remove,
                key: Key('key_model_data_removal_dialog_test_please_note_remove'),
                fontWeight: AFontWight.regular,
                textAlign: TextAlign.start,
                color: AColors.iconGreyColor,
                fontSize: 11,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                key: Key('key_model_data_removal_dialog_test_row'),
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AColors.iconGreyColor, width: 1),
                            right: BorderSide(color: AColors.iconGreyColor, width: .5),
                          ),
                        ),
                        child: NormalTextWidget(
                          context.toLocale!.lbl_btn_cancel,
                          color: AColors.grColorDark,
                          fontWeight: AFontWight.semiBold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    key: Key('key_model_data_removal_dialog_test_expanded'),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onTapSelect();
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AColors.iconGreyColor, width: 1),
                            left: BorderSide(color: AColors.iconGreyColor, width: .5),
                          ),
                        ),
                        child: NormalTextWidget(
                          context.toLocale!.lbl_btn_yes,
                          color: AColors.themeBlueColor,
                          fontWeight: AFontWight.semiBold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FileContainer extends StatefulWidget {
  final String title;
  final Map<String, List<FloorDetail>> fileList;
  final bool isActive;
  final List<CalibrationDetails> calibrateList;
  final Map<String, List<FloorDetail>> removeList;
  final bool isCalibrate;
  final bool isRemove;
  final bool isCaliRemove;

  const FileContainer({
    super.key,
    required this.title,
    required this.fileList,
    required this.calibrateList,
    this.removeList = const {},
    this.isCalibrate = false,
    this.isRemove = false,
    this.isCaliRemove = false,
    this.isActive = true,
  });

  @override
  State<FileContainer> createState() => _FileContainerState();
}

class _FileContainerState extends State<FileContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animationIcon;
  bool _isExpanded = false;
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  // List<FloorDetail> _subListData = [];
  ScrollController _scrollController = ScrollController();

  void _toggleExpanded() {
    if (widget.isActive) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void initState() {


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _animationIcon = _controller.drive(_halfTween.chain(_easeInTween));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('key_model_remove_dialog_file_container_gesture_detector'),
      onTap: _toggleExpanded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            key: Key('key_model_remove_dialog_file_container_row'),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: NormalTextWidget(
                  widget.title,
                  fontWeight: AFontWight.semiBold,
                  textAlign: TextAlign.start,
                  color: AColors.black,
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              RotationTransition(
                turns: _animationIcon,
                child: const Icon(
                  Icons.arrow_drop_down_outlined,
                  size: 22,
                ),
              ),
            ],
          ),
          if (widget.isActive)
            SizedBox(
              key: Key('key_model_remove_dialog_file_container_sized_box'),
              width: double.infinity,
              child: SizeTransition(
                sizeFactor: _animation,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Scrollbar(
                        controller: _scrollController,
                        trackVisibility: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            for (var data in widget.calibrateList)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4, top: 8),
                                child: NormalTextWidget(
                                  data.calibrationName + " (" + data.sizeOf2DFile.toString() + " KB)",
                                  fontWeight: AFontWight.regular,
                                  textAlign: TextAlign.center,
                                  color: AColors.black,
                                  fontSize: 13,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            for (var group in widget.fileList.keys)...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4, top: 8),
                                child: NormalTextWidget(
                                  "$group",
                                  fontWeight: AFontWight.semiBold,
                                  textAlign: TextAlign.center,
                                  color: AColors.black,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              for (var data in widget.fileList[group]??[])...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4, top: 8),
                                  child: NormalTextWidget(
                                    "Floor (${data.levelName}) (${double.parse(data.fileSize.toString()).toStringAsFixed(2).toString()} MB)",
                                    fontWeight: AFontWight.regular,
                                    textAlign: TextAlign.center,
                                    color: AColors.black,
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )]
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}