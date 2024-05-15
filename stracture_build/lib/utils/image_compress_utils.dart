import 'package:field/utils/extensions.dart';
import 'package:flutter/services.dart';

import '../logger/logger.dart';

Future<String> compressImageFile(String path, {int maxFileSize = 0, int quality = 0, String? imageType}) async {
  var platform = const MethodChannel('flutter.native/imageCompression');
  try {
    Map map = {
      "imagePath": path
    };
    if (maxFileSize > 0) {
      map["maxFileSize"] = maxFileSize;
    }
    if (quality > 0) {
      map["quality"] = quality;
    }
    if (!imageType.isNullOrEmpty()) {
      map["imageType"] = imageType;
    }
    return await platform.invokeMethod('imageCompression', map);
  } on PlatformException catch (e) {
    Log.e("Compress Image Failed to Invoke: '${e.message}'.");
    return "";
  } catch (e) {
    Log.e("Compress Image Failed to Invoke: '$e'.");
    return "";
  }
}

