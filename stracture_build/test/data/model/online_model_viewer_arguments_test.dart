import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/online_model_viewer_arguments.dart';
import 'package:field/data/model/online_model_viewer_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineModelViewerArguments Test', () {
    test('toJson() should return a valid JSON map', () {
      final onlineViewerModelRequestModel = OnlineViewerModelRequestModel(
        modelName: 'Test Model',
        modelId: '12345',
        isSelectedModel: true,
      );

      final model= Model(
        modelId: "1",
        bimModelId: "model1",
        projectId: "project1",
        projectName: "Project 1",
        bimModelName: "Model 1",
        modelDescription: "Description 1",
        userModelName: "User Model 1",
        workPackageId: 101,
        modelCreatorUserId: "user1",
        modelStatus: true,
        modelCreationDate: "2023-07-01",
        lastUpdateDate: "2023-07-25",
        mergeLevel: 2,
        isFavoriteModel: 1,
        dc: "",
        modelViewId: 201,
        revisionId: "revision1",
        folderId: "folder1",
        revisionNumber: 1,
        worksetId: "workset1",
        docId: "doc1",
        publisher: "Publisher 1",
        lastUpdatedUserId: "user2",
        lastUpdatedBy: "User 2",
        lastAccessUserId: "user3",
        lastAccessBy: "User 3",
        lastAccessModelDate: "2023-07-20",
        modelTypeId: 301,
        generateUri: true,
        setAsOffline: false,
        isDropOpen: true,
        isDownload: true,
        fileSize: "1024 KB",
      );

      final onlineModelViewerArguments = OnlineModelViewerArguments(projectId: '0\$\$ZQZZEA', isShowSideToolBar: false, onlineViewerModelRequestModel:onlineViewerModelRequestModel, offlineParams: {}, model: model);

      final jsonMap = onlineModelViewerArguments.toJson();

      final expectedJsonMap = {
        "projectId": '0\$\$ZQZZEA',
        "isShowSideToolBar": false,
        "onlineViewerModelRequestModel": onlineViewerModelRequestModel,
        "offlineParams": {},
        "model": model,
      };

      expect(jsonMap, equals(expectedJsonMap));
    });

    test('fromJson() should correctly parse a JSON map', () {
      final onlineViewerModelRequestModel = OnlineViewerModelRequestModel(
        modelName: 'Test Model',
        modelId: '12345',
        isSelectedModel: true,
      );

      final model= Model(
        modelId: "1",
        bimModelId: "model1",
        projectId: "project1",
        projectName: "Project 1",
        bimModelName: "Model 1",
        modelDescription: "Description 1",
        userModelName: "User Model 1",
        workPackageId: 101,
        modelCreatorUserId: "user1",
        modelStatus: true,
        modelCreationDate: "2023-07-01",
        lastUpdateDate: "2023-07-25",
        mergeLevel: 2,
        isFavoriteModel: 1,
        dc: "",
        modelViewId: 201,
        revisionId: "revision1",
        folderId: "folder1",
        revisionNumber: 1,
        worksetId: "workset1",
        docId: "doc1",
        publisher: "Publisher 1",
        lastUpdatedUserId: "user2",
        lastUpdatedBy: "User 2",
        lastAccessUserId: "user3",
        lastAccessBy: "User 3",
        lastAccessModelDate: "2023-07-20",
        modelTypeId: 301,
        generateUri: true,
        setAsOffline: false,
        isDropOpen: true,
        isDownload: true,
        fileSize: "1024 KB",
      );
      final jsonMap = {
        "projectId": '0\$\$ZQZZEA',
        "isShowSideToolBar": false,
        "onlineViewerModelRequestModel": onlineViewerModelRequestModel,
        "model": model,
        "offlineParams": {
          "test":"test"
        },
      };

      final onlineModelViewerArguments = OnlineModelViewerArguments.fromJson(jsonMap);

      expect(onlineModelViewerArguments.projectId, equals('0\$\$ZQZZEA'));
      expect(onlineModelViewerArguments.isShowSideToolBar, equals(false));
      expect(onlineModelViewerArguments.offlineParams, equals({
        "test":"test"
      }));
    });

    // test('toJson() and fromJson() should be consistent', () {
    //   final model = OnlineViewerModelRequestModel(
    //     modelName: 'Test Model',
    //     modelId: '12345',
    //     isSelectedModel: true,
    //   );
    //
    //   final jsonMap = model.toJson();
    //   final parsedModel = OnlineViewerModelRequestModel.fromJson(jsonMap);
    //
    //   expect(parsedModel.modelName, equals(model.modelName));
    //   expect(parsedModel.modelId, equals(model.modelId));
    //   expect(parsedModel.isSelectedModel, equals(model.isSelectedModel));
    // });
    //
    // test('props should return an empty list', () {
    //   final data = OnlineViewerModelRequestModel(
    //     modelName: 'Test Model',
    //     modelId: '12345',
    //     isSelectedModel: true,
    //   );
    //
    //   final props = data.props;
    //
    //   expect(props, isEmpty);
    // });
    //
    //
    // test('fromJson should parse valid JSON correctly', () {
    //   // Test the fromJson method (same as previous test).
    // });
    //
    // test('toJson should encode valid object correctly', () {
    //   // Test the toJson method (same as previous test).
    // });
  });
}
