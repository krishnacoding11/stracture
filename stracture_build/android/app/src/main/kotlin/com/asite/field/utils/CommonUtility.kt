package com.asite.field.utils

import android.text.TextUtils
import android.webkit.MimeTypeMap
import java.io.File

class CommonUtility {
    companion object {
        fun getMimeType(filePath: String?): String? {
            var type: String? = ""
            if (filePath == null || filePath.length == 0) {
                type = ""
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("kml")) {
                type = "application/vnd.google-earth.kml+xml"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("PNG")) {
                type = "image/png"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mp3")) {
                type = "audio/mp3"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("m4a")) {
                type = "audio/m4a"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("3gp")) {
                type = "audio/3gp"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("aa")) {
                type = "audio/aa"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("aac")) {
                type = "audio/aac"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("aax")) {
                type = "audio/aax"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("act")) {
                type = "audio/act"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("aiff")) {
                type = "audio/aiff"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("amr")) {
                type = "audio/amr"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("ape")) {
                type = "audio/ape"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("au")) {
                type = "audio/au"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("awb")) {
                type = "audio/awb"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("dct")) {
                type = "audio/dct"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("dss")) {
                type = "audio/dss"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("dvf")) {
                type = "audio/dvf"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("flac")) {
                type = "audio/flac"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("gsm")) {
                type = "audio/gsm"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("iklax")) {
                type = "audio/iklax"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("ivs")) {
                type = "audio/ivs"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("m4b")) {
                type = "audio/m4b"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("m4p")) {
                type = "audio/m4p"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mmf")) {
                type = "audio/mmf"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mpc")) {
                type = "audio/mpc"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("msv")) {
                type = "audio/msv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("wav")) {
                type = "audio/wav"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("raw")) {
                type = "audio/raw"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mp4")) {
                type = "video/mp4"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mkv")) {
                type = "video/mkv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("flv")) {
                type = "video/flv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("vob")) {
                type = "video/vob"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("ogg")) {
                type = "video/ogg"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("ogv")) {
                type = "video/ogv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("drc")) {
                type = "video/drc"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("avi")) {
                type = "video/avi"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mov")) {
                type = "video/mov"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("qt")) {
                type = "video/qt"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("wmv")) {
                type = "video/wmv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("yuv")) {
                type = "video/yuv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("rm")) {
                type = "video/rm"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("rmvb")) {
                type = "video/rmvb"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("asf")) {
                type = "video/asf"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("amv")) {
                type = "video/amv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("m4p")) {
                type = "video/m4p"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("m4v")) {
                type = "video/m4v"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mpg")) {
                type = "video/mpg"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mp2")) {
                type = "video/mp2"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mpeg")) {
                type = "video/mpeg"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mpe")) {
                type = "video/mpe"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mpv")) {
                type = "video/mpv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("m2v")) {
                type = "video/m2v"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("m4v")) {
                type = "video/m4v"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("svi")) {
                type = "video/svi"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("3g2")) {
                type = "video/3g2"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("mxf")) {
                type = "video/mxf"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("roq")) {
                type = "video/roq"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("nsv")) {
                type = "video/nsv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("flv")) {
                type = "video/flv"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("f4v")) {
                type = "video/f4v"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("f4p")) {
                type = "video/f4p"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("f4a")) {
                type = "video/f4a"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("f4b")) {
                type = "video/f4b"
            } else if (filePath.substring(filePath.lastIndexOf(".")).contains("pdf")) {
                type = "application/pdf"
            } else {
                try {
                    var extension = MimeTypeMap.getFileExtensionFromUrl(filePath)
                    if (TextUtils.isEmpty(extension)) {
                        extension = File(filePath).extension
                    }
                    type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
                    if (type == null) {
                        type = ""
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            return type
        }
    }
}