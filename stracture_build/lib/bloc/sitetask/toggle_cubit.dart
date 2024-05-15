import 'package:flutter_bloc/flutter_bloc.dart';

class ToggleCubit extends Cubit<bool> {
  ToggleCubit() : super(false);

  toggleChange(bool isShow) {
    if(!isClosed){
      emit(isShow);
    }
  }
}