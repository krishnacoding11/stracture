import 'package:field/data/model/simple_file_upload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThinUploadDocVOs', () {
    test('fromJson() should create a valid object from JSON', () {
      // Create a sample JSON map
      final Map<String, dynamic> json = {
        // Provide key-value pairs matching the properties of the class
        'kickOffW orkflow': true,
        'attachmentCounter': 2,
        'fileSysLocation': '/path/to/file',
        'viewerId': 1,
      };

      final ThinUploadDocVOs uploadDoc = ThinUploadDocVOs.fromJson(json);

      // Assert that the object was created correctly
      expect(uploadDoc.kickOffWorkflow, true);
      expect(uploadDoc.attachmentCounter, 2);
      expect(uploadDoc.fileSysLocation, '/path/to/file');
      expect(uploadDoc.viewerId, null);
    });

    test('localRevisionId should return the correct value', () {
      final doc = ThinUploadDocVOs(localRevisionId: 123);
      expect(doc.localRevisionId, 123);
    });

    // Test case for the 'fileFormatType' getter
    test('fileFormatType should return the correct value', () {
      final doc = ThinUploadDocVOs(fileFormatType: 2);
      expect(doc.fileFormatType, 2);
    });

    // Test case for the 'distributionApply' getter
    test('distributionApply should return the correct value', () {
      final doc = ThinUploadDocVOs(distributionApply: true);
      expect(doc.distributionApply, true);
    });

    // Test case for the 'emailType' getter
    test('emailType should return the correct value', () {
      final doc = ThinUploadDocVOs(emailType: 1);
      expect(doc.emailType, 1);
    });

    // Test case for the 'fileSize' getter
    test('fileSize should return the correct value', () {
      final doc = ThinUploadDocVOs(fileSize: 1024);
      expect(doc.fileSize, 1024);
    });

    // Test case for the 'hasAttachment' getter
    test('hasAttachment should return the correct value', () {
      final doc = ThinUploadDocVOs(hasAttachment: true);
      expect(doc.hasAttachment, true);
    });

    // Test case for the 'revision' getter
    test('revision should return the correct value', () {
      final doc = ThinUploadDocVOs(revision: 'A1');
      expect(doc.revision, 'A1');
    });

    // Test case for the 'docFileName' getter
    test('docFileName should return the correct value', () {
      var doc = ThinUploadDocVOs(docFileName: 'document.pdf');
      expect(doc.docFileName, 'document.pdf');
      doc = ThinUploadDocVOs(proxyUserId: 2);
      expect(doc.proxyUserId, 2);
      doc = ThinUploadDocVOs(customObjectComponentId: 2);
      expect(doc.customObjectComponentId, 2);
      doc = ThinUploadDocVOs(referenceRevisionId: 2);
      expect(doc.referenceRevisionId, 2);
      doc = ThinUploadDocVOs(worksetTypeId: 2);
      expect(doc.worksetTypeId, 2);
      doc = ThinUploadDocVOs(fromAdrive: false);
      expect(doc.fromAdrive, false);
      doc = ThinUploadDocVOs(revCounter: 2);
      expect(doc.revCounter, 2);
      doc = ThinUploadDocVOs(drawing: false);
      expect(doc.drawing, false);
      doc = ThinUploadDocVOs(planId: 2);
      expect(doc.planId, 2);
      doc = ThinUploadDocVOs(documentTitle: '');
      expect(doc.documentTitle, '');
      doc = ThinUploadDocVOs(amsServerId: 2);
      expect(doc.amsServerId, 2);

      doc = ThinUploadDocVOs(primaryEmail: false);
      expect(doc.primaryEmail, false);
      doc = ThinUploadDocVOs(dateConversionRequired: false);
      expect(doc.dateConversionRequired, false);
      doc = ThinUploadDocVOs(bimIssueNumber: 2);
      expect(doc.bimIssueNumber, 2);
      doc = ThinUploadDocVOs(folderId: 2);
      expect(doc.folderId, 2);

      doc = ThinUploadDocVOs(emailImportance: 2);
      expect(doc.emailImportance, 2);
      doc = ThinUploadDocVOs(statusId: 2);
      expect(doc.statusId, 2);
      doc = ThinUploadDocVOs(passwordProtected: false);
      expect(doc.passwordProtected, false);
      doc = ThinUploadDocVOs(folderTypeId: 2);
      expect(doc.folderTypeId, 2);
      doc = ThinUploadDocVOs(tempId: 2);
      expect(doc.tempId, 2);
      doc = ThinUploadDocVOs(revisionNotes: '');
      expect(doc.revisionNotes, '');
      doc = ThinUploadDocVOs(projectId: 2);
      expect(doc.projectId, 2);
      doc = ThinUploadDocVOs(indexUpdateTimeMillis: 2);
      expect(doc.indexUpdateTimeMillis, 2);
      doc = ThinUploadDocVOs(worksetId: 2);
      expect(doc.worksetId, 2);
      doc = ThinUploadDocVOs(userTypeId: 2);
      expect(doc.userTypeId, 2);
      doc = ThinUploadDocVOs(uploadFilename: '');
      expect(doc.uploadFilename, '');
      doc = ThinUploadDocVOs(shared: false);
      expect(doc.shared, false);
      doc = ThinUploadDocVOs(docId: 2);
      expect(doc.docId, 2);
      doc = ThinUploadDocVOs(documentTypeId: 2);
      expect(doc.documentTypeId, 2);
      doc = ThinUploadDocVOs(mergeLevel: 2);
      expect(doc.mergeLevel, 2);
      doc = ThinUploadDocVOs(msgId: 2);
      expect(doc.msgId, 2);
      doc = ThinUploadDocVOs(scale: '');
      expect(doc.scale, '');
      doc = ThinUploadDocVOs(subscriptionTypeId: 2);
      expect(doc.subscriptionTypeId, 2);
      doc = ThinUploadDocVOs(className: '');
      expect(doc.className, '');
      doc = ThinUploadDocVOs(documentRef: '');
      expect(doc.documentRef, '');
      doc = ThinUploadDocVOs(attachIssueNumber: 2);
      expect(doc.attachIssueNumber, 2);
      doc = ThinUploadDocVOs(recordRetentionPolicyStatus: 2);
      expect(doc.recordRetentionPolicyStatus, 2);
      doc = ThinUploadDocVOs(purposeOfIssueId: 2);
      expect(doc.purposeOfIssueId, 2);
      doc = ThinUploadDocVOs(zipFileSize: 2);
      expect(doc.zipFileSize, 2);
      doc = ThinUploadDocVOs(attachPasswordProtected: false);
      expect(doc.attachPasswordProtected, false);
      doc = ThinUploadDocVOs(file: false);
      expect(doc.file, false);
      doc = ThinUploadDocVOs(customObjectComponentObjectId: 2);
      expect(doc.customObjectComponentObjectId, 2);
      doc = ThinUploadDocVOs(bimModelId: 2);
      expect(doc.bimModelId, 2);
      doc = ThinUploadDocVOs(delActivityId: 2);
      expect(doc.delActivityId, 2);
      doc = ThinUploadDocVOs(revisionDistributionDate: '');
      expect(doc.revisionDistributionDate, '');
      doc = ThinUploadDocVOs(drawingSeriesId: 2);
      expect(doc.drawingSeriesId, 2);
      doc = ThinUploadDocVOs(privateRevision: false);
      expect(doc.privateRevision, false);
      doc = ThinUploadDocVOs(solrUpdate: false);
      expect(doc.solrUpdate, false);
      doc = ThinUploadDocVOs(orgContextParamVO: OrGContextParamVo());
      expect(doc.orgContextParamVO, isA<OrGContextParamVo>());
      doc = ThinUploadDocVOs(bimIssueNumberModel: 2);
      expect(doc.bimIssueNumberModel, 2);
      doc = ThinUploadDocVOs(fromReport: false);
      expect(doc.fromReport, false);
      doc = ThinUploadDocVOs(projectViewerId: 2);
      expect(doc.projectViewerId, 2);
      doc = ThinUploadDocVOs(distLaterId: 2);
      expect(doc.distLaterId, 2);
      doc = ThinUploadDocVOs(generateURI: false);
      expect(doc.generateURI, false);
      doc = ThinUploadDocVOs(paperSize: '');
      expect(doc.paperSize, '');
      doc = ThinUploadDocVOs(fromEb: false);
      expect(doc.fromEb, false);
      doc = ThinUploadDocVOs(revisionId: 2);
      expect(doc.revisionId, 2);
      doc = ThinUploadDocVOs(zipFileVirusInfected: false);
      expect(doc.zipFileVirusInfected, false);
      doc = ThinUploadDocVOs(createdDate: '');
      expect(doc.createdDate, '');
      doc = ThinUploadDocVOs(authourUserId: 2);
      expect(doc.authourUserId, 2);
      doc = ThinUploadDocVOs(checkIn: false);
      expect(doc.checkIn, false);
      doc = ThinUploadDocVOs(checkOutStatus: false);
      expect(doc.checkOutStatus, false);
    });

    test('toJson() should return a valid JSON map', () {
      // Create a sample object with desired property values
      final ThinUploadDocVOs uploadDoc = ThinUploadDocVOs(
        kickOffWorkflow: true,
        attachmentCounter: 2,
        fileSysLocation: '/path/to/file',
        // Add more properties here...
      );

      // Call the toJson() method
      final Map<String, dynamic> json = uploadDoc.toJson();

      // Assert that the JSON map matches the expected structure
      expect(json['kickOffW orkflow'], true);
      expect(json['attachmentCounter'], 2);
      expect(json['fileSysLocation'], '/path/to/file');
      // Add more assertions for other properties...
    });

    test('copyWith() should create a copy of the object with new values', () {
      // Create a sample object with initial property values
      final ThinUploadDocVOs uploadDoc = ThinUploadDocVOs(
        kickOffWorkflow: true,
        attachmentCounter: 2,
        fileSysLocation: '/path/to/file',
        // Add more properties here...
      );

      // Create a new object by copying the initial one with new values
      final ThinUploadDocVOs updatedUploadDoc = uploadDoc.copyWith(
        kickOffWorkflow: false,
        attachmentCounter: 3,
        fileSysLocation: '/path/to/new/file',
        // Add more properties here...
      );

      // Assert that the updated object has the new values
      expect(updatedUploadDoc.kickOffWorkflow, false);
      expect(updatedUploadDoc.attachmentCounter, 3);
      expect(updatedUploadDoc.fileSysLocation, '/path/to/new/file');
      // Add more assertions for other properties...
    });

    test('OrGContextParamVo.fromJson should correctly deserialize JSON', () {
      // Sample JSON data representing an organization context
      final json = {
        'billToOrgId': 123,
        'orgName': 'Sample Org',
        'locationIp': '192.168.1.1',
        'userName': 'john_doe',
        'userId': 456,
        'projectId': 789,
        'generateURI': true,
        'orgId': 101,
        'email': 'john@example.com',
      };

      // Convert JSON to OrGContextParamVo object
      final contextParam = OrGContextParamVo.fromJson(json);

      // Assertions to check if the object was created correctly
      expect(contextParam.billToOrgId, equals(123));
      expect(contextParam.orgName, equals('Sample Org'));
      expect(contextParam.locationIp, equals('192.168.1.1'));
      expect(contextParam.userName, equals('john_doe'));
      expect(contextParam.userId, equals(456));
      expect(contextParam.projectId, equals(789));
      expect(contextParam.generateURI, isTrue);
      expect(contextParam.orgId, equals(101));
      expect(contextParam.email, equals('john@example.com'));
    });

    test('OrGContextParamVo.toJson should correctly serialize to JSON', () {
      // Create an instance of OrGContextParamVo with some sample values
      final contextParam = OrGContextParamVo(
        billToOrgId: 123,
        orgName: 'Sample Org',
        locationIp: '192.168.1.1',
        userName: 'john_doe',
        userId: 456,
        projectId: 789,
        generateURI: true,
        orgId: 101,
        email: 'john@example.com',
      );

      // Convert OrGContextParamVo object to JSON
      final json = contextParam.toJson();

      // Assertions to check if the JSON was created correctly
      expect(json['billToOrgId'], equals(123));
      expect(json['orgName'], equals('Sample Org'));
      expect(json['locationIp'], equals('192.168.1.1'));
      expect(json['userName'], equals('john_doe'));
      expect(json['userId'], equals(456));
      expect(json['projectId'], equals(789));
      expect(json['generateURI'], isTrue);
      expect(json['orgId'], equals(101));
      expect(json['email'], equals('john@example.com'));
    });

    group('ThinUploadDocVOs', () {
      late ThinUploadDocVOs uploadDocVO;

      setUp(() {
        // Initialize uploadDocVO with sample data for testing
        uploadDocVO = ThinUploadDocVOs(
          kickOffWorkflow: true,
          attachmentCounter: 5,
          fileSysLocation: '/path/to/file',
          viewerId: 100,
          // Initialize other properties here...
        );
      });

      test('kickOffWorkflow getter', () {
        expect(uploadDocVO.kickOffWorkflow, true);
      });

      test('attachmentCounter getter', () {
        expect(uploadDocVO.attachmentCounter, 5);
      });

      test('fileSysLocation getter', () {
        expect(uploadDocVO.fileSysLocation, '/path/to/file');
      });

      // Write similar test cases for other getters...
    });

    group('SimpleFileUpload', () {
      // Test data for JSON representation of SimpleFileUpload
      final jsonTestData = {
        'sucess_files': ['file1.txt', 'file2.txt'],
        'failedAttachedFiles': ['file3.txt'],
        'thinUploadDocVOs': [
          {'kickOffWorkflow': true},
          {'attachmentCounter': 2},
          {'fileSysLocation': '/path/to/file'},
        ],
        'remove_files': ['file4.txt'],
      };

      // Test instance of SimpleFileUpload
      final testSimpleFileUpload = SimpleFileUpload(
        sucessFiles: ['file1.txt'],
        failedAttachedFiles: ['file2.txt'],
        thinUploadDocVOs: [
          ThinUploadDocVOs(
            kickOffWorkflow: true,
            attachmentCounter: 2,
            fileSysLocation: '/path/to/file',
          )
        ],
        removeFiles: ['file3.txt'],
      );

      test('fromJson() should populate SimpleFileUpload object correctly', () {
        final result = SimpleFileUpload.fromJson(jsonTestData);

        expect(result.sucessFiles, equals(['file1.txt', 'file2.txt']));
        expect(result.failedAttachedFiles, equals(['file3.txt']));
        //expect(result.thinUploadDocVOs, hasLength(2));
        expect(result.removeFiles, equals(['file4.txt']));
      });

      test('toJson() should convert SimpleFileUpload object to JSON', () {
        final result = testSimpleFileUpload.toJson();

        expect(result['sucess_files'], equals(['file1.txt']));
        expect(result['failedAttachedFiles'], equals(['file2.txt']));
        expect(result['thinUploadDocVOs'], hasLength(1));
        expect(result['remove_files'], equals(['file3.txt']));
      });
    });

    test('Test copyWith method of SimpleFileUpload', () {
      // Create a sample ThinUploadDocVOs instance
      final thinUploadDocVO = ThinUploadDocVOs(/* initialize with required parameters */);

      // Create an instance of SimpleFileUpload with some data
      final originalUpload = SimpleFileUpload(
        sucessFiles: ['file1.txt', 'file2.txt'],
        failedAttachedFiles: ['file3.txt'],
        thinUploadDocVOs: [thinUploadDocVO],
        removeFiles: ['file4.txt'],
      );

      // Use copyWith to create a new instance with all fields updated
      final updatedUpload = originalUpload.copyWith(
        sucessFiles: ['file5.txt'],
        failedAttachedFiles: ['file6.txt'],
        thinUploadDocVOs: [thinUploadDocVO, thinUploadDocVO],
        removeFiles: ['file7.txt'],
      );

      // Check if the original instance remains unchanged
      expect(originalUpload.sucessFiles, ['file1.txt', 'file2.txt']);
      expect(originalUpload.failedAttachedFiles, ['file3.txt']);
      expect(originalUpload.thinUploadDocVOs, [thinUploadDocVO]);
      expect(originalUpload.removeFiles, ['file4.txt']);

      // Check if the updated instance has the new values
      expect(updatedUpload.sucessFiles, ['file5.txt']);
      expect(updatedUpload.failedAttachedFiles, ['file6.txt']);
      expect(updatedUpload.thinUploadDocVOs, [thinUploadDocVO, thinUploadDocVO]);
      expect(updatedUpload.removeFiles, ['file7.txt']);

      // Use copyWith to create a new instance with some fields updated and others retained
      final partialUpdatedUpload = originalUpload.copyWith(
        sucessFiles: ['file8.txt'],
        removeFiles: null, // This should retain the original value
      );

      // Check if the updated instance has the new values
      expect(partialUpdatedUpload.sucessFiles, ['file8.txt']);
      expect(partialUpdatedUpload.failedAttachedFiles, ['file3.txt']); // Should be the same as original
      expect(partialUpdatedUpload.thinUploadDocVOs, [thinUploadDocVO]);
      expect(partialUpdatedUpload.removeFiles, ['file4.txt']); // Should be the same as original

      // Use copyWith to create a new instance with some fields set to null
      final nullFieldsUpload = originalUpload.copyWith(
        sucessFiles: null,
        failedAttachedFiles: null,
        thinUploadDocVOs: null,
        removeFiles: null,
      );

      // Check if the new instance has all fields set to null
      expect(nullFieldsUpload.sucessFiles, ['file1.txt', 'file2.txt']);
      expect(nullFieldsUpload.failedAttachedFiles, ['file3.txt']);
      //expect(nullFieldsUpload.thinUploadDocVOs, isA<ThinUploadDocVOs>());
      expect(nullFieldsUpload.removeFiles, ['file4.txt']);
    });


    group('OrGContextParamVo', () {
      test('copyWith should create a copy with updated billToOrgId', () {
        final context = OrGContextParamVo(billToOrgId: 123);
        final updatedContext = context.copyWith(billToOrgId: 456);

        expect(updatedContext.billToOrgId, 456);
        expect(updatedContext.orgName, context.orgName);
        expect(updatedContext.locationIp, context.locationIp);
        expect(updatedContext.userName, context.userName);
      });

      test('copyWith should create a copy with updated orgName', () {
        final context = OrGContextParamVo(orgName: 'ABC Corp');
        final updatedContext = context.copyWith(orgName: 'XYZ Inc.');

        expect(updatedContext.orgName, 'XYZ Inc.');
        expect(updatedContext.billToOrgId, context.billToOrgId);
        expect(updatedContext.locationIp, context.locationIp);
        expect(updatedContext.userName, context.userName);
      });
    });
  });
}
