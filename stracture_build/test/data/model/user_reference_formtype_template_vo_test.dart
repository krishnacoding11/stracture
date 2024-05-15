import 'package:field/data/model/user_reference_formtype_template_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test UserReferenceFormTypeTemplateVo properties', () {
    // Arrange
    final userReference = UserReferenceFormTypeTemplateVo();

    // Act
    userReference.userId = 'user123';
    userReference.projectId = 'project456';
    userReference.formTypeID = 'form789';
    userReference.userCloudId = 'cloudID101';

    // Assert
    expect(userReference.userId, 'user123');
    expect(userReference.projectId, 'project456');
    expect(userReference.formTypeID, 'form789');
    expect(userReference.userCloudId, 'cloudID101');
  });

  test('Test UserReferenceFormTypeTemplateVo properties with null values', () {
    // Arrange
    final userReference = UserReferenceFormTypeTemplateVo();

    // Act
    userReference.userId = null;
    userReference.projectId = null;
    userReference.formTypeID = null;
    userReference.userCloudId = null;

    // Assert
    expect(userReference.userId, isNull);
    expect(userReference.projectId, isNull);
    expect(userReference.formTypeID, isNull);
    expect(userReference.userCloudId, isNull);
  });
}
