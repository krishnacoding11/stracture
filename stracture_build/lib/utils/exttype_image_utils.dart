import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';

enum FileType { image, audio, video, code, powerpoint, word, zip, excel, pdf, text }

class TypeImageUtility{
  static Map<FileType,Color> imageTypeColor = {
    FileType.image : "#008299".toColor(),
    FileType.audio : "#ff8040".toColor(),
    FileType.video : "#3374ec".toColor(),
    FileType.code : "#1f7246".toColor(),
    FileType.powerpoint : "#d04626".toColor(),
    FileType.word : "#2a5699".toColor(),
    FileType.zip : "#b047a0".toColor(),
    FileType.excel : "#1f7246".toColor(),
    FileType.pdf : "#e91f00".toColor(),
    FileType.text : "#0eabd1".toColor(),
  };

  static Map<FileType,List<String>> extTypeMap = {
    FileType.image : ["jpeg", "jpg", "gif", "png", "bmp", "ppm", "pgm", "pbm", "pnm", "webp", "bpg", "ico", "img", "pgf", "xisf", "wmf", "emf", "vml", "xps", "dwg","tiff"],
    FileType.audio : ["aa", "aac", "aax", "act", "aiff", "amr", "ape", "au", "awb", "dct", "dss", "dvf", "flac", "gsm", "ikla", "ivs", "m4a", "m4b", "mmf", "mp3", "mpc", "msv", "ogg", "opus", "ra,", "raw", "sln", "tta", "vox", "wav", "wma", "wv", "8sv", "caf", "opus"],
    FileType.video : ["webm", "mkv", "flv", "vob", "ogv", "ogg", "drc", "mng", "mng", "avi", "mov", "qt", "rm", "yuv", "rmvb", "asf", "amv", "mp4", "m4p", "m4v", "mpg", "mp2", "mpeg", "mpe", "mpv", "m2v", "svi", "3gp", "3g2", "mxf", "roq", "nsv", "f4v", "f4p", "f4a", "f4b"],
    FileType.code : ["asp", "jsp", "js", "xml", "bat", "cmd", "class", "cpp", "def", "dll", "dtd", "exe", "font", "html", "htm", "java", "css", "ts", "json"],
    FileType.powerpoint : ["ppt", "pot", "pps", "pptx", "pptm", "potx", "potm", "ppam", "ppsx", "ppsm", "sldx", "sldm"],
    FileType.word : ["doc", "dot", "wbk", "docx", "docm", "dotx", "dotm", "docb", "docx"],
    FileType.zip : ["zip", "lib", "jar", "war", "ear", "iso", "rar", "7z"],
    FileType.excel : ["xls", "xlsm", "xlt", "xlm", "xltm", "xltx", "xlsx", "xlsb", "xla", "xlam", "xll", "xlw", "csv"],
    FileType.pdf : ["pdf"],
    FileType.text : ["txt"],
  };

  static Map<FileType,String> imagePath = {
    FileType.image : AImageConstants.fTypeImage,
    FileType.audio : AImageConstants.fTypeAudio,
    FileType.video : AImageConstants.fTypeVideo,
    FileType.code : AImageConstants.fTypeCode,
    FileType.powerpoint : AImageConstants.fTypePowerPoint,
    FileType.word : AImageConstants.fTypeWord,
    FileType.zip : AImageConstants.fTypeZip,
    FileType.excel : AImageConstants.fTypeExcel,
    FileType.pdf : AImageConstants.fTypePdf,
    FileType.text : AImageConstants.fTypeText,
  };

  static bool isThumbnailTypeImage (String ext){
    if(ext.isNotEmpty) {
      return extTypeMap[FileType.image]?.contains(ext) == true
          || extTypeMap[FileType.pdf]?.contains(ext) == true ? true : false;
    }
    return false;
  }

  static FileType? getFileType (String ext){
    FileType? type;
    if(ext.isNotEmpty) {
      extTypeMap.forEach((key, value) {
        if (value.contains(ext) == true) {
          type = key;
        }
      });
    }
    return type;
  }

  static Widget getImage(String ext, {SizedBox rect = const SizedBox(height: 20,width: 20)}){
    return getFileType(ext) == null ?
    Image.asset(
      key: Key("ext null"),
      alignment: Alignment.bottomRight,
      height: rect.height,
      width: rect.width,
      imagePath[FileType.text]!,
      color: imageTypeColor[FileType.text],
    ) :
    Image.asset(
      key: Key("ext exists"),
      alignment: Alignment.bottomRight,
      height: rect.height,
      width: rect.width,
      imagePath[getFileType(ext)]!,
      color: imageTypeColor[getFileType(ext)],
    );
  }
}