import 'dart:convert';
import 'package:field/data/model/form_message_vo.dart';
import 'package:field/data/model/login_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/fixture_reader.dart';

void main() {
  late Map<String, dynamic> jsonMap;
  late AsiteApiExceptionThrown asiteApiExceptionThrown;

  setUp(() {
    jsonMap = jsonDecode(fixture("login_exception.json"));
    asiteApiExceptionThrown=AsiteApiExceptionThrown.fromJson(jsonMap);
  });

  group("Login Exception Thrown Model Test :", () {
    test("fromJson() method unit testing", () {
      final result = AsiteApiExceptionThrown.fromJson(jsonMap);
      expect(result.errorcode, equals("216"));
      expect(result.errormessage, equals("Invalid Password given for Authentication"));
      expect(result.errordescription, equals("BAD_PASSWORD"));
    });

    test("toJson() method unit testing", () {
      final jsonMap = asiteApiExceptionThrown.toJson();
      expect(jsonMap["_ERROR_CODE"], equals("216"));
      expect(jsonMap["ERROR_MESSAGE"], equals("Invalid Password given for Authentication"));
      expect(jsonMap["ERROR_DESCRIPTION"], equals("BAD_PASSWORD"));
    });
  });
}
