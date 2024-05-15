import 'package:flutter_bloc/flutter_bloc.dart';

class UniqueValueCubit extends Cubit<String> {
  UniqueValueCubit() : super(DateTime.now().millisecondsSinceEpoch.toString());

  updateValue() {
    if(!isClosed){
      emit(DateTime.now().millisecondsSinceEpoch.toString());
    }
  }
}