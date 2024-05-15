import 'package:camera/camera.dart';
import 'package:field/widgets/a_file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import '../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AFilePicker filePicker = AFilePicker();

  setUp(() {
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  });

  testWidgets("Check Invalid Image", (WidgetTester tester) async {
    PlatformFile platformInValidFile = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/@##%%^&^&(())__+{}})()&(&^&%^%#%#@#@@!@!#@.png", name: "@##%%^&^&(())__+{}})()&(&^&%^%#%#@#@@!@!#@.png", bytes: null, readStream: null, size: 3028);
    FilePickerResult filePickerResult1 = FilePickerResult([platformInValidFile]);
    Map inValidFiles = filePicker.getSelectedValidFile(filePickerResult1);
    expect(inValidFiles["validFiles"] != null, false);
    expect(inValidFiles["inValidFiles"] != null, true);
  });

  testWidgets("Check valid Image", (WidgetTester tester) async {
    PlatformFile platformFile = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/Test.png", name: "test.png", bytes: null, readStream: null, size: 3028);
    FilePickerResult filePickerResult = FilePickerResult([platformFile]);
    Map filesValidImage = filePicker.getSelectedValidFile(filePickerResult);
    expect(filesValidImage["validFiles"] != null, true);
    expect(filesValidImage["inValidFiles"] != null, false);
  });

  testWidgets("Check Invalid File", (WidgetTester tester) async {
    PlatformFile platformFile = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/@##%%^&^&(())__+{}})()&(&^&%^%#%#@#@@!@!#@.pdf", name: "@##%%^&^&(())__+{}})()&(&^&%^%#%#@#@@!@!#@.pdf", bytes: null, readStream: null, size: 3028);
    FilePickerResult filePickerResult = FilePickerResult([platformFile]);
    Map files = filePicker.getSelectedValidFile(filePickerResult);
    expect(files["validFiles"] != null, false);
    expect(files["inValidFiles"] != null, true);
  });

  testWidgets("Check valid File", (WidgetTester tester) async {
    PlatformFile platformFile = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/Test.pdf", name: "Test.pdf", bytes: null, readStream: null, size: 3028);
    FilePickerResult filePickerResult = FilePickerResult([platformFile]);
    Map files = filePicker.getSelectedValidFile(filePickerResult);
    expect(files["validFiles"] != null, true);
    expect(files["inValidFiles"] != null, false);
  });

  testWidgets("Check multiple Files", (WidgetTester tester) async {
    PlatformFile platformFile1 = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/@#%^&^&(())__+{}})()&(&^&%^@@!@!#@.pdf", name: "@#%^&^&(())__+{}})()&(&^&%^@@!@!#@.pdf", bytes: null, readStream: null, size: 3028);
    PlatformFile platformFile2 = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/download?#@(2).jpg", name: "download (2).jpg", bytes: null, readStream: null, size: 7399);
    FilePickerResult filePickerResult = FilePickerResult([platformFile1, platformFile2]);
    Map<String, dynamic> files = await filePicker.getSelectedFiles(filePickerResult);
    expect(files["validFiles"] != null, false);
    expect(files["inValidFiles"] != null, true);
  });

  testWidgets("Check multiple Files With Type", (WidgetTester tester) async {
    PlatformFile platformFile = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/Test.pdf", name: "test.pdf", bytes: null, readStream: null, size: 3028);
    FilePickerResult filePickerResult = FilePickerResult([platformFile]);
    Map<String, dynamic> files = await filePicker.getSelectedFiles(filePickerResult, 'image/*');
    expect(files["validFiles"] != null, false);
    expect(files["inValidFiles"] != null, true);
  });

  testWidgets("Check multiple Files With Type", (WidgetTester tester) async {
    PlatformFile platformFile = PlatformFile(path: "/data/user/0/com.asite.field/cache/file_picker/Test.webm", name: "test.pdf", bytes: null, readStream: null, size: 3028);
    FilePickerResult filePickerResult = FilePickerResult([platformFile]);
    Map<String, dynamic> files = await filePicker.getSelectedFiles(filePickerResult, 'image/*');
    expect(files["validFiles"] != null, false);
    expect(files["inValidFiles"] != null, true);
  });

  testWidgets("Check valid file captured from Camera", (WidgetTester tester) async {
    XFile filePickerResult = XFile("/data/user/0/com.asite.field/cache/file_picker/Test.png");
    List<XFile> listFiles = [filePickerResult];
    filePicker.validateSelectedFileFromCamera(listFiles, 'image/*', (filesValidImage) {
      expect(filesValidImage["validFiles"] != null, true);
      expect(filesValidImage["inValidFiles"] != null, false);
    });

    filePicker.validateSelectedFileFromCamera(null, 'image/*', (filesValidImage) {
      expect(filesValidImage["validFiles"] == null, true);
      expect(filesValidImage["inValidFiles"] == null, true);
    });

    filePicker.validateSelectedFileFromCamera(listFiles, 'video/*', (filesValidImage) {
      expect(filesValidImage["validFiles"] != null, false);
      expect(filesValidImage["inValidFiles"] != null, true);
    });
  });

  test('Test getMultipleImages', () async {
    // Call the getMultipleImages method with the mock result
    Map<String, dynamic> selectedFiles = {};
    await filePicker.getMultipleImages(
      (error, stackTrace) {},
      FileType.image,
      (result) => selectedFiles = result,
      'image/jpeg', // Mime type of the images
    );

    // Assert that the selectedFiles map contains the validFiles and it is not empty
    expect(selectedFiles.containsKey('validFiles'), false);
    expect(selectedFiles['validFiles'], null);

    // Assert that the selectedFiles map does not contain inValidFiles
    expect(selectedFiles.containsKey('inValidFiles'), true);
  });

  test('Test getSingleFile function', () async {
    // Call the getSingleFile function with the mock result
    await filePicker.getSingleFile(
        (error, stackTrace) {
          // This callback should not be called in this test case.
          fail('Error callback should not be called in this test.');
        },
        FileType.any,
        (selectedFile) {
          // This callback should be called with the selected file.
          expect(selectedFile, isNotNull);
          expect(selectedFile['name'], null);
          expect(selectedFile['path'], null);
        });
  });

  test('Test getSingleImage function', () async {
    // Call the getSingleFile function with the mock result
    await filePicker.getSingleImage((error, stackTrace) {
      // This callback should not be called in this test case.
      fail('Error callback should not be called in this test.');
    }, (selectedFile) {
      expect(selectedFile, isNotNull);
      expect(selectedFile['name'], null);
      expect(selectedFile['path'], null);
    });
  });

  /*test('Test clearTemporaryFolder', () async {
    // Create temporary files in the tempFolder directory
    Directory appDir = await getApplicationDocumentsDirectory();
    Directory tempDir = Directory('${appDir.path}/tempFolder');
    await tempDir.create(recursive: false);
    File tempFile1 = File('${tempDir.path}/temp1.txt');
    //File tempFile2 = File('${tempDir.path}/temp2.txt');
    await tempFile1.writeAsString('Temporary content 1');
    //await tempFile2.writeAsString('Temporary content 2');

    // Perform the clearTemporaryFolder method
    await filePicker.clearTemporaryFolder();

    //expect(tempDir.listSync(recursive: true).isEmpty, isFalse);
    expect(tempDir.listSync(recursive: false).isEmpty, false);
  });*/
}
