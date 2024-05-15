import 'package:equatable/equatable.dart';
import 'package:field/data/model/file_association_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'view_file_association_state.dart';

class FileAssociationCubit extends Cubit<FileAssociationState> {
  FileAssociationCubit() : super(ViewFullScreenFileAssociation(false));

  List<FileAssociation> viewFileAssociationList = [];
  bool isFullViewObjectDetails = false;

  void emitFullWidth(isFullWidth) {
    emit(ViewFullScreenFileAssociation(isFullWidth));
    isFullViewObjectDetails = isFullWidth;
  }
}
