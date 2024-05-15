

import '../../presentation/base/state_renderer/state_render_impl.dart';

class LanguageChangeState extends FlowState {

  final String? languageId;

  LanguageChangeState(this.languageId);

  @override
  List<Object> get props => [languageId!];
}