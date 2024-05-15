import 'package:field/data/repository/site/create_form_repository.dart';
import 'package:field/networking/network_response.dart';

class CreateFormLocalRepository with CreateFormRepository {
  CreateFormLocalRepository();

  @override
  Future<Result> downloadInLineAttachment(Map<String, dynamic> request) async{
    return FAIL("", -1);
  }

  @override
  Future<Result> uploadAttachment(Map<String, dynamic> request) async{
    return FAIL("", -1);
  }

  @override
  Future<Result> uploadInlineAttachment(Map<String, dynamic> request) async{
    return SUCCESS(request, null, null);
  }

  @override
  Future<Result> saveFormToServer(Map<String, dynamic> request) {
    // TODO: implement saveFormToServer
    throw UnimplementedError();
  }

  @override
  Future<Result> formDistActionTaskToServer(Map<String, dynamic> request) {
    // TODO: implement formDistributionActionToServer
    throw UnimplementedError();
  }

  @override
  Future<Result> formOtherActionTaskToServer(Map<String, dynamic> request) {
    // TODO: implement formOtherActionTaskToServer
    throw UnimplementedError();
  }

  @override
  Future<Result> formStatusChangeTaskToServer(Map<String, dynamic> request) {
    // TODO: implement formStatusChangeTaskToServer
    throw UnimplementedError();
  }
}