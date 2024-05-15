import 'dart:async';
import 'dart:isolate';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/data/model/sync_status.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:field/sync/executors/site_sync_executor.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/sync_task_factory.dart';
import 'package:field/sync/task/column_header_list_sync_task.dart';
import 'package:field/sync/task/filter_sync_task.dart';
import 'package:field/sync/task/form_list_sync_task.dart';
import 'package:field/sync/task/form_message_batch_list_sync_task.dart';
import 'package:field/sync/task/formtype_list_sync_task.dart';
import 'package:field/sync/task/location_plan_sync_task.dart';
import 'package:field/sync/task/manage_type_list_sync_task.dart';
import 'package:field/sync/task/project_and_location_sync_task.dart';
import 'package:field/sync/task/status_style_list_sync_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class SyncTaskFactoryMock extends Mock implements SyncTaskFactory {}

class DBServiceMock extends Mock implements DBService {}

class ProjectAndLocationSyncTaskMock extends Mock implements ProjectAndLocationSyncTask {}

class FormListSyncTaskMock extends Mock implements FormListSyncTask {}

class FormTypeListSyncTaskMock extends Mock implements FormTypeListSyncTask {}

class LocationPlanSyncTaskMock extends Mock implements LocationPlanSyncTask {}

class ManageTypeListSyncTaskMock extends Mock implements ManageTypeListSyncTask {}

class StatusStyleListSyncTaskMock extends Mock implements StatusStyleListSyncTask {}

class FormMessageBatchListSyncTaskMock extends Mock implements FormMessageBatchListSyncTask {}

class FilterSyncTaskMock extends Mock implements FilterSyncTask {}

