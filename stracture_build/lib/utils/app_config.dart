import 'package:field/data/model/sync/sync_property_detail_vo.dart';

import '../data/model/user_vo.dart';

class AppConfig{
  User? _currentUser;
  Map<String, dynamic>? _currentSelectedProject;
  Map<String, dynamic>? _getNotificationDetail;
  Map<String,dynamic>? _appConfigData = <String,dynamic>{};
  int? _storedTimestamp;
  SyncManagerPropertyDetails? _syncPropertyDetails;
  bool? _isOnBoarding;

  User? get currentUser => _currentUser;
  Map<String,dynamic>? get appConfigData => _appConfigData;
  Map<String, dynamic>? get currentSelectedProject => _currentSelectedProject;
  int? get storedTimestamp => _storedTimestamp;
  SyncManagerPropertyDetails? get syncPropertyDetails => _syncPropertyDetails ?? SyncManagerPropertyDetails();

  SyncManagerPropertyDetails? getSyncManagerProperty([bool requiredDefaultValue = true]){
    if(requiredDefaultValue){
      return _syncPropertyDetails ?? SyncManagerPropertyDetails();
    }else {
      return _syncPropertyDetails;
    }
  }

  bool? get isOnBoarding => _isOnBoarding ?? true;

  set currentUser(User? value) {
    _currentUser = value;
  }

  set syncPropertyDetails(SyncManagerPropertyDetails? value) {
    _syncPropertyDetails = value;
  }

  set appConfigData(Map<String,dynamic>? value){
    _appConfigData = value;
  }

  set currentSelectedProject(Map<String, dynamic>? value){
    _currentSelectedProject = value;
  }

  set storedTimestamp(int? value){
    _storedTimestamp = value;
  }

  set isOnBoarding(bool? value){
    _isOnBoarding = value;
  }
}