
class Language {
  List<JsonLocales>? jsonLocales;
  String? locales;

  Language({this.jsonLocales, this.locales});

  Language.fromJson(dynamic json) {
    if (json['jsonLocales'] != null) {
      jsonLocales = <JsonLocales>[];
      json['jsonLocales'].forEach((v) {
        jsonLocales!.add(JsonLocales.fromJson(v));
      });
    }
    locales = json['locales'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (jsonLocales != null) {
      data['jsonLocales'] = jsonLocales!.map((v) => v.toJson()).toList();
    }
    data['locales'] = locales;
    return data;
  }
}

class JsonLocales {
  String? displayCountry;
  String? languageId;
  String? displayLanguage;

  JsonLocales({this.displayCountry, this.languageId, this.displayLanguage});

  JsonLocales.fromJson(Map<String, dynamic> json) {
    displayCountry = json['displayCountry'];
    languageId = json['languageId'];
    displayLanguage = json['displayLanguage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['displayCountry'] = displayCountry;
    data['languageId'] = languageId;
    data['displayLanguage'] = displayLanguage;
    return data;
  }
}