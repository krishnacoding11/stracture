import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_config.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/model/download_size_vo.dart';
import '../data/model/popupdata_vo.dart';
import '../data/model/user_vo.dart';
import '../networking/network_response.dart';
import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';
import '../presentation/managers/image_constant.dart';
import '../presentation/managers/routes_manager.dart';
import '../widgets/elevatedbutton.dart';
import 'constants.dart';
import 'file_utils.dart';
import '../../../injection_container.dart' as di;
import 'package:field/utils/app_config.dart';

enum DeviceType { phone, tablet }

enum FromScreen { unknown, longPress, qrCode, listing, dashboard, siteTakListing, planView, task, quality }

class Utility {
  static Timer? _timer;
  static const String weekStartDayKey = "start_date";
  static const String weekEndDayKey = "end_date";
  static const String defaultDateFormat = "dd-MMM-yyyy";

  static bool isTablet = getDeviceType() == DeviceType.tablet;
  static bool isSmallTablet = getDeviceTabletType() == DeviceType.tablet;
  static bool isPhone = getDeviceTabletType() == DeviceType.phone;

  static const agentPlatform = MethodChannel('addodle.useragent/channel');

  static bool isIos = Platform.isIOS ? true : false;

  static Popupdata popupData = Popupdata();

  static const String keyDollar = "\$\$";

