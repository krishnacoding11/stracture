import 'package:field/networking/network_response.dart';

abstract class TaskActionCountRepository<REQUEST,RESPONSE> {
  Future<Result?>? getTaskActionCount(Map<String, dynamic> request);
}