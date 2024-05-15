import 'package:field/bloc/project_list_item/project_item_cubit.dart';
import 'package:field/bloc/project_list_item/project_item_cubit.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/bottom_navigation/models/model_storage_details.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/storage_widget/storage_details_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/model_list/model_list_cubit.dart' as model_cubit;
import '../../../../../bloc/storage_details/storage_details_cubit.dart';
import '../../../../../injection_container.dart';
import '../../../../../utils/navigation_utils.dart';
import '../models_list_screen.dart';
import 'model_storage_widget_landscape.dart';

class ModelStorageWidget extends StatefulWidget {
  final Project selectedProject;
  const ModelStorageWidget({super.key, required this.selectedProject});

  @override
  State<ModelStorageWidget> createState() => _ModelStorageWidgetState();
}

class _ModelStorageWidgetState extends State<ModelStorageWidget> with SingleTickerProviderStateMixin {
  late String lastDownloadedDate;
  final StorageDetailsCubit storageCubit = getIt<StorageDetailsCubit>();
  late AnimationController _controller;
  late Animation<double> _animation;
  final model_cubit.ModelListCubit _modelListCubit = getIt<model_cubit.ModelListCubit>();

  @override
  void initState() {
    storageCubit.initStorageSpace();
    storageCubit.updateModelSize(_modelListCubit.selectedModel);
    lastDownloadedDate = storageCubit.getCurrentDate().replaceAll("-", " ");
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    storageCubit.showDetails = false;
    super.initState();
  }

