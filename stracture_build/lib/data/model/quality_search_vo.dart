import 'dart:convert';

import 'package:field/data/model/quality_plan_list_vo.dart';

/// filterResponse : {"filterVOs":[{"id":2538478,"userId":2017529,"filterName":"Unsaved Filter","listingTypeId":134,"subListingTypeId":1,"isUnsavedFilter":true,"creationDate":"2023-04-17 13:08:08.903","filterQueryVOs":[{"id":14333411,"filterId":2538478,"fieldName":"summary","operatorId":11,"logicalOperator":"null","sequenceId":1,"returnIndexFields":"null","dataType":"Text","solrCollections":"-1","labelName":"Contains Text","optionalValues":"null","popupTo":{"totalDocs":0,"recordBatchSize":0,"data":[{"id":"test","value":"test","dataCenterId":0,"isSelected":true,"imgId":-1,"isActive":true}],"isSortRequired":true,"isReviewEnableProjectSelected":false,"isAmessageProjectSelected":false,"generateURI":true},"indexField":"summary","isCustomAttribute":false,"inputDataTypeId":0,"isBlankSearchAllowed":true,"supportDashboardWidget":false,"isMultipleAttributeWithSameName":false,"digitSeparatorEnabled":false,"generateURI":true}],"isFavorite":false,"isRecent":false,"isMyAction":false,"docCount":0,"isEditable":true,"isShared":false,"originatorName":"Mayur Raval m.","originatorId":2017529,"userAccesibleDCIds":[1],"isAccessByDashboardShareOnly":false,"dueDateId":0,"generateURI":true}]}
/// filterData : {"totalDocs":45,"recordBatchSize":250,"listingType":134,"currentPageNo":1,"recordStartFrom":0,"columnHeader":[{"id":"0","fieldName":"planId","solrIndexfieldName":"id","colDisplayName":"","colType":"checkbox","userIndex":0,"imgName":"","tooltipSrc":"","dataType":"checkbox","function":"","funParams":"","wrapData":"","widthOfColumn":35,"isSortSupported":false,"isCustomAttributeColumn":false,"isActive":false},{"id":"6","fieldName":"percentageCompletion","solrIndexfieldName":"percentage_completion","colDisplayName":"% Completion","colType":"number","userIndex":2,"imgName":"","tooltipSrc":"per-completion","dataType":"number","function":"","funParams":"","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"2","fieldName":"createdByUser","solrIndexfieldName":"created_by_name","colDisplayName":"Created By","colType":"imgwithtext","userIndex":3,"imgName":"","tooltipSrc":"createdByName","dataType":"imgwithtext","function":"showUserContactCard","funParams":"createdByUserid","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"3","fieldName":"planCreationDate","solrIndexfieldName":"plan_creation_date","colDisplayName":"Created Date","colType":"text","userIndex":4,"imgName":"","tooltipSrc":"planCreationDate","dataType":"timestamp","function":"","funParams":"","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"4","fieldName":"lastUpdatedUser","solrIndexfieldName":"last_updated_by_name","colDisplayName":"Last Updated By","colType":"imgwithtext","userIndex":5,"imgName":"","tooltipSrc":"lastupdatedbyName","dataType":"imgwithtext","function":"showUserContactCard","funParams":"updatedById","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"5","fieldName":"lastupdatedate","solrIndexfieldName":"last_updated_on","colDisplayName":"Last Updated On","colType":"text","userIndex":6,"imgName":"","tooltipSrc":"lastupdatedate","dataType":"timestamp","function":"","funParams":"","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"1","fieldName":"planTitle","solrIndexfieldName":"title","colDisplayName":"Title","colType":"text","userIndex":1,"imgName":"","tooltipSrc":"title","dataType":"text","function":"viewTestPlan","funParams":"planId, planTitle, projectId, projectName, dcId, percentageCompletion","wrapData":"","widthOfColumn":157,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false}],"data":[{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5368$$rIc2XS","planTitle":"Test plan 1","percentageCompletion":0,"createdBy":"1906453","createdByUserid":"1906453$$fMqcZy","planCreationDate":"12-Apr-2023#00:11 PST","createdByName":"hardik111 Asite, Asite Solutions Ltd","lastupdatedate":"12-Apr-2023#00:22 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1681284177000,"planCreationDateInMS":1681283465000,"firstName":"hardik111","lastName":"Asite","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5359$$SwSCkv","planTitle":"TestNew","percentageCompletion":3,"createdBy":"1906453","createdByUserid":"1906453$$fMqcZy","planCreationDate":"09-Apr-2023#22:36 PST","createdByName":"hardik111 Asite, Asite Solutions Ltd","lastupdatedate":"11-Apr-2023#05:17 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1681215452000,"planCreationDateInMS":1681104969000,"firstName":"hardik111","lastName":"Asite","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5364$$u6J5a1","planTitle":"TestPerf","percentageCompletion":0,"createdBy":"1925069","createdByUserid":"1925069$$JSw9uw","planCreationDate":"10-Apr-2023#21:21 PST","createdByName":"Shubham Patidar, Asite Solutions","lastupdatedate":"10-Apr-2023#23:27 PST","updatedById":"1925069$$JSw9uw","lastupdatedbyName":"Shubham Patidar, Asite Solutions","updatedDateInMS":1681194450000,"planCreationDateInMS":1681186905000,"firstName":"Shubham","lastName":"Patidar","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/no_image.jpg#Shubham","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/no_image.jpg#Shubham","lastUpdatedUserFname":"Shubham","lastUpdatedUserLname":"Patidar","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"522$$SaytK1","planTitle":"Test Cdp","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"07-Jul-2021#22:15 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1625721313000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5184$$WXsBTb","planTitle":"test","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"24-May-2022#23:44 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1653461071000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5183$$FZpfdC","planTitle":"Test Demo DV0001","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"23-May-2022#03:50 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1653303007000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5176$$DaBBBZ","planTitle":"Test Export Plan DV","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"02-May-2022#03:59 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1651489148000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5136$$duBdBH","planTitle":"testtest","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"17-Feb-2022#04:09 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1645099775000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5034$$QAynNn","planTitle":"Test-1334","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"22-Sep-2021#23:57 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1632380243000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"4620$$ZzV1GS","planTitle":"Test 1093","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"24-Aug-2021#23:07 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1629871656000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"300$$cf4wND","planTitle":"Pin - DV TEst 150601","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"14-Jun-2021#23:41 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623739275000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"293$$nzMoc4","planTitle":"Test0002","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"13-Jun-2021#23:44 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623653067000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"285$$3GH1lU","planTitle":"Test0001","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"11-Jun-2021#08:15 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623424527000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"283$$k00aZP","planTitle":"Test Copy Location 002","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"11-Jun-2021#04:20 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623410424000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"282$$MiSBox","planTitle":"Test Copy Location 001","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"11-Jun-2021#04:06 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623409589000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"1867$$0vElSF","planTitle":"test draft 123","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"15-Jul-2021#01:49 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1626338949000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5353$$8Te2RA","planTitle":"TestPerformance","percentageCompletion":0,"createdBy":"1906453","createdByUserid":"1906453$$fMqcZy","planCreationDate":"05-Apr-2023#21:59 PST","createdByName":"hardik111 Asite, Asite Solutions Ltd","lastupdatedate":"09-Apr-2023#22:47 PST","updatedById":"1906453$$fMqcZy","lastupdatedbyName":"hardik111 Asite, Asite Solutions Ltd","updatedDateInMS":1681105659000,"planCreationDateInMS":1680757169000,"firstName":"hardik111","lastName":"Asite","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUserFname":"hardik111","lastUpdatedUserLname":"Asite","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"4615$$Xjn9co","planTitle":"test","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"20-Aug-2021#03:01 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"07-Apr-2023#05:17 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1680869836000,"planCreationDateInMS":1629453667000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5358$$JvM9fJ","planTitle":"Test Plan","percentageCompletion":1,"createdBy":"2017529","createdByUserid":"2017529$$RfZJh0","planCreationDate":"07-Apr-2023#04:55 PST","createdByName":"Mayur Raval m., Asite Solutions Ltd","lastupdatedate":"07-Apr-2023#05:06 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1680869210000,"planCreationDateInMS":1680868532000,"firstName":"Mayur","lastName":"Raval m.","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5346$$wgY078","planTitle":"Test Demo 1022","percentageCompletion":1,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"27-Mar-2023#06:20 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"07-Apr-2023#05:02 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1680868948000,"planCreationDateInMS":1679923233000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5280$$SvVxlK","planTitle":"testquality","percentageCompletion":0,"createdBy":"752058","createdByUserid":"752058$$1ZoQpI","planCreationDate":"14-Nov-2022#21:57 PST","createdByName":"Achal Shah (5361), Asite Solutions","lastupdatedate":"21-Mar-2023#23:30 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1679466646000,"planCreationDateInMS":1668491864000,"firstName":"Achal","lastName":"Shah (5361)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_752058_thumbnail.jpg?v=1657276387000#Achal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5318$$ZqubgZ","planTitle":"hb test1","percentageCompletion":0,"createdBy":"726145","createdByUserid":"726145$$cyKQQi","planCreationDate":"12-Mar-2023#22:14 PST","createdByName":"hardik bhow (5321), Asite Solutions","lastupdatedate":"13-Mar-2023#04:07 PST","updatedById":"1906453$$fMqcZy","lastupdatedbyName":"hardik111 Asite, Asite Solutions Ltd","updatedDateInMS":1678705657000,"planCreationDateInMS":1678684478000,"firstName":"hardik","lastName":"bhow (5321)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_726145_thumbnail.jpg?v=1677828222000#hardik","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUserFname":"hardik111","lastUpdatedUserLname":"Asite","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2119100$$ZLtqG9","projectName":"Weekly Checklist builder - QA","planId":"5187$$8dSZmw","planTitle":"Testing","percentageCompletion":2,"createdBy":"850847","createdByUserid":"850847$$QxM5D7","planCreationDate":"06-Jun-2022#06:23 PST","createdByName":"Reegan Kothari(5311), Asite Solutions","lastupdatedate":"23-Feb-2023#01:33 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1677144783000,"planCreationDateInMS":1654521822000,"firstName":"Reegan","lastName":"Kothari(5311)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_850847_thumbnail.jpg?v=1537161255000#Reegan","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5263$$mK4yKt","planTitle":"Test-Pack","percentageCompletion":4,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"14-Oct-2022#03:56 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"01-Feb-2023#05:10 PST","updatedById":"1116052$$y5Ej8I","lastupdatedbyName":"jatin diyora, Asite Solutions","updatedDateInMS":1675257045000,"planCreationDateInMS":1665744984000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/no_image.jpg#jatin","lastUpdatedUserFname":"jatin","lastUpdatedUserLname":"diyora","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5292$$RZTsO4","planTitle":"HB test plan","percentageCompletion":4,"createdBy":"726145","createdByUserid":"726145$$cyKQQi","planCreationDate":"27-Dec-2022#02:34 PST","createdByName":"hardik bhow (5321), Asite Solutions","lastupdatedate":"19-Jan-2023#05:15 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1674134117000,"planCreationDateInMS":1672137246000,"firstName":"hardik","lastName":"bhow (5321)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_726145_thumbnail.jpg?v=1677828222000#hardik","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5180$$S4QLYB","planTitle":"kphtml test","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"11-May-2022#23:32 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"01-Nov-2022#06:32 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1667309534000,"planCreationDateInMS":1652337151000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5193$$VhmoWf","planTitle":"Test API","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"27-Jun-2022#21:31 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"03-Oct-2022#02:29 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1664789355000,"planCreationDateInMS":1656390686000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5156$$3O17VQ","planTitle":"Test_Vijay_Edit","percentageCompletion":1,"createdBy":"859155","createdByUserid":"859155$$QpfnyM","planCreationDate":"24-Feb-2022#01:03 PST","createdByName":"Saurabh Banethia (5327), Asite Solutions","lastupdatedate":"28-Sep-2022#23:47 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1664434040000,"planCreationDateInMS":1645693408000,"firstName":"Saurabh","lastName":"Banethia (5327)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_859155_thumbnail.jpg?v=1669201730000#Saurabh","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2093498$$TAOd0E","projectName":"Gtest - UK","planId":"1236$$lZt3xA","planTitle":"TEST 12072021","percentageCompletion":0,"createdBy":"712144","createdByUserid":"712144$$e3hvZw","planCreationDate":"11-Jul-2021#23:20 PST","createdByName":"Gagan Chapadia (5364), Asite Solutions","lastupdatedate":"25-Jul-2022#00:19 PST","updatedById":"712144$$e3hvZw","lastupdatedbyName":"Gagan Chapadia (5364), Asite Solutions","updatedDateInMS":1658733552000,"planCreationDateInMS":1626070857000,"firstName":"Gagan","lastName":"Chapadia (5364)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUserFname":"Gagan","lastUpdatedUserLname":"Chapadia (5364)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5196$$Cs5QI4","planTitle":"Test ✔️ ☆","percentageCompletion":0,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"06-Jul-2022#02:53 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"06-Jul-2022#02:55 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1657101352000,"planCreationDateInMS":1657101206000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5063$$PuoiKW","planTitle":"Vijay-DeltaSync-Test","percentageCompletion":1,"createdBy":"707447","createdByUserid":"707447$$3uo0We","planCreationDate":"06-Oct-2021#00:15 PST","createdByName":"Vijay Mavadiya (5336), Asite Solutions","lastupdatedate":"23-May-2022#03:53 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1653303209000,"planCreationDateInMS":1633504512000,"firstName":"Vijay","lastName":"Mavadiya (5336)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_707447_thumbnail.jpg?v=1650517948000#Vijay","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5119$$vh01RZ","planTitle":"Test Asite","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"30-Jan-2022#21:03 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"22-Feb-2022#23:57 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1645603043000,"planCreationDateInMS":1643605426000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"256$$tkUhI1","planTitle":"kp test","percentageCompletion":4,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"02-Jun-2021#00:21 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"10-Feb-2022#02:53 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1644490391000,"planCreationDateInMS":1622618465000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5128$$ryeJhg","planTitle":"test plan","percentageCompletion":0,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"04-Feb-2022#04:43 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"07-Feb-2022#07:38 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1644248333000,"planCreationDateInMS":1643978635000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5086$$ZtssRN","planTitle":"Test Plan DD","percentageCompletion":5,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"19-Nov-2021#00:02 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"06-Feb-2022#23:10 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1644217815000,"planCreationDateInMS":1637308938000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5111$$QjMilB","planTitle":"Test dalet","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"24-Jan-2022#01:35 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"27-Jan-2022#05:06 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1643288818000,"planCreationDateInMS":1643016937000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5110$$EFR3Ab","planTitle":"Test 1 plan","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"20-Jan-2022#04:46 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"20-Jan-2022#04:46 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1642682784000,"planCreationDateInMS":1642682784000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5035$$mABT6y","planTitle":"test","percentageCompletion":0,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"23-Sep-2021#01:49 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"23-Sep-2021#01:49 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1632386981000,"planCreationDateInMS":1632386981000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5011$$Z7N8O2","planTitle":"testtesttest","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"13-Sep-2021#22:59 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"13-Sep-2021#23:01 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1631599273000,"planCreationDateInMS":1631599199000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"4533$$7nYg2k","planTitle":"Percentage test","percentageCompletion":3,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"23-Jul-2021#02:20 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"07-Sep-2021#05:46 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1631018799000,"planCreationDateInMS":1627032010000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"4517$$CjPT33","planTitle":"Test123","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"22-Jul-2021#07:19 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"22-Jul-2021#07:19 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1626963583000,"planCreationDateInMS":1626963583000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"1198$$k2CkpP","planTitle":"Test Cdp 0907","percentageCompletion":3,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"08-Jul-2021#23:10 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"16-Jul-2021#03:09 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1626430166000,"planCreationDateInMS":1625811021000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"1872$$gYXdI1","planTitle":"test draft 345","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"15-Jul-2021#01:51 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"15-Jul-2021#01:58 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1626339505000,"planCreationDateInMS":1626339077000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"288$$6rxMNr","planTitle":"test site forms","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"12-Jun-2021#04:02 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"12-Jun-2021#04:02 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1623495773000,"planCreationDateInMS":1623495773000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2093498$$TAOd0E","projectName":"Gtest - UK","planId":"188$$YrrT5D","planTitle":"testedit","percentageCompletion":0,"createdBy":"712144","createdByUserid":"712144$$e3hvZw","planCreationDate":"11-May-2021#23:21 PST","createdByName":"Gagan Chapadia (5364), Asite Solutions","lastupdatedate":"11-May-2021#23:21 PST","updatedById":"712144$$e3hvZw","lastupdatedbyName":"Gagan Chapadia (5364), Asite Solutions","updatedDateInMS":1620800515000,"planCreationDateInMS":1620800515000,"firstName":"Gagan","lastName":"Chapadia (5364)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUserFname":"Gagan","lastUpdatedUserLname":"Chapadia (5364)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true}],"sortField":"lastupdatedate","sortFieldType":"timestamp","sortOrder":"desc","editable":true,"isIncludeSubFolder":true,"totalListData":0}

