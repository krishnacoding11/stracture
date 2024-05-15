import 'package:equatable/equatable.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/view_object_details_model.dart';

part 'view_object_details_state.dart';

class ViewObjectDetailsCubit extends Cubit<ViewObjectDetailsState> {
  ViewObjectDetailsCubit() : super(PaginationListInitial());

  List<Detail> viewObjectDetailsModelList = [];
  bool isFullViewObjectDetails = false;

  late Map<String, String> headersMap;

  initUser() async {
    User? user = await StorePreference.getUserData();
    if (user != null) {
      headersMap = {'Cookie': 'ASessionID=${user.usersessionprofile!.aSessionId};JSessionID=${user.usersessionprofile!.currentJSessionID}'};
    }
  }

  void emitFullWidth(isFullWidth) {
    emit(ViewFullScreenObjectDetails(isFullWidth));
    isFullViewObjectDetails = isFullWidth;
  }

  void normalState() {
    emit(NormalHandleState());
  }

  void isExpandedState(isExpanded) {
    emit(ExpandedDropdownState(isExpanded));
  }
}
