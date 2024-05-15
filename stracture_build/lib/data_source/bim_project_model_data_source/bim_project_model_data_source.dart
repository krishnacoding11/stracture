import 'package:field/data/model/bim_project_model_vo.dart';

abstract class BimProjectModelDataSource {
  Future<List<BimProjectModel>> getBimProjectModel(
      Map<String, dynamic> request);
}