class QualitySearchVo {
  QualitySearchVo({
      FilterResponse? filterResponse,
      FilterData? filterData,}){
    _filterResponse = filterResponse;
    _filterData = filterData;
}

  QualitySearchVo.fromJson(dynamic value) {
    dynamic json = jsonDecode(value);
    _filterResponse = json['filterResponse'] != null ? FilterResponse.fromJson(json['filterResponse']) : null;
    _filterData = json['filterData'] != null ? FilterData.fromJson(json['filterData']) : null;
  }
  FilterResponse? _filterResponse;
  FilterData? _filterData;
QualitySearchVo copyWith({  FilterResponse? filterResponse,
  FilterData? filterData,
}) => QualitySearchVo(  filterResponse: filterResponse ?? _filterResponse,
  filterData: filterData ?? _filterData,
);
  FilterResponse? get filterResponse => _filterResponse;
  FilterData? get filterData => _filterData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_filterResponse != null) {
      map['filterResponse'] = _filterResponse?.toJson();
    }
    if (_filterData != null) {
      map['filterData'] = _filterData?.toJson();
    }
    return map;
  }

}

/// totalDocs : 45
/// recordBatchSize : 250
/// listingType : 134
/// currentPageNo : 1
/// recordStartFrom : 0
/// columnHeader : [{"id":"0","fieldName":"planId","solrIndexfieldName":"id","colDisplayName":"","colType":"checkbox","userIndex":0,"imgName":"","tooltipSrc":"","dataType":"checkbox","function":"","funParams":"","wrapData":"","widthOfColumn":35,"isSortSupported":false,"isCustomAttributeColumn":false,"isActive":false},{"id":"6","fieldName":"percentageCompletion","solrIndexfieldName":"percentage_completion","colDisplayName":"% Completion","colType":"number","userIndex":2,"imgName":"","tooltipSrc":"per-completion","dataType":"number","function":"","funParams":"","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"2","fieldName":"createdByUser","solrIndexfieldName":"created_by_name","colDisplayName":"Created By","colType":"imgwithtext","userIndex":3,"imgName":"","tooltipSrc":"createdByName","dataType":"imgwithtext","function":"showUserContactCard","funParams":"createdByUserid","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"3","fieldName":"planCreationDate","solrIndexfieldName":"plan_creation_date","colDisplayName":"Created Date","colType":"text","userIndex":4,"imgName":"","tooltipSrc":"planCreationDate","dataType":"timestamp","function":"","funParams":"","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"4","fieldName":"lastUpdatedUser","solrIndexfieldName":"last_updated_by_name","colDisplayName":"Last Updated By","colType":"imgwithtext","userIndex":5,"imgName":"","tooltipSrc":"lastupdatedbyName","dataType":"imgwithtext","function":"showUserContactCard","funParams":"updatedById","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"5","fieldName":"lastupdatedate","solrIndexfieldName":"last_updated_on","colDisplayName":"Last Updated On","colType":"text","userIndex":6,"imgName":"","tooltipSrc":"lastupdatedate","dataType":"timestamp","function":"","funParams":"","wrapData":"","widthOfColumn":125,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false},{"id":"1","fieldName":"planTitle","solrIndexfieldName":"title","colDisplayName":"Title","colType":"text","userIndex":1,"imgName":"","tooltipSrc":"title","dataType":"text","function":"viewTestPlan","funParams":"planId, planTitle, projectId, projectName, dcId, percentageCompletion","wrapData":"","widthOfColumn":157,"isSortSupported":true,"isCustomAttributeColumn":false,"isActive":false}]
/// data : [{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5368$$rIc2XS","planTitle":"Test plan 1","percentageCompletion":0,"createdBy":"1906453","createdByUserid":"1906453$$fMqcZy","planCreationDate":"12-Apr-2023#00:11 PST","createdByName":"hardik111 Asite, Asite Solutions Ltd","lastupdatedate":"12-Apr-2023#00:22 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1681284177000,"planCreationDateInMS":1681283465000,"firstName":"hardik111","lastName":"Asite","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5359$$SwSCkv","planTitle":"TestNew","percentageCompletion":3,"createdBy":"1906453","createdByUserid":"1906453$$fMqcZy","planCreationDate":"09-Apr-2023#22:36 PST","createdByName":"hardik111 Asite, Asite Solutions Ltd","lastupdatedate":"11-Apr-2023#05:17 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1681215452000,"planCreationDateInMS":1681104969000,"firstName":"hardik111","lastName":"Asite","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5364$$u6J5a1","planTitle":"TestPerf","percentageCompletion":0,"createdBy":"1925069","createdByUserid":"1925069$$JSw9uw","planCreationDate":"10-Apr-2023#21:21 PST","createdByName":"Shubham Patidar, Asite Solutions","lastupdatedate":"10-Apr-2023#23:27 PST","updatedById":"1925069$$JSw9uw","lastupdatedbyName":"Shubham Patidar, Asite Solutions","updatedDateInMS":1681194450000,"planCreationDateInMS":1681186905000,"firstName":"Shubham","lastName":"Patidar","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/no_image.jpg#Shubham","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/no_image.jpg#Shubham","lastUpdatedUserFname":"Shubham","lastUpdatedUserLname":"Patidar","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"522$$SaytK1","planTitle":"Test Cdp","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"07-Jul-2021#22:15 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1625721313000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5184$$WXsBTb","planTitle":"test","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"24-May-2022#23:44 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1653461071000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5183$$FZpfdC","planTitle":"Test Demo DV0001","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"23-May-2022#03:50 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1653303007000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5176$$DaBBBZ","planTitle":"Test Export Plan DV","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"02-May-2022#03:59 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1651489148000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5136$$duBdBH","planTitle":"testtest","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"17-Feb-2022#04:09 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1645099775000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5034$$QAynNn","planTitle":"Test-1334","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"22-Sep-2021#23:57 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1632380243000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"4620$$ZzV1GS","planTitle":"Test 1093","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"24-Aug-2021#23:07 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1629871656000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"300$$cf4wND","planTitle":"Pin - DV TEst 150601","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"14-Jun-2021#23:41 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623739275000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"293$$nzMoc4","planTitle":"Test0002","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"13-Jun-2021#23:44 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623653067000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"285$$3GH1lU","planTitle":"Test0001","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"11-Jun-2021#08:15 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623424527000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"283$$k00aZP","planTitle":"Test Copy Location 002","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"11-Jun-2021#04:20 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623410424000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"282$$MiSBox","planTitle":"Test Copy Location 001","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"11-Jun-2021#04:06 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1623409589000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"1867$$0vElSF","planTitle":"test draft 123","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"15-Jul-2021#01:49 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"10-Apr-2023#06:13 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1681132421000,"planCreationDateInMS":1626338949000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5353$$8Te2RA","planTitle":"TestPerformance","percentageCompletion":0,"createdBy":"1906453","createdByUserid":"1906453$$fMqcZy","planCreationDate":"05-Apr-2023#21:59 PST","createdByName":"hardik111 Asite, Asite Solutions Ltd","lastupdatedate":"09-Apr-2023#22:47 PST","updatedById":"1906453$$fMqcZy","lastupdatedbyName":"hardik111 Asite, Asite Solutions Ltd","updatedDateInMS":1681105659000,"planCreationDateInMS":1680757169000,"firstName":"hardik111","lastName":"Asite","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUserFname":"hardik111","lastUpdatedUserLname":"Asite","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"4615$$Xjn9co","planTitle":"test","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"20-Aug-2021#03:01 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"07-Apr-2023#05:17 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1680869836000,"planCreationDateInMS":1629453667000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5358$$JvM9fJ","planTitle":"Test Plan","percentageCompletion":1,"createdBy":"2017529","createdByUserid":"2017529$$RfZJh0","planCreationDate":"07-Apr-2023#04:55 PST","createdByName":"Mayur Raval m., Asite Solutions Ltd","lastupdatedate":"07-Apr-2023#05:06 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1680869210000,"planCreationDateInMS":1680868532000,"firstName":"Mayur","lastName":"Raval m.","orgName":"Asite Solutions Ltd","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5346$$wgY078","planTitle":"Test Demo 1022","percentageCompletion":1,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"27-Mar-2023#06:20 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"07-Apr-2023#05:02 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1680868948000,"planCreationDateInMS":1679923233000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5280$$SvVxlK","planTitle":"testquality","percentageCompletion":0,"createdBy":"752058","createdByUserid":"752058$$1ZoQpI","planCreationDate":"14-Nov-2022#21:57 PST","createdByName":"Achal Shah (5361), Asite Solutions","lastupdatedate":"21-Mar-2023#23:30 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1679466646000,"planCreationDateInMS":1668491864000,"firstName":"Achal","lastName":"Shah (5361)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_752058_thumbnail.jpg?v=1657276387000#Achal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5318$$ZqubgZ","planTitle":"hb test1","percentageCompletion":0,"createdBy":"726145","createdByUserid":"726145$$cyKQQi","planCreationDate":"12-Mar-2023#22:14 PST","createdByName":"hardik bhow (5321), Asite Solutions","lastupdatedate":"13-Mar-2023#04:07 PST","updatedById":"1906453$$fMqcZy","lastupdatedbyName":"hardik111 Asite, Asite Solutions Ltd","updatedDateInMS":1678705657000,"planCreationDateInMS":1678684478000,"firstName":"hardik","lastName":"bhow (5321)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_726145_thumbnail.jpg?v=1677828222000#hardik","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111","lastUpdatedUserFname":"hardik111","lastUpdatedUserLname":"Asite","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2119100$$ZLtqG9","projectName":"Weekly Checklist builder - QA","planId":"5187$$8dSZmw","planTitle":"Testing","percentageCompletion":2,"createdBy":"850847","createdByUserid":"850847$$QxM5D7","planCreationDate":"06-Jun-2022#06:23 PST","createdByName":"Reegan Kothari(5311), Asite Solutions","lastupdatedate":"23-Feb-2023#01:33 PST","updatedById":"2017529$$RfZJh0","lastupdatedbyName":"Mayur Raval m., Asite Solutions Ltd","updatedDateInMS":1677144783000,"planCreationDateInMS":1654521822000,"firstName":"Reegan","lastName":"Kothari(5311)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions Ltd","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_850847_thumbnail.jpg?v=1537161255000#Reegan","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1679404525000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval m.","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5263$$mK4yKt","planTitle":"Test-Pack","percentageCompletion":4,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"14-Oct-2022#03:56 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"01-Feb-2023#05:10 PST","updatedById":"1116052$$y5Ej8I","lastupdatedbyName":"jatin diyora, Asite Solutions","updatedDateInMS":1675257045000,"planCreationDateInMS":1665744984000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/no_image.jpg#jatin","lastUpdatedUserFname":"jatin","lastUpdatedUserLname":"diyora","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5292$$RZTsO4","planTitle":"HB test plan","percentageCompletion":4,"createdBy":"726145","createdByUserid":"726145$$cyKQQi","planCreationDate":"27-Dec-2022#02:34 PST","createdByName":"hardik bhow (5321), Asite Solutions","lastupdatedate":"19-Jan-2023#05:15 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1674134117000,"planCreationDateInMS":1672137246000,"firstName":"hardik","lastName":"bhow (5321)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_726145_thumbnail.jpg?v=1677828222000#hardik","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5180$$S4QLYB","planTitle":"kphtml test","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"11-May-2022#23:32 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"01-Nov-2022#06:32 PST","updatedById":"1933873$$HSE8HZ","lastupdatedbyName":"Jinal Vithalapara, Asite Solutions","updatedDateInMS":1667309534000,"planCreationDateInMS":1652337151000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1933873_thumbnail.jpg?v=1681192261000#Jinal","lastUpdatedUserFname":"Jinal","lastUpdatedUserLname":"Vithalapara","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5193$$VhmoWf","planTitle":"Test API","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"27-Jun-2022#21:31 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"03-Oct-2022#02:29 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1664789355000,"planCreationDateInMS":1656390686000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5156$$3O17VQ","planTitle":"Test_Vijay_Edit","percentageCompletion":1,"createdBy":"859155","createdByUserid":"859155$$QpfnyM","planCreationDate":"24-Feb-2022#01:03 PST","createdByName":"Saurabh Banethia (5327), Asite Solutions","lastupdatedate":"28-Sep-2022#23:47 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1664434040000,"planCreationDateInMS":1645693408000,"firstName":"Saurabh","lastName":"Banethia (5327)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_859155_thumbnail.jpg?v=1669201730000#Saurabh","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2093498$$TAOd0E","projectName":"Gtest - UK","planId":"1236$$lZt3xA","planTitle":"TEST 12072021","percentageCompletion":0,"createdBy":"712144","createdByUserid":"712144$$e3hvZw","planCreationDate":"11-Jul-2021#23:20 PST","createdByName":"Gagan Chapadia (5364), Asite Solutions","lastupdatedate":"25-Jul-2022#00:19 PST","updatedById":"712144$$e3hvZw","lastupdatedbyName":"Gagan Chapadia (5364), Asite Solutions","updatedDateInMS":1658733552000,"planCreationDateInMS":1626070857000,"firstName":"Gagan","lastName":"Chapadia (5364)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUserFname":"Gagan","lastUpdatedUserLname":"Chapadia (5364)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5196$$Cs5QI4","planTitle":"Test ✔️ ☆","percentageCompletion":0,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"06-Jul-2022#02:53 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"06-Jul-2022#02:55 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1657101352000,"planCreationDateInMS":1657101206000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5063$$PuoiKW","planTitle":"Vijay-DeltaSync-Test","percentageCompletion":1,"createdBy":"707447","createdByUserid":"707447$$3uo0We","planCreationDate":"06-Oct-2021#00:15 PST","createdByName":"Vijay Mavadiya (5336), Asite Solutions","lastupdatedate":"23-May-2022#03:53 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1653303209000,"planCreationDateInMS":1633504512000,"firstName":"Vijay","lastName":"Mavadiya (5336)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_707447_thumbnail.jpg?v=1650517948000#Vijay","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5119$$vh01RZ","planTitle":"Test Asite","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"30-Jan-2022#21:03 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"22-Feb-2022#23:57 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1645603043000,"planCreationDateInMS":1643605426000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"256$$tkUhI1","planTitle":"kp test","percentageCompletion":4,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"02-Jun-2021#00:21 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"10-Feb-2022#02:53 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1644490391000,"planCreationDateInMS":1622618465000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5128$$ryeJhg","planTitle":"test plan","percentageCompletion":0,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"04-Feb-2022#04:43 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"07-Feb-2022#07:38 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1644248333000,"planCreationDateInMS":1643978635000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"5086$$ZtssRN","planTitle":"Test Plan DD","percentageCompletion":5,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"19-Nov-2021#00:02 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"06-Feb-2022#23:10 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1644217815000,"planCreationDateInMS":1637308938000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5111$$QjMilB","planTitle":"Test dalet","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"24-Jan-2022#01:35 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"27-Jan-2022#05:06 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1643288818000,"planCreationDateInMS":1643016937000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5110$$EFR3Ab","planTitle":"Test 1 plan","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"20-Jan-2022#04:46 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"20-Jan-2022#04:46 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1642682784000,"planCreationDateInMS":1642682784000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5035$$mABT6y","planTitle":"test","percentageCompletion":0,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"23-Sep-2021#01:49 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"23-Sep-2021#01:49 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1632386981000,"planCreationDateInMS":1632386981000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"5011$$Z7N8O2","planTitle":"testtesttest","percentageCompletion":0,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"13-Sep-2021#22:59 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"13-Sep-2021#23:01 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1631599273000,"planCreationDateInMS":1631599199000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2089700$$pOgoCK","projectName":"KrupalField19.8UK","planId":"4533$$7nYg2k","planTitle":"Percentage test","percentageCompletion":3,"createdBy":"758244","createdByUserid":"758244$$9jLIUF","planCreationDate":"23-Jul-2021#02:20 PST","createdByName":"Krupal Patel (5345), Asite Solutions","lastupdatedate":"07-Sep-2021#05:46 PST","updatedById":"758244$$9jLIUF","lastupdatedbyName":"Krupal Patel (5345), Asite Solutions","updatedDateInMS":1631018799000,"planCreationDateInMS":1627032010000,"firstName":"Krupal","lastName":"Patel (5345)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal","lastUpdatedUserFname":"Krupal","lastUpdatedUserLname":"Patel (5345)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"4517$$CjPT33","planTitle":"Test123","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"22-Jul-2021#07:19 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"22-Jul-2021#07:19 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1626963583000,"planCreationDateInMS":1626963583000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"1198$$k2CkpP","planTitle":"Test Cdp 0907","percentageCompletion":3,"createdBy":"808581","createdByUserid":"808581$$WwCUWm","planCreationDate":"08-Jul-2021#23:10 PST","createdByName":"Mayur Raval (5372), Asite Solutions","lastupdatedate":"16-Jul-2021#03:09 PST","updatedById":"808581$$WwCUWm","lastupdatedbyName":"Mayur Raval (5372), Asite Solutions","updatedDateInMS":1626430166000,"planCreationDateInMS":1625811021000,"firstName":"Mayur","lastName":"Raval (5372)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_808581_thumbnail.jpg?v=1673327483000#Mayur","lastUpdatedUserFname":"Mayur","lastUpdatedUserLname":"Raval (5372)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"1872$$gYXdI1","planTitle":"test draft 345","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"15-Jul-2021#01:51 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"15-Jul-2021#01:58 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1626339505000,"planCreationDateInMS":1626339077000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2116416$$81EMhn","projectName":"!!PIN_ANY_APP_TYPE_20_9","planId":"288$$6rxMNr","planTitle":"test site forms","percentageCompletion":0,"createdBy":"514806","createdByUserid":"514806$$EWGZh0","planCreationDate":"12-Jun-2021#04:02 PST","createdByName":"Dhaval Vekaria (5226), Asite Solutions","lastupdatedate":"12-Jun-2021#04:02 PST","updatedById":"514806$$EWGZh0","lastupdatedbyName":"Dhaval Vekaria (5226), Asite Solutions","updatedDateInMS":1623495773000,"planCreationDateInMS":1623495773000,"firstName":"Dhaval","lastName":"Vekaria (5226)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","lastUpdatedUserFname":"Dhaval","lastUpdatedUserLname":"Vekaria (5226)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true},{"id":0,"projectId":"2093498$$TAOd0E","projectName":"Gtest - UK","planId":"188$$YrrT5D","planTitle":"testedit","percentageCompletion":0,"createdBy":"712144","createdByUserid":"712144$$e3hvZw","planCreationDate":"11-May-2021#23:21 PST","createdByName":"Gagan Chapadia (5364), Asite Solutions","lastupdatedate":"11-May-2021#23:21 PST","updatedById":"712144$$e3hvZw","lastupdatedbyName":"Gagan Chapadia (5364), Asite Solutions","updatedDateInMS":1620800515000,"planCreationDateInMS":1620800515000,"firstName":"Gagan","lastName":"Chapadia (5364)","orgName":"Asite Solutions","lastUpdatedUserOrg":"Asite Solutions","createdByUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUser":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_712144_thumbnail.jpg?v=1521091826000#Gagan","lastUpdatedUserFname":"Gagan","lastUpdatedUserLname":"Chapadia (5364)","dcId":1,"lastSyncDate":"2023-04-17 13:08:09","generateURI":true}]
/// sortField : "lastupdatedate"
/// sortFieldType : "timestamp"
/// sortOrder : "desc"
/// editable : true
/// isIncludeSubFolder : true
/// totalListData : 0