  _toggleExpanded() async {
    storageCubit.showDetails = !storageCubit.showDetails;
    if (storageCubit.showDetails) {
      storageCubit.showStorageDetails(true);
      _controller.forward();
    } else {
      await _controller.reverse();
      storageCubit.showStorageDetails(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: storageCubit,
      child: BlocListener<StorageDetailsCubit, StorageDetailsState>(
        listener: (BuildContext context, state) async {
          if(state is ProjectUnmarkState){
            NavigationUtils.mainNavigationKey.currentContext!.shownCircleSnackBar(context.toLocale!.warning, context.toLocale!.selected_project_has_been_unmarked_for_offline_usage, Icons.warning_rounded, AColors.warningIconColor);
          }
        },
        child: BlocBuilder<StorageDetailsCubit, StorageDetailsState>(builder: (context, state) {
          return Container(
            key: const Key("key_container_model_storage_portrait"),
            padding: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            child: Column(
              key: const Key("key_column"),
              children: [
                Padding(
                  key: const Key("key_padding"),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: NormalTextWidget(
                          "Last download - $lastDownloadedDate",
                          key: const Key("key_download_size_text_widget"),
                          fontWeight: AFontWight.medium,
                          textAlign: TextAlign.start,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RefreshButton(
                              size: 16.0,
                              key: const Key("key_refresh_button"),
                              onTap: () {
                                storageCubit.modelSelectState(storageCubit.selectedModel);
                              }),
                          NormalTextWidget(
                            "${getStorageSpaceSize()} Used",
                            key: const Key("key_storage_space_text"),
                            fontWeight: AFontWight.medium,
                            textAlign: TextAlign.start,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  margin: EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 16),
                  child: buildStackedBar100Chart(context),
                ),
                !storageCubit.showDetails
                    ? Row(
                        children: [
                          const SizedBox(width: 16),
                          const StorageDetailsList(),
                          const Spacer(),
                          GestureDetector(
                            key: Key("key_details_toggle_button"),
                            onTap: () {
                              _toggleExpanded();
                            },
                            child: Row(
                              children: [
                                Icon(Icons.expand_more, size: 24.0, color: Colors.grey),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  context.toLocale!.lbl_details,
                                  style: TextStyle(fontSize: 20, color: Colors.grey),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizeTransition(
                  sizeFactor: _animation,
                  child: Container(
                    height: 350,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            const StorageDetailsList(),
                            const Spacer(),
                          ],
                        ),
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Colors.grey[100],
                          ),
                          padding: const EdgeInsets.only(
                            left: 15,
                            top: 15,
                            right: 15,
                          ),
                          margin: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StorageDetails(
                                      detailType: "calibrate",
                                      iconData: AImageConstants.calibrationFile,
                                      totalSpace: formatStorageSize((storageCubit.storageSpace?.totalSize ?? 0).toString()) - double.parse(storageCubit.modelsFileSize.split(" ")[0]),
                                      usedFileSizeUnformat: double.parse(storageCubit.calibFileSize.split(" ")[0]),
                                      title: context.toLocale!.file_related_data,
                                      usedFileSize: _modelListCubit.allItems.isEmpty
                                          ? "0.00 MB"
                                          : formatFileSize(double.parse(storageCubit.calibFileSize.split(" ")[0])).toString() != "0" || formatFileSize(double.parse(storageCubit.calibFileSize.split(" ")[0])).toString() != "0.00 B"
                                          ? formatFileSize(double.parse(storageCubit.calibFileSize.split(" ")[0]))
                                          : "0.00 MB",
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    StorageDetails(
                                      detailType: "model",
                                      key: const Key("key_storage_details"),
                                      iconData: AImageConstants.cubeOutline,
                                      title: context.toLocale!.model_related_data,
                                      totalSpace: formatStorageSize((storageCubit.storageSpace?.totalSize ?? 0).toString()) - double.parse(storageCubit.calibFileSize.split(" ")[0]),
                                      usedFileSizeUnformat: double.parse(storageCubit.modelsFileSize.split(" ")[0]),
                                      usedFileSize: _modelListCubit.allItems.isEmpty
                                          ? "0.00 MB"
                                          : formatFileSize(double.parse(storageCubit.modelsFileSize.split(" ")[0])).toString() != "0" || formatFileSize(double.parse(storageCubit.modelsFileSize.split(" ")[0])).toString() != "0.00 B"
                                              ? formatFileSize(double.parse(storageCubit.modelsFileSize.split(" ")[0]))
                                              : "0.00 MB",
                                    ),
                                  ],
                                ), // More details chart here
                              ),
                              Spacer(),
                              Center(
                                key: const Key("key_center"),
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(side: BorderSide(color: AColors.black, width: .5)),
                                      onPressed: () {
                                        storageCubit.onClearButton(context,storageCubit,widget.selectedProject);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            size: 17.0,
                                            color: AColors.themeBlueColor,
                                          ),
                                          NormalTextWidget(
                                            storageCubit.selectedModel == null ? context.toLocale!.clear_project_data : context.toLocale!.clear_model_data,
                                            fontWeight: AFontWight.medium,
                                            textAlign: TextAlign.start,
                                            color: AColors.themeBlueColor,
                                            fontSize: 15,
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _toggleExpanded();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.keyboard_arrow_up_outlined, size: 26.0, color: Colors.grey),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          context.toLocale!.lbl_hide,
                                          style: TextStyle(fontSize: 20, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  String getStorageSpaceSize() {
    var totalSize = (double.parse(storageCubit.modelsFileSize.split(" ")[0]) + (double.parse(storageCubit.calibFileSize.split(" ")[0])));
    return "${totalSize.toString() == "0.0"?'0.00 MB':_modelListCubit.allItems.isNotEmpty ? formatFileSize(totalSize) : '0.00 MB'} of ${storageCubit.storageSpace?.totalSize ?? 0}";
  }

  Widget buildStackedBar100Chart(BuildContext context) {
    if (!storageCubit.isDataLoading) storageCubit.maxDataValue = storageCubit.data.map((storage) => storage.value).reduce((a, b) => a + b);
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AColors.lightBlueColor,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: Offset(1.0, 0.0), spreadRadius: 1, blurRadius: .8)],
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Row(
        children: List.generate(storageCubit.data.length, (index) {
          final storage = storageCubit.data[index];
          double percentage = (storage.value / storageCubit.maxDataValue);
          double barWidth = percentage * storageCubit.totalSpace;

          return Expanded(
            flex: (percentage * 100).round(),
            child: Container(
              width: barWidth,
              color: storage.color,
            ),
          );
        }),
      ),
    );
  }
}
