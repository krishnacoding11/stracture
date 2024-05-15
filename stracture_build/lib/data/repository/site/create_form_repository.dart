import 'package:field/networking/network_response.dart';

mixin CreateFormRepository {
  Future<Result> uploadAttachment(Map<String, dynamic> request);
  Future<Result> downloadInLineAttachment(Map<String, dynamic> request);

  Future<Result> uploadInlineAttachment(Map<String, dynamic> request);

  Future<Result> saveFormToServer(Map<String, dynamic> request);

  Future<Result> formDistActionTaskToServer(Map<String, dynamic> request);

  Future<Result> formOtherActionTaskToServer(Map<String, dynamic> request);

  Future<Result> formStatusChangeTaskToServer(Map<String, dynamic> request);
}