class FilterData {
  FilterData({
      num? totalDocs, 
      num? recordBatchSize, 
      num? listingType, 
      num? currentPageNo, 
      num? recordStartFrom, 
      List<ColumnHeader>? columnHeader, 
      List<Data>? data,
      String? sortField, 
      String? sortFieldType, 
      String? sortOrder, 
      bool? editable, 
      bool? isIncludeSubFolder, 
      num? totalListData,}){
    _totalDocs = totalDocs;
    _recordBatchSize = recordBatchSize;
    _listingType = listingType;
    _currentPageNo = currentPageNo;
    _recordStartFrom = recordStartFrom;
    _columnHeader = columnHeader;
    _data = data;
    _sortField = sortField;
    _sortFieldType = sortFieldType;
    _sortOrder = sortOrder;
    _editable = editable;
    _isIncludeSubFolder = isIncludeSubFolder;
    _totalListData = totalListData;
}

  FilterData.fromJson(dynamic json) {
    _totalDocs = json['totalDocs'];
    _recordBatchSize = json['recordBatchSize'];
    _listingType = json['listingType'];
    _currentPageNo = json['currentPageNo'];
    _recordStartFrom = json['recordStartFrom'];
    if (json['columnHeader'] != null) {
      _columnHeader = [];
      json['columnHeader'].forEach((v) {
        _columnHeader?.add(ColumnHeader.fromJson(v));
      });
    }
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _sortField = json['sortField'];
    _sortFieldType = json['sortFieldType'];
    _sortOrder = json['sortOrder'];
    _editable = json['editable'];
    _isIncludeSubFolder = json['isIncludeSubFolder'];
    _totalListData = json['totalListData'];
  }
  num? _totalDocs;
  num? _recordBatchSize;
  num? _listingType;
  num? _currentPageNo;
  num? _recordStartFrom;
  List<ColumnHeader>? _columnHeader;
  List<Data>? _data;
  String? _sortField;
  String? _sortFieldType;
  String? _sortOrder;
  bool? _editable;
  bool? _isIncludeSubFolder;
  num? _totalListData;
FilterData copyWith({  num? totalDocs,
  num? recordBatchSize,
  num? listingType,
  num? currentPageNo,
  num? recordStartFrom,
  List<ColumnHeader>? columnHeader,
  List<Data>? data,
  String? sortField,
  String? sortFieldType,
  String? sortOrder,
  bool? editable,
  bool? isIncludeSubFolder,
  num? totalListData,
}) => FilterData(  totalDocs: totalDocs ?? _totalDocs,
  recordBatchSize: recordBatchSize ?? _recordBatchSize,
  listingType: listingType ?? _listingType,
  currentPageNo: currentPageNo ?? _currentPageNo,
  recordStartFrom: recordStartFrom ?? _recordStartFrom,
  columnHeader: columnHeader ?? _columnHeader,
  data: data ?? _data,
  sortField: sortField ?? _sortField,
  sortFieldType: sortFieldType ?? _sortFieldType,
  sortOrder: sortOrder ?? _sortOrder,
  editable: editable ?? _editable,
  isIncludeSubFolder: isIncludeSubFolder ?? _isIncludeSubFolder,
  totalListData: totalListData ?? _totalListData,
);
  num? get totalDocs => _totalDocs;
  num? get recordBatchSize => _recordBatchSize;
  num? get listingType => _listingType;
  num? get currentPageNo => _currentPageNo;
  num? get recordStartFrom => _recordStartFrom;
  List<ColumnHeader>? get columnHeader => _columnHeader;
  List<Data>? get data => _data;
  String? get sortField => _sortField;
  String? get sortFieldType => _sortFieldType;
  String? get sortOrder => _sortOrder;
  bool? get editable => _editable;
  bool? get isIncludeSubFolder => _isIncludeSubFolder;
  num? get totalListData => _totalListData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['totalDocs'] = _totalDocs;
    map['recordBatchSize'] = _recordBatchSize;
    map['listingType'] = _listingType;
    map['currentPageNo'] = _currentPageNo;
    map['recordStartFrom'] = _recordStartFrom;
    if (_columnHeader != null) {
      map['columnHeader'] = _columnHeader?.map((v) => v.toJson()).toList();
    }
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['sortField'] = _sortField;
    map['sortFieldType'] = _sortFieldType;
    map['sortOrder'] = _sortOrder;
    map['editable'] = _editable;
    map['isIncludeSubFolder'] = _isIncludeSubFolder;
    map['totalListData'] = _totalListData;
    return map;
  }

}

