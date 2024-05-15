import 'package:equatable/equatable.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/bim_request_data.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/bim_model_list_use_cases/bim_project_model_use_case.dart';
import '../../utils/actionIdConstants.dart';

part 'bim_project_model_state.dart';

class BimProjectModelListCubit extends Cubit<BimProjectModelListState> {
  BimProjectModelListCubit() : super(PaginationListInitial());
  final BimProjectModelListUseCase _modelListUseCase =
      di.getIt<BimProjectModelListUseCase>();
  List<BimProjectModel> tempList = [];
  List<String> fileSize = [];

  Future<List<BimProjectModel>> getBimProjectModel(
      {BimProjectModelRequestModel? project}) async {
    emit(LoadingState());
    Map<String, dynamic> map = {};
    map["projectId"] = project?.projectId;
    map["action_id"] = ActionConstants.actionId714;
    map["model_id"] = project?.modelId;
    map["modelVersionID"] = '-1';
    try {
      fileSize = [];
      var result = await _modelListUseCase.getBimProjectModelList(map);
      tempList = result;
      emit(LoadedState());
      return result;
    } on AppException catch (e) {
      emit(ErrorState(exception: AppException(message: e.message)));
      return Future.value([]);
    }
  }

}
