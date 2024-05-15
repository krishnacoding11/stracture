import 'package:camera/camera.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:native_exif/native_exif.dart';

import '../../utils/store_preference.dart';
import 'image_annotation_state.dart';

class ImageAnnotationCubit extends BaseCubit {
  int _activePage = 0;
  List<AnnotatedImageClass> imagePathList = [];
  List<String> docPathList = [];
  bool attachmentClicked=false;

  ImageAnnotationCubit() : super(FlowState());

  int get getActivePage => _activePage;

  initImagepathData(List<dynamic> imagePaths) {
    for (var i = 0; i < imagePaths.length; i += 1) {
      dynamic filePath = imagePaths[i];
      if (filePath is PlatformFile || filePath is XFile) {
        if (Utility.isImageFile(filePath.path!)) {
          imagePathList.add(AnnotatedImageClass(filePath.path!,
              time: DateTime.now().millisecondsSinceEpoch.toString()));
        } else {
          docPathList.add(filePath.path!);
        }
      } else {
        docPathList.add(filePath.path);
      }
    }
    emitState((AddAttachmentState(time: DateTime.now().millisecondsSinceEpoch.toString())));
  }

  void updateSelected(int activePage) {
    Log.e("updateSelected ===>$_activePage");
    _activePage = activePage;
    emitState((ContentState(time: DateTime.now().millisecondsSinceEpoch.toString())));
  }

  void removeData(int index) {
    imagePathList.removeAt(index);
    if (index >= imagePathList.length - 1) {
      updateSelected(imagePathList.length - 1);
    } else {
      emitState((ContentState(time: DateTime.now().millisecondsSinceEpoch.toString())));
    }
  }

  void addAttachmentClickEvent(){
    attachmentClicked = true;
    emitState((ContentState(time: DateTime.now().millisecondsSinceEpoch.toString())));
  }

  setImageData(int index, PainterController? controller) {
    String imgPath = imagePathList[index].imgPath;
    var renderBox =
        controller?.painterKey.currentContext?.findRenderObject() as RenderBox?;
    var imgDrawables = controller?.value.drawables;
    imagePathList[index].imgPath = imgPath;
    imagePathList[index].renderBox = renderBox;
    imagePathList[index].imgDrawables = imgDrawables;
  }

  Future<void> copyEXIfData(
      {String? originalPath, String? compressedImagePath}) async {
    String isGeoTagEnabled = await StorePreference.getProjectGeoTagSettings();
    if(isGeoTagEnabled == "true") {
      if (originalPath != null) {
        try {
          Exif? exif = await Exif.fromPath(originalPath);
          var attributes = await exif.getAttributes();
          if (attributes != null) {
            Exif? newExif = await Exif.fromPath(compressedImagePath!);
            var latLong = await exif.getLatLong();
            if (latLong != null) {
              final latitude = latLong?.latitude;
              final longitude = latLong?.longitude;
              final altitude = attributes['GPSAltitude'];
              final dateTimeOriginal = attributes['DateTime'];

              await newExif.writeAttributes({
                'GPSLatitude': '$latitude',
                'GPSLongitude': '$longitude',
                'GPSAltitude': '$altitude',
                'DateTimeOriginal': '$dateTimeOriginal',
              });
              newExif.close();
            }
          }
          exif.close();
        } catch (e) {
        }
      }
    }
  }
}

class AnnotatedImageClass {
  String imgPath;
  dynamic time;
  Size? size;
  RenderBox? renderBox;
  List<Drawable>? imgDrawables = [];

  AnnotatedImageClass(this.imgPath,
      {this.renderBox, this.imgDrawables, this.time, this.size});

  List<Drawable>? get drawables => imgDrawables;
}
