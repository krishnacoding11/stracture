import 'package:field/data/model/user_reference_attachment_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test UserReferenceAttachmentVo properties', () {
    // Arrange
    final userAttachment = UserReferenceAttachmentVo();

    // Act
    userAttachment.userId = 'user123';
    userAttachment.projectId = 'project456';
    userAttachment.revisionId = 'revision789';
    userAttachment.userCloudId = 'cloudID101';

    // Assert
    expect(userAttachment.userId, 'user123');
    expect(userAttachment.projectId, 'project456');
    expect(userAttachment.revisionId, 'revision789');
    expect(userAttachment.userCloudId, 'cloudID101');
  });

  test('Test UserReferenceAttachmentVo properties with null values', () {
    // Arrange
    final userAttachment = UserReferenceAttachmentVo();

    // Act
    userAttachment.userId = null;
    userAttachment.projectId = null;
    userAttachment.revisionId = null;
    userAttachment.userCloudId = null;

    // Assert
    expect(userAttachment.userId, isNull);
    expect(userAttachment.projectId, isNull);
    expect(userAttachment.revisionId, isNull);
    expect(userAttachment.userCloudId, isNull);
  });
}
