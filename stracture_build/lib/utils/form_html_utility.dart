

import 'dart:io';

import 'package:field/logger/logger.dart';

import 'file_utils.dart';

class FormHtmlUtility {
  static final FormHtmlUtility _instance = FormHtmlUtility._internal();

  FormHtmlUtility._internal();

  factory FormHtmlUtility() {
    return _instance;
  }

  String replacePathInData(String fileContent, String searchToken, String replaceToken, String delimiter) {
    if (fileContent.isNotEmpty) {
      int found = fileContent.indexOf(searchToken);
      if (found != -1) {
        int found1 = fileContent.lastIndexOf(delimiter, found);
        int found2 = fileContent.indexOf(delimiter, found);
        fileContent = fileContent.replaceRange(found1 + 1, found2 - 1, replaceToken);
      }
    }
    return fileContent;
  }

  String prependStringInContentData(String strContentData, String strFindString, String strBeginString, String strNewString) {
    String strContentDataNew = strContentData;
    int posLast = 0;
    while ((posLast = strContentDataNew.indexOf(strFindString, posLast))!=-1) {
      if (posLast != -1) {
        int posFirst = strContentDataNew.lastIndexOf(strBeginString, posLast);
        strContentDataNew = strContentDataNew.replaceRange(posFirst + strBeginString.length, posLast, strNewString);
        posLast = posFirst + strNewString.length + strBeginString.length + strFindString.length;
      }
    }
    return strContentDataNew;
  }

  bool updateHTML5FormTemplatePath({required String zipFilePath, required String templateDirPath, required String appDirPath,required String basePath}) {
    /*List<String> listOfCSSFile = [
      "form-builder-bootstrap.css","newui/vendor/font-awesome.min.css","htmlform/textAngular.css",
      "htmlform/spectrum.css","htmlform/defect.manager.css"
    ];*/
    try {
      final fileList = ZipUtility().getFileList(strZipFilePath: zipFilePath);
      List<String> htmlFiles = [], otherFiles = [];
      for (var fileName in fileList) {
        (fileName.endsWith(".html"))
            ? htmlFiles.add(fileName)
            : otherFiles.add(fileName);
      }

      String relativeTemplateDirPath = templateDirPath.replaceAll(basePath, "./../..");
      String relativeAppDirPath = appDirPath.replaceAll(basePath, "./../..");
      for (var htmlFileName in htmlFiles) {
        String oriFilePath = "$templateDirPath/$htmlFileName";
        File fileTmp = File(oriFilePath);
        if (fileTmp.existsSync()) {
          String fileContents = fileTmp.readAsStringSync();
          for (var otherFileName in otherFiles) {
            String oriPathToReplace = "$relativeTemplateDirPath/$otherFileName";
            String searchStringToken = "/$otherFileName";
            if (otherFileName.contains("template_language")) {
              oriPathToReplace = "json!$oriPathToReplace!ingnoreBase";
            }
            fileContents = replacePathInData(fileContents, searchStringToken, oriPathToReplace, "\"");
          }
          String strCommonCSSFile = "/css/htmlform/common.css";
          int cssIdx = fileContents.indexOf(strCommonCSSFile);
          if (cssIdx != -1) {
            int found1 = fileContents.lastIndexOf("\"", cssIdx);
            int found2 = fileContents.indexOf("\"", cssIdx);
            fileContents = fileContents.replaceRange(found1 + 1, found2 - 1, "$relativeAppDirPath$strCommonCSSFile");
          } else {
            String strLinkTagForCss = "<link type=\"text/css\" rel=\"stylesheet\" href=\"$relativeAppDirPath$strCommonCSSFile\">";
            int strTagFound = fileContents.indexOf("<link type=\"text/css\"", 0);
            if (strTagFound != -1) {
              fileContents = fileContents.replaceRange(strTagFound, strTagFound, strLinkTagForCss);
            }
          }
          fileContents = fileContents.replaceAll("\"/css/", "\"$relativeAppDirPath/css/");
          fileContents = fileContents.replaceAll("th:value", "value");
          fileContents = fileContents.replaceAll(" th:", " ");
          String tempStringToReplace = "<script type=\"text/javascript\">var path = '$relativeTemplateDirPath/';</script>";
          fileContents = fileContents.replaceAll("<script inline=\"javascript\">/*<![CDATA[*/var path = /*[[\${staticContentPath}]]*/;/*]]>*/</script>", tempStringToReplace);
          fileContents = fileContents.replaceAll("/*<![CDATA[*/var path = /*[[\${staticContentPath}]]*/;/*]]>*/", "var path = '$relativeTemplateDirPath/';");
          fileContents = fileContents.replaceAll("/*[[\${staticContentPath}]]*/", "'$relativeTemplateDirPath/'");
          fileContents = fileContents.replaceAll("\${staticContentPath} + 'template.css'", "$relativeTemplateDirPath/template.css");
          fileContents = fileContents.replaceAll("\${staticContentPath} + 'template.js'", "$relativeTemplateDirPath/template.js");
          fileContents = fileContents.replaceAll("\${staticContentPath_offline}+", "$relativeTemplateDirPath/");
          fileContents = fileContents.replaceAll("<!-----", "");
          fileContents = fileContents.replaceAll("----->", "");
          fileContents = fileContents.replaceAll("<script attr=\"src=","<script src=\"");

          fileTmp.deleteSync();
          fileTmp.createSync(recursive: true);
          fileTmp.writeAsStringSync(fileContents);
        }
      }
      for (var otherFileName in otherFiles) {
        if (otherFileName.endsWith(".js")) {
          String strFilePath = "$templateDirPath/$otherFileName";
          File fileTmp = File(strFilePath);
          if (fileTmp.existsSync()) {
            String fileContents = fileTmp.readAsStringSync();
            fileTmp.deleteSync();
            fileTmp.createSync(recursive: true);
            fileContents = fileContents.replaceAll("\$window._isOffline = false;", "\$window._isOffline = true;");
            fileContents = fileContents.replaceAll("\$window._isOffline=false;", "\$window._isOffline=true;");
            fileTmp.writeAsStringSync(fileContents);
          }
        }
      }
      return true;
    } on Exception catch (e) {
      Log.e("FormHtmlUtility::updateHTML5FormTemplatePath error=$e");
      return false;
    }
  }