/// id : 0
/// projectId : "2089700$$pOgoCK"
/// projectName : "KrupalField19.8UK"
/// planId : "5368$$rIc2XS"
/// planTitle : "Test plan 1"
/// percentageCompletion : 0
/// createdBy : "1906453"
/// createdByUserid : "1906453$$fMqcZy"
/// planCreationDate : "12-Apr-2023#00:11 PST"
/// createdByName : "hardik111 Asite, Asite Solutions Ltd"
/// lastupdatedate : "12-Apr-2023#00:22 PST"
/// updatedById : "758244$$9jLIUF"
/// lastupdatedbyName : "Krupal Patel (5345), Asite Solutions"
/// updatedDateInMS : 1681284177000
/// planCreationDateInMS : 1681283465000
/// firstName : "hardik111"
/// lastName : "Asite"
/// orgName : "Asite Solutions Ltd"
/// lastUpdatedUserOrg : "Asite Solutions"
/// createdByUser : "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1680675482000#hardik111"
/// lastUpdatedUser : "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_758244_thumbnail.jpg?v=1679043345000#Krupal"
/// lastUpdatedUserFname : "Krupal"
/// lastUpdatedUserLname : "Patel (5345)"
/// dcId : 1
/// lastSyncDate : "2023-04-17 13:08:09"
/// generateURI : true

