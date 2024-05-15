import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

class TaskListingState extends FlowState {
  final InternalState internalState;
  final String message;

  TaskListingState(this.internalState, {this.message = ""});

  @override
  List<Object> get props => [internalState, message];
}
