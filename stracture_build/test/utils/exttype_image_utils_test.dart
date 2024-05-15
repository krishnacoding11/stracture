import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/exttype_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isThumbnailTypeImage', () {
    bool isExtExists = TypeImageUtility.isThumbnailTypeImage("tiff");
    expect(true, isExtExists);
  });
  test('getFileType', () {
    FileType? fileType = TypeImageUtility.getFileType("tiff");
    expect(true, fileType == FileType.image);
  });
  test('getImage', () {
    Widget widgetType = TypeImageUtility.getImage("tiff");
    expect(widgetType.key == Key("ext exists") ,true);
  });
  test('getImage null', () {
    Widget widgetType = TypeImageUtility.getImage("abc");
    expect(widgetType.key == Key("ext null"),true);
  });
}