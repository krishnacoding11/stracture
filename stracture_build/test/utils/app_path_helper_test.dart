import 'dart:io';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/injection_container.dart' as di;
import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import 'load_url.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  AppConfigTestData().setupAppConfigTestData();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setgetapplabel();
  final appPathHelper = AppPathHelper();

  test("Get Base Path", () async {
    final basePath = await appPathHelper.getBasePath();
    expect(basePath, TEST_MOCK_STORAGE);
  });

  test("Create Directory If Not Exist", () async {
    final path = '/test/createDir';
    final dirPath = await appPathHelper.createDirectoryIfNotExist(path);
    expect(dirPath, path);
  });

  test("Get App Root Directory", () async {
    final childPath = 'test/createDir';
    final dirPath = await appPathHelper.getAppRootDirectory(childPath);
    expect(dirPath, '$TEST_MOCK_STORAGE/$childPath');
  });

  test("Get Asset HTML5 FormZip Path", () async {
    final dirPath = await appPathHelper.getAssetHTML5FormZipPath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${AppPathHelper.HTML5FORM_FOLDER}");
  });

  test("Get Asset Offline ZipPath", () async {
    final dirPath = await appPathHelper.getAssetOfflineZipPath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${AppPathHelper.OFFLINE_HTML_FOLDER}");
  });

  test("Get Offline ViewFormHTML FilePath", () async {
    final dirPath = await appPathHelper.getOfflineViewFormHTMLFilePath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${AppPathHelper.HTML5FORM_FOLDER}/${AppPathHelper.offlineViewFormHtmlFile}");
  });

  test("Get TempOfflineViewFormsHTML FilePath", () async {
    final dirPath = await appPathHelper.getTempOfflineViewFormsHTMLFilePath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${AppPathHelper.HTML5FORM_FOLDER}/${AppPathHelper.TMPOFFLINEFORMS_FOLDER}");
  });

  test("Get User Database Path", () async {
    final dirPath = await appPathHelper.getUserDatabasePath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}");
  });

  test("Get User Data Path", () async {
    final dirPath = await appPathHelper.getUserDataPath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}");
  });

  test("Get AppFilesData Path", () async {
    final dirPath = await appPathHelper.getAppFilesDataPath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}");
  });

  test("Get ColumnHeaderFile Path", () async {
    final dirPath = await appPathHelper.getColumnHeaderFilePath( listingType: 'listingType');
    expect(dirPath, '$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/${AppPathHelper.COLUMNHEADER_FOLDER}/listingType.json');
  });

  test("Get UserDBFile Path", () async {
    final dirPath = await appPathHelper.getUserDBFilePath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${AConstants.userDbFile}");
  });

  test("Get UserDataDBFile Path", () async {
    final dirPath = await appPathHelper.getUserDataDBFilePath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/${AConstants.dataDbFile}");
  });

  test("Get Plan Directory", () async {
    final dirPath = await appPathHelper.getPlanDirectory(projectId: '2116416');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.PLANS_FOLDER}");
  });

  test("Get Model Directory", () async {
    final dirPath = await appPathHelper.getModelDirectory(projectId: '2116416');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.MODEL_FOLDER}");
  });

  test("Get Plan PDFFile Path", () async {
    final dirPath = await appPathHelper.getPlanPDFFilePath(projectId: '2116416', revisionId: '2');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.PLANS_FOLDER}/2.pdf");
  });

  test("Get ModelScsFile Path", () async {
    final dirPath = await appPathHelper.getModelScsFilePath(projectId: '2116416', revisionId: '2', filename: 'filename.pdf', modelId: '234');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.MODEL_FOLDER}/2/filename.pdf");
  });

  test("Get ModelRevId Path", () async {
    final dirPath = await appPathHelper.getModelRevIdPath(projectId: '2116416', revisionId: '10', modelId: '234');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.MODEL_FOLDER}/10");
  });

  test("Get PlanXFDFFile Path", () async {
    final dirPath = await appPathHelper.getPlanXFDFFilePath(projectId: '2116416', revisionId: '10');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.PLANS_FOLDER}/10.xfdf");
  });

  test("getDownloadAppNamePath", () async {
    Directory dirPath = await appPathHelper.getDownloadAppNamePath();
    expect(dirPath.path, "/storage/emulated/0/Download/");
  });

  test("Get Attachment Directory", () async {
    final dirPath = await appPathHelper.getAttachmentDirectory(projectId: '2116416');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.ATTACHMENTS_FOLDER}");
  });

  test("Get AttachmentFile Path", () async {
    final dirPath = await appPathHelper.getAttachmentFilePath(projectId: '2116416', revisionId: '10', fileExtention: 'pdf');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.ATTACHMENTS_FOLDER}/10.pdf");
  });

  test("Get AppDataFormType Directory", () async {
    final dirPath = await appPathHelper.getAppDataFormTypeDirectory(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641");
  });

  test("Get FormTypeTemplateFile Path", () async {
    final dirPath = await appPathHelper.getFormTypeTemplateFilePath(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641/10641.zip");
  });

  test("Get ProjectFilterAttribute File", () async {
    final dirPath = await appPathHelper.getProjectFilterAttributeFile(projectId: '2116416');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.filterAttributeJsonFile}");
  });

  test("Get UserDataFormType Directory", () async {
    final dirPath = await appPathHelper.getUserDataFormTypeDirectory(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641");
  });

  test("Get FormTypeDataJsonFile Path", () async {
    final dirPath = await appPathHelper.getFormTypeDataJsonFilePath(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.FILES_FOLDER}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641/${AppPathHelper.dataJsonFile}");
  });

  test("Get FormTypeFixFieldFile Path", () async {
    final dirPath = await appPathHelper.getFormTypeFixFieldFilePath(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641/${AppPathHelper.fixFieldJsonFile}");
  });

  test("Get FormTypeDistributionFile Path", () async {
    final dirPath = await appPathHelper.getFormTypeDistributionFilePath(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641/${AppPathHelper.distributionJsonFile}");
  });

  test("Get FormTypeCustomAttributeFile Path", () async {
    final dirPath = await appPathHelper.getFormTypeCustomAttributeFilePath(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641/${AppPathHelper.customAttributeJsonFile}");
  });

  test("Get FormTypeStatusListFile Path", () async {
    final dirPath = await appPathHelper.getFormTypeStatusListFilePath(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641/${AppPathHelper.statusListJsonFile}");
  });

  test("Get FormTypeControllerUserListFile Path", () async {
    final dirPath = await appPathHelper.getFormTypeControllerUserListFilePath(projectId: '2116416', formTypeId: '10641');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.FORMTYPES_FOLDER}/10641/${AppPathHelper.controllerUserListJsonFile}");
  });

  test("Get XSNFormViewFile Path", () async {
    final dirPath = await appPathHelper.getXSNFormViewFilePath(projectId: '2116416', formId: '200');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.XSNFORMVIEW_FOLDER}/200.html");
  });

  test("Get OfflineRequestDataFile Path", () async {
    final dirPath = await appPathHelper.getOfflineRequestDataFilePath(projectId: '2116416', msgId: '300');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.OFFLINEREQUESTDATA_FOLDER}/300.txt");
  });

  test("Get TemporaryAttachment Path", () async {
    final dirPath = await appPathHelper.getTemporaryAttachmentPath(fileName: 'filename', projectId: '2116416');
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/2116416/${AppPathHelper.TEMP_ATTACHMENTS_FOLDER}/filename");
  });

  test("Get UserDataProfile Path", () async {
    final dirPath = await appPathHelper.getUserDataProfilePath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AppPathHelper.DATABASE_FOLDER}/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}/${AConstants.userProfile}");
  });

  test("Get SyncLogFile Path", () async {
    final dirPath = await appPathHelper.getSyncLogFilePath();
    expect(dirPath, "$TEST_MOCK_STORAGE/${AConstants.syncLogFilePath}");
  });
}