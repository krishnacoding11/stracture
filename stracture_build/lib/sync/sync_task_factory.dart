import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/sync/task/column_header_list_sync_task.dart';
import 'package:field/sync/task/filter_sync_task.dart';
import 'package:field/sync/task/form_list_sync_task.dart';
import 'package:field/sync/task/form_message_batch_list_sync_task.dart';
import 'package:field/sync/task/formtype_list_sync_task.dart';
import 'package:field/sync/task/location_plan_sync_task.dart';
import 'package:field/sync/task/manage_homepage_configuration_task.dart';
import 'package:field/sync/task/manage_type_list_sync_task.dart';
import 'package:field/sync/task/project_and_location_sync_task.dart';
import 'package:field/sync/task/push_to_server_form_distribution_action_task.dart';
import 'package:field/sync/task/push_to_server_form_other_action_task.dart';
import 'package:field/sync/task/push_to_server_form_status_change_task.dart';
import 'package:field/sync/task/push_to_server_form_sync_task.dart';
import 'package:field/sync/task/status_style_list_sync_task.dart';

class SyncTaskFactory {

  PushToServerFormSyncTask getFormSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return PushToServerFormSyncTask(syncRequestTask, syncCallback);
  }

  PushToServerFormStatusChangeTask getForStatusChangeSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return PushToServerFormStatusChangeTask(syncRequestTask, syncCallback);
  }

  PushToServerFormDistributionActionTask getFormDistributeActionSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return PushToServerFormDistributionActionTask(syncRequestTask, syncCallback);
  }

  PushToServerFormOherActionTask getFormOtherActionSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return PushToServerFormOherActionTask(syncRequestTask, syncCallback);
  }

  ProjectAndLocationSyncTask getProjectAndLocationSyncTask(SiteSyncRequestTask siteSyncRequestTask, SyncCallback syncCallback) {
    return ProjectAndLocationSyncTask(siteSyncRequestTask, syncCallback);
  }

  ColumnHeaderListSyncTask getColumnHeaderListSyncTask(SiteSyncRequestTask siteSyncRequestTask, SyncCallback syncCallback) {
    return ColumnHeaderListSyncTask(siteSyncRequestTask, syncCallback);
  }

  FormListSyncTask getFormListSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return FormListSyncTask(syncRequestTask, syncCallback);
  }

  FormTypeListSyncTask getFormTypeListSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return FormTypeListSyncTask(syncRequestTask, syncCallback);
  }

  FormMessageBatchListSyncTask getFormMessageBatchListSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return FormMessageBatchListSyncTask(syncRequestTask, syncCallback);
  }

  FilterSyncTask getFilterSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return FilterSyncTask(syncRequestTask, syncCallback);
  }

  LocationPlanSyncTask getLocationPlanSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return LocationPlanSyncTask(syncRequestTask, syncCallback);
  }

  StatusStyleListSyncTask getStatusStyleListSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return StatusStyleListSyncTask(syncRequestTask, syncCallback);
  }

  ManageTypeListSyncTask getManageTypeListSyncTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return ManageTypeListSyncTask(syncRequestTask, syncCallback);
  }

  ManageHomePageConfigurationTask getManageHomePageConfigurationTask(SyncRequestTask syncRequestTask, SyncCallback syncCallback) {
    return ManageHomePageConfigurationTask(syncRequestTask, syncCallback);
  }
}
