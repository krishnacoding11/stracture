import 'dart:ui';

class LocaleManager {
  Map<String, Locale> localeList = <String, Locale>{
    "en_US": const Locale('en', 'US'),
    "en_UK": const Locale('en', 'UK'),
    "en_CA": const Locale('en', 'CA'),
    "en_GB": const Locale('en', 'GB'),
    "en_AU": const Locale('en', 'AU'),
    "en_ZA": const Locale('en', 'ZA'),
    "en_IE": const Locale('en', 'IE'),
    "fr_FR": const Locale('fr', ''),// Language Code Not supported
    "ru_RU": const Locale('ru', ''),// Language Code Not supported
    "es_ES": const Locale('es', ''),// Language Code Not supported
    "zh_CN": const Locale('zh', ''),// Language Code Not supported
    "de_DE": const Locale('de', ''),// Language Code Not supported
    "ga_IE": const Locale('ga', ''),// Both are not supported
    "ar_SA": const Locale('ar', ''),// Language Code Not supported
    "ja_JP": const Locale('ja', ''),// Language Code Not supported
    "it_IT": const Locale('it', ''),// Language Code Not supported
    "nl_NL": const Locale('nl', ''),// Language Code Not supported
    "cs_CZ": const Locale('cs', ''),// Language Code Not supported
    "tr_TR": const Locale('tr', ''),// Language Code Not supported
    "vi_VN": const Locale('vi', '')
  };
}

/*
*
*
*     "fr_FR": const Locale('fr', 'FR'),// Language Code Not supported
    "ru_RU": const Locale('ru', 'RU'),// Language Code Not supported
    "es_ES": const Locale('es', 'ES'),// Language Code Not supported
    "zh_CN": const Locale('zh', 'CN'),// Language Code Not supported
    "de_DE": const Locale('de', 'DE'),// Language Code Not supported
    "ga_IE": const Locale('ga', 'IE'),// Both are not supported
    "ar_SA": const Locale('ar', 'SA'),// Language Code Not supported
    "ja_JP": const Locale('ja', 'JP'),// Language Code Not supported
    "it_IT": const Locale('it', 'IT'),// Language Code Not supported
    "nl_NL": const Locale('nl', 'NL'),// Language Code Not supported
    "cs_CZ": const Locale('cs', 'CZ'),// Language Code Not supported
    "tr_TR": const Locale('tr', 'TR'),// Language Code Not supported
    "vi_VN": const Locale('vi', 'VN')*/
