import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';

import '../../data_source/bim_project_model_data_source/bim_project_model_data_source.dart';
import '../../data_source/bim_project_model_data_source/bim_project_model_local_data_source_impl.dart';
import '../../data_source/bim_project_model_data_source/bim_project_model_remote_data_source_impl.dart';
import '../remote/bim_model_list/bim_project_model_repository.dart';

class BimProjectModelRepositoryImpl extends BimProjectModelListRepository {
  BimProjectModelDataSource? _projectDataSource;

  Future<BimProjectModelDataSource?> getInstance() async {
    if (isNetWorkConnected()) {
      _projectDataSource = getIt<BimProjectModelListRemoteDataSourceImpl>();
      return _projectDataSource;
    } else {
      _projectDataSource = getIt<BimProjectModelListLocalDataSourceImpl>();
      return _projectDataSource;
    }
  }

  @override
  Future<List<BimProjectModel>> getBimProjectModelList(
      Map<String, dynamic> request) async {
    await getInstance();
    return await _projectDataSource!.getBimProjectModel(request);
  }
}
