import 'package:field/data/model/language_vo.dart';
import 'package:test/test.dart';

void main() {
  group('Language Tests', () {
    test('Language.fromJson should create a Language object from JSON', () {
      // Sample JSON data representing a Language object
      final json = {
        'jsonLocales': [
          {
            'displayCountry': 'US',
            'languageId': 'en',
            'displayLanguage': 'English',
          },
          {
            'displayCountry': 'JP',
            'languageId': 'ja',
            'displayLanguage': 'Japanese',
          },
        ],
        'locales': 'en_US',
      };

      // Create a Language object from the JSON data
      final language = Language.fromJson(json);

      // Check if the properties are correctly set
      expect(language.jsonLocales, isNotNull);
      expect(language.jsonLocales!.length, 2);
      expect(language.locales, 'en_US');
      expect(language.jsonLocales![0].displayCountry, 'US');
      expect(language.jsonLocales![0].languageId, 'en');
      expect(language.jsonLocales![0].displayLanguage, 'English');
      expect(language.jsonLocales![1].displayCountry, 'JP');
      expect(language.jsonLocales![1].languageId, 'ja');
      expect(language.jsonLocales![1].displayLanguage, 'Japanese');
    });

    test('Language.toJson should convert a Language object to JSON', () {
      // Create a sample Language object
      final language = Language(
        jsonLocales: [
          JsonLocales(
            displayCountry: 'US',
            languageId: 'en',
            displayLanguage: 'English',
          ),
          JsonLocales(
            displayCountry: 'JP',
            languageId: 'ja',
            displayLanguage: 'Japanese',
          ),
        ],
        locales: 'en_US',
      );

      // Convert the Language object to JSON
      final json = language.toJson();

      // Check if the JSON object is correctly generated
      expect(json['jsonLocales'], isNotNull);
      expect(json['jsonLocales'], isList);
      expect(json['jsonLocales'].length, 2);
      expect(json['jsonLocales'][0]['displayCountry'], 'US');
      expect(json['jsonLocales'][0]['languageId'], 'en');
      expect(json['jsonLocales'][0]['displayLanguage'], 'English');
      expect(json['jsonLocales'][1]['displayCountry'], 'JP');
      expect(json['jsonLocales'][1]['languageId'], 'ja');
      expect(json['jsonLocales'][1]['displayLanguage'], 'Japanese');
      expect(json['locales'], 'en_US');
    });
  });

  group('JsonLocales Tests', () {
    test('JsonLocales.fromJson should create a JsonLocales object from JSON', () {
      // Sample JSON data representing a JsonLocales object
      final json = {
        'displayCountry': 'US',
        'languageId': 'en',
        'displayLanguage': 'English',
      };

      // Create a JsonLocales object from the JSON data
      final jsonLocales = JsonLocales.fromJson(json);

      // Check if the properties are correctly set
      expect(jsonLocales.displayCountry, 'US');
      expect(jsonLocales.languageId, 'en');
      expect(jsonLocales.displayLanguage, 'English');
    });

    test('JsonLocales.toJson should convert a JsonLocales object to JSON', () {
      // Create a sample JsonLocales object
      final jsonLocales = JsonLocales(
        displayCountry: 'US',
        languageId: 'en',
        displayLanguage: 'English',
      );

      // Convert the JsonLocales object to JSON
      final json = jsonLocales.toJson();

      // Check if the JSON object is correctly generated
      expect(json['displayCountry'], 'US');
      expect(json['languageId'], 'en');
      expect(json['displayLanguage'], 'English');
    });
  });
}
