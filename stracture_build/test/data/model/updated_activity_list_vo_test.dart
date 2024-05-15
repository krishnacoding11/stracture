import 'package:field/data/model/updated_activity_list_vo.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  test('Test UpdatedActivityListVo constructor and getters', () {
    // Arrange
    final response = Response(root: Root(errorDesc: 'Some error'));
    final updatedActivityListVo = UpdatedActivityListVo(
      msg: 'Message',
      response: response,
      errorCode: 'Error123',
      isSuccess: true,
    );

    // Assert
    expect(updatedActivityListVo.msg, 'Message');
    expect(updatedActivityListVo.response, response);
    expect(updatedActivityListVo.errorCode, 'Error123');
    expect(updatedActivityListVo.isSuccess, true);
  });


  test('Test UpdatedActivityListVo constructor and getter and check if success is null', () {

    // Arrange
    final response = Response(root: Root(errorDesc: 'Some error', deliverableActivities: []));
    final updatedActivityListVo = UpdatedActivityListVo(
      msg: 'Message',
      response: response,
      errorCode: 'Error123',
      isSuccess: null,
    );

    // Assert
    expect(updatedActivityListVo.msg, 'Message');
    expect(updatedActivityListVo.response, response);
    expect(updatedActivityListVo.errorCode, 'Error123');
    expect(updatedActivityListVo.isSuccess, null);
  });

  test('Test UpdatedActivityListVo fromJson', () {
    // Arrange
    final json = {
      'msg': 'Another message',
      'response': {
        'root': {'errorDesc': 'Some other error'}
      },
      'errorCode': 'Error456',
      'isSuccess': false,
    };

    // Act
    final updatedActivityListVo = UpdatedActivityListVo.fromJson(json);

    // Assert
    expect(updatedActivityListVo.msg, 'Another message');
    expect(updatedActivityListVo.response?.root?.errorDesc, 'Some other error');
    expect(updatedActivityListVo.errorCode, 'Error456');
    expect(updatedActivityListVo.isSuccess, false);
  });

  test('Test UpdatedActivityListVo copyWith', () {
    // Arrange
    final originalResponse = Response(root: Root(errorDesc: 'Original error'));
    final originalUpdatedActivityListVo = UpdatedActivityListVo(
      msg: 'Original message',
      response: originalResponse,
      errorCode: 'OriginalError',
      isSuccess: true,
    );

    // Act
    final updatedActivityListVo = originalUpdatedActivityListVo.copyWith(
      msg: 'Updated message',
      isSuccess: false,
    );

    // Assert
    expect(updatedActivityListVo.msg, 'Updated message');
    expect(updatedActivityListVo.response, originalResponse);
    expect(updatedActivityListVo.errorCode, 'OriginalError');
    expect(updatedActivityListVo.isSuccess, false);
  });

  test('Test UpdatedActivityListVo copyWith + success is null', () {
    // Arrange
    final originalResponse = Response(root: Root(errorDesc: 'Original error'));
    final originalUpdatedActivityListVo = UpdatedActivityListVo(
      msg: 'Original message',
      response: originalResponse,
      errorCode: 'OriginalError',
      isSuccess: null,
    );

    // Act
    final updatedActivityListVo = originalUpdatedActivityListVo.copyWith(
      msg: 'Updated message',
      isSuccess: null,
    );

    // Assert
    expect(updatedActivityListVo.msg, 'Updated message');
    expect(updatedActivityListVo.response, originalResponse);
    expect(updatedActivityListVo.errorCode, 'OriginalError');
    expect(updatedActivityListVo.isSuccess, null);
  });

  test('Test UpdatedActivityListVo toJson', () {
    // Arrange
    final response = Response(root: Root(errorDesc: 'JSON error'));
    final updatedActivityListVo = UpdatedActivityListVo(
      msg: 'JSON message',
      response: response,
      errorCode: 'JSONError',
      isSuccess: true,
    );

    // Act
    final json = updatedActivityListVo.toJson();

    // Assert
    expect(json['msg'], 'JSON message');
    expect(json['response']['root']['errorDesc'], 'JSON error');
    expect(json['errorCode'], 'JSONError');
    expect(json['isSuccess'], true);
  });

  test('Test LocPercentage fromJson and toJson', () {
    // Arrange
    final json = {'Plan': 50};

    // Act
    final locPercentage = LocPercentage.fromJson(json);
    final locPercentageJson = locPercentage.toJson();

    // Assert
    expect(locPercentage.plan, 50);
    expect(locPercentageJson['Plan'], 50);
  });

  group('Root Test', () {
    test('toJson() should return a valid JSON map', () {
      final locPercentage = LocPercentage(); // Replace with appropriate values for LocPercentage object
      final root = Root(
        errorDesc: 'Test error',
        locPercentage: locPercentage,
        deliverableActivities: [],
        errorCode: 404,
      );

      final jsonMap = root.toJson();

      // Replace the values below with the expected JSON map
      final expectedJsonMap = {
        'errorDesc': 'Test error',
        'locPercentage': locPercentage.toJson(),
        'deliverableActivities': [],
        'errorCode': 404,
      };

      expect(jsonMap, equals(expectedJsonMap));
    });

    test('fromJson() should correctly parse a JSON map', () {
      final jsonMap = {
        'errorDesc': 'Test error',
        'locPercentage': {}, // Replace with appropriate values for LocPercentage JSON
        'deliverableActivities': [],
        'errorCode': 404,
      };

      final root = Root.fromJson(jsonMap);

      // Replace the values below with the expected values from the JSON map
      // Assuming that LocPercentage.fromJson(jsonMap['locPercentage']) is properly tested
      expect(root.errorDesc, equals('Test error'));
      expect(root.errorCode, equals(404));
    });
  });

  group('LocPercentage Test', () {
    test('toJson() should return a valid JSON map', () {
      final locPercentage = LocPercentage(
        plan: 10,
      );

      final jsonMap = locPercentage.toJson();

      // Replace the values below with the expected JSON map
      final expectedJsonMap = {
        'Plan': 10,
      };

      expect(jsonMap, equals(expectedJsonMap));
    });

    test('fromJson() should correctly parse a JSON map', () {
      final jsonMap = {
        'Plan': 10,
      };

      final locPercentage = LocPercentage.fromJson(jsonMap);

      // Replace the values below with the expected values from the JSON map
      expect(locPercentage.plan, equals(10));
    });
  });

  test('Test Response copyWith', () {
    final root = Root(
        errorDesc: 'Original error'
    );
    final response = Response(root: root);
    final newRoot = Root(
        errorDesc: 'Original error'
    );
    final updatedResponse = response.copyWith(root: newRoot);

    expect(updatedResponse.root, equals(newRoot));
  });

  test('Test Root copyWith', () {
    final root = Root(
        errorDesc: 'Original error',
      deliverableActivities: []
    );

    final updatedResponse = root.copyWith(errorCode: 201);

    expect(updatedResponse.errorCode, 201);
  });

  test('Test Root copyWith + errorCode = null', () {
    final root = Root(
        errorDesc: 'Original error',
        deliverableActivities: []
    );

    final updatedResponse = root.copyWith(errorCode: null);

    expect(updatedResponse.errorCode, null);
  });

  test('Test Root copyWith + deliverableActivities = null', () {
    final root = Root(
        errorDesc: 'Original error',
        deliverableActivities: []
    );

    final updatedResponse = root.copyWith(deliverableActivities: null);

    expect(updatedResponse.deliverableActivities, []);
  });

  test('Test LocPercentage copyWith', () {
    // Arrange
    final json = {'Plan': 50};

    // Act
    final locPercentage = LocPercentage.fromJson(json);
    final locPercentageJson = locPercentage.toJson();

    // Assert
    expect(locPercentage.plan, 50);
    expect(locPercentageJson['Plan'], 50);

    locPercentage.copyWith(plan: 1);
    expect(locPercentage.plan, 50);

    locPercentage.copyWith(plan: null);
    expect(locPercentage.plan, 50);
  });
}


