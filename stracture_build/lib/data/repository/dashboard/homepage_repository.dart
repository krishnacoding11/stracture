import '../../../networking/network_response.dart';

abstract class HomePageRepository {
  Future<Result?> getShortcutConfigList(Map<String, dynamic> request);

  Future<Result?> getPendingShortcutConfigList(Map<String, dynamic> request);

  Future<Result?>? updateShortcutConfigList(Map<String, dynamic> request);
}
