import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/repository/site/location_tree_repository.dart';
import 'package:field/data_source/site_location/site_location_local_data_source.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';

import '../../../utils/download_service.dart';

abstract class SiteRepository with LocationTreeRepository{
  final SiteLocationLocalDatasource siteLocationLocalDatasource = di.getIt<SiteLocationLocalDatasource>();
  Future<DownloadResponse> downloadPdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = true});

  Future<DownloadResponse> downloadXfdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = false});

  Future<List<ObservationData>?> getObservationListByPlan(Map<String, dynamic> request);
  Future<Result> getSearchList(Map<String, dynamic> request);
  Future<Result?> getSuggestedSearchList(Map<String, dynamic> request);
}
