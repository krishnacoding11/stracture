import 'package:field/data/model/sync/sync_status_data_vo.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SiteSyncStatusDataVo', () {
    test('fromJson should correctly parse JSON data', () {
      final jsonData = {
        'ProjectId': 'project_123',
        'LocationId': 'loc_1',
        'FormId': 'form_1',
        'SyncStatus': 2,
        'SyncProgress': 0.75,
      };

      final siteSyncStatusData = SiteSyncStatusDataVo.fromJson(jsonData);

      expect(siteSyncStatusData.projectId, 'project_123');
      expect(siteSyncStatusData.locationId, 'loc_1');
      expect(siteSyncStatusData.eSyncStatus, ESyncStatus.inProgress);
      expect(siteSyncStatusData.syncProgress, 0.75);
    });

    test('toJson should correctly convert to JSON data', () {
      final siteSyncStatusData = SiteSyncStatusDataVo();
      siteSyncStatusData.projectId = 'project_456';
      siteSyncStatusData.locationId = 'loc_2';
      siteSyncStatusData.eSyncStatus = ESyncStatus.inProgress;
      siteSyncStatusData.syncProgress = 0.5;

      final jsonData = siteSyncStatusData.toJson();
      final expectedJson = {
        'ProjectId': 'project_456',
        'LocationId': 'loc_2',
        'FormId': 'form_2',
        'SyncStatus': ESyncStatus.inProgress.value,
        'SyncProgress': 0.5,
      };

      expect(jsonData, expectedJson);
    });

    test('toList should correctly convert list of JSON data', () {
      final jsonList = [
        {
          'ProjectId': 'project_123',
          'LocationId': 'loc_1',
          'FormId': 'form_1',
          'SyncStatus': 2,
          'SyncProgress': 0.75,
        },
        {
          'ProjectId': 'project_456',
          'LocationId': 'loc_2',
          'FormId': 'form_2',
          'SyncStatus': 1,
          'SyncProgress': 0.5,
        },
      ];

      final siteSyncStatusList = SiteSyncStatusDataVo().toList(jsonList);

      expect(siteSyncStatusList, isA<List<SiteSyncStatusDataVo>>());
      expect(siteSyncStatusList.length, 2);

      expect(siteSyncStatusList[0].projectId, 'project_123');
      expect(siteSyncStatusList[0].locationId, 'loc_1');
      expect(siteSyncStatusList[0].eSyncStatus, ESyncStatus.inProgress);
      expect(siteSyncStatusList[0].syncProgress, 0.75);

      expect(siteSyncStatusList[1].projectId, 'project_456');
      expect(siteSyncStatusList[1].locationId, 'loc_2');
      expect(siteSyncStatusList[1].eSyncStatus, ESyncStatus.success);
      expect(siteSyncStatusList[1].syncProgress, 0.5);
    });

    ////////
  });
}
