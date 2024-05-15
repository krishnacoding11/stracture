import 'dart:io';

import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';

class AppPathHelper {
  static const DATABASE_FOLDER = "database";
  static const HTML5FORM_FOLDER = "HTML5Form";
  static const OFFLINE_HTML_FOLDER = "OfflineHtml";
  static const FILES_FOLDER = "files";
  static const PLANS_FOLDER = "Plans";
  static const MODEL_FOLDER = "Models";
  static const ATTACHMENTS_FOLDER = "Attachments";
  static const FORMTYPES_FOLDER = "FormTypes";
  static const XSNFORMVIEW_FOLDER = "XSNFormView";
  static const COLUMNHEADER_FOLDER = "ColumnHeader";
  static const TMPOFFLINEFORMS_FOLDER = "TmpOffline";
  static const TEMP_ATTACHMENTS_FOLDER = "tempAttachments";
  static const OFFLINEREQUESTDATA_FOLDER = "OfflineRequestData";

  static const dataJsonFile = "data.json";
  static const fixFieldJsonFile = "Fix-FieldData.json";
  static const distributionJsonFile = "DistributionData.json";
  static const customAttributeJsonFile = "CustomAttributeData.json";
  static const statusListJsonFile = "StatusListData.json";
  static const controllerUserListJsonFile = "ControllerUserListData.json";
  static const offlineViewFormHtmlFile = "offlineViewForm.html";
  static const filterAttributeJsonFile = "filterAttributeData.json";
  static const homePageShortcutConfigJsonFile = "homePageShortcutConfigData.json";

  static final AppPathHelper _instance = AppPathHelper._internal();
  String _basePath = "";
  String get basePath => _basePath;

  factory AppPathHelper() {
    return _instance;
  }

  AppPathHelper._internal();

  /// return-> /data/data/com.asite.field/app_flutter
  Future<String> getBasePath() async {
    if (_basePath.isEmpty) {
      Directory appDir = await getDocumentDirectory();
      _basePath = appDir.path;
    }
    return _basePath;
  }
  Future<Directory> getDocumentDirectory() async{
    if(Platform.isIOS){
      return await getLibraryDirectory();
    }else{
      return await getApplicationDocumentsDirectory();
    }
  }
  /// Create Directory and return $path
  Future<String> createDirectoryIfNotExist(String path) async {
    final Directory dbDir = Directory(path);
    if (await dbDir.exists()) {
      return dbDir.path;
    } else {
      final Directory dbDirNew = await dbDir.create(recursive: true);
      return dbDirNew.path;
    }
  }