/// id : "0"
/// fieldName : "planId"
/// solrIndexfieldName : "id"
/// colDisplayName : ""
/// colType : "checkbox"
/// userIndex : 0
/// imgName : ""
/// tooltipSrc : ""
/// dataType : "checkbox"
/// function : ""
/// funParams : ""
/// wrapData : ""
/// widthOfColumn : 35
/// isSortSupported : false
/// isCustomAttributeColumn : false
/// isActive : false

class ColumnHeader {
  ColumnHeader({
      String? id, 
      String? fieldName, 
      String? solrIndexfieldName, 
      String? colDisplayName, 
      String? colType, 
      num? userIndex, 
      String? imgName, 
      String? tooltipSrc, 
      String? dataType, 
      String? function, 
      String? funParams, 
      String? wrapData, 
      num? widthOfColumn, 
      bool? isSortSupported, 
      bool? isCustomAttributeColumn, 
      bool? isActive,}){
    _id = id;
    _fieldName = fieldName;
    _solrIndexfieldName = solrIndexfieldName;
    _colDisplayName = colDisplayName;
    _colType = colType;
    _userIndex = userIndex;
    _imgName = imgName;
    _tooltipSrc = tooltipSrc;
    _dataType = dataType;
    _function = function;
    _funParams = funParams;
    _wrapData = wrapData;
    _widthOfColumn = widthOfColumn;
    _isSortSupported = isSortSupported;
    _isCustomAttributeColumn = isCustomAttributeColumn;
    _isActive = isActive;
}

