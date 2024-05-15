import 'package:field/data/model/taskstatussist_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskStatusListVo', () {
    test('fromJson should correctly parse JSON data', () {
      // Arrange
      final jsonData = '{"statusId": 1, "statusDesc": "In Progress", "statusName": "In_Progress"}';

      // Act
      final taskStatus = taskStatusListVoFromJson(jsonData);

      // Assert
      expect(taskStatus.statusId, 1);
      expect(taskStatus.statusDesc, 'In Progress');
      expect(taskStatus.statusName, 'In_Progress');
    });

    test('toJson should correctly convert object to JSON data', () {
      // Arrange
      final taskStatus = TaskStatusListVo(
        statusId: 1,
        statusDesc: 'In Progress',
        statusName: 'In_Progress',
      );

      // Act
      final jsonData = taskStatusListVoToJson(taskStatus);

      // Assert
      final expectedJsonData = '{"statusId":1,"statusDesc":"In Progress","statusName":"In_Progress"}';
      expect(jsonData, expectedJsonData);
    });

    test('copyWith should create a new object with updated values', () {
      // Arrange
      final originalStatus = TaskStatusListVo(
        statusId: 1,
        statusDesc: 'In Progress',
        statusName: 'In_Progress',
      );

      // Act
      final updatedStatus = originalStatus.copyWith(statusId: 2, statusDesc: 'Completed');

      // Assert
      expect(updatedStatus.statusId, 2);
      expect(updatedStatus.statusDesc, 'Completed');
      expect(updatedStatus.statusName, 'In_Progress'); // statusName should remain the same
    });

    test('copyWith should create a new object with updated values', () {
      // Arrange
      final originalStatus = TaskStatusListVo(
        statusId: 1,
        statusDesc: null,
        statusName: 'In_Progress',
      );

      // Act
      final updatedStatus = originalStatus.copyWith(statusId: 2, statusDesc: null);

      // Assert
      expect(updatedStatus.statusId, 2);
      expect(updatedStatus.statusDesc, null);
      expect(updatedStatus.statusName, 'In_Progress'); // statusName should remain the same
    });
  });
}