  /// return-> /data/data/com.asite.field/app_flutter/{childDirectory}
  Future<String> getAppRootDirectory(String childDirectory) async {
    String appDir = await getBasePath();
    final path = '$appDir/$childDirectory';
    return await createDirectoryIfNotExist(path);
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/HTML5Form
  Future<String> getAssetHTML5FormZipPath() async {
    return await getAppRootDirectory("$DATABASE_FOLDER/$HTML5FORM_FOLDER");
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/HTML5Form
  Future<String> getAssetOfflineZipPath() async {
    return await getAppRootDirectory("$DATABASE_FOLDER/$OFFLINE_HTML_FOLDER");
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/HTML5Form/offlineViewForm.html
  Future<String> getOfflineViewFormHTMLFilePath() async {
    String path = await getAssetHTML5FormZipPath();
    path = "$path/$offlineViewFormHtmlFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/HTML5Form/offlineViewForm.html
  Future<String> getTempOfflineViewFormsHTMLFilePath() async {
    String path = await getAssetHTML5FormZipPath();
    path = "$path/$TMPOFFLINEFORMS_FOLDER";
    return await createDirectoryIfNotExist(path);
  }

  /// return-> /data/data/com.asite.field/app_flutter/database
  Future<String> getUserDatabasePath() async {
    return await getAppRootDirectory(DATABASE_FOLDER);
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}
  Future<String> getUserDataPath() async {
    String path = await getUserDatabasePath();
    path =
        "$path/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}";
    return await createDirectoryIfNotExist(path);
  }

  /// return-> /data/data/com.asite.field/app_flutter/files
  Future<String> getAppFilesDataPath() async {
    return await getAppRootDirectory(FILES_FOLDER);
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/ColumnHeader/${listingType}.json
  Future<String> getColumnHeaderFilePath({required String listingType}) async {
    String path =
        await getAppRootDirectory("$FILES_FOLDER/$COLUMNHEADER_FOLDER");
    path = "$path/$listingType.json";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/fieldUser.db
  Future<String> getUserDBFilePath() async {
    String path = await getUserDatabasePath();
    path = "$path/${AConstants.userDbFile}";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/fieldData.db
  Future<String> getUserDataDBFilePath() async {
    String path = await getUserDataPath();
    path = "$path/${AConstants.dataDbFile}";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/2116416/Plans
  Future<String> getPlanDirectory({required String projectId}) async {
    String path = await getAppFilesDataPath();
    path = "$path/${projectId.plainValue()}/$PLANS_FOLDER";
    return await createDirectoryIfNotExist(path);
  }

  Future<String> getModelDirectory({required String projectId}) async {
    String path = await getAppFilesDataPath();
    path = "$path/${projectId.plainValue()}/$MODEL_FOLDER";
    return await createDirectoryIfNotExist(path);
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/Plans/${revisionId}.${fileExtention}
  Future<String> getPlanPDFFilePath(
      {required String projectId,
      required String revisionId,
      String fileExtension = "pdf"}) async {
    String path = await getPlanDirectory(projectId: projectId);
    path = "$path/${revisionId.plainValue()}.$fileExtension";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/Models/${revisionId}/.${filename}
  Future<String> getModelScsFilePath(
      {required String projectId,
      required String revisionId,
      required String filename,
      required String modelId}) async {
    String path = await getModelDirectory(projectId: projectId);
    path = "$path/${revisionId.plainValue()}/$filename";
   // path = "$path/${modelId.plainValue()}/${revisionId.plainValue()}/$filename";
    return path;
  }

  Future<String> getModelRevIdPath(
      {required String projectId,
      required String revisionId,
      required String modelId}) async {
    String path = await getModelDirectory(projectId: projectId);
  //  path = "$path/${modelId.plainValue()}/${revisionId.plainValue()}";
    path = "$path/${revisionId.plainValue()}";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/Plans/${revisionId}.${fileExtention}
  Future<String> getPlanXFDFFilePath(
      {required String projectId,
      required String revisionId,
      String fileExtention = "xfdf"}) async {
    String path = await getPlanDirectory(projectId: projectId);
    path = "$path/${revisionId.plainValue()}.$fileExtention";
    return path;
  }

  // return -> /storage/emulated/0/Download/$appLabel
  Future<Directory> getDownloadAppNamePath() async {
    Directory? externalDir;
    final appLabel = await Utility.getApplicationLabel();
    externalDir = appLabel != null ? Directory('/storage/emulated/0/Download/$appLabel')
                    : Directory('/storage/emulated/0/Download');
    await externalDir.create(recursive: true);
    return externalDir;
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/Attachments
  Future<String> getAttachmentDirectory({required String projectId}) async {
    String path = await getAppFilesDataPath();
    path = "$path/${projectId.plainValue()}/$ATTACHMENTS_FOLDER";
    return await createDirectoryIfNotExist(path);
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/Attachments/${revisionId}.${fileExtention}
  Future<String> getAttachmentFilePath({required String projectId, required String revisionId, required String fileExtention, bool isExtensionNameOnly = false}) async {
    String path = await getAttachmentDirectory(projectId: projectId);
    path = isExtensionNameOnly
        ? "$path/${revisionId.plainValue()}$fileExtention"
        : fileExtention.isNotEmpty
            ? "$path/${revisionId.plainValue()}.$fileExtention"
            : "$path/${revisionId.plainValue()}";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/FormTypes/${formTypeId}
  Future<String> getAppDataFormTypeDirectory(
      {required String projectId, required String formTypeId}) async {
    String path = await getAppFilesDataPath();
    path =
        "$path/${projectId.plainValue()}/$FORMTYPES_FOLDER/${formTypeId.plainValue()}";
    return await createDirectoryIfNotExist(path);
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/FormTypes/${formTypeId}/${formTypeId}.${fileExtention}
  Future<String> getFormTypeTemplateFilePath(
      {required String projectId,
      required String formTypeId,
      String fileExtention = "zip"}) async {
    String path = await getAppDataFormTypeDirectory(
        projectId: projectId, formTypeId: formTypeId);
    path = "$path/${formTypeId.plainValue()}.$fileExtention";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/filterAttributeData.json
  Future<String> getProjectFilterAttributeFile({required String projectId}) async {
    String path = await getUserDataPath();
    path = "$path/${projectId.plainValue()}";
    await createDirectoryIfNotExist(path);
    path = "$path/$filterAttributeJsonFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/FormTypes/${formTypeId}
  Future<String> getUserDataFormTypeDirectory(
      {required String projectId, required String formTypeId}) async {
    String path = await getUserDataPath();
    path =
        "$path/${projectId.plainValue()}/$FORMTYPES_FOLDER/${formTypeId.plainValue()}";
    return await createDirectoryIfNotExist(path);
  }

  /// return-> /data/data/com.asite.field/app_flutter/files/${projectId}/FormTypes/${formTypeId}/data.json
  Future<String> getFormTypeDataJsonFilePath(
      {required String projectId, required String formTypeId}) async {
    String path = await getAppDataFormTypeDirectory(
        projectId: projectId, formTypeId: formTypeId);
    path = "$path/$dataJsonFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/FormTypes/${formTypeId}/Fix-FieldData.json
  Future<String> getFormTypeFixFieldFilePath(
      {required String projectId, required String formTypeId}) async {
    String path = await getUserDataFormTypeDirectory(
        projectId: projectId, formTypeId: formTypeId);
    path = "$path/$fixFieldJsonFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/FormTypes/${formTypeId}/DistributionData.json
  Future<String> getFormTypeDistributionFilePath(
      {required String projectId, required String formTypeId}) async {
    String path = await getUserDataFormTypeDirectory(
        projectId: projectId, formTypeId: formTypeId);
    path = "$path/$distributionJsonFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/FormTypes/${formTypeId}/CustomAttributeData.json
  Future<String> getFormTypeCustomAttributeFilePath(
      {required String projectId, required String formTypeId}) async {
    String path = await getUserDataFormTypeDirectory(
        projectId: projectId, formTypeId: formTypeId);
    path = "$path/$customAttributeJsonFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/FormTypes/${formTypeId}/StatusListData.json
  Future<String> getFormTypeStatusListFilePath(
      {required String projectId, required String formTypeId}) async {
    String path = await getUserDataFormTypeDirectory(
        projectId: projectId, formTypeId: formTypeId);
    path = "$path/$statusListJsonFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/FormTypes/${formTypeId}/ControllerUserListData.json
  Future<String> getFormTypeControllerUserListFilePath(
      {required String projectId, required String formTypeId}) async {
    String path = await getUserDataFormTypeDirectory(
        projectId: projectId, formTypeId: formTypeId);
    path = "$path/$controllerUserListJsonFile";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/XSNFormView/${formId}.${fileExtension}
  Future<String> getXSNFormViewFilePath(
      {required String projectId,
      required String formId,
      String fileExtention = "html"}) async {
    String path = await getUserDataPath();
    path = "$path/${projectId.plainValue()}/$XSNFORMVIEW_FOLDER";
    path = await createDirectoryIfNotExist(path);
    path = "$path/${formId.plainValue()}.$fileExtention";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/OfflineRequestData/${msgId}.${fileExtension}
  Future<String> getOfflineRequestDataFilePath(
      {required String projectId,
        required String msgId,
        String fileExtention = "txt"}) async {
    String path = await getUserDataPath();
    path = "$path/${projectId.plainValue()}/$OFFLINEREQUESTDATA_FOLDER";
    path = await createDirectoryIfNotExist(path);
    path = "$path/${msgId.plainValue()}.$fileExtention";
    return path;
  }


  Future<String> getTemporaryAttachmentPath({required String fileName, required String projectId}) async {
    String path = await getUserDataPath();
    path = "$path/${projectId.plainValue()}/$TEMP_ATTACHMENTS_FOLDER";
    path = await createDirectoryIfNotExist(path);
    path = "$path/$fileName";
    return path;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/userProfile
  Future<String> getUserDataProfilePath() async {
    String path = await getUserDataPath();
    path = "$path/${AConstants.userProfile}";
    return path;
  }

  Future<String> getSyncLogFilePath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/${AConstants.syncLogFilePath}';
    return filePath;
  }

  /// return-> /data/data/com.asite.field/app_flutter/database/${cloudId}_${userId}/${projectId}/homePageShortcutConfigData.json
  Future<String> getHomePageShortcutConfigFile({required String projectId}) async {
    String path = await getUserDataPath();
    path = "$path/${projectId.plainValue()}";
    await createDirectoryIfNotExist(path);
    path = "$path/$homePageShortcutConfigJsonFile";
    return path;
  }
}
