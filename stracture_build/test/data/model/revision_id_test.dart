import 'package:field/data/model/revision_data.dart';
import 'package:test/test.dart';

void main() {
  group('RevisionId tests', () {
    test('fromJson() should initialize object from JSON', () {
      // Given
      Map<String, dynamic> json = {
        "revisionId": 12345,
        "status": "approved",
      };

      // When
      var revisionId = RevisionId.fromJson(json);

      // Then
      expect(revisionId.revisionId, equals(12345));
      expect(revisionId.status, equals("approved"));
    });

    test('toJson() should convert object to JSON', () {
      // Given
      var revisionId = RevisionId(revisionId: 12345, status: "approved");

      // When
      var json = revisionId.toJson();

      // Then
      expect(json["revisionId"], equals(12345));
      expect(json["status"], equals("approved"));
    });
  });
}
