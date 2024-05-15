import 'package:field/data/dao/model_db_delete.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/model_dialogs/model_data_removal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:storage_space/storage_space.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../bloc/model_list/model_list_cubit.dart' as model_cubit;
import '../../../../injection_container.dart';
import '../../data/model/floor_details.dart';
import '../../domain/use_cases/model_list_use_case/model_list_use_case.dart';
import '../../presentation/screen/bottom_navigation/models/models_list_screen.dart';
import '../model_list/model_list_cubit.dart';
import '../project_list_item/project_item_cubit.dart';

part 'storage_details_state.dart';

class StorageDetailsCubit extends Cubit<StorageDetailsState> {
  StorageDetailsCubit() : super(PaginationListInitial());
  final ModelListUseCase _modelListUseCase = getIt<ModelListUseCase>();
  List<ChartData>? chartData;
  StorageSpace? storageSpace;
  TooltipBehavior? tooltipBehavior;
  late String lastDownloadedDate;
  String? freeSize, totalSize;
  List<FloorDetail> floorListSelected = [];
  List<CalibrationDetails> calibList = [];
  bool showDetails = false;
  Model? selectedModel;
  bool isDataLoading = true;
  final model_cubit.ModelListCubit _modelListCubit = getIt<model_cubit.ModelListCubit>();
  String modelsFileSize = "0";
  String calibFileSize = "0";
  double modelsSize = 0.0;
  double calibSize = 0.0;

  Future<void> initStorageSpace() async {
    isDataLoading = true;
    selectedModel = null;
    data = [];
    totalSpace = 0.0;
    maxDataValue = 0.0;
    modelsFileSize = "0.0";
    calibFileSize = "0.0";
    StorageSpace storageSpace = await getStorageSpace(
      lowOnSpaceThreshold: 10 * 1024 * 1024 * 1024, // 2GB
      fractionDigits: 1,
    );
    this.storageSpace = storageSpace;
    modelSelectState(selectedModel);
  }

  String getCurrentDate() {
    var date = DateTime.now();
    final DateFormat formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(date).toString();
  }

  List<StorageData> data = [];
  double totalSpace = 0.0;
  double maxDataValue = 0.0;

  initData(StorageSpace? storageSpace) {
    data = [];
    totalSpace = 0.0;
    maxDataValue = 0.0;

    var model = double.parse(modelsFileSize.split(" ").first);
    var calib = double.parse(calibFileSize.split(" ").first);
    totalSpace = double.parse(storageSpace?.totalSize.split(" ").first ?? "0") * 1024;

    data = [
      StorageData(name: 'Models', value: model, color: AColors.modelColorForStorage),
      StorageData(name: 'Files', value: calib, color: AColors.blueColor),
      StorageData(name: 'Free Space', value: totalSpace - (model + calib), color: AColors.lightBlueColor),
    ];
  }

  List<ChartSeries<ChartData, String>> getStackedBarSeries() {
    return <ChartSeries<ChartData, String>>[
      StackedBar100Series<ChartData, String>(
        color: AColors.modelColorForStorage,
        dataSource: chartData != null ? chartData! : [],
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.models,
        name: 'models',
      ),
      StackedBar100Series<ChartData, String>(
        dataSource: chartData != null ? chartData! : [],
        color: AColors.blueColor,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.calibrations,
        name: 'calibration',
      ),
      StackedBar100Series<ChartData, String>(
        dataSource: chartData != null ? chartData! : [],
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.free,
        name: 'free',
      ),
    ];
  }

  showStorageDetails(bool isShow) {
    showDetails = isShow;
    emit(ShowHideDetailsState(isShow));
  }

  loadingStorage(bool isShow) {
    showDetails = isShow;
    emit(ShowHideDetailsState(isShow));
  }

  updateModelSize(Model? selectedModel) async {
    this.selectedModel = selectedModel;
    modelsFileSize = await getProjectModelsSize(selectedModel != null, selectedModel?.modelId ?? "");
    calibFileSize = await getProjectCalibrationSize(selectedModel != null, selectedModel?.modelId ?? "");
    initData(storageSpace);
    if (isDataLoading) {
      isDataLoading = false;
    }
  }

  modelSelectState(Model? model) async {
    selectedModel = model;
    emit(RefreshState());
    await updateSizeChart();
    emit(ModelSelectedState(selectedModel));
  }

