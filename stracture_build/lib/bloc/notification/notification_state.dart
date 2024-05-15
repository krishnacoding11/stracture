import 'package:field/data/model/notification_detail_vo.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import '../../exception/app_exception.dart';

abstract class NotificationState extends FlowState{}

class NotificationLoading extends NotificationState {}

class GetTaskDetailSuccessState extends NotificationState {
  late final List<String> recentList;

  GetTaskDetailSuccessState({required this.recentList});

  @override
  List<Object?> get props => [recentList];
}

class GetTaskDetailErrorState extends NotificationState {
  late final AppException exception;

  GetTaskDetailErrorState({required this.exception});

  @override
  List<Object?> get props => [exception];
}

class NotificationDetailSuccessState extends NotificationState {
  // late final SiteForm siteForm;
  // late final Map<String,dynamic> data;
  //
  // NotificationDetailSuccessState({required this.siteForm,required this.data});

  late final NotificationDetailVo notificationDetailVo;
  late final Map<String,dynamic> data;
  int entityType;
  NotificationDetailSuccessState({required this.notificationDetailVo,required this.data, required this.entityType});
  @override
 // List<Object?> get props => [siteForm,data];
  List<Object?> get props => [notificationDetailVo,data];
}

class NotificationErrorState extends NotificationState {
  // final AppException exception;
  //
  // NotificationErrorState({required this.exception});
  //
  // @override
  // List<Object?> get props => [exception];

  final String message;
  NotificationErrorState(this.message);

  @override
  String getMessage() => message;

  @override
  List<Object?> get props => [message];
}
