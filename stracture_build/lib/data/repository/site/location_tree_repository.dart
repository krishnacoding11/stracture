import '../../../networking/network_response.dart';
import '../../model/site_location.dart';

enum LocationTreeViewFrom { projectList, sitePlanView }

mixin LocationTreeRepository {
  Future<Result> getLocationTree(Map<String, dynamic> request);

  Future<SiteLocation?> getLocationTreeByAnnotationId(
      Map<String, dynamic> request);

  Future<List<SiteLocation>?> getLocationDetailsByLocationIds(
      Map<String, dynamic> request);
}
