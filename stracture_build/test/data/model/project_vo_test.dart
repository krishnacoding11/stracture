import 'package:field/data/model/project_vo.dart';
import 'package:test/test.dart';

void main() {

  group('Project', () {
    test('fromJson should parse valid JSON correctly', () {
      final jsonData = {
        'iProjectId': 1,
        'dcId': 123,
        'projectName': 'Sample Project',
        // Add other properties here with sample values
      };

      final project = Project.fromJson(jsonData);

      expect(project.iProjectId, equals(1));
      expect(project.dcId, equals(123));
      expect(project.projectName, equals('Sample Project'));
      // Add other expectations for the rest of the properties
    });

    test('toJson should encode valid object correctly', () {
      final project = Project(
        iProjectId: 1,
        dcId: 123,
        projectName: 'Sample Project',
        // Add other properties here with sample values
      );

      final json = project.toJson();

      expect(json['iProjectId'], equals(1));
      expect(json['dcId'], equals(123));
      expect(json['projectName'], equals('Sample Project'));
      // Add other expectations for the rest of the properties
    });

    test('props should return an empty list', () {
      final project = Project(
        iProjectId: 1,
        dcId: 123,
        projectName: 'Sample Project',
        // Add other properties here with sample values
      );

      final props = project.props;

      expect(props, isEmpty);
    });
  });
}
