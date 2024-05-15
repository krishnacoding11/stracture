import 'package:field/networking/network_response.dart';

abstract class TaskListingRepository<REQUEST,RESPONSE> {
  Future<Result> getTaskListing(Map<String, dynamic> request);
  Future<Result> getTaskStatusList(Map<String, dynamic> request);
  Future<Result> getTaskDetail(Map<String, dynamic> request);
}