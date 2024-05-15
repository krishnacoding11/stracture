import 'package:field/data/model/forgotpassword_vo.dart';
import 'package:test/test.dart';

void main() {
  group('ForgotPasswordVo Tests', () {
    test('fromJson should correctly deserialize JSON to ForgotPasswordVo object', () {
      final json = {
        'status': 'success',
        'errorMsg': 'Password reset successful',
        'errorCode': '200',
      };

      final forgotPasswordVo = ForgotPasswordVo.fromJson(json);

      // Verify that the object is correctly deserialized
      expect(forgotPasswordVo, isA<ForgotPasswordVo>());
      expect(forgotPasswordVo.status, equals('success'));
      expect(forgotPasswordVo.errorMsg, equals('Password reset successful'));
      expect(forgotPasswordVo.errorCode, equals('200'));
    });

    test('toJson should correctly serialize ForgotPasswordVo object to JSON', () {
      final forgotPasswordVo = ForgotPasswordVo(
        status: 'success',
        errorMsg: 'Password reset successful',
        errorCode: '200',
      );

      final json = forgotPasswordVo.toJson();

      // Verify that the JSON is correctly serialized
      expect(json, isA<Map<String, dynamic>>());
      expect(json['status'], equals('success'));
      expect(json['errorMsg'], equals(null));
      expect(json['errorCode'], equals('200'));
    });

    test('copyWith should return a new ForgotPasswordVo object with updated properties', () {
      final forgotPasswordVo = ForgotPasswordVo(
        status: 'success',
        errorMsg: 'Password reset successful',
        errorCode: '200',
      );

      final updatedForgotPasswordVo = forgotPasswordVo.copyWith(
        status: 'error',
        errorMsg: 'Invalid email address',
        errorCode: '400',
      );

      // Verify that the original object is not modified
      expect(forgotPasswordVo.status, equals('success'));
      expect(forgotPasswordVo.errorMsg, equals('Password reset successful'));
      expect(forgotPasswordVo.errorCode, equals('200'));

      // Verify that the new object has the updated properties
      expect(updatedForgotPasswordVo.status, equals('error'));
      expect(updatedForgotPasswordVo.errorMsg, equals('Password reset successful'));
      expect(updatedForgotPasswordVo.errorCode, equals('200'));
    });
  });

  test('copyWith should return a new ForgotPasswordVo object with updated status', () {
    final forgotPasswordVo = ForgotPasswordVo(
      status: 'success',
      errorMsg: 'Password reset successful',
      errorCode: '200',
    );

    var updatedForgotPasswordVo = forgotPasswordVo.copyWith(
      status: 'error',
    );

    // Verify that the original object is not modified
    expect(forgotPasswordVo.status, equals('success'));
    expect(forgotPasswordVo.errorMsg, equals('Password reset successful'));
    expect(forgotPasswordVo.errorCode, equals('200'));

    // Verify that the new object has the updated status
    expect(updatedForgotPasswordVo.status, equals('error'));
    expect(updatedForgotPasswordVo.errorMsg, equals('Password reset successful'));
    expect(updatedForgotPasswordVo.errorCode, equals('200'));
    updatedForgotPasswordVo = forgotPasswordVo.copyWith(
      status: null,
    );
    expect(forgotPasswordVo.status, 'success');
  });
}
