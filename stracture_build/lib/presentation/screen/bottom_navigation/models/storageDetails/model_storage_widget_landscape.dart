import 'package:field/bloc/model_list/model_list_cubit.dart' as model_cubit;
import 'package:field/data/model/project_vo.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/bottom_navigation/models/model_storage_details.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/storage_widget/storage_details_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/project_list_item/project_item_cubit.dart';
import '../../../../../bloc/storage_details/storage_details_cubit.dart';
import '../../../../../injection_container.dart';
import '../../../../../networking/network_info.dart';
import '../../../../../utils/navigation_utils.dart';
import '../../../../managers/font_manager.dart';
import '../models_list_screen.dart';

class ModelStorageLandscapeWidget extends StatefulWidget {
  final Project selectedProject;

  const ModelStorageLandscapeWidget({super.key, required this.selectedProject});

  @override
  State<ModelStorageLandscapeWidget> createState() => _ModelStorageLandscapeWidgetState();
}

class _ModelStorageLandscapeWidgetState extends State<ModelStorageLandscapeWidget> with SingleTickerProviderStateMixin {
  late String lastDownloadedDate;
  final StorageDetailsCubit storageCubit = getIt<StorageDetailsCubit>();
  final model_cubit.ModelListCubit _modelListCubit = getIt<model_cubit.ModelListCubit>();

  @override
  void initState() {
    storageCubit.initStorageSpace();
    storageCubit.updateModelSize(_modelListCubit.selectedModel);
    lastDownloadedDate = storageCubit.getCurrentDate().replaceAll("-", " ");
    super.initState();
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
            key: Key('key_container_landscape_storage'),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
            child: Column(
              key: Key('key_column_landscape_storage'),
              children: [
                Padding(
                  key: Key('key_padding_landscape_storage'),
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NormalTextWidget(
                        "Last download - $lastDownloadedDate",
                        key: Key('key_last_downloaded_text_landscape_storage'),
                        fontWeight: AFontWight.medium,
                        textAlign: TextAlign.start,
                        fontSize: 16,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: NormalTextWidget(
                              "${getStorageSpaceSize()} Used",
                              key: Key('key_storage_space_text_landscape_storage'),
                              fontWeight: AFontWight.medium,
                              textAlign: TextAlign.start,
                              fontSize: 16,
                            ),
                          ),
                          RefreshButton(
                            key: Key('key_refresh_button'),
                            onTap: () {
                              storageCubit.modelSelectState(storageCubit.selectedModel);
                            },
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  key: Key('key_build_stack_bar_landscape_storage'),
                  height: 32,
                  margin: EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
                  child: buildStackedBar100Chart(context),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 2, bottom: 26),
                  child: StorageDetailsList(),
                ),
                Container(
                  key: Key('key_storage_details_container'),
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StorageDetails(
                        key: Key('key_storage_details_calibrate'),
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
                        key: Key('key_storage_details_model'),
                        iconData: AImageConstants.cubeOutline,
                        detailType: "model",
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
                const SizedBox(height: 50),
                Center(
                  key: Key('key_center_clear_project_button'),
                  child: SizedBox(
                    height: 50,
                    width: 242,
                    child: OutlinedButton(
                        key: Key('key_outlined_landscape_button'),
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AColors.black, width: .5)),
                        onPressed: () {
                          storageCubit.onClearButton(context, storageCubit, widget.selectedProject);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Icon(
                                Icons.delete_outline,
                                size: 18.0,
                                color: AColors.themeBlueColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              flex: 7,
                              child: NormalTextWidget(
                                storageCubit.selectedModel == null ? context.toLocale!.clear_project_data : context.toLocale!.clear_model_data,
                                key: Key('key_text_clear_project'),
                                fontWeight: AFontWight.medium,
                                textAlign: TextAlign.start,
                                color: AColors.themeBlueColor,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
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

  String getStorageSpaceSize() {
    var totalSize = (double.parse(storageCubit.modelsFileSize.split(" ")[0]) + (double.parse(storageCubit.calibFileSize.split(" ")[0])));
    return "${_modelListCubit.allItems.isEmpty ? "0.00 MB" : formatFileSize(totalSize)} of ${storageCubit.storageSpace?.totalSize ?? 0}";
  }
}

class RefreshButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  RefreshButton({super.key, required this.onTap, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.only(top: 4, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.refresh, size: (size + 4), color: AColors.blueColor),
            NormalTextWidget(
              context.toLocale!.lbl_refresh,
              fontWeight: AFontWight.semiBold,
              textAlign: TextAlign.start,
              color: AColors.blueColor,
              maxLines: 1,
              fontSize: size,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