  updateSizeChart() async {
    await updateModelSize(selectedModel);
  }

  refreshState() {
    emit(RefreshState());
    emit(ModelSelectedState(null));
  }

  Future<String> getProjectModelsSize(bool isModelSelected, String modelId) async {
    double modelsSize = 0.0;
    String modelsFileSize = "0";
    floorListSelected = isModelSelected && modelId.isNotEmpty ? await _modelListUseCase.fetchFloorsByModelId(modelId.plainValue()) : await _modelListUseCase.fetchAllFloors(_modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString().plainValue() : '');
    for (int i = 0; i < floorListSelected.length; i++) {
      modelsSize += double.parse(floorListSelected[i].fileSize.toString());
    }

    modelsFileSize = formatFileSize(modelsSize);
    return modelsFileSize;
  }

  Future<String> getProjectCalibrationSize(bool isModelSelected, String modelId) async {
    String calibFileSize = "0";
    var calibSize = 0.0;

    calibList = isModelSelected && modelId.isNotEmpty ? await _modelListUseCase.fetchCalibrateByModel(modelId.plainValue()) : await _modelListUseCase.fetchAllCalibrates(_modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString().plainValue() : '');
    for (int i = 0; i < calibList.length; i++) {
      calibSize += double.parse(calibList[i].sizeOf2DFile.toString());
    }
    calibFileSize = formatPdfFileSizeInMB(calibSize);

    return calibFileSize;
  }

