


import 'package:field/data/local/cbim_settings/cbim_settings_local_data_source_impl.dart';
import 'package:field/data_source/cBim_settings_data_source/cBim_settings_data_source.dart';

import '../../../injection_container.dart';

class CbimSettingsRepositoryImpl{

  CbimSettingsDataSource _dataSource = getIt<CbimSettingsLocalDataSourceImpl>();

  Future setCbimSettingsValue(int value) async {
    return _dataSource.setCbimSettingsValue(value);
  }

  Future<Map<String, dynamic>> getCbimSettingsValue() async {
    return _dataSource.getCbimSettingsValue();
  }


}