  static DeviceType getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
  }

  Center noModelWidget(String str) {
    return Center(
      child: Text(str),
    );
  }

  static DeviceType getDeviceTabletType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 650 ? DeviceType.phone : DeviceType.tablet;
  }

  static Future<String?> getExternalDirectoryPath() async {
    Directory? externalDir;
    if (Platform.isIOS) {
      externalDir = await getApplicationDocumentsDirectory();
      return externalDir?.path;
    } else {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      externalDir = await AppPathHelper().getDownloadAppNamePath();

      if (!await externalDir.exists()) {
        externalDir = await getExternalStorageDirectory();
      }

      return externalDir!.path;
    }
  }

  static Future<String?> getUserDirPath({String? path}) async {
    String appDirPath = await AppPathHelper().getBasePath();
    Usersessionprofile? userSessionProfile = (await StorePreference.getUserData() as User).usersessionprofile;
    if (userSessionProfile != null) {
      String userFolder = "${userSessionProfile.userID!}_${userSessionProfile.tpdOrgID}";
      if (path != null && path.isNotEmpty) {
        userFolder = "$userFolder/$path";
      }
      final Directory dbDir = Directory('$appDirPath/$userFolder');
      if (await dbDir.exists()) {
        //if folder already exists return path
        return dbDir.path;
      } else {
        //if folder not exists create folder and then return its path
        final Directory dbDirNew = await dbDir.create(recursive: true);
        return dbDirNew.path;
      }
    }
    return null;
  }

  static Future<String?> getAppDirPath({String? path}) async {
    Directory appDir = await AppPathHelper().getDocumentDirectory();
    String userFolder = appDir.path;
    if (path != null && path.isNotEmpty) {
      userFolder = "$userFolder/$path";
    }
    final Directory dbDir = Directory(userFolder);
    if (await dbDir.exists()) {
      return dbDir.path;
    } else {
      final Directory dbDirNew = await dbDir.create(recursive: true);
      return dbDirNew.path;
    }
  }

  static showReLoginDialog(FAIL fail) {
    if (fail.responseCode == 401 || fail.responseCode == 409 || fail.responseCode == 403) {
      showAlertWithOk(NavigationUtils.mainNavigationKey.currentContext!, fail.failureMessage!, onPress: () {
        Navigator.pushReplacementNamed(NavigationUtils.mainNavigationKey.currentContext!, Routes.onboardingLogin);
        StorePreference.clearUserPreferenceData();
      });
    }
  }

  static showAlertDialog(BuildContext context, String title, String messages) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (cnx) => AlertDialog(
        title: Text(title),
        content: Text(messages),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(cnx).pop();
              },
              child: Text(context.toLocale!.lbl_btn_cancel))
        ],
      ),
    );
  }

  static showAlertWithOk(BuildContext context, String msg, {Function? onPress}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Message'),
        content: Text(msg),
        actions: [
          ElevatedButton(
              onPressed: () {
                if (onPress != null) {
                  onPress();
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(context.toLocale!.lbl_ok))
        ],
      ),
    );
  }

  static showConfirmationDialog({required BuildContext context, String? title, required String msg, Function? onPressOkButton, Function? onPressCancelButton}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(actionsPadding:EdgeInsets.zero ,titlePadding: EdgeInsets.zero,contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 18),insetPadding: EdgeInsets.symmetric(horizontal: 20),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300, // Border color
                  width: 1.0, // Border width
                ),
              ),
            ),
            child: NormalTextWidget(title ?? 'Alert', fontSize: 14, textAlign: TextAlign.start, fontWeight: FontWeight.normal,)),
        content: NormalTextWidget(msg, fontSize: 15, fontWeight: FontWeight.normal,textAlign: TextAlign.left,),
        actions: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade200, // Border color
                width: 1.0, // Border width
              ),
            ),
          ),
          child: ButtonBar(
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    if (onPressCancelButton != null) {
                      onPressCancelButton(context);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 4,horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0), // Border radius here
                        side: BorderSide(color: Colors.grey, width: 1.0), // Border color and width here
                      ),
                    ),
                  child: NormalTextWidget(
                    context.toLocale!.lbl_btn_cancel,
                    color: AColors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  )),
            Container(
              width: 45,
              child: OutlinedButton(
                onPressed: () {
                  if (onPressOkButton != null) {
                    onPressOkButton(context);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 0),
                  backgroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0), // Border radius here
                    side: BorderSide(color: Colors.grey, width: 1.0), // Border color and width here
                  ),
                ),
                child: NormalTextWidget(
                  context.toLocale!.lbl_ok,
                  color: AColors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),]),
        )]
      ));

  }

  static String getErrorMessage(int? errorCode, {String? message}) {
    switch (errorCode) {
      case 221:
        return NavigationUtils.mainNavigationKey.currentContext?.toLocale?.error_message_221 ?? "Account locked due to multiple invalid login attempts. Please contact the Asite Helpdesk";
      case 224:
        return NavigationUtils.mainNavigationKey.currentContext?.toLocale?.error_message_224 ?? "Your login account is not active. Please contact the administrator for more help";
      case 403:
      case 409:
        return NavigationUtils.mainNavigationKey.currentContext?.toLocale?.error_message_403 ?? "You have been logged Out!. Another login to Asite app on this or another device with the same login details terminated your Asite app session";
      case 401:
        return NavigationUtils.mainNavigationKey.currentContext?.toLocale?.error_message_403 ?? "You have been logged Out!. Another login to Asite app on this or another device with the same login details terminated your Asite app session";
      case 404:
        return (!message!.isNullOrEmpty()) ? message : (NavigationUtils.mainNavigationKey.currentContext?.toLocale?.error_message_404 ?? "Something went wrong please try again later");
      case 502:
      case 503:
        return NavigationUtils.mainNavigationKey.currentContext?.toLocale?.error_message_503 ?? "Server is not available. Please try after sometime.";
      default:
        return (!message!.isNullOrEmpty()) ? message : NavigationUtils.mainNavigationKey.currentContext?.toLocale?.error_message_404 ?? "Something went wrong. Please try again later";
    }
  }

  static Future<String> getUserAgent() async {
    try {
      return await agentPlatform.invokeMethod('getUserAgent');
    } catch (e) {
      return "Mozilla/5.0 (Linux; Android 11; sdk_gphone_x86_arm Build/RPB1.200504.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.44 Safari/537.36";
    }
  }

  static String getFileSizeString({required double bytes, int decimals = 0}) {
    // const suffixes = ["b", "kb", "mb", "gb", "tb"];
    // var i = (log(bytes) / log(1024)).floor();
    // return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
    String fileSize = "";

    double b = bytes;
    double kb = bytes / 1000.0;
    double mb = bytes / 1000000.0;
    double gb = bytes / 1000000000.0;
    double tb = bytes / 1000000000000.0;

    if (tb > 1) {
      fileSize = "${tb.toStringAsFixed(2)} TB";
    } else if (gb > 1) {
      fileSize = "${gb.toStringAsFixed(2)} GB";
    } else if (mb > 1) {
      fileSize = "${mb.toStringAsFixed(2)} MB";
    } else if (kb > 1) {
      fileSize = "${kb.toStringAsFixed(2)} KB";
    } else {
      fileSize = "${b.toStringAsFixed(2)} Bytes";
    }
    return fileSize;
  }

  static bool isPDFTronSupported(String ext) {
    switch (ext.toUpperCase()) {
      case "PDF":
      case "XFDF":
      case "FDF":
      case "DOC":
      case "DOCX":
      case "XLS":
      case "XLSX":
      case "PPT":
      case "PPTX":
      case "SVG":
      case "BMP":
      case "EMF":
      case "GIF":
      case "JPG":
      case "PNG":
      case "TIF":
      case "HTML":
      case "TXT":
      case "XPS":
        return true;
      case "JP2":
      case "JPC":
        {
          if (Utility.isIos) {
            return false;
          } else {
            return true;
          }
        }
      case "HEIF":
      case "RTF":
      case "PAGES":
      case "KEY":
      case "NUMBERS":
        {
          if (Utility.isIos) {
            return true;
          } else {
            return false;
          }
        }
      default:
        return false;
    }
  }

  static String generateRandomNumberForDocument() {
    Random r = Random();
    String randomNumber = r.nextInt(1001).toString().padLeft(4, '0');
    List<String> characters = randomNumber.split('');
    String randomStr = '';
    for (String c in characters) {
      randomStr = '$randomStr${c}_';
    }
    if (kDebugMode) {
      Log.d("===Random==sb==$randomStr");
    }
    return randomStr;
  }

  static Future<String> getCurrentDateForWeatherWidget() async {
    DateTime date = DateTime.now();
    try {
      String dateFormat = "EEE d MMMM yyyy";
      User? user = await StorePreference.getUserData();
      String lang = user?.usersessionprofile!.languageId ?? "";
      lang = lang.split("_").first;
      String finalDate = DateFormat(dateFormat, lang).format(date);
      return finalDate;
    } catch (e) {
      String dateFormat = "EEE d MMMM yyyy";
      String finalDate = DateFormat(dateFormat, 'en').format(date);
      return finalDate;
    }
  }

  static Map<String, String> getWeekStartEndDate(DateTime date, {String dateFormat = 'dd-MMM-yyyy', int weekDays = 5}) {
    var startDate = date.subtract(Duration(days: date.weekday - 1));
    var endDate = startDate.add(Duration(days: weekDays - 1));
    return {
      weekStartDayKey: DateFormat(dateFormat).format(startDate),
      weekEndDayKey: DateFormat(dateFormat).format(endDate),
    };
  }

  /*
  Future<String> getDirectorySize(String plainProjectId, String modelId) async {
    String getTotalSizeOfFolder = "0kb";
    Directory appDir = await getApplicationDocumentsDirectory();
    Usersessionprofile? userSessionProfile = (await StorePreference.getUserData() as User).usersessionprofile;

    if (userSessionProfile != null) {
      String userFolder = "${userSessionProfile.userID!}_${userSessionProfile.tpdOrgID}";
      if (plainProjectId.isNotEmpty) {
        userFolder = "$userFolder/${plainProjectId.plainValue()}/${modelId.plainValue()}";
      }
      final Directory dbDir = Directory('${appDir.path}/$userFolder');
      if (await dbDir.exists()) {
        //if folder already exists return path

        var listOfAllFolderAndFiles = await dbDir.list(recursive: false).toList();
        List<String> tempList = [];
        for (int i = 0; i < listOfAllFolderAndFiles.length; i++) {
          tempList.add(listOfAllFolderAndFiles[i].path);
        }
        getTotalSizeOfFolder = getFolderSize(tempList, 0);

        return getTotalSizeOfFolder;
      } else {
        return getTotalSizeOfFolder;
      }
    }
    return getTotalSizeOfFolder;
  }

  Future<String> getFilesSize(String plainProjectId, String revisionId, String modelId) async {
    String fileSize = "0kb";
    Directory appDir = await getApplicationDocumentsDirectory();
    Usersessionprofile? userSessionProfile = (await StorePreference.getUserData() as User).usersessionprofile;

    if (userSessionProfile != null) {
      String userFolder = "${userSessionProfile.userID!}_${userSessionProfile.tpdOrgID}";
      if (plainProjectId.isNotEmpty) {
        userFolder = "$userFolder/${plainProjectId.plainValue()}/${modelId.plainValue()}";
      }

      final Directory dbDir = Directory('${appDir.path}/$userFolder');
      if (await dbDir.exists()) {
        //if folder already exists return path
        Directory dir = Directory("${appDir.path}/$userFolder/${revisionId.plainValue()}.scs");

        fileSize = getFileSize(dir.path, 0);
        if (fileSize == "0kb") {
          return "Need to download";
        }
        return fileSize;
      } else {
        return "Need to download";
      }
    }
    return fileSize;
  }

  */
  String getFileSize(String filePath, int decimals) {
    try {
      File image = File(filePath);
      var bytes = image.lengthSync();
      const suffixes = ["b", "kb", "mb", "gb", "tb"];
      var i = 1;
      if (bytes != 0) {
        i = (log(bytes) / log(1024)).floor();
      }
      return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
    } on Exception {
      return "0kb";
    }
  }

  static Future<String?> getModelDirPath(String projectId, String revisionId, String modelID, String ext) async {
    String plainProjectId = projectId.plainValue();
    String modelId = modelID.plainValue();
    String plainRevisionId = revisionId.plainValue();
    String fileName = "$modelId/$plainRevisionId$ext";
    String dirPath = await Utility.getUserDirPath(path: plainProjectId) as String;
    return "$dirPath/$fileName";
  }

  void deleteFolder(String plainProjectId, String modelId) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    Usersessionprofile? userSessionProfile = (await StorePreference.getUserData() as User).usersessionprofile;

    if (userSessionProfile != null) {
      String userFolder = "${userSessionProfile.userID!}_${userSessionProfile.tpdOrgID}";
      if (plainProjectId.isNotEmpty) {
        userFolder = "$userFolder/${plainProjectId.plainValue()}/${modelId.plainValue()}";
      }

      final Directory dbDir = Directory('${appDir.path}/$userFolder');
      var listOfAllFolderAndFiles = await dbDir.list(recursive: false).toList();

      for (int i = 0; i < listOfAllFolderAndFiles.length; i++) {
        deleteFile(File(listOfAllFolderAndFiles[i].path));
      }
    }
  }

  Future<void> deleteFile(File? file, {bool recursive = false}) async {
    if (await isFileExists(file)) {
      Log.d("File exists");
      await file!.delete(recursive: recursive);
    } else {
      Log.d("File not exists");
    }
  }

  String getFolderSize(List<String> filePath, int decimals) {
    int totalBytes = 0;
    String folderSizeInString = "0kb";
    try {
      for (int j = 0; j < filePath.length; j++) {
        File image = File(filePath[j]);
        totalBytes = totalBytes + image.lengthSync();
      }
      const suffixes = ["b", "kb", "mb", "gb", "tb"];
      var i = 1;
      if (totalBytes != 0) {
        i = (log(totalBytes) / log(1024)).floor();
      }
      folderSizeInString = ((totalBytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
      return folderSizeInString;
    } on Exception {
      return folderSizeInString;
    }
  }

  Future<String> getDownloadedFilesPath(String plainProjectId, String revisionId, String modelId) async {
    String fileSize = "";
    Directory appDir = await getApplicationDocumentsDirectory();
    Usersessionprofile? userSessionProfile = (await StorePreference.getUserData() as User).usersessionprofile;

    if (userSessionProfile != null) {
      String userFolder = "${userSessionProfile.userID!}_${userSessionProfile.tpdOrgID}";
      if (plainProjectId.isNotEmpty) {
        userFolder = "$userFolder/${plainProjectId.plainValue()}/${modelId.plainValue()}";
      }
      final Directory dbDir = Directory('${appDir.path}/$userFolder');
      if (await dbDir.exists()) {
        Directory dir = Directory("${appDir.path}/$userFolder/${revisionId.plainValue()}.scs");

        fileSize = getFileSize(dir.path, 0);
        if (fileSize == "0kb") {
          return "";
        } else {
          return dir.path;
        }
      } else {
        return "";
      }
    }
    return fileSize;
  }

  static String getDateTimeFromTimeStamp(String timestamp, {String dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"}) {
    return DateFormat(dateFormat).format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)));
  }

  static Map<String, String> get2WeekStartEndDate(DateTime date, {String dateFormat = 'dd-MMM-yyyy'}) {
    var startDate = DateTime(date.year, date.month, date.day - 14);
    var endDate = date;
    return {
      weekStartDayKey: DateFormat(dateFormat).format(startDate),
      weekEndDayKey: DateFormat(dateFormat).format(endDate),
    };
  }

  static Map<String, String> getMonthStartEndDate(DateTime date, {String dateFormat = 'dd-MMM-yyyy'}) {
    var startDate = DateTime(date.year, date.month - 1, date.day);
    var endDate = date;
    return {
      weekStartDayKey: DateFormat(dateFormat).format(startDate),
      weekEndDayKey: DateFormat(dateFormat).format(endDate),
    };
  }

  static Future<void> setDataToFirebaseInstance(Usersessionprofile usersessionprofile) async {
    var userCloud = await StorePreference.getUserCloud();
    FirebaseCrashlytics.instance.setUserIdentifier(usersessionprofile.firstName!);
    FirebaseCrashlytics.instance.setCustomKey("user_id", usersessionprofile.userID!);
    FirebaseCrashlytics.instance.setCustomKey("usercloud", userCloud!);
    FirebaseCrashlytics.instance.setCustomKey("session_id", usersessionprofile.aSessionId!);
  }

  static bool isImageFile(dynamic filepath) {
    var extension = filepath.toString().getFileExtension()?.toLowerCase();
    if (extension != null && (extension.contains("jpeg") || (Platform.isIOS && extension.contains("tif")) || extension.contains("heif") || extension.contains("heic") || extension.contains("png") || extension.contains("jpg") || extension.contains("bmp"))) {
      return true;
    } else {
      return false;
    }
  }

  static dynamic parseEventActionUrl(String url, String command) {
    dynamic decodeJson;
    List<String> data = url.split("js-frame:$command:");
    String jsonString = Uri.decodeFull(data[1]);
    jsonString = jsonString.replaceAll("/", "\\");
    try {
      decodeJson = json.decode(jsonString);
    } on FormatException catch (e) {
      jsonString = jsonString.replaceAll("\\", "/");
      decodeJson = json.decode(jsonString.replaceAllMapped(RegExp(r'/("x|"y|":)'), (match) => '\\${match.group(1)}'));
    }
    return decodeJson; //return map of fields
  }

  static Future<String> getUserDateFormat() async {
    Map<String, dynamic>? json = (await StorePreference.getPrefDataFromUtil(AConstants.keyUserData))?.cast<String, dynamic>();
    if (json == null) return "dd-MMM-yyyy";
    User user = User.fromJson(json);
    Log.d("Date format ${user.usersessionprofile!.dateFormatforLanguage}");
    return user.usersessionprofile!.dateFormatforLanguage ?? defaultDateFormat;
  }

  static String getTemperatureInFahrenheit(String temp) {
    int? t = int.tryParse(temp);
    if (t != null) {
      t = (t * 1.8).ceil();
      t = t + 32;
    }
    return "";
  }

  static final transparentImage = Image.memory(Utility.kTransparentImage, fit: BoxFit.fill);

  static final Uint8List kTransparentImage = Uint8List.fromList(<int>[
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
  ]);

  static Future<void> showNetworkLostBanner(BuildContext context) async {
    bool offline = await StorePreference.isWorkOffline();
    if (!offline) {
      showBannerNotification(context, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.connection_lost, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.reconnect_network_offline, Icons.warning, AColors.warningIconColor);
      // NavigationUtils.mainNavigationKey.currentContext!.showSnackBarAsBanner(
      //     NavigationUtils.mainNavigationKey.currentContext!.toLocale!.connection_lost,
      //     NavigationUtils.mainNavigationKey.currentContext!.toLocale!.reconnect_network_offline,
      //     Icons.warning,
      //     AColors.warningIconColor);
    }
  }

  static showBannerNotification(BuildContext context, String title, String message, IconData bannerIcon, Color bannerIconColor) {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }
    ScaffoldMessengerState messengerState = ScaffoldMessenger.of(context);
    //This line is used to remove current displaying banner
    messengerState.hideCurrentMaterialBanner();
    //This line is used to remove banner after 5 second which will be displayed next.
    _timer = Timer(Duration(seconds: 5), () {
      messengerState.hideCurrentMaterialBanner(reason: MaterialBannerClosedReason.swipe);
    });
    context.showBanner(title, message, bannerIcon, bannerIconColor, timer: _timer);
  }

  static closeBanner() {
    if (NavigationUtils.mainNavigationKey.currentContext != null) NavigationUtils.mainNavigationKey.currentContext!.closeCurrentSnackBar();
  }

  static Future<void> showSyncRemainderBanner(BuildContext context) async {
    bool offline = await StorePreference.isWorkOffline();
    if (!offline) {
      NavigationUtils.mainNavigationKey.currentContext!.showSnackBarAsBanner(NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_sync_remainder, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.lbl_sync_remainder_msg, Icons.warning, AColors.warningIconColor);
    }
  }

  static String getFileExtension(String? fileName) {
    return (fileName ?? "").getExtension()?.replaceFirst(".", "") ?? "";
  }

  static String getValueFromJson(String strJsonData, String key) {
    String value = "";
    try {
      var postDataMap = jsonDecode(strJsonData);
      value = postDataMap[key];
    } catch (e) {
      value = "";
      Log.d("Utils getValueFromJson STD::EXCEPTION key=${key}");
    }
    return value;
  }

  static String offlineFormCreationDate() {
    String dateTime = "";
    try {
      String createdDateOffline = "yyyy-MM-dd HH:mm:ss";
      DateTime now = DateTime.now();
      DateFormat createdDateFormat = DateFormat(createdDateOffline);
      dateTime = createdDateFormat.format(now);
    } catch (e) {
      Log.e("Utility::OfflineFormCreationDate $e");
    }
    return dateTime;
  }

  static Future<void> deleteSyncLogFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/${AConstants.syncLogFilePath}';
    var file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  static Future<String> getSyncLogFileText() async {
    final String filePath = await AppPathHelper().getSyncLogFilePath();
    var file = File(filePath);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
    return '';
  }

  static String getFileSizeWithMetaData({required int bytes, int decimals = 0}) {
    return getFileSizeString(bytes: bytes.toDouble());
  }

  static Future<String?> getApplicationLabel() async {
    var platform = const MethodChannel('flutter.native/getapplabel');
    final String appLabel = await platform.invokeMethod('getapplabel');
    return appLabel;
  }

  static int getPreviousDaysTimeStamp({required int days}) {
    return DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
  }

  static int getTimeStampFromDate(String date, String dateFormat) {
    try {
      dateFormat = (!dateFormat.contains("HH")) ? "$dateFormat HH:mm:ss" : dateFormat;
      return DateFormat(dateFormat).parse(date).millisecondsSinceEpoch;
    } catch (e) {
      Log.e("Utils:getTimeStampFromDate ${e.toString()}");
    }
    return 0;
  }

  static int getTotalSizeOfLocation(Map<String, List<Map<String, DownloadSizeVo>>> downloadItems) {
    int totalDownloadSize = 0;
    downloadItems.forEach((key, value) {
      value.forEach((element) {
        element.forEach((key, value) {
          totalDownloadSize += int.parse(value.totalSize.toString());
        });
      });
    });

    return totalDownloadSize;
  }

  static double getFontScale(context) {
    return MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.3);
  }

  static int getTotalSizeOfMetaData(int totalLocationCount) {
    int totalMetaDataSize = 0;
    totalMetaDataSize = totalLocationCount * 500;
    return totalMetaDataSize;
  }

  static List<TextSpan> getTextSpans(String displayText, String boldTextFromSearch) {
    List<TextSpan> textSpans = [];

    int index = displayText.toLowerCase().indexOf(boldTextFromSearch.toLowerCase());
    if (index >= 0) {
      if (index > 0) {
        String regularText = displayText.substring(0, index);
        textSpans.add(TextSpan(
            text: regularText,
            style: TextStyle(
              fontSize: 15,
              overflow: TextOverflow.ellipsis,
              color: AColors.textColor,
            )));
      }
      String boldTextToView = displayText.substring(index, index + boldTextFromSearch.length);
      textSpans.add(TextSpan(
        text: boldTextToView,
        style: TextStyle(fontWeight: AFontWight.bold, fontSize: 15, color: AColors.textColor),
      ));

      if (index + boldTextToView.length < displayText.length) {
        String remainingText = displayText.substring(index + boldTextToView.length);
        textSpans.add(TextSpan(
            text: remainingText,
            style: TextStyle(
              fontSize: 15,
              overflow: TextOverflow.ellipsis,
              color: AColors.textColor,
            )));
      }
    } else {
      textSpans.add(TextSpan(text: displayText));
    }

    return textSpans;
  }
  static Future<String?> getPDFTronLicenseKey() async {
    // var stringValue = await PreferenceUtils.getString(AConstants.keyAppConfig);
    AppConfig appConfig = di.getIt<AppConfig>();
    return appConfig.syncPropertyDetails?.pdftronAndroidIosKey;
  }
  static showQRAlertDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        contentPadding: const EdgeInsets.all(20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              alignment: Alignment.center,
              child: Image(
                height: 110,
                image: AssetImage(AImageConstants.alertHeader),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Column(
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_location_unavailable_error,
                  textAlign: TextAlign.center,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: AColors.textColor,
                ),
                const SizedBox(
                  height: 5.0,
                ),
                NormalTextWidget(
                  msg,
                  textAlign: TextAlign.center,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: AColors.textColor,
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            AElevatedButtonWidget(
                key: const Key('dialog_close_btn'),
                btnLabel: context.toLocale!.lbl_btn_cancel,
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                btnLabelClr: AColors.white,
                btnBackgroundClr: AColors.userOnlineColor,
                borderRadius: 5.0,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
    );
  }

  static String getLogFileFolderID(BuildEnvironment environment) {
    switch (environment) {
      case BuildEnvironment.live:
        return '106102071';
      case  BuildEnvironment.qa:
        return '106102080';
      case  BuildEnvironment.development:
        return  '106102101';
      case  BuildEnvironment.staging:
        return  '106102115';
      default:
        return '106102080';
    }
  }
}