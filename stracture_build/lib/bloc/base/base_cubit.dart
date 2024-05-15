import 'package:field/data/model/project_vo.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/base/state_renderer/state_render_impl.dart';


class BaseCubit extends Cubit<FlowState> {
  BaseCubit(FlowState initialState) : super(initialState);

  Future<bool> checkIfProjectSelected() async{
    Project? project = await StorePreference.getSelectedProjectData();
    if(project==null){
      emitState(NoProjectSelectedState());
      return false;
    }
    return true;
  }

  emitState(FlowState state) {
    emitStateWithDuration(state, Duration.zero);
  }

  emitStateWithDuration(FlowState state,Duration duration) {
    if(!isClosed){
      emit(state);
      // Future.delayed(duration).then((value) => emit(state));
    }
  }

}
