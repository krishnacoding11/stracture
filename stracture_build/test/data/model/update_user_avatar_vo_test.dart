import 'package:field/data/model/update_user_avatar_vo.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateUserAvatarVo', () {
    test('Test constructor and getters', () {
      // Arrange
      final updateUserAvatarVo = UpdateUserAvatarVo(
        isPortraitException: true,
        exceptionMessagePortrait: 'Some exception',
        passwordModifiedDate: '2023-07-26',
      );

      // Assert
      expect(updateUserAvatarVo.isPortraitException, true);
      expect(updateUserAvatarVo.exceptionMessagePortrait, 'Some exception');
      expect(updateUserAvatarVo.passwordModifiedDate, '2023-07-26');
    });

    test('Test fromJson', () {
      // Arrange
      final json = '{ "isPortraitException": true, "exceptionMessagePortrait": "Another exception", "passwordModifiedDate": "2023-07-27" }';

      // Act
      final updateUserAvatarVo = UpdateUserAvatarVo.fromJson(json);

      // Assert
      expect(updateUserAvatarVo.isPortraitException, true);
      expect(updateUserAvatarVo.exceptionMessagePortrait, 'Another exception');
      expect(updateUserAvatarVo.passwordModifiedDate, '2023-07-27');
    });

    test('Test copyWith', () {
      // Arrange
      final originalUpdateUserAvatarVo = UpdateUserAvatarVo(
        isPortraitException: false,
        exceptionMessagePortrait: 'Original exception',
        passwordModifiedDate: '2023-07-25',
      );

      // Act
      final updatedUserAvatarVo = originalUpdateUserAvatarVo.copyWith(isPortraitException: true, exceptionMessagePortrait: 'Updated exception', passwordModifiedDate: '2023-07-28', active: false, companyId: 1, agreedToTermsOfUse: false, comments: "", contactId: 1, createDate: "", defaultUser: false, emailAddress: "", failedLoginAttempts: 1, graceLoginCount: 1, greeting: "", isSuccess: false, languageId: "", lastFailedLoginDate: "", lastLoginDate: "", lockout: false, lockoutDate: "", loginDate: "", modifiedDate: "", openId: "", passwordEncrypted: false, passwordReset: false, portraitId: 1, rawOffset: 1, screenName: "", timeZoneId: "", userId: 1, uuid: "");

      // Assert
      expect(updatedUserAvatarVo.isPortraitException, true);
      expect(updatedUserAvatarVo.exceptionMessagePortrait, 'Updated exception');
      expect(updatedUserAvatarVo.passwordModifiedDate, '2023-07-28');
      expect(updatedUserAvatarVo.active, false);
      expect(updatedUserAvatarVo.companyId, 1);
      expect(updatedUserAvatarVo.agreedToTermsOfUse, false);
      expect(updatedUserAvatarVo.comments, "");
      expect(updatedUserAvatarVo.contactId, 1);
      expect(updatedUserAvatarVo.contactId, 1);
      expect(updatedUserAvatarVo.createDate, '');
      expect(updatedUserAvatarVo.defaultUser, false);
      expect(updatedUserAvatarVo.emailAddress, '');
      expect(updatedUserAvatarVo.failedLoginAttempts, 1);
      expect(updatedUserAvatarVo.graceLoginCount, 1);
      expect(updatedUserAvatarVo.greeting, '');
      expect(updatedUserAvatarVo.isSuccess, false);
      expect(updatedUserAvatarVo.languageId, '');
      expect(updatedUserAvatarVo.lastFailedLoginDate, '');
      expect(updatedUserAvatarVo.lastLoginDate, '');
      expect(updatedUserAvatarVo.lockout, false);
      expect(updatedUserAvatarVo.lockoutDate, '');
      expect(updatedUserAvatarVo.loginDate, '');
      expect(updatedUserAvatarVo.modifiedDate, '');
      expect(updatedUserAvatarVo.openId, '');
      expect(updatedUserAvatarVo.passwordEncrypted, false);
      expect(updatedUserAvatarVo.passwordReset, false);
      expect(updatedUserAvatarVo.portraitId, 1);
      expect(updatedUserAvatarVo.rawOffset, 1);
      expect(updatedUserAvatarVo.screenName, "");
      expect(updatedUserAvatarVo.timeZoneId, "");
      expect(updatedUserAvatarVo.userId, 1);
      expect(updatedUserAvatarVo.uuid, "");
    });

    test('Test copyWith + check with comments is null', () {
      // Arrange
      final originalUpdateUserAvatarVo = UpdateUserAvatarVo();

      // Act
      final updatedUserAvatarVo = originalUpdateUserAvatarVo.copyWith();

      // Assert
      expect(updatedUserAvatarVo.comments, null);
    });

    test('Test toJson', () {
      // Arrange
      final updateUserAvatarVo = UpdateUserAvatarVo(
        isPortraitException: true,
        exceptionMessagePortrait: 'JSON exception',
        passwordModifiedDate: '2023-07-29',
        // ... (other properties)
      );

      // Act
      final json = updateUserAvatarVo.toJson();

      // Assert
      expect(json['isPortraitException'], null);
      expect(json['exceptionMessagePortrait'], null);
      expect(json['passwordModifiedDate'], '2023-07-29');
    });
  });
}
