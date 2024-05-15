import 'package:field/data/model/bim_project_model_vo.dart';

import '../../../data/repository/bim_project_model_repository_impl.dart';

class BimProjectModelListUseCase {
  final BimProjectModelRepositoryImpl _modelListRepositoryImpl =
      BimProjectModelRepositoryImpl();

  Future<List<BimProjectModel>> getBimProjectModelList(Map<String, dynamic> request) async {
    return await _modelListRepositoryImpl.getBimProjectModelList(request);
  }
}
