import 'package:field/domain/use_cases/cBim_settings/cBim_setting_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cBim_settings_state.dart';

class CBIMSettingsCubit extends Cubit<CBIMSettingsState> {
  CBIMSettingsCubit(super.initialState) {
    initCBIMSettings();
  }

  CBimSettingUseCase _cBimRepositoryUseCase = CBimSettingUseCase();

  double selectedSliderValue = 5;
  double max = 10;
  double min = 1;

  initCBIMSettings() async {
    Map<String, dynamic> db = await _cBimRepositoryUseCase.getCbimSettingsValue();
    if (db.isNotEmpty) {
      if (db['NavigationSpeed'] != -1) {
        selectedSliderValue = double.parse(db['NavigationSpeed'].toString());
      }
    }
  }

  void onSliderChange(double? newValue, {bool isTest = false}) {
    selectedSliderValue = newValue!;
    _setValue();
    emit(SliderValueChangeState(selectedSliderValue));
  }

  void _setValue() {
     _cBimRepositoryUseCase.setCbimSettingsValue(selectedSliderValue.toInt());
  }
}