  ColumnHeader.fromJson(dynamic json) {
    _id = json['id'];
    _fieldName = json['fieldName'];
    _solrIndexfieldName = json['solrIndexfieldName'];
    _colDisplayName = json['colDisplayName'];
    _colType = json['colType'];
    _userIndex = json['userIndex'];
    _imgName = json['imgName'];
    _tooltipSrc = json['tooltipSrc'];
    _dataType = json['dataType'];
    _function = json['function'];
    _funParams = json['funParams'];
    _wrapData = json['wrapData'];
    _widthOfColumn = json['widthOfColumn'];
    _isSortSupported = json['isSortSupported'];
    _isCustomAttributeColumn = json['isCustomAttributeColumn'];
    _isActive = json['isActive'];
  }
  String? _id;
  String? _fieldName;
  String? _solrIndexfieldName;
  String? _colDisplayName;
  String? _colType;
  num? _userIndex;
  String? _imgName;
  String? _tooltipSrc;
  String? _dataType;
  String? _function;
  String? _funParams;
  String? _wrapData;
  num? _widthOfColumn;
  bool? _isSortSupported;
  bool? _isCustomAttributeColumn;
  bool? _isActive;
ColumnHeader copyWith({  String? id,
  String? fieldName,
  String? solrIndexfieldName,
  String? colDisplayName,
  String? colType,
  num? userIndex,
  String? imgName,
  String? tooltipSrc,
  String? dataType,
  String? function,
  String? funParams,
  String? wrapData,
  num? widthOfColumn,
  bool? isSortSupported,
  bool? isCustomAttributeColumn,
  bool? isActive,
}) => ColumnHeader(  id: id ?? _id,
  fieldName: fieldName ?? _fieldName,
  solrIndexfieldName: solrIndexfieldName ?? _solrIndexfieldName,
  colDisplayName: colDisplayName ?? _colDisplayName,
  colType: colType ?? _colType,
  userIndex: userIndex ?? _userIndex,
  imgName: imgName ?? _imgName,
  tooltipSrc: tooltipSrc ?? _tooltipSrc,
  dataType: dataType ?? _dataType,
  function: function ?? _function,
  funParams: funParams ?? _funParams,
  wrapData: wrapData ?? _wrapData,
  widthOfColumn: widthOfColumn ?? _widthOfColumn,
  isSortSupported: isSortSupported ?? _isSortSupported,
  isCustomAttributeColumn: isCustomAttributeColumn ?? _isCustomAttributeColumn,
  isActive: isActive ?? _isActive,
);
  String? get id => _id;
  String? get fieldName => _fieldName;
  String? get solrIndexfieldName => _solrIndexfieldName;
  String? get colDisplayName => _colDisplayName;
  String? get colType => _colType;
  num? get userIndex => _userIndex;
  String? get imgName => _imgName;
  String? get tooltipSrc => _tooltipSrc;
  String? get dataType => _dataType;
  String? get function => _function;
  String? get funParams => _funParams;
  String? get wrapData => _wrapData;
  num? get widthOfColumn => _widthOfColumn;
  bool? get isSortSupported => _isSortSupported;
  bool? get isCustomAttributeColumn => _isCustomAttributeColumn;
  bool? get isActive => _isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['fieldName'] = _fieldName;
    map['solrIndexfieldName'] = _solrIndexfieldName;
    map['colDisplayName'] = _colDisplayName;
    map['colType'] = _colType;
    map['userIndex'] = _userIndex;
    map['imgName'] = _imgName;
    map['tooltipSrc'] = _tooltipSrc;
    map['dataType'] = _dataType;
    map['function'] = _function;
    map['funParams'] = _funParams;
    map['wrapData'] = _wrapData;
    map['widthOfColumn'] = _widthOfColumn;
    map['isSortSupported'] = _isSortSupported;
    map['isCustomAttributeColumn'] = _isCustomAttributeColumn;
    map['isActive'] = _isActive;
    return map;
  }

}

/// filterVOs : [{"id":2538478,"userId":2017529,"filterName":"Unsaved Filter","listingTypeId":134,"subListingTypeId":1,"isUnsavedFilter":true,"creationDate":"2023-04-17 13:08:08.903","filterQueryVOs":[{"id":14333411,"filterId":2538478,"fieldName":"summary","operatorId":11,"logicalOperator":"null","sequenceId":1,"returnIndexFields":"null","dataType":"Text","solrCollections":"-1","labelName":"Contains Text","optionalValues":"null","popupTo":{"totalDocs":0,"recordBatchSize":0,"data":[{"id":"test","value":"test","dataCenterId":0,"isSelected":true,"imgId":-1,"isActive":true}],"isSortRequired":true,"isReviewEnableProjectSelected":false,"isAmessageProjectSelected":false,"generateURI":true},"indexField":"summary","isCustomAttribute":false,"inputDataTypeId":0,"isBlankSearchAllowed":true,"supportDashboardWidget":false,"isMultipleAttributeWithSameName":false,"digitSeparatorEnabled":false,"generateURI":true}],"isFavorite":false,"isRecent":false,"isMyAction":false,"docCount":0,"isEditable":true,"isShared":false,"originatorName":"Mayur Raval m.","originatorId":2017529,"userAccesibleDCIds":[1],"isAccessByDashboardShareOnly":false,"dueDateId":0,"generateURI":true}]

class FilterResponse {
  FilterResponse({
      List<FilterVOs>? filterVOs,}){
    _filterVOs = filterVOs;
}

