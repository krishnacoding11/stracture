import 'package:field/data/model/upload_fail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test UploadFail constructor and getters', () {
    // Arrange
    final uploadFail = UploadFail(
      id: 1,
      statusCode: 400,
      fileName: ['file1.txt', 'file2.txt'],
      messageString: 'Upload failed!',
    );

    // Assert
    expect(uploadFail.id, 1);
    expect(uploadFail.statusCode, 400);
    expect(uploadFail.fileName, ['file1.txt', 'file2.txt']);
    expect(uploadFail.messageString, 'Upload failed!');
  });

  test('Test UploadFail fromJson', () {
    // Arrange
    final json = {
      'id': 2,
      'statusCode': 500,
      'fileName': ['file3.txt'],
      'messageString': 'Another upload failure!',
    };

    // Act
    final uploadFail = UploadFail.fromJson(json);

    // Assert
    expect(uploadFail.id, 2);
    expect(uploadFail.statusCode, 500);
    expect(uploadFail.fileName, ['file3.txt']);
    expect(uploadFail.messageString, 'Another upload failure!');
  });

  test('Test UploadFail copyWith', () {
    // Arrange
    final originalFail = UploadFail(
      id: 3,
      statusCode: 200,
      fileName: ['file4.txt'],
      messageString: 'Original fail',
    );

    // Act
    final copiedFail = originalFail.copyWith(
      messageString: 'Updated fail',
    );

    // Assert
    expect(copiedFail.id, 3);
    expect(copiedFail.statusCode, 200);
    expect(copiedFail.fileName, ['file4.txt']);
    expect(copiedFail.messageString, 'Updated fail');
  });

  test('Test UploadFail copyWith with messageString', () {
    // Arrange
    final originalFail = UploadFail(
      id: 3,
      statusCode: 200,
      fileName: ['file4.txt'],
      messageString: 'Original fail',
    );

    // Act
    final copiedFail = originalFail.copyWith(
      messageString: null,
    );

    // Assert
    expect(copiedFail.id, 3);
    expect(copiedFail.statusCode, 200);
    expect(copiedFail.fileName, ['file4.txt']);
    expect(copiedFail.messageString, 'Original fail');
  });


  test('Test UploadFail toJson', () {
    // Arrange
    final uploadFail = UploadFail(
      id: 4,
      statusCode: 201,
      fileName: ['file5.txt'],
      messageString: 'Success!',
    );

    // Act
    final json = uploadFail.toJson();

    // Assert
    expect(json['id'], 4);
    expect(json['statusCode'], 201);
    expect(json['fileName'], ['file5.txt']);
    expect(json['messageString'], 'Success!');
  });

  test('Test UploadFail jsonToList', () {
    // Arrange
    final response = [
      {
        'id': 5,
        'statusCode': 404,
        'fileName': ['file6.txt'],
        'messageString': 'Not found',
      },
    ];

    // Act
    final list = UploadFail.jsonToList(response);

    // Assert
    expect(list.length, 1);
    expect(list[0].id, 5);
    expect(list[0].statusCode, 404);
    expect(list[0].fileName, ['file6.txt']);
    expect(list[0].messageString, 'Not found');
  });
}
