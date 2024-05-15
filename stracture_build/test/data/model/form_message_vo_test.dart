import 'dart:convert';
import 'package:field/data/model/form_message_vo.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/fixture_reader.dart';

void main() {
  late Map<String, dynamic> jsonMap;
  late Map<String, dynamic> offlineJsonMap;
  late FormMessageVO formMessageVO;
  late FormMessageVO offlineFormMessageVo;

  setUp(() {
    jsonMap = jsonDecode(fixture("form_message.json"));
    offlineJsonMap = jsonDecode(fixture("form_message_db.json"));
    formMessageVO=FormMessageVO.fromJson(jsonMap);
    offlineFormMessageVo=FormMessageVO.offlineFromJson(offlineJsonMap);
  });

  group("Form Message Model:", () {
    test("fromJson() method unit testing", () {
      final result = FormMessageVO.fromJson(jsonMap);
      expect(result.projectId, equals("2130192"));
      expect(result.projectName, equals("Site Quality Demo"));
      expect(result.formId, equals("11607652"));
      expect(result.commId, equals("11607652"));
    });

    test("offlineFromJson() method unit testing", () {
      final result = FormMessageVO.offlineFromJson(offlineJsonMap);
      expect(result.projectId, equals("2130192"));
      expect(result.projectName, equals("Site Quality Demo"));
      expect(result.formId, equals(null));
      expect(result.commId, equals(null));
    });
  });
}
