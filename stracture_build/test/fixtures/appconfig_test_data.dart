import 'dart:convert';

import 'package:field/data/model/user_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/app_config.dart';

import 'fixture_reader.dart';

class AppConfigTestData {
  setupAppConfigTestData() {
    if (di.getIt.isRegistered<AppConfig>()) di.getIt.unregister<AppConfig>();
    di.getIt.registerLazySingleton(() => AppConfig());

    AppConfig appConfig = di.getIt<AppConfig>();

    User user = User.fromJson(jsonDecode(fixture("user_data.json")));
    appConfig.currentUser = user;
    appConfig.appConfigData = {
      "userData": jsonDecode(fixture("user_data.json")),
      "userCurrentLanguage": "en_GB",
      "cloud_type_data": "1",
      "languageData": {
        "jsonLocales": [
          {"displayCountry": "United Kingdom", "languageId": "en_GB", "displayLanguage": "English"},
          {"displayCountry": "United States", "languageId": "en_US", "displayLanguage": "English"},
          {"displayCountry": "Canada", "languageId": "en_CA", "displayLanguage": "English"},
          {"displayCountry": "France", "languageId": "fr_FR", "displayLanguage": "Français"},
          {"displayCountry": "Russia", "languageId": "ru_RU", "displayLanguage": "Русский"},
          {"displayCountry": "Spain", "languageId": "es_ES", "displayLanguage": "Español"},
          {"displayCountry": "Australia", "languageId": "en_AU", "displayLanguage": "English"},
          {"displayCountry": "China", "languageId": "zh_CN", "displayLanguage": "中文"},
          {"displayCountry": "Germany", "languageId": "de_DE", "displayLanguage": "Deutsch"},
          {"displayCountry": "Ireland", "languageId": "ga_IE", "displayLanguage": "Gaeilge"},
          {"displayCountry": "South Africa", "languageId": "en_ZA", "displayLanguage": "English"},
          {"displayCountry": "Saudi Arabia", "languageId": "ar_SA", "displayLanguage": "العربية"},
          {"displayCountry": "Japan", "languageId": "ja_JP", "displayLanguage": "日本語"},
          {"displayCountry": "Ireland", "languageId": "en_IE", "displayLanguage": "English"},
          {"displayCountry": "Italy", "languageId": "it_IT", "displayLanguage": "Italiano"},
          {"displayCountry": "Netherlands", "languageId": "nl_NL", "displayLanguage": "Nederlands"},
          {"displayCountry": "Czech Republic", "languageId": "cs_CZ", "displayLanguage": "Čeština"},
          {"displayCountry": "Turkey", "languageId": "tr_TR", "displayLanguage": "Türkçe"},
          {"displayCountry": "Vietnam", "languageId": "vi_VN", "displayLanguage": "Tiếng Việt"}
        ],
        "locales": "en_GB,en_US,en_CA,fr_FR,ru_RU,es_ES,en_AU,zh_CN,de_DE,ga_IE,en_ZA,ar_SA,ja_JP,en_IE,it_IT,nl_NL,cs_CZ,tr_TR,vi_VN"
      }
    };
    appConfig.currentSelectedProject = jsonDecode(fixture("project.json"));
  }
}