  bool updateHTML5AssetFilePath({required String zipFilePath, required String zipDirPath,required String basePath}) {
    bool isSuccess = false;
    try {

      String relativeZipDirPath = zipDirPath.replaceAll(basePath, "./../..");
      Log.d("CHtml5FormUtility::updateHTML5AssetFilePath zipDirPath=$zipDirPath");
      { //offlineViewForm.html
        String fileName = "offlineViewForm.html";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = prependStringInContentData(fileContents, "/images/logo_small.png", "\"", relativeZipDirPath);
          fileContents = prependStringInContentData(fileContents, "/css/", "\"", relativeZipDirPath);
          fileContents = prependStringInContentData(fileContents, "/scripts/", "\"", relativeZipDirPath);
          fileContents = fileContents.replaceAll("(/images/", "($relativeZipDirPath/images/");
          fileContents = fileContents.replaceAll("images/avatar.png", "$relativeZipDirPath/images/avatar.png");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      { //offlineViewFile.html
        String fileName = "offlineViewFile.html";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = prependStringInContentData(fileContents, "/css/", "\"", relativeZipDirPath);
          fileContents = prependStringInContentData(fileContents, "/scripts/", "\"", relativeZipDirPath);
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      { //viewer.bundle.css
        String fileName = "css/viewer.bundle.css";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = fileContents.replaceAll("/css/fonts/", "./fonts/");
          fileContents = fileContents.replaceAll("\"/css/fonts/", "\"./fonts/");
          fileContents = fileContents.replaceAll("(../fonts/", "(./fonts/");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      { //font-awesome.min.css
        String fileName = "css/newui/vendor/font-awesome.min.css";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = fileContents.replaceAll("'/css/fonts/", "'./../../fonts/");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      { //main.js
        String fileName = "scripts/htmlform/main.js";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = fileContents.replaceAll("'/scripts/htmlform'","'./scripts/htmlform'");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      { //main1.js
        String fileName = "scripts/htmlform/main1.js";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = fileContents.replaceAll("'/scripts/htmlform'","'./scripts/htmlform'");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      { //common.css
        String fileName = "css/htmlform/common.css";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = fileContents.replaceAll("\"/images/loading.gif\"","\"$relativeZipDirPath/images/loading.gif\"");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      { //datepicker.js
        String fileName = "scripts/htmlform/components/datepicker.js";
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = fileContents.replaceAll("\"/images/", "\"./images/");
          fileContents = fileContents.replaceAll("/icons", "");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      var fileNameList = [
        "scripts/htmlform/controllers/defect.manager.js",
        "scripts/htmlform/controllers/site.task.js",
        "scripts/htmlform/controllers/wbho.rfi.js",
        "scripts/htmlform/controllers/aus.defect.manager.js",
        "scripts/htmlform/controllers/aldar.site.task.js",
      ];
      for (var fileName in fileNameList) {
        Log.d("CHtml5FormUtility::updateHTML5AssetFilePath strFile=$fileName");
        String filePath = "$zipDirPath/$fileName";
        var curFile = File(filePath);
        if (curFile.existsSync()) {
          String fileContents = curFile.readAsStringSync();
          fileContents = fileContents.replaceAll("\$window._isOffline = false;", "\$window._isOffline = true;");
          fileContents = fileContents.replaceAll("\$window._isOffline=false;", "\$window._isOffline=true;");
          curFile.deleteSync();
          curFile.createSync(recursive: true);
          curFile.writeAsStringSync(fileContents);
        }
      }

      isSuccess = true;
    } on Exception catch (e) {
      Log.e("FormHtmlUtility::updateHTML5AssetFilePath error=$e");
    }
    return isSuccess;
  }

  String getHTMLHiddenFieldAttributeData({required Map<String,dynamic> htmlAttributeMap}) {
    String htmlHiddenFieldData = "";
    htmlAttributeMap.forEach((key, value) {
      htmlHiddenFieldData = "$htmlHiddenFieldData<input type='hidden' name=\"$key\" id=\"$key\" value=\'${value?.toString() ?? ""}\' />";
    });
    return htmlHiddenFieldData;
  }
}