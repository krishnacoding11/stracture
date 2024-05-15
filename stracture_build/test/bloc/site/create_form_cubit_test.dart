import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:field/bloc/site/create_form_cubit.dart';

import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class DBServiceMock extends Mock implements DBService {}

class MockCreateFormUseCase extends MockCubit<FlowState> implements CreateFormUseCase {}

class MockAppPathHelper extends MockCubit<FlowState> implements AppPathHelper {
  @override
  Future<String> getTemporaryAttachmentPath({required String fileName, required String projectId}) {
    return Future.value('/data/data/com.asite.field/app_flutter');
  }
}

class MockMultipartFile extends MockCubit<FlowState> implements MultipartFile {}

class FileUtilityMock extends Mock implements FileUtility {
  @override
  Future<void> createFileFromFile(String? orignal, String? path) async {}
}

// getTemporaryAttachmentPath

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  DBServiceMock? mockDb;
  late CreateFormCubit createFormCubit;
  MockCreateFormUseCase mockCreateFormUseCase = MockCreateFormUseCase();
  MockAppPathHelper mockAppPathHelper = MockAppPathHelper();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AConstants.loadProperty();
  FileUtilityMock? mockFileUtility;

  configureCubitDependencies() {
    mockFileUtility = FileUtilityMock();
    mockDb = DBServiceMock();
    di.init(test: true);
    di.getIt.unregister<CreateFormUseCase>();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactory<CreateFormUseCase>(() => mockCreateFormUseCase);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    di.getIt.unregister<FileUtility>();
    di.getIt.registerLazySingleton<FileUtility>(() => mockFileUtility!);
    SharedPreferences.setMockInitialValues({
      "userData": fixture("user_data.json"),
    });
  }

  setUp(() {
    createFormCubit = CreateFormCubit(createFormCubit: mockCreateFormUseCase, appPathHelper: mockAppPathHelper);
    MockMethodChannel().setAsitePluginsMethodChannel();
    mockDb = DBServiceMock();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  });

  group('Create Form Selection Cubit Tests -', () {
    configureCubitDependencies();

    blocTest<CreateFormCubit, FlowState>("uploadAttachment [Success] state.",
        build: () {
          return createFormCubit;
        },
        act: (c) {
          when(() => mockCreateFormUseCase.uploadAttachment({'projectID': '123456'})).thenAnswer((invocation) => Future.value(SUCCESS(jsonEncode({}), null, 200, requestData: NetworkRequestBody.json({'projectID': '123456'}))));
          c.uploadAttachment('projectID', '/data/data/com.asite.field/app_flutter/database/', 'folderID', 'appTypeID');
        },
        expect: () => [isA<LoadingState>()]);

    blocTest<CreateFormCubit, FlowState>("uploadInlineAttachment [Success] state.",
        build: () {
          return createFormCubit;
        },
        act: (c) {
          when(() => mockCreateFormUseCase.uploadInlineAttachment({'projectID': '123456'})).thenAnswer((invocation) => Future.value(SUCCESS(jsonEncode({}), null, 200, requestData: NetworkRequestBody.json({'projectID': '123456'}))));
          c.uploadInlineAttachment('projectID', 'filePath', {'folderID': '12345'}, 'appTypeID');
        },
        expect: () => [isA<LoadingState>()]);
  });
}
