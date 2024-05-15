import 'package:field/data/dao/form_dao.dart';
import 'package:field/data_source/filter/filter_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() async {
  FilterLocalDataSource dbManager = FilterLocalDataSource();
  dbManager.databaseManager = MockDatabaseManager();

  group("FilterLocalDataSource Test", () {
    test("getFilterAttributeValueList fail test", () async {
      when(() => dbManager.databaseManager.executeSelectFromTable(any(), any()))
          .thenAnswer((_) {
        return [{}];
      });
      var result = await dbManager.getFilterAttributeValueList({});
      expect(result is FAIL, true);
    });

    test("getFilterAttributeValueList Form Type success test", () async {
      String query = "SELECT DISTINCT FormTypeName AS Id, FormTypeName AS Value FROM FormGroupAndFormTypeListTbl"
          "\nWHERE ProjectId IN (2130192)"
          "\nORDER BY Value COLLATE NOCASE ASC"
          "\nLIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": "Attachment", "Value": "Attachment"}, {"Id": "AttachmentAssoc", "Value": "AttachmentAssoc"}, {"Id": "Defect", "Value": "Defect"}, {"Id": "Discussion", "Value": "Discussion"}, {"Id": "Edit and Forward/Distribute", "Value": "Edit and Forward/Distribute"}, {"Id": "Edit ORI", "Value": "Edit ORI"}, {"Id": "HTML Base Form", "Value": "HTML Base Form"}, {"Id": "Site Tasks", "Value": "Site Tasks"}, {"Id": "Site V3", "Value": "Site V3"}, {"Id": "test_html", "Value": "test_html"}]);
      final param = {"appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":860,\"fieldName\":\"Form Type\",\"indexField\":\"form_type_name\",\"labelName\":\"Form Type\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"Text\",\"solrCollections\":\"forms\",\"returnIndexFields\":\"form_type_name,form_type_id\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"form_type_name\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":10,\"recordBatchSize\":10,\"data\":[{\"id\":\"Attachment\",\"value\":\"Attachment\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"AttachmentAssoc\",\"value\":\"AttachmentAssoc\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Defect\",\"value\":\"Defect\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Discussion\",\"value\":\"Discussion\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Edit and Forward/Distribute\",\"value\":\"Edit and Forward/Distribute\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Edit ORI\",\"value\":\"Edit ORI\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"HTML Base Form\",\"value\":\"HTML Base Form\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Site Tasks\",\"value\":\"Site Tasks\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Site V3\",\"value\":\"Site V3\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"test_html\",\"value\":\"test_html\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList Originator success test", () async {
      String query = "SELECT DISTINCT OriginatorId AS Id,OriginatorDisplayName COLLATE NOCASE AS Value FROM FormListTbl"
          "\nWHERE ProjectId IN (2130192)"
          "\nORDER BY Value COLLATE NOCASE ASC"
          "\nLIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": 2017529, "Value": "Mayur Raval m., Asite Solutions Ltd"}, {"Id": 859155, "Value": "Saurabh Banethia (5327), Asite Solutions"}, {"Id": 707447, "Value": "Vijay Mavadiya (5336), Asite Solutions"}]);
      final param = {"appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":764,\"fieldName\":\"Originator\",\"indexField\":\"originator_user_id\",\"labelName\":\"Originator\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"Text\",\"solrCollections\":\"users\",\"returnIndexFields\":\"originator_user_id\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"originator_user_id\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":3,\"recordBatchSize\":10,\"data\":[{\"id\":2017529,\"value\":\"Mayur Raval m., Asite Solutions Ltd\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":859155,\"value\":\"Saurabh Banethia (5327), Asite Solutions\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":707447,\"value\":\"Vijay Mavadiya (5336), Asite Solutions\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList Originator Org success test", () async {
      String query = "SELECT DISTINCT OrgId AS Id,OrgName COLLATE NOCASE AS Value FROM FormListTbl"
          "\nWHERE ProjectId IN (2130192)"
          "\nORDER BY Value COLLATE NOCASE ASC"
          "\nLIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": 3, "Value": "Asite Solutions"}, {"Id": 5763307, "Value": "Asite Solutions Ltd"}]);
      final param = {"appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":765,\"fieldName\":\"Originator Organisation\",\"indexField\":\"originator_organisation\",\"labelName\":\"Originator Organisation\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"Text\",\"solrCollections\":\"users\",\"returnIndexFields\":\"orgId,orgName\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"originator_organisation\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":2,\"recordBatchSize\":10,\"data\":[{\"id\":3,\"value\":\"Asite Solutions\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":5763307,\"value\":\"Asite Solutions Ltd\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList Recipient success test", () async {
      String query = "SELECT DISTINCT RecipientUserId AS Id,RecipientName COLLATE NOCASE AS Value FROM FormMsgActionListTbl"
          "\nWHERE ProjectId IN (2130192)"
          "\nORDER BY Value COLLATE NOCASE ASC"
          "\nLIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": "2017529", "Value": "Mayur Raval m., Asite Solutions Ltd"}]);
      final param = {"appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":380,\"fieldName\":\"Recipient\",\"indexField\":\"distribution_list\",\"labelName\":\"Recipient\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"Text\",\"solrCollections\":\"users\",\"returnIndexFields\":\"distribution_list\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"distribution_list\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":1,\"recordBatchSize\":10,\"data\":[{\"id\":\"2017529\",\"value\":\"Mayur Raval m., Asite Solutions Ltd\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList Recipient Org success test", () async {
      String query = "SELECT DISTINCT RecipientOrgId AS Id,TRIM(SUBSTR(RecipientName,INSTR(RecipientName,',')+1,LENGTH(RecipientName))) COLLATE NOCASE AS Value FROM FormMsgActionListTbl"
          "\nWHERE ProjectId IN (2130192)"
          "\nORDER BY Value COLLATE NOCASE ASC"
          "\nLIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": "5763307", "Value": "Asite Solutions Ltd"}]);
      final param = {"appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":767,\"fieldName\":\"Recipient Organization\",\"indexField\":\"recipient_org\",\"labelName\":\"Recipient Organization\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"Text\",\"solrCollections\":\"users\",\"returnIndexFields\":\"orgId,orgName\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"recipient_org\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":1,\"recordBatchSize\":10,\"data\":[{\"id\":\"5763307\",\"value\":\"Asite Solutions Ltd\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList Status success test", () async {
      String query = "SELECT DISTINCT StatusName COLLATE NOCASE AS Id, StatusName COLLATE NOCASE AS Value FROM FormListTbl"
          "\nWHERE ProjectId IN (2130192)"
          "\nORDER BY Value COLLATE NOCASE ASC"
          "\nLIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": "Open", "Value": "Open"}, {"Id": "Resolved", "Value": "Resolved"}, {"Id": "Verified", "Value": "Verified"}]);
      final param = {"appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":364,\"fieldName\":\"Status\",\"indexField\":\"form_status\",\"labelName\":\"Status\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"text\",\"solrCollections\":\"docstatuscache\",\"returnIndexFields\":\"status_id,status_name\",\"optionalValues\":\"-1\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"form_status\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":3,\"recordBatchSize\":10,\"data\":[{\"id\":\"Open\",\"value\":\"Open\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Resolved\",\"value\":\"Resolved\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Verified\",\"value\":\"Verified\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList Status with search value success test", () async {
      String query = "SELECT DISTINCT StatusName COLLATE NOCASE AS Id, StatusName COLLATE NOCASE AS Value FROM FormListTbl"
          "\nWHERE ProjectId IN (2130192)"
          "\nAND Value LIKE ('%res%')"
          "\nORDER BY Value COLLATE NOCASE ASC"
          "\nLIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": "Resolved", "Value": "Resolved"}]);
      final param = {"searchValue": "res", "appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":364,\"fieldName\":\"Status\",\"indexField\":\"form_status\",\"labelName\":\"Status\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"text\",\"solrCollections\":\"docstatuscache\",\"returnIndexFields\":\"status_id,status_name\",\"optionalValues\":\"-1\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"form_status\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":1,\"recordBatchSize\":10,\"data\":[{\"id\":\"Resolved\",\"value\":\"Resolved\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList CFID_TaskType with search value success test", () async {
      String query = "SELECT DISTINCT TaskTypeName COLLATE NOCASE AS Id,TaskTypeName COLLATE NOCASE AS Value FROM FormListTbl\n"
          "WHERE ProjectId IN (2130192)\n"
          "AND Value LIKE ('%arc^_test%') ESCAPE '^'\n"
          "ORDER BY Value COLLATE NOCASE ASC\n"
          "LIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": "arc_test 1", "Value": "arc_test 1"}]);
      final param = {"searchValue": "arc_test", "appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":364,\"fieldName\":\"Task Type\",\"indexField\":\"CFID_TaskType\",\"labelName\":\"Task Type\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"text\",\"solrCollections\":\"docstatuscache\",\"returnIndexFields\":\"status_id,status_name\",\"optionalValues\":\"-1\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"form_status\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":1,\"recordBatchSize\":10,\"data\":[{\"id\":\"arc_test 1\",\"value\":\"arc_test 1\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });

    test("getFilterAttributeValueList CFID_DefectTyoe success test", () async {
      String query = "SELECT DISTINCT ObservationDefectType COLLATE NOCASE AS Id, ObservationDefectType COLLATE NOCASE AS Value FROM FormListTbl\n"
          "WHERE ProjectId IN (2130192)\n"
          "ORDER BY Value COLLATE NOCASE ASC\n"
          "LIMIT 0,10";
      when(() => dbManager.databaseManager.executeSelectFromTable(FormDao.tableName, query))
          .thenReturn([{"Id": "Civil", "Value": "Civil"}, {"Id": "Electrical", "Value": "Electrical"}]);
      final param = {"appType": "2", "checkHashing": "false", "action_id": "707", "isFromDeviceFilter": "true", "isBlankSearchAllowed": "false", "jsonData": "{\"id\":364,\"fieldName\":\"Defect Type\",\"indexField\":\"CFID_DefectTyoe\",\"labelName\":\"Defect Type\",\"subListingTypeId\":2,\"listingTypeId\":31,\"dataType\":\"text\",\"solrCollections\":\"docstatuscache\",\"returnIndexFields\":\"status_id,status_name\",\"optionalValues\":\"-1\",\"operatorsId\":\"1,2\",\"isCustomAttribute\":false,\"operatorId\":0,\"popupTo\":{\"totalDocs\":0,\"recordBatchSize\":0,\"isSortRequired\":true,\"isReviewEnableProjectSelected\":false,\"isAmessageProjectSelected\":false,\"generateURI\":true},\"isBlankSearchAllowed\":false,\"languageKey\":\"form_status\",\"listingColumnFieldName\":\"-1\",\"digitSeparatorEnabled\":false,\"generateURI\":true}", "recordBatchSize": "10", "projectIds": "2130192", "selectedFolderIds": "-1", "selectedProjectIds": "-1", "isFromSyncCall": "true"};
      var result = await dbManager.getFilterAttributeValueList(param);
      expect(result is SUCCESS, true);
      String outputData = "{\"totalDocs\":2,\"recordBatchSize\":10,\"data\":[{\"id\":\"Civil\",\"value\":\"Civil\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true},{\"id\":\"Electrical\",\"value\":\"Electrical\",\"dataCenterId\":0,\"isSelected\":false,\"isActive\":true}],\"isSortRequired\":true,\"generateURI\":true}";
      expect(result.data == outputData, true);
    });
  });
}