  FilterResponse.fromJson(dynamic json) {
    if (json['filterVOs'] != null) {
      _filterVOs = [];
      json['filterVOs'].forEach((v) {
        _filterVOs?.add(FilterVOs.fromJson(v));
      });
    }
  }
  List<FilterVOs>? _filterVOs;
FilterResponse copyWith({  List<FilterVOs>? filterVOs,
}) => FilterResponse(  filterVOs: filterVOs ?? _filterVOs,
);
  List<FilterVOs>? get filterVOs => _filterVOs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_filterVOs != null) {
      map['filterVOs'] = _filterVOs?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 2538478
/// userId : 2017529
/// filterName : "Unsaved Filter"
/// listingTypeId : 134
/// subListingTypeId : 1
/// isUnsavedFilter : true
/// creationDate : "2023-04-17 13:08:08.903"
/// filterQueryVOs : [{"id":14333411,"filterId":2538478,"fieldName":"summary","operatorId":11,"logicalOperator":"null","sequenceId":1,"returnIndexFields":"null","dataType":"Text","solrCollections":"-1","labelName":"Contains Text","optionalValues":"null","popupTo":{"totalDocs":0,"recordBatchSize":0,"data":[{"id":"test","value":"test","dataCenterId":0,"isSelected":true,"imgId":-1,"isActive":true}],"isSortRequired":true,"isReviewEnableProjectSelected":false,"isAmessageProjectSelected":false,"generateURI":true},"indexField":"summary","isCustomAttribute":false,"inputDataTypeId":0,"isBlankSearchAllowed":true,"supportDashboardWidget":false,"isMultipleAttributeWithSameName":false,"digitSeparatorEnabled":false,"generateURI":true}]
/// isFavorite : false
/// isRecent : false
/// isMyAction : false
/// docCount : 0
/// isEditable : true
/// isShared : false
/// originatorName : "Mayur Raval m."
/// originatorId : 2017529
/// userAccesibleDCIds : [1]
/// isAccessByDashboardShareOnly : false
/// dueDateId : 0
/// generateURI : true

class FilterVOs {
  FilterVOs({
      num? id, 
      num? userId, 
      String? filterName, 
      num? listingTypeId, 
      num? subListingTypeId, 
      bool? isUnsavedFilter, 
      String? creationDate, 
      List<FilterQueryVOs>? filterQueryVOs, 
      bool? isFavorite, 
      bool? isRecent, 
      bool? isMyAction, 
      num? docCount, 
      bool? isEditable, 
      bool? isShared, 
      String? originatorName, 
      num? originatorId, 
      List<num>? userAccesibleDCIds, 
      bool? isAccessByDashboardShareOnly, 
      num? dueDateId, 
      bool? generateURI,}){
    _id = id;
    _userId = userId;
    _filterName = filterName;
    _listingTypeId = listingTypeId;
    _subListingTypeId = subListingTypeId;
    _isUnsavedFilter = isUnsavedFilter;
    _creationDate = creationDate;
    _filterQueryVOs = filterQueryVOs;
    _isFavorite = isFavorite;
    _isRecent = isRecent;
    _isMyAction = isMyAction;
    _docCount = docCount;
    _isEditable = isEditable;
    _isShared = isShared;
    _originatorName = originatorName;
    _originatorId = originatorId;
    _userAccesibleDCIds = userAccesibleDCIds;
    _isAccessByDashboardShareOnly = isAccessByDashboardShareOnly;
    _dueDateId = dueDateId;
    _generateURI = generateURI;
}

  FilterVOs.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['userId'];
    _filterName = json['filterName'];
    _listingTypeId = json['listingTypeId'];
    _subListingTypeId = json['subListingTypeId'];
    _isUnsavedFilter = json['isUnsavedFilter'];
    _creationDate = json['creationDate'];
    if (json['filterQueryVOs'] != null) {
      _filterQueryVOs = [];
      json['filterQueryVOs'].forEach((v) {
        _filterQueryVOs?.add(FilterQueryVOs.fromJson(v));
      });
    }
    _isFavorite = json['isFavorite'];
    _isRecent = json['isRecent'];
    _isMyAction = json['isMyAction'];
    _docCount = json['docCount'];
    _isEditable = json['isEditable'];
    _isShared = json['isShared'];
    _originatorName = json['originatorName'];
    _originatorId = json['originatorId'];
    _userAccesibleDCIds = json['userAccesibleDCIds'] != null ? json['userAccesibleDCIds'].cast<num>() : [];
    _isAccessByDashboardShareOnly = json['isAccessByDashboardShareOnly'];
    _dueDateId = json['dueDateId'];
    _generateURI = json['generateURI'];
  }
  num? _id;
  num? _userId;
  String? _filterName;
  num? _listingTypeId;
  num? _subListingTypeId;
  bool? _isUnsavedFilter;
  String? _creationDate;
  List<FilterQueryVOs>? _filterQueryVOs;
  bool? _isFavorite;
  bool? _isRecent;
  bool? _isMyAction;
  num? _docCount;
  bool? _isEditable;
  bool? _isShared;
  String? _originatorName;
  num? _originatorId;
  List<num>? _userAccesibleDCIds;
  bool? _isAccessByDashboardShareOnly;
  num? _dueDateId;
  bool? _generateURI;
FilterVOs copyWith({  num? id,
  num? userId,
  String? filterName,
  num? listingTypeId,
  num? subListingTypeId,
  bool? isUnsavedFilter,
  String? creationDate,
  List<FilterQueryVOs>? filterQueryVOs,
  bool? isFavorite,
  bool? isRecent,
  bool? isMyAction,
  num? docCount,
  bool? isEditable,
  bool? isShared,
  String? originatorName,
  num? originatorId,
  List<num>? userAccesibleDCIds,
  bool? isAccessByDashboardShareOnly,
  num? dueDateId,
  bool? generateURI,
}) => FilterVOs(  id: id ?? _id,
  userId: userId ?? _userId,
  filterName: filterName ?? _filterName,
  listingTypeId: listingTypeId ?? _listingTypeId,
  subListingTypeId: subListingTypeId ?? _subListingTypeId,
  isUnsavedFilter: isUnsavedFilter ?? _isUnsavedFilter,
  creationDate: creationDate ?? _creationDate,
  filterQueryVOs: filterQueryVOs ?? _filterQueryVOs,
  isFavorite: isFavorite ?? _isFavorite,
  isRecent: isRecent ?? _isRecent,
  isMyAction: isMyAction ?? _isMyAction,
  docCount: docCount ?? _docCount,
  isEditable: isEditable ?? _isEditable,
  isShared: isShared ?? _isShared,
  originatorName: originatorName ?? _originatorName,
  originatorId: originatorId ?? _originatorId,
  userAccesibleDCIds: userAccesibleDCIds ?? _userAccesibleDCIds,
  isAccessByDashboardShareOnly: isAccessByDashboardShareOnly ?? _isAccessByDashboardShareOnly,
  dueDateId: dueDateId ?? _dueDateId,
  generateURI: generateURI ?? _generateURI,
);
  num? get id => _id;
  num? get userId => _userId;
  String? get filterName => _filterName;
  num? get listingTypeId => _listingTypeId;
  num? get subListingTypeId => _subListingTypeId;
  bool? get isUnsavedFilter => _isUnsavedFilter;
  String? get creationDate => _creationDate;
  List<FilterQueryVOs>? get filterQueryVOs => _filterQueryVOs;
  bool? get isFavorite => _isFavorite;
  bool? get isRecent => _isRecent;
  bool? get isMyAction => _isMyAction;
  num? get docCount => _docCount;
  bool? get isEditable => _isEditable;
  bool? get isShared => _isShared;
  String? get originatorName => _originatorName;
  num? get originatorId => _originatorId;
  List<num>? get userAccesibleDCIds => _userAccesibleDCIds;
  bool? get isAccessByDashboardShareOnly => _isAccessByDashboardShareOnly;
  num? get dueDateId => _dueDateId;
  bool? get generateURI => _generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['userId'] = _userId;
    map['filterName'] = _filterName;
    map['listingTypeId'] = _listingTypeId;
    map['subListingTypeId'] = _subListingTypeId;
    map['isUnsavedFilter'] = _isUnsavedFilter;
    map['creationDate'] = _creationDate;
    if (_filterQueryVOs != null) {
      map['filterQueryVOs'] = _filterQueryVOs?.map((v) => v.toJson()).toList();
    }
    map['isFavorite'] = _isFavorite;
    map['isRecent'] = _isRecent;
    map['isMyAction'] = _isMyAction;
    map['docCount'] = _docCount;
    map['isEditable'] = _isEditable;
    map['isShared'] = _isShared;
    map['originatorName'] = _originatorName;
    map['originatorId'] = _originatorId;
    map['userAccesibleDCIds'] = _userAccesibleDCIds;
    map['isAccessByDashboardShareOnly'] = _isAccessByDashboardShareOnly;
    map['dueDateId'] = _dueDateId;
    map['generateURI'] = _generateURI;
    return map;
  }

}

/// id : 14333411
/// filterId : 2538478
/// fieldName : "summary"
/// operatorId : 11
/// logicalOperator : "null"
/// sequenceId : 1
/// returnIndexFields : "null"
/// dataType : "Text"
/// solrCollections : "-1"
/// labelName : "Contains Text"
/// optionalValues : "null"
/// popupTo : {"totalDocs":0,"recordBatchSize":0,"data":[{"id":"test","value":"test","dataCenterId":0,"isSelected":true,"imgId":-1,"isActive":true}],"isSortRequired":true,"isReviewEnableProjectSelected":false,"isAmessageProjectSelected":false,"generateURI":true}
/// indexField : "summary"
/// isCustomAttribute : false
/// inputDataTypeId : 0
/// isBlankSearchAllowed : true
/// supportDashboardWidget : false
/// isMultipleAttributeWithSameName : false
/// digitSeparatorEnabled : false
/// generateURI : true

class FilterQueryVOs {
  FilterQueryVOs({
      num? id, 
      num? filterId, 
      String? fieldName, 
      num? operatorId, 
      String? logicalOperator, 
      num? sequenceId, 
      String? returnIndexFields, 
      String? dataType, 
      String? solrCollections, 
      String? labelName, 
      String? optionalValues, 
      PopupTo? popupTo, 
      String? indexField, 
      bool? isCustomAttribute, 
      num? inputDataTypeId, 
      bool? isBlankSearchAllowed, 
      bool? supportDashboardWidget, 
      bool? isMultipleAttributeWithSameName, 
      bool? digitSeparatorEnabled, 
      bool? generateURI,}){
    _id = id;
    _filterId = filterId;
    _fieldName = fieldName;
    _operatorId = operatorId;
    _logicalOperator = logicalOperator;
    _sequenceId = sequenceId;
    _returnIndexFields = returnIndexFields;
    _dataType = dataType;
    _solrCollections = solrCollections;
    _labelName = labelName;
    _optionalValues = optionalValues;
    _popupTo = popupTo;
    _indexField = indexField;
    _isCustomAttribute = isCustomAttribute;
    _inputDataTypeId = inputDataTypeId;
    _isBlankSearchAllowed = isBlankSearchAllowed;
    _supportDashboardWidget = supportDashboardWidget;
    _isMultipleAttributeWithSameName = isMultipleAttributeWithSameName;
    _digitSeparatorEnabled = digitSeparatorEnabled;
    _generateURI = generateURI;
}

