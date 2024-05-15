import 'dart:async';

import 'package:asite_plugins/asite_plugins.dart';
import 'package:asite_plugins/asite_plugins_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/custom_banner/aBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';
import 'field_enums.dart';
import 'navigation_utils.dart';
import 'package:path/path.dart' as path;

bool isBannerShowing = false;
extension StringExtension on String? {
  toColor() {
    var hexColor = this!.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }

  String? removeWhitespace() {
    return this?.replaceAll(" ", "");
  }

  bool isNullOrEmpty() => this == null || this == '' || this == "null";

  bool isNullEmptyOrFalse() => isNullOrEmpty() || this?.toLowerCase() == "false";

  bool isNullEmptyZeroOrFalse() => isNullEmptyOrFalse() || this == "0";

  plainValue() {
    if (isNullOrEmpty()) {
      return "";
    } else if (this!.contains("\$\$")) {
      return this!.substring(0, this!.indexOf("\$\$"));
    } else {
      return this;
    }
  }

  bool isHashValue() {
    return !isNullOrEmpty() && this!.contains("\$\$");
  }

  Future<String> decrypt() async {
    var plugin = AsitePlugins();
    return await plugin.decrypt(this, EncryptionAlgorithm.ecb);
  }

  Future<String> encrypt() async {
    var plugin = AsitePlugins();
    return await plugin.encrypt(this, EncryptionAlgorithm.ecb);
  }

  String? getFileExtension() {
    try {
      return ".${this!.split('.').last.toString()}";
    } catch (e) {
      return null;
    }
  }
  String getExtension() {
    return path.extension(this ?? "");
  }

  String getFileNameWithoutExtension() {
    return path.basenameWithoutExtension(this ?? "");
  }

  String toWorkPackage() {
    /// on offline mode get work package data in 66644#Computer format
    String workPackage = this.toString();
    if (this == null || this == 'null') {
      return "";
    }
    if (workPackage.contains("#")) {
      return workPackage.split("#")[1];
    }
    return workPackage;
  }

  String toDateFormat({String format = "dd-MMM-yyyy"}) {
    String date = this.toString();
    try {
      return DateFormat(format).format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  /// Text widget doesn't ellipsis correctly so,replace space with Zero Width Space char.
  /// String replaceAll solution breaks when users are using emojis. That's why I use Characters class.
  String? get overflow => isNullOrEmpty() ? this : Characters(this!).replaceAll(Characters(''), Characters('\u{200B}')).toString();

  // Check filename is valid or not
  Map<String, dynamic> isValidFileName() {
    String fileName = this.toString();
    if (fileName.length > 200) {
      return {"valid": false, "validMsg": NavigationUtils.mainNavigationKey.currentContext?.toLocale?.filename_allow_max_200_characters_update_proceed ?? ""};
    }

    bool isValidString = true;
    final specialCharacterPattern = RegExp(r'^[^\\/\\\\:*?<>|;%#~\\\"]+$');
    final uniCodePattern = RegExp(r'[\u200B-\u200F\u2028-\u2029\u202A-\u202E\u2060-\u2069\u206A-\u206F\uFEFF]');

    if (!specialCharacterPattern.hasMatch(fileName)) {
      isValidString = false;
    } else if (uniCodePattern.hasMatch(fileName)) {
      isValidString = false;
    } else {
      int charLength = fileName.codeUnits.where((ch) => (ch < 32 || ch == 63)).length;
      if (charLength > 0) {
        isValidString = false;
      }
    }

    return {"valid": isValidString, "validMsg": NavigationUtils.mainNavigationKey.currentContext?.toLocale?.special_character_validation_update_proceed ?? ""};
  }

  // Check valid file type
  Map<String, dynamic> isValidFileType(String fileType) {
    if(fileType.isNullOrEmpty()) {
      return {"valid": true, "validMsg": ""};
    }

    String fileName = this.toString();
    String mimeType = lookupMimeType(fileName) ?? "";
    bool isValid = true;
    String? validationMsg = "";
    //If fileType ends with '/*'
    if (fileType.indexOf('/*') != -1 && (fileType.length - fileType.indexOf('/*') == 2)) {
      isValid = fileType.split('/*')[0] == mimeType.split('/')[0];
    } else {
      isValid = fileType.indexOf(fileName.getFileExtension() ?? "") != -1;
    }
    if (!isValid) {
      validationMsg = NavigationUtils.mainNavigationKey.currentContext?.toLocale?.supported_file_type_only(fileType);
    }

    return {"valid": isValid, "validMsg": validationMsg};
  }
}

// Used for get JSession ID from response headers
extension HeaderExtension on Headers? {
  String? getJSessionId() {
    String? jSessionId = "";
    outerloop:
    for (var i = 0; i < this!.map.values.toList().length; i++) {
      List<String>? temp = this!.map.values.toList()[i];
      for (var i = 0; i < temp.length; i++) {
        String str = temp[i];
        if (str.contains('JSESSIONID')) {
          str = str.split(';').first;
          str = str.replaceAll('JSESSIONID=', '');
          jSessionId = str;
          break outerloop;
        }
      }
    }
    return jSessionId;
  }
}

extension LocalizedBuildContext on BuildContext {
  AppLocalizations? get toLocale => AppLocalizations.of(this);
}

extension CustomSnackBar on BuildContext {
  void showSnack(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(textAlign: TextAlign.center, text)));
  }