class ColumnHeaderListSyncTaskMock extends Mock implements ColumnHeaderListSyncTask {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  DBServiceMock mockDb = DBServiceMock();
  SyncTaskFactoryMock mockFactory = SyncTaskFactoryMock();
  ProjectAndLocationSyncTaskMock projectAndLocationSyncTaskMock = ProjectAndLocationSyncTaskMock();
  FormListSyncTaskMock formListSyncTaskMock = FormListSyncTaskMock();
  FormTypeListSyncTaskMock formTypeListSyncTaskMock = FormTypeListSyncTaskMock();
  LocationPlanSyncTaskMock locationPlanSyncTaskMock = LocationPlanSyncTaskMock();
  ManageTypeListSyncTaskMock manageTypeListSyncTaskMock = ManageTypeListSyncTaskMock();
  StatusStyleListSyncTaskMock statusStyleListSyncTaskMock = StatusStyleListSyncTaskMock();
  FormMessageBatchListSyncTaskMock formMessageBatchListSyncTaskMock = FormMessageBatchListSyncTaskMock();
  FilterSyncTaskMock filterSyncTaskMock = FilterSyncTaskMock();
  ColumnHeaderListSyncTaskMock columnHeaderListSyncTaskMock = ColumnHeaderListSyncTaskMock();
  configureDependencies() {
    di.getIt.unregister<SyncTaskFactory>();
    di.getIt.unregister<DBService>();
    di.getIt.unregister<ProjectListUseCase>();
    di.getIt.registerLazySingleton<SyncTaskFactory>(() => mockFactory);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);
  }

  tearDown(() {
    reset(mockFactory);
    reset(mockDb);
  });

  setUpAll(() {
    configureDependencies();
  });

  tearDownAll(() {});

  group("SiteSyncExecutor Test", () {
    test('Test execute method', () async {
      final c = new Completer();
      final receivePort = ReceivePort();
      SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2089700\$\$i4Izt6"
        ..projectName = "Test"
        ..isMarkOffline = true
        ..isMediaSyncEnable = false
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "1024";
      SiteSyncExecutor siteSyncExecutor = SiteSyncExecutor(syncRequestTask);
      TaskPool taskPool =  TaskPool(3);

      when(() => mockFactory.getProjectAndLocationSyncTask(syncRequestTask, any())).thenReturn(projectAndLocationSyncTaskMock);
      when(() => mockFactory.getFilterSyncTask(syncRequestTask, any())).thenReturn(filterSyncTaskMock);
      when(() => mockFactory.getFormListSyncTask(syncRequestTask, any())).thenReturn(formListSyncTaskMock);
      when(() => mockFactory.getLocationPlanSyncTask(syncRequestTask, any())).thenReturn(locationPlanSyncTaskMock);
      when(() => mockFactory.getFormTypeListSyncTask(syncRequestTask, any())).thenReturn(formTypeListSyncTaskMock);
      when(() => mockFactory.getFormMessageBatchListSyncTask(syncRequestTask, any())).thenReturn(formMessageBatchListSyncTaskMock);
      when(() => mockFactory.getManageTypeListSyncTask(syncRequestTask, any())).thenReturn(manageTypeListSyncTaskMock);
      when(() => mockFactory.getStatusStyleListSyncTask(syncRequestTask, any())).thenReturn(statusStyleListSyncTaskMock);
      when(() => mockFactory.getColumnHeaderListSyncTask(syncRequestTask, any())).thenReturn(columnHeaderListSyncTaskMock);
      when(() => columnHeaderListSyncTaskMock.syncColumnHeaderListData(any())).thenAnswer((_) => Future.delayed(Duration(milliseconds: 400)));
      when(() => projectAndLocationSyncTaskMock.syncProjectAndLocationData(any())).thenAnswer((_) {
        siteSyncExecutor.syncCallback(ESyncTaskType.projectAndLocationSyncTask, ESyncStatus.success, {"projectList": [], "siteLocationList": []});
        Project p = Project();
        p.projectID = syncRequestTask.projectId;
        //  projectAndLocationSyncTaskMock.passDataToSyncCallback(ESyncTaskType.projectAndLocationSyncTask, ESyncStatus.success, {"projectList": [], "siteLocationList": []});
        return Future.value(SyncSuccessProjectLocationState([p], []));
      });
      when(() => locationPlanSyncTaskMock.downloadPlanFile(any(), any())).thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));
      when(() => statusStyleListSyncTaskMock.syncStatusStyleData(any())).thenReturn({});
      when(() => manageTypeListSyncTaskMock.syncManageTypeListData(any())).thenReturn({});
      when(() => formListSyncTaskMock.syncFormListData(any(), any(), any())).thenAnswer((_) => Future.value(SyncSuccessFormListState([])));
      when(() => formTypeListSyncTaskMock.getFormTypeList(projectId: any(named: "projectId"), formTypeIds: any(named: "formTypeIds"), formsFormTypeIds: (any(named: "formsFormTypeIds")))).thenAnswer((_) => Future.value(SyncStatus.formTypeList([])));
      when(() => formMessageBatchListSyncTaskMock.syncFormMessageBatchListData(any(), any())).thenAnswer((_) => Future.value(SyncSuccessBatchMessageListState()));
      when(() => filterSyncTaskMock.getAttributeList(projectId: any(named: "projectId"), appTypeId: any(named: "appTypeId"))).thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));

      when(() => mockDb.selectFromTable("SyncProjectTbl", "SELECT ProjectId,SyncStatus,SyncProgress FROM SyncProjectTbl\nWHERE ProjectId=2089700")).thenReturn(ResultSet(
          ["ProjectId", "LocationId", "FormId", "SyncStatus", "SyncProgress"],
          null,
          [
            ["2089700", "", "", 1, 100],
          ]));

      siteSyncExecutor.execute((eSyncType, eSyncStatus, data) {
        if (eSyncStatus == ESyncStatus.success) {
          c.complete();
        }
      }, receivePort.sendPort);

      await c.future;
      expect(taskPool.pendingTaskSize, 0);
      verify(() => mockFactory.getProjectAndLocationSyncTask(syncRequestTask, any())).called(1);
    });
    test('Test execute method with SyncError', () async {
      final c = new Completer();
      final receivePort = ReceivePort();
      SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2089700\$\$i4Izt6"
        ..projectName = "Test"
        ..isMarkOffline = true
        ..isMediaSyncEnable = false
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "1024";
      SiteSyncExecutor siteSyncExecutor = SiteSyncExecutor(syncRequestTask);
      TaskPool taskPool = TaskPool(3);

      when(() => mockFactory.getProjectAndLocationSyncTask(syncRequestTask, any())).thenReturn(projectAndLocationSyncTaskMock);
      when(() => mockFactory.getFilterSyncTask(syncRequestTask, any())).thenReturn(filterSyncTaskMock);
      when(() => mockFactory.getFormListSyncTask(syncRequestTask, any())).thenReturn(formListSyncTaskMock);
      when(() => mockFactory.getLocationPlanSyncTask(syncRequestTask, any())).thenReturn(locationPlanSyncTaskMock);
      when(() => mockFactory.getFormTypeListSyncTask(syncRequestTask, any())).thenReturn(formTypeListSyncTaskMock);
      when(() => mockFactory.getFormMessageBatchListSyncTask(syncRequestTask, any())).thenReturn(formMessageBatchListSyncTaskMock);
      when(() => mockFactory.getManageTypeListSyncTask(syncRequestTask, any())).thenReturn(manageTypeListSyncTaskMock);
      when(() => mockFactory.getStatusStyleListSyncTask(syncRequestTask, any())).thenReturn(statusStyleListSyncTaskMock);
      when(() => mockFactory.getColumnHeaderListSyncTask(syncRequestTask, any())).thenReturn(columnHeaderListSyncTaskMock);
      when(() => columnHeaderListSyncTaskMock.syncColumnHeaderListData(any())).thenAnswer((_) => Future.delayed(Duration(milliseconds: 400)));
      when(() => projectAndLocationSyncTaskMock.syncProjectAndLocationData(any())).thenAnswer((_) => Future.value(SyncErrorState("", "")));

      when(() => mockDb.selectFromTable("SyncProjectTbl", "SELECT ProjectId,SyncStatus,SyncProgress FROM SyncProjectTbl\nWHERE ProjectId=2089700")).thenReturn(ResultSet(
          ["ProjectId", "LocationId", "FormId", "SyncStatus", "SyncProgress"],
          null,
          [
            ["2089700", "", "", 1, 100],
          ]));

      siteSyncExecutor.execute((eSyncType, eSyncStatus, data) {
        if (eSyncStatus == ESyncStatus.success) {
          c.complete();
        }
      }, receivePort.sendPort);

      await c.future;
      expect(taskPool.pendingTaskSize, 0);
      verify(() => mockFactory.getProjectAndLocationSyncTask(syncRequestTask, any())).called(1);
    });
    test('Test execute method with Exception', () async {
      final c = new Completer();
      final receivePort = ReceivePort();
      SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2089700\$\$i4Izt6"
        ..projectName = "Test"
        ..isMarkOffline = true
        ..isMediaSyncEnable = false
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "1024";
      SiteSyncExecutor siteSyncExecutor = SiteSyncExecutor(syncRequestTask);

      when(() => mockFactory.getProjectAndLocationSyncTask(syncRequestTask, any())).thenReturn(projectAndLocationSyncTaskMock);
      when(() => mockFactory.getFilterSyncTask(syncRequestTask, any())).thenReturn(filterSyncTaskMock);
      when(() => mockFactory.getFormListSyncTask(syncRequestTask, any())).thenReturn(formListSyncTaskMock);
      when(() => mockFactory.getLocationPlanSyncTask(syncRequestTask, any())).thenReturn(locationPlanSyncTaskMock);
      when(() => mockFactory.getFormTypeListSyncTask(syncRequestTask, any())).thenReturn(formTypeListSyncTaskMock);
      when(() => mockFactory.getFormMessageBatchListSyncTask(syncRequestTask, any())).thenReturn(formMessageBatchListSyncTaskMock);
      when(() => mockFactory.getManageTypeListSyncTask(syncRequestTask, any())).thenReturn(manageTypeListSyncTaskMock);
      when(() => mockFactory.getStatusStyleListSyncTask(syncRequestTask, any())).thenReturn(statusStyleListSyncTaskMock);
      when(() => mockFactory.getColumnHeaderListSyncTask(syncRequestTask, any())).thenReturn(columnHeaderListSyncTaskMock);
      when(() => columnHeaderListSyncTaskMock.syncColumnHeaderListData(any())).thenAnswer((_) => Future.delayed(Duration(milliseconds: 400)));
      when(() => projectAndLocationSyncTaskMock.syncProjectAndLocationData(any())).thenAnswer((_) {
        siteSyncExecutor.syncCallback(ESyncTaskType.projectAndLocationSyncTask, ESyncStatus.success, {"projectList": [], "siteLocationList": []});
        return Future.value(SyncSuccessProjectLocationState([Project()], []));
      });
      when(() => locationPlanSyncTaskMock.downloadPlanFile(any(), any())).thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));
      when(() => statusStyleListSyncTaskMock.syncStatusStyleData(any())).thenReturn({});
      when(() => manageTypeListSyncTaskMock.syncManageTypeListData(any())).thenReturn({});
      when(() => formListSyncTaskMock.syncFormListData(any(), any(), any())).thenAnswer((_) => Future.value(SyncSuccessFormListState([])));
      when(() => formTypeListSyncTaskMock.getFormTypeList(projectId: any(named: "projectId"), formTypeIds: any(named: "formTypeIds"), formsFormTypeIds: (any(named: "formsFormTypeIds")))).thenAnswer((_) => Future.value(SyncStatus.formTypeList([])));
      when(() => formMessageBatchListSyncTaskMock.syncFormMessageBatchListData(any(), any())).thenAnswer((_) => Future.value(SyncSuccessBatchMessageListState()));
      when(() => filterSyncTaskMock.getAttributeList(projectId: any(named: "projectId"), appTypeId: any(named: "appTypeId"))).thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));

      when(() => mockDb.selectFromTable("SyncProjectTbl", "SELECT ProjectId,SyncStatus,SyncProgress FROM SyncProjectTbl\nWHERE ProjectId=2089700")).thenReturn(ResultSet(
          ["ProjectId", "LocationId", "FormId", "SyncStatus", "SyncProgress"],
          null,
          [
            ["2089700", "", "", 1, 100],
          ]));

      try {
        siteSyncExecutor.execute((eSyncType, eSyncStatus, data) {
          if (eSyncStatus == ESyncStatus.success) {
            c.complete();
          }
        }, receivePort.sendPort);
      } catch (e) {
        expect(e, TypeMatcher<Exception>());
        c.completeError(e);
      }
      await c.future;
      verify(() => mockFactory.getProjectAndLocationSyncTask(syncRequestTask, any())).called(1);
    });
  });
}