  FilterQueryVOs.fromJson(dynamic json) {
    _id = json['id'];
    _filterId = json['filterId'];
    _fieldName = json['fieldName'];
    _operatorId = json['operatorId'];
    _logicalOperator = json['logicalOperator'];
    _sequenceId = json['sequenceId'];
    _returnIndexFields = json['returnIndexFields'];
    _dataType = json['dataType'];
    _solrCollections = json['solrCollections'];
    _labelName = json['labelName'];
    _optionalValues = json['optionalValues'];
    _popupTo = json['popupTo'] != null ? PopupTo.fromJson(json['popupTo']) : null;
    _indexField = json['indexField'];
    _isCustomAttribute = json['isCustomAttribute'];
    _inputDataTypeId = json['inputDataTypeId'];
    _isBlankSearchAllowed = json['isBlankSearchAllowed'];
    _supportDashboardWidget = json['supportDashboardWidget'];
    _isMultipleAttributeWithSameName = json['isMultipleAttributeWithSameName'];
    _digitSeparatorEnabled = json['digitSeparatorEnabled'];
    _generateURI = json['generateURI'];
  }
  num? _id;
  num? _filterId;
  String? _fieldName;
  num? _operatorId;
  String? _logicalOperator;
  num? _sequenceId;
  String? _returnIndexFields;
  String? _dataType;
  String? _solrCollections;
  String? _labelName;
  String? _optionalValues;
  PopupTo? _popupTo;
  String? _indexField;
  bool? _isCustomAttribute;
  num? _inputDataTypeId;
  bool? _isBlankSearchAllowed;
  bool? _supportDashboardWidget;
  bool? _isMultipleAttributeWithSameName;
  bool? _digitSeparatorEnabled;
  bool? _generateURI;
FilterQueryVOs copyWith({  num? id,
  num? filterId,
  String? fieldName,
  num? operatorId,
  String? logicalOperator,
  num? sequenceId,
  String? returnIndexFields,
  String? dataType,
  String? solrCollections,
  String? labelName,
  String? optionalValues,
  PopupTo? popupTo,
  String? indexField,
  bool? isCustomAttribute,
  num? inputDataTypeId,
  bool? isBlankSearchAllowed,
  bool? supportDashboardWidget,
  bool? isMultipleAttributeWithSameName,
  bool? digitSeparatorEnabled,
  bool? generateURI,
}) => FilterQueryVOs(  id: id ?? _id,
  filterId: filterId ?? _filterId,
  fieldName: fieldName ?? _fieldName,
  operatorId: operatorId ?? _operatorId,
  logicalOperator: logicalOperator ?? _logicalOperator,
  sequenceId: sequenceId ?? _sequenceId,
  returnIndexFields: returnIndexFields ?? _returnIndexFields,
  dataType: dataType ?? _dataType,
  solrCollections: solrCollections ?? _solrCollections,
  labelName: labelName ?? _labelName,
  optionalValues: optionalValues ?? _optionalValues,
  popupTo: popupTo ?? _popupTo,
  indexField: indexField ?? _indexField,
  isCustomAttribute: isCustomAttribute ?? _isCustomAttribute,
  inputDataTypeId: inputDataTypeId ?? _inputDataTypeId,
  isBlankSearchAllowed: isBlankSearchAllowed ?? _isBlankSearchAllowed,
  supportDashboardWidget: supportDashboardWidget ?? _supportDashboardWidget,
  isMultipleAttributeWithSameName: isMultipleAttributeWithSameName ?? _isMultipleAttributeWithSameName,
  digitSeparatorEnabled: digitSeparatorEnabled ?? _digitSeparatorEnabled,
  generateURI: generateURI ?? _generateURI,
);
  num? get id => _id;
  num? get filterId => _filterId;
  String? get fieldName => _fieldName;
  num? get operatorId => _operatorId;
  String? get logicalOperator => _logicalOperator;
  num? get sequenceId => _sequenceId;
  String? get returnIndexFields => _returnIndexFields;
  String? get dataType => _dataType;
  String? get solrCollections => _solrCollections;
  String? get labelName => _labelName;
  String? get optionalValues => _optionalValues;
  PopupTo? get popupTo => _popupTo;
  String? get indexField => _indexField;
  bool? get isCustomAttribute => _isCustomAttribute;
  num? get inputDataTypeId => _inputDataTypeId;
  bool? get isBlankSearchAllowed => _isBlankSearchAllowed;
  bool? get supportDashboardWidget => _supportDashboardWidget;
  bool? get isMultipleAttributeWithSameName => _isMultipleAttributeWithSameName;
  bool? get digitSeparatorEnabled => _digitSeparatorEnabled;
  bool? get generateURI => _generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['filterId'] = _filterId;
    map['fieldName'] = _fieldName;
    map['operatorId'] = _operatorId;
    map['logicalOperator'] = _logicalOperator;
    map['sequenceId'] = _sequenceId;
    map['returnIndexFields'] = _returnIndexFields;
    map['dataType'] = _dataType;
    map['solrCollections'] = _solrCollections;
    map['labelName'] = _labelName;
    map['optionalValues'] = _optionalValues;
    if (_popupTo != null) {
      map['popupTo'] = _popupTo?.toJson();
    }
    map['indexField'] = _indexField;
    map['isCustomAttribute'] = _isCustomAttribute;
    map['inputDataTypeId'] = _inputDataTypeId;
    map['isBlankSearchAllowed'] = _isBlankSearchAllowed;
    map['supportDashboardWidget'] = _supportDashboardWidget;
    map['isMultipleAttributeWithSameName'] = _isMultipleAttributeWithSameName;
    map['digitSeparatorEnabled'] = _digitSeparatorEnabled;
    map['generateURI'] = _generateURI;
    return map;
  }

}

/// totalDocs : 0
/// recordBatchSize : 0
/// data : [{"id":"test","value":"test","dataCenterId":0,"isSelected":true,"imgId":-1,"isActive":true}]
/// isSortRequired : true
/// isReviewEnableProjectSelected : false
/// isAmessageProjectSelected : false
/// generateURI : true

class PopupTo {
  PopupTo({
      num? totalDocs, 
      num? recordBatchSize, 
      List<PopupToData>? data,
      bool? isSortRequired, 
      bool? isReviewEnableProjectSelected, 
      bool? isAmessageProjectSelected, 
      bool? generateURI,}){
    _totalDocs = totalDocs;
    _recordBatchSize = recordBatchSize;
    _data = data;
    _isSortRequired = isSortRequired;
    _isReviewEnableProjectSelected = isReviewEnableProjectSelected;
    _isAmessageProjectSelected = isAmessageProjectSelected;
    _generateURI = generateURI;
}

  PopupTo.fromJson(dynamic json) {
    _totalDocs = json['totalDocs'];
    _recordBatchSize = json['recordBatchSize'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(PopupToData.fromJson(v));
      });
    }
    _isSortRequired = json['isSortRequired'];
    _isReviewEnableProjectSelected = json['isReviewEnableProjectSelected'];
    _isAmessageProjectSelected = json['isAmessageProjectSelected'];
    _generateURI = json['generateURI'];
  }
  num? _totalDocs;
  num? _recordBatchSize;
  List<PopupToData>? _data;
  bool? _isSortRequired;
  bool? _isReviewEnableProjectSelected;
  bool? _isAmessageProjectSelected;
  bool? _generateURI;
PopupTo copyWith({  num? totalDocs,
  num? recordBatchSize,
  List<PopupToData>? data,
  bool? isSortRequired,
  bool? isReviewEnableProjectSelected,
  bool? isAmessageProjectSelected,
  bool? generateURI,
}) => PopupTo(  totalDocs: totalDocs ?? _totalDocs,
  recordBatchSize: recordBatchSize ?? _recordBatchSize,
  data: data ?? _data,
  isSortRequired: isSortRequired ?? _isSortRequired,
  isReviewEnableProjectSelected: isReviewEnableProjectSelected ?? _isReviewEnableProjectSelected,
  isAmessageProjectSelected: isAmessageProjectSelected ?? _isAmessageProjectSelected,
  generateURI: generateURI ?? _generateURI,
);
  num? get totalDocs => _totalDocs;
  num? get recordBatchSize => _recordBatchSize;
  List<PopupToData>? get data => _data;
  bool? get isSortRequired => _isSortRequired;
  bool? get isReviewEnableProjectSelected => _isReviewEnableProjectSelected;
  bool? get isAmessageProjectSelected => _isAmessageProjectSelected;
  bool? get generateURI => _generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['totalDocs'] = _totalDocs;
    map['recordBatchSize'] = _recordBatchSize;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['isSortRequired'] = _isSortRequired;
    map['isReviewEnableProjectSelected'] = _isReviewEnableProjectSelected;
    map['isAmessageProjectSelected'] = _isAmessageProjectSelected;
    map['generateURI'] = _generateURI;
    return map;
  }

}

/// id : "test"
/// value : "test"
/// dataCenterId : 0
/// isSelected : true
/// imgId : -1
/// isActive : true

class PopupToData {
  PopupToData({
      String? id, 
      String? value, 
      num? dataCenterId, 
      bool? isSelected, 
      num? imgId, 
      bool? isActive,}){
    _id = id;
    _value = value;
    _dataCenterId = dataCenterId;
    _isSelected = isSelected;
    _imgId = imgId;
    _isActive = isActive;
}

  PopupToData.fromJson(dynamic json) {
    _id = json['id'];
    _value = json['value'];
    _dataCenterId = json['dataCenterId'];
    _isSelected = json['isSelected'];
    _imgId = json['imgId'];
    _isActive = json['isActive'];
  }
  String? _id;
  String? _value;
  num? _dataCenterId;
  bool? _isSelected;
  num? _imgId;
  bool? _isActive;
  PopupToData copyWith({  String? id,
  String? value,
  num? dataCenterId,
  bool? isSelected,
  num? imgId,
  bool? isActive,
}) => PopupToData(  id: id ?? _id,
  value: value ?? _value,
  dataCenterId: dataCenterId ?? _dataCenterId,
  isSelected: isSelected ?? _isSelected,
  imgId: imgId ?? _imgId,
  isActive: isActive ?? _isActive,
);
  String? get id => _id;
  String? get value => _value;
  num? get dataCenterId => _dataCenterId;
  bool? get isSelected => _isSelected;
  num? get imgId => _imgId;
  bool? get isActive => _isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['value'] = _value;
    map['dataCenterId'] = _dataCenterId;
    map['isSelected'] = _isSelected;
    map['imgId'] = _imgId;
    map['isActive'] = _isActive;
    return map;
  }

}