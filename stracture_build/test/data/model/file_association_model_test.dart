import 'dart:convert';

import 'package:field/data/model/file_association_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FileAssociation fileAssociation;

  setUp(() async {
    fileAssociation = FileAssociation(revisionId: "revisionId", documentTypeId: 4, projectId: "projectId", folderId: "folderId", generateUri: true, filename: '', filepath: '', documentRevision: '', publisherName: '', publisherOrganization: '', revisionCounter: '', publishDate: '', documentTitle: '', documentId: '', associatedDate: '');
  });

  group("test FileAssociation", () {
    test("test with toJson expected FileAssociation", () async {
      Map<String, dynamic> map = fileAssociation.toJson();
      expect(map["filepath"], fileAssociation.filepath);
    });

    test("test with fromJson expected FileAssociation with valid data", () async {
      Map<String, dynamic> map = fileAssociation.toJson();
      expect(FileAssociation.fromJson(map), isA<FileAssociation>());
    });

    test("test with fileAssociationFromJson expected list of FileAssociation", () async {
      String fileAssociationData = jsonEncode([fileAssociation]);

      List<FileAssociation> list = fileAssociationFromJson(fileAssociationData);
      expect(list, isA<List<FileAssociation>>());
    });

    test("test with fileAssociationToJson expected string data", () async {
      String fileAssociationData = jsonEncode([fileAssociation]);
      List<FileAssociation> list = fileAssociationFromJson(fileAssociationData);

      String result = fileAssociationToJson(list);
      expect(result, fileAssociationData);
    });
  });
}
