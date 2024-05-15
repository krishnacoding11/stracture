import '../../presentation/base/state_renderer/state_render_impl.dart';

class FormTypeExpandedState extends FlowState {
  final String time = DateTime.now().millisecondsSinceEpoch.toString();
  final bool isFormTypeExpanded;

  FormTypeExpandedState(this.isFormTypeExpanded);

  @override
  List<Object?> get props => [isFormTypeExpanded,time];
}

class FormTypeSearchClearState extends FlowState {
  FormTypeSearchClearState();

  @override
  List<Object?> get props => [];
}

class NormalState extends FlowState {
  NormalState();

  @override
  List<Object?> get props => [];
}