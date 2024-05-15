import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/image_annotation/image_annotation.dart';

import 'annotation_state.dart';

class AnnotationSelectionCubit extends BaseCubit {
  bool _isSelected = false;

  AnnotationSelectionCubit() : super(AnnotationSelectionState(false,null));

  showSelectedAnnotation(AnnotationOptions selectedAnnotation) {
    _isSelected = !_isSelected;
    emitState(AnnotationSelectionState(_isSelected,selectedAnnotation));
  }
}