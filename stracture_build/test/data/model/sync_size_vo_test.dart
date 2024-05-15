import 'package:field/data/model/download_size_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DownloadSizeVo? downloadSizeVo;
  late SyncSizeVo syncSizeVo;

  setUp(() {
    syncSizeVo = SyncSizeVo();
  });

  group("SyncSizeVo Test", () {
    test('fromJson Test success', () {
      final jsonData = {
        'projectId': '2',
        'locationId': 56,
        'downloadSizeVo': downloadSizeVo,
      };
      expect(jsonData, SyncSizeVo.fromJson(jsonData).toJson());
    });

    test('toJson Test success', () {
      syncSizeVo.projectId = '55';
      syncSizeVo.locationId = 99;
      syncSizeVo.downloadSizeVo = downloadSizeVo;
      final map = <String, dynamic>{};
      map['projectId'] = '55';
      map['locationId'] = 99;
      map['downloadSizeVo'] = downloadSizeVo;
      expect(map, syncSizeVo.toJson());
    });
  });
}
