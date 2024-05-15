import 'package:field/data/local/site/create_form_local_repository.dart';
import 'package:field/data/remote/site/create_form_remote_repository.dart';
import 'package:field/data/repository/site/create_form_repository.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';

import '../../../networking/network_response.dart';

class CreateFormUseCase extends BaseUseCase with CreateFormRepository {
  CreateFormRepository? _createFormRepository;

  @override
  Future<Result> uploadAttachment(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _createFormRepository!.uploadAttachment(request);
    return result;
  }

  @override
  Future<Result> downloadInLineAttachment(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _createFormRepository!.downloadInLineAttachment(request);
    if (result is SUCCESS) {
      final temp = result.data;
    }
    return result;
  }

  @override
  Future<Result> uploadInlineAttachment(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _createFormRepository!.uploadInlineAttachment(request);
    return result;
  }

  @override
  Future<Result> saveFormToServer(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _createFormRepository!.saveFormToServer(request);
    return result;
  }

  @override
  Future getInstance() async {
    if (isNetWorkConnected()) {
      _createFormRepository = di.getIt<CreateFormRemoteRepository>();
    } else {
      _createFormRepository = di.getIt<CreateFormLocalRepository>();
    }
    return _createFormRepository;
  }

  @override
  Future<Result> formDistActionTaskToServer(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _createFormRepository!.formDistActionTaskToServer(request);
    return result;
  }

  @override
  Future<Result> formOtherActionTaskToServer(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _createFormRepository!.formOtherActionTaskToServer(request);
    return result;
  }

  @override
  Future<Result> formStatusChangeTaskToServer(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _createFormRepository!.formStatusChangeTaskToServer(request);
    return result;
  }
}
