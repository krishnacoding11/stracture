import 'package:field/data/model/sync/sync_status_result.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncStatusResult', () {
    test('fromJson should correctly parse JSON data', () {
      final jsonData = {
        'syncType': 1,
        'syncStatus': 2,
        'data': 'example data',
      };

      final syncStatusResult = SyncStatusResult.fromJson(jsonData);

      expect(syncStatusResult.eSyncType, ESyncType.project);
      expect(syncStatusResult.eSyncStatus, ESyncStatus.inProgress);
      expect(syncStatusResult.data, 'example data');
    });

    test('toJson should correctly convert to JSON data', () {
      final syncStatusResult = SyncStatusResult();
      syncStatusResult.eSyncType = ESyncType.pushToServer;
      syncStatusResult.eSyncStatus = ESyncStatus.inProgress;
      syncStatusResult.data = 'test data';

      final jsonData = syncStatusResult.toJson();
      final expectedJson = {
        'syncType': 0,
        'syncStatus': ESyncStatus.inProgress.value,
        'data': 'test data',
      };

      expect(jsonData, expectedJson);
    });
  });
}
