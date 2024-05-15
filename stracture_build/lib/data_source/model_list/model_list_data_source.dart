import 'package:field/data/model/model_vo.dart';

abstract class ModelListDataSource {
  Future<List<Model>> getModelList(Map<String, dynamic> request);
  Future<List<Model>> getWorkspaceList(Map<String, dynamic> request);
  Future<dynamic> setFavModel(Map<String, dynamic> request);
  Future<List<Model>> getPopupDataList(Map<String, dynamic> request);
}
