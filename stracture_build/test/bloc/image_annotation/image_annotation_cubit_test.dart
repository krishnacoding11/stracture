import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/image_annotation/image_annotation_cubit.dart';
import 'package:field/bloc/image_annotation/image_annotation_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);

  late ImageAnnotationCubit imageAnnotationCubit;
  var dummyPath = fixtureFile("temp_img_annotation.png");
  List<dynamic> imgPath = [
    PlatformFile(
        path: dummyPath,
        name: "temp_img_annotation.png",
        bytes: null,
        readStream: null,
        size: 408906),
  ];

  setUp(() {
    imageAnnotationCubit = ImageAnnotationCubit();
  });

  group("Image annotation cubit", () {
    test("Initial state", () {
      expect(imageAnnotationCubit.state, isA<FlowState>());
    });

    blocTest<ImageAnnotationCubit, FlowState>(
        "Init data State",
        build: () {
          return imageAnnotationCubit;
        },
        act: (c) async {
          c.initImagepathData(imgPath);
        },
        expect: () => [isA<AddAttachmentState>()]
    );

    blocTest<ImageAnnotationCubit, FlowState>(
        "Update selected index",
        build: () {
          return imageAnnotationCubit;
        },
        act: (c) async {
          c.updateSelected(0);
        },
        expect: () => [isA<ContentState>()]
    );

    blocTest<ImageAnnotationCubit, FlowState>(
        "Remove selected data",
        build: () {
          return imageAnnotationCubit;
        },
        act: (c) async {
          c.initImagepathData(imgPath);
          c.removeData(0);
        },
        expect: () => [isA<AddAttachmentState>(),isA<ContentState>()]
    );
  });
}
