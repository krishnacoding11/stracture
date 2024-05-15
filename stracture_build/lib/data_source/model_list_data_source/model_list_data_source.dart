import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/project_vo.dart';

import '../../data/model/bim_project_model_vo.dart';
import '../../data/model/calibrated.dart';
import '../../data/model/model_vo.dart';

abstract class ModelListDataSource {
  Future<List<FloorData>> getFloorList(Map<String, dynamic> request);

  Future<List<Model>> fetchModeList(Map<String, dynamic> request, String projectId);

  Future<String> getProjectFromProjectDetailsTable(String projectId, bool isSetOffline);
  Future updateProject(Project project);

  Future<String> getProjectNameProjectDetailsTable(String projectId, bool isSetOffline);

  Future<dynamic> setParallelViewAuditTrail(Map<String, dynamic> request, String projectId);

  Future<List<Model>> getFilteredModelList(Map<String, dynamic> request, String projectId, String searchValue);

  Future<dynamic> syncWithDB(
    List<FloorDetail> floodDBList,
    List<CalibrationDetails> calibrationList,
    ModelListCubit modelListCubit,
    List<String> downloadedScsFiles,
    List<FloorDetail> downloadedFiles,
    List<BimModel> groupBimList,
    BimModel selectedBimModelData,
    double floorSize,
  );

  Future<dynamic> getDownloadedModelsPath(String projectId, String modelId, String revisionId, List<String> downloadedScsFiles);
  Future<dynamic> getDownloadedPdfFile(String projectId, List<String> downloadedScsFiles);

  Future<List<FloorDetail>> fetchRevisionId(String revId);
  Future<double> floorSizeByModelId(String plainModelId);
  Future<List<FloorDetail>> fetchFloorsByModelId(String modelId);
  Future<List<FloorDetail>> fetchAllFloors(String projectId);
  Future<List<CalibrationDetails>> fetchAllCalibrates(String projectId);
  Future<List<CalibrationDetails>> fetchCalibrateByModel(String modelId);


}
