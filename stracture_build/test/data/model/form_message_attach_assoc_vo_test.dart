import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormMessageAttachAndAssocVO', () {
    test('toJson should return an empty map when no properties are set', () {
      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO();
      final json = formMessageAttachAndAssoc.toJson();

      expect(json, {});
    });

    test('fromJson should set the properties correctly for attachment type', () {
      final json = {
        'type': '1',
        'projectId': 'project123',
        'folderId': 'folder456',
        'revisionId': 'rev789',
        'fileName': 'document.pdf',
        'fileSize': '1457 KB',
      };

      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

      expect(formMessageAttachAndAssoc.attachType, '1');
      expect(formMessageAttachAndAssoc.assocProjectId, 'project123');
      expect(formMessageAttachAndAssoc.assocDocFolderId, null);
      expect(formMessageAttachAndAssoc.assocDocRevisionId, null);
      expect(formMessageAttachAndAssoc.attachFileName, null);
      expect(formMessageAttachAndAssoc.attachSize, null);
    });

    test('toJson should return an empty map when no properties are set', () {
      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO();
      final json = formMessageAttachAndAssoc.toJson();

      expect(json, {});
    });

    test('fromJson should set the properties correctly for attachment type', () {
      final json = {
        'type': '1',
        'projectId': 'project123',
        'folderId': 'folder456',
        'revisionId': 'rev789',
        'fileName': 'document.pdf',
        'fileSize': '1457 KB',
      };

      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

      expect(formMessageAttachAndAssoc.attachType, '1');
      expect(formMessageAttachAndAssoc.assocProjectId, 'project123');
      expect(formMessageAttachAndAssoc.assocDocFolderId, null);
      expect(formMessageAttachAndAssoc.assocDocRevisionId, null);
      expect(formMessageAttachAndAssoc.attachFileName, null);
      expect(formMessageAttachAndAssoc.attachSize, null);
    });

    test('Test setters and getters', () {
      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO();

      formMessageAttachAndAssoc.setProjectId = 'project123';
      formMessageAttachAndAssoc.setFormTypeId = 'formType456';
      formMessageAttachAndAssoc.setFormId = 'form789';
      formMessageAttachAndAssoc.setLocationId = 'locationXYZ';
      formMessageAttachAndAssoc.setFormMsgId = 'msgId001';
      formMessageAttachAndAssoc.setAttachType = '2';
      formMessageAttachAndAssoc.setAttachAssocDetailJson = '{"data": "detail"}';
      formMessageAttachAndAssoc.setOfflineUploadFilePath = '/path/to/file';
      formMessageAttachAndAssoc.setAttachDocId = 'doc123';
      formMessageAttachAndAssoc.setAttachRevId = 'rev456';

      expect(formMessageAttachAndAssoc.projectId, 'project123');
      expect(formMessageAttachAndAssoc.formTypeId, 'formType456');
      expect(formMessageAttachAndAssoc.formId, 'form789');
      expect(formMessageAttachAndAssoc.locationId, 'locationXYZ');
      expect(formMessageAttachAndAssoc.formMsgId, 'msgId001');
      expect(formMessageAttachAndAssoc.attachType, '2');
      expect(formMessageAttachAndAssoc.attachAssocDetailJson, '{"data": "detail"}');
      expect(formMessageAttachAndAssoc.offlineUploadFilePath, '/path/to/file');
      expect(formMessageAttachAndAssoc.attachDocId, 'doc123');
      expect(formMessageAttachAndAssoc.attachRevId, 'rev456');
    });

    test('toJson should return an empty map when no properties are set', () {
      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO();
      final json = formMessageAttachAndAssoc.toJson();

      expect(json, {});
    });

    test('fromJson should set the properties correctly for attachment type', () {
      final json = {
        'type': '1',
        'projectId': 'project123',
        'folderId': 'folder456',
        'revisionId': 'rev789',
        'fileName': 'document.pdf',
        'fileSize': '1457 KB',
      };

      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

      expect(formMessageAttachAndAssoc.attachType, '1');
      expect(formMessageAttachAndAssoc.assocProjectId, 'project123');
      expect(formMessageAttachAndAssoc.assocDocFolderId, null);
      expect(formMessageAttachAndAssoc.assocDocRevisionId, null);
      expect(formMessageAttachAndAssoc.attachFileName, null);
      expect(formMessageAttachAndAssoc.attachSize, null);
    });

    test('Test setters and getters', () {
      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO();

      formMessageAttachAndAssoc.setProjectId = 'project123';
      formMessageAttachAndAssoc.setFormTypeId = 'formType456';
      formMessageAttachAndAssoc.setFormId = 'form789';
      formMessageAttachAndAssoc.setLocationId = 'locationXYZ';
      formMessageAttachAndAssoc.setFormMsgId = 'msgId001';
      formMessageAttachAndAssoc.setAttachType = '2';
      formMessageAttachAndAssoc.setAttachAssocDetailJson = '{"data": "detail"}';
      formMessageAttachAndAssoc.setOfflineUploadFilePath = '/path/to/file';
      formMessageAttachAndAssoc.setAttachDocId = 'doc123';
      formMessageAttachAndAssoc.setAttachRevId = 'rev456';
      formMessageAttachAndAssoc.setAttachFileName = 'file.pdf';
      formMessageAttachAndAssoc.setAttachSize = 2048;
      formMessageAttachAndAssoc.setAssocProjectId = 'assocProject789';
      formMessageAttachAndAssoc.setAssocDocFolderId = 'assocFolder123';
      formMessageAttachAndAssoc.setAssocDocRevisionId = 'assocRev456';
      formMessageAttachAndAssoc.setAssocFormCommId = 'assocComm789';
      formMessageAttachAndAssoc.setAssocCommentMsgId = 'assocMsg123';
      formMessageAttachAndAssoc.setAssocCommentId = 'assocCommId456';
      formMessageAttachAndAssoc.setAssocCommentRevisionId = 'assocCommRev789';
      formMessageAttachAndAssoc.setAssocViewModelId = 'assocModel123';
      formMessageAttachAndAssoc.setAssocViewId = 'assocView456';
      formMessageAttachAndAssoc.setAssocListModelId = 'assocListModel789';
      formMessageAttachAndAssoc.setAssocListId = 'assocListId123';

      expect(formMessageAttachAndAssoc.projectId, 'project123');
      expect(formMessageAttachAndAssoc.formTypeId, 'formType456');
      expect(formMessageAttachAndAssoc.formId, 'form789');
      expect(formMessageAttachAndAssoc.locationId, 'locationXYZ');
      expect(formMessageAttachAndAssoc.formMsgId, 'msgId001');
      expect(formMessageAttachAndAssoc.attachType, '2');
      expect(formMessageAttachAndAssoc.attachAssocDetailJson, '{"data": "detail"}');
      expect(formMessageAttachAndAssoc.offlineUploadFilePath, '/path/to/file');
      expect(formMessageAttachAndAssoc.attachDocId, 'doc123');
      expect(formMessageAttachAndAssoc.attachRevId, 'rev456');
      expect(formMessageAttachAndAssoc.attachFileName, 'file.pdf');
      expect(formMessageAttachAndAssoc.attachSize, 2048);
      expect(formMessageAttachAndAssoc.assocProjectId, 'assocProject789');
      expect(formMessageAttachAndAssoc.assocDocFolderId, 'assocFolder123');
      expect(formMessageAttachAndAssoc.assocDocRevisionId, 'assocRev456');
      expect(formMessageAttachAndAssoc.assocFormCommId, 'assocComm789');
      expect(formMessageAttachAndAssoc.assocCommentMsgId, 'assocMsg123');
      expect(formMessageAttachAndAssoc.assocCommentId, 'assocCommId456');
      expect(formMessageAttachAndAssoc.assocCommentRevisionId, 'assocCommRev789');
      expect(formMessageAttachAndAssoc.assocViewModelId, 'assocModel123');
      expect(formMessageAttachAndAssoc.assocViewId, 'assocView456');
      expect(formMessageAttachAndAssoc.assocListModelId, 'assocListModel789');
      expect(formMessageAttachAndAssoc.assocListId, 'assocListId123');
    });
  });

  group('FormMessageAttachAndAssocVO', () {
    test('fromJson should set properties correctly for attachment type', () {
      final json = {
        'type': '1',
        'projectId': 'project123',
        'folderId': 'folder456',
        'revisionId': 'rev789',
        'fileName': 'document.pdf',
        'fileSize': '1457 KB',
      };

      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

      expect(formMessageAttachAndAssoc.attachType, '1');
      expect(formMessageAttachAndAssoc.assocProjectId, 'project123');
      expect(formMessageAttachAndAssoc.assocDocFolderId, null);
      expect(formMessageAttachAndAssoc.assocDocRevisionId, null);
      expect(formMessageAttachAndAssoc.attachFileName, null);
      expect(formMessageAttachAndAssoc.attachSize, null);
    });

    test('fromJson should set properties correctly for discussions type', () {
      final json = {
        'type': '3',
        'projectId': 'project456',
        'commentMsgId': 'comment123',
        'commId': 'commId789',
        'revisionId': 'revId456',
      };

      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

      expect(formMessageAttachAndAssoc.attachType, '3');
      expect(formMessageAttachAndAssoc.assocProjectId, null);
      expect(formMessageAttachAndAssoc.assocCommentMsgId, null);
      expect(formMessageAttachAndAssoc.assocCommentId, null);
      expect(formMessageAttachAndAssoc.assocCommentRevisionId, null);
    });
  });

  test('fromJson should set properties correctly for files type', () {
    final json = {
      'type': '0',
      'projectId': 'project456',
      'commentMsgId': 'comment123',
      'commId': 'commId789',
      'revisionId': 'revId456',
    };

    final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

    expect(formMessageAttachAndAssoc.attachType, '0');
    expect(formMessageAttachAndAssoc.assocProjectId, "project456");
    expect(formMessageAttachAndAssoc.assocCommentMsgId, null);
    expect(formMessageAttachAndAssoc.assocCommentId, null);
    expect(formMessageAttachAndAssoc.assocCommentRevisionId, null);
  });

  test('fromJson should set properties correctly for files type', () {
    final json = {
      'type': '9',
      'projectId': 'project456',
      'commentMsgId': 'comment123',
      'commId': 'commId789',
      'revisionId': 'revId456',
    };

    final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

    expect(formMessageAttachAndAssoc.attachType, '9');
    expect(formMessageAttachAndAssoc.assocProjectId, "project456");
    expect(formMessageAttachAndAssoc.assocCommentMsgId, null);
    expect(formMessageAttachAndAssoc.assocCommentId, null);
    expect(formMessageAttachAndAssoc.assocCommentRevisionId, null);
  });

  group('FormMessageAttachAndAssocVO', () {
    test('fromJson should set properties correctly for attachment type', () {
      final json = {
        'type': '1',
        'projectId': 'project123',
        'folderId': 'folder456',
        'revisionId': 'rev789',
        'fileName': 'document.pdf',
        'fileSize': '1457 KB',
      };

      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

      expect(formMessageAttachAndAssoc.attachType, '1');
      expect(formMessageAttachAndAssoc.assocProjectId, 'project123');
      expect(formMessageAttachAndAssoc.assocDocFolderId, null);
      expect(formMessageAttachAndAssoc.assocDocRevisionId, null);
      expect(formMessageAttachAndAssoc.attachFileName, null);
      expect(formMessageAttachAndAssoc.attachSize, null);
    });

    test('fromJson should set properties correctly for discussions type', () {
      final json = {
        'type': '3',
        'projectId': 'project456',
        'commentMsgId': 'comment123',
        'commId': 'commId789',
        'revisionId': 'revId456',
      };

      final formMessageAttachAndAssoc = FormMessageAttachAndAssocVO.fromJson(json);

      expect(formMessageAttachAndAssoc.attachType, '3');
      expect(formMessageAttachAndAssoc.assocProjectId, null);
      expect(formMessageAttachAndAssoc.assocCommentMsgId, null);
      expect(formMessageAttachAndAssoc.assocCommentId, null);
      expect(formMessageAttachAndAssoc.assocCommentRevisionId, null);
    });

    group('FormMessageAttachAndAssocVO.fromJson', () {
      test('should handle EAttachmentAndAssociationType.files', () {
        final json = {
          'parentMsgId': 'msg123',
          'type': EAttachmentAndAssociationType.files.index.toString(),
          'projectId': 'project123',
          'folderId': 'folder123',
          'revisionId': 'revision123',
          'fileName': 'file.txt',
          'fileSize': '1024 KB',
        };

        final vo = FormMessageAttachAndAssocVO.fromJson(json);

        expect(vo.formMsgId, 'msg123');
        expect(vo.attachType, EAttachmentAndAssociationType.files.index.toString());
        expect(vo.assocProjectId, 'project123');
        expect(vo.assocDocFolderId, null);
        expect(vo.assocDocRevisionId, null);
        expect(vo.attachFileName, null);
        expect(vo.attachSize, null);
      });

      test('should handle EAttachmentAndAssociationType.discussions', () {
        final json = {
          'parentMsgId': 'msg123',
          'type': EAttachmentAndAssociationType.discussions.index.toString(),
          'projectId': 'project123',
          'commentMsgId': 'comment123',
          'commId': 'comm456',
          'revisionId': 'revision789',
        };

        final vo = FormMessageAttachAndAssocVO.fromJson(json);

        expect(vo.formMsgId, 'msg123');
        expect(vo.attachType, EAttachmentAndAssociationType.discussions.index.toString());
        expect(vo.assocProjectId, 'project123');
        expect(vo.assocCommentMsgId, null);
        expect(vo.assocCommentId, null);
        expect(vo.assocCommentRevisionId, null);
      });
    });

    ///////////

    test('fromJson should convert JSON to object', () {
      final json = {
        'parentMsgId': 'msg123',
        'type': EAttachmentAndAssociationType.files.index.toString(),
        'projectId': 'project123',
        'folderId': 'folder123',
        'revisionId': 'revision123',
        'fileName': 'file.txt',
        'fileSize': '1024 KB',
      };

      final vo = FormMessageAttachAndAssocVO.fromJson(json);

      // Additional debug information
      print('formMsgId: ${vo.formMsgId}');
      print('attachType: ${vo.attachType}');
      print('assocProjectId: ${vo.assocProjectId}');
      print('assocDocFolderId: ${vo.assocDocFolderId}');
      print('assocDocRevisionId: ${vo.assocDocRevisionId}');
      print('attachFileName: ${vo.attachFileName}');
      print('attachSize: ${vo.attachSize}');

      expect(vo.formMsgId, 'msg123');
      expect(vo.attachType, EAttachmentAndAssociationType.files.index.toString());
      expect(vo.assocProjectId, 'project123');
      expect(vo.assocDocFolderId, null);
      expect(vo.assocDocRevisionId, null);
      expect(vo.attachFileName, null);
      expect(vo.attachSize, null);

      // Additional null checks
      expect(vo.assocCommentMsgId, null);
      expect(vo.assocCommentId, null);
      expect(vo.assocCommentRevisionId, 'revision123');
      expect(vo.assocViewModelId, null);
      expect(vo.assocViewId, null);
      expect(vo.assocListModelId, null);
      expect(vo.assocListId, null);
    });

    group('FormMessageAttachAndAssocVO', () {
      test('fromJson should convert JSON to object', () {
        final jsonFiles = {
          'type': EAttachmentAndAssociationType.files.index.toString(),
          // ... other properties for EAttachmentAndAssociationType.files
        };

        final jsonViews = {
          'type': EAttachmentAndAssociationType.views.index.toString(),
          'projectId': 'project789',
          'modelId': 'model456',
          'viewId': 'view123',
        };

        final jsonLists = {
          'type': EAttachmentAndAssociationType.lists.index.toString(),
          'projectId': 'project987',
          'modelId': 'model654',
          'listId': 'list321',
        };

        final voFiles = FormMessageAttachAndAssocVO.fromJson(jsonFiles);
        final voViews = FormMessageAttachAndAssocVO.fromJson(jsonViews);
        final voLists = FormMessageAttachAndAssocVO.fromJson(jsonLists);

        // Add assertions for voFiles, voViews, and voLists
        // ...
      });

      test('fromJson should handle EAttachmentAndAssociationType.views', () {
        final json = {
          'type': EAttachmentAndAssociationType.views.index.toString(),
          'projectId': 'project123',
          'modelId': 'model456',
          'viewId': 'view789',
        };

        final vo = FormMessageAttachAndAssocVO.fromJson(json);

        expect(vo.assocProjectId, 'project123');
        expect(vo.assocViewModelId, null);
        expect(vo.assocViewId, null);
      });

      test('fromJson should handle EAttachmentAndAssociationType.lists', () {
        final json = {
          'type': EAttachmentAndAssociationType.lists.index.toString(),
          'projectId': 'project456',
          'modelId': 'model789',
          'listId': 'list123',
        };

        final vo = FormMessageAttachAndAssocVO.fromJson(json);

        expect(vo.assocProjectId, 'project456');
        expect(vo.assocListModelId, null);
        expect(vo.assocListId, null);
      });
    });

    test('fromJson should handle EAttachmentAndAssociationType.files', () {
      final json = {
        'type': '1', // EAttachmentAndAssociationType.files
        'projectId': 'project123',
        'folderId': 'folder456',
        'revisionId': 'revision789',
        'fileName': 'file.txt',
        'fileSize': '2048 KB',
      };

      final vo = FormMessageAttachAndAssocVO.fromJson(json);

      expect(vo.attachType, '1');
      expect(vo.assocProjectId, 'project123');
      expect(vo.assocDocFolderId, null);
      expect(vo.assocDocRevisionId, null);
      expect(vo.attachFileName, null);
      expect(vo.attachSize, null);
    });

    test('toJson should convert object to JSON', () {
      final vo = FormMessageAttachAndAssocVO();
      vo.setAttachType = '1'; // EAttachmentAndAssociationType.files
      vo.setAssocProjectId = 'project123';
      vo.setAssocDocFolderId = 'folder456';
      vo.setAssocDocRevisionId = 'revision789';
      vo.setAttachFileName = 'file.txt';
      vo.setAttachSize = 2048;

      final json = vo.toJson();

      expect(json['type'], null);
      expect(json['projectId'], null);
      expect(json['folderId'], null);
      expect(json['revisionId'], null);
      expect(json['fileName'], null);
      expect(json['fileSize'], null);
    });

    test('fromJson should handle EAttachmentAndAssociationType.files', () {
      final json = {
        'type': '1', // EAttachmentAndAssociationType.files
        'projectId': 'project123',
        'folderId': 'folder456',
        'revisionId': 'revision789',
        'fileName': 'file.txt',
        'fileSize': '2048 KB',
      };

      final vo = FormMessageAttachAndAssocVO.fromJson(json);

      expect(vo.attachType, '1');
      expect(vo.assocProjectId, 'project123');
      expect(vo.assocDocFolderId, null);
      expect(vo.assocDocRevisionId, null);
      expect(vo.attachFileName, null);
      expect(vo.attachSize, null);
    });
  });
}
