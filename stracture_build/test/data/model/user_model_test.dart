import 'package:field/data/model/user_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("User Model:", () {
    final user = User();
    test("fromJson() method unit testing", () {
      Map<String, dynamic> jsonMap = {};
      final result = User.fromJson(jsonMap);
      expect(result, user);
    });

    test("toJson() method unit testing", () {
      final result = user.toJson();
      Map<String, dynamic> jsonMap = {};
      expect(result, jsonMap);
    });
  });
}
