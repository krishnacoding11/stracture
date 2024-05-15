import 'dart:convert';
import 'dart:io';

import 'package:field/data_source/forms/view_form_local_data_source.dart';
import 'package:field/enums.dart';
import 'package:field/presentation/screen/webview/asite_file_webview.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../analytics/event_analytics.dart';
import '../data/model/form_vo.dart';
import '../data_source/forms/create_form_local_data_source.dart';
import '../presentation/managers/color_manager.dart';
import '../presentation/managers/image_constant.dart';
import '../presentation/screen/webview/asite_formwebview.dart';
import '../presentation/screen/webview/asite_webview.dart';
import 'app_path_helper.dart';
import 'constants.dart';
import 'field_enums.dart';
import 'navigation_utils.dart';

class FileFormUtility {
  /// It is been used for Web View of file and form both.
  static showFileFormViewDialog(BuildContext context, {required String frmViewUrl, required Map<String, dynamic> data,  Color? color,num? associationType, Function? callback}) async {
    if (Utility.isTablet) {
      showDialog(
          context: context,
          builder: (context) {
            var height = MediaQuery.of(context).size.height * 0.85;
            var width = MediaQuery.of(context).size.width * 0.87;
            return Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: SizedBox(
                width: width,
                height: height,
                child: associationType != null && associationType == AssociationTypeEnum.file.value
                    ? AsiteFileWebView(url: frmViewUrl, data: data)
                    : AsiteFormWebView(url: frmViewUrl, headerIconColor: color, data: data),
              ),
            );
          }).then((value) {
        if (value != null) {
          if (callback != null) {
            callback(value);
          }
          //_planCubit.refreshPinsAndHighLight(value);
        }
      });
    } else {
      await NavigationUtils.mainPushWithResult(
        context,
        MaterialPageRoute(
          builder: (context) =>associationType == AssociationTypeEnum.file.value
              ? AsiteFileWebView(url: frmViewUrl, data: data)
              : AsiteFormWebView(
            url: frmViewUrl,
            headerIconColor: color,
            data: data,
          ),
        ),
      )?.then((value) {
        if (value != null) {
          //_planCubit.refreshPinsAndHighLight(value);
          if (callback != null) {
            callback(value);
          }
        }
      });
    }
  }

  static showFormCreateDialog(BuildContext context,
      {required String frmViewUrl, required Map<String, dynamic> data, String? title, Function? function, FireBaseFromScreen screenName = FireBaseFromScreen.quality}) async {
    var url = '';
    try{
       url = Uri.decodeFull(frmViewUrl);
    }catch (e){
      url = frmViewUrl;
    }
    if (Utility.isTablet) {
      showDialog(
          context: context,
          builder: (context) {
            var height = MediaQuery.of(context).size.height * 0.85;
            var width = MediaQuery.of(context).size.width * 0.87;
            return Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: SizedBox(
                width: width,
                height: height,
                child: AsiteWebView(
                  url: url,
                  title: title ?? "",
                  data: data,
                  isAppbarRequired: true,
                ),
              ),
            );
          }).then((value) {
        if (value != null) {
          if (function != null) {
            function(value,data);
          }
          //_planCubit.refreshPinsAndHighLight(value);
        }
      });
    } else {
      await NavigationUtils.mainPushWithResult(
        context,
        MaterialPageRoute(
          builder: (context) => AsiteWebView(
            url: url,
            title: title ?? "",
            data: data,
            isAppbarRequired: true,
          ),
        ),
      )?.then((value) {
        if (value != null) {
          //_planCubit.refreshPinsAndHighLight(value);
          if (function != null) {
            function(value, data);
          }
        }
      });
    }
  }

  static String getCreatedDate(SiteForm item) {
    return item.formCreationDate?.split('#').first ?? "";
  }

  static String getDueDate(SiteForm item) {
    return item.responseRequestBy?.split('#').first ?? "";
  }

  static String getStatusUpdateDate(SiteForm item) {
    return item.statusUpdateDate?.split('#').first ?? "";
  }

  static String getFormIconName(SiteForm item) {
    return (item.appBuilderId != null && AConstants.siteAppBuilderIds.contains(item.appBuilderId?.toLowerCase())) ? AImageConstants.accountHardHat : AImageConstants.otherTask;
  }

  static Color getStatusColor(SiteForm item) {
    if (item.statusRecordStyle != null) {
      return (item.statusRecordStyle['backgroundColor'] as String).toColor();
    }
    return AColors.iconGreyColor;
  }

  static String getLocationPath(SiteForm item, {bool isProjectRequired = false, String pathSpliter = '\\', String pathSeparator = '\\'}) {
    String locationPath = item.locationPath ?? "";
    if (locationPath != "") {
      if (!isProjectRequired) {
        String projectTitle = item.projectName ?? locationPath.split(pathSpliter)[0];
        locationPath = locationPath.replaceFirst("$projectTitle$pathSpliter", "");
      }
      if (pathSpliter != pathSeparator) {
        locationPath = locationPath.replaceAll(pathSpliter, pathSeparator);
      }
    }
    return locationPath;
  }

  static showFormActionViewDialog(BuildContext context,
      {required String frmViewUrl, required Map<String, dynamic> data, required Color? color}) async {
    dynamic result;
    if (Utility.isTablet) {
      await showDialog(
          context: context,
          builder: (context) {
            var height = MediaQuery.of(context).size.height * 0.85;
            var width = MediaQuery.of(context).size.width * 0.87;
            return Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: SizedBox(
                width: width,
                height: height,
                child: AsiteFormWebView(
                  url: frmViewUrl,
                  headerIconColor: color,
                  data: data,
                ),
              ),
            );
          }).then((value) {
        if (value != null) {
          result = value;
        }
      });
    } else {
      await NavigationUtils.mainPushWithResult(
        context,
        MaterialPageRoute(
          builder: (context) => AsiteFormWebView(
            url: frmViewUrl,
            headerIconColor: color,
            data: data,
          ),
        ),
      )?.then((value) {
        if (value != null) {
          result = value;
        }
      });
    }
    return result;
  }

  static Future<String> getOfflineCreateFormPath(Map<String, dynamic> requestParam) async {
    requestParam['formCreationDate'] = Utility.offlineFormCreationDate();
    CreateFormLocalDataSource createFormLocalDataSource = CreateFormLocalDataSource();
    await createFormLocalDataSource.init();
    String? createFormHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.create, requestParam);
    if (!createFormHtmlResponse.isNullOrEmpty()) {
      String url = "${await AppPathHelper().getAssetHTML5FormZipPath()}/createFormHTML.html";
      File file = File(url);
      // file.writeAsStringSync(createFormHtmlResponse!);
      file.writeAsBytesSync(utf8.encode(createFormHtmlResponse!));
      return "file://${file.path}";
    }

    return "";
  }

  static Future<String> getOfflineViewFormPath(Map<String, dynamic> requestParam) async {
    String formId = requestParam['formId'].toString().plainValue();
    ViewFormLocalDataSource viewFormLocalDataSource = ViewFormLocalDataSource();
    String offlineFormData = await viewFormLocalDataSource.getOfflineFormViewHtml(requestParam);
    if (!offlineFormData.isNullOrEmpty()) {
      String fileName = "view_$formId.html";
      String filePath = await AppPathHelper().getAssetHTML5FormZipPath();

      filePath = "$filePath/$fileName";
      File file = File(filePath);
      file.writeAsBytesSync(utf8.encode(offlineFormData));
      return "file://${file.path}";
    }
    return "";
  }

  static String getExpectedFinishedDate(String dateFormat, String startDate, int? days) {
      DateFormat dtFrmt = DateFormat(dateFormat);
      DateTime dateTime = dtFrmt.parse(startDate);
      dateTime = dateTime.add(Duration(days: days?? 0));
     return dtFrmt.format(dateTime);
  }
}
