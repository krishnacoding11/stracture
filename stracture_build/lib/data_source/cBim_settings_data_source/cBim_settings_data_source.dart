abstract class CbimSettingsDataSource {
  Future<Map<String, dynamic>> getCbimSettingsValue();
  Future<dynamic> setCbimSettingsValue(int value);
}
