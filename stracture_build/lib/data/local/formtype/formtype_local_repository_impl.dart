import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/repository/formtype/formtype_repository.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/calculation/site_form_listing_local_data_soruce.dart';
import 'package:flutter/cupertino.dart';

import '../../../utils/global.dart' as globals;

class FormTypeLocalRepository extends FormTypeRepository<Map, Result> {
  FormTypeLocalRepository();
  FormTypeDao formTypeDao = FormTypeDao();
  @visibleForTesting
  SiteFormListingLocalDataSource siteFormListingLocalDataSource = getIt<SiteFormListingLocalDataSource>();

  @override
  Future<Result?>? getFormTypeControllerUserList(Map<String, dynamic> request) {
    return null;
  }

  @override
  Future<Result?>? getFormTypeCustomAttributeList(Map<String, dynamic> request) {
    return null;
  }
  @override
  Future<Result?>? getFormTypeAttributeSetDetail(Map<String, dynamic> request) {
   return null;
  }

  @override
  Future<Result?>? getFormTypeDistributionList(Map<String, dynamic> request) {
    return null;
  }

  @override
  Future<Result?>? getFormTypeFixFieldData(Map<String, dynamic> request) {
    return null;
  }

  @override
  Future<Result?>? getFormTypeHTMLTemplateZipDownload(Map<String, dynamic> request) {
    return null;
  }

  @override
  Future<Result?>? getFormTypeStatusList(Map<String, dynamic> request) {
    return null;
  }

  @override
  Future<Result?>? getFormTypeXSNTemplateZipDownload(Map<String, dynamic> request) {
    return null;
  }

  @override
  Future<Result?>? getLatestProjectDefectFormTypeIdList(Map<String, dynamic> request) {
    return null;
  }

  @override
  Future<void> getAppTypeList(String projectId, isFromMap, String appTypeId) async {
    List<AppType> items = [];

    final qurResult = await siteFormListingLocalDataSource.fetchAppTypeList(projectId);
    if (qurResult.isNotEmpty) {
      for (var item in qurResult) {
        if(item["CanCreateForms"] == 1){
          final appItem = formTypeDao.fromMap(item);
          appItem.isRecent = item["FormCreationDateInMS"] == 0 ? false : true;
          items.add(appItem);
        }
      }
      globals.appTypeList = [...items];
    } else {
      globals.appTypeList.clear();
    }
  }
}