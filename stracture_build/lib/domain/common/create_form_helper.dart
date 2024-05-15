import '../../bloc/site/create_form_selection_cubit.dart';
import '../../data/model/project_vo.dart';
import '../../injection_container.dart';
import '../../utils/store_preference.dart';

class CreateFormHelper {
  Future<CreateFormSelectionCubit> onPostApiCall(bool isFromMap,String appTypeId) async {
    Project? project = await StorePreference.getSelectedProjectData();
    CreateFormSelectionCubit createFormSelectionCubit = getIt<CreateFormSelectionCubit>();
    createFormSelectionCubit.getAppList(project?.projectID ?? "",isFromMap,appTypeId);

    return createFormSelectionCubit;
  }
}