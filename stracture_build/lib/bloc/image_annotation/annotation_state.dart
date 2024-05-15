import 'package:field/image_annotation/image_annotation.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

class AnnotationSelectionState extends FlowState {
  final bool isSelected;
  final AnnotationOptions? selectedAnnotation;

  AnnotationSelectionState(this.isSelected,this.selectedAnnotation);

  @override
  List<Object?> get props => [isSelected,selectedAnnotation];
}