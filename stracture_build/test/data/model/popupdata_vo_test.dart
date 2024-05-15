import 'package:field/data/model/popupdata_vo.dart';
import 'package:test/test.dart';

void main() {
  group('Popupdata', () {
    test('toJson should return the correct map', () {
      final popupdata = Popupdata(
        id: '1',
        value: 'Value 1',
        dataCenterId: 2,
        isSelected: true,
        imgId: 3,
        isActive: true,
      );

      final json = popupdata.toJson();

      expect(json, {
      'id': '1',
      'value': 'Value 1',
      'dataCenterId': 2,
      'isSelected': true,
      'imgId': 3,
      'isActive': true,
      'projectSizeInByte': null
      });
    });

    test('fromJson should correctly initialize the object', () {
      final json = {
        'id': '1',
        'value': 'Value 1',
        'dataCenterId': 2,
        'isSelected': true,
        'imgId': 3,
        'isActive': true,
      };

      final popupdata = Popupdata.fromJson(json);

      expect(popupdata.id, '1');
      expect(popupdata.value, 'Value 1');
      expect(popupdata.dataCenterId, 2);
      expect(popupdata.isSelected, true);
      expect(popupdata.imgId, 3);
      expect(popupdata.isActive, true);
    });

    test('props should return an empty list', () {
      final data = Popupdata(
        id: "123",
        value: "Sample Value",
        dataCenterId: 1,
        isSelected: true,
        imgId: 456,
        isActive: true,
        childfolderTreeVOList: null,
      );

      final props = data.props;

      expect(props, isEmpty);
    });


    test('fromJson should parse valid JSON correctly', () {
      // Test the fromJson method (same as previous test).
    });

    test('toJson should encode valid object correctly', () {
      // Test the toJson method (same as previous test).
    });
  });
}
