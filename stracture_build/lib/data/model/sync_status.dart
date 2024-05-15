import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';

class SyncStatus {
  SyncStatus._();
  factory SyncStatus.success(String result) = SyncSuccessState;
  factory SyncStatus.projectLocation(List<Project> projectList,List<SiteLocation> siteLocationList) = SyncSuccessProjectLocationState;
  factory SyncStatus.formTypeList(List<AppType> appTypeList,{String? formTypeIds}) = SyncSuccessFormTypeListState;
  factory SyncStatus.error(String className,String error) = SyncErrorState;
}

class SyncErrorState extends SyncStatus {
  SyncErrorState(this.className,this.msg): super._();
  final String className;
  final String msg;
}

class SyncSuccessState extends SyncStatus {
  SyncSuccessState(this.value): super._();
  final String value;
}

class SyncSuccessProjectLocationState extends SyncStatus {
  SyncSuccessProjectLocationState(this.projectList,this.siteLocationList): super._();
  final List<Project> projectList ;
  final List<SiteLocation> siteLocationList ;
}

class SyncSuccessFormListState extends SyncStatus {
  SyncSuccessFormListState(this.formList): super._();
  final List<SiteForm> formList ;
}
class SyncSuccessFormTypeListState extends SyncStatus {
  SyncSuccessFormTypeListState(this.appTypeList, {this.formTypeIds}): super._();
  final List<AppType> appTypeList ;
  final String? formTypeIds;
}
class SyncSuccessBatchMessageListState extends SyncStatus {
  SyncSuccessBatchMessageListState(): super._();
}