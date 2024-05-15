import 'package:field/injection_container.dart' as di;

import '../../../bloc/project_list/project_list_cubit.dart';
import '../../../data/remote/notification/notification_repository_impl.dart';
import '../../../networking/network_response.dart';

class NotificationUseCase{
  final NotificationRemoteRepository _notificationRemoteRepository = di.getIt<NotificationRemoteRepository>();
  final ProjectListCubit _cubit = di.getIt<ProjectListCubit>();

  // Future<Result?> getNotificationFromServer(requestMap) async {
  //   return await _notificationRemoteRepository.getNotificationList(requestMap);
  // }

  Future<Result?> sendTaskDetailRequest(requestMap) async {
    return await _notificationRemoteRepository.sendTaskDetailRequest(requestMap);
  }
}