import 'dart:async';
import 'dart:io';

import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/data/dao/user_reference_attachment_dao.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/data/remote/generic/generic_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/sync/db_config.dart';
import 'package:field/sync/task/offline_project_mark.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/qrcode_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/language_change/language_change_cubit.dart';
import '../../data/local/login/login_local_repository.dart';
import '../../data/model/user_vo.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/form_html_utility.dart';
import '../../utils/store_preference.dart';
import '../../widgets/login_background.dart';
import '../../widgets/logo.dart';
import '../managers/routes_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  _copyAssetFileToFileSystemAndExtract() async {
    ByteData data = await rootBundle.load("assets/offline/HTML5Form.zip");
    String zipDir = await AppPathHelper().getAssetHTML5FormZipPath();
    String zipFilePath = "$zipDir/HTML5Form.zip";
    Log.d("htmlform" + zipFilePath);
    File zipFile = File(zipFilePath)..writeAsBytesSync(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    if (await ZipUtility().extractZipFile(strZipFilePath: zipFilePath, strExtractDirectory: zipDir)) {
      FormHtmlUtility().updateHTML5AssetFilePath(zipFilePath: zipFilePath, zipDirPath: zipDir, basePath: await AppPathHelper().getBasePath());
    }
    zipFile.deleteSync();
  }

  _copyAssetFileToFileSystemAndExtractOfflineHtml() async {
    ByteData data = await rootBundle.load("assets/offline/ModelLoader.zip");
    String zipDir = await AppPathHelper().getAssetOfflineZipPath();
    String zipFilePath = "$zipDir/ModelLoader.zip";
    Log.d("zipFilePath" + zipFilePath);
    File zipFile = File(zipFilePath)..writeAsBytesSync(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    if (await ZipUtility().extractZipFile(strZipFilePath: zipFilePath, strExtractDirectory: zipDir)) {
      // FormHtmlUtility().updateHTML5AssetFilePath(
      //     zipFilePath: zipFilePath, zipDirPath: zipDir);
    }
    zipFile.deleteSync();
  }

  _initAppPreRequisiteData() async {
    int currentVersionCode = 1; // Need to get current app version
    int oldVersionCode = await StorePreference.getLastAppVersion();
    if (oldVersionCode < currentVersionCode) {
      await _copyAssetFileToFileSystemAndExtract();
      await _copyAssetFileToFileSystemAndExtractOfflineHtml();
    }
    await StorePreference.setLastAppVersion(currentVersionCode);
  }


  Future<void> deleteAttachmentZipFile() async {
    final offlineProjectMark = OfflineProjectMark();
    await offlineProjectMark.deleteAttachmentZipFiles();
  }

  @override
  initState() {
    super.initState();
    deleteAttachmentZipFile();
    checkInternetConnection();
    checkFile();
    Timer(const Duration(milliseconds: 800), () async {
      await _initAppPreRequisiteData();
      User? currUser = await StorePreference.getUserData();
      if (mounted) {
        if (currUser?.usersessionprofile != null) {
          Project? currSelectedProject = await StorePreference.getSelectedProjectData();
          await Utility.setDataToFirebaseInstance(currUser!.usersessionprofile!);
          await setupUserCurrentSetting(currUser);
          await DBConfig().removeAndCreateSyncStatusTables();
          if (currUser.usersessionprofile!.isAgreedToTermsAndCondition == "true") {
            QRCodeDataVo? qrObj = await QrCodeUtility.extractDataFromLink();
            if (isNetWorkConnected()) {
              await di.getIt<GenericRemoteRepository>().getDeviceConfiguration();
            }
            if (currSelectedProject == null && qrObj?.projectId == null) {
              Navigator.pushReplacementNamed(context, Routes.projectList, arguments: AConstants.projectSelection);
            } else {
              di.getIt<ProjectListCubit>().getWorkspaceSettingData(currSelectedProject!.projectID!);
              await StorePreference.checkAndSetSelectedProjectIdHash();
              Navigator.pushReplacementNamed(context, Routes.dashboard);
            }
          } else {
            Navigator.pushReplacementNamed(context, Routes.userFirstLoginSetup, arguments: "fromSplash");
          }
        } else {
          Navigator.pushReplacementNamed(context, Routes.onboardingLogin);
        }
      }
    });
  }

  Future<void> checkFile() async {
    File file = File("${await AppPathHelper().getAssetOfflineZipPath()}/files/offline.html");
    bool isExist = await file.exists();
    if (!isExist) {
      await _copyAssetFileToFileSystemAndExtractOfflineHtml();
    }
  }

  Future<void> checkInternetConnection() async {
    await di.getIt<InternetCubit>().checkConnectivity();
    di.getIt<InternetCubit>().updateConnectionStatus();
  }

  Future<void> setupUserCurrentSetting(User currentUser) async {
    String? localLanguageDateFormat = await StorePreference.getLocalLanguageDateFormat();

    if (localLanguageDateFormat!.isNotEmpty) {
      List<String> listLocalLanguageDateFormat = localLanguageDateFormat.split("#");
      if (listLocalLanguageDateFormat.length > 1) {
        String languageId = listLocalLanguageDateFormat[0];
        String dateFormat = listLocalLanguageDateFormat[1];

        if (dateFormat != currentUser.usersessionprofile!.dateFormatforLanguage && languageId != currentUser.usersessionprofile!.languageId) {
          currentUser.usersessionprofile!.languageId = languageId;
          currentUser.usersessionprofile!.dateFormatforLanguage = dateFormat;

          //Storage OPERATION
          await StorePreference.setUserCurrentLanguage(languageId);
          await StorePreference.setUserCurrentDateFormatForLanguage(languageId);
          await StorePreference.setUserData(currentUser);

          //LOCAl DB OPERATION
          final LogInLocalRepository _loginLocalRepository = di.getIt<LogInLocalRepository>();
          List<User> userFormLocalDb = await _loginLocalRepository.getData();
          List<User> findUserFromDb;

          if (userFormLocalDb.isNotEmpty && userFormLocalDb.isNotEmpty) {
            findUserFromDb = userFormLocalDb.where((User dbUser) => (dbUser.usersessionprofile!.userID == currentUser.usersessionprofile!.userID)).toList();

            if (findUserFromDb.isNotEmpty) {
              findUserFromDb[0].usersessionprofile!.languageId = languageId;
              findUserFromDb[0].usersessionprofile!.dateFormatforLanguage = dateFormat;
            }
          }
        }
      }
    }
    di.getIt<LanguageChangeCubit>().getUserWithSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return const LoginBackgroundWidget(child: LogoWidget());
  }
}
