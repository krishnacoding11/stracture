import 'dart:io';

import 'package:camera/camera.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class AFilePicker{
  Future<void> getSingleImage([Function? onError, Function? selectedFileCallBack]) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(
      type: FileType.image,
    ).onError(
            (error, stackTrace) {
      if (onError != null) {
        onError(error, stackTrace);
      }
    });
    if (selectedFileCallBack != null) {
      selectedFileCallBack(result != null ? await getSelectedValidFile(result) : {});
    }
  }

  Future<void> getSingleFile([Function? onError,FileType? fileType, Function? selectedFileCallBack]) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type : fileType ?? FileType.any,allowMultiple: false).onError(
            (error, stackTrace) {
          if (onError != null) {
            onError(error, stackTrace);
          }
        });
    if (selectedFileCallBack != null) {
      selectedFileCallBack(result != null ? await getSelectedValidFile(result) : {});
    }
  }

  getSelectedValidFile(FilePickerResult result){
    Map<String, dynamic> fileDetails = {};
    String? fileName = result.files[0].name;
    Map<String, dynamic> validationObj = fileName.isValidFileName();
    if(validationObj["valid"] == false){
      fileDetails["inValidFiles"] =  validationObj["validMsg"];
    } else {
      fileDetails["validFiles"] = result.files;
    }
    return fileDetails;
  }

  Future<void> getMultipleImages([Function? onError,FileType? fileType, Function? selectedFilesCallBack, String? mimeType]) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType ?? FileType.media, allowMultiple: true,
    ).onError(
            (error, stackTrace) {
          if (onError != null) {
            onError(error, stackTrace);
          }
          return;
        }
    );
    if (selectedFilesCallBack != null) {
        selectedFilesCallBack(result != null ? await getSelectedFiles(result, mimeType) : {});
    }
  }

  Future<Map<String, dynamic>> getSelectedFiles(FilePickerResult result, [String? mimeType]) async{
    List<PlatformFile> arr = result.files;
    List newArr = [], inValidFiles = [];
    Map<String, dynamic> fileDetails = {};
    Directory appDir = await AppPathHelper().getDocumentDirectory();
    await Future.forEach(arr.toSet(), (PlatformFile filePath) async {
      String fileName = filePath.path!.split("/").last;
      Map<String, dynamic> validTypeObj = fileName.isValidFileType(mimeType ?? "");
      if(validTypeObj["valid"] == false){
        inValidFiles.add(validTypeObj["validMsg"]);
      } else {
        Map<String, dynamic> validationObj = fileName.isValidFileName();
        if(validationObj['valid'] == false){
          inValidFiles.add(validationObj["validMsg"]);
        } else {
          String path = "${appDir.path}/tempFolder/$fileName";
          await createFileFromFile(filePath.path!, path);
          PlatformFile newFile = PlatformFile(name: filePath.name, size: filePath.size, path: path);
          newArr.add(newFile);
        }
      }
    });
    if(inValidFiles.isNotEmpty) {
      List<dynamic>? fileList = inValidFiles.toSet().toList();
      fileDetails["inValidFiles"] = fileList;
    }
    if(newArr.isNotEmpty) fileDetails["validFiles"] = newArr;
    return fileDetails;
  }

  Future<void> validateSelectedFileFromCamera(List<XFile>? result, [String? mimeType, Function? selectedFilesCallBack]) async{
    List<XFile> validFiles = [];
    List<dynamic> inValidFiles = [];
    Map<String, dynamic> fileDetails = {};
    result?.forEach((file) {
      String fileName = file.path!.split("/").last;
      Map<String, dynamic> validTypeObj = fileName.isValidFileType(mimeType ?? "");
      if(validTypeObj["valid"] == false) {
        inValidFiles.add(validTypeObj["validMsg"]);
      } else {
        validFiles.add(file);
      }
    });
    if(inValidFiles.isNotEmpty) {
      fileDetails["inValidFiles"] = inValidFiles;
    }
    if(validFiles.isNotEmpty) {
      fileDetails["validFiles"] = validFiles;
    }

    if (selectedFilesCallBack != null) {
      selectedFilesCallBack(fileDetails);
    }

  }

  clearTemporaryFolder() async {
    List<FileSystemEntity> arr;
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = "${appDir.path}/tempFolder/";
    final myDir = Directory(path);
    if(myDir.existsSync()){
      arr = myDir.listSync(recursive: true, followLinks: false);
      for(var file in arr) {
        file.delete();
      }
    }
  }
}