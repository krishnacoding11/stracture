import 'dart:convert';
import 'package:field/data/model/offline_activity_vo.dart';
import 'package:field/data/model/revision_data.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson should convert JSON map to OfflineActivityVo object', () {
    final jsonString = '{"revisionId": 12345, "status": "downloading"}';
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final revisionId = RevisionId.fromJson(jsonMap);

    expect(revisionId.revisionId, equals(12345));
    expect(revisionId.status, equals("downloading"));
  });

  test('toJson should convert OfflineActivityVo object to JSON map', () {
    final revisionId = RevisionId(
      revisionId: 12345,
      status: "downloading",
    );

    final jsonMap = revisionId.toJson();

    expect(jsonMap['revisionId'], equals(12345));
    expect(jsonMap['status'], equals("downloading"));
  });
}