  void closeCurrentSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).hideCurrentMaterialBanner();
  }

  void showSnackWithTimeLimit(String text, bool isClose) {
    if (isClose) {
      ScaffoldMessenger.of(this).clearSnackBars();
    } else {
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        content: Text(textAlign: TextAlign.center, text),
        duration: const Duration(milliseconds: 500),
      ));
    }
  }

  void showBanner(String title, String message, IconData bannerIcon, Color bannerIconColor, {Timer? timer}) {
    var deviceWidth = MediaQuery.of(this).size.width;
    ScaffoldMessenger.of(this).showMaterialBanner(ABanner(
      elevation: 1,
      forceActionsBelow: false,
      backgroundColor: Colors.transparent,
      content: Dismissible(
        direction: DismissDirection.horizontal,
        key: Key("banner"),
        onDismissed: (_) {
          timer?.cancel();
          ScaffoldMessenger.of(this).hideCurrentMaterialBanner(reason: MaterialBannerClosedReason.swipe);
        },
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(5), color: AColors.white),
          //height: 76,
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: AColors.dividerColor,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 5.0,
                            height: 75.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                              color: bannerIconColor,
                            ),
                          ),
                          SizedBox(width: Utility.isTablet ? 20.0 : 10.0),
                          Icon(
                            bannerIcon,
                            size: 24,
                            color: bannerIconColor,
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: Utility.isTablet ? 20.0 : 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(title, style: TextStyle(color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold), textAlign: TextAlign.left,textScaleFactor: MediaQuery.of(this).textScaleFactor.clamp(1.0, deviceWidth < 400 ? 1.1 : Utility.getFontScale(this)),),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(message, softWrap: true, maxLines: 2, textAlign: TextAlign.left, style: TextStyle(color: AColors.textColor, fontSize: 13, fontWeight: AFontWight.regular),textScaleFactor: MediaQuery.of(this).textScaleFactor.clamp(1.0, deviceWidth < 400 ? 1.0 : Utility.getFontScale(this)),),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          color: AColors.userOnlineColor,
          width: 100,
        )
      ],
      // padding: Utility.isTablet? const EdgeInsetsDirectional.fromSTEB(100, 0, 100, 0) :const EdgeInsetsDirectional.all(0),
      padding: const EdgeInsetsDirectional.all(0),
      // leading: Container(),
      // backgroundColor: Colors.transparent,
      leadingPadding: const EdgeInsetsDirectional.all(0),
      onVisible: () {
      },
    ));
  }

  void nCircleShowBanner(String title, String message, IconData bannerIcon, Color bannerIconColor) {
    if (isBannerShowing) {
      return;
    }
    ScaffoldMessenger.of(this).showMaterialBanner(ABanner(
      elevation: 1,
      forceActionsBelow: false,
      backgroundColor: Colors.transparent,
      content: Dismissible(
        direction: DismissDirection.horizontal,
        key: Key("banner"),
        onDismissed: (_) {
          ScaffoldMessenger.of(this).hideCurrentMaterialBanner(reason: MaterialBannerClosedReason.swipe);
        },
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(5), color: AColors.white),
          height: 71,
          child: Column(
            children: [
              Container(
                height: 1,
                color: AColors.dividerColor,
              ),
              Row(
                children: [
                  Container(
                    width: 5.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                      color: bannerIconColor,
                    ),
                  ),
                  SizedBox(width: Utility.isTablet ? 20.0 : 10.0),
                  Icon(
                    bannerIcon,
                    size: 24,
                    color: bannerIconColor,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: Utility.isTablet ? 20.0 : 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title, style: TextStyle(color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold), textAlign: TextAlign.left),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(message, softWrap: true, maxLines: 2, textAlign: TextAlign.left, style: TextStyle(color: AColors.textColor, fontSize: 13, fontWeight: AFontWight.regular)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: [
        Container(
          color: AColors.userOnlineColor,
          width: 100,
        )
      ],
      padding: const EdgeInsetsDirectional.all(0),
      leadingPadding: const EdgeInsetsDirectional.all(0),
      onVisible: () {
        Future.delayed(const Duration(seconds: 2)).then((value) {
          isBannerShowing=false;
          ScaffoldMessenger.of(this).hideCurrentMaterialBanner();
        });
      },
    ));
    isBannerShowing=true;
  }

  void showSnackBarAsBanner(String title, String message, IconData bannerIcon, Color bannerIconColor) {
    showBanner(title, message, bannerIcon, bannerIconColor);
  }

  void shownCircleSnackBarAsBanner(String title, String message, IconData bannerIcon, Color bannerIconColor) {
    NavigationUtils.mainNavigationKey.currentContext!.nCircleShowBanner(title, message, bannerIcon, bannerIconColor);
  }

  void shownCircleSnackBar(String title, String message, IconData bannerIcon, Color bannerIconColor) {
    nCircleShowBanner(title, message, bannerIcon, bannerIconColor);
  }

  void showSnackBarAsBannerDismissible(String title, String message, IconData bannerIcon, Color bannerIconColor, {bool? isCloseManually, Function? onTap}) {
    var paddingForSnack = Utility.isTablet ? 150.0 : 10.0;
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Container(
        decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(5), color: AColors.white),
        height: 70.0,
        child: Row(
          children: [
            Container(
              width: 5.0,
              height: 70.0,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                color: bannerIconColor,
              ),
            ),
            SizedBox(width: Utility.isTablet ? 20.0 : 10.0),
            Icon(
              bannerIcon,
              size: 24,
              color: bannerIconColor,
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: Utility.isTablet ? 20.0 : 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: TextStyle(color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold), textAlign: TextAlign.left),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(message, softWrap: true, maxLines: 2, textAlign: TextAlign.left, style: TextStyle(color: AColors.textColor, fontSize: 13, fontWeight: AFontWight.regular)),
                  ],
                ),
              ),
            ),
            isCloseManually!
                ? InkWell(
                    onTap: () => onTap!(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Icon(
                        Icons.clear,
                        color: AColors.iconGreyColor,
                      ),
                    ))
                : Container()
          ],
        ),
      ),
      duration: const Duration(seconds: 50),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white70,
      padding: const EdgeInsets.all(0),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(this).size.height - 155,
        left: paddingForSnack,
        right: paddingForSnack,
      ),
    ));
  }

  void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(<K, List<E>>{}, (Map<K, List<E>> map, E element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

extension TemplateTypeExtension on int? {
  bool get isXSN => ETemplateType.fromNumber(this ?? 1) == ETemplateType.xsn;

  bool get isHTML => ETemplateType.fromNumber(this ?? 1) == ETemplateType.html;

  bool get isOne => (this != null && this == 1);
}

extension DurationExtensions on Duration {
  /// Converts the duration into a readable string
  /// 05:15
  String toHoursMinutes() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes";
  }

  /// Converts the duration into a readable string
  /// 05:15:35
  String toHoursMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _toTwoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}

extension DeviceSize on BuildContext {
  double height() {
    return MediaQuery.of(this).size.height;
  }

  double width() {
    return MediaQuery.of(this).size.width;
  }

  Size getDeviceSize() {
    return MediaQuery.of(this).size;
  }

  Orientation orientation() {
    return MediaQuery.of(this).orientation;
  }
}
