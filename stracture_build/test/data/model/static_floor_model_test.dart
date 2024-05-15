import 'package:field/data/model/static_floor_model.dart';
import 'package:test/test.dart';

void main() {
  group('FloorModel Tests', () {
    test('FloorModel should be constructed correctly', () {
      // Arrange
      String text = 'Floor 1';
      bool isShowListView = true;
      bool isShowCheckBox = false;

      // Act
      var floorModel = FloorModel(text, isShowListView, isShowCheckBox);

      // Assert
      expect(floorModel.text, equals(text));
      expect(floorModel.isShowListView, equals(isShowListView));
      expect(floorModel.isShowCheckBox, equals(isShowCheckBox));
    });

    test('FloorModel should update properties correctly', () {
      // Arrange
      String text = 'Floor 2';
      bool isShowListView = false;
      bool isShowCheckBox = true;

      // Act
      var floorModel = FloorModel('', false, false);
      floorModel.text = text;
      floorModel.isShowListView = isShowListView;
      floorModel.isShowCheckBox = isShowCheckBox;

      // Assert
      expect(floorModel.text, equals(text));
      expect(floorModel.isShowListView, equals(isShowListView));
      expect(floorModel.isShowCheckBox, equals(isShowCheckBox));
    });
  });
}
