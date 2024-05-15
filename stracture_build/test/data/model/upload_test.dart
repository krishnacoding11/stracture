import 'dart:convert';

import 'package:field/data/model/simple_file_upload.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  dynamic simpleFileUploadResponse;
  SimpleFileUpload simpleFileUpload;

  setUp(() {
    simpleFileUploadResponse = jsonDecode(fixture("simple_file_upload.json"));
  });

  test(
    "Test simple file upload response parsing",
    () {
      simpleFileUpload = SimpleFileUpload.fromJson(simpleFileUploadResponse);
      List<String>  successFiles = simpleFileUpload!.sucessFiles!;
      expect(successFiles.isNotEmpty, true);
    },
  );

  group("Simple File Upload Model:", () {
    test("fromJson() method unit testing", () {
      simpleFileUpload = SimpleFileUpload.fromJson(simpleFileUploadResponse);
      Map<String, dynamic> jsonMap = simpleFileUpload.toJson();
      final result = SimpleFileUpload.fromJson(jsonMap);
      expect(jsonEncode(result), jsonEncode(simpleFileUpload));
    });

    test("toJson() method unit testing", () {
      simpleFileUpload = SimpleFileUpload.fromJson(simpleFileUploadResponse);
      Map<String, dynamic> jsonMap = simpleFileUpload.toJson();
      final result = simpleFileUpload.toJson();
      expect(result, jsonMap);
    });

  });

}
