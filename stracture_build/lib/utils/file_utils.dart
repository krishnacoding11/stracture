import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:image/image.dart' as img;

import '../logger/logger.dart';

FileUtility fileUtility = getIt<FileUtility>();

List<String> imageExtension = [".jpg", ".png", ".jpeg"];

Future<String?> getFileDir({String? filePath}) async {
  return await fileUtility.getFileDir(filePath: filePath);
}

Future<String> getFilterFilePath({required String fileName}) async {
  return await fileUtility.getFilterFilePath(fileName: fileName);
}

Future<File?> getFile(String fileName, {String? filePath}) async {
  return await fileUtility.getFile(fileName, filePath: filePath);
}

Future<bool> isFileExists(File? file) async {
  return await fileUtility.isFileExists(file);
}

bool isFileExist(String filePath) {
  return fileUtility.isFileExist(filePath);
}

Future<void> writeIntoFile(File? file, String data) async {
  await fileUtility.writeIntoFile(file, data);
}

Future<String?> readDataFromFile(File? file) async {
  return await fileUtility.readDataFromFile(file);
}

String readFromFile(String filePath) {
  return fileUtility.readFromFile(filePath);
}

Future<void> deleteFile(File? file, {bool recursive = false}) async {
  await fileUtility.deleteFile(file, recursive: recursive);
}

Future<void> deleteFileAtPath(String? path, {bool recursive = false}) async {
  await fileUtility.deleteFileAtPath(path, recursive: recursive);
}

Future<void> createFileFromFile(String? orignal, String? path) async {
  await fileUtility.createFileFromFile(orignal, path);
}

void deleteDirectory({required String directoryPath})  {
   fileUtility.deleteDirectory(directoryPath: directoryPath);
}

Future<int> getFileSize(String path) async {
  return await fileUtility.getFileSize(path);
}

int getFileSizeSync(String path) {
  return fileUtility.getFileSizeSync(path);
}

String getFileNameFromPath(String path) {
  return fileUtility.getFileNameFromPath(path);
}

String getFileNameWithoutExtention(String fileName) {
  return fileUtility.getFileNameWithoutExtention(fileName);
}

Future<void> writeDataToFile(String filePath, dynamic data) async {
  await fileUtility.writeDataToFile(filePath, data);
}

void renameFile(String oldFilePath, String newFilePath) {
  fileUtility.renameFile(oldFilePath, newFilePath);
}

class FileUtility {
  void renameFile(String oldFilePath, String newFilePath) {
    File(oldFilePath).renameSync(newFilePath);
  }

  void copySyncFile(String originalFilePath, String copyFilePath) {
    File(originalFilePath).copySync(copyFilePath);
  }

  Future<String?> getFileDir({String? filePath}) async {
    return await Utility.getUserDirPath(path: filePath) as String;
  }

  Future<String> getFilterFilePath({required String fileName}) async {
    String path = await getFileDir() ?? "";
    Project? temp = await StorePreference.getSelectedProjectData();
    String projectID = temp?.projectID.plainValue() ?? "";
    String dcId = temp?.dcId.toString() ?? "";
    path = "$path/${dcId}_${projectID}_$fileName";
    return path;
  }

  Future<File?> getFile(String fileName, {String? filePath}) async {
    try {
      String? dirPath = await getFileDir(filePath: filePath);
      if (!dirPath.isNullOrEmpty()) {
        return File('$dirPath/$fileName');
      }
    } catch (e) {
      Log.e(e);
    }
    return null;
  }

  Future<bool> isFileExists(File? file) async {
    return file != null && file.existsSync();
  }

  bool isFileExist(String filePath) {
    if (filePath.isEmpty) {
      return false;
    } else {
      String fileExtension = filePath.getExtension();
      if (fileExtension.length > 1) {
        return (filePath.isNotEmpty) ? File(filePath).existsSync() : false;
      } else {
        bool isFileExist = false;
        try {
          String dirPath = filePath.substring(0, filePath.toString().lastIndexOf("/"));
          Directory dir = Directory(dirPath);
          if (dir.existsSync()) {
                    String fileName = filePath.getFileNameWithoutExtension();
                    final files = dir.listSync();
                    for (int i = 0; i < files.length; i++) {
                      if (files[i] is File && files[i].path.toString().getFileNameWithoutExtension() == fileName) {
                        isFileExist = true;
                        break;
                      }
                    }
                  }
        } catch (e) {}
        return isFileExist;
      }
    }
  }

