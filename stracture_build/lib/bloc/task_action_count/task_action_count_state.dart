import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import '../../data/model/taskactioncount_vo.dart';

class TaskActionCountState extends FlowState {
  final InternalState internalState;
  final String message;
  final TaskActionCountVo taskActionCount;

  TaskActionCountState(this.internalState,{required this.taskActionCount,this.message = ""});

  @override
  List<Object> get props => [internalState,taskActionCount, message,DateTime.now().millisecondsSinceEpoch.toString()];
}