  void onClearButton(BuildContext context, StorageDetailsCubit storageDetailsCubit, Project selectedProject) async {
    String projectId = await getIt<ModelListCubit>().getProjectId(selectedProject.projectID!, false);
    List<FloorDetail> floors = await _modelListUseCase.fetchAllFloors(
      selectedProject != null ? selectedProject.projectID.toString().plainValue() : '',
    );
    List<CalibrationDetails> calib = await _modelListUseCase.fetchAllCalibrates(selectedProject != null ? selectedProject.projectID.toString().plainValue() : '');
    if (calibList.isNotEmpty || floorListSelected.isNotEmpty) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext cont) => ModelDataRemovalDialog(
                key: Key("ModelDataRemovalDialog_widget"),
                onTapSelect: () async {
                  if (selectedModel != null) {
                    await _modelListCubit.removeCalibrateFromLocal(
                      calibList,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                      selectedModel!,
                    );
                    await _modelListCubit.removeFloorsFromLocal(
                      selectedModel!,
                      floorListSelected,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                    );
                    if (!isNetWorkConnected()) {
                      _modelListCubit.allItems.removeWhere((element) => element.bimModelId == selectedModel!.bimModelId!);
                    }
                    await ModelDbDelete.clearModel(selectedModel!);
                    selectedModel!.isDownload = false;
                    selectedModel!.fileSize = "";
                    _modelListCubit.selectedModel = null;
                    selectedModel = null;
                    List<FloorDetail> floors = await _modelListUseCase.fetchAllFloors(
                      selectedProject != null ? selectedProject.projectID.toString().plainValue() : '',
                    );
                    List<CalibrationDetails> calib = await _modelListUseCase.fetchAllCalibrates(selectedProject != null ? selectedProject.projectID.toString().plainValue() : '');

                    if (floors.isEmpty && calib.isEmpty) {
                      getIt<ProjectItemCubit>().itemDeleteRequestSuccess(projectId: selectedProject.projectID!);
                    }
                    modelSelectState(null);
                  } else {
                    await _modelListCubit.removeCalibrateFromLocal(
                      calibList,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                      selectedModel,
                    );
                    await _modelListCubit.removeFloorsFromLocal(
                      selectedModel,
                      floorListSelected,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                    );
                    await ModelDbDelete.clearProject();
                    modelsFileSize = "0";
                    calibFileSize = "0";
                    calibList.clear();
                    floorListSelected.clear();
                    if (!isNetWorkConnected()) {
                      _modelListCubit.allItems.clear();
                    }
                    modelSelectState(null);
                    getIt<ProjectItemCubit>().itemDeleteRequestSuccess(projectId: selectedProject.projectID!);
                  }
                  _modelListCubit.clearData();
                  context.shownCircleSnackBarAsBanner(context.toLocale!.successfully, context.toLocale!.model_remove_successfully, Icons.check_circle, Colors.green);
                  await _modelListCubit.pageFetch(
                    0,
                    false,
                    false,
                    "",
                    _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : '',
                    _modelListCubit.isFavorite ? 1 : 0,
                    true,
                    "aesc",
                    _modelListCubit.searchString,
                  );
                },
                floorList: floorListSelected,
                calibList: calibList,
                modelFileSize: modelsFileSize,
                calibrate: [],
                calibrateFileSize: formatPdfFileSizeInMB(double.parse(calibFileSize.split(" ")[0]) * 1024),
                removeList: [],
                caliRemoveList: [],
                removeFileSize: '',
                caliRemoveFileSize: '',
              ));
    } else if (projectId.isNotEmpty && (floors.isNotEmpty && calib.isNotEmpty)) {
      getIt<ProjectItemCubit>().itemDeleteRequestSuccess(projectId: selectedProject.projectID!);
      emit(ProjectUnmarkState());
    }
  }

  void onClickToManage(BuildContext context, {required String fileType, bool isTest = false}) {
    if (fileType == "calibrate") {
      if (calibList.isEmpty) return;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext cont) => ModelDataRemovalDialog(
                onTapSelect: () async {
                  if (selectedModel != null) {
                    await _modelListCubit.removeCalibrateFromLocal(
                      calibList,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                      selectedModel!,
                    );
                    selectedModel = null;
                    _modelListCubit.selectedModel = null;
                  } else {
                    await _modelListCubit.removeCalibrateFromLocal(
                      calibList,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                      selectedModel,
                    );
                    selectedModel = null;
                    _modelListCubit.selectedModel = null;
                  }
                  modelSelectState(null);
                  if (!isTest) context.shownCircleSnackBarAsBanner(context.toLocale!.successfully, context.toLocale!.model_remove_successfully, Icons.check_circle, Colors.green);

                  await _modelListCubit.pageFetch(
                    0,
                    false,
                    false,
                    "",
                    _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : '',
                    _modelListCubit.isFavorite ? 1 : 0,
                    true,
                    "aesc",
                    _modelListCubit.searchString,
                  );
                },
                floorList: [],
                calibList: calibList,
                modelFileSize: '',
                calibrate: [],
                calibrateFileSize: formatPdfFileSizeInMB(double.parse(calibFileSize.split(" ")[0]) * 1024),
                removeList: [],
                caliRemoveList: [],
                removeFileSize: '',
                caliRemoveFileSize: '',
              ));
    }
    if (fileType == "model") {
      if (floorListSelected.isEmpty) return;
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext cont) => ModelDataRemovalDialog(
                onTapSelect: () async {
                  if (selectedModel != null) {
                    await _modelListCubit.removeFloorsFromLocal(
                      selectedModel!,
                      floorListSelected,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                    );
                    selectedModel = null;
                    _modelListCubit.selectedModel = null;
                  } else {
                    await _modelListCubit.removeFloorsFromLocal(
                      selectedModel,
                      floorListSelected,
                      _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : "",
                    );
                    selectedModel = null;
                    _modelListCubit.selectedModel = null;
                  }
                  modelSelectState(null);

                  if (!isTest) context.shownCircleSnackBarAsBanner(context.toLocale!.successfully, context.toLocale!.model_remove_successfully, Icons.check_circle, Colors.green);

                  await _modelListCubit.pageFetch(
                    0,
                    false,
                    false,
                    "",
                    _modelListCubit.selectedProject != null ? _modelListCubit.selectedProject.projectID.toString() : '',
                    _modelListCubit.isFavorite ? 1 : 0,
                    true,
                    "aesc",
                    _modelListCubit.searchString,
                  );
                },
                floorList: floorListSelected,
                calibList: [],
                modelFileSize: modelsFileSize,
                calibrate: [],
                calibrateFileSize: "",
                removeList: [],
                caliRemoveList: [],
                removeFileSize: '',
                caliRemoveFileSize: '',
              ));
    }
  }

  void emitSizeUpdateState() {
    emit(SizeUpdateState());
  }

  void emitPaginationListInitial() {
    emit(PaginationListInitial());
  }
}

class ChartData {
  ChartData(this.x, this.models, this.calibrations, this.free);

  final String x;
  final num models;
  final num calibrations;
  final num free;
}

class StorageData {
  final String name;
  final double value;
  final Color color;

  StorageData({required this.name, required this.value, required this.color});
}
