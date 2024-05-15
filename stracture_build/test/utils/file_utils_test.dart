import 'package:field/utils/file_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../bloc/mock_method_channel.dart';
import '../fixtures/fixture_reader.dart';

class MockFileUtility extends Mock implements FileUtility {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setAsitePluginsMethodChannel();

  FileUtility fileUtility = FileUtility();

  test('create File From File When Image', () async {
    String filePath = fixtureFile("temp_img_annotation.png");
    String path = fixtureFile("temp_img_annotation_copy.png");
    await fileUtility.createFileFromFile(filePath,path);
    expect(fileUtility.isFileExist(path), true);
  });
  test('create File From File When PDF', () async {
    String filePath = fixtureFile("test.pdf");
    String path = fixtureFile("test_copy.pdf");
    await fileUtility.createFileFromFile(filePath,path);
    expect(fileUtility.isFileExist(path), true);
  });

  group("File Exist", () {
    test('check file Exist with Extension', () async {
      String filePath = fixtureFile("test.pdf");
      expect(fileUtility.isFileExist(filePath), true);
    });

    test('check file Exist without Extension', () async {
      String filePath = fixtureFile("test");
      expect(fileUtility.isFileExist(filePath), true);
    });
  });
}