  Future<void> writeIntoFile(File? file, String data) async {
    if (file != null) {
      await file.writeAsString(data);
    }
  }

  Future<String?> readDataFromFile(File? file) async {
    if (await isFileExists(file)) {
      return await file!.readAsString();
    } else {
      return null;
    }
  }

  String readFromFile(String filePath) {
    File file = File(filePath);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    return "";
  }

  Future<void> deleteFile(File? file, {bool recursive = false}) async {
    await file!.delete(recursive: recursive);
  }

  Future<void> deleteFileAtPath(String? path, {bool recursive = false}) async {
    if (path != null) {
      var file = File(path);
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Error in getting access to the file.
      }
    }
  }

  Future<void> createFileFromFile(String? original, String? path) async {
    if (original != null && path != null) {
      var tempFilePath = File(path);
      tempFilePath.createSync(recursive: true);
      if (imageExtension.contains(path.toString().getFileExtension()?.toLowerCase())) {
        var originalFile = File(original);
        var bytes = originalFile.readAsBytesSync();
        final img.Image? capturedImage = img.decodeImage(bytes);
        if (capturedImage != null) {
          final img.Image orientedImage = img.bakeOrientation(capturedImage);
          tempFilePath.writeAsBytesSync(img.encodeJpg(orientedImage));
        } else {
          File(original).copySync(tempFilePath.path);
        }
      } else {
        File(original).copySync(tempFilePath.path);
      }
    }
  }

  void deleteDirectory({required String directoryPath}) {
    final dir = Directory(directoryPath);
    dir.deleteSync(recursive: true);
  }

  Future<int> getFileSize(String path) async {
    var file = File(path);
    int bytes = await file.length();
    return bytes;
  }

  int getFileSizeSync(String path) {
    return File(path).lengthSync();
  }

  String getFileNameFromPath(String path) {
    var fileName = (path.split('/').last);
    return fileName;
  }

  String getFileNameWithoutExtention(String fileName) {
    var extension = (fileName.split('.').first);
    return extension;
  }

  Future<void> writeDataToFile(String filePath, dynamic data) async {
    var file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync(recursive: true);
    await file.writeAsString(data);
  }
}

class ZipUtility {
  static final ZipUtility _instance = ZipUtility._internal();

  factory ZipUtility() {
    return _instance;
  }

  ZipUtility._internal();

  Future<bool> extractZipFile({required String strZipFilePath, required String strExtractDirectory, bool removeOldData = true}) async {
    bool isSuccess = false;
    try {
      if (isFileExist(strZipFilePath)) {
        final inputStream = InputFileStream(strZipFilePath);
        final archive = ZipDecoder().decodeBuffer(inputStream);
        if (removeOldData) {
          final deleteDataList = archive.files.where((tmpName) => ((!tmpName.name.contains('/') && tmpName.isFile) || (tmpName.name.endsWith('/') && "/".allMatches(tmpName.name).length <= 1 && !tmpName.isFile))).toList();
          for (ArchiveFile file in deleteDataList) {
            String itemName = file.name;
            if (file.isFile) {
              await deleteFileAtPath("$strExtractDirectory/$itemName");
            } else {
              final dir = Directory("$strExtractDirectory/$itemName");
              if (dir.existsSync()) {
                dir.deleteSync(recursive: true);
              }
            }
          }
        }
        extractArchiveToDisk(archive, strExtractDirectory);
        isSuccess = true;
      }
    } on Exception catch (e) {
      Log.e("ZipUtility::extractZipFile exception=$e");
    }
    return isSuccess;
  }

  List<String> getFileList({required String strZipFilePath}) {
    List<String> fileList = [];
    try {
      final inputStream = InputFileStream(strZipFilePath);
      final archive = ZipDecoder().decodeBuffer(inputStream);
      for (var element in archive.files) {
        if (element.isFile) {
          fileList.add(element.name);
        }
      }
    } on Exception catch (e) {
      Log.e("ZipUtility::getFileList exception=$e");
    }
    return fileList;
  }

  bool isZipFileExist({required String strZipFilePath}) {
    bool isSuccess = false;
    try {
      if (File(strZipFilePath).existsSync()) {
        final inputStream = InputFileStream(strZipFilePath);
        final archive = ZipDecoder().decodeBuffer(inputStream);
        isSuccess = (archive.isNotEmpty);
      }
    } on Exception catch (e) {
      Log.e("ZipUtility::isZipFileExist exception=$e");
    }
    return isSuccess;
  }
}
