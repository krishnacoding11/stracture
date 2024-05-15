import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/model/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncStatus', () {
    test('SyncStatus factory constructor should create SyncSuccessState instance', () {
      final result = 'Success Result';
      final syncStatus = SyncStatus.success(result);

      expect(syncStatus, isA<SyncSuccessState>());
      expect((syncStatus as SyncSuccessState).value, result);
    });

    test('SyncStatus factory constructor should create SyncSuccessProjectLocationState instance', () {
      final projectList = [Project(), Project()];
      final siteLocationList = [SiteLocation(), SiteLocation()];
      final syncStatus = SyncStatus.projectLocation(projectList, siteLocationList);

      expect(syncStatus, isA<SyncSuccessProjectLocationState>());
      expect((syncStatus as SyncSuccessProjectLocationState).projectList, projectList);
      expect((syncStatus).siteLocationList, siteLocationList);
    });

    test('SyncStatus factory constructor should create SyncSuccessFormTypeListState instance', () {
      final appTypeList = [AppType(), AppType()];
      final formTypeIds = 'form_type_ids';
      final syncStatus = SyncStatus.formTypeList(appTypeList, formTypeIds: formTypeIds);

      expect(syncStatus, isA<SyncSuccessFormTypeListState>());
      expect((syncStatus as SyncSuccessFormTypeListState).appTypeList, appTypeList);
      expect((syncStatus).formTypeIds, formTypeIds);
    });

    test('SyncStatus factory constructor should create SyncErrorState instance', () {
      final className = 'Class';
      final errorMsg = 'Error Message';
      final syncStatus = SyncStatus.error(className, errorMsg);

      expect(syncStatus, isA<SyncErrorState>());
      expect((syncStatus as SyncErrorState).className, className);
      expect((syncStatus).msg, errorMsg);
    });
  });

  group('SyncErrorState', () {
    test('SyncErrorState should extend SyncStatus', () {
      final className = 'Class';
      final errorMsg = 'Error Message';
      final syncErrorState = SyncErrorState(className, errorMsg);

      expect(syncErrorState, isA<SyncStatus>());
      expect(syncErrorState.className, className);
      expect(syncErrorState.msg, errorMsg);
    });
  });

  group('SyncSuccessState', () {
    test('SyncSuccessState should extend SyncStatus', () {
      final result = 'Success Result';
      final syncSuccessState = SyncSuccessState(result);

      expect(syncSuccessState, isA<SyncStatus>());
      expect(syncSuccessState.value, result);
    });
  });

  group('SyncSuccessProjectLocationState', () {
    test('SyncSuccessProjectLocationState should extend SyncStatus', () {
      final projectList = [Project(), Project()];
      final siteLocationList = [SiteLocation(), SiteLocation()];
      final syncSuccessProjectLocationState = SyncSuccessProjectLocationState(projectList, siteLocationList);

      expect(syncSuccessProjectLocationState, isA<SyncStatus>());
      expect(syncSuccessProjectLocationState.projectList, projectList);
      expect(syncSuccessProjectLocationState.siteLocationList, siteLocationList);
    });
  });

  group('SyncSuccessFormListState', () {
    test('SyncSuccessFormListState should extend SyncStatus', () {
      final formList = [SiteForm(), SiteForm()];
      final syncSuccessFormListState = SyncSuccessFormListState(formList);

      expect(syncSuccessFormListState, isA<SyncStatus>());
      expect(syncSuccessFormListState.formList, formList);
    });
  });

  group('SyncSuccessFormTypeListState', () {
    test('SyncSuccessFormTypeListState should extend SyncStatus', () {
      final appTypeList = [AppType(), AppType()];
      final formTypeIds = 'form_type_ids';
      final syncSuccessFormTypeListState = SyncSuccessFormTypeListState(appTypeList, formTypeIds: formTypeIds);

      expect(syncSuccessFormTypeListState, isA<SyncStatus>());
      expect(syncSuccessFormTypeListState.appTypeList, appTypeList);
      expect(syncSuccessFormTypeListState.formTypeIds, formTypeIds);
    });
  });

  group('SyncSuccessBatchMessageListState', () {
    test('SyncSuccessBatchMessageListState should extend SyncStatus', () {
      final syncSuccessBatchMessageListState = SyncSuccessBatchMessageListState();

      expect(syncSuccessBatchMessageListState, isA<SyncStatus>());
    });
  });
}
