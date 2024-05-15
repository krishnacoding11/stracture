import 'package:field/data/model/model_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModelList', () {
    test('modelListFromJson should correctly parse JSON data', () {
      final jsonData = '''
        {
          "totalDocs": 10,
          "recordBatchSize": 5,
          "listingType": 1,
          "currentPageNo": 1,
          "recordStartFrom": 1,
          "columnHeader": [
            {
              "id": "1",
              "fieldName": "field1",
              "solrIndexfieldName": "solrField1",
              "colDisplayName": "Column 1",
              "colType": "string",
              "userIndex": 1,
              "imgName": "",
              "tooltipSrc": "",
              "dataType": "text",
              "function": "",
              "funParams": "",
              "wrapData": "",
              "widthOfColumn": 100,
              "isSortSupported": true,
              "isCustomAttributeColumn": false,
              "isActive": true,
              "isFavoriteModel": null
            }
          ],
          "data": [
            {
              "modelId": "1",
              "bimModelId": "model1",
              "projectId": "project1",
              "projectName": "Project 1",
              "bimModelName": "Model 1",
              "modelDescription": "Description 1",
              "userModelName": "User Model 1",
              "workPackageId": 101,
              "modelCreatorUserId": "user1",
              "modelStatus": true,
              "modelCreationDate": "2023-07-01",
              "lastUpdateDate": "2023-07-25",
              "mergeLevel": 2,
              "isFavoriteModel": 1,
              "dc": "",
              "modelViewId": 201,
              "revisionId": "revision1",
              "folderId": "folder1",
              "revisionNumber": 1,
              "worksetId": "workset1",
              "docId": "doc1",
              "publisher": "Publisher 1",
              "lastUpdatedUserId": "user2",
              "lastUpdatedBy": "User 2",
              "lastAccessUserId": "user3",
              "lastAccessBy": "User 3",
              "lastAccessModelDate": "2023-07-20",
              "modelTypeId": 301,
              "worksetdetails": {},
              "workingFolders": {},
              "generateURI": true,
              "setAsOffline": false,
              "isDropOpen": true,
              "isDownload": true,
              "fileSize": "1024 KB",
              "downloadProgress": "50%"
            }
          ],
          "viewType": "table",
          "sortField": "field1",
          "sortFieldType": "string",
          "sortOrder": "asc",
          "editable": true,
          "isIncludeSubFolder": false,
          "totalListData": 100
        }
      ''';

      final modelList = modelListFromJson(jsonData);

      expect(modelList.totalDocs, 10);
      expect(modelList.recordBatchSize, 5);
      expect(modelList.listingType, 1);
      // ... (Add similar expect statements for other properties)
      expect(modelList.columnHeader.length, 1);
      expect(modelList.data.length, 1);
    });

    test('modelListToJson should correctly convert ModelList instance to JSON', () {
      final modelList = ModelList(
        totalDocs: 10,
        recordBatchSize: 5,
        listingType: 1,
        columnHeader: [
          ColumnHeader(
            id: "1",
            fieldName: "field1",
            solrIndexfieldName: "solrField1",
            colDisplayName: "Column 1",
            colType: "string",
            userIndex: 1,
            imgName: ImgName.empty,
            tooltipSrc: "",
            dataType: "text",
            function: "",
            funParams: "",
            wrapData: "",
            widthOfColumn: 100,
            isSortSupported: true,
            isCustomAttributeColumn: false,
            isActive: true,
            isFavoriteModel: null,
          ),
        ],
        data: [
          Model(
            modelId: "1",
            bimModelId: "model1",
            projectId: "project1",
            fileSize: "1024 KB",
            downloadProgress: "50%",
          ),
        ],
        currentPageNo: 1,
        recordStartFrom: 1,
        viewType: '',
        sortField: '',
        sortFieldType: '',
        sortOrder: '',
        editable: false,
        isIncludeSubFolder: false,
        totalListData: 1,
      );

      final jsonData = modelListToJson(modelList);

      final expectedJson =
          '''{"totalDocs":10,"recordBatchSize":5,"listingType":1,"currentPageNo":1,"recordStartFrom":1,"columnHeader":[{"id":"1","fieldName":"field1","solrIndexfieldName":"solrField1","colDisplayName":"Column 1","colType":"string","userIndex":1,"imgName":"","tooltipSrc":"","dataType":"text","function":"","funParams":"","wrapData":"","widthOfColumn":100,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":true,"isFavoriteModel":null}],"data":[{"modelId":"1","bimModelId":"model1","projectId":"project1","projectName":null,"bimModelName":null,"modelDescription":null,"userModelName":null,"workPackageId":null,"modelCreatorUserId":null,"modelStatus":null,"modelCreationDate":null,"lastUpdateDate":null,"mergeLevel":null,"isFavoriteModel":null,"dc":null,"modelViewId":null,"revisionId":null,"folderId":null,"revisionNumber":null,"worksetId":null,"docId":null,"publisher":null,"lastUpdatedUserId":null,"lastUpdatedBy":null,"lastAccessUserId":null,"lastAccessBy":null,"lastAccessModelDate":null,"modelTypeId":null,"worksetdetails":null,"workingFolders":null,"generateURI":null,"setAsOffline":null,"isDropOpen":null,"isDownload":null,"fileSize":"1024 KB"}],"viewType":"","sortField":"","sortFieldType":"","sortOrder":"","editable":false,"isIncludeSubFolder":false,"totalListData":1}''';

      expect(jsonData, expectedJson);
    });

    test('modelVoNewFromJson should correctly parse a list of Model from JSON', () {
      final jsonData = '''
        [
          {
            "modelId": "1",
            "bimModelId": "model1",
            "projectId": "project1",
            "fileSize": "1024 KB",
            "downloadProgress": "50%"
          },
          {
            "modelId": "2",
            "bimModelId": "model2",
            "projectId": "project2",
            "fileSize": "2048 KB",
            "downloadProgress": "75%"
          }
        ]
      ''';

      final modelList = modelVoNewFromJson(jsonData);

      expect(modelList.length, 2);

      final model1 = modelList[0];
      expect(model1.modelId, "1");
      expect(model1.bimModelId, "model1");
      // ... (Add similar expect statements for other properties of model1)

      final model2 = modelList[1];
      expect(model2.modelId, "2");
      expect(model2.bimModelId, "model2");
      // ... (Add similar expect statements for other properties of model2)
    });

    test('modelVoNewToJson should correctly convert a list of Model to JSON', () {
      final models = [
        Model(
          modelId: "1",
          bimModelId: "model1",
          projectId: "project1",
          fileSize: "1024 KB",
          downloadProgress: "50%",
        ),
        Model(
          modelId: "2",
          bimModelId: "model2",
          projectId: "project2",
          fileSize: "2048 KB",
          downloadProgress: "75%",
        ),
      ];

      final jsonData = modelVoNewToJson(models);

      final expectedJson =
          '''[{"modelId":"1","bimModelId":"model1","projectId":"project1","projectName":null,"bimModelName":null,"modelDescription":null,"userModelName":null,"workPackageId":null,"modelCreatorUserId":null,"modelStatus":null,"modelCreationDate":null,"lastUpdateDate":null,"mergeLevel":null,"isFavoriteModel":null,"dc":null,"modelViewId":null,"revisionId":null,"folderId":null,"revisionNumber":null,"worksetId":null,"docId":null,"publisher":null,"lastUpdatedUserId":null,"lastUpdatedBy":null,"lastAccessUserId":null,"lastAccessBy":null,"lastAccessModelDate":null,"modelTypeId":null,"worksetdetails":null,"workingFolders":null,"generateURI":null,"setAsOffline":null,"isDropOpen":null,"isDownload":null,"fileSize":"1024 KB","modelId":"2","bimModelId":"model2","projectId":"project2","projectName":null,"bimModelName":null,"modelDescription":null,"userModelName":null,"workPackageId":null,"modelCreatorUserId":null,"modelStatus":null,"modelCreationDate":null,"lastUpdateDate":null,"mergeLevel":null,"isFavoriteModel":null,"dc":null,"modelViewId":null,"revisionId":null,"folderId":null,"revisionNumber":null,"worksetId":null,"docId":null,"publisher":null,"lastUpdatedUserId":null,"lastUpdatedBy":null,"lastAccessUserId":null,"lastAccessBy":null,"lastAccessModelDate":null,"modelTypeId":null,"worksetdetails":null,"workingFolders":null,"generateURI":null,"setAsOffline":null,"isDropOpen":null,"isDownload":null,"fileSize":"2048 KB"}]''';

      expect(jsonData, expectedJson);
    });

    test('fromJson should create a Work object from JSON', () {
      // Arrange
      final json = {'someKey': 'someValue'};

      // Act
      final work = Work.fromJson(json);

      // Assert
      expect(work, isA<Work>());
      // Add more assertions based on your expected behavior
    });

    test('toJson should convert a Work object to JSON', () {
      // Arrange
      final work = Work();

      // Act
      final json = work.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
    });

    test('props getter should return a list of all properties', () {
      // Arrange
      final model = Model(
        modelId: '123',
        bimModelId: '456',
        projectId: '789',
      );

      // Act
      final props = model.props;

      // Assert
      expect(props, isA<List<Object?>>());
      expect(
          props,
          containsAllInOrder([
            '123',
            '456',
            '789',
          ]));
    });
  });
}
