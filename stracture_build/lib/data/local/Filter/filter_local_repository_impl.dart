import 'package:field/data/repository/filter_repository.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/file_utils.dart';

import '../../../data_source/filter/filter_local_data_source.dart';
import '../../../networking/request_body.dart';
import '../../../utils/app_path_helper.dart';

class FilterLocalRepository extends FilterRepository<Map,Result> {
  FilterLocalDataSource? localDataSource;

  FilterLocalRepository();

  @override Future<Result?>? getFilterDataForDefect(Map<String, dynamic> request) async {
    if ((request["projectIds"]?.toString() ?? "").isNotEmpty) {
      String filePath = await AppPathHelper().getProjectFilterAttributeFile(projectId: request["projectIds"]!.toString());
      if (filePath.isNotEmpty) {
        String fileContent = readFromFile(filePath);
        if (fileContent.isNotEmpty) {
          return SUCCESS(fileContent, null, 200, requestData: NetworkRequestBody.json(request));
        }
      }
    }
    return FAIL("", -1);
  }

  @override
  Future<Result?>? getFilterSearchData(Map<String, dynamic> request) async {
    FilterLocalDataSource localDB = await getLocalDataSource();
    return await localDB.getFilterAttributeValueList(request);
  }

  Future<FilterLocalDataSource> getLocalDataSource() async {
    if (localDataSource==null) {
      localDataSource = FilterLocalDataSource();
      await localDataSource!.init();
    }
    return localDataSource!;
  }

}