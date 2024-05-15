import 'package:field/data/model/calibrated.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

import '../../data/model/floor_details.dart';

class ModelDownLoadDialog extends StatefulWidget {
  final VoidCallback onTapSelect;
  List<FloorDetail> floors;
  final String modelFileSize;
  List<CalibrationDetails> calibrate;
  final String calibrateFileSize;
  final String removeFileSize;
  final List<FloorDetail> removeList;
  final List<CalibrationDetails> caliRemoveList;
  final String caliRemoveFileSize;
  bool isUpdate;

  ModelDownLoadDialog({
    Key? key,
    required this.onTapSelect,
    required this.floors,
    this.isUpdate = false,
    required this.modelFileSize,
    required this.calibrate,
    required this.calibrateFileSize,
    required this.removeList,
    required this.caliRemoveList,
    required this.removeFileSize,
    required this.caliRemoveFileSize,
  }) : super(key: key);

  @override
  State<ModelDownLoadDialog> createState() => _ModelDownLoadDialogState();
}

class _ModelDownLoadDialogState extends State<ModelDownLoadDialog> {
  Map<String, List<FloorDetail>> groupFloorList = {};
  Map<String, List<FloorDetail>> groupRemoveFloorsList = {};
  @override
  void initState() {
    widget.floors = widget.floors.where((e) => e.isChecked && !e.isDownloaded).toList();
    widget.calibrate = widget.calibrate.where((e) => e.isChecked && !e.isDownloaded).toList();

    groupFloorList = widget.floors.groupBy((FloorDetail obj) => obj.revName!);
    groupRemoveFloorsList = widget.removeList.groupBy((FloorDetail obj) => obj.revName!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      key: Key('key_model_download_dialog_orientation_builder'),
      builder: (BuildContext context, Orientation orientation) {
        return Center(
          key: Key('key_model_download_dialog_center'),
          child: Container(
            key: Key('key_model_download_dialog_container'),
            width: Utility.isTablet
                ? orientation == Orientation.landscape
                    ? MediaQuery.of(context).size.width * .40
                    : MediaQuery.of(context).size.width * .60
                : MediaQuery.of(context).size.width * .94,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Material(
              child: Column(
                key: Key('key_model_download_dialog_column'),
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 16),
                  !widget.isUpdate
                      ? Image.asset(
                          AImageConstants.cloudDownloadOutlined,
                          key: Key('key_model_download_dialog_image_cloud_outlined'),
                          scale: 1,
                          height: 36,
                          width: 36,
                          color: Colors.green,
                        )
                      : Icon(
                          Icons.offline_pin_outlined,
                          key: Key('key_model_download_dialog_offline_pin_icon'),
                          size: 36,
                          color: Colors.green,
                        ),
                  const SizedBox(height: 8),
                  NormalTextWidget(
                    widget.isUpdate ? context.toLocale!.update : context.toLocale!.lbl_download,
                    key: Key('key_model_download_dialog_update_text_widget'),
                    fontWeight: AFontWight.bold,
                    textAlign: TextAlign.start,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  NormalTextWidget(
                    widget.isUpdate ? context.toLocale!.are_sure_update : context.toLocale!.are_sure_download,
                    key: Key('key_model_download_dialog_download_update_text'),
                    fontWeight: AFontWight.regular,
                    textAlign: TextAlign.center,
                    color: AColors.iconGreyColor,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                      key: Key('key_model_download_dialog_single_child_scroll_view'),
                      child: Column(
                        children: [
                          if (widget.floors.isNotEmpty) ...[
                            Padding(
                              key: Key('key_model_download_dialog_padding_floor_size'),
                              padding: EdgeInsets.all(Utility.isTablet ? 0.0 : 8.0),
                              child: FileContainer(
                                key: Key('key_download_model_file_size'),
                                title: "Download ${widget.modelFileSize} of model data",
                                floorList: groupFloorList,
                                isActive: widget.floors.isNotEmpty,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (widget.removeList.isNotEmpty) ...[
                            Padding(
                              key: Key('key_model_download_dialog_padding_remove_file_size'),
                              padding: EdgeInsets.all(Utility.isTablet ? 0.0 : 8.0),
                              child: FileContainer(
                                title: "Remove ${widget.removeFileSize} of model data",
                                removeList: groupRemoveFloorsList,
                                isRemove: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (widget.caliRemoveList.isNotEmpty) ...[
                            Padding(
                              key: Key('key_model_download_dialog_padding_calib_remove'),
                              padding: EdgeInsets.all(Utility.isTablet ? 0.0 : 8.0),
                              child: FileContainer(
                                title: "Remove ${widget.caliRemoveFileSize} of calibrated drawings data",
                                calibrateList: widget.caliRemoveList,
                                isCaliRemove: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (widget.calibrate.isNotEmpty) ...[
                            Padding(
                              key: Key('key_model_download_dialog_padding_calib_file'),
                              padding: EdgeInsets.all(Utility.isTablet ? 0.0 : 8.0),
                              child: FileContainer(
                                title: "Download ${widget.calibrateFileSize} of calibrated drawings data",
                                calibrateList: widget.calibrate,
                                isActive: widget.calibrate.isNotEmpty,
                                isCalibrate: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      )),
                  NormalTextWidget(
                    context.toLocale!.please_note_download,
                    key: Key('key_model_download_dialog_download_widget'),
                    fontWeight: AFontWight.regular,
                    textAlign: TextAlign.start,
                    color: AColors.iconGreyColor,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    key: Key('key_model_download_dialog_row'),
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
                        key: Key('key_model_download_dialog_expanded'),
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
      },
    );
  }
}

class FileContainer extends StatefulWidget {
  final String title;
  final Map<String, List<FloorDetail>> floorList;
  final bool isActive;
  final List<CalibrationDetails> calibrateList;
  final Map<String, List<FloorDetail>> removeList;
  final bool isCalibrate;
  final bool isRemove;
  final bool isCaliRemove;

  const FileContainer({
    super.key,
    required this.title,
    this.floorList = const {},
    this.calibrateList = const [],
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
  ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  static final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

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
      onTap: _toggleExpanded,
      child: Column(
        key: Key('key_file_container_column'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: NormalTextWidget(
                  widget.title,
                  key: Key('key_file_container_title'),
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
            Container(
              key: Key('key_file_container_container'),
              constraints: BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Scrollbar(
                  controller: _scrollController,
                  trackVisibility: true,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SizeTransition(
                          sizeFactor: _animation,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                if (widget.isCalibrate) ...[
                                  for (var data in widget.calibrateList)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4, top: 8),
                                      child: NormalTextWidget(
                                        data.calibrationName + " (" + (data.sizeOf2DFile).toString() + " KB)",
                                        fontWeight: AFontWight.regular,
                                        textAlign: TextAlign.center,
                                        color: AColors.black,
                                        fontSize: 14,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ] else if (widget.isRemove) ...[
                                  for (var group in widget.removeList.keys) ...[
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
                                    for (var data in widget.removeList[group] ?? []) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4, top: 8),
                                        child: NormalTextWidget(
                                          "Floor (${data.levelName}) (${double.parse(data.fileSize.toString()).toStringAsFixed(2).toString() != "0.00" ? double.parse(data.fileSize.toString()).toStringAsFixed(2).toString() : double.parse(data.fileSize.toString()).toStringAsFixed(5).toString()} MB)",
                                          fontWeight: AFontWight.regular,
                                          textAlign: TextAlign.center,
                                          color: AColors.black,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ]
                                  ]
                                ] else if (widget.isCaliRemove) ...[
                                  for (var data in widget.calibrateList)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4, top: 8),
                                      child: NormalTextWidget(
                                        data.calibrationName + " (" + data.sizeOf2DFile.toString() + " KB)",
                                        fontWeight: AFontWight.regular,
                                        textAlign: TextAlign.center,
                                        color: AColors.black,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ] else ...[
                                  for (var group in widget.floorList.keys) ...[
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
                                    for (var data in widget.floorList[group] ?? []) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4, top: 8),
                                        child: NormalTextWidget(
                                          "Floor (${data.levelName}) (${double.parse(data.fileSize.toString()).toStringAsFixed(2).toString() != "0.00" ? double.parse(data.fileSize.toString()).toStringAsFixed(2).toString() : double.parse(data.fileSize.toString()).toStringAsFixed(5).toString()} MB)",
                                          fontWeight: AFontWight.regular,
                                          textAlign: TextAlign.center,
                                          color: AColors.black,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ]
                                  ]
                                ]
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class RadioTile<T> extends StatelessWidget {
  final String title;
  final T value;
  final T selectedValue;
  final Function(T) onChange;

  const RadioTile({super.key, required this.title, required this.value, required this.selectedValue, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChange(value);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 60, bottom: 12),
        child: Row(
          children: <Widget>[
            Icon(
              value == selectedValue ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.grey,
              size: 26,
            ),
            const SizedBox(width: 8),
            NormalTextWidget(
              title,
              fontWeight: AFontWight.regular,
              textAlign: TextAlign.start,
              color: AColors.black,
              fontSize: 14,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
