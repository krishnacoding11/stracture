
import '../../../data/local/cbim_settings/Cbim_settings_repository_impl.dart';

class CBimSettingUseCase {
  final CbimSettingsRepositoryImpl _cbimSettingsRepositoryImpl = CbimSettingsRepositoryImpl();

  Future setCbimSettingsValue(int value) async {
    return _cbimSettingsRepositoryImpl.setCbimSettingsValue(value);
  }

  Future<Map<String, dynamic>> getCbimSettingsValue() async {
    return _cbimSettingsRepositoryImpl.getCbimSettingsValue();
